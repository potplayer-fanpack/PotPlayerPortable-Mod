//==============================================================================
//
//						CONSTRAST ADAPTIVE SHARPENING
//
//==============================================================================
//
// This code is ported version of the Contrast Adaptive Sharpening (CAS) code.
// The original code is provided by AMD and can be found at the URL below.
// https://github.com/GPUOpen-Effects/FidelityFX
//
// Ported by Seongmun Jung, Computaional Aerodynamics & Design Optimization Lab.
//																	- 04/10/2019
//
//==============================================================================
//	License of original code and this code
//==============================================================================
// Copyright (c) 2019 Advanced Micro Devices, Inc. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//=============================================================================

sampler s0 : register(s0);
float4 p1  : register(c1);

#define SHARPNESS		0.5		//	Sharpening strength. Recommended range: [0, 1]
#define px (p1[0])				//	Pixel dx
#define py (p1[1])				//	Pixel dy


float4 main(float2 tex : TEXCOORD0) : COLOR {
	//	Get stencil points and saturate values (Remain or BTB or WTW)
	//	[c1    c2    c3]
	//	[c4    c5    c6]
	//	[c7    c8    c9]
	float3 c1 = saturate( tex2D(s0, tex + float2(-px, -py)).rgb );
	float3 c2 = saturate( tex2D(s0, tex + float2(  0, -py)).rgb );
	float3 c3 = saturate( tex2D(s0, tex + float2(+px, -py)).rgb );
	float3 c4 = saturate( tex2D(s0, tex + float2(-px,   0)).rgb );
	float3 c5 = saturate( tex2D(s0, tex + float2(  0,   0)).rgb );
	float3 c6 = saturate( tex2D(s0, tex + float2(+px,   0)).rgb );
	float3 c7 = saturate( tex2D(s0, tex + float2(-px, +py)).rgb );
	float3 c8 = saturate( tex2D(s0, tex + float2(  0, +py)).rgb );
	float3 c9 = saturate( tex2D(s0, tex + float2(+px, +py)).rgb );

	//	Calculate soft minimum and soft maximum
	float3 minRGB = min( min( min( c4, c6 ), min( c2, c8 ) ), c5     );
	float3 min2   = min( min( min( c1, c3 ), min( c7, c9 ) ), minRGB );
	float3 maxRGB = max( max( max( c4, c6 ), max( c2, c8 ) ), c5     );
	float3 max2   = max( max( max( c1, c3 ), max( c7, c9 ) ), maxRGB );
	minRGB += min2;
	maxRGB += max2;

	//	Smooth minimum distance to signal limit divided by smooth max
	float3 rcpmax = rcp( maxRGB );
	float3 ampRGB = saturate( min(minRGB, 2.0 - maxRGB) * rcpmax );

	//	Shaping amount of sharpening (SHARPNESS is not saturated)
	ampRGB = sqrt( ampRGB );
	float  peak = -rcp( 8.0 - 3.0 * SHARPNESS );
	float3 wRGB = ampRGB * peak;
	float3 rcpwRGB = rcp(1.0 + 4.0 * wRGB);

	//	Apply filter to get output
	//	- Filter shape -
	//	[0    w    0]
	//	[w    1    w]
	//	[0    w    0]
	float3 c2468 = (c2 + c8) + (c4 + c6);

	//	Original code: Use green value only
	//return float4( saturate( (wRGB[1] * c2468 + c5) * rcpwRGB[1] ), 1 );
	//	Optional code: Use whole RGB values
	return float4( saturate( (wRGB * c2468 + c5) * rcpwRGB ), 1 );
}
