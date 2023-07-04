// Fix incorrect display SMPTE ST 2084 after incorrect YUV to RGB conversion in EVR Mixer.

sampler image : register(s0);

#define ST2084_m1 ((2610.0 / 4096.0) / 4.0)
#define ST2084_m2 ((2523.0 / 4096.0) * 128.0)
#define ST2084_c1 ( 3424.0 / 4096.0)
#define ST2084_c2 ((2413.0 / 4096.0) * 32.0)
#define ST2084_c3 ((2392.0 / 4096.0) * 32.0)

#define SRC_LUMINANCE_PEAK     10000.0
#define DISPLAY_LUMINANCE_PEAK 125.0

//#include "hdr_tone_mapping.hlsl"
//#include "colorspace_gamut_conversion.hlsl"

#pragma warning(disable: 3571) // fix warning X3571 in pow().

// using code from zimg - https://github.com/sekrit-twc/zimg

static const float REC_709_PRIMARIES[3][2]  = { { 0.640, 0.330 }, { 0.300, 0.600 }, { 0.150, 0.060 } };
static const float REC_2020_PRIMARIES[3][2] = { { 0.708, 0.292 }, { 0.170, 0.797 }, { 0.131, 0.046 } };

static const float ILLUMINANT_D65[2] = { 0.3127, 0.3290 };

const float det2(const float a00, const float a01, const float a10, const float a11)
{
    return a00 * a11 - a01 * a10;
}

const float determinant(const float3x3 m)
{
    float det = 0;

    det += m[0][0] * det2(m[1][1], m[1][2], m[2][1], m[2][2]);
    det -= m[0][1] * det2(m[1][0], m[1][2], m[2][0], m[2][2]);
    det += m[0][2] * det2(m[1][0], m[1][1], m[2][0], m[2][1]);

    return det;
}

const float3x3 inverse(const float3x3 m)
{
    float3x3 ret;
    const float det = determinant(m);

    ret[0][0] = det2(m[1][1], m[1][2], m[2][1], m[2][2]) / det;
    ret[0][1] = det2(m[0][2], m[0][1], m[2][2], m[2][1]) / det;
    ret[0][2] = det2(m[0][1], m[0][2], m[1][1], m[1][2]) / det;
    ret[1][0] = det2(m[1][2], m[1][0], m[2][2], m[2][0]) / det;
    ret[1][1] = det2(m[0][0], m[0][2], m[2][0], m[2][2]) / det;
    ret[1][2] = det2(m[0][2], m[0][0], m[1][2], m[1][0]) / det;
    ret[2][0] = det2(m[1][0], m[1][1], m[2][0], m[2][1]) / det;
    ret[2][1] = det2(m[0][1], m[0][0], m[2][1], m[2][0]) / det;
    ret[2][2] = det2(m[0][0], m[0][1], m[1][0], m[1][1]) / det;

    return ret;
}

const float3 xy_to_xyz(const float x, const float y)
{
    float3 ret;

    ret[0] = x / y;
    ret[1] = 1.0;
    ret[2] = (1.0 - x - y) / y;

    return ret;
}

const float3 get_d65_xyz()
{
    return xy_to_xyz(ILLUMINANT_D65[0], ILLUMINANT_D65[1]);
}

const float3x3 get_primaries_xyz(const float primaries_xy[3][2])
{
    // Columns: R G B
    // Rows: X Y Z
    float3x3 ret;

    ret[0] = xy_to_xyz(primaries_xy[0][0], primaries_xy[0][1]);
    ret[1] = xy_to_xyz(primaries_xy[1][0], primaries_xy[1][1]);
    ret[2] = xy_to_xyz(primaries_xy[2][0], primaries_xy[2][1]);

    return transpose(ret);
}

const float3x3 gamut_rgb_to_xyz_matrix(const float primaries_xy[3][2])
{
    const float3x3 xyz_matrix = get_primaries_xyz(primaries_xy);
    const float3 white_xyz = get_d65_xyz();

    const float3 s = mul(inverse(xyz_matrix), white_xyz);
    const float3x3 m = { xyz_matrix[0] * s, xyz_matrix[1] * s, xyz_matrix[2] * s };

    return m;
}

static const float3x3 gamut_xyz_color_matrix_2020 = gamut_rgb_to_xyz_matrix(REC_2020_PRIMARIES);
static const float3x3 gamut_xyz_color_matrix_709  = gamut_rgb_to_xyz_matrix(REC_709_PRIMARIES);
static const float3x3 convert_matrix_2020_to_709  = mul(inverse(gamut_xyz_color_matrix_709), gamut_xyz_color_matrix_2020);

float3 Colorspace_Gamut_Conversion_2020_to_709(const float3 rgb)
{
    return mul(convert_matrix_2020_to_709, rgb);
}

const float hable(const float x)
{
    const float A = 0.15, B = 0.50, C = 0.10, D = 0.20, E = 0.02, F = 0.30;

    return ((x * (A * x + (C * B)) + (D * E)) / (x * (A * x + B) + (D * F))) - E / F;
}

const float3 hable(float3 rgb)
{
    rgb.r = hable(rgb.r);
    rgb.g = hable(rgb.g);
    rgb.b = hable(rgb.b);

    return rgb;
}

float3 ToneMappingHable(const float3 rgb)
{
    static const float HABLE_DIV = hable(4.8);

    return hable(rgb) / HABLE_DIV;
}


float4 main(float2 tex : TEXCOORD0) : COLOR
{
    //float4 pixel = saturate(tex2D(image, tex)); // use mindless saturate() for fix warning X3571 in pow()
    float4 pixel = tex2D(image, tex);

    // ST2084 to Linear
    pixel.rgb = pow(pixel.rgb, 1.0 / ST2084_m2);
    pixel.rgb = max(pixel.rgb - ST2084_c1, 0.0) / (ST2084_c2 - ST2084_c3 * pixel.rgb);
    pixel.rgb = pow(pixel.rgb, 1.0 / ST2084_m1);

    // Peak luminance
    pixel.rgb = pixel.rgb * (SRC_LUMINANCE_PEAK / DISPLAY_LUMINANCE_PEAK);

    // HDR tone mapping
    pixel.rgb = ToneMappingHable(pixel.rgb);

    // Colorspace Gamut Conversion
    pixel.rgb = Colorspace_Gamut_Conversion_2020_to_709(pixel.rgb);

    // Linear to sRGB
    pixel.rgb = saturate(pixel.rgb);
    pixel.rgb = pow(pixel.rgb, 1.0 / 2.2);

    return pixel;
}
