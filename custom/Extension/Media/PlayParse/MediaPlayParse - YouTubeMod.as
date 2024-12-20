/*
	YouTube media parse
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 									-> get title for UI
// string GetVersion									-> get version for manage
// string GetDesc()										-> get detail information
// string GetLoginTitle()								-> get title for login dialog
// string GetLoginDesc()								-> get desc for login dialog
// string GetUserText()									-> get user text for login dialog
// string GetPasswordText()								-> get password text for login dialog
// string ServerCheck(string User, string Pass) 		-> server check
// string ServerLogin(string User, string Pass) 		-> login
// void ServerLogout() 									-> logout
//------------------------------------------------------------------------------------------------
// bool PlayitemCheck(const string &in)					-> check playitem
// array<dictionary> PlayitemParse(const string &in)	-> parse playitem
// bool PlaylistCheck(const string &in)					-> check playlist
// array<dictionary> PlaylistParse(const string &in)	-> parse playlist
//------------------------------------------------------------------------------------------------

const string modVersion = "PRE-ALPHA 1";

//------------------------------------------------------------------------------------------------

namespace config
{
	bool showDebugLog         = false;

	bool useCurl              = true;
	
	bool useCookies           = true;

	bool useSponsorBlock      = false;

	bool cacheMetaData        = true;

	bool fixFormats           = true;

	bool jpegThumbnails       = true;

	bool skipStartPos         = true;

	bool markWatched          = true;

	bool normalizeTitle       = true;

	bool autoRedirect         = true;

	bool hotConfig            = false;
	
	uint showChannelName      = 2;      

	uint typeChannelName      = 3;      

	string titleFormat        = "title | channel";

	string userAgent          = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Safari/537.36";

	string ytApiKey           = "AIzaSyAbCm1he8HQ_X0TPM9wYkKVatg_1aHbBkQ";
}

//------------------------------------------------------------------------------------------------

string playerDir     = "";

string extDir        = "";

string userDir       = "";

string configPath    = "Data\\YouTubeMod\\config.cfg";

string curlPath      = "Data\\Curl\\curl.exe";

string cookiesPath   = "Data\\Cookies\\cookies.txt";

enum PathType {ptAuto, ptPlayer, ptUser}

uint configTime = 0;

//------------------------------------------------------------------------------------------------

array<dictionary> cacheQualityList;

dictionary cacheMetaData;

string cacheUrl, cacheFinalUrl;

uint cacheTime = 0;

//------------------------------------------------------------------------------------------------

string GetTitle()
{
	return "YouTubeMod - " + modVersion;
}

string GetVersion()
{
	return modVersion;
}

string GetDesc()
{
	return "";
}

void OnInitialize()
{
	HostIncTimeOut(5 * 60 * 1000);

	InitMod();
}

string YOUTUBE_MP_URL				= "://www.youtube.com/";
string YOUTUBE_PL_URL				= "://www.youtube.com/playlist?";
string YOUTUBE_USER_URL    			= "://www.youtube.com/user/";
string YOUTUBE_USER_SHORT_URL       = "://www.youtube.com/c/";
string YOUTUBE_CHANNEL_URL			= "://www.youtube.com/channel/";
string YOUTUBE_URL_LIBRARY          = "youtube.com/@";
string YOUTUBE_URL					= "://www.youtube.com/watch?";
string YOUTUBE_URL2					= "://www.youtube.com/v/";
string YOUTUBE_URL3					= "://www.youtube.com/embed/";
string YOUTUBE_URL4					= "://www.youtube.com/attribution_link?a=";
string YOUTUBE_URL5					= "://www.youtube.com/shorts";
string YOUTUBE_URL6					= "://www.youtube.com/clip";
string YOUTUBE_URL_LIVE				= "://www.youtube.com/live";
string YOUTU_BE_URL1				= "://youtu.be/";
string YOUTU_BE_URL2				= "://youtube.com/";
string YOUTU_BE_URL3				= "://m.youtube.com/";
string YOUTU_BE_URL4				= "://gaming.youtube.com/";
string YOUTU_BE_URL5				= "://music.youtube.com/";
string VIMEO_URL					= "://vimeo.com/";

string MATCH_STREAM_MAP_START		= "\"url_encoded_fmt_stream_map\"";
string MATCH_STREAM_MAP_START2		= "url_encoded_fmt_stream_map=";
string MATCH_ADAPTIVE_FMTS_START	= "\"adaptive_fmts\"";
string MATCH_ADAPTIVE_FMTS_START2	= "adaptive_fmts=";
string MATCH_HLSMPD_START			= "hlsManifestUrl";
string MATCH_DASHMPD_START			= "dashManifestUrl";
string MATCH_WIDTH_START			= "meta property=\"og:video:width\" content=\"";
string MATCH_JS_START				= "\"js\":";
string MATCH_JS_START_2             = "'PREFETCH_JS_RESOURCES': [\"";
string MATCH_JS_START_3             = "\"PLAYER_JS_URL\":\"";
string MATCH_END					= "\"";
string MATCH_END2					= "&";

string MATCH_PLAYER_RESPONSE       = "\"player_response\":\"";
string MATCH_PLAYER_RESPONSE2      = "player_response=";
string MATCH_PLAYER_RESPONSE_END   = "}\"";

string MATCH_PLAYER_RESPONSE_2     = "ytInitialPlayerResponse = ";

string MATCH_CHAPTER_RESPONSE      = "chapteredPlayerBarRenderer";
string MATCH_CHAPTER_RESPONSE2     = "key\":\"DESCRIPTION_CHAPTERS\",\"value\"";

bool Is60Frame(int iTag)
{
	return iTag == 272 || iTag == 298 || iTag == 299 || iTag == 300 || iTag == 301 || iTag == 302 || iTag == 303 || iTag == 308 || iTag == 315 || iTag == 334 || iTag == 335 || iTag == 336 || iTag == 337;
}

bool IsHDR(int iTag)
{
	return iTag >= 330 && iTag <= 337 || iTag >= 694 && iTag <= 702;
}

bool IsTag3D(int iTag)
{
	return (iTag >= 82 && iTag <= 85) || (iTag >= 100 && iTag <= 102);
}

enum ytype
{
	y_unknown,
	y_mp4,
	y_webm,
	y_flv,
	y_3gp,
	y_3d_mp4,
	y_3d_webm,
	y_apple_live,
	y_dash_mp4_video,
	y_dash_mp4_audio,
	y_webm_video,
	y_webm_audio,
};

class YOUTUBE_PROFILES
{
	int iTag;
	ytype type;
	int quality;
	string ext;

	YOUTUBE_PROFILES(int _iTag, ytype _type, int _quality, string _ext)
	{
		iTag = _iTag;
		type = _type;
		quality = _quality;
		ext = _ext;
	}
	YOUTUBE_PROFILES()
	{
	}
};

array<YOUTUBE_PROFILES> youtubeProfiles =
{
	YOUTUBE_PROFILES(22, y_mp4, 720, "mp4"),
	YOUTUBE_PROFILES(37, y_mp4, 1080, "mp4"),
	YOUTUBE_PROFILES(38, y_mp4, 3072, "mp4"),
	YOUTUBE_PROFILES(18, y_mp4, 360, "mp4"),

	YOUTUBE_PROFILES(45, y_webm, 720, "webm"),
	YOUTUBE_PROFILES(46, y_webm, 1080, "webm"),
	YOUTUBE_PROFILES(44, y_webm, 480, "webm"),
	YOUTUBE_PROFILES(43, y_webm, 360, "webm"),

	YOUTUBE_PROFILES(120, y_flv, 720, "flv"),
	YOUTUBE_PROFILES(35, y_flv, 480, "flv"),
	YOUTUBE_PROFILES(34, y_flv, 360, "flv"),
	YOUTUBE_PROFILES(6, y_flv, 270, "flv"),
	YOUTUBE_PROFILES(5, y_flv, 240, "flv"),

	YOUTUBE_PROFILES(36, y_3gp, 240, "3gp"),
	YOUTUBE_PROFILES(13, y_3gp, 144, "3gp"),
	YOUTUBE_PROFILES(17, y_3gp, 144, "3gp"),
};

array<YOUTUBE_PROFILES> youtubeProfilesExt =
{
//	3d
	YOUTUBE_PROFILES(84, y_3d_mp4, 720, "mp4"),
	YOUTUBE_PROFILES(85, y_3d_mp4, 520, "mp4"),
	YOUTUBE_PROFILES(83, y_3d_mp4, 480, "mp4"),
	YOUTUBE_PROFILES(82, y_3d_mp4, 360, "mp4"),

// 	live
	YOUTUBE_PROFILES(267, y_mp4,  2160, "mp4"),
	YOUTUBE_PROFILES(265, y_mp4,  1440, "mp4"),
	YOUTUBE_PROFILES(301, y_mp4, 1080, "mp4"),
	YOUTUBE_PROFILES(300, y_mp4,  720, "mp4"),
	YOUTUBE_PROFILES(96, y_mp4, 1080, "mp4"),
	YOUTUBE_PROFILES(95, y_mp4,  720, "mp4"),
	YOUTUBE_PROFILES(94, y_mp4,  480, "mp4"),
	YOUTUBE_PROFILES(93, y_mp4,  360, "mp4"),
	YOUTUBE_PROFILES(92, y_mp4,  240, "mp4"),

// 	av1
	YOUTUBE_PROFILES(571, y_dash_mp4_video, 4320, "mp4"),
	YOUTUBE_PROFILES(402, y_dash_mp4_video, 4320, "mp4"),
	YOUTUBE_PROFILES(401, y_dash_mp4_video, 2160, "mp4"),
	YOUTUBE_PROFILES(400, y_dash_mp4_video, 1440, "mp4"),
	YOUTUBE_PROFILES(399, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(398, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(397, y_dash_mp4_video, 480, "mp4"),
	YOUTUBE_PROFILES(396, y_dash_mp4_video, 360, "mp4"),
	YOUTUBE_PROFILES(395, y_dash_mp4_video, 240, "mp4"),
	YOUTUBE_PROFILES(394, y_dash_mp4_video, 144, "mp4"),

//	av1 hdr
	YOUTUBE_PROFILES(702, y_dash_mp4_video, 4320, "mp4"),
	YOUTUBE_PROFILES(701, y_dash_mp4_video, 2160, "mp4"),
	YOUTUBE_PROFILES(700, y_dash_mp4_video, 1440, "mp4"),
	YOUTUBE_PROFILES(699, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(698, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(697, y_dash_mp4_video, 480, "mp4"),
	YOUTUBE_PROFILES(696, y_dash_mp4_video, 360, "mp4"),
	YOUTUBE_PROFILES(695, y_dash_mp4_video, 240, "mp4"),
	YOUTUBE_PROFILES(694, y_dash_mp4_video, 144, "mp4"),

	YOUTUBE_PROFILES(102, y_webm_video, 720, "webm"),
	YOUTUBE_PROFILES(100, y_webm_video, 360, "webm"),
	YOUTUBE_PROFILES(101, y_webm_video, 360, "webm"),

// 	dash
	YOUTUBE_PROFILES(266, y_dash_mp4_video, 2160, "mp4"),
	YOUTUBE_PROFILES(138, y_dash_mp4_video, 2160, "mp4"), // 8K도 이걸로 될 수 있다.. ㄷㄷ
	YOUTUBE_PROFILES(264, y_dash_mp4_video, 1440, "mp4"),
	YOUTUBE_PROFILES(137, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(136, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(135, y_dash_mp4_video, 480, "mp4"),
	YOUTUBE_PROFILES(134, y_dash_mp4_video, 360, "mp4"),
	YOUTUBE_PROFILES(133, y_dash_mp4_video, 240, "mp4"),
	YOUTUBE_PROFILES(160, y_dash_mp4_video, 144, "mp4"),
	YOUTUBE_PROFILES(139, y_dash_mp4_audio, 64, "m4a"),
	YOUTUBE_PROFILES(140, y_dash_mp4_audio, 128, "m4a"),
	YOUTUBE_PROFILES(141, y_dash_mp4_audio, 256, "m4a"),
	YOUTUBE_PROFILES(256, y_dash_mp4_audio, 192, "m4a"),
	YOUTUBE_PROFILES(258, y_dash_mp4_audio, 384, "m4a"),
	YOUTUBE_PROFILES(327, y_dash_mp4_audio, 320, "m4a"),

	YOUTUBE_PROFILES(380, y_dash_mp4_audio, 384, "m4a"), // AC3
	YOUTUBE_PROFILES(328, y_dash_mp4_audio,	384, "m4a"), // E-AC3
	YOUTUBE_PROFILES(325, y_dash_mp4_audio,	384, "m4a"), // DTS-Express

	YOUTUBE_PROFILES(272, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(271, y_webm_video, 1440, "webm"),
	YOUTUBE_PROFILES(248, y_webm_video, 1080, "webm"),
	YOUTUBE_PROFILES(247, y_webm_video, 720, "webm"),
	YOUTUBE_PROFILES(244, y_webm_video, 480, "webm"),
	YOUTUBE_PROFILES(243, y_webm_video, 360, "webm"),
	YOUTUBE_PROFILES(242, y_webm_video, 240, "webm"),
	YOUTUBE_PROFILES(278, y_webm_video, 144, "webm"),

	YOUTUBE_PROFILES(171, y_webm_audio, 128, "webm"),
	YOUTUBE_PROFILES(172, y_webm_audio, 192, "webm"),
	YOUTUBE_PROFILES(338, y_webm_audio, 256, "webm"),
	YOUTUBE_PROFILES(339, y_webm_audio, 320, "webm"),

	YOUTUBE_PROFILES(249, y_webm_audio, 48,  "webm"), // opus
	YOUTUBE_PROFILES(250, y_webm_audio, 64, "webm"), // opus
	YOUTUBE_PROFILES(251, y_webm_audio, 256, "webm"), // opus
	YOUTUBE_PROFILES(338, y_webm_audio, 128, "webm"), // opus

	YOUTUBE_PROFILES(313, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(314, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(302, y_webm_video, 720, "webm"),

	// 60p
	YOUTUBE_PROFILES(315, y_webm_video, 2160, "webm"),
	YOUTUBE_PROFILES(308, y_webm_video, 1440, "webm"),
	YOUTUBE_PROFILES(303, y_webm_video, 1080, "webm"),

	// HDR
	YOUTUBE_PROFILES(330, y_webm_video, 144, "webm"),
	YOUTUBE_PROFILES(331, y_webm_video, 240, "webm"),
	YOUTUBE_PROFILES(332, y_webm_video, 360, "webm"),
	YOUTUBE_PROFILES(333, y_webm_video, 480, "webm"),
	YOUTUBE_PROFILES(334, y_webm_video, 720, "webm"),
	YOUTUBE_PROFILES(335, y_webm_video, 1080, "webm"),
	YOUTUBE_PROFILES(336, y_webm_video, 1440, "webm"),
	YOUTUBE_PROFILES(337, y_webm_video, 2160, "webm"),

	// 60P
	YOUTUBE_PROFILES(298, y_dash_mp4_video, 720, "mp4"),
	YOUTUBE_PROFILES(299, y_dash_mp4_video, 1080, "mp4"),
	YOUTUBE_PROFILES(304, y_dash_mp4_video, 1440, "mp4"),
};

int GetYouTubeQuality(int iTag)
{
	for (int i = 0, len = youtubeProfiles.size(); i < len; i++)
	{
		if (iTag == youtubeProfiles[i].iTag) return youtubeProfiles[i].quality;
	}

	for (int i = 0, len = youtubeProfilesExt.size(); i < len; i++)
	{
		if (iTag == youtubeProfilesExt[i].iTag) return youtubeProfilesExt[i].quality;
	}

	return 0;
}

ytype GetYouTubeType(int iTag)
{
	for (int i = 0, len = youtubeProfiles.size(); i < len; i++)
	{
		if (iTag == youtubeProfiles[i].iTag) return youtubeProfiles[i].type;
	}

	for (int i = 0, len = youtubeProfilesExt.size(); i < len; i++)
	{
		if (iTag == youtubeProfilesExt[i].iTag) return youtubeProfilesExt[i].type;
	}

	return y_unknown;
}

YOUTUBE_PROFILES getProfile(int iTag, bool ext = false)
{
	for (int i = 0, len = youtubeProfiles.size(); i < len; i++)
	{
		if (iTag == youtubeProfiles[i].iTag) return youtubeProfiles[i];
	}

	if (ext)
	{
		for (int i = 0, len = youtubeProfilesExt.size(); i < len; i++)
		{
			if (iTag == youtubeProfilesExt[i].iTag) return youtubeProfilesExt[i];
		}
	}

	YOUTUBE_PROFILES youtubeProfileEmpty(0, y_unknown, 0, "");
	return youtubeProfileEmpty;
}

bool SelectBestProfile(int &itag_final, string &ext_final, int itag_current, YOUTUBE_PROFILES sets)
{
	YOUTUBE_PROFILES current = getProfile(itag_current);

	if (current.iTag <= 0 || current.type != sets.type || current.quality > sets.quality)
	{
		return false;
	}

	if (itag_final != 0)
	{
		YOUTUBE_PROFILES fin = getProfile(itag_final);

		if (current.quality < fin.quality) return false;
	}

	itag_final = current.iTag;
	ext_final = "." + current.ext;

	return true;
}

bool SelectBestProfile2(int &itag_final, string &ext_final, int itag_current, YOUTUBE_PROFILES sets)
{
	YOUTUBE_PROFILES current = getProfile(itag_current, true);

	if (current.iTag <= 0 || current.quality > sets.quality)
	{
		return false;
	}

	if (itag_final != 0)
	{
		YOUTUBE_PROFILES fin = getProfile(itag_final, true);

		if (current.quality < fin.quality) return false;
	}

	itag_final = current.iTag;
	ext_final = "." + current.ext;

	return true;
}

class QualityListItem
{
	string url;
	string quality;
	string qualityDetail;
	string resolution;
	string bitrate;
	string format;
	int itag = 0;
	double fps = 0.0;
	int type3D = 0; // 1:sbs, 2:t&b
	bool is360 = false;
	bool isHDR = false;
	string audioName;
	string audioCode;
	int bitrateVal = 0;
	int64 sizeVal = 0;

	dictionary toDictionary()
	{
		dictionary ret;

		ret["url"] = url;
		ret["quality"] = quality;
		ret["qualityDetail"] = qualityDetail;
		ret["resolution"] = resolution;
		ret["bitrate"] = bitrate;
		ret["format"] = format;
		ret["itag"] = itag;
		ret["fps"] = fps;
		ret["type3D"] = type3D;
		ret["is360"] = is360;
		ret["isHDR"] = isHDR;
		ret["audioName"] = audioName;
		ret["audioCode"] = audioCode;
		ret["bitrateVal"] = bitrateVal;
		ret["sizeVal"] = sizeVal;
		return ret;
	}
};

void AppendQualityList(array<dictionary> &QualityList, QualityListItem &item, string url)
{
	YOUTUBE_PROFILES pPro = getProfile(item.itag, true);

	if (pPro.iTag > 0)
	{
		bool Detail = false;

		if (Is60Frame(item.itag) && item.fps < 1) item.fps = 60.0;
		if (!url.empty()) item.url = url;
		if (item.format.empty()) item.format = pPro.ext;
		if (item.quality.empty())
		{
			if (pPro.type == y_dash_mp4_audio || pPro.type == y_webm_audio)
			{
				string quality = formatInt(pPro.quality) + "K";
				if (item.bitrate.empty()) item.quality = quality;
				else item.quality = item.bitrate;
			}
			else
			{
				Detail = true;
				if (!item.bitrate.empty())
				{
					if (!item.resolution.empty())
					{
						int p = item.resolution.find("x");

						if (p > 0)
						{
							item.quality = item.resolution.substr(p + 1);
							item.quality += "P";
						}
					}
				}
			}
		}
		else Detail = true;
		if (Detail && !item.bitrate.empty()) item.quality = item.bitrate + ", " + item.quality;

		bool Res = false;
		if (item.qualityDetail.empty())
		{
			item.qualityDetail = item.quality;
			Res = true;
		}
		if (Detail)
		{
			bool add = true;

			if (Res)
			{
				if (item.resolution.empty())
				{
					if (pPro.type == y_dash_mp4_audio || pPro.type == y_webm_audio) add = false;
					else item.qualityDetail = formatInt(pPro.quality) + "P";
				}
				else item.qualityDetail = item.resolution;
			}
			if (add && !item.bitrate.empty()) item.qualityDetail = item.bitrate + ", " + item.qualityDetail;
		}
		for (uint i = 0; i < QualityList.size(); i++)
		{
			int itag = 0;
			string audioCode;

			QualityList[i].get("itag", itag);
			QualityList[i].get("audioCode", audioCode);
			if (((pPro.type == y_dash_mp4_audio && GetYouTubeType(itag) == y_dash_mp4_audio) || (pPro.type == y_webm_audio && GetYouTubeType(itag) == y_webm_audio)) && audioCode == item.audioCode)
			{
				int bitrateVal = 0;

				QualityList[i].get("bitrateVal", bitrateVal);
				if (item.bitrateVal > bitrateVal) QualityList[i] = item.toDictionary();
				return;
			}
			else if (itag == item.itag && audioCode == item.audioCode)
			{
				string format, resolution, quality, qualityDetail;

				QualityList[i].get("format", format);
				QualityList[i].get("resolution", resolution);
				QualityList[i].get("quality", quality);
				QualityList[i].get("qualityDetail", qualityDetail);
				if (format.size() < item.format.size()) QualityList[i]["format"] = item.format;
				if (resolution.size() < item.resolution.size()) QualityList[i]["resolution"] = item.resolution;
				if (quality.size() < item.quality.size()) QualityList[i]["quality"] = item.quality;
				if (qualityDetail.size() < item.qualityDetail.size()) QualityList[i]["qualityDetail"] = item.qualityDetail;
				QualityList[i]["url"] = item.url;
				QualityList[i]["audioCode"] = item.audioCode;
				return;
			}
		}
		QualityList.insertLast(item.toDictionary());
	}
	else
	{
		DebugPrint("Unknown ITag: " + formatInt(item.itag));
	}
}

string GetEntry(string &pszBuff, string pszMatchStart, string pszMatchEnd)
{
	int Start = pszBuff.find(pszMatchStart);

	if (Start >= 0)
	{
		Start += pszMatchStart.size();
		int End = pszBuff.find(pszMatchEnd, Start);
		if (End > Start) return pszBuff.substr(Start, End - Start);
		else
		{
			End = pszBuff.size();
			return pszBuff.substr(Start, End - Start);
		}
	}

	return "";
}

void GetEntrys(string pszBuff, string pszMatchStart, string pszMatchEnd, array<string> &pEntrys)
{
	while (true)
	{
		string entry = GetEntry(pszBuff, pszMatchStart, pszMatchEnd);

		if (entry.empty()) break;
		else
		{
			pEntrys.insertLast(entry);

			int Start = pszBuff.find(pszMatchStart);
			if (Start >= 0)
			{
				Start += pszMatchStart.size();
				pszBuff = pszBuff.substr(Start, pszBuff.size() - Start);
			}
			else break;
		}
	}
}

string RepleaceYouTubeUrl(string url)
{
	if (url.find(YOUTU_BE_URL1) >= 0) url.replace(YOUTU_BE_URL1, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL2) >= 0) url.replace(YOUTU_BE_URL2, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL3) >= 0) url.replace(YOUTU_BE_URL3, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL4) >= 0) url.replace(YOUTU_BE_URL4, YOUTUBE_MP_URL);
	if (url.find(YOUTU_BE_URL5) >= 0) url.replace(YOUTU_BE_URL5, YOUTUBE_MP_URL);

	if (url.find(YOUTUBE_URL2) >= 0 || url.find(YOUTUBE_URL3) >= 0 || url.find(YOUTUBE_URL4) >= 0 || url.find(YOUTUBE_URL5) >= 0 || url.find(YOUTUBE_URL6) >= 0 || url.find(YOUTUBE_URL_LIVE) >= 0)
	{
		int p = url.rfind("/");

		if (p >= 0)
		{
			string id = url.substr(p + 1);

			url = "https" + YOUTUBE_URL + "v=" + id;
		}
	}

	return url;
}

string MakeYouTubeUrl(string url)
{
	if (url.find("watch?v=") < 0 && url.find("&v=") < 0)
	{
		url.replace("watch?", "watch?v=");
		if (url.find("watch?v=") < 0)
		{
			int p = url.rfind("/");

			if (p > 0) url.insert(p + 1, "watch?v=");
		}
	}
	return url;
}

string CorrectURL(string url)
{
	int p = url.find("http");
	if (p > 0) url.erase(0, p);
	p = url.find("\"");
	if (p > 0) url = url.substr(0, p);
	return url;
}

string PlayerYouTubeSearchJS(string data)
{
	string find1 = "html5player.js";
	int s = data.find(find1);

	if (s >= 0)
	{
		int e = s + find1.size();
		bool found = false;

		while (s > 0)
		{
			if (data.substr(s, 1) == "\"")
			{
				s++;
				found = true;
				break;
			}
			s--;
		}
		if (found)
		{
			string ret = data.substr(s, e - s);

			return ret;
		}
	}

	s = data.find(MATCH_JS_START);
	if (s >= 0)
	{
		s += 6;
		int e = data.find(".js", s);

		if (e > s)
		{
			string ret = data.substr(s, e + 3 - s);

			ret.Trim();
			ret.Trim("\"");
			return ret;
		}
	}

	s = data.find("/jsbin/player-");
	if (s >= 0)
	{
		s += 6;
		int e = data.find(".js", s);

		while (s > 0)
		{
			if (data.substr(s, 1) == "\"") break;
			else s--;
		}
		if (e > s)
		{
			string ret = data.substr(s, e + 3 - s);

			ret.Trim();
			ret.Trim("\"");
			return ret;
		}
	}

	return "";
}

enum youtubeFuncType
{
	funcNONE = -1,
	funcDELETE,
	funcREVERSE,
	funcSWAP
};

void Delete(string &a, int b)
{
	a.erase(0, b);
}

void Swap(string &a, int b)
{
	uint8 c = a[0];

	b %= a.size();
	a[0] = a[b];
	a[b] = c;
};

void Reverse(string &a)
{
	int len = a.size();

	for (int i = 0; i < len / 2; ++i)
	{
		uint8 c = a[i];

		a[i] = a[len - i - 1];
		a[len - i - 1] = c;
	}
}

string ReplaceCodecName(string name, string id)
{
	int s = name.find(id);

	if (s > 0)
	{
		int e = name.find(")", s);

		if (e < 0) e = name.find(",", s);
		if (e < 0) e = name.find("/", s);
		if (e < 0) e = name.size();
		s += id.size();
		name.erase(s, e - s);
	}
	return name;
}

string GetCodecName(string type)
{
	type.replace(",+", "/");
	type.replace(";+", " ");
	type.replace("video/", "");
	type.replace("audio/", "");
	type.replace(" codecs=", ", ");
	type.replace("\"", "");
	type.replace("x-flv", "flv");
	type = ReplaceCodecName(type, "avc");
	type = ReplaceCodecName(type, "vp09");
	type = ReplaceCodecName(type, "av01");
	type = ReplaceCodecName(type, "mp4v");
	type = ReplaceCodecName(type, "mp4a");
	type.replace(";,", ";");

	return type;
}

string GetFunction(string str)
{
	array<string> signatureRegExps =
	{
		"(?:\\b|[^a-zA-Z0-9$])([a-zA-Z0-9$]{2,})\\s*=\\s*function\\(\\s*a\\s*\\)\\s*\\{\\s*a\\s*=\\s*a\\.split\\(\\s*\"\"\\s*\\)",
		"(?:\\b|[^a-zA-Z0-9$])([a-zA-Z0-9$]{2,})\\s*=\\s*function\\(\\s*a\\s*\\)\\s*\\{\\s*a\\s*=\\s*a\\.split\\(\\s*\"\"\\s*\\);[a-zA-Z0-9$]{2}\\.[a-zA-Z0-9$]{2}\\(a,\\d+\\)",
		"\\b[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*encodeURIComponent\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"\\b[a-zA-Z0-9]+\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*encodeURIComponent\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"([a-zA-Z0-9$]+)\\s*=\\s*function\\(\\s*a\\s*\\)\\s*\\{\\s*a\\s*=\\s*a\\.split\\(\\s*\"\"\\s*\\)",
		"([\"\\'])signature\\1\\s*,\\s*([a-zA-Z0-9$]+)\\(",
		"\\.sig\\|\\|([a-zA-Z0-9$]+)\\(",
		"yt\\.akamaized\\.net/\\)\\s*\\|\\|\\s*.*?\\s*[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*(?:encodeURIComponent\\s*\\()?\\s*([a-zA-Z0-9$]+)\\(",
		"\\b[cs]\\s*&&\\s*[adf]\\.set\\([^,]+\\s*,\\s*([a-zA-Z0-9$]+)\\(",
		"\\b[a-zA-Z0-9]+\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*([a-zA-Z0-9$]+)\\(",
		"\\bc\\s*&&\\s*a\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"\\bc\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*([a-zA-Z0-9$]+)\\(",
		"\\bc\\s*&&\\s*[a-zA-Z0-9]+\\.set\\([^,]+\\s*,\\s*\\([^)]*\\)\\s*\\(\\s*([a-zA-Z0-9$]+)\\("
	};
	for (int i = 0, len = signatureRegExps.size(); i < len; i++)
	{
		string ret = HostRegExpParse(str, signatureRegExps[i]);
		if (!ret.empty()) return ret;
	}

	string r, sig = "\"signature\"";
	int p = 0;
	while (true)
	{
		int e = str.find(sig, p);

		if (e < 0) break;
		int s1 = str.find("(", e);
		int s2 = str.find(")", e);
		if (s1 > s2)
		{
			p = e + 10;
			continue;
		}
		p = e + sig.size() + 1;
		r = str.substr(p, s1 - p);
		break;
	}
	r.Trim(",");
	r.Trim();
	r.Trim(",");
	r.Trim();
	return r;
}

string SignatureDecode(string url, string signature, string append, string data, string js_data, array<youtubeFuncType> &JSFuncs, array<int> &JSFuncArgs)
{
	if (JSFuncs.size() == 0 && !js_data.empty())
	{
		string funcName = GetFunction(js_data);

		if (!funcName.empty())
		{
			string funcRegExp = funcName + "=function\\(a\\)\\{([^\\n]+)\\};";
			string funcBody = HostRegExpParse(data, funcRegExp);

			if (funcBody.empty())
			{
				string varfunc = funcName + "=function(a){";

				funcBody = GetEntry(js_data, varfunc, "};");
			}
			if (!funcBody.empty())
			{
				string funcGroup;
				array<string> funcList;
				array<string> funcCodeList;

				array<string> code = funcBody.split(";");
				for (int i = 0, len = code.size(); i < len; i++)
				{
					string line = code[i];

					if (!line.empty())
					{
						if (line.find("split") >= 0 || line.find("return") >= 0) continue;
						funcList.insertLast(line);
						if (funcGroup.empty())
						{
							int k = line.find(".");

							if (k > 0) funcGroup = line.Left(k);
						}
					}
				}

				if (!funcGroup.empty())
				{
					string tmp = GetEntry(js_data, "var " + funcGroup + "={", "};");

					if (!tmp.empty())
					{
						tmp.replace("\n", "");
						funcCodeList = tmp.split("},");
					}
				}

				if (!funcList.empty() && !funcCodeList.empty())
				{
					for (int j = 0, len = funcList.size(); j < len; j++)
					{
						string func = funcList[j];

						if (!func.empty())
						{
							int funcArg = 0;
							string funcArgs = GetEntry(func, "(", ")");
							array<string> args = funcArgs.split(",");

							if (args.size() >= 1)
							{
								string arg = args[args.size() - 1];

								funcArg = parseInt(arg);
							}

							funcName = GetEntry(func, funcGroup + '.', "(");
							if (funcName.empty())
							{
								funcName = GetEntry(func, funcGroup, "(");
								if (funcName.empty()) continue;
							}
							if (funcName.find("[") >= 0)
							{
								funcName.replace("[", "");
								funcName.replace("]", "");
							}
							funcName += ":function";

							youtubeFuncType funcType = youtubeFuncType::funcNONE;
							for (uint k = 0; k < funcCodeList.size(); k++)
							{
								string funcCode = funcCodeList[k];

								if (funcCode.find(funcName) >= 0)
								{
									if (funcCode.find("splice") > 0) funcType = youtubeFuncType::funcDELETE;
									else if (funcCode.find("reverse") > 0) funcType = youtubeFuncType::funcREVERSE;
									else if (funcCode.find(".length]") > 0) funcType = youtubeFuncType::funcSWAP;
									break;
								}
							}
							if (funcType != youtubeFuncType::funcNONE)
							{
								JSFuncs.insertLast(funcType);
								JSFuncArgs.insertLast(funcArg);
							}
						}
					}
				}
			}
		}
	}

	if (!JSFuncs.empty() && JSFuncs.size() == JSFuncArgs.size())
	{
		for (int i = 0, len = JSFuncs.size(); i < len; i++)
		{
			youtubeFuncType func = JSFuncs[i];
			int arg = JSFuncArgs[i];

			switch (func)
			{
			case youtubeFuncType::funcDELETE:
				Delete(signature, arg);
				break;
			case youtubeFuncType::funcSWAP:
				Swap(signature, arg);
				break;
			case youtubeFuncType::funcREVERSE:
				Reverse(signature);
				break;
			}
		}
		url = url + append + signature;
	}

	return url;
}

bool PlayerYouTubeCheck(string url)
{
	url.MakeLower();
	if (url.find(YOUTUBE_MP_URL) >= 0 || url.find(YOUTUBE_URL) >= 0 || url.find(YOUTU_BE_URL1) >= 0 || url.find(YOUTU_BE_URL2) >= 0 || url.find(YOUTU_BE_URL3) >= 0 || url.find(YOUTU_BE_URL4) >= 0 || url.find(YOUTU_BE_URL5) >= 0)
	{
		if (url.find("watch?") < 0 || url.find("playlist?") >= 0 || url.find("&list=") >= 0)
		{
			if (url.find(YOUTUBE_URL) >= 0) return true;
			if (url.find(YOUTUBE_URL2) >= 0) return true;
			if (url.find(YOUTUBE_URL3) >= 0) return true;
			if (url.find(YOUTUBE_URL4) >= 0) return true;
			if (url.find(YOUTUBE_URL5) >= 0) return true;
			if (url.find(YOUTUBE_URL6) >= 0) return true;
			if (url.find(YOUTUBE_URL_LIVE) >= 0) return true;
			return false;
		}
		else
		{
			return true;
		}
	}
	return false;
}

string GetVideoID(string url)
{
	string videoId = HostRegExpParse(url, "v=([-a-zA-Z0-9_]+)");
	if (videoId.empty()) videoId = HostRegExpParse(url, "video_ids=([-a-zA-Z0-9_]+)");
	return videoId;
}

bool PlayitemCheck(const string &in path)
{
	HostIncTimeOut(5 * 60 * 1000);
	
	InitMod(true);

	DebugPrint();
	DebugPrint("PlayItemCheck: \"" + path + "\"");
	
	bool succ;

	if (config::autoRedirect)
	{
		string tmp = ExtractRedirect(path);
		
		if (!tmp.isEmpty() && (tmp != path))
		{
			DebugPrint("PlayitemCheck: \"" + tmp + "\"");
			
			succ = _PlayitemCheck(tmp);
		}
		else
		{
			succ = _PlayitemCheck(path);
		}
	}
	else
	{
		succ = _PlayitemCheck(path);
	}
	
	DebugPrint("PlayItemCheck: " + (succ ? "true" : "false"));

	return succ;
}

bool _PlayitemCheck(string path)
{
	if (PlayerYouTubeCheck(path))
	{
		string url = RepleaceYouTubeUrl(path);
		url = MakeYouTubeUrl(url);

		string videoId = GetVideoID(url);

		return !videoId.empty();
	}

	return false;
}

string TrimFloatString(string str)
{
	str.TrimRight("0");
	str.TrimRight(".");
	return str;
}

string GetBitrateString(int64 val)
{
	string ret;

	if (val >= 1000 * 1000)
	{
		val = val / 1000;
		ret = formatFloat(val / 1000.0, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += "M";
	}
	else if (val >= 1000)
	{
		ret = formatFloat(val / 1000.0, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += "K";
	}
	else ret = formatInt(val);
	return ret;
}

string XMLAttrValue(XMLElement Element, string name)
{
	string ret;
	XMLAttribute Attr = Element.FindAttribute(name);

	if (Attr.isValid()) ret = Attr.asString();
	return ret;
}

string GetUserAgent()
{
	return "GooglePlayer";
}

string GetJsonCode(string data, string code, int pos = 0)
{
	int start = data.find(code, pos);

	if (start >= 0)
	{
		int count = 0;
		int len = data.size();
		bool IsString = false;

		start += code.size();
		while (start < len && data.substr(start, 1) != "{") start++;

		int end = start;
		while (end < len)
		{
			string ch = data.substr(end, 1);

			if (ch == "\"")
			{
				string prev = data.substr(end - 1, 1);

				if (prev != "\\") IsString = !IsString;
			}
			if (!IsString)
			{
				if (ch == "{") count++;
				else if (ch == "}") count--;
			}
			end++;
			if (count == 0) break;
		}
		if (end > start) return data.substr(start, end - start);
	}
	return "";
}

bool GetVideoJson(string videoId, int playerId, string &out json, const string &in data = "", const string &in js_data = "")
{
	json = "";

	string userAgent = "com.google.android.youtube/19.09.37 (Linux; U; Android 11) gzip";
	string apiKey    = "AIzaSyA8eiZmM1FaDVjRy-df2KTyQ_vz_yYM39w";
	bool   noCookie  = true;

	string headers, postData;

	DebugPrint();

	switch (playerId)
	{
		case 0:
		{
			DebugPrint("PLAYER: 1");

			headers   = "X-YouTube-Client-Name: 3\r\nX-YouTube-Client-Version: 19.09.37\r\nOrigin: https://www.youtube.com\r\ncontent-type: application/json\r\n";
			postData  = "{\"context\": {\"client\": {\"clientName\": \"ANDROID\", \"clientVersion\": \"19.09.37\", \"hl\": \"" + HostIso639LangName() + "\"}}, \"videoId\": \"" + videoId + "\", \"params\": \"CgIQBg==\", \"playbackContext\": {\"contentPlaybackContext\": {\"html5Preference\": \"HTML5_PREF_WANTS\"}}, \"contentCheckOk\": true, \"racyCheckOk\": true}";

			break;
		}
		case 1:
		{
			DebugPrint("PLAYER: 2");

			headers   = "X-YouTube-Client-Name: 3\r\nX-YouTube-Client-Version: 19.09.37\r\nOrigin: https://www.youtube.com\r\ncontent-type: application/json\r\n";
			postData  = "{\"context\": {\"client\": {\"clientName\": \"ANDROID\", \"clientVersion\": \"19.09.37\", \"clientScreen\": \"EMBED\"}, \"thirdParty\": {\"embedUrl\": \"https://google.com\"}}, \"videoId\": \"" + videoId + "\", \"params\": \"CgIQBg==\", \"contentCheckOk\": true, \"racyCheckOk\": true}";

			break;
		}
		case 2:
		{
			if (!config::useCookies || !config::useCurl || !FileExists(GetCookiesPath()) || !FileExists(GetCurlPath())) return true;

			DebugPrint("PLAYER: 3");

			string sessId, visId, pageId, hash;

			if (!ExtractJsonValue(data, "SESSION_INDEX", sessId) && !ExtractJsonValue(data, "authorizedUserIndex", sessId)) sessId = "0";
			if (!ExtractJsonValue(data, "VISITOR_DATA", visId)) ExtractJsonValue(data, "visitorData", visId);
			if (!ExtractJsonValue(data, "DELEGATED_SESSION_ID", pageId) && !ExtractJsonValue(data, "initialDelegatedSessionId", pageId))
			{
				if (ExtractJsonValue(data, "datasyncId", pageId) || ExtractJsonValue(data, "DATASYNC_ID", pageId)) pageId = pageId.substr(0, pageId.find("|"));
			}
			hash = SAPISIDHash(GetCookiesPath());

			headers   = "X-YouTube-Client-Name: 5\r\nX-YouTube-Client-Version: 19.09.3\r\nOrigin: https://www.youtube.com\r\nContent-Type: application/json\r\n";
			headers  += "X-Origin: https://www.youtube.com\r\n";

			if (!sessId.isEmpty()) headers += "X-Goog-Authuser: " + sessId + "\r\n";
			if (!visId.isEmpty())  headers += "X-Goog-Visitor-Id: " + visId + "\r\n";
			if (!pageId.isEmpty()) headers += "X-Goog-PageId: " + pageId + "\r\n";
			if (!hash.isEmpty())   headers += "Authorization: " + hash + "\r\n";

			postData  = "{\"context\": {\"client\": {\"clientName\": \"IOS\", \"clientVersion\": \"19.09.3\", \"deviceModel\": \"iPhone14,3\", \"userAgent\": \"com.google.ios.youtube/19.09.3 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)\", \"hl\": \"" + HostIso639LangName() + "\", \"timeZone\": \"UTC\", \"utcOffsetMinutes\": 0}}, \"videoId\": \"" + videoId + "\", \"playbackContext\": {\"contentPlaybackContext\": {\"html5Preference\": \"HTML5_PREF_WANTS\"}}, \"contentCheckOk\": true, \"racyCheckOk\": true}";
			userAgent = "com.google.ios.youtube/19.09.3 (iPhone14,3; U; CPU iOS 15_6 like Mac OS X)";
			apiKey    = "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc";
			noCookie  = false;

			break;
		}
		case 3:
		{
			DebugPrint("PLAYER: 4");

			string sts = HostRegExpParse(js_data, "\\bsignatureTimestamp\\s*:\\s*(\\d+)");
			if (sts.isEmpty()) sts = HostRegExpParse(js_data, "\\bsts\\s*:\\s*(\\d+)");

			headers   = "X-YouTube-Client-Name: 85\r\nX-YouTube-Client-Version: 2.0\r\nOrigin: https://www.youtube.com\r\nContent-Type: application/json\r\n";
			postData  = "{\"context\":{\"client\":{\"clientName\":\"TVHTML5_SIMPLY_EMBEDDED_PLAYER\",\"clientVersion\":\"2.0\",\"hl\":\"" + HostIso639LangName() + "\",\"clientScreen\":\"EMBED\"},\"thirdParty\":{\"embedUrl\":\"https://google.com\"}},\"playbackContext\":{\"contentPlaybackContext\":{\"html5Preference\":\"HTML5_PREF_WANTS\"" + (!sts.isEmpty() ? ",\"signatureTimestamp\":" + sts : "") + "}},\"contentCheckOk\":true,\"racyCheckOk\":true,\"videoId\":\"" + videoId + "\"}";
			apiKey    = "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8";

			break;
		}
		case 4:
		{
			DebugPrint("PLAYER: 5");

			headers   = "X-YouTube-Client-Name: 85\r\nX-YouTube-Client-Version: 2.0\r\nOrigin: https://www.youtube.com\r\ncontent-type: application/json\r\n";
			postData  = "{\"context\":{\"client\":{\"clientName\":\"TVHTML5_SIMPLY_EMBEDDED_PLAYER\",\"clientVersion\":\"2.0\"},\"thirdParty\":{\"embedUrl\":\"https://www.youtube.com\"}},\"videoId\":\"" + videoId + "\",\"racyCheckOk\":true,\"contentCheckOk\":true}";
			apiKey    = "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8";

			break;
		}
		default:
		{
			DebugPrint("PLAYERS FAIL");

			return false;
		}
	}

	if (!apiKey.isEmpty()) apiKey = "?key=" + apiKey;

	json = UrlGetString("https://www.youtube.com/youtubei/v1/player" + apiKey, userAgent, headers, postData, noCookie);

	return true;
}

string LoadJS(const string &in path, const string &in videoId, string &inout data)
{
	if (data.empty()) return "";

	string jsUrl = PlayerYouTubeSearchJS(data);

	if (jsUrl.empty()) jsUrl = GetEntry(data, MATCH_JS_START_2, MATCH_END);
	if (jsUrl.empty()) jsUrl = GetEntry(data, MATCH_JS_START_3, MATCH_END);
	if (jsUrl.empty())
	{
		string link = "https://www.youtube.com/embed/" + videoId;

		string JSData = UrlGetString(link, /*GetUserAgent()*/"", "", "", false);

		if (!JSData.empty())
		{
			jsUrl = PlayerYouTubeSearchJS(JSData);
			if (jsUrl.empty()) jsUrl = GetEntry(JSData, MATCH_JS_START_2, MATCH_END);
			if (jsUrl.empty()) jsUrl = GetEntry(JSData, MATCH_JS_START_3, MATCH_END);
		}
	}
	if (!jsUrl.empty())
	{
		jsUrl.replace("\\/", "/");
		if (jsUrl.find("//") == 0)
		{
			int p = path.find("//");

			if (p > 0) jsUrl = path.substr(0, p) + jsUrl;
		}
		if (jsUrl.find("://") < 0) jsUrl = "https://www.youtube.com" + jsUrl;
	}
	if (jsUrl.empty()) jsUrl = "https://www.youtube.com/yts/jsbin/player-ko_KR-vflHE7FfV/base.js";

	return UrlGetString(jsUrl, GetUserAgent(), "", "", true);
}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList)
{
	HostIncTimeOut(5 * 60 * 1000);
	
	InitMod(true);

	return _PlayitemParse(path, MetaData, QualityList);
}

string _PlayitemParse(string path, dictionary@ const &in MetaData, array<dictionary>@ const &in QualityList)
{
	//HostOpenConsole();

	DebugPrint();
	DebugPrint("PlayItemParse: \"" + path + "\"");

	DebugPrint(@MetaData is null ? "MetaData: null" : "");
	DebugPrint(@QualityList is null ? "QualityList: null" : "");

	string final_url = LoadCache(path, MetaData, QualityList);

	string error_message;

	if (!final_url.empty())
	{
		if (@MetaData !is null)
		{
			DebugPrint();
			DebugPrint("MetaData:");
			DebugPrint(MetaData, "  ");
		}

		if (@QualityList !is null)
		{
			DebugPrint();
			DebugPrint("QualityList:");
			DebugPrint(QualityList, "  ");
		}

		DebugPrint();
		DebugPrint("PlayItemParse: SUCCESS");
		return final_url;
	}

	//if (PlayitemCheck(path))
	{
		string fn = path;
		string tmp_fn = fn;

		tmp_fn.MakeLower();
		if (tmp_fn.find(YOUTUBE_URL2) >= 0 || tmp_fn.find(YOUTUBE_URL3) >= 0 || tmp_fn.find(YOUTUBE_URL4) >= 0 || tmp_fn.find(YOUTUBE_URL5) >= 0 || tmp_fn.find(YOUTUBE_URL6) >= 0 || tmp_fn.find(YOUTUBE_URL_LIVE) >= 0) fn = RepleaceYouTubeUrl(fn);

		string linkWeb = RepleaceYouTubeUrl(fn);
		linkWeb = MakeYouTubeUrl(linkWeb);

		string videoId = GetVideoID(linkWeb);
		linkWeb.replace("http://", "https://");

		linkWeb  += "&gl=" + HostIso3166CtryName() + "&hl=" + HostIso639LangName() + "&has_verified=1&bpctr=9999999999";

		string WebData = UrlGetString(linkWeb, /*GetUserAgent()*/"", "", "", false);

		if (WebData.isEmpty())
		{
			DebugPrint();
			DebugPrint("PlayItemParse: FAIL");
			return "";
		}


		if (@MetaData !is null)
		{
			MetaData["vid"]    = videoId;
			MetaData["webUrl"] = "https://www.youtube.com/watch?v=" + videoId;

			string temp = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE_2);

			JsonReader Reader;
			JsonValue Root;

			if (!temp.empty() && Reader.parse(temp, Root) && Root.isObject())
			{
				JsonValue microformat = Root["microformat"];

				if (microformat.isObject())
				{
					JsonValue playerMicroformatRenderer = microformat["playerMicroformatRenderer"];
					if (playerMicroformatRenderer.isObject())
					{
						JsonValue title = playerMicroformatRenderer["title"];
						if (title.isObject())
						{
							JsonValue simpleText = title["simpleText"];
							if (simpleText.isString())
							{
								string sTitle = simpleText.asString();
								if (!sTitle.empty())
								{
									sTitle = FixHtmlSymbols(sTitle);
									//sTitle.replace("+", " ");
									MetaData["title"] = sTitle;
								}
							}
						}

						JsonValue description = playerMicroformatRenderer["description"];
						if (description.isObject())
						{
							JsonValue simpleText = description["simpleText"];
							if (simpleText.isString())
							{
								string sDesc = simpleText.asString();
								if (!sDesc.empty())
								{
									sDesc = FixHtmlSymbols(sDesc);
									//sDesc.replace("+", " ");
									sDesc.replace("\\r\\n", "\n");
									sDesc.replace("\\n", "\n");
									MetaData["content"] = sDesc;
								}
							}
						}

						JsonValue author = playerMicroformatRenderer["ownerChannelName"];
						if (author.isString())
						{
							string sAuthor = author.asString();
							if (!sAuthor.empty())
							{
								//sAuthor.replace("+", " ");
								MetaData["author"] = sAuthor;
							}
						}

						JsonValue authorShort = playerMicroformatRenderer["ownerProfileUrl"];
						if (authorShort.isString())
						{
							string sAuthorShort = authorShort.asString();
							if (!sAuthorShort.empty())
							{
								sAuthorShort = sAuthorShort.substr(sAuthorShort.findLast("/") + 1).TrimLeft("@");
								MetaData["authorShort"] = sAuthorShort;
							}
						}

						JsonValue lengthSeconds = playerMicroformatRenderer["lengthSeconds"];
						if (lengthSeconds.isString()) MetaData["duration"] = parseInt(lengthSeconds.asString()) * 1000;

						JsonValue thumbnail = playerMicroformatRenderer["thumbnail"];
						if (thumbnail.isObject())
						{
							JsonValue thumbnails = thumbnail["thumbnails"];
							if (thumbnails.isArray())
							{
								JsonValue th = thumbnails[0];
								if (th.isObject())
								{
									JsonValue url = th["url"];
									if (url.isString()) MetaData["thumbnail"] = url.asString();
								}
							}
						}
					}
				}
			}
		}

		if (@QualityList is null)
		{
			FixMetaData(MetaData);

			if (@MetaData !is null)
			{
				DebugPrint();
				DebugPrint("MetaData:");
				DebugPrint(MetaData, "  ");
			}

			DebugPrint();
			DebugPrint("PlayItemParse: SUCCESS");

			return path;
		}


		array<youtubeFuncType> JSFuncs;
		array<int> JSFuncArgs;

		int iYoutubeTag = 22;
		YOUTUBE_PROFILES youtubeSets = getProfile(iYoutubeTag);
		if (youtubeSets.iTag == 0) youtubeSets = getProfile(22);

		// Load js
		string js_data = LoadJS(fn, videoId, WebData);

		string json;

		string player_response_jsonData, player_chapter_jsonData, player_sponsors_jsonData;

		int i = 0;
		while (true)
		{
			if (!GetVideoJson(videoId, i++, json, WebData, js_data)) break;

			if (!json.empty())
			{
				json = HostUrlDecode(json);

				JsonReader Reader;
				JsonValue Root;

				if (Reader.parse(json, Root) && Root.isObject())
				{
					JsonValue streamingData = Root["streamingData"];

					if (streamingData.isObject() && streamingData.size() > 0) player_response_jsonData = json;
					else
					{
						JsonValue playabilityStatus = Root["playabilityStatus"];
						if (playabilityStatus.isObject())
						{
							JsonValue status = playabilityStatus["status"];
							if (status.isString() && status.asString() != "OK")
							{
								JsonValue reason = playabilityStatus["reason"];
								if (reason.isString())
								{
									string s = reason.asString();
									if (error_message.empty()) error_message = s;

									if (!s.empty())
									{
										DebugPrint();
										DebugPrint("Error: " + s);
									}
								}
							}
						}
					}
				}
			}
			if (!player_response_jsonData.empty()) break;
		}
		if (player_response_jsonData.empty())
		{
			player_response_jsonData = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE);
			player_response_jsonData.replace("\\/", "/");
			player_response_jsonData.replace("\\\"", "\"");
			player_response_jsonData.replace("\\\\", "\\");
		}
		if (player_response_jsonData.empty()) player_response_jsonData = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE_2);

		if (config::useSponsorBlock)
		{
			player_sponsors_jsonData = UrlGetString("https://sponsor.ajay.app/api/skipSegments?categories=" + HostUrlEncode("[\"sponsor\", \"selfpromo\",\"interaction\", \"intro\", \"outro\", \"preview\", \"music_offtopic\", \"filler\"]") + "&videoID=" + videoId, "", "", "", true);
			player_sponsors_jsonData.replace("\\/", "/");
			// player_sponsors_jsonData.replace("\\\"", "\"");
			player_sponsors_jsonData.replace("\\\\", "\\");
		}

		player_chapter_jsonData = GetJsonCode(WebData, MATCH_CHAPTER_RESPONSE);
		if (player_chapter_jsonData.empty()) player_chapter_jsonData = GetJsonCode(WebData, MATCH_CHAPTER_RESPONSE2);
		player_chapter_jsonData.replace("\\/", "/");
		// player_chapter_jsonData.replace("\\\"", "\"");
		player_chapter_jsonData.replace("\\\\", "\\");

		int stream_map_start = -1;
		int stream_map_len = 0;

		int adaptive_fmts_start = -1;
		int adaptive_fmts_len = 0;

		int hlsmpd_start = -1;
		int hlsmpd_len = 0;

		int dashmpd_start = -1;
		int dashmpd_len = 0;

		// url_encoded_fmt_stream_map
		if (stream_map_start <= 0 && (stream_map_start = WebData.find(MATCH_STREAM_MAP_START)) >= 0)
		{
			stream_map_start += MATCH_STREAM_MAP_START.size() + 2;
			stream_map_len = WebData.find(MATCH_END, stream_map_start + 10);
			if (stream_map_len > 0) stream_map_len += 10;
			else stream_map_len = WebData.size();
			stream_map_len -= stream_map_start;
		}

		// adaptive_fmts
		if (adaptive_fmts_start <= 0 && (adaptive_fmts_start = WebData.find(MATCH_ADAPTIVE_FMTS_START)) >= 0)
		{
			adaptive_fmts_start += MATCH_ADAPTIVE_FMTS_START.size() + 2;
			adaptive_fmts_len = WebData.find(MATCH_END, adaptive_fmts_start + 10);
			if (adaptive_fmts_len > 0) adaptive_fmts_len += 10;
			else adaptive_fmts_len = WebData.size();
			adaptive_fmts_len -= adaptive_fmts_start;
		}

		// dash mainfest mpd
		if (dashmpd_start <= 0 && (dashmpd_start = WebData.find(MATCH_DASHMPD_START)) >= 0)
		{
			dashmpd_start += MATCH_DASHMPD_START.size();
			dashmpd_len = WebData.find(MATCH_END2, dashmpd_start + 10);
			dashmpd_len -= dashmpd_start;
		}

		// hls live streaming
		if (hlsmpd_start <= 0 && (hlsmpd_start = WebData.find(MATCH_HLSMPD_START)) >= 0)
		{
			hlsmpd_start += MATCH_HLSMPD_START.size();
			hlsmpd_len = WebData.find(MATCH_END2, hlsmpd_start + 10);
			hlsmpd_len -= hlsmpd_start;
		}

		if (player_response_jsonData.empty() && stream_map_len <= 0 && hlsmpd_len <= 0)
		{
			if (@MetaData !is null) MetaData["errorMessage"] = error_message;

			DebugPrint();
			DebugPrint("PlayItemParse: FAIL");
			return "";
		}

		if (@MetaData !is null)
		{
			int type3D = 0;
			string threed = GetEntry(WebData, "threed_layout", ",");
			threed.Trim();
			threed.Trim("\"");
			threed.Trim(":");
			threed.Trim("\"");
			threed.Trim();
			if (threed == "1") type3D = 1; // SBS Half
			else if (threed == "2") type3D = 2; // SBS Full
			else if (threed == "3") type3D = 3; // T&B Half
			else if (threed == "4") type3D = 4; // T&B Full
			if (type3D > 0) MetaData["type3D"] = type3D;

			string title = string(MetaData["title"]);
			if (title.find("360°") >= 0 || title.find("360VR") >= 0) MetaData["is360"] = 1;
		}

		final_url = "";
		string final_url2;
		string final_ext;
		if (adaptive_fmts_start <= 0 && (dashmpd_len > 0 && hlsmpd_len > 0)) // 일단 live만 mpd 지원되게 하자...
		{
			string url = WebData.substr(dashmpd_start, dashmpd_len);

			url = HostUrlDecode(HostUrlDecode(url));
			url.replace("\\/", "/");
			url = CorrectURL(url);
			if (url.find("/s/") > 0)
			{
				string tmp = url;
				string signature = HostRegExpParse(tmp, "/s/([0-9A-Z]+.[0-9A-Z]+)");

				if (!signature.empty()) url = SignatureDecode(tmp, signature, "/signature/", WebData, js_data, JSFuncs, JSFuncArgs);
			}
			url = url + "?ForceBHD";
			final_url = url;
			final_ext = "mp4";

			//if (@MetaData !is null) MetaData["chatUrl"] = "https://www.youtube.com/live_chat?v=" + videoId + "&is_popout=1";
		}
		else if (hlsmpd_len > 0)
		{
			string url = WebData.substr(hlsmpd_start, hlsmpd_len);

			url = HostUrlDecode(HostUrlDecode(url));
			url.replace("\\/", "/");
			url = CorrectURL(url);
			if (url.find("/s/") > 0)
			{
				string tmp = url;
				string signature = HostRegExpParse(tmp, "/s/([0-9A-Z]+.[0-9A-Z]+)");

				if (!signature.empty()) url = SignatureDecode(tmp, signature, "/signature/", WebData, js_data, JSFuncs, JSFuncArgs);
			}
			url = url + "?ForceBHD";
			final_url = url;
			final_ext = "mp4";

			//if (@MetaData !is null) MetaData["chatUrl"] = "https://www.youtube.com/live_chat?v=" + videoId + "&is_popout=1";
		}
		else
		{
			int final_itag = 0;
			bool IsOK = false;
			JsonReader Reader;
			JsonValue Root;

			if (!player_response_jsonData.empty() && Reader.parse(player_response_jsonData, Root) && Root.isObject())
			{
				if (@MetaData !is null)
				{
					JsonValue playabilityStatus = Root["playabilityStatus"];
					if (playabilityStatus.isObject())
					{
						JsonValue status = playabilityStatus["status"];
						if (status.isString() && status.asString() != "OK")
						{
							JsonValue reason = playabilityStatus["reason"];
							if (reason.isString())
							{
								string s = reason.asString();
								if (error_message.empty()) error_message = s;

								if (!s.empty())
								{
									DebugPrint();
									DebugPrint("Error: " + s);
								}
							}
						}
					}
				}

				JsonValue streamingData = Root["streamingData"];
				if (streamingData.isObject())
				{
					for (int i = 0; i < 2; i++)
					{
						JsonValue formats = streamingData[i == 0 ? "formats" : "adaptiveFormats"];
						if (formats.isArray())
						{
							for(int j = 0, len = formats.size(); j < len; j++)
							{
								JsonValue format = formats[j];

								if (format.isObject())
								{
									if (i == 1)
									{
										JsonValue type = format["type"];

										// fragmented url
										if (type.isString() && type.asString() == "FORMAT_STREAM_TYPE_OTF") continue;
									}

									QualityListItem item;
									JsonValue itag = format["itag"];
									JsonValue url = format["url"];
									JsonValue bitrate = format["bitrate"];
									JsonValue size = format["contentLength"];
									JsonValue width = format["width"];
									JsonValue height = format["height"];
									JsonValue quality = format["quality"];
									JsonValue qualityLabel = format["qualityLabel"];
									JsonValue projectionType = format["projectionType"];
									JsonValue mimeType = format["mimeType"];
									JsonValue fps = format["fps"];
									JsonValue cipher = format["cipher"];
									JsonValue signatureCipher = format["signatureCipher"];
									JsonValue audioTrack = format["audioTrack"];
									
									if (itag.isInt()) item.itag = itag.asInt();
									if (width.isInt() && height.isInt()) item.resolution = formatInt(width.asInt()) + "x" + formatInt(height.asInt());
									if (bitrate.isInt())
									{
										item.bitrate = GetBitrateString(bitrate.asInt());
										item.bitrateVal = bitrate.asInt();
									}
									if (quality.isString()) item.quality = quality.asString();
									if (qualityLabel.isString()) item.qualityDetail = qualityLabel.asString();
									if (mimeType.isString()) item.format = GetCodecName(HostUrlDecode(mimeType.asString()));
									if (fps.isDouble())
									{
										double val = fps.asDouble();

										if (val > 0) item.fps = val;
									}
									if (projectionType.isString())
									{
										int type = parseInt(quality.asString());

										if (type == 2)
										{
											MetaData["type3D"] = 0;
											MetaData["is360"] = 1; // 360 VR
										}
										else if (type == 3)
										{
											MetaData["type3D"] = 3; 	// T&B Half
											MetaData["is360"] = 1; // 360 VR
										}
										else if (type == 4)
										{
										}
										int type3D;
										if (MetaData.get("type3D", type3D)) item.type3D = type3D;

										int is360;
										if (MetaData.get("is360", is360)) item.is360 = is360 == 1;
									}
									if (audioTrack.isObject())
									{
										JsonValue displayName = audioTrack["displayName"];
										if (displayName.isString()) item.audioName = displayName.asString();

										JsonValue id = audioTrack["id"];
										if (id.isString())
										{
											item.audioCode = id.asString();
											int p = item.audioCode.find(".");
											if (p > 0) item.audioCode = item.audioCode.Left(p);
										}
									}
									if (url.isString())
									{
										item.url = url.asString();
										if (item.url.find("xtags=drc") > 0) continue;
									}
									else if (cipher.isString() || signatureCipher.isString())
									{
										string u, signature, sigName = "signature";
										string str = cipher.isString() ? cipher.asString() : signatureCipher.isString() ? signatureCipher.asString() : "";

										str.replace("\\u0026", "&");
										array<string> params = str.split("&");
										for (uint i = 0; i < params.size(); i++)
										{
											string param = params[i];
											int k = param.find("=");

											if (k > 0)
											{
												string paramHeader = param.Left(k);
												string paramValue = param.substr(k + 1);

												if (paramHeader == "url") u = HostUrlDecode(paramValue);
												else if (paramHeader == "s") signature = HostUrlDecode(paramValue);
												else if (paramHeader == "sp") sigName = paramValue;
												else if (!u.empty()) u = u + "&" + paramHeader + "=" + HostUrlDecode(paramValue);
											}
											else if (!u.empty()) u = u + "&" + param;
										}
										if (!u.empty() && !signature.empty() && !js_data.empty())
										{
											string param = "&" + sigName + "=";

											u = SignatureDecode(u, signature, param, WebData, js_data, JSFuncs, JSFuncArgs);
										}
										item.url = u;
									}
									item.url.replace("\\u0026", "&");
									
									if (size.isInt())
									{
										item.sizeVal = size.asInt();
									}
									if (item.sizeVal == 0)
									{
										int p1 = item.url.find("clen=");
										
										if (p1 > -1)
										{
											int p2 = item.url.find("&", p1 + 1);
											
											if (p2 == 0) p2 = item.url.length();
											
											item.sizeVal = parseInt(item.url.substr(p1 + 5, p2 - (p1 + 5)));
										}
									}
									if (item.sizeVal == 0)
									{
										JsonValue duration = format["approxDurationMs"];
										
										if (duration.isString())
										{
											string s = duration.asString();
											
											item.sizeVal = CalcSize(item.bitrateVal, parseInt(s) / 1000);
										}
									}
									if (item.sizeVal == 0)
									{
										int p1 = item.url.find("dur=");
										
										if (p1 > -1)
										{
											int p2 = item.url.find("&", p1 + 1);
											
											if (p2 == 0) p2 = item.url.length();
											
											string s = item.url.substr(p1 + 4, p2 - (p1 + 4));
											
											s.replace(".", "");
											
											item.sizeVal = CalcSize(item.bitrateVal, parseInt(s) / 1000);
										}
									}

									if (item.itag != 0 && !item.url.empty())
									{
										if (videoId == "jj9RZODDDZs" && item.url.find("clen=") < 0) continue; // 특수한 경우 ㄷㄷㄷ
										if (item.url.find("dur=0.000") > 0) continue;

										if (item.url.find("xtags=vproj=mesh") > 0) MetaData["is360"] = 1;
										item.isHDR = IsHDR(item.itag);
										if (@QualityList !is null) AppendQualityList(QualityList, item, "");
										if (SelectBestProfile(final_itag, final_ext, item.itag, youtubeSets)) final_url = item.url;
										if (SelectBestProfile2(final_itag, final_ext, item.itag, youtubeSets)) final_url2 = item.url;
										IsOK = true;
									}
								}
							}
						}
					}
				}
			}

			if (!IsOK)
			{
				string str;
				if (stream_map_len > 0) str = WebData.substr(stream_map_start, stream_map_len);
				if (adaptive_fmts_len > 0)
				{
					if (!str.empty()) str = str + ",";
					str += WebData.substr(adaptive_fmts_start, adaptive_fmts_len);
				}
				str.replace("\\u0026", "&");

				array<string> lines = str.split(",");
				for (int i = 0, len = lines.size(); i < len; i++)
				{
					string line = lines[i];

					line.Trim(":");
					line.Trim("\"");
					line.Trim("\'");
					line.Trim(",");

					int itag = 0;
					string url, signature, sig, sigName = "signature";
					QualityListItem item;

					array<string> params = line.split("&");
					for (uint j = 0; j < params.size(); j++)
					{
						string param = params[j];
						int k = param.find("=");

						if (k > 0)
						{
							string paramHeader = param.Left(k);
							string paramValue = param.substr(k + 1);

							// "quality", "fallback_host", "url", "itag", "type"
							if (paramHeader == "url")
							{
								url = HostUrlDecode(HostUrlDecode(paramValue));
								url.replace("http://", "https://");
							}
							else if (paramHeader == "itag")
							{
								itag = parseInt(paramValue);
								item.itag = itag;
							}
							else if (paramHeader == "sig")
							{
								sig = HostUrlDecode(HostUrlDecode(paramValue));
								sig.Trim();
								signature = "";
							}
							else if (paramHeader == "s")
							{
								signature = HostUrlDecode(HostUrlDecode(paramValue));
								signature.Trim();
								sig = "";
							}
							else if (paramHeader == "sp")
							{
								sigName = HostUrlDecode(paramValue);
								sigName.Trim();
							}
							else if (paramHeader == "quality")
							{
								item.quality = paramValue;
							}
							else if (paramHeader == "size")
							{
								item.resolution = paramValue;
							}
							else if (paramHeader == "bitrate")
							{
								int64 bit = parseInt(paramValue);

								item.bitrate = GetBitrateString(bit);
								item.bitrateVal = bit;
							}
							else if (paramHeader == "projection_type")
							{
								int type = parseInt(paramValue);

								if (type == 2)
								{
									MetaData["type3D"] = 0;
									MetaData["is360"] = 1; // 360 VR
								}
								else if (type == 3)
								{
									MetaData["type3D"] = 3; 	// T&B Half
									MetaData["is360"] = 1; // 360 VR
								}
								else if (type == 4)
								{
								}
								int type3D;
								if (MetaData.get("type3D", type3D)) item.type3D = type3D;

								int is360;
								if (MetaData.get("is360", is360)) item.is360 = is360 == 1;
							}
							else if (paramHeader == "type")
							{
								item.format = GetCodecName(HostUrlDecode(paramValue));
							}
							else if (paramHeader == "fps")
							{
								double fps = parseFloat(paramValue);

								if (fps > 0) item.fps = fps;
							}
						}
					}
					if (videoId == "jj9RZODDDZs" && url.find("clen=") < 0) continue; // 특수한 경우 ㄷㄷㄷ
					if (url.find("dur=0.000") > 0) continue;

					if (!sig.empty()) url = url + "&signature=" + sig;
					else if (!signature.empty() && !js_data.empty())
					{
						string param = "&" + sigName + "=";

						url = SignatureDecode(url, signature, param, WebData, js_data, JSFuncs, JSFuncArgs);
					}
					if (itag > 0)
					{
						if (url.find("xtags=vproj=mesh") > 0) MetaData["is360"] = 1;
						item.isHDR = IsHDR(item.itag);
						if (@QualityList !is null) AppendQualityList(QualityList, item, url);
						if (SelectBestProfile(final_itag, final_ext, itag, youtubeSets)) final_url = url;
						if (SelectBestProfile2(final_itag, final_ext, itag, youtubeSets)) final_url2 = url;
					}
				}
			}
		}

		if (final_url.empty()) final_url = final_url2;
		if (!final_url.empty())
		{
			final_url.replace("http://", "https://");
			if (!videoId.empty() && (@MetaData !is null))
			{
				bool ParseMeta = false;
				array<dictionary> subtitle;
				JsonReader Reader;
				JsonValue Root;

				if (!player_response_jsonData.empty() && Reader.parse(player_response_jsonData, Root) && Root.isObject())
				{
					JsonValue videoDetails = Root["videoDetails"];
					if (videoDetails.isObject())
					{
						JsonValue title = videoDetails["title"];
						if (title.isString())
						{
							string sTitle = title.asString();

							if (!sTitle.empty())
							{
								sTitle = FixHtmlSymbols(sTitle);
								//sTitle.replace("+", " ");
								MetaData["title"] = sTitle;
								ParseMeta = true;
							}
						}

						JsonValue author = videoDetails["author"];
						if (author.isString())
						{
							string sAuthor = author.asString();

							if (!sAuthor.empty())
							{
								//sAuthor.replace("+", " ");
								MetaData["author"] = sAuthor;
								ParseMeta = true;
							}
						}

						JsonValue shortDescription = videoDetails["shortDescription"];
						if (shortDescription.isString())
						{
							string sDesc = shortDescription.asString();

							if (!sDesc.empty())
							{
								sDesc = FixHtmlSymbols(sDesc);
								//sDesc.replace("+", " ");
								sDesc.replace("\\r\\n", "\n");
								sDesc.replace("\\n", "\n");
								MetaData["content"] = sDesc;
								ParseMeta = true;
							}
						}

						JsonValue lengthSeconds = videoDetails["lengthSeconds"];
						if (lengthSeconds.isString()) MetaData["duration"] = parseInt(lengthSeconds.asString()) * 1000;

						JsonValue viewCount = videoDetails["viewCount"];
						if (viewCount.isString()) MetaData["viewCount"] = viewCount.asString();

						JsonValue thumbnail = videoDetails["thumbnail"];
						if (thumbnail.isObject())
						{
							JsonValue thumbnails = thumbnail["thumbnails"];
							if (thumbnails.isArray())
							{
								for (int j = 0, len = thumbnails.size(); j < len; j++)
								{
									JsonValue it = thumbnails[j];

									if (it.isObject())
									{
										JsonValue url = it["url"];

										if (url.isString())
										{
											MetaData["thumbnail"] = url.asString();
											break;
										}
									}
								}
							}
						}
					}

					JsonValue microformat = Root["microformat"];
					if (!microformat.isObject())
					{
						string temp = GetJsonCode(WebData, MATCH_PLAYER_RESPONSE_2);

						if (!temp.empty() && Reader.parse(temp, Root) && Root.isObject())
						{
							microformat = Root["microformat"];
						}
					}
					if (microformat.isObject())
					{
						JsonValue playerMicroformatRenderer = microformat["playerMicroformatRenderer"];
						if (playerMicroformatRenderer.isObject())
						{
							JsonValue publishDate = playerMicroformatRenderer["publishDate"];
							if (publishDate.isString())
							{
								string sDate = publishDate.asString();

								if (!sDate.empty())
								{
									MetaData["date"] = sDate.substr(0, 10);
									ParseMeta = true;
								}
							}

							JsonValue title = playerMicroformatRenderer["title"];
							if (title.isObject())
							{
								JsonValue simpleText = title["simpleText"];
								if (simpleText.isString())
								{
									string sTitle = simpleText.asString();

									if (!sTitle.empty())
									{
										sTitle = FixHtmlSymbols(sTitle);
										//sTitle.replace("+", " ");
										MetaData["title"] = sTitle;
										ParseMeta = true;
									}
								}
							}

							JsonValue description = playerMicroformatRenderer["description"];
							if (description.isObject())
							{
								JsonValue simpleText = description["simpleText"];
								if (simpleText.isString())
								{
									string sDesc = simpleText.asString();

									if (!sDesc.empty())
									{
										sDesc = FixHtmlSymbols(sDesc);
										//sDesc.replace("+", " ");
										sDesc.replace("\\r\\n", "\n");
										sDesc.replace("\\n", "\n");
										MetaData["content"] = sDesc;
										ParseMeta = true;
									}
								}
							}

							JsonValue author = playerMicroformatRenderer["ownerChannelName"];
							if (author.isString())
							{
								string sAuthor = author.asString();

								if (!sAuthor.empty())
								{
									//sAuthor.replace("+", " ");
									MetaData["author"] = sAuthor;
									ParseMeta = true;
								}
							}

							JsonValue authorShort = playerMicroformatRenderer["ownerProfileUrl"];
							if (authorShort.isString())
							{
								string sAuthorShort = authorShort.asString();

								if (!sAuthorShort.empty())
								{
									sAuthorShort = sAuthorShort.substr(sAuthorShort.findLast("/") + 1).TrimLeft("@");
									MetaData["authorShort"] = sAuthorShort;
									ParseMeta = true;
								}
							}

							JsonValue viewCount = playerMicroformatRenderer["viewCount"];
							if (viewCount.isString()) MetaData["viewCount"] = viewCount.asString();

							JsonValue lengthSeconds = playerMicroformatRenderer["lengthSeconds"];
							if (lengthSeconds.isString()) MetaData["duration"] = parseInt(lengthSeconds.asString()) * 1000;
						}
					}

					JsonValue captions = Root["captions"];
					if (captions.isObject())
					{
						JsonValue playerCaptionsTracklistRenderer = captions["playerCaptionsTracklistRenderer"];

						if (playerCaptionsTracklistRenderer.isObject())
						{
							JsonValue captionTracks = playerCaptionsTracklistRenderer["captionTracks"];

							if (captionTracks.isArray())
							{
								for (int j = 0, len = captionTracks.size(); j < len; j++)
								{
									JsonValue captionTrack = captionTracks[j];

									if (captionTrack.isObject())
									{
										JsonValue baseUrl = captionTrack["baseUrl"];
										if (baseUrl.isString())
										{
											string vtt = "&fmt=vtt";
											string url = baseUrl.asString();
											int p = url.find("&fmt=");
											if (p > 0)
											{
												int e = url.find("&", p + 1);
												if (e < 0) e = url.length();
												url.erase(p, e - p);
												url.insert(p, vtt);
											}
											else url += vtt;

											string subname;
											JsonValue name = captionTrack["name"];
											if (name.isObject())
											{
												JsonValue simpleText = name["simpleText"];
												if (simpleText.isString()) subname = simpleText.asString();
											}
											else
											{
												JsonValue runs = name["runs"];

												if (runs.isArray())
												{
													for (int k = 0; k < runs.size(); k++)
													{
														JsonValue run = runs[k];
														if (run.isObject())
														{
															JsonValue text = run["text"];
															if (text.isString())
															{
																subname = text.asString();
																break;
															}
														}
													}
												}
											}
											if (subname.rfind(" - Default") == subname.length() - 10) subname = subname.substr(0, subname.length() - 10);

											JsonValue languageCode = captionTrack["languageCode"];

											dictionary item;

											JsonValue kind = captionTrack["kind"];
											if (kind.isString()) item["kind"] = kind.asString();

											item["name"] = subname;
											item["url"] = url;
											if (languageCode.isString()) item["langCode"] = languageCode.asString();
											subtitle.insertLast(item);
										}
									}
								}
							}
						}
					}
				}

				if (!ParseMeta)
				{
					string api = "https://www.googleapis.com/youtube/v3/videos?id=" + videoId + "&part=snippet,statistics,contentDetails&fields=items/snippet/title,items/snippet/publishedAt,items/snippet/channelTitle,items/snippet/description,items/statistics,items/contentDetails/duration";
					string json = UrlGetString(api + (!config::ytApiKey.isEmpty() ? "&key=" + config::ytApiKey : ""), GetUserAgent(), "", "", true);

					JsonReader Reader;
					JsonValue Root;

					if (Reader.parse(json, Root) && Root.isObject())
					{
						JsonValue items = Root["items"];
						if (items.isArray())
						{
							JsonValue item = items[0];

							if (item.isObject())
							{
								JsonValue statistics = item["statistics"];
								if (statistics.isObject())
								{
									JsonValue viewCount = statistics["viewCount"];
									if (viewCount.isString()) MetaData["viewCount"] = viewCount.asString();

									JsonValue likeCount = statistics["likeCount"];
									if (likeCount.isString()) MetaData["likeCount"] = likeCount.asString();

									JsonValue dislikeCount = statistics["dislikeCount"];
									if (dislikeCount.isString()) MetaData["dislikeCount"] = dislikeCount.asString();
								}

								JsonValue snippet = item["snippet"];
								if (snippet.isObject())
								{
									JsonValue title = snippet["title"];
									if (title.isString())
									{
										string sTitle = title.asString();

										if (!sTitle.empty()) MetaData["title"] = FixHtmlSymbols(sTitle);
									}

									JsonValue channelTitle = snippet["channelTitle"];
									if (channelTitle.isString())
									{
										string sAuthor = channelTitle.asString();

										if (!sAuthor.empty()) MetaData["author"] = sAuthor;
									}

									JsonValue description = snippet["description"];
									if (description.isString())
									{
										string sDesc = description.asString();

										if (!sDesc.empty())
										{
											sDesc = FixHtmlSymbols(sDesc);
											sDesc.replace("\\r\\n", "\n");
											sDesc.replace("\\n", "\n");
											MetaData["content"] = sDesc;
										}
									}

									JsonValue publishedAt = snippet["publishedAt"];
									if (publishedAt.isString())
									{
										string sDate = publishedAt.asString();

										if (!sDate.empty()) MetaData["date"] = sDate.substr(0, 10);
									}
								}

								JsonValue contentDetails = item["contentDetails"];
								if (contentDetails.isObject())
								{
									JsonValue duration = contentDetails["duration"];
									if (duration.isString())
									{
										array<dictionary> match;

										if (HostRegExpParse(duration.asString(), "PT(\\d+H)?(\\d{1,2}M)?(\\d{1,2}S)?", match) && match.size() == 4)
										{
											string h;
											string m;
											string s;

											match[1].get("first", h);
											match[2].get("first", m);
											match[3].get("first", s);

											MetaData["duration"] = (parseInt(h) * 3600 + parseInt(m) * 60 + parseInt(s)) * 1000;
										}
									}
								}
							}
						}
					}
				}

				if (subtitle.empty() && (@QualityList !is null))
				{
					// langCode: http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
					// http://video.google.com/timedtext?lang=en&v=R9Fu6Leb_aE&fmt=vtt
					// &fmt=srt		&fmt=vtt
					string api = "https://www.youtube.com/api/timedtext?v=" + videoId + "&expire=1&type=list";
					string xml = UrlGetString(api, GetUserAgent(), "", "", true);
					XMLDocument dxml;

					if (dxml.Parse(xml))
					{
						XMLElement Root = dxml.RootElement();

						if (Root.isValid() && Root.Name() == "transcript_list")
						{
							XMLElement track = Root.FirstChildElement("track");

							while (track.isValid())
							{
								XMLAttribute lang_code = track.FindAttribute("lang_code");

								if (lang_code.isValid())
								{
									XMLAttribute name = track.FindAttribute("name");
									XMLAttribute lang_translated = track.FindAttribute("lang_translated");
									XMLAttribute lang_original = track.FindAttribute("lang_original");
									string s1 = name.isValid() ? name.Value() : "";
									string s2 = lang_translated.isValid() ? lang_translated.Value() : "";
									string s3 = lang_original.isValid() ? lang_original.Value() : "";
									string s4 = lang_code.isValid() ? lang_code.Value() : "";
									string s5 = "https://www.youtube.com/api/timedtext?v=" + videoId + "&lang=" + s4;
									dictionary item;

									item["name"] = s1;
									item["langTranslated"] = s2;
									item["langOriginal"] = s3;
									item["langCode"] = s4;
									item["url"] = s5;
									subtitle.insertLast(item);
								}
								track = track.NextSiblingElement();
							}
						}
					}
				}
				if (!subtitle.empty() && (@QualityList !is null)) MetaData["subtitle"] = subtitle;

				// Chapters
				if ((@QualityList !is null) && (!player_sponsors_jsonData.empty() || !player_chapter_jsonData.empty()))
				{
					JsonReader reader;
					JsonValue sponsorsRoot;
					JsonValue ytRoot;

					array<dictionary> ytChapt;
					array<dictionary> spChapt;

					// Youtube Chapters
					if (reader.parse(player_chapter_jsonData, ytRoot) && ytRoot.isObject())
					{
						JsonValue chapters = ytRoot["chapters"];

						if (chapters.isArray())
						{
							for(int j = 0, len = chapters.size(); j < len; j++)
							{
								JsonValue chapter = chapters[j];

								if (chapter.isObject())
								{
									JsonValue chapterRenderer = chapter["chapterRenderer"];

									if (chapterRenderer.isObject())
									{
										JsonValue title = chapterRenderer["title"];

										if (title.isObject())
										{
											JsonValue simpleText = title["simpleText"];
											JsonValue timeRangeStartMillis = chapterRenderer["timeRangeStartMillis"];

											if (simpleText.isString() && timeRangeStartMillis.isInt())
											{
												dictionary item;

												item["title"] = simpleText.asString();
												item["time"] = timeRangeStartMillis.asInt();
												ytChapt.insertLast(item);
											}
										}
									}
								}
							}
						}
					}

					// Sponsors
					if (reader.parse(player_sponsors_jsonData, sponsorsRoot) && sponsorsRoot.isArray())
					{
						// Apparently declaring string dictionaries is not a thing??
						dictionary typesToId = {
							{"sponsor", 0},
							{"selfpromo", 1},
							{"interaction", 2},
							{"intro", 3},
							{"outro", 4},
							{"preview", 5},
							{"music_offtopic", 6},
							{"filler", 7}
						};

						array<string> readableCats = {"Sponsor", "Self Promotion", "Interaction Reminder", "Intro", "Outro", "Preview", "No Music", "Non-essential Filler"};

						for(int j = 0, len = sponsorsRoot.size(); j < len; j++)
						{
							JsonValue chapter = sponsorsRoot[j];

							if (chapter.isObject())
							{
								JsonValue segment = chapter["segment"];
								if (segment.isArray()) {
									dictionary startItem;
									dictionary endItem;

									startItem["time"] = segment[0].asFloat() * 1000;
									endItem["time"] = segment[1].asFloat() * 1000;

									string startChapterName = getChapterName(ytChapt, int(startItem["time"]));
									string endChapterName = getChapterName(ytChapt, int(endItem["time"]));

									int categoryId = int(typesToId[chapter["category"].asString()]);
									startItem["title"] = (startChapterName != "" ? startChapterName + " | " : "") + "SB - " + readableCats[categoryId];

									endItem["title"] = endChapterName == "" ? "Video" : endChapterName;

									spChapt.insertLast(startItem);
									spChapt.insertLast(endItem);
								}
							}
						}
					}

					array<dictionary> chapt;

					for (uint i = 0; i < ytChapt.length(); i++) {
						string sponsor = getChapterName(spChapt, int(ytChapt[i]["time"]));
						if (sponsor.findFirst("SB -") > 0) {
							ytChapt[i]["title"] = string(ytChapt[i]["title"]) + " | " + sponsor;
						}
						ytChapt[i]["time"] = formatFloat(float(ytChapt[i]["time"]), "", 32, 0);
						chapt.insertLast(ytChapt[i]);
					}
					for (uint i = 0; i < spChapt.length(); i++) {
						spChapt[i]["time"] = formatFloat(float(spChapt[i]["time"]), "", 32, 0);
						chapt.insertLast(spChapt[i]);
					}

					if (!chapt.empty() && (@QualityList !is null)) MetaData["chapter"] = chapt;

				}
			}

			if (@MetaData !is null) MetaData["fileExt"] = final_ext;

			FixMetaData(MetaData, true);
			FixQualityList(QualityList, MetaData);
			SaveCache(path, MetaData, QualityList, final_url);

			if (@MetaData !is null)
			{
				DebugPrint();
				DebugPrint("MetaData:");
				DebugPrint(MetaData, "  ");
			}

			if (@QualityList !is null)
			{
				DebugPrint();
				DebugPrint("QualityList:");
				DebugPrint(QualityList, "  ");
			}

			DebugPrint();
			DebugPrint("PlayItemParse: SUCCESS");
			return final_url;
		}
	}

	if (@MetaData !is null) MetaData["errorMessage"] = error_message;

	DebugPrint();
	DebugPrint("PlayItemParse: FAIL");
	return "";
}

string getChapterName(array<dictionary> chapters, int time) {
	string name = "";
	for (uint i = 0; i < chapters.length(); i++) {
		if (int(chapters[i]["time"]) <= time && (i >= chapters.length() - 1 ? true : int(chapters[i+1]["time"]) > time)) {
			name = string(chapters[i]["title"]);
			break;
		}
	}
	return name;
}

bool PlaylistCheck(const string &in path)
{
	HostIncTimeOut(5 * 60 * 1000);
	
	InitMod(true);

	DebugPrint();
	DebugPrint("PlayListCheck: \"" + path + "\"");

	bool succ;

	if (config::autoRedirect)
	{
		string tmp = ExtractRedirect(path);
		
		if (!tmp.isEmpty() && (tmp != path))
		{
			DebugPrint("PlayListCheck: \"" + tmp + "\"");
			
			succ = _PlaylistCheck(tmp);
		}
		else
		{
			succ = _PlaylistCheck(path);
		}
	}
	else
	{
		succ = _PlaylistCheck(path);
	}

	DebugPrint("PlayListCheck: " + (succ ? "true" : "false"));
	
	return succ;
}

bool _PlaylistCheck(string path)
{
	if (config::skipStartPos && ContainStartAt(path)) return true;
		
	if (_PlayitemCheck(path)) return true;

	string url = path;

	url.MakeLower();
	url = RepleaceYouTubeUrl(url);
	url.replace("https", "");
	url.replace("http", "");

	if (url == YOUTUBE_MP_URL) return false;
	if (url.find(YOUTUBE_PL_URL) >= 0 || (url.find(YOUTUBE_URL) >= 0 && url.find("&list=") >= 0)) return true;
	if (url.find(YOUTUBE_USER_URL) >= 0 || url.find(YOUTUBE_CHANNEL_URL) >= 0 || url.find(YOUTUBE_USER_SHORT_URL) >= 0) return true;
	if (url.find(YOUTUBE_URL_LIBRARY) >= 0) return true;
	if (url.find(YOUTUBE_MP_URL) >= 0 && url.find("watch?") < 0)
	{
		int p = url.find(YOUTUBE_MP_URL);

		url.erase(p, YOUTUBE_MP_URL.size());
		if (url.find("/") >= 0 || url.find("?list=") >= 0 || url.find("&") >= 0) return true;
	}

	return false;
}

array<dictionary> PlayerYouTubePlaylistByAPI(string url)
{
	array<dictionary> ret;
	string pid = HostRegExpParse(url, "list=([-a-zA-Z0-9_]+)");

	if (!pid.empty())
	{
		string nextToken;
		string vid = GetVideoID(url);
		string maxResults = HostRegExpParse(url, "maxResults=([0-9]+)");
		uint maxCount = parseUInt(maxResults);

		for (int i = 0; i < 200; i++)
		{
			string api = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=" + pid + "&maxResults=50";

			if (!nextToken.empty())
			{
				api = api + "&pageToken=" + nextToken;
				nextToken = "";
			}
			string json = UrlGetString(api + (!config::ytApiKey.isEmpty() ? "&key=" + config::ytApiKey : ""), GetUserAgent(), "", "", true);
			//HostIncTimeOut(5000);
			if (json.empty()) break;
			else
			{
				JsonReader Reader;
				JsonValue Root;

				if (Reader.parse(json, Root) && Root.isObject())
				{
					JsonValue nextPageToken = Root["nextPageToken"];
					if (nextPageToken.isString()) nextToken = nextPageToken.asString();

					JsonValue items = Root["items"];
					if (items.isArray())
					{
						string currVideoId, prevVideoId;

						for(int j = 0, len = items.size(); j < len; j++)
						{
							JsonValue item = items[j];

							if (item.isObject())
							{
								JsonValue snippet = item["snippet"];

								if (snippet.isObject())
								{
									JsonValue resourceId = snippet["resourceId"];

									if (resourceId.isObject())
									{
										JsonValue videoId = resourceId["videoId"];

										if (videoId.isString())
										{
											currVideoId = videoId.asString();

											if (currVideoId == prevVideoId) continue;

											prevVideoId = currVideoId;

											dictionary item;
											bool IsDel = false;

											item["url"] = "https://www.youtube.com/watch?v=" + currVideoId;

											JsonValue title = snippet["title"];
											if (title.isString())
											{
												string str = title.asString();

												item["title"] = str;
												IsDel = (("Deleted video" == str) || ("Private video" == str));
											}

											JsonValue thumbnails = snippet["thumbnails"];
											if (thumbnails.isObject() && thumbnails.size() > 0)
											{
												JsonValue medium = thumbnails["medium"];
												string thumbnail;

												if (medium.isObject())
												{
													JsonValue url = medium["url"];

													if (url.isString()) thumbnail = url.asString();
												}
												if (thumbnail.empty())
												{
													JsonValue def = thumbnails["default"];

													if (def.isObject())
													{
														JsonValue url = def["url"];

														if (url.isString()) thumbnail = url.asString();
													}
												}
												/*
												JsonValue high = thumbnails["high"];
												if (high.isObject())
												{
													JsonValue url = high["url"];

													if (url.isString()) thumbnail = url.asString();
												}*/
												if (!thumbnail.empty()) item["thumbnail"] = thumbnail;
											}
											else if (IsDel) continue;
											if (vid == videoId.asString()) item["current"] = "1";

											ret.insertLast(item);
										}
									}
								}
							}
						}
					}
				}
			}
			if (nextToken.empty()) break;
			if (maxCount > 0 && ret.size() >= maxCount) break;
		}
	}

	return ret;
}

string FixHtmlSymbols(string inStr)
{
	inStr.replace("&quot;", "\"");
	inStr.replace("&amp;", "&");
	inStr.replace("&#39;", "'");
	inStr.replace("&#039;", "'");
	inStr.replace("\\n", "\r\n");
	inStr.replace("\n", "\r\n");
	inStr.replace("\\", "");

	inStr.replace(" - YouTube", "");
	inStr.replace(" on Vimeo", "");

	return inStr;
}

bool IsArrayExist(array<dictionary> &pls, string url)
{
	for (uint i = 0; i < pls.size(); i++)
	{
		string str;
		bool isValid = pls[i].get("url", str);

		if (isValid && str == url) return true;
	}

	return false;
}

string ParserPlaylistItem(string html, int start, int len, string vid, array<dictionary> &pls)
{
	string block = html.substr(start, len);
	string szEnd = block;
	array<dictionary> match;
	string data_video_id;
	string data_video_username;
	string data_video_title;
	string data_thumbnail_url;

	while (HostRegExpParse(szEnd, "([a-z-]+)=\"([^\"]+)\"", match))
	{
		if (match.size() == 3)
		{
			string propHeader;
			string propValue;

			 match[1].get("first", propHeader);
			 match[2].get("first", propValue);
			 propHeader.Trim();
			 propValue.Trim();

			// data-video-id, data-video-clip-end, data-index, data-video-username, data-video-title, data-video-clip-start.
			if (propHeader == "data-video-id") data_video_id = propValue;
			else if (propHeader == "data-video-username") data_video_username = FixHtmlSymbols(propValue);
			else if (propHeader == "data-video-title" || propHeader == "data-title") data_video_title = FixHtmlSymbols(propValue);
			else if (propHeader == "data-thumbnail-url") data_thumbnail_url = propValue;
		}

		match[0].get("second", szEnd);
	}

	if (!data_video_id.empty())
	{
		string url = "https://www.youtube.com/watch?v=" + data_video_id;
		if (IsArrayExist(pls, url)) return "";

		dictionary item;
		item["url"] = url;
		item["title"] = data_video_title;
		if (data_thumbnail_url.empty())
		{
			int p = html.find("yt-thumb-clip", start);

			if (p >= 0)
			{
				int img = html.find(data_video_id, p);

				if (img > p)
				{
					while (img > p)
					{
						string ch = html.substr(img, 1);

						if (ch == "\"" || ch == "=") break;
						else img--;
					}

					int end = html.find(".jpg", img);
					if (end > img)
					{
						string thumb = html.substr(img, end + 4 - img);

						thumb.Trim();
						thumb.Trim("\"");
						thumb.Trim("=");
						if (thumb.find("://") < 0)
						{
							if (thumb.find("//") == 0) thumb = "https:" + thumb;
							else thumb = "https://" + thumb;
						}
						data_thumbnail_url = thumb;
					}
				}
			}
		}
		if (!data_thumbnail_url.empty()) item["thumbnail"] = data_thumbnail_url;

		if (block.find("currently-playing") >= 0 || vid == data_video_id) item["current"] = "1";
		pls.insertLast(item);
	}

	return data_video_id;
}

string ParserPlaylistItem(JsonValue object, array<dictionary> &pls, string vid)
{
	JsonValue videoId = object["videoId"];
	string lastvideoId;

	if (videoId.isString())
	{
		string url = "https://www.youtube.com/watch?v=" + videoId.asString();
		if (IsArrayExist(pls, url)) return lastvideoId;

		JsonValue title = object["title"];
		if (title.isObject())
		{
			JsonValue simpleText = title["simpleText"];

			if (!simpleText.isString())
			{
				JsonValue runs = title["runs"];

				if (runs.isObject())
				{
					JsonValue zero = runs["0"];

					if (zero.isObject()) simpleText = zero["text"];
				}
				else if (runs.isArray())
				{
					JsonValue zero = runs[0];

					if (zero.isObject()) simpleText = zero["text"];
				}
			}
			
			if (simpleText.isString())
			{
				dictionary item;
				item["title"] = simpleText.asString();
				
				string duration;
				JsonValue lengthSeconds = object["lengthSeconds"];
				JsonValue lengthText = object["lengthText"];

				if (lengthSeconds.isUInt()) duration = lengthSeconds.asString();
				else if (lengthText.isObject())
				{
					simpleText = lengthText["simpleText"];

					if (simpleText.isString()) duration = simpleText.asString();
				}

				string thumb;
				JsonValue thumbnail = object["thumbnail"];
				if (thumbnail.isObject())
				{
					JsonValue thumbnails = thumbnail["thumbnails"];

					if (thumbnails.isArray())
					{
						JsonValue th = thumbnails[0];

						if (th.isObject())
						{
							JsonValue url = th["url"];

							if (url.isString()) thumb = url.asString();
						}
					}
				}

				lastvideoId = videoId.asString();

				item["url"] = url;
				item["duration"] = duration;
				if (!thumb.empty()) item["thumbnail"] = thumb;
				if (lastvideoId == vid) item["current"] = "1";
				pls.insertLast(item);
			}
		}
	}
	return lastvideoId;
}

JsonValue GetJsonPath(JsonValue object, string path)
{
	JsonValue ret;

	while (!path.empty())
	{
		int p = path.find("/");
		string str;

		if (p >= 0)
		{
			str = path.substr(0, p);
			path.erase(0, p + 1);
		}
		else
		{
			str = path;
			path = "";
		}
		if (!str.empty())
		{
			JsonValue r;

			if (object.isObject()) r = object[str];
			else if (object.isArray()) r = object[parseInt(str)];
			if (path.empty()) ret = r;
			if (r.isObject() || r.isArray()) object = r;
			else break;
		}
	}
	return ret;
}

string MATCH_PLAYLIST_ITEM_START	= "<li class=\"yt-uix-scroller-scroll-unit ";
string MATCH_PLAYLIST_ITEM_START2	= "<tr class=\"pl-video yt-uix-tile ";
string MATCH_PLAYLIST_ITEM_START3	= "\"playlistVideoRenderer\"";

array<dictionary> PlaylistParse(const string &in path)
{
	HostIncTimeOut(5 * 60 * 1000);
	
	InitMod(true);

	return _PlaylistParse(path);
}

array<dictionary> _PlaylistParse(string path)
{
	//HostOpenConsole();

	DebugPrint();
	DebugPrint("PlayListParse: \"" + path + "\"");

	array<dictionary> ret;
	
	if (config::autoRedirect)
	{
		string tmp = ExtractRedirect(path);
		
		if (!tmp.isEmpty() && (tmp != path))
		{
			DebugPrint("PlayListParse: \"" + tmp + "\"");
			
			path = tmp;
		}
	}

	bool is_plst = _PlaylistCheck(path);
	bool is_item = _PlayitemCheck(path);

	if (path.isEmpty())
	{
		//
	}
	else if (is_item || (config::skipStartPos && ContainStartAt(path)))
	{
		if (config::skipStartPos) path = RemoveStartAt(path);

		dictionary MetaData;

		_PlayitemParse(path, @MetaData, null);//if result

		dictionary item;

		item["url"] = string(MetaData["webUrl"]);
		item["title"] = string(MetaData["title"]);
		item["duration"] = int64(MetaData["duration"]);
		item["thumbnail"] = string(MetaData["thumbnail"]);
		item["current"] = "1";

		ret.insertLast(item);
	}
	else if (is_plst)
	{
		string url = path;

		string channelId = HostRegExpParse(url, "www.youtube.com/(?:channel/|c/|user/|@)([^/?&#]+)");
		if (!channelId.empty())
		{
			if (url.find(YOUTUBE_CHANNEL_URL) < 0)
			{
				string dataStr = UrlGetString(RepleaceYouTubeUrl(url), /*GetUserAgent()*/"", "", "", false);

				channelId = GetEntry(dataStr, "content=\"https://www.youtube.com/channel/", "\"");
				if (channelId.empty()) channelId = HostRegExpParse(dataStr, "(\\\\?\"channelId\\\\?\":\\\\?\"([-a-zA-Z0-9_]+)\\\\?)");
			}
			if (channelId.substr(0, 2) == "UC")
			{
				string playlistId = "UU" + channelId.substr(2, channelId.length() - 2);

				url = "https://www.youtube.com/playlist?list=" + playlistId;
			}
		}
		
		url = RepleaceYouTubeUrl(url);
		url = MakeYouTubeUrl(url);

		string pid = HostRegExpParse(url, "list=([-a-zA-Z0-9_]+)");
		string vid = GetVideoID(url);

		bool MixedFormat = pid.substr(0, 2) == "RD" || pid.substr(0, 2) == "UL" || pid.substr(0, 2) == "PU";
		if (MixedFormat) url = "https://www.youtube.com/watch?v=" + vid + "&list=" + pid;
		else url = "https://www.youtube.com/playlist?list=" + pid;

		string dataStr = UrlGetString(RepleaceYouTubeUrl(url), /*GetUserAgent()*/"", "", "", false);

		while (!dataStr.empty())
		{
			array<string> Entrys;

			GetEntrys(dataStr, "ytInitialData = ", "};", Entrys);
			dataStr = "";
			string lastvideoId;
			for (uint i = 0; i < Entrys.size(); i++)
			{
				string jsonEntry = Entrys[i];
				JsonReader reader;
				JsonValue root;

				jsonEntry += "}";
				if (reader.parse(jsonEntry, root) && root.isObject())
				{
					JsonValue contents = GetJsonPath(root, "contents/twoColumnBrowseResultsRenderer/tabs/0/tabRenderer/content/sectionListRenderer/contents/0/itemSectionRenderer/contents/0/playlistVideoListRenderer/contents");
					if (!contents.isArray()) contents = GetJsonPath(root, "contents/twoColumnWatchNextResults/playlist/playlist/contents");

					if (contents.isArray())
					{
						for(int j = 0, len = contents.size(); j < len; j++)
						{
							JsonValue content = contents[j];

							if (content.isObject())
							{
								JsonValue playlistPanelVideoRenderer = content["playlistPanelVideoRenderer"];
								JsonValue playlistVideoRenderer = content["playlistVideoRenderer"];

								if (playlistPanelVideoRenderer.isObject() && playlistPanelVideoRenderer.size() > 0) lastvideoId = ParserPlaylistItem(playlistPanelVideoRenderer, ret, vid);
								else if (playlistVideoRenderer.isObject()) lastvideoId = ParserPlaylistItem(playlistVideoRenderer, ret, vid);
								//HostIncTimeOut(5000);
							}
						}
					}
				}
			}
			if (!lastvideoId.empty())
			{
				url = "https://www.youtube.com/watch?v=" + lastvideoId + "&list=" + pid;
				dataStr = UrlGetString(RepleaceYouTubeUrl(url), /*GetUserAgent()*/"", "", "", false);
				//HostIncTimeOut(5000);
			}
		}

		if (ret.size() == 0)
		{
			url += "&disable_polymer=true";
			dataStr = UrlGetString(RepleaceYouTubeUrl(url), /*GetUserAgent()*/"", "", "", false);

			bool UseJson = false;
			string moreStr = MixedFormat ? "" : dataStr;
			while (!dataStr.empty())
			{
				string match;

				int p = dataStr.find(MATCH_PLAYLIST_ITEM_START);
				if (p >= 0) match = MATCH_PLAYLIST_ITEM_START;
				else
				{
					p = dataStr.find(MATCH_PLAYLIST_ITEM_START2);
					if (p >= 0) match = MATCH_PLAYLIST_ITEM_START2;
					else
					{
						p = dataStr.find(MATCH_PLAYLIST_ITEM_START3);
						if (p >= 0)
						{
							match = MATCH_PLAYLIST_ITEM_START3;
							UseJson = true;
						}
					}
				}
				if (p < 0) break;

				//HostIncTimeOut(5000);
				string lastvideoId;
				while (p >= 0)
				{
					if (UseJson)
					{
						string code = GetJsonCode(dataStr, match, p);
						JsonReader reader;
						JsonValue root;

						if (reader.parse(code, root) && root.isObject())
						{
							JsonValue videoId = root["videoId"];

							if (videoId.isString())
							{
								string id = videoId.asString();
								string url = "https://www.youtube.com/watch?v=" + id;

								if (!IsArrayExist(ret, url))
								{
									dictionary item;
									item["url"] = url;

									JsonValue lengthSeconds = root["lengthSeconds"];
									if (lengthSeconds.isString()) item["duration"] = lengthSeconds.asString();

									JsonValue title = root["title"];
									if (title.isObject())
									{
										JsonValue simpleText = title["simpleText"];
										if (simpleText.isString()) item["title"] = simpleText.asString();
									}

									JsonValue thumbnail = root["thumbnail"];
									if (thumbnail.isObject())
									{
										JsonValue thumbnails = thumbnail["thumbnails"];
										if (thumbnails.isArray())
										{
											JsonValue th = thumbnails[0];

											if (th.isObject())
											{
												JsonValue url = th["url"];

												if (url.isString()) item["thumbnail"] = url.asString();
											}
										}
									}

									ret.insertLast(item);
								}
								lastvideoId = id;
							}
						}
						p += match.size();
					}
					else
					{
						p += match.size();

						int end = dataStr.find(">", p);
						if (end > p)
						{
							string id = ParserPlaylistItem(dataStr, p, end - p, vid, ret);

							if (!id.empty()) lastvideoId = id;
						}
					}
					//HostIncTimeOut(5000);
					p = dataStr.find(match, p);
				}

				if (MixedFormat)
				{
					if (lastvideoId.empty()) break;

					url = "https://www.youtube.com/watch?v=" + lastvideoId + "&list=" + pid + "&disable_polymer=true";
					dataStr = UrlGetString(RepleaceYouTubeUrl(url), /*GetUserAgent()*/"", "", "", false);
				}
				else
				{
					moreStr = "";
					dataStr = "";
					string moreUrl = HostUrlDecode(HostRegExpParse(moreStr, "data-uix-load-more-href=\"/?([^\"]+)\\\""));
					if (!moreUrl.empty())
					{
						moreUrl.replace("&amp;", "&");
						moreUrl += "&disable_polymer=true";
						url = "https://www.youtube.com/" + moreUrl;
						string json = UrlGetString(url, /*GetUserAgent()*/"", "x-youtube-client-name: 1\r\nx-youtube-client-version: 1.20200609.04.02\r\n", "", false);
						JsonReader Reader;
						JsonValue Root;
						if (!json.empty() && Reader.parse(json, Root) && Root.isObject())
						{
							JsonValue content_html = Root["content_html"];
							JsonValue load_more_widget_html = Root["load_more_widget_html"];

							if (content_html.isString() && load_more_widget_html.isString())
							{
								dataStr = content_html.asString();
								moreStr = load_more_widget_html.asString();
							}
						}
					}
				}
			}
		}

		if (ret.size() == 0) ret = PlayerYouTubePlaylistByAPI(path);
	}

	for (int i = ret.size() - 1; i > 0; i--)
	{
		if (string(ret[i]["url"]).isEmpty()) ret.removeAt(i);
	}

	if (ret.size() == 0)
	{
		dictionary item;
		item["url"] = path;
		ret.insertLast(item);
	}

	FixPlaylist(@ret);

	if (ret.size() > 0)
	{
		DebugPrint();
		DebugPrint("PlayList:");
		DebugPrint(@ret, "  ");
	}

	DebugPrint();
	DebugPrint("PlayListParse: " + formatInt(ret.size()));

	return ret;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void InitMod(const bool &in reload = false)
{
	if (reload)
	{
		if (config::hotConfig)
		{
			uint time = HostGetTickCount();
			
			if ((time - configTime) < 500)
			{
				DebugPrint();
				DebugPrint("Config skiped: " + formatFloat(double(time - configTime) / 1000, "", 0, 3).TrimRight("0.") + " < 0.500");
				
				return;
			}
		}
		else
		{
			return;
		}
	}


	dictionary config;

	PathType pathType = ptPlayer;

	string path, log;

	bool load = true;

	while (true)
	{
		path = GetConfigPath(pathType);
		
		log += "Load Config: \"" + path + "\"" + "\r\n";
		
		if (!ReadConfig(config, path))
		{
			load = false;

			log += "Config is not loaded: \"" + path + "\"" + "\r\n";
		}

		load = ReadBool(config,     config::showDebugLog,    "showDebugLog", true) && load;
		load = ReadBool(config,     config::useCurl,         "useCurl", true) && load;
		load = ReadBool(config,     config::useCookies,      "useCookies", true) && load;
		load = ReadBool(config,     config::useSponsorBlock, "useSponsorBlock", true) && load;
		load = ReadBool(config,     config::cacheMetaData,   "cacheMetaData", true) && load;
		load = ReadBool(config,     config::fixFormats,      "fixFormats", true) && load;
		load = ReadBool(config,     config::jpegThumbnails,  "jpegThumbnails", true) && load;
		load = ReadBool(config,     config::skipStartPos,    "skipStartPos", true) && load;
		load = ReadBool(config,     config::markWatched,     "markWatched", true) && load;
		load = ReadBool(config,     config::normalizeTitle,  "normalizeTitle", true) && load;
		load = ReadBool(config,     config::autoRedirect,    "autoRedirect", true) && load;
		load = ReadBool(config,     config::hotConfig,       "hotConfig", true) && load;
		load = ReadUInt(config,     config::showChannelName, "showChannelName", true) && load;
		load = ReadUInt(config,     config::typeChannelName, "typeChannelName", true) && load;
		load = ReadStr(config,      config::titleFormat,     "titleFormat", true) && load;
		//load = ReadStr(config,      config::userAgent,       "userAgent", true) && load;
		//load = ReadStr(config,      config::ytApiKey,        "ytApiKey", true) && load;

		if (!load)
		{
			log += "Save Config: \"" + path + "\"" + "\r\n";

			if (!WriteConfig(config, path))
			{
				log += "Config is not saved: \"" + path + "\"" + "\r\n";
			}
			else
			{
				break;
			}
		}
		else
		{
			break;
		}

		if (pathType == ptUser)
		{
			config::showDebugLog = true;

			break;
		}

		pathType = ptUser;
	}

	if (config::showDebugLog)
	{
		HostOpenConsole();

		if (!reload)
		{
			DebugPrint();
			DebugPrint(GetTitle());
			
			playerDir = "";
			extDir = "";
			userDir = "";
		}

		if (!log.isEmpty())
		{
			DebugPrint();
			DebugPrint(log);
		}

		DebugPrint();
		DebugPrint("Paths:");
		DebugPrint("playerDir:     \"" + GetPlayerDir() + "\"", "  ");
		DebugPrint("extDir:        \"" + GetExtDir() + "\"", "  ");
		DebugPrint("userDir:       \"" + GetUserDir() + "\"", "  ");
		DebugPrint("configPath:    \"" + path + "\"", "  ");
		DebugPrint("curlPath:      \"" + GetCurlPath() + "\"", "  ");
		DebugPrint("cookiesPath:   \"" + GetCookiesPath() + "\"", "  ");

		DebugPrint();
		DebugPrint("Config:");
		DebugPrint(config, "  ");
		
		if (!reload) DebugPrint();
	}

	configTime = HostGetTickCount();
}

bool WriteConfig(const dictionary &in config, const string &in path)
{
	if (path.isEmpty()) return false;


	string dir = path.substr(0, path.findLast("\\") + 1);

	HostExecuteProgram("cmd.exe", "/A /Q /C (MKDIR \"" + dir + "\")");

	HostExecuteProgram("cmd.exe", "/A /Q /C (COPY /Y /B NUL \"" + path + "\")");

	if (!FileExists(path)) return false;


	array<string> keys = config.getKeys();

	keys.sortAsc();

	for (uint i = 0; i < keys.size(); i++)
	{
		string name = keys[i];

		string strValue;

		if (config.get(name, strValue))
		{
			if (!IsLatinStr(strValue)) strValue = HostBase64Enc(strValue);

			int64 size = FileSize(path);

			HostExecuteProgram("cmd.exe", "/A /Q /C ((@ECHO.) && (@ECHO " + EscapeCommand(name + " = " + strValue) + "))>>\"" + path + "\"");

			if (size == FileSize(path)) return false;
		}
		else
		{
			double floatValue;

			if (config.get(name, floatValue))
			{
				int64 size = FileSize(path);

				string str = formatFloat(floatValue, "").TrimRight("0.");

				if (str.isEmpty()) str = "0";

				HostExecuteProgram("cmd.exe", "/A /Q /C ((@ECHO.) && (@ECHO " + EscapeCommand(name + " = " + str) + "))>>\"" + path + "\"");

				if (size == FileSize(path)) return false;
			}
			else
			{
				array<int64> arrayValue;

				if (config.get(name, arrayValue))
				{
					string str;

					for (uint i = 0; i < arrayValue.size(); i++)
					{
						str += formatInt(arrayValue[i]) + ", ";
					}

					int64 size = FileSize(path);

					HostExecuteProgram("cmd.exe", "/A /Q /C ((@ECHO.) && (@ECHO " + EscapeCommand(name + " = " + str.TrimRight(" ,")) + "))>>\"" + path + "\"");

					if (size == FileSize(path)) return false;
				}
				else
				{
					array<int> arrayValue;

					if (config.get(name, arrayValue))
					{
						string str;

						for (uint i = 0; i < arrayValue.size(); i++)
						{
							str += formatInt(arrayValue[i]) + ", ";
						}

						int64 size = FileSize(path);

						HostExecuteProgram("cmd.exe", "/A /Q /C ((@ECHO.) && (@ECHO " + EscapeCommand(name + " = " + str.TrimRight(" ,")) + "))>>\"" + path + "\"");

						if (size == FileSize(path)) return false;
					}
					else
					{
						array<uint64> arrayValue;

						if (config.get(name, arrayValue))
						{
							string str;

							for (uint i = 0; i < arrayValue.size(); i++)
							{
								str += formatUInt(arrayValue[i]) + ", ";
							}

							int64 size = FileSize(path);

							HostExecuteProgram("cmd.exe", "/A /Q /C ((@ECHO.) && (@ECHO " + EscapeCommand(name + " = " + str.TrimRight(" ,")) + "))>>\"" + path + "\"");

							if (size == FileSize(path)) return false;
						}
						else
						{
							array<uint> arrayValue;

							if (config.get(name, arrayValue))
							{
								string str;

								for (uint i = 0; i < arrayValue.size(); i++)
								{
									str += formatUInt(arrayValue[i]) + ", ";
								}

								int64 size = FileSize(path);

								HostExecuteProgram("cmd.exe", "/A /Q /C ((@ECHO.) && (@ECHO " + EscapeCommand(name + " = " + str.TrimRight(" ,")) + "))>>\"" + path + "\"");

								if (size == FileSize(path)) return false;
							}
						}
					}
				}
			}
		}
	}

	return true;
}

bool ReadConfig(dictionary &inout config, const string &in path)
{
	if (path.isEmpty()) return false;

	uintptr pFile = HostFileOpen(path);

	if (pFile == 0) return false;

	string data = TrimTotal(HostFileRead(pFile, HostFileLength(pFile)));

	HostFileClose(pFile);

	if (data.isEmpty()) return false;


	bool succ = false;

	array<string> lines = data.split("\n");

	for (uint i = 0; i < lines.size(); i++)
	{
		string line = TrimTotal(lines[i]);

		if (!line.isEmpty())
		{
			int p = line.find("=");

			if (p > -1)
			{
				string name = TrimTotal(line.substr(0, p));

				if (!name.isEmpty())
				{
					string value = TrimTotal(line.substr(p + 1));

					if (!value.isEmpty())
					{
						array<dictionary> matches;

						if (HostRegExpParse(value, "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$", matches))
						{
							string tmp = HostBase64Dec(value);

							if (!tmp.isEmpty()) value = tmp;
						}
						
						config[name] = value;

						succ = true;
					}
				}
			}
		}
	}

	return succ;
}

bool ReadBool(dictionary &inout config, bool &inout value, const string &in name, const bool &in write = false)
{
	string tmp;

	if (config.get(name, tmp))
	{
		tmp.Trim("\"");
		tmp.Trim("'");
		tmp = TrimTotal(tmp);

		tmp.MakeLower();

		if ((tmp == "1") || (tmp == "true") || (tmp == "yes") || (tmp == "ok"))
		{
			value = true;

			if (write) config[name] = 1;

			return true;
		}
		else if ((tmp == "0") || (tmp == "-1") || (tmp == "false") || (tmp == "no"))
		{
			value = false;

			if (write) config[name] = 0;

			return true;
		}
	}

	if (write)
	{
		if (value)
		{
			config[name] = 1;
		}
		else
		{
			config[name] = 0;
		}
	}

	return false;
}

bool ReadInt(dictionary &inout config, int &inout value, const string &in name, const bool &in write = false)
{
	int64 tmp = value;

	if (ReadInt(config, tmp, name, write))
	{
		value = tmp;

		return true;
	}

	return false;
}

bool ReadInt(dictionary &inout config, int64 &inout value, const string &in name, const bool &in write = false)
{
	string tmp;

	if (config.get(name, tmp))
	{
		tmp.Trim("\"");
		tmp.Trim("'");
		tmp = TrimTotal(tmp);

		array<dictionary> matches;

		if (HostRegExpParse(tmp, "^[+-]?[0-9]+([.,]0+)?$", matches))
		{
			value = parseInt(tmp);

			if (write) config[name] = value;

			return true;
		}
	}

	if (write) config[name] = value;

	return false;
}

bool ReadUInt(dictionary &inout config, uint &inout value, const string &in name, const bool &in write = false)
{
	uint64 tmp = value;

	if (ReadUInt(config, tmp, name, write))
	{
		value = tmp;

		return true;
	}

	return false;
}

bool ReadUInt(dictionary &inout config, uint64 &inout value, const string &in name, const bool &in write = false)
{
	string tmp;

	if (config.get(name, tmp))
	{
		tmp.Trim("\"");
		tmp.Trim("'");
		tmp = TrimTotal(tmp);

		array<dictionary> matches;

		if (HostRegExpParse(tmp, "^\\+?[0-9]+([.,]0+)?$", matches))
		{
			value = parseUInt(tmp);

			if (write) config[name] = value;

			return true;
		}
	}

	if (write) config[name] = value;

	return false;
}

bool ReadArrayInt(dictionary &inout config, array<int> &inout values, const string &in name, const bool &in write = false)
{
	array<int64> tmp;

	tmp.resize(values.size());

	for (uint i = 0; i < values.size(); i++)
	{
		tmp[i] = values[i];
	}

	if (ReadArrayInt(config, tmp, name, write))
	{
		values.resize(tmp.size());

		for (uint i = 0; i < tmp.size(); i++)
		{
			values[i] = tmp[i];
		}

		return true;
	}

	return false;
}

bool ReadArrayInt(dictionary &inout config, array<int64> &inout values, const string &in name, const bool &in write = false)
{
	string tmp;

	if (config.get(name, tmp))
	{
		tmp.Trim("\"");
		tmp.Trim("'");
		tmp = TrimTotal(tmp);

		bool f1 = (tmp.find(";") > -1);
		bool f2 = (tmp.find(",") > -1);

		tmp.replace("\t", " ");
		tmp.replace(", ", ";");
		tmp.replace(". ", ";");
		tmp.replace(" ", "");

		if (!f1)
		{
			if (!f2)
			{
				tmp.replace(".", ";");
			}
			else
			{
				tmp.replace(",", ";");
			}
		}

		bool succ = false;

		array<string> lines = tmp.split(";");

		for (uint i = 0; i < lines.size(); i++)
		{
			string line = TrimTotal(lines[i]);

			if (!line.isEmpty())
			{
				array<dictionary> matches;

				if (HostRegExpParse(line, "^[+-]?[0-9]+([.,]0+)?$", matches))
				{
					if (!succ) values.resize(0);

					values.insertLast(parseInt(line));

					succ = true;
				}
			}
		}

		if (succ)
		{
			if (write) config[name] = values;

			return true;
		}
	}

	if (write) config[name] = values;

	return false;
}

bool ReadArrayUInt(dictionary &inout config, array<uint> &inout values, const string &in name, const bool &in write = false)
{
	array<uint64> tmp;

	tmp.resize(values.size());

	for (uint i = 0; i < values.size(); i++)
	{
		tmp[i] = values[i];
	}

	if (ReadArrayUInt(config, tmp, name, write))
	{
		values.resize(tmp.size());

		for (uint i = 0; i < tmp.size(); i++)
		{
			values[i] = tmp[i];
		}

		return true;
	}

	return false;
}

bool ReadArrayUInt(dictionary &inout config, array<uint64> &inout values, const string &in name, const bool &in write = false)
{
	string tmp;

	if (config.get(name, tmp))
	{
		tmp.Trim("\"");
		tmp.Trim("'");
		tmp = TrimTotal(tmp);

		bool f1 = (tmp.find(";") > -1);
		bool f2 = (tmp.find(",") > -1);

		tmp.replace("\t", " ");
		tmp.replace(", ", ";");
		tmp.replace(". ", ";");
		tmp.replace(" ", "");

		if (!f1)
		{
			if (!f2)
			{
				tmp.replace(".", ";");
			}
			else
			{
				tmp.replace(",", ";");
			}
		}

		bool succ = false;

		array<string> lines = tmp.split(";");

		for (uint i = 0; i < lines.size(); i++)
		{
			string line = TrimTotal(lines[i]);

			if (!line.isEmpty())
			{
				array<dictionary> matches;

				if (HostRegExpParse(line, "^\\+?[0-9]+([.,]0+)?$", matches))
				{
					if (!succ) values.resize(0);

					values.insertLast(parseInt(line));

					succ = true;
				}
			}
		}

		if (succ)
		{
			if (write) config[name] = values;

			return true;
		}
	}

	if (write) config[name] = values;

	return false;
}

bool ReadStr(dictionary &inout config, string &inout value, const string &in name, const bool &in write = false)
{
	string tmp;

	if (config.get(name, tmp))
	{
		value = tmp;

		return true;
	}

	if (write) config[name] = value;

	return false;
}

string GetPlayerDir()
{
	if (!playerDir.isEmpty()) return playerDir;


	string dir = ".\\";

	if (!FileExists(dir + "PotPlayerMini.exe"))
	{
		if (!FileExists(dir + "PotPlayerMini64.exe"))
		{
			if (!FileExists(dir + "PotPlayerMiniXP.exe"))
			{
				if (!FileExists(dir + "PotPlayerMiniXP64.exe"))
				{
					if (!FileExists(dir + "PotPlayer.exe"))
					{
						if (!FileExists(dir + "PotPlayer64.exe"))
						{
							if (!FileExists(dir + "PotPlayerXP.exe"))
							{
								if (!FileExists(dir + "PotPlayerXP64.exe"))
								{
									dir = "";
								}
							}
						}
					}
				}
			}
		}
	}

	if (!dir.isEmpty())
	{
		playerDir = dir;

		return playerDir;
	}


	string path = "";

	string mark = HostHashMD5(formatInt(HostGetTickCount()));

	string xml  = HostExecuteProgram("cmd.exe", "/A /Q /C (@ECHO " + mark + ") && (WMIC.exe PROCESS GET CommandLine, ExecutablePath, ParentProcessId, ProcessId /FORMAT:RAWXML) && (DEL /Q TempWmicBatchFile.bat)");
	
	
	XMLDocument doc;

	if (doc.Parse(xml))
	{
		uint playerId = 0;

		array<uint> ids;

		array<string> paths;


		XMLElement root = doc.RootElement();

		if (root.isValid() && (root.Name() == "COMMAND"))
		{
			XMLElement results = root.FirstChildElement("RESULTS");

			while (results.isValid())
			{
				XMLElement cim = results.FirstChildElement("CIM");

				if (cim.isValid())
				{
					XMLElement instance = cim.FirstChildElement("INSTANCE");

					while (instance.isValid())
					{
						string commandLine = "";

						string executablePath = "";

						uint parentProcessId = 0;

						uint processId = 0;


						XMLElement value;

						XMLElement property = instance.FirstChildElement("PROPERTY");

						while (property.isValid())
						{
							XMLAttribute attr = property.FindAttribute("NAME");

							if (attr.isValid())
							{
								string attrName = attr.Value();


								if (attrName == "CommandLine")
								{
									value = property.FirstChildElement("VALUE");

									if (value.isValid()) commandLine = value.asString();
								}
								else if (attrName == "ExecutablePath")
								{
									value = property.FirstChildElement("VALUE");

									if (value.isValid()) executablePath = value.asString();
								}
								else if (attrName == "ParentProcessId")
								{
									value = property.FirstChildElement("VALUE");

									if (value.isValid()) parentProcessId = value.asUInt();
								}
								else if (attrName == "ProcessId")
								{
									value = property.FirstChildElement("VALUE");

									if (value.isValid()) processId = value.asUInt();
								}
							}

							property = property.NextSiblingElement();
						}


						if (!commandLine.isEmpty() && !executablePath.isEmpty() && (parentProcessId != 0) && (processId != 0))
						{
							if ((playerId == 0) && (commandLine.find(mark) > -1))
							{
								playerId = parentProcessId;
							}

							ids.insertLast(processId);

							paths.insertLast(executablePath);
						}

						instance = instance.NextSiblingElement();
					}
				}

				results = results.NextSiblingElement();
			}

			XMLElement element = doc.FirstChildElement("RESULTS");
		}


		if (playerId != 0)
		{
			int i = ids.find(playerId);

			if (i > -1) path = paths[i];
		}
	}


	if (FileExists(path))
	{
		playerDir = path.substr(0, path.findLast("\\") + 1); 
	}
	else
	{
		DebugPrint("PotPlayer not found: \"" + path + "\"");

		return "";
	}

	return playerDir;
}

string GetExtDir()
{
	if (!extDir.isEmpty()) return extDir;


	string dir = GetPlayerDir();

	if (dir.isEmpty()) return "";


	extDir = dir + "Extension\\";

	if (!DirExists(extDir))
	{
		extDir = dir + "Extention\\";

		if (!DirExists(extDir))
		{
			extDir = "";
		}
	}

	if (extDir.isEmpty())
	{
		DebugPrint("Extension not found: \"" + dir + "\"");
	}

	return extDir;
}

string GetUserDir()
{
	if (!userDir.isEmpty()) return userDir;


	string dir = TrimTotal(HostExecuteProgram("cmd.exe", "/A /Q /C (@ECHO %APPDATA%)"));

	if (dir.isEmpty())
	{
		DebugPrint("Application Data not found");
	}
	else
	{
		userDir = dir + "\\Daum\\PotPlayer\\Extension\\";
	}

	return userDir;
}

string GetConfigPath(const PathType &in pathType = ptAuto)
{
	string path;

	if (pathType != ptUser)
	{
		path = GetExtDir() + configPath;

		if ((pathType != ptAuto) || FileExists(path))
		{
			return path;
		}
	}

	if (pathType != ptPlayer)
	{
		path = GetUserDir() + configPath;

		if ((pathType != ptAuto) || FileExists(path))
		{
			return path;
		}
	}

	return "";
}

string GetCurlPath(const PathType &in pathType = ptAuto)
{
	string path;

	if (pathType != ptUser)
	{
		path = GetExtDir() + curlPath;

		if ((pathType != ptAuto) || FileExists(path))
		{
			return path;
		}
	}

	if (pathType != ptPlayer)
	{
		path = GetUserDir() + curlPath;

		if ((pathType != ptAuto) || FileExists(path))
		{
			return path;
		}
	}

	return "";
}

string GetCookiesPath(const PathType &in pathType = ptAuto)
{
	string path;

	if (pathType != ptUser)
	{
		path = GetExtDir() + cookiesPath;

		if ((pathType != ptAuto) || FileExists(path))
		{
			return path;
		}
	}

	if (pathType != ptPlayer)
	{
		path = GetUserDir() + cookiesPath;

		if ((pathType != ptAuto) || FileExists(path))
		{
			return path;
		}
	}

	return "";
}

void DebugPrint()
{
	if (config::showDebugLog) HostPrintUTF8("");
}

void DebugPrint(const string &in value, const string &in offset = "", const bool &in raw = false)
{
	if (!config::showDebugLog) return;

	if (value.isEmpty()) return;

	if (!raw)
	{
		array<string> lines = value.split("\n");

		for (uint i = 0; i < lines.size(); i++)
		{
			string line = TrimTotal(lines[i]);

			if (!line.isEmpty()) HostPrintUTF8("[YouTubeMod] " + offset + line);
		}
	}
	else
	{
		HostPrintUTF8(value);
	}
}

void DebugPrint(const bool &in value, const string &in offset = "")
{
	if (config::showDebugLog) HostPrintUTF8("[YouTubeMod] " + offset + (value ? "true" : "false"));
}

void DebugPrint(const int64 &in value, const string &in offset = "")
{
	if (config::showDebugLog) HostPrintUTF8("[YouTubeMod] " + offset + formatInt(value));
}

void DebugPrint(const uint64 &in value, const string &in offset = "")
{
	if (config::showDebugLog) HostPrintUTF8("[YouTubeMod] " + offset + formatInt(value));
}

void DebugPrint(const double &in value, const string &in offset = "")
{
	string str = formatFloat(value, "", 0, 3).TrimRight("0.");

	if (str.isEmpty()) str = "0";

	if (config::showDebugLog) HostPrintUTF8("[YouTubeMod] " + offset + str);
}

void DebugPrint(const dictionary@ &in dict, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (dict is null) return;

	array<string> keys = dict.getKeys();

	keys.sortAsc();

	for (uint i = 0; i < keys.size(); i++)
	{
		string name = keys[i];

		string strValue;

		if (dict.get(name, strValue))
		{
			array<string> lines = strValue.split("\n");

			if (lines.size() > 1)
			{
				HostPrintUTF8("[YouTubeMod] " + offset + name + ":");

				for (uint j = 0; j < lines.size(); j++)
				{
					string line = TrimTotal(lines[j]);

					if (!line.isEmpty()) HostPrintUTF8("[YouTubeMod] " + offset + "  \"" + line + "\"");
				}
			}
			else
			{
				HostPrintUTF8("[YouTubeMod] " + offset + name + ": \"" + TrimTotal(strValue) + "\"");
			}
		}
		else
		{
			double floatValue;

			if (dict.get(name, floatValue))
			{
				string str = formatFloat(floatValue, "", 0, 3).TrimRight("0.");

				if (str.isEmpty()) str = "0";

				HostPrintUTF8("[YouTubeMod] " + offset + name + ": \"" + str + "\"");
			}
			else
			{
				array<dictionary> arrayDict;

				if (dict.get(name, arrayDict))
				{
					HostPrintUTF8("[YouTubeMod] " + offset + name + ":");

					for (uint j = 0; j < arrayDict.size(); j++)
					{
						DebugPrint(arrayDict[j], offset + "  ");

						if (j < arrayDict.size() - 1) HostPrintUTF8("");
					}
				}
				else
				{
					array<string> arrayValue;

					if (dict.get(name, arrayValue))
					{
						HostPrintUTF8("[YouTubeMod] " + offset + name + ":");

						for (uint j = 0; j < arrayValue.size(); j++)
						{
							array<string> lines = arrayValue[j].split("\n");

							for (uint l = 0; l < lines.size(); l++)
							{
								string line = TrimTotal(lines[l]);

								if (!line.isEmpty()) HostPrintUTF8("[YouTubeMod] " + offset + "  \"" + line + "\"");
							}
						}
					}
					else
					{
						array<int64> arrayValue;

						if (dict.get(name, arrayValue))
						{
							string str;

							for (uint i = 0; i < arrayValue.size(); i++)
							{
								str += formatInt(arrayValue[i]) + ", ";
							}

							if (!str.isEmpty())
							{
								HostPrintUTF8("[YouTubeMod] " + offset + name + ": \"" + str.TrimRight(" ,") + "\"");
							}
						}
						else
						{
							array<int> arrayValue;

							if (dict.get(name, arrayValue))
							{
								string str;

								for (uint i = 0; i < arrayValue.size(); i++)
								{
									str += formatInt(arrayValue[i]) + ", ";
								}

								if (!str.isEmpty())
								{
									HostPrintUTF8("[YouTubeMod] " + offset + name + ": \"" + str.TrimRight(" ,") + "\"");
								}
							}
							else
							{
								array<uint64> arrayValue;

								if (dict.get(name, arrayValue))
								{
									string str;

									for (uint i = 0; i < arrayValue.size(); i++)
									{
										str += formatUInt(arrayValue[i]) + ", ";
									}

									if (!str.isEmpty())
									{
										HostPrintUTF8("[YouTubeMod] " + offset + name + ": \"" + str.TrimRight(" ,") + "\"");
									}
								}
								else
								{
									array<uint> arrayValue;

									if (dict.get(name, arrayValue))
									{
										string str;

										for (uint i = 0; i < arrayValue.size(); i++)
										{
											str += formatUInt(arrayValue[i]) + ", ";
										}

										if (!str.isEmpty())
										{
											HostPrintUTF8("[YouTubeMod] " + offset + name + ": \"" + str.TrimRight(" ,") + "\"");
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

void DebugPrint(const array<string>@ &in values, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (values is null) return;

	for (uint i = 0; i < values.size(); i++)
	{
		HostPrintUTF8("[YouTubeMod] " + offset + values[i]);
	}
}

void DebugPrint(const array<int>@ &in values, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (values is null) return;

	string str;

	for (uint i = 0; i < values.size(); i++)
	{
		str += formatInt(values[i]) + ", ";
	}

	if (!str.isEmpty())
	{
		HostPrintUTF8("[YouTubeMod] " + offset + str.TrimRight(" ,"));
	}
}

void DebugPrint(const array<int64>@ &in values, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (values is null) return;

	string str;

	for (uint i = 0; i < values.size(); i++)
	{
		str += formatInt(values[i]) + ", ";
	}

	if (!str.isEmpty())
	{
		HostPrintUTF8("[YouTubeMod] " + offset + str.TrimRight(" ,"));
	}
}

void DebugPrint(const array<uint>@ &in values, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (values is null) return;

	string str;

	for (uint i = 0; i < values.size(); i++)
	{
		str += formatInt(values[i]) + ", ";
	}

	if (!str.isEmpty())
	{
		HostPrintUTF8("[YouTubeMod] " + offset + str.TrimRight(" ,"));
	}
}

void DebugPrint(const array<uint64>@ &in values, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (values is null) return;

	string str;

	for (uint i = 0; i < values.size(); i++)
	{
		str += formatInt(values[i]) + ", ";
	}

	if (!str.isEmpty())
	{
		HostPrintUTF8("[YouTubeMod] " + offset + str.TrimRight(" ,"));
	}
}

void DebugPrint(const array<dictionary>@ &in values, const string &in offset = "")
{
	if (!config::showDebugLog) return;

	if (values is null) return;

	for (uint i = 0; i < values.size(); i++)
	{
		DebugPrint(values[i], offset);

		if (i < values.size() - 1) HostPrintUTF8("");
	}
}

int64 FileSize(const string &in path)
{
	int64 size = 0;

	if (!path.isEmpty())
	{
		uintptr file = HostFileOpen(path);

		if (file != 0)
		{
			size = HostFileLength(file);

			HostFileClose(file);
		}
	}

	return size;
}

bool FileExists(const string &in path)
{
	if (!path.isEmpty())
	{
		uintptr file = HostFileOpen(path);

		if (file != 0)
		{
			HostFileClose(file);

			return true;
		}
	}

	return false;
}

bool DirExists(const string &in dir)
{
	if (dir.isEmpty()) return false;

	if (FileExists(dir)) return false;

	return (TrimTotal(HostExecuteProgram("cmd.exe", "/A /Q /C (IF EXIST \"" + dir + "\" @ECHO 1)")) == "1");
}

string EscapeJson(const string &in str)
{
	string result = str;

	if (!result.isEmpty())
	{
		result.replace("\\\"", "\\\\\"");
		result.replace("\"", "\\\"");
	}

	return result;
}

string EscapeCommand(const string &in str)
{
	string result = str;

	if (!result.isEmpty())
	{
		result.replace("^", "^^");
		result.replace("&", "^&");
		result.replace("<", "^<");
		result.replace(">", "^>");
		result.replace("|", "^|");
		result.replace("'", "^'");
		result.replace("`", "^`");
		result.replace(",", "^,");
		result.replace(";", "^;");
		result.replace("=", "^=");
		result.replace("(", "^(");
		result.replace(")", "^)");
		result.replace("!", "^!");
		result.replace("\"", "^\"");
		result.replace("%", "^%");
	}

	return result;
}

string TrimTotal(string str)
{
	int len = str.length();

	if (len == 0) return "";

	while (true)
	{
		str.Trim("\r");
		str.Trim("\n");
		str.Trim("\t");
		str.Trim();

		int newLen = str.length();

		if (newLen == len) break;

		len = newLen;
	}

	return str;
}

string GetBytes(const string &in chars)
{
	if (chars.isEmpty()) return "";

	array<string> arrayBytes(chars.length());

	for (uint i = 0; i < chars.length(); i++)
	{
		arrayBytes[i] = formatInt(chars[i], "0", 3);
	}

	return join(arrayBytes, ", ");
}

string ByteToStr(const uint8 &in byte)
{
	string tmp = " ";
	
	tmp[0] = byte;
	
	return tmp;
}

string SizeToStr(int64 size)
{
	if (size == 0) return "0 b";

	string ret;
	
	bool neg = false;
	
	if (size < 0)
	{
		size = size * (-1);
		neg = true;
	}

	if (size >= 1000000000)
	{
		size = size / 1000000;
		ret = formatFloat(double(size) / 1000, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += " Gb";
	}
	else if (size >= 1000000)
	{
		size = size / 1000;
		ret = formatFloat(double(size) / 1000, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += " Mb";
	}
	else if (size >= 1000)
	{
		ret = formatFloat(double(size) / 1000, "", 0, 1);
		ret = TrimFloatString(ret);
		ret += " Kb";
	}
	else
	{
		ret = formatInt(size);
		ret += " b";
	}
	
	if (neg) ret = "-" + ret;
	
	return ret;
}

int64 CalcSize(int bitrate, int sec)
{
	return int64(double(bitrate / 8) * sec);
}

int64 UnixTime()
{
	datetime dateTime = datetime();

	return UnixTime(dateTime.get_year(), dateTime.get_month(), dateTime.get_day(), dateTime.get_hour(), dateTime.get_minute(), dateTime.get_second());
}

int64 UnixTime(int year, int month, int day, int hour, int min, int sec)
{
	array<int> days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

	if ((year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))) days[1] = 29;

	if ((year >= 1) && (year <= 9999) && (month >= 1) && (month <= 12) && (day >= 1) && (day <= days[month - 1]) && (hour < 24) && (min < 60) && (sec < 60))
	{
		for (int i = 0; i < month - 1; i++) day += days[i];

		year--;

		return (((year * 365) + int(year / 4) - int(year / 100) + int(year / 400) + day - 719163) * 86400) + (hour * 3600) + (min * 60) + sec;
	}

	return 0;
}

bool IsRusLang(string lang = "")
{
	if (lang.isEmpty())
	{
		lang = HostIso639LangName();
	}

	lang.MakeLower();

	if (lang == "ru")
	{
		return true;
	}

	if (lang == "en")
	{
		return true;
	}

	const array<string> langs = {"ab", "av", "az", "ba", "be", "ce", "cv", "hy", "ka", "kk", "kv", "ky", "os", "tg", "tk", "tt", "uk", "uz"};

	return (langs.find(lang) > -1);
}

bool IsLatinStr(const string &in str)
{
	for (uint i = 0; i < str.length(); i++)
	{
		if (str[i] > 127) return false;
	}

	return true;
}

uint UnicodeCount(const string &in str)
{
	uint8 char;

	uint size;

	uint i = 0;

	uint len = str.length();

	uint count = 0;

	while (i < len)
	{
		char = str[i];

		size = 0;

		if ((char >= 0) && (char <= 127))
		{
			size = 1;
		}
		else if ((char <= 223) && (char >= 194))
		{
			size = 2;
		}
		else if ((char == 224) ||
				 (char == 237) ||
			    ((char <= 236) && (char >= 225)) ||
			    ((char <= 239) && (char >= 238)))
		{
			size = 3;
		}
		else if ((char == 240) ||
			 	 (char == 244) ||
			    ((char <= 243) && (char >= 241)))
		{
			size = 4;
		}
		else
		{
			break;
		}

		count++;

		i += size;
	}

	return count;
}

bool ExtractJsonValue(const string &in data, string name, string &out value)
{
	value = "";

	if (!data.isEmpty())
	{
		name = "\"" + name + "\":\"";

		int p1 = data.find(name);

		if (p1 > -1)
		{
			p1 += name.length();

			int p2 = data.find("\"", p1);

			if (p2 > 0)
			{
				value = TrimTotal(data.substr(p1, p2 - p1));

				return !value.isEmpty();
			}
		}
	}

	return false;
}

string ExtractRedirect(string url)
{
	string params = url.substr(url.find("?") + 1);

	array<string> lines = params.split("&");

	for (uint i = 0; i < lines.size(); i++)
	{
		string line = TrimTotal(lines[i]);

		if (!line.isEmpty())
		{
			int p = line.find("=");

			if (p > -1)
			{
				string name = TrimTotal(line.substr(0, p));

				string value = HostUrlDecode(TrimTotal(line.substr(p + 1)));

				if (!name.isEmpty() && !value.isEmpty())
				{
					string tmp = value;

					tmp.MakeLower();

					if ((tmp.find("https://") == 0) || (tmp.find("http://") == 0))
					{
						return value;
					}
				}
			}
		}
	}

	url = HostUrlDecode(url);

	string tmp = url;

	tmp.MakeLower();

	int p = tmp.find("https://", 1);

	if (p < 1) p = tmp.find("http://", 1);

	if (p > 0) return url.substr(p);

	return url;
}

bool ContainStartAt(string url)
{
	int p = url.find("?t=");

	if (p < 0) p = url.find("&t=");

	return (p > -1);
}

string RemoveStartAt(string url)
{
	int p = url.find("?t=");

	int r = 0;

	if (p > 0) r = p;

	if (p < 0) p = url.find("&t=");

	if (p > 0)
	{
		string newUrl = url.substr(0, p);

		p = url.find("&", p + 3);

		if (p > 0)
		{
			newUrl = newUrl + url.substr(p);

			if (r > 0) newUrl[r] = "?"[0];
		}

		return newUrl;
	}

	return url;
}

string ReplaceWebp(string url)
{
	url.replace("vi_webp/", "vi/");
	url.replace(".webp", ".jpg");

	return url;
}

class Cookie {
	string domain;
	bool   subdomains = false;
	string path;
	bool   https = false;
	int64  expires = 0;
	string name;
	string value;

	void clear()
	{
		domain     = "";
		subdomains = false;
		path       = "";
		https      = false;
		expires    = 0;
		name       = "";
		value      = "";
	}

	string toString()
	{
		return domain + "\t" + (subdomains ? "TRUE" : "FALSE") + "\t" + path + "\t" + (https ? "TRUE" : "FALSE") + "\t" + formatInt(expires) + "\t" + name + "\t" + value;
	}
};

bool ParseCookies(const string &in path, const string &in domain, const string &in name, Cookie &out cookie)
{
	string cache;

	return ParseCookies(path, domain, name, cookie, cache);
}

bool ParseCookies(const string &in path, string domain, string name, Cookie &out cookie, string &inout cache)
{
	cookie.clear();

	if ((path.isEmpty() && cache.isEmpty()) || domain.isEmpty() || name.isEmpty()) return false;


	if (cache.isEmpty())
	{
		uintptr pFile = HostFileOpen(path);

		if (pFile == 0) return false;

		cache = HostFileRead(pFile, HostFileLength(pFile));

		HostFileClose(pFile);

		if (cache.isEmpty()) return false;
	}


	domain = "\n" + domain.MakeLower() + "\t";

	name.MakeLower();

	int p1;

	int p2 = 0;

	while (true)
	{
		p1 = cache.find(domain, p2);

		if (p1 > -1)
		{
			p2 = cache.find("\n", p1 + domain.length());

			if (p2 < 0) p2 = cache.length();


			uint n = 0;

			array<string> values(7);

			values[n++] = TrimTotal(cache.substr(p1 + 1, domain.length() - 2));


			int i1 = p1 + domain.length();

			int i2;

			while (true)
			{
				if (n >= values.size()) break;

				i2 = cache.find("\t", i1);

				if ((i2 < 0) || (i2 > p2))
				{
					values[n++] = TrimTotal(cache.substr(i1, p2 - i1 - 1));

					break;
				}

				values[n++] = TrimTotal(cache.substr(i1, i2 - i1));

				i1 = i2 + 1;
			}

			--p2;


			if (n == values.size())
			{
				string tmp = values[5];
				tmp.MakeLower();

				if (name != tmp) continue;

				n = 0;

				cookie.domain     = values[n++];
				cookie.subdomains = values[n++].MakeLower() == "true";
				cookie.path       = values[n++];
				cookie.https      = values[n++].MakeLower() == "true";
				cookie.expires    = parseInt(values[n++]);
				cookie.name       = values[n++];
				cookie.value      = values[n++];

				return !cookie.value.isEmpty();
			}
		}
		else
		{
			break;
		}
	}

	return false;
}

string SAPISIDHash(const string &in cookiesPath, const string &in origin = "https://www.youtube.com")
{
	Cookie cookie;

	string cache;

	string SAPISID;

	if (ParseCookies(cookiesPath, ".youtube.com", "SAPISID", cookie, cache))
	{
		SAPISID = cookie.value;
	}
	else if (ParseCookies("", ".youtube.com", "__Secure-1PAPISID", cookie, cache) || (ParseCookies("", ".youtube.com", "__Secure-3PAPISID", cookie, cache)))
	{
		SAPISID = cookie.value;

		cookie.name = "SAPISID";

		HostExecuteProgram("cmd.exe", "/A /Q /C (@ECHO " + EscapeCommand(cookie.toString()) + ")>>\"" + cookiesPath + "\"");
	}

	if (SAPISID.isEmpty()) return "";

	int64 time = UnixTime();

	if (time == 0) return "";

	string hash = HostHashSHA1(formatInt(time) + " " + SAPISID + " " + origin);

	return "SAPISIDHASH " + formatInt(time) + "_" + hash;
}

void FixYouTubeLang(const string &in cookiesPath, string lang = "")
{
	if (lang.isEmpty()) lang = HostIso639LangName();

	if (lang == "en") return;

	Cookie cookie;

	if (ParseCookies(cookiesPath, ".youtube.com", "PREF", cookie))
	{
		if (cookie.value.find("hl=en") > -1)
		{
			cookie.value.replace("hl=en", "hl=" + lang);

			HostExecuteProgram("cmd.exe", "/A /Q /C (@ECHO " + EscapeCommand(cookie.toString()) + ")>>\"" + cookiesPath + "\"");
		}
	}
}

string UrlGetString(string url, string userAgent = "", string headers = "", string postData = "", bool noCookie = false)
{
	if (url.isEmpty()) return "";
	
	const int retryCount = 2;

	DebugPrint();
	DebugPrint("URL:");
	DebugPrint(url);

	if (userAgent.isEmpty())
	{
		userAgent = config::userAgent;
	}

	string tmp_headers = headers;
	tmp_headers.MakeLower();

	string ctry, lang;

	if (tmp_headers.find("accept-language:") == -1)
	{
		ctry = HostIso3166CtryName().MakeLower();
		lang = HostIso639LangName();

		if ((lang == "en") && (ctry == "us"))
		{
			headers += "Accept-Language: en-US,en;q=0.5\r\n";
		}
		else
		{
			headers += "Accept-Language: " + lang + "-" + ctry.MakeUpper() + "," + lang + ";q=0.9,en-US;q=0.8,en;q=0.7\r\n";
		}
	}

	DebugPrint();
	DebugPrint("UserAgent:");
	DebugPrint(userAgent);

	if (!headers.isEmpty())
	{
		DebugPrint();
		DebugPrint("Headers:");
		DebugPrint(headers);
	}

	if (!postData.isEmpty())
	{
		DebugPrint();
		DebugPrint("PostData:");
		DebugPrint(postData);
	}


	if (!config::useCurl || !FileExists(GetCurlPath()))
	{
		string response;

		if (config::showDebugLog)
		{
			int code = 0;
		
			int count = 0;
			
			int redirectCount = 0;
			
			while (true)
			{
				count++;
				
				bool redirect = false;
				
				uintptr pHttp = HostOpenHTTP(url, userAgent, headers, postData, noCookie);

				code = HostGetStatusHTTP(pHttp);

				headers  = HostGetHeaderHTTP(pHttp);
				
				if ((code >= 300) && (code < 400))
				{
					array<string> lines = headers.split("\n");

					for (uint i = 0; i < lines.size(); i++)
					{
						string line = TrimTotal(lines[i]);

						if (!line.isEmpty())
						{
							int p = line.find(":");

							if (p > -1)
							{
								string name = TrimTotal(line.substr(0, p));
								
								name.MakeLower();

								if (name == "location")
								{
									string value = TrimTotal(line.substr(p + 1));

									if (!value.isEmpty())
									{
										url = value;
										
										redirect = true;
									}
								}
							}
						}
					}
				}
				
				if (redirect && redirectCount < 30)
				{
					HostCloseHTTP(pHttp);
					
					count--;
					
					redirectCount++;
					
					continue;
				}

				response = TrimTotal(HostGetContentHTTP(pHttp));

				HostCloseHTTP(pHttp);
				
				if (!response.isEmpty()) break;
				
				if (count >= retryCount) break;
				
				DebugPrint();
				DebugPrint("RETRY: " + url);
				
				HostSleep(1000);
			}

			DebugPrint();
			DebugPrint("Status: " + formatInt(code));
			if (!headers.isEmpty()) DebugPrint(headers);

			if (!response.isEmpty())
			{
				DebugPrint();
				DebugPrint("Response:");
				//DebugPrint(response, "", true);
				DebugPrint(TrimTotal(response.substr(0, 1024)), "", true);
				if (response.length() > 1024) DebugPrint("...", "", true);
			}
		}
		else
		{
			int count = 0;
			
			while (true)
			{
				count++;
				
				response = TrimTotal(HostUrlGetString(url, userAgent, headers, postData, noCookie));
				
				if (!response.isEmpty()) break;
				
				if (count >= retryCount) break;
				
				HostSleep(1000);
			}
		}

		return response;
	}


	string args = "-s -S -k -L -A \"" + userAgent + "\"";

	if (!noCookie && config::useCookies && FileExists(GetCookiesPath()))
	{
		args += " -b \"" + GetCookiesPath() + "\"";
		//args += " -c \"" + GetCookiesPath() + "\"";

		if ((url.find("youtube.com/") > -1) || (url.find("youtu.be/") > -1))
		{
			FixYouTubeLang(GetCookiesPath(), lang);
		}
	}

	if (!headers.isEmpty())
	{
		array<string> lines = headers.split("\n");

		for (uint i = 0; i < lines.size(); i++)
		{
			string line = TrimTotal(lines[i]);

			if (!line.isEmpty())
			{
				args += " -H \"" + line + "\"";
			}
		}
	}

	if (!postData.isEmpty())
	{
		if (tmp_headers.find("application/json") > -1)
		{
			postData = EscapeJson(postData);
		}

		args += " -d \"" + postData + "\" -X POST";
	}
	else
	{
		args += " -X GET";
	}

	if (config::showDebugLog)
	{
		args += " -i";
	}

	args += " \"" + url + "\" --compressed";

	DebugPrint();
	DebugPrint("curl.exe " + args, "", true);
	
	
	string response;
	
	int count = 0;
	
	while (true)
	{
		count++;
		
		response = TrimTotal(HostExecuteProgram(GetCurlPath(), args));
		
		if (!response.isEmpty()) break;
		
		if (count >= retryCount) break;
		
		DebugPrint();
		DebugPrint("RETRY: " + url);
		
		HostSleep(1000);
	}

	
	if (config::showDebugLog)
	{
		int p1 = 0;
		
		while (true)
		{
			if (response.substr(p1, 5) == "HTTP/")
			{
				int p2 = response.find("\r\n\r\n", p1 + 1);
				
				if (p2 == -1) break;

				headers = TrimTotal(response.substr(p1, p2 - p1));
				
				if (!headers.isEmpty())
				{
					DebugPrint();
					DebugPrint("Status: " + headers);
				}
				
				p1 = p2 + 4;
			}
			else
			{
				break;
			}
		}

		response = TrimTotal(response.substr(p1));

		if (!response.isEmpty())
		{
			DebugPrint();
			DebugPrint("Response:");
			//DebugPrint(response, "", true);
			DebugPrint(TrimTotal(response.substr(0, 1024)), "", true);
			if (response.length() > 1024) DebugPrint("...", "", true);
		}
	}

	return response;
}

void SaveCache(const string &in url, const dictionary@ &in MetaData, const array<dictionary>@ &in QualityList, const string &in finalUrl)
{
	if (!config::cacheMetaData) return;

	if (url.empty()) return;

	if (cacheUrl == url) return;

	if (QualityList is null) return;

	cacheUrl = url;


	cacheQualityList.resize(0);

	for (uint i = 0; i < QualityList.size(); i++)
	{
		cacheQualityList.insertLast(QualityList[i]);
	}

	if (MetaData !is null)
	{
		cacheMetaData.deleteAll();

		array<string> keys = MetaData.getKeys();

		for (uint i = 0; i < keys.size(); i++)
		{
			string name = keys[i];

			cacheMetaData[name] = MetaData[name];
		}
	}

	cacheFinalUrl = finalUrl;

	cacheTime = HostGetTickCount();
}

string LoadCache(const string &in url, dictionary@ const &in MetaData, array<dictionary>@ const &in QualityList)
{
	if (!config::cacheMetaData) return "";

	if (url.empty()) return "";

	if (cacheUrl != url) return "";

	if (QualityList is null) return "";

	if ((HostGetTickCount() - cacheTime) > 3600000) return "";


	QualityList.resize(0);

	for (uint i = 0; i < cacheQualityList.size(); i++)
	{
		QualityList.insertLast(cacheQualityList[i]);
	}

	if (MetaData !is null)
	{
		MetaData.deleteAll();

		array<string> keys = cacheMetaData.getKeys();

		for (uint i = 0; i < keys.size(); i++)
		{
			string name = keys[i];

			MetaData[name] = cacheMetaData[name];
		}
	}

	return cacheFinalUrl;
}

void FixMetaData(dictionary@ const &in MetaData, const bool &in playing = false)
{
	if (MetaData is null) return;


	string title = string(MetaData["title"]);
	string channel = string(MetaData["author"]);

	if (title.isEmpty()) title = string(MetaData["vid"]);


	if (config::normalizeTitle)
	{
		string content = string(MetaData["content"]);
		
		NormalizeString(title);
		NormalizeString(channel);
		NormalizeString(content);
		
		MetaData["author"] = channel;
		MetaData["content"] = content;
	}


	if (config::showChannelName > 0)
	{
		string channelShort = string(MetaData["authorShort"]);

		if (config::normalizeTitle)
		{
			NormalizeString(channelShort);
		}

		string tmp0 = title;
		string tmp1 = channel;
		string tmp2 = channelShort;
				
		if (!config::normalizeTitle)
		{
			NormalizeString(tmp0);
			NormalizeString(tmp1);
			NormalizeString(tmp2);
		}

		tmp0.MakeLower();
		tmp1.MakeLower();
		tmp2.MakeLower();
		
		
		string tmp3 = tmp0;
		
		tmp3.Trim("|");
		
		int p = tmp3.findLast("|");
		
		if (p >= 0)
		{
			tmp3 = tmp3.substr(p + 1);
			tmp3.Trim();
		}
		else
		{
			tmp3.Trim("/");
			
			int p = tmp3.findLast("/");
			
			if (p >= 0)
			{
				tmp3 = tmp3.substr(p + 1);
				tmp3.Trim();
			}
			else
			{
				tmp3.Trim("\\");
				
				int p = tmp3.findLast("\\");
				
				if (p >= 0)
				{
					tmp3 = tmp3.substr(p + 1);
					tmp3.Trim();
				}
				else
				{
					tmp3.Trim("-");
					
					int p = tmp3.findLast("-");
					
					if (p >= 0)
					{
						tmp3 = tmp3.substr(p + 1);
						tmp3.Trim();
					}
					else
					{
						tmp3.Trim("(");
						
						int p = tmp3.findLast("(");
						
						if (p >= 0)
						{
							tmp3 = tmp3.substr(p + 1);
							tmp3.Trim();
						}
						else
						{
							tmp3.Trim("[");
							
							int p = tmp3.findLast("[");
							
							if (p >= 0)
							{
								tmp3 = tmp3.substr(p + 1);
								tmp3.Trim();
							}
							else
							{
								tmp3.Trim("<");
								
								int p = tmp3.findLast("<");
								
								if (p >= 0)
								{
									tmp3 = tmp3.substr(p + 1);
									tmp3.Trim();
								}
								else
								{
									tmp3 = "";
								}
							}
						}
					}
				}
			}
		}
		
		
		string tmp4 = tmp0;
		
		tmp4.Trim("-");
		
		p = tmp4.find("-");
		
		if (p >= 0)
		{
			tmp4 = tmp4.substr(0, p - 1);
			tmp4.Trim();
		}
		else
		{
			tmp4.Trim(")");
			
			int p = tmp4.find(")");
			
			if (p >= 0)
			{
				tmp4 = tmp4.substr(0, p - 1);
				tmp4.Trim();
			}
			else
			{
				tmp4.Trim("]");
				
				int p = tmp4.find("]");
				
				if (p >= 0)
				{
					tmp4 = tmp4.substr(0, p - 1);
					tmp4.Trim();
				}
				else
				{
					tmp4.Trim(">");
					
					int p = tmp4.find(">");
					
					if (p >= 0)
					{
						tmp4 = tmp4.substr(0, p - 1);
						tmp4.Trim();
					}
					else
					{
						tmp4.Trim("|");
						
						int p = tmp4.find("|");
						
						if (p >= 0)
						{
							tmp4 = tmp4.substr(0, p - 1);
							tmp4.Trim();
						}
						else
						{
							tmp4.Trim("/");
							
							int p = tmp4.find("/");
							
							if (p >= 0)
							{
								tmp4 = tmp4.substr(0, p - 1);
								tmp4.Trim();
							}
							else
							{
								tmp4.Trim("\\");
								
								int p = tmp4.find("\\");
								
								if (p >= 0)
								{
									tmp4 = tmp4.substr(0, p - 1);
									tmp4.Trim();
								}
								else
								{
									tmp4 = "";
								}
							}
						}
					}
				}
			}
		}
		
		if (tmp4 == tmp3) tmp4 = "";
		
		
		const array<string> chars = {" ", "•", "!", "'", "\"", "*", "+", ",", "-", ".", ";", "=", "?", "_", "{", "|", "}", "[", "\\", "/", "]", "^", "~", "(", ")", "#", "$", "%", "&", ":", "<", ">"};

		for (uint i = 0; i < chars.size(); i++)
		{
			tmp0.replace(chars[i], "");
			tmp1.replace(chars[i], "");
			tmp2.replace(chars[i], "");
			tmp3.replace(chars[i], "");
			tmp4.replace(chars[i], "");
		}
		
		if ((config::showChannelName == 1) || ((config::showChannelName == 2) && (tmp1.isEmpty() || ((tmp0.find(tmp1) == -1) && (tmp3.isEmpty() || ((tmp1.find(tmp3) == -1) && (tmp3.find(tmp1) == -1))) && (tmp4.isEmpty() || ((tmp1.find(tmp4) == -1) && (tmp4.find(tmp1) == -1))))) && (tmp2.isEmpty() || ((tmp0.find(tmp2) == -1)  && (tmp3.isEmpty() || ((tmp2.find(tmp3) == -1) && (tmp3.find(tmp2) == -1))) && (tmp4.isEmpty() || ((tmp2.find(tmp4) == -1) && (tmp4.find(tmp2) == -1)))))))
		{
			if (config::typeChannelName == 1)
			{
				if (channel.isEmpty()) channel = channelShort;
			}
			else if (config::typeChannelName == 2)
			{
				if (!channelShort.isEmpty()) channel = channelShort;
			}
			else if (config::typeChannelName == 3)
			{
				if (channel.isEmpty() || (!channelShort.isEmpty() && (UnicodeCount(tmp1) > (UnicodeCount(tmp2) + 3))))
				{
					channel = channelShort;
				}
			}
			
			title = CombineTitleChannel(config::titleFormat, title, channel);
		}
	}

	if (playing && config::markWatched) title = "[×] " + title;

	MetaData["title"] = title;
	

	if (config::jpegThumbnails) MetaData["thumbnail"] = ReplaceWebp(string(MetaData["thumbnail"]));


	if (config::normalizeTitle)
	{
		array<dictionary> chapters;

		MetaData.get("chapter", chapters);

		if (chapters.size() > 0)
		{
			for (uint i = 0; i < chapters.size(); i++)
			{
				title = string(chapters[i]["title"]);

				NormalizeString(title);

				chapters[i]["title"] = title;
			}

			MetaData["chapter"] = chapters;
		}
	}
}

void FixQualityList(array<dictionary>@ const &in QualityList, dictionary@ const &in MetaData)
{
	if (!config::fixFormats) return;

	if (QualityList is null) return;


	array<string> formatList;

	string format;

	bool f;

	for (uint i = 0; i < QualityList.size(); i++)
	{
		QualityList[i].get("format", format);

		f = false;

		for (uint j = 0; j < formatList.size(); j++)
		{
			if (format == formatList[j])
			{
				f = true;

				break;
			}
		}

		if (!f) formatList.insertLast(format);
	}

	formatList.sortDesc();

	{
		uint i = 0;
		
		int j = formatList.size();

		while (i < j)
		{
			format = formatList[i];

			if (format.find("mp4; avc") == 0)
			{
				formatList.removeAt(i);

				formatList.insertLast(format);

				j--;
			}
			else
			{
				i++;
			}
		}
	}
	

 	for (uint x = 0; x < formatList.size(); x++)
	{
		string format1, format2;

		uint i = 0;

		while (i < QualityList.size())
		{
			QualityList[i].get("format", format1);

			if (format1 == formatList[x])
			{
				int j = QualityList.size() - 1;

				while (j >= i)
				{
					dictionary item = QualityList[j];

					item.get("format", format2);

					if (format1 == format2)
					{
						QualityList.removeAt(j);

						QualityList.insertAt(0, item);

						i++;
					}
					else
					{
						j--;
					}
				}

				break;
			}
			else
			{
				i++;
			}
		}
	}


	int duration = -1;

	QualityList.reverse();

	for (uint i = 0; i < QualityList.size(); i++)
	{
		string quality;

		string resolution;
		
		QualityList[i].get("format", format);

		QualityList[i].get("resolution", resolution);

		if (!resolution.isEmpty())
		{
			double fps = 0.0;

			QualityList[i].get("fps", fps);

			if (fps > 0.0)
			{
				quality = " " + resolution + ", " + formatFloat(fps, "", 0, 0) + "F";
			}
			else
			{
				quality = " " + resolution;
			}
		}

		if (quality.isEmpty())
		{
			string bitrate;

			QualityList[i].get("bitrate", bitrate);

			if (!bitrate.isEmpty())
			{
				quality = " " + bitrate;
			}
			else
			{
				int itag = 0;

				QualityList[i].get("itag", itag);

				if (itag != 0)
				{
					quality = " f" + formatInt(itag);
				}
			}

		}
		
		QualityList[i]["quality"] = "[#" + formatInt(i + 1, '0', 2) + "]" + quality + " (" + format + ")";
		
		
		int64 size = 0;
		
		QualityList[i].get("sizeVal", size);
		
		if (size == 0)
		{
			int bitrate;

			QualityList[i].get("bitrateVal", bitrate);
			
			if (bitrate != 0)
			{
				if ((duration == -1) && (MetaData !is null))
				{
					duration = 0;
					
					MetaData.get("duration", duration);
				}
				
				if (duration != 0)
				{
					size = CalcSize(bitrate, duration / 1000);
					
					if (size != 0)
					{
						QualityList[i]["sizeVal"] = size;
					}
				}
			}
		}
		
		if (size > 0)
		{
			string qualityDetail;

			QualityList[i].get("qualityDetail", qualityDetail);
			
			if (!qualityDetail.isEmpty())
			{
				QualityList[i]["qualityDetail"] = qualityDetail + " (" + SizeToStr(size) + ")";
			}
		}
	}
}

void FixPlaylist(array<dictionary>@ const &in playlist)
{
	if (@playlist is null) return;
	
	
	if (config::jpegThumbnails)
	{
		for (uint i = 0; i < playlist.size(); i++)
		{
			dictionary item = playlist[i];

			item["thumbnail"] = ReplaceWebp(string(item["thumbnail"]));

			playlist[i] = item;
		}
	}
}

string CombineTitleChannel(string format, string title, string channel)
{
	if (title.isEmpty()) return channel;

	if (channel.isEmpty()) return title;
	

	if (format.isEmpty()) format = "title | channel";

	DebugPrint();
	DebugPrint(format);
	DebugPrint(title);
	DebugPrint(channel);

	int p1 = format.find("title");
	int p2 = format.find("channel");

	if (p1 < p2)
	{
		string tmp = title;
		title = channel;
		channel = tmp;
		
		format.replace("title", "4R5T6y5T4R");
		format.replace("channel", "1Q2W3e2W1Q");
	}
	else
	{
		format.replace("title", "1Q2W3e2W1Q");
		format.replace("channel", "4R5T6y5T4R");
	}
	
	p1 = format.find("1Q2W3e2W1Q");
	p2 = format.find("4R5T6y5T4R");
	
	string str = format.substr(p2 + 10, p1 - (p2 + 10));
	
	//DebugPrint("\"" + str + "\"");
	
	
	string tmp1 = str;
	string tmp2 = title;
	
	tmp1.TrimLeft();
	tmp2.TrimLeft();
	
	uint p = 0;
	int i = 0;
	
	while (i < tmp1.length())
	{
		for (uint j = 0; j < tmp2.length(); j++)
		{
			//DebugPrint("i = " + formatInt(i) + " \"" + ByteToStr(tmp1[i]) + "\"");
			//DebugPrint("j = " + formatInt(j) + " \"" + ByteToStr(tmp2[j]) + "\"");
			
			if (tmp1[i] != tmp2[j]) break;
			
			//DebugPrint("\"" + ByteToStr(tmp1[i]) + "\"");
			
			p++;
			i++;
			
			if (i >= tmp1.length()) break;
		}
		
		if (p > 0) break;
		
		i++;
	}
	
	if (p > 0)
	{
		tmp2 = tmp2.substr(p);
		
		//DebugPrint("\"" + tmp2 + "\"");
	}
	
	format.replace("1Q2W3e2W1Q", tmp2.Trim());
	
	
	tmp1 = str;
	tmp2 = channel;
	
	tmp1.TrimRight();
	tmp2.TrimRight();

	p = 0;
	i = tmp1.length() - 1;
	
	while (i >= 0)
	{
		for (int j = tmp2.length() - 1; j >= 0; j--)
		{
			//DebugPrint("i = " + formatInt(i) + " \"" + ByteToStr(tmp1[i]) + "\"");
			//DebugPrint("j = " + formatInt(j) + " \"" + ByteToStr(tmp2[j]) + "\"");
			
			if (tmp1[i] != tmp2[j]) break;
			
			//DebugPrint("\"" + ByteToStr(tmp1[i]) + "\"");
			
			p++;
			i--;
			
			if (i < 0) break;
		}
		
		if (p > 0) break;
		
		i--;
	}
	
	if (p > 0)
	{
		tmp2 = tmp2.substr(0, tmp2.length() - p);
		
		//DebugPrint("\"" + tmp2 + "\"");
	}
	
	format.replace("4R5T6y5T4R", tmp2.Trim());
	format.Trim();
	

	DebugPrint(format);
	
	return format;
}

const array<array<string>> normalizeChars =
	{{"rad/s2", "㎯"},
	{"100000", "ↈ"},
	{"rad/s", "㎮"},
	{"50000", "ↇ"},
	{"10000", "ↂ"},
	{"∫∫∫∫", "⨌"},
	{"viii", "ⅷ"},
	{"p.m.", "㏘"},
	{"m/s2", "㎨"},
	{"kcal", "㎉"},
	{"a.m.", "㏂"},
	{"VIII", "Ⅷ"},
	{"FREE", "🆓"},
	{"COOL", "🆒"},
	{"C/kg", "㏆"},
	{"5000", "ↁ"},
	{"1000", "ↀ"},
	{"1/10", "⅒"},
	{"(20)", "⒇"},
	{"(19)", "⒆"},
	{"(18)", "⒅"},
	{"(17)", "⒄"},
	{"(16)", "⒃"},
	{"(15)", "⒂"},
	{"(14)", "⒁"},
	{"(13)", "⒀"},
	{"(12)", "⑿"},
	{"(11)", "⑾"},
	{"(10)", "⑽"},
	{"''''", "′′′′", "⁗"},
	{"∫∫∫", "∭"},
	{"ффф", "∰", "∮∮∮"},
	{"xii", "ⅻ"},
	{"vii", "ⅶ"},
	{"rad", "㎭"},
	{"mol", "㏖"},
	{"mm3", "㎣"},
	{"mm2", "㎟"},
	{"mil", "㏕"},
	{"m/s", "㎧"},
	{"log", "㏒"},
	{"km3", "㎦"},
	{"km2", "㎢"},
	{"kPa", "㎪"},
	{"kHz", "㎑"},
	{"iii", "ⅲ"},
	{"hPa", "㍱"},
	{"gal", "㏿"},
	{"ffl", "ﬄ"},
	{"ffi", "ﬃ"},
	{"erg", "㋍"},
	{"dm3", "㍹"},
	{"dm2", "㍸"},
	{"cm3", "㎤"},
	{"cm2", "㎠"},
	{"cal", "㎈"},
	{"c/u", "℆"},
	{"c/o", "℅"},
	{"bar", "㍴"},
	{"aaa", "🝛"},
	{"a/s", "℁"},
	{"a/c", "℀"},
	{"XII", "Ⅻ"},
	{"VII", "Ⅶ"},
	{"V/m", "㏞"},
	{"UP!", "🆙"},
	{"THz", "㎔"},
	{"TEL", "℡"},
	{"SYN", "␖"},
	{"SUB", "␚"},
	{"STX", "␂"},
	{"SOS", "🆘"},
	{"SOH", "␁"},
	{"PTE", "㉐"},
	{"PPV", "🅎"},
	{"PPM", "㏙"},
	{"NUL", "␀"},
	{"NEW", "🆕"},
	{"NAK", "␕"},
	{"MPa", "㎫"},
	{"MHz", "㎒"},
	{"LTD", "㋏"},
	{"III", "Ⅲ"},
	{"GPa", "㎬"},
	{"GHz", "㎓"},
	{"FAX", "℻"},
	{"ETX", "␃"},
	{"ETB", "␗"},
	{"ESC", "␛"},
	{"EOT", "␄"},
	{"ENQ", "␅"},
	{"DLE", "␐"},
	{"DEL", "␡"},
	{"DC4", "␔"},
	{"DC3", "␓"},
	{"DC2", "␒"},
	{"DC1", "␑"},
	{"Co.", "㏇"},
	{"CAN", "␘"},
	{"BEL", "␇"},
	{"ACK", "␆"},
	{"A/s", "⅍"},
	{"A/m", "㏟"},
	{"===", "⩶"},
	{"::=", "⩴"},
	{"7/8", "⅞"},
	{"5/8", "⅝"},
	{"5/6", "⅚"},
	{"4/5", "⅘"},
	{"3/8", "⅜"},
	{"3/5", "⅗"},
	{"3/4", "¾"},
	{"20.", "⒛"},
	{"2/5", "⅖"},
	{"2/3", "⅔"},
	{"19.", "⒚"},
	{"18.", "⒙"},
	{"17.", "⒘"},
	{"16.", "⒗"},
	{"15.", "⒖"},
	{"14.", "⒕"},
	{"13.", "⒔"},
	{"12.", "⒓"},
	{"11.", "⒒"},
	{"10.", "⒑"},
	{"1/9", "⅑"},
	{"1/8", "⅛"},
	{"1/7", "⅐"},
	{"1/6", "⅙"},
	{"1/5", "⅕"},
	{"1/4", "¼"},
	{"1/3", "⅓"},
	{"1/2", "½"},
	{"0/3", "↉"},
	{"...", "…"},
	{"(z)", "⒵"},
	{"(y)", "⒴"},
	{"(x)", "⒳"},
	{"(w)", "⒲"},
	{"(v)", "⒱"},
	{"(u)", "⒰"},
	{"(t)", "⒯"},
	{"(s)", "⒮"},
	{"(r)", "⒭"},
	{"(q)", "⒬"},
	{"(p)", "⒫"},
	{"(o)", "⒪"},
	{"(n)", "⒩"},
	{"(m)", "⒨"},
	{"(l)", "⒧"},
	{"(k)", "⒦"},
	{"(j)", "⒥"},
	{"(i)", "⒤"},
	{"(h)", "⒣"},
	{"(g)", "⒢"},
	{"(f)", "⒡"},
	{"(e)", "⒠"},
	{"(d)", "⒟"},
	{"(c)", "⒞"/*, "©"*/},
	{"(b)", "⒝"},
	{"(a)", "⒜"},
	{"(Z)", "🄩"},
	{"(Y)", "🄨"},
	{"(X)", "🄧"},
	{"(W)", "🄦"},
	{"(V)", "🄥"},
	{"(U)", "🄤"},
	{"(T)", "🄣"},
	{"(S)", "🄪", "🄢"},
	{"(R)", "🄡"/*, "®"*/},
	{"(Q)", "🄠"},
	{"(P)", "🄟"},
	{"(O)", "🄞"},
	{"(N)", "🄝"},
	{"(M)", "🄜"},
	{"(L)", "🄛"},
	{"(K)", "🄚"},
	{"(J)", "🄙"},
	{"(I)", "🄘"},
	{"(H)", "🄗"},
	{"(G)", "🄖"},
	{"(F)", "🄕"},
	{"(E)", "🄔"},
	{"(D)", "🄓"},
	{"(C)", "🄒"},
	{"(B)", "🄑"},
	{"(A)", "🄐"},
	{"(9)", "⑼"},
	{"(8)", "⑻"},
	{"(7)", "⑺"},
	{"(6)", "⑹"},
	{"(5)", "⑸"},
	{"(4)", "⑷"},
	{"(3)", "⑶"},
	{"(2)", "⑵"},
	{"(1)", "⑴"},
	{"'''", "‴", "‷", "′′′", "‵‵‵"},
	{"∫∫", "∬"},
	{"фф", "∯", "∮∮"},
	{"xi", "ⅺ"},
	{"ww", "ʬ"},
	{"vi", "ⅵ"},
	{"us", "μs", "㎲"},
	{"uo", "ꭣ"},
	{"um", "μm", "㎛"},
	{"ul", "μl", "㎕"},
	{"ui", "ꭐ"},
	{"ug", "μg", "㎍"},
	{"ue", "ᵫ"},
	{"uW", "μW", "㎼"},
	{"uV", "μV", "㎶"},
	{"uF", "㎌", "μF"},
	{"uA", "μA", "㎂"},
	{"t∫", "ʧ", "𐞮"},
	{"tz", "ꜩ"},
	{"ts", "𐞭", "𐞬", "ꭧ", "ʦ"},
	{"th", "ᵺ"},
	{"tc", "𐞫", "ʨ"},
	{"st", "ﬆ"},
	{"sr", "㏛"},
	{"qp", "ȹ"},
	{"ps", "㎰"},
	{"pc", "㍶"},
	{"pW", "㎺"},
	{"pV", "㎴"},
	{"pF", "㎊"},
	{"pA", "㎀"},
	{"oy", "ѹ"},
	{"oo", "ꚙ", "ꝏ"},
	{"oe", "ꟹ", "œ"},
	{"oV", "㍵"},
	{"ns", "㎱"},
	{"nm", "㎚"},
	{"nj", "ǌ"},
	{"nW", "㎻"},
	{"nV", "㎵"},
	{"nF", "㎋"},
	{"nA", "㎁"},
	{"ms", "㎳"},
	{"mm", "㎜"},
	{"ml", "㎖"},
	{"mg", "㎎"},
	{"mb", "㏔"},
	{"mW", "㎽"},
	{"mV", "㎷"},
	{"mA", "㎃"},
	{"m3", "㎥"},
	{"m2", "㎡"},
	{"lz", "𐞚", "ʫ"},
	{"lx", "㏓"},
	{"ls", "ʪ", "𐞙"},
	{"ln", "㏑"},
	{"lm", "㏐"},
	{"ll", "ỻ"},
	{"lj", "ǉ"},
	{"lL", "Ỻ"},
	{"kt", "㏏"},
	{"km", "㎞"},
	{"kl", "㎘"},
	{"kg", "㎏"},
	{"kW", "㎾"},
	{"kV", "㎸"},
	{"kO", "㏀", "kΩ"},
	{"kA", "㎄"},
	{"ix", "ⅸ"},
	{"iv", "ⅳ"},
	{"in", "㏌"},
	{"ij", "ĳ"},
	{"ii", "ⅱ"},
	{"ie", "ꭡ"},
	{"ib", "℔"},
	{"ha", "㏊"},
	{"ft", "ﬅ"},
	{"fn", "𐞐", "ʩ"},
	{"fm", "㎙"},
	{"fl", "ﬂ"},
	{"fi", "ﬁ"},
	{"ff", "ﬀ"},
	{"et", "🙰"},
	{"eo", "ᴔ"},
	{"eV", "㋎"},
	{"dz", "ǆ", "ǳ", "ʣ", "ʥ", "ꭦ", "dž", "𐞇", "𐞈", "𐞉"},
	{"dm", "㍷"},
	{"dl", "㎗"},
	{"db", "ȸ"},
	{"da", "㍲"},
	{"dB", "㏈"},
	{"d3", "𐞊", "ʤ"},
	{"cm", "㎝"},
	{"ce", "ꭢ"},
	{"cd", "㏅"},
	{"cc", "㏄"},
	{"ay", "ꜽ"},
	{"av", "ꜹ"},
	{"au", "ꜷ"},
	{"ao", "ꜵ"},
	{"ae", "æ", "ǣ", "ǽ", "ӕ", "ᴂ", "ᵆ", "ꬱ", "ǽ", "ǣ", "𐞃"},
	{"aa", "ꜳ"},
	{"\\", "🙽", "⤡", "＼", "﹨", "丶", "㇔", "⼂", "⧹", "⧵", "⟍", "∖"},
	{"\"", "«", "»", "🙸", "🙷", "🙶", "¨", "ʺ", "˝", "ˮ", "˵", "˶", "᳓", "“", "”", "„", "‟", "″", "‶", "〃", "＂", " ̈", "′′", "‵‵"},
	{"XI", "Ⅺ"},
	{"Wz", "🄮"},
	{"Wb", "㏝"},
	{"WC", "🆏", "🅏"},
	{"VT", "␋"},
	{"VS", "🆚"},
	{"VI", "Ⅵ"},
	{"VB", "🝬"},
	{"US", "␟"},
	{"Tz", "Ꜩ"},
	//{"TM", "™"},
	{"Sv", "㏜"},
	{"SS", "🅍"},
	{"SP", "␠"},
	{"SO", "␎"},
	{"SM", "℠"},
	{"SI", "␏"},
	{"SD", "🅌"},
	{"SA", "🆍"},
	{"Rs", "₨"},
	{"RS", "␞"},
	{"Pa", "㎩"},
	{"PR", "㏚"},
	{"PH", "㏗"},
	{"PA", "🆌"},
	{"Oy", "Ѹ"},
	{"OO", "Ꝏ", "Ꚙ"},
	{"OK", "🆗"},
	{"OE", "ɶ", "𐞣"},
	//{"No", "№"},
	{"Nj", "ǋ"},
	{"NL", "␤"},
	{"NJ", "Ǌ"},
	{"NG", "🆖"},
	{"MW", "㎿"},
	{"MV", "🅋", "㎹"},
	{"MO", "MΩ", "㏁"},
	{"MB", "㎆", "🝫"},
	{"Lj", "ǈ"},
	{"LJ", "Ǉ"},
	{"LF", "␊"},
	{"KM", "㏎"},
	{"KK", "㏍"},
	{"KB", "㎅"},
	{"JX", "Ԕ"},
	{"IX", "Ⅸ"},
	{"IV", "Ⅳ"},
	{"IU", "㍺"},
	{"IJ", "Ĳ"},
	{"II", "Ⅱ"},
	{"ID", "🆔"},
	{"IC", "🆋"},
	{"Hz", "㎐"},
	{"Hg", "㋌"},
	{"HV", "🅊"},
	{"HT", "␉"},
	{"HP", "㏋"},
	{"Gy", "㏉"},
	{"GS", "␝"},
	{"GB", "㎇"},
	{"FS", "␜"},
	{"FF", "␌"},
	{"EM", "␙"},
	{"D.C.", "𝄉"},
	{"D.S.", "𝄊"},
	{"Dz", "ǅ", "ǲ", "Dž"},
	{"DZ", "DŽ", "Ǳ", "Ǆ"},
	{"DJ", "🆐"},
	{"CR", "␍"},
	{"CL", "🆑", "℄"},
	{"CE", "Œ"},
	{"CD", "🄭"},
	{"Bq", "㏃"},
	{"BS", "␈"},
	{"AY", "Ꜽ"},
	{"AV", "Ꜹ", "Ꜻ"},
	{"AU", "Ꜷ", "㍳"},
	{"AR", "🜇"},
	{"AO", "Ꜵ"},
	{"AE", "Ǣ", "Ǽ", "ᴭ", "ᴁ", "Ӕ", "Ǽ", "Ǣ", "Æ"},
	{"AB", "🆎"},
	{"AA", "Ꜳ"},
	{"??", "⁇"},
	{"?!", "🙻", "🙺", "🙹", "⁈"},
	{"==", "⩵"},
	{"90", "Ϟ"},
	{"9.", "⒐"},
	{"9,", "🄊"},
	{"80", "㉏"},
	{"8.", "⒏"},
	{"8,", "🄉"},
	{"70", "㉎"},
	{"7.", "⒎"},
	{"7,", "🄈"},
	{"60", "㉍"},
	{"6.", "⒍"},
	{"6,", "🄇"},
	{"50", "㉌", "㊿"},
	{"5.", "⒌"},
	{"5,", "🄆"},
	{"49", "㊾"},
	{"48", "㊽"},
	{"47", "㊼"},
	{"46", "㊻"},
	{"45", "㊺"},
	{"44", "㊹"},
	{"43", "㊸"},
	{"42", "㊷"},
	{"41", "㊶"},
	{"40", "㉋", "㊵"},
	{"4.", "⒋"},
	{"4,", "🄅"},
	{"39", "㊴"},
	{"38", "㊳"},
	{"37", "㊲"},
	{"36", "㊱"},
	{"35", "㉟"},
	{"34", "㉞"},
	{"33", "㉝"},
	{"32", "㉜"},
	{"31", "31日", "㏾", "㉛"},
	{"30", "30日", "㏽", "㉚", "㉊"},
	{"3.", "⒊"},
	{"3,", "🄄"},
	{"29", "㉙", "㏼", "29日"},
	{"28", "28日", "㏻", "㉘"},
	{"27", "27日", "㏺", "㉗"},
	{"26", "㉖", "㏹", "26日"},
	{"25", "25日", "㏸", "㉕"},
	{"24", "㉔", "㍰", "㏷", "24日", "24点"},
	{"23", "23点", "23日", "㏶", "㍯", "㉓"},
	{"22", "㉒", "㍮", "㏵", "22日", "22点"},
	{"21", "21点", "21日", "㏴", "㍭", "㉑"},
	{"20", "⑳", "⓴", "㉉", "㍬", "㏳", "20日", "20点"},
	{"2.", "⒉"},
	{"2,", "🄃"},
	{"19", "⑲", "⓳", "㍫", "㏲", "19日", "19点"},
	{"18", "18点", "18日", "㏱", "㍪", "⓲", "⑱"},
	{"17", "⑰", "⓱", "㍩", "㏰", "17日", "17点"},
	{"16", "16点", "16日", "㏯", "㍨", "⓰", "⑯"},
	{"15", "15点", "15日", "㏮", "㍧", "⓯", "⑮"},
	{"14", "⑭", "⓮", "㍦", "㏭", "14日", "14点"},
	{"13", "13点", "13日", "㏬", "㍥", "⓭", "⑬"},
	{"12", "⑫", "⓬", "㋋", "㍤", "㏫", "12日", "12月", "12点"},
	{"11", "11点", "11月", "11日", "㏪", "㍣", "㋊", "⓫", "⑪"},
	{"10", "10点", "10月", "10日", "㏩", "㍢", "㋉", "㉈", "➓", "➉", "❿", "⓾", "⑩"},
	{"1/", "⅟"},
	{"1.", "⒈"},
	{"1,", "🄂"},
	{"0.", "🄀"},
	{"0,", "🄁"},
	{"..", "‥"},
	{"!?", "⁉"},
	{"!!", "‼"},
	{"♫", "🎵", "♬"},
	{"♪", "🎼", "🎶", "♩", "𝄞", "𝄟", "𝄠", "𝄫", "𝄭", "𝅗𝅥", "𝅘𝅥", "𝅘𝅥𝅮", "𝅘𝅥𝅯", "𝅘𝅥𝅰", "𝅘𝅥𝅱", "𝅘𝅥𝅲"},
	{"♦", "♢", "◆", "◇", "◈", "◊"},
	{"♥", "🩵", "🩶", "🩷", "🫀", "🧡", "🤎", "🤍", "🖤", "💟", "💞", "💝", "💛", "💚", "💙", "💘", "💗", "💖", "💕", "💔", "💓", "💌", "💋", "🎔", "❧", "❦", "❥", "❤", "❣", "♡", "☙", "ღ"},
	{"♣", "♧"},
	{"♠", "♤"},
	{"☻", "🫠", "🥰", "🤭", "🤪", "🤩", "🤤", "🤣", "🤠", "🤗", "🤓", "🙃", "🙂", "😝", "😜", "😛", "😚", "😙", "😎", "😍", "😌", "😋", "😊", "😉", "😇", "😆", "😅", "😄", "😃", "😂", "😁", "😀", "シ"},
	{"▫", "🢬", "🢭", "𝅆", "▯", "▱", "◽", "◽︎", "◽️", "▫︎", "▫️"},
	{"▪", "🢟", "🢞", "🢝", "🢜", "𝅇", "▰", "◾", "◾︎", "◾️", "▪︎", "▪️"},
	{"□", "□", "▤", "▦", "▧", "▨", "⧈", "🞑", "🞒", "🞓", "𝅚", "▢", "▣", "▥", "▩", "▭", "◰", "◱", "◲", "◳", "◻", "◫", "◻︎", "◻️"},
	{"■", "￭", "𝅛", "◼", "◧", "◨", "◩", "◪", "◼︎", "◼️", "◘", "◙", "◚", "◛"},
	{"≠", "≢", "≭", "≉", "≇", "≄", "≠", "≭", "≢", "≉", "≇", "≄"},
	{"∫", "ʃ", "ᶴ"},
	{"↕", "🗘", "🔃", "⮃", "⮁", "⭿", "⬍", "⥯", "⥮", "⥑", "⥏", "⥍", "⥌", "⇵", "⇳", "⇕", "⇅", "↨"},
	{"↔", "↔", "↭", "↮", "↹", "⇄", "⇆", "⇋", "⇌", "⇔", "⇹", "⇼", "⇿", "⟷", "⤄", "⥂", "⥃", "⥄", "⥈", "⥊", "⥋", "⥎", "⥐", "⥦", "⥧", "⥨", "⥩", "⬄", "⬌", "⭾", "⮀", "⮂", "🔁", "🔂", "🔄"},
	{"▼", "◡", "↓", "🢗", "🢓", "⯯", "⮟", "⮛", "▿", "▾", "▽", "⌄", "🢃", "🡻", "🡳", "🡫", "🡣", "🡇", "🡃", "🠿", "🠻", "🠗", "🠓", "￬", "⮷", "⮶", "⮯", "⮮", "⮏", "⮋", "⮇", "⭽", "⬇", "⥥", "⥡", "⥝", "⥙", "⥕", "⤹", "⤸", "⤵", "⤓", "⤋", "⤈", "⟳", "⟲", "⟱", "☟", "⍗", "⍖", "⍔", "⍌", "⇩", "⇣", "⇟", "⇓", "⇊", "⇃", "⇂", "↷", "↶", "↴", "↧", "↡", "ᗐ", "ᐯ", "ᐁ", "̬", "ˬ", "ˇ", "˅"},
	{">", "⧁", "◿", "◹", "►", "→", "◢", "🢆", "🡾", "🡶", "🡮", "🡦", "⭸", "⬊", "⬂", "⤥", "➷", "➴", "➘", "☇", "⇲", "⇘", "↘", "◥", "↗", "⇗", "➚", "➶", "➹", "⤤", "⬀", "⬈", "⭷", "🡥", "🡭", "🡵", "🡽", "🢅", "▶", "▶︎", "▶️", "▷", "▸", "▹", "▻", "➢", "➣", "➤", "⮚", "⮞", "⯮", "🢒", "🢫", "🢩", "🢧", "🢥", "🢣", "🢡", "🢂", "🡺", "🡲", "🡪", "🡢", "🡆", "🡂", "🠾", "🠺", "🠖", "🠒", "￫", "⮳", "⮱", "⮫", "⮩", "⮎", "⮊", "⮆", "⭼", "⭲", "⥹", "⥸", "⥵", "⥴", "⥲", "⥱", "⥰", "⥭", "⥬", "⥤", "⥟", "⥛", "⥗", "⥓", "⥇", "⥅", "⤿", "⤼", "⤻", "⤷", "⤳", "⤠", "⤞", "⤜", "⤚", "⤘", "⤗", "⤖", "⤕", "⤔", "⤑", "⤐", "⤏", "⤍", "⤇", "⤅", "⤃", "⤁", "⤀", "⟿", "⟾", "⟼", "⟹", "⟶", "⟴", "➾", "➽", "➼", "➻", "➺", "➸", "➵", "➳", "➲", "➱", "➯", "➮", "➭", "➬", "➫", "➪", "➩", "➨", "➧", "➦", "➥", "➡", "➠", "➟", "➞", "➝", "➜", "➛", "➙", "➔", "☞", "☛", "⍈", "⍆", "⇾", "⇻", "⇸", "⇶", "⇴", "⇰", "⇨", "⇥", "⇢", "⇝", "⇛", "⇒", "⇏", "⇉", "⇁", "⇀", "↳", "↱", "↬", "↪", "↦", "↣", "↠", "↝", "↛", "⃗", "⃕"},
	{"▲", "◮", "◭", "◬", "◠", "↑", "🢕", "🢑", "⯭", "⮝", "⮙", "▵", "▴", "△", "ᐃ", "ᐞ", "ᐱ", "ᗑ", "ᛣ", "↟", "↥", "↺", "↻", "↾", "↿", "⇈", "⇑", "⇞", "⇡", "⇧", "⇪", "⇫", "⇬", "⇭", "⇮", "⇯", "⍍", "⍏", "⍐", "⍓", "☝", "⟰", "⤉", "⤊", "⤒", "⤴", "⥉", "⥔", "⥘", "⥜", "⥠", "⥣", "⬆", "⭮", "⭯", "⭱", "⭻", "⮅", "⮉", "⮍", "⮬", "⮭", "⮴", "⮵", "￪", "🠑", "🠕", "🠹", "🠽", "🡁", "🡅", "🡡", "🡩", "🡱", "🡹", "🢁"},
	{"<", "⧀", "◺", "◸", "◄", "←", "◣", "↙", "⇙", "⤦", "⬃", "⬋", "⭹", "🡧", "🡯", "🡷", "🡿", "🢇", "◤", "🢄", "🡼", "🡴", "🡬", "🡤", "⭶", "⬉", "⬁", "⤣", "⇱", "⇖", "↸", "↖", "◀", "◀︎", "◀️", "◁", "◂", "◃", "◅", "⮘", "⮜", "⯬", "🢐", "🢪", "🢨", "🢦", "🢤", "🢢", "🢠", "🢀", "🡸", "🡰", "🡨", "🡠", "🡄", "🡀", "🠼", "🠸", "🠔", "🠐", "￩", "⮲", "⮰", "⮪", "⮨", "⮌", "⮈", "⮄", "⭺", "⭰", "⬿", "⬽", "⬼", "⬻", "⬺", "⬹", "⬶", "⬵", "⬴", "⬳", "⬅", "⥺", "⥷", "⥶", "⥳", "⥫", "⥪", "⥢", "⥞", "⥚", "⥖", "⥒", "⥆", "⤾", "⤽", "⤺", "⤶", "⤟", "⤝", "⤛", "⤙", "⤎", "⤌", "⤆", "⤂", "⟽", "⟻", "⟸", "⟵", "☚", "⍇", "⍅", "⇽", "⇺", "⇷", "⇦", "⇤", "⇠", "⇜", "⇚", "⇐", "⇍", "⇇", "↽", "↼", "↵", "↲", "↰", "↫", "↩", "↤", "↢", "↞", "↜", "↚", "⃖"},
	{"ё", "ѐ", "ӗ", "ә", "ӛ", "ѐ", "ӗ", "ё", "ӛ"},
	{"ю", "𞁉"},
	{"э", "𞁈", "ӭ", "ӭ"},
	{"ь", "ꚝ"},
	{"ы", "𞁬", "𞁦", "𞁇", "ӹ", "ꙑ", "ӹ"},
	{"ъ", "ꚜ", "𞁥"},
	{"ш", "𞁤", "𞁆"},
	{"ч", "𞁣", "𞁅", "ӵ", "ӵ"},
	{"ц", "џ", "𞁄", "𞁢", "𞁪"},
	{"х", "𞁡", "𞁃"},
	{"ф", "ɸ", "φ", "ϕ", "ᵠ", "ᵩ", "ᶲ", "𝛗", "𝛟", "𝜑", "𝜙", "𝝋", "𝝓", "𝞅", "𝞍", "𝞿", "𝟇", "𞁂", "𞁠"},
	{"у", "𞁭", "𞁟", "𞁏", "𞁁", "ӳ", "ӱ", "ў", "ӯ", "ӳ", "ӱ", "ӯ", "ұ", "ү", "ў"},
	{"т", "𞁀"},
	{"с", "ҫ", "𞀿", "𞁞", "𞁫"},
	{"р", "𞀾"},
	{"п", "π", "ϖ", "ℼ", "𝛑", "𝜋", "𝝅", "𝝿", "𝞹", "𞀽", "𞁝"},
	{"о", "𞁜", "𞁎", "𞀼", "ӫ", "ӧ", "ӫ", "ө", "ӧ"},
	{"н", "ᵸ"},
	{"м", "𞀻"},
	{"л", "𞁛", "𞀺"},
	{"к", "ќ", "ќ", "𞀹", "𞁚"},
	{"й", "ӥ", "й", "ӣ", "ѝ", "ӥ", "ӣ", "ѝ", "й"},
	{"и", "𞁙", "𞀸"},
	{"з", "ǯ", "ʒ", "ӟ", "ᶾ", "ǯ", "ӟ", "𝖟", "𞀷", "𞁘"},
	{"ж", "𞁗", "𞀶", "ӝ", "ӂ", "ӝ", "ӂ"},
	{"е", "𞀵", "𞁋", "𞁖"},
	{"д", "𞁕", "𞁊", "𞀴", "ꚉ"},
	{"г", "ѓ", "ґ", "ѓ", "𞀳", "𞁔", "𞁧"},
	{"в", "𞁓", "𞀲"},
	{"б", "𞀱", "𞁒"},
	{"а", "𞁑", "𞀰", "ӓ", "ӑ", "ӓ", "ӑ"},
	{"Э", "Ӭ", "Ӭ"},
	{"Ы", "Ӹ", "Ӹ"},
	{"Ч", "Ӵ", "Ӵ"},
	{"Ф", "Φ", "𝚽", "𝛷", "𝜱", "𝝫", "𝞥"},
	{"У", "Ӳ", "Ӱ", "Ў", "Ӯ", "Ӳ", "Ӱ", "Ӯ", "Ў"},
	{"П", "𝞟", "𝝥", "𝜫", "𝛱", "𝚷", "ℿ", "Π"},
	{"О", "Ӧ", "Ӫ", "Ӧ", "Ӫ"},
	{"Л", "𝞚", "𝝠", "𝜦", "𝛬", "𝚲", "Λ"},
	{"К", "Ќ", "Ќ"},
	{"Й", "Ӥ", "Й", "Ӣ", "Ѝ", "Ӥ", "Ӣ", "Ѝ"},
	{"З", "𝖅", "Ӟ", "Ǯ", "Ӟ", "Ǯ"},
	{"Ж", "Ӂ", "Ӝ", "Ӂ", "Ӝ"},
	{"Е", "Ӛ", "Ӛ"},
	{"Г", "Γ", "Ѓ", "ℾ", "Ѓ", "𝚪", "𝛤", "𝜞", "𝝘", "𝞒"},
	{"А", "Ӓ", "Ӑ", "Ӓ", "Ӑ"},
	{"Δ", "𝞓", "𝝙", "𝜟", "𝛥", "𝚫"},
	{"•", "●", "·", "ˑ", "·", "𐞂", "◎", "◉", "￮", "◌", "◦", "⚫", "🔵", "🔴", "⦿", "🔘", "❂", "☢", "∘", "⧳", "⧲", "⧭"},
	{"¯", " ̅", " ̄", "￣", "﹌", "﹋", "﹊", "﹉", "▔", "‾"},
	{"£", "￡"},
	{"~", " ̈͂", "῁", " ͂", "～", "⸟", "⸞", "∿", "∾", "∽", "∼", "∻", "⁓", "῁", "῀", "˷", "˜"},
	{"}", "﹜", "︸", "❵"},
	{"} ", "｝"},
	{"|", "💜", "𐞷", "𐞶", "￨", "￤", "｜", "︴", "︳", "︲", "︱", "❙", "▕", "▏", "▎", "╽", "│", "⎮", "⎪", "⎥", "⎢", "⎜", "‖", "།", "।", "ߊ", "ǁ", "ǀ", "¦", "𝄀", "𝄁", "𝄂", "𝄃", "𝄄", "𝄅", "𝄆", "𝄇", "𝅥", "▮"},
	{">", "⏵"},
	{"||","⏸"},
	{">||", "⏯"},
	{"■", "⏹"},
	{"<<", "⏪"},
	{">>", "⏩"},
	{"|<<", "⏮"},
	{">>|", "⏭"},
	{"•", "⏺"},
	{"▲", "⏏"},
	{"{", "︷", "﹛", "❴", "𝄔"},
	{" {", "｛"},
	{"z", "򸰵", "򫰵", "򞰵", "򑰵", "򄰵", "񷰵", "񪰵", "񪐼", "񝰵", "񐰵", "񃰵", "𶰵", "𝞯", "𝝵", "𝜻", "𝜁", "𝛇", "𝚣", "𝙯", "𝘻", "𝘇", "𝗓", "𝕫", "𝔷", "𝔃", "𝓏", "𝒛", "𝑧", "𝐳", "𜰵", "z͏", "ẕ", "ẓ", "ž", "ż", "ẑ", "ź", "ｚ", "ꙃ", "ꙁ", "乙", "ⴭ", "ⲍ", "ⱬ", "☡", "ⓩ", "ẕ", "ẓ", "ẑ", "ᶽ", "ᶼ", "ᶻ", "ᶎ", "ᵶ", "ᴢ", "ᙆ", "ᗱ", "ጊ", "ຊ", "ζ", "ʑ", "ʐ", "ɀ", "ȥ", "ƶ", "ž", "ż", "ź"},
	{"y", "ý", "ÿ", "ŷ", "ƴ", "ȳ", "ɏ", "ɣ", "ɤ", "ʎ", "ʸ", "ˠ", "γ", "λ", "ע", "ץ", "ߌ", "ฯ", "Ⴘ", "Ⴞ", "Ⴤ", "უ", "ყ", "ჩ", "ჸ", "ሃ", "ᖻ", "ᵞ", "ᵧ", "ᶌ", "ẏ", "ẙ", "ỳ", "ỵ", "ỷ", "ỹ", "ỿ", "ℽ", "ⓨ", "ⲩ", "ㄚ", "丫", "Ꚕ", "ꚕ", "ｙ", "ﾘ", "ỳ", "ý", "ŷ", "ỹ", "ȳ", "ẏ", "ÿ", "ỷ", "ẙ", "ỵ", "𐒋", "𐒦", "𐞑", "𐞠", "𐞡", "𝐲", "𝑦", "𝒚", "𝓎", "𝔂", "𝕪", "𝗒", "𝘆", "𝘺", "𝙮", "𝚢", "𝛄", "𝛌", "𝛾", "𝜆", "𝜸", "𝝀", "𝝲", "𝝺", "𝞬", "𝞴", "𝼆"},
	{"x", "򸐵", "򫐵", "򞐵", "򑐵", "򄐵", "񷐵", "񪐵", "񩰼", "񝐵", "񐐵", "񃐵", "𶐵", "🗙", "𝟀", "𝞆", "𝝌", "𝜒", "𝛘", "𝚡", "𝙭", "𝘹", "𝘅", "𝗑", "𝖝", "𝕩", "𝔵", "𝔁", "𝓍", "𝒙", "𝑥", "𝐱", "𜐵", "x͏", "ẍ", "ẋ", "ﾒ", "ｘ", "乂", "ㄨ", "ⵋ", "ⵅ", "ⴴ", "ⲭ", "⨯", "⨉", "⧖", "⤬", "⤫", "✘", "✗", "✕", "⛌", "☓", "╳", "ⓧ", "⌧", "ⅹ", "ₓ", "ẍ", "ẋ", "ᶍ", "ᵪ", "ᵡ", "ᚕ", "᙮", "ᕁ", "ሸ", "྾", "Ӿ", "ӽ", "ҳ", "χ", "ͯ", "ˣ", "×", "𝅃", "𝅅"},
	{"w", "ᾧ", "ᾥ", "ᾣ", "ᾦ", "ᾤ", "ᾢ", "ῷ", "ᾡ", "ὧ", "ὥ", "ὣ", "ᾠ", "ὦ", "ὤ", "ὢ", "ῴ", "ῲ", "🝃", "𝟉", "𝟂", "𝟁", "𝞏", "𝞈", "𝞇", "𝝕", "𝝎", "𝝍", "𝜛", "𝜔", "𝜓", "𝛡", "𝛚", "𝛙", "𝚠", "𝙬", "𝘸", "𝘄", "𝗐", "𝖜", "𝕨", "𝔴", "𝔀", "𝓌", "𝒘", "𝑤", "𝐰", "𐞤", "ῳ", "ῶ", "ὡ", "ὠ", "ώ", "ὼ", "ẉ", "ẘ", "ẅ", "ẇ", "ŵ", "ẃ", "ẁ", "ｗ", "ꟺ", "ꞷ", "ꝡ", "ꙍ", "山", "ⲱ", "Ⲱ", "ⱳ", "ⓦ", "⍹", "⍵", "ῷ", "ῶ", "ῴ", "ῳ", "ῲ", "ᾧ", "ᾦ", "ᾥ", "ᾤ", "ᾣ", "ᾢ", "ᾡ", "ᾠ", "ώ", "ὼ", "ὧ", "ὦ", "ὥ", "ὤ", "ὣ", "ὢ", "ὡ", "ὠ", "ẘ", "ẉ", "ẇ", "ẅ", "ẃ", "ẁ", "ᶭ", "ᵚ", "ᥕ", "ᙡ", "ᙎ", "ᘺ", "ᗵ", "ᐜ", "Ꮗ", "ሥ", "ሡ", "ሠ", "ຟ", "ພ", "ຝ", "ຜ", "ฬ", "ฟ", "พ", "ผ", "ധ", "ഡ", "౻", "պ", "ա", "ԝ", "ѿ", "ѡ", "ώ", "ω", "ψ", "ʷ", "ɷ", "ɰ", "ɯ", "Ɯ", "ŵ"},
	{"v", "ʊ", "ʋ", "ʌ", "ͮ", "ΰ", "ν", "ϋ", "ύ", "ѵ", "ѷ", "ש", "٧", "۷", "ݍ", "߇", "ߜ", "౮", "ง", "ሀ", "ᐺ", "ᕂ", "ᕓ", "ᘁ", "ᜠ", "ᜱ", "៴", "ᴠ", "ᴧ", "ᵛ", "ᵥ", "ᶷ", "ᶹ", "ᶺ", "ṽ", "ṿ", "ὐ", "ὑ", "ὒ", "ὓ", "ὔ", "ὕ", "ὖ", "ὗ", "ὺ", "ύ", "ῠ", "ῡ", "ῢ", "ΰ", "ῦ", "ῧ", "ⅴ", "√", "∨", "⋁", "⋎", "⌵", "ⓥ", "⛛", "✓", "ⱱ", "ⴸ", "ｖ", "ṽ", "ṿ", "v͏", "ὺ", "ύ", "ῡ", "ῠ", "ϋ", "ὐ", "ὑ", "ῦ", "ѷ", "𐞰", "𛰵", "𝐯", "𝑣", "𝒗", "𝓋", "𝓿", "𝔳", "𝕧", "𝖛", "𝗏", "𝘃", "𝘷", "𝙫", "𝚟", "𝛎", "𝜈", "𝝂", "𝝼", "𝞶", "🜄", "𵰵", "񂰵", "񏰵", "񜰵", "񩐼", "񩰵", "񶰵", "򃰵", "򐰵", "򝰵", "򪰵", "򷰵", "ῢ", "ΰ", "ῧ", "ὒ", "ὔ", "ὖ", "ὓ", "ὕ", "ὗ"},
	{"u", "ự", "ử", "ữ", "ứ", "ừ", "ǚ", "ǖ", "ǘ", "ǜ", "ṻ", "ṹ", "𝞾", "𝞵", "𝞄", "𝝻", "𝝊", "𝝁", "𝜐", "𝜇", "𝛖", "𝛍", "𝚞", "𝙪", "𝘶", "𝘂", "𝗎", "𝖚", "𝕦", "𝔲", "𝓾", "𝓊", "𝒖", "𝑢", "𝐮", "𐒜", "ṵ", "ṷ", "ų", "ṳ", "ụ", "ư", "ȗ", "ȕ", "ǔ", "ű", "ů", "ủ", "ü", "ŭ", "ū", "ũ", "û", "ú", "ù", "ｕ", "ꭟ", "ꭒ", "ㄩ", "ⵡ", "ⓤ", "⋃", "⊔", "⊍", "∪", "ự", "ữ", "ử", "ừ", "ứ", "ủ", "ụ", "ṻ", "ṹ", "ṷ", "ṵ", "ṳ", "ᶶ", "ᵤ", "ᵘ", "ᥩ", "ᥙ", "ᕫ", "ᓑ", "ᑌ", "ᐡ", "ሆ", "ህ", "ሁ", "ပ", "ມ", "ປ", "ບ", "ย", "ป", "น", "ப", "૫", "પ", "ߎ", "և", "ն", "υ", "μ", "ͧ", "ʯ", "ʉ", "ȗ", "ȕ", "ǜ", "ǚ", "ǘ", "ǖ", "ǔ", "Ʋ", "ư", "ų", "ű", "ů", "ŭ", "ū", "ũ", "ü", "û", "ú", "ù", "µ"},
	{"t", "ţ", "ť", "ŧ", "ƚ", "ƫ", "ƭ", "ț", "ȶ", "ʈ", "τ", "ϯ", "Ե", "Է", "ե", "է", "ߙ", "ቲ", "ፕ", "Ꮏ", "ᖶ", "ᵗ", "ᵵ", "ᶵ", "ṫ", "ṭ", "ṯ", "ṱ", "ẗ", "ₜ", "ⓣ", "ⱦ", "七", "丅", "Ꚍ", "ꚍ", "ｔ", "ｲ", "ṫ", "ẗ", "ť", "ṭ", "ț", "ţ", "ṱ", "ṯ", "t͏", "𐞯", "𛐵", "𝐭", "𝑡", "𝒕", "𝓉", "𝓽", "𝔱", "𝕥", "𝖙", "𝗍", "𝘁", "𝘵", "𝙩", "𝚝", "𝛕", "𝜏", "𝝉", "𝞃", "𝞽", "𵐵", "񂐵", "񏐵", "񜐵", "񨰼", "񩐵", "񶐵", "򃐵", "򐐵", "򝐵", "򪐵", "򷐵"},
	{"s", "ṩ", "ṧ", "ṥ", "𞁩", "𝚜", "𝙨", "𝘴", "𝘀", "𝗌", "𝖘", "𝕤", "𝔰", "𝓼", "𝓈", "𝒔", "𝑠", "𝐬", "𐑈", "ẛ", "ş", "ș", "ṣ", "š", "ṡ", "ŝ", "ś", "ｓ", "ﻛ", "ﮑ", "ﮐ", "ꞩ", "ꚃ", "ꙅ", "ꗟ", "ꕷ", "ꕶ", "丂", "⳽", "⟆", "ⓢ", "ₛ", "ẛ", "ṩ", "ṧ", "ṥ", "ṣ", "ṡ", "ᶳ", "ᶊ", "ᣵ", "ᔕ", "ነ", "ຮ", "ຣ", "ร", "ઽ", "ડ", "ક", "ऽ", "ی", "ي", "ى", "ѕ", "ϩ", "ˢ", "ʂ", "ȿ", "ș", "ƨ", "ſ", "š", "ş", "ŝ", "ś"},
	{"r", "ṝ", "򶰵", "򩰵", "򜰵", "򏰵", "򂰵", "񵰵", "񨰵", "񨐼", "񛰵", "񎰵", "񁰵", "𴰵", "𝼈", "𝚛", "𝙧", "𝘳", "𝗿", "𝗋", "𝖗", "𝕣", "𝔯", "𝓻", "𝓇", "𝒓", "𝑟", "𝐫", "𚰵", "𐞩", "𐞨", "𐞧", "𐞦", "r͏", "ṟ", "ŗ", "ṛ", "ȓ", "ȑ", "ř", "ṙ", "ŕ", "ｒ", "ꞧ", "ꞅ", "Ꞅ", "ꞃ", "꜒", "尺", "⸢", "⸀", "ⲅ", "Ⲅ", "┏", "┎", "┍", "┌", "ⓡ", "ṟ", "ṝ", "ṛ", "ṙ", "ᶉ", "ᵲ", "ᵣ", "ᣴ", "ᣘ", "Ꮧ", "ዪ", "ཞ", "୮", "۲", "ր", "ͬ", "ʵ", "ʴ", "ʳ", "ɾ", "ɽ", "ɼ", "ɻ", "ɺ", "ɹ", "ɍ", "ȓ", "ȑ", "ř", "ŗ", "ŕ"},
	{"q", "Ɋ", "ɋ", "ԛ", "զ", "٩", "۹", "৭", "੧", "૧", "๑", "ዒ", "ᕴ", "ᶐ", "ⓠ", "ꘫ", "ꝗ", "ꝙ", "ｑ", "𐞥", "𝐪", "𝑞", "𝒒", "𝓆", "𝓺", "𝔮", "𝕢", "𝖖", "𝗊", "𝗾", "𝘲", "𝙦", "𝚚"},
	{"p", "򶐵", "򩐵", "򜐵", "򏐵", "򂐵", "񵐵", "񨐵", "񧰼", "񛐵", "񎐵", "񁐵", "𴐵", "𝟈", "𝞺", "𝞎", "𝞀", "𝝔", "𝝆", "𝜚", "𝜌", "𝛠", "𝛒", "𝚙", "𝙥", "𝘱", "𝗽", "𝗉", "𝖕", "𝕡", "𝔭", "𝓹", "𝓅", "𝒑", "𝑝", "𝐩", "𚐵", "𐓬", "ῥ", "ῤ", "p͏", "ṗ", "ṕ", "ｱ", "ｐ", "ꝭ", "Ꝭ", "ꝥ", "ꝕ", "ꝓ", "ꝑ", "卩", "ⲣ", "ⓟ", "⍴", "℘", "ₚ", "ῥ", "ῤ", "ṗ", "ṕ", "ᶈ", "ᵽ", "ᵱ", "ᵨ", "ᵖ", "ᕶ", "ᕵ", "ᒆ", "ᒅ", "ᑹ", "ᑸ", "ᑷ", "ᑶ", "ᑵ", "ᑴ", "ᑮ", "ᑭ", "ᑬ", "ᑫ", "Ꭾ", "የ", "ཥ", "ק", "ҏ", "ϼ", "ϸ", "ϱ", "ρ", "ƿ", "ƥ"},
	{"o", "⃝", "⊖", "⊘", "⊚", "⊛", "⊜", "⊝", "⊗", "⥁", "⥀", "〶", "🎯", "⨸", "⨷", "♽", "♼", "☯", "☮", "࿊", "⬤", "∅", "⧬", "⧃", "⧂", "⦽", "⦼", "⦺", "⦹", "✆", "◷", "◶", "◵", "◴", "º", "ð", "ò", "ó", "ô", "õ", "ö", "ø", "ō", "ŏ", "ő", "ơ", "ǒ", "ǫ", "ǭ", "ǿ", "ȍ", "ȏ", "ȫ", "ȭ", "ȯ", "ȱ", "ɵ", "ʘ", "ο", "σ", "ό", "ѳ", "Ѻ", "ѻ", "օ", "ס", "٥", "ܘ", "߀", "ߋ", "०", "০", "૦", "೦", "൦", "๏", "๐", "໐", "༠", "࿀", "စ", "ဓ", "ဝ", "၀", "ዐ", "ዑ", "ᓍ", "ᗝ", "ᴏ", "ᴑ", "ᵒ", "ᶞ", "ᶱ", "ᶿ", "ṍ", "ṏ", "ṑ", "ṓ", "ọ", "ỏ", "ố", "ồ", "ổ", "ỗ", "ộ", "ớ", "ờ", "ở", "ỡ", "ợ", "ὀ", "ὁ", "ὂ", "ὃ", "ὄ", "ὅ", "ὸ", "ό", "ₒ", "ℴ", "⊕", "⊙", "ⓞ", "◯", "☉", "⚈", "⚉", "⚬", "❍", "○", "◍", "◐", "◑", "◒", "◓", "◔", "◕", "⭕", "⭘", "ⲑ", "ⲟ", "ⴰ", "ⵀ", "ⵙ", "〇", "ㄖ", "ㅇ", "ㆁ", "ꙩ", "ꙫ", "ꝋ", "ꝍ", "ｏ", "ò", "ó", "ô", "õ", "ō", "ŏ", "ȯ", "ö", "ỏ", "ő", "ǒ", "ȍ", "ȏ", "ơ", "ọ", "ǫ", "ǿ", "ὸ", "ό", "ὀ", "ὁ", "𐞢", "𐞵", "𝐨", "𝑜", "𝒐", "𝓸", "𝔬", "𝕠", "𝖔", "𝗈", "𝗼", "𝘰", "𝙤", "𝚘", "𝛉", "𝛐", "𝛔", "𝜃", "𝜊", "𝜎", "𝜽", "𝝄", "𝝈", "𝝑", "𝝷", "𝝾", "𝞂", "𝞱", "𝞸", "𝞼", "𝟅", "ồ", "ố", "ỗ", "ổ", "ṍ", "ȭ", "ṏ", "ṑ", "ṓ", "ȱ", "ȫ", "ờ", "ớ", "ỡ", "ở", "ợ", "ộ", "ǭ", "ὂ", "ὄ", "ὃ", "ὅ"},
	{"n", "ᾗ", "ᾕ", "ᾓ", "ᾖ", "ᾔ", "ᾒ", "ῇ", "ᾑ", "ἧ", "ἥ", "ἣ", "ᾐ", "ἦ", "ἤ", "ἢ", "ῄ", "ῂ", "򵰵", "򨰵", "򛰵", "򎰵", "򁰵", "񴰵", "񧰵", "񧐼", "񚰵", "񍰵", "񀰵", "𳰵", "𝞰", "𝝶", "𝜼", "𝜂", "𝛈", "𝚗", "𝙣", "𝘯", "𝗻", "𝗇", "𝖞", "𝖓", "𝕟", "𝔶", "𝔫", "𝓷", "𝓃", "𝒏", "𝑛", "𝐧", "𙰵", "𐒐", "𐍀", "𐌿", "ῃ", "ῆ", "ἡ", "ἠ", "ή", "ὴ", "ʼn", "n͏", "ṉ", "ṋ", "ņ", "ṇ", "ň", "ṅ", "ñ", "ń", "ǹ", "ｎ", "תּ", "ﬨ", "ꞥ", "ꞑ", "Ꞃ", "ꝴ", "刀", "几", "Ⲡ", "ⓝ", "⋂", "∩", "∏", "ₙ", "ⁿ", "ῇ", "ῆ", "ῄ", "ῃ", "ῂ", "ᾗ", "ᾖ", "ᾕ", "ᾔ", "ᾓ", "ᾒ", "ᾑ", "ᾐ", "ή", "ὴ", "ἧ", "ἦ", "ἥ", "ἤ", "ἣ", "ἢ", "ἡ", "ἠ", "ṋ", "ṉ", "ṇ", "ṅ", "ᶯ", "ᶮ", "ᶇ", "ᵰ", "ᵑ", "ᴨ", "ᴎ", "ᥰ", "ᥥ", "ᥒ", "ᘉ", "ᑏ", "ᑎ", "ክ", "ቢ", "ቡ", "በ", "ი", "ຖ", "ກ", "ภ", "ก", "ת", "ח", "ս", "ռ", "ո", "ղ", "դ", "ԥ", "ԉ", "Ԉ", "ҋ", "η", "ή", "ͷ", "ɳ", "ɲ", "Ƞ", "ǹ", "ƞ", "ŋ", "ŉ", "ň", "ņ", "ń", "ñ"},
	{"m", "ɱ", "ʍ", "ͫ", "ന", "൩", "ෆ", "๓", "ო", "ጠ", "ጡ", "ጢ", "ጣ", "ጦ", "ᗶ", "ᘻ", "ᙢ", "ᵐ", "ᵯ", "ᶆ", "ᶬ", "ḿ", "ṁ", "ṃ", "ₘ", "₥", "ⅿ", "ⓜ", "♏", "⩋", "⫙", "爪", "ꝳ", "ꭩ", "ｍ", "ﾶ", "ḿ", "ṁ", "ṃ", "𝐦", "𝑚", "𝒎", "𝓂", "𝓶", "𝔪", "𝕞", "𝖒", "𝗆", "𝗺", "𝘮", "𝙢", "𝚖"},
	{"l", "ḹ", "򵐵", "򨐵", "򛐵", "򎐵", "򁐵", "񴐵", "񧐵", "񦰼", "񚐵", "񍐵", "񀐵", "𳐵", "𝞲", "𝝸", "𝜾", "𝜄", "𝛊", "𝚕", "𝙡", "𝘭", "𝗹", "𝗅", "𝖑", "𝕝", "𝔩", "𝓵", "𝓁", "𝒍", "𝑙", "𝐥", "𝍩", "𙐵", "𐞝", "𐞛", "l͏", "ḻ", "ḽ", "ļ", "ḷ", "ľ", "ĺ", "l·", "ﾚ", "ｌ", "ﺎ", "ﺍ", "ꭞ", "ꭝ", "ꬷ", "ꞎ", "ꝲ", "ꝉ", "ꝇ", "꜖", "乚", "丨", "ㅣ", "ㄴ", "ㄥ", "⸤", "❘", "╿", "╵", "╙", "┕", "└", "┃", "ⓛ", "⎩", "⎣", "⎟", "⎝", "⍳", "⌊", "ⅼ", "ℓ", "ₗ", "ι", "ḽ", "ḻ", "ḹ", "ḷ", "ᶪ", "ᶩ", "ᶥ", "ᶅ", "ᥨ", "ᥣ", "ረ", "ไ", "เ", "ட", "৷", "١", "ן", "׀", "Ӏ", "ι", "ˡ", "ʅ", "ɭ", "ɬ", "ɫ", "ɩ", "Ɩ", "ł", "ŀ", "ľ", "ļ", "ĺ"},
	{"k", "ķ", "ĸ", "ƙ", "ǩ", "ʞ", "κ", "ϰ", "қ", "ҝ", "ҟ", "ҡ", "ӄ", "ԟ", "ጕ", "ᵏ", "ᶄ", "ḱ", "ḳ", "ḵ", "ₖ", "ⓚ", "ⱪ", "ⲕ", "ⳤ", "ズ", "ꗪ", "ꝁ", "ꝃ", "Ꝅ", "ꝅ", "ꞣ", "ｋ", "ḱ", "ǩ", "ḳ", "ķ", "ḵ", "ᖽᐸ", "𐓤", "𐓥", "𐓦", "𝐤", "𝑘", "𝒌", "𝓀", "𝓴", "𝔨", "𝕜", "𝖐", "𝗄", "𝗸", "𝘬", "𝙠", "𝚔", "𝛋", "𝛞", "𝜅", "𝜘", "𝜿", "𝝒", "𝝹", "𝞌", "𝞳", "𝟆"},
	{"j", "򴰵", "򧰵", "򚰵", "򍰵", "򀰵", "񳰵", "񦰵", "񦐼", "񙰵", "񌰵", "𿰵", "𲰵", "𞁍", "𝚥", "𝚓", "𝙟", "𝘫", "𝗷", "𝗃", "𝖏", "𝕛", "𝔧", "𝓳", "𝒿", "𝒋", "𝑗", "𝐣", "𘰵", "𐞘", "j͏", "ǰ", "ĵ", "ﾌ", "ｊ", "ﻧ", "ﻟ", "ﻞ", "ﻝ", "ﮌ", "ⱼ", "ⓙ", "⎭", "⌡", "ⅉ", "ᶨ", "ᶡ", "ጋ", "၂", "ว", "ݬ", "ۯ", "ڶ", "ڵ", "ژ", "ڒ", "ڑ", "ل", "ز", "ذ", "נ", "ј", "ϳ", "ʲ", "ʝ", "ʄ", "ɟ", "ɉ", "ȷ", "ǰ", "ĵ"},
	{"i", "ἷ", "ἵ", "ἳ", "ἶ", "ἴ", "ἲ", "ῗ", "ΐ", "ῒ", "ḯ", "𞁨", "𞁐", "𞁌", "𝚤", "𝚒", "𝙞", "𝘪", "𝗶", "𝗂", "𝖎", "𝕚", "𝔦", "𝓲", "𝒾", "𝒊", "𝑖", "𝐢", "ї", "ῖ", "ἱ", "ἰ", "ϊ", "ῐ", "ῑ", "ί", "ḭ", "į", "ị", "ȋ", "ȉ", "ǐ", "ỉ", "ï", "ĭ", "ī", "ĩ", "î", "í", "ì", "ｉ", "ﺄ", "ﺃ", "ﺂ", "וֹ", "ꜟ", "ꜞ", "讠", "ⲓ", "ⓘ", "ⅰ", "ⅈ", "ℹ", "ⁱ", "ῗ", "ῖ", "ΐ", "ῒ", "ῑ", "ῐ", "ί", "ὶ", "ἷ", "ἶ", "ἵ", "ἴ", "ἳ", "ἲ", "ἱ", "ἰ", "ị", "ỉ", "ḯ", "ḭ", "ᶤ", "ᶖ", "ᵢ", "ᵎ", "ᴉ", "ᓰ", "Ꭵ", "ጎ", "༏", "أ", "ӏ", "ї", "і", "ϊ", "ί", "ΐ", "ɨ", "ȋ", "ȉ", "ǐ", "ı", "į", "ĭ", "ī", "ĩ", "ï", "î", "í", "ì"},
	{"h", "ĥ", "ħ", "ƕ", "ȟ", "ɥ", "ɦ", "ɧ", "ʰ", "ʱ", "ͪ", "ђ", "ћ", "Һ", "һ", "Ԧ", "ԧ", "Կ", "ի", "կ", "հ", "୳", "Ⴌ", "Ⴏ", "ዘ", "Ꮒ", "Ꮵ", "ᑋ", "ᕼ", "ᶣ", "ḣ", "ḥ", "ḧ", "ḩ", "ḫ", "ẖ", "ₕ", "ℎ", "ℏ", "ⓗ", "♄", "ⱨ", "ん", "卄", "ꜧ", "ꞕ", "ꭜ", "ｈ", "ĥ", "ḣ", "ḧ", "ȟ", "ḥ", "ḩ", "ḫ", "ẖ", "h͏", "𐌷", "𐞕", "𐞗", "𘐵", "𝐡", "𝒉", "𝒽", "𝓱", "𝔥", "𝕙", "𝖍", "𝗁", "𝗵", "𝘩", "𝙝", "𝚑", "𲐵", "𿐵", "񌐵", "񙐵", "񥰼", "񦐵", "񳐵", "򀐵", "򍐵", "򚐵", "򧐵", "򴐵"},
	{"g", "𝚐", "𝙜", "𝘨", "𝗴", "𝗀", "𝖌", "𝕘", "𝔤", "𝓰", "𝒈", "𝑔", "𝐠", "𐞓", "ģ", "ǧ", "ġ", "ğ", "ḡ", "ĝ", "ǵ", "ｇ", "ﻮ", "Ɡ", "ꞡ", "Ꝯ", "ⓖ", "ℊ", "ḡ", "ᶢ", "ᶃ", "ᵍ", "ᘜ", "ኗ", "გ", "ဌ", "ງ", "ق", "ց", "Ց", "ϭ", "Ϭ", "ɡ", "ɠ", "ǵ", "ǧ", "ǥ", "ƃ", "ģ", "ġ", "ğ", "ĝ"},
	{"f", "ƒ", "ʇ", "ϝ", "ғ", "ӻ", "բ", "ቻ", "ᖴ", "ᵮ", "ᵳ", "ᶂ", "ᶠ", "ḟ", "ẜ", "ẝ", "ⓕ", "⨍", "⨎", "⨏", "千", "ꝼ", "ꞙ", "ｆ", "ｷ", "ḟ", "f͏", "𗰵", "𝐟", "𝑓", "𝒇", "𝒻", "𝓯", "𝔣", "𝕗", "𝖋", "𝖿", "𝗳", "𝘧", "𝙛", "𝚏", "𝟋", "🝡", "𱰵", "𾰵", "񋰵", "񘰵", "񥐼", "񥰵", "񲰵", "񿰵", "򌰵", "򙰵", "򦰵", "򳰵"},
	{"e", "ἕ", "ἓ", "ἔ", "ἒ", "ḝ", "ệ", "ḗ", "ḕ", "ể", "ễ", "ế", "ề", "𝟄", "𝞷", "𝞮", "𝞊", "𝝽", "𝝴", "𝝐", "𝝃", "𝜺", "𝜖", "𝜉", "𝜀", "𝛜", "𝛏", "𝛆", "𝚎", "𝙚", "𝘦", "𝗲", "𝖾", "𝖊", "𝕖", "𝔢", "𝓮", "𝒆", "𝑒", "𝐞", "𐞏", "𐞎", "ἑ", "ἐ", "έ", "ὲ", "ḛ", "ḙ", "ę", "ȩ", "ẹ", "ȇ", "ȅ", "ě", "ẻ", "ë", "ė", "ĕ", "ē", "ẽ", "ê", "é", "è", "ｅ", "巳", "已", "乇", "ⓔ", "ⅇ", "ℯ", "℮", "€", "ₔ", "ₑ", "έ", "ὲ", "ἕ", "ἔ", "ἓ", "ἒ", "ἑ", "ἐ", "ệ", "ễ", "ể", "ề", "ế", "ẽ", "ẻ", "ẹ", "ḝ", "ḛ", "ḙ", "ḗ", "ḕ", "ᶟ", "ᶒ", "ᵌ", "ᵋ", "ᵊ", "ᵉ", "ᥱ", "ᘿ", "ᗴ", "ᕪ", "ᕦ", "ቿ", "ല", "ల", "Ә", "ҿ", "Ҿ", "ҽ", "Ҽ", "є", "ϵ", "ξ", "ε", "έ", "ɞ", "ɜ", "ɛ", "ə", "ɘ", "ɇ", "ȩ", "ȇ", "ȅ", "ǝ", "Ə", "ě", "ę", "ė", "ĕ", "ē", "ë", "ê", "é", "è"},
	{"d", "򳐵", "򦐵", "򙐵", "򌐵", "񿐵", "񲐵", "񥐵", "񤰼", "񘐵", "񋐵", "𾐵", "𱐵", "𝟃", "𝞭", "𝞉", "𝝳", "𝝏", "𝜹", "𝜕", "𝛿", "𝛛", "𝛅", "𝚍", "𝙙", "𝘥", "𝗱", "𝖽", "𝖉", "𝕕", "𝔡", "𝓭", "𝒹", "𝒅", "𝑑", "𝐝", "𗐵", "𐞍", "𐞌", "𐞋", "d͏", "ḏ", "ḓ", "ḑ", "ḍ", "ď", "ḋ", "ｄ", "ꝱ", "ⓓ", "∂", "ⅾ", "ⅆ", "ḓ", "ḑ", "ḏ", "ḍ", "ḋ", "ᶑ", "ᶁ", "ᵭ", "ᵟ", "ᵈ", "ᕷ", "ᕲ", "ᒇ", "ᒄ", "ᑽ", "ᑼ", "ᑻ", "ᑺ", "ᑱ", "ᑰ", "ᑯ", "Ꮷ", "ዕ", "ძ", "໓", "๔", "ժ", "Ժ", "ԃ", "Ԃ", "ԁ", "Ԁ", "δ", "ͩ", "ɗ", "ɖ", "ȡ", "đ", "ď"},
	{"c", "¢", "ç", "ć", "ĉ", "ċ", "č", "ƈ", "ȼ", "ɔ", "ɕ", "ͨ", "ͻ", "ͼ", "ͽ", "ς", "ϛ", "ϲ", "ҁ", "८", "င", "၁", "ር", "ᥴ", "ᴄ", "ᴐ", "ᵓ", "ᶜ", "ᶝ", "ḉ", "ⅽ", "ↄ", "ⓒ", "ⲥ", "⸦", "ㄷ", "匚", "꜀", "ꜿ", "ꞓ", "ꞔ", "ｃ", "￠", "ć", "ĉ", "ċ", "č", "ç", "𐑋", "𐑮", "𝐜", "𝑐", "𝒄", "𝒸", "𝓬", "𝔠", "𝕔", "𝖈", "𝖼", "𝗰", "𝘤", "𝙘", "𝚌", "𝛓", "𝜍", "𝝇", "𝞁", "𝞻", "ḉ", "𝄴", "𝄵"},
	{"b", "򲰵", "򥰵", "򘰵", "򋰵", "񾰵", "񱰵", "񤰵", "񤐼", "񗰵", "񊰵", "𽰵", "𰰵", "𝼅", "𝞫", "𝝱", "𝜷", "𝛽", "𝛃", "𝚋", "𝙗", "𝘣", "𝗯", "𝖻", "𝖇", "𝕓", "𝔟", "𝓫", "𝒷", "𝒃", "𝑏", "𝐛", "𖰵", "𐞟", "𐞞", "𐞅", "𐌜", "b͏", "ḇ", "ḅ", "ḃ", "ｂ", "ꞗ", "ꝧ", "Ꙏ", "乃", "ⱃ", "Ⱃ", "♭", "ⓑ", "␢", "ḇ", "ḅ", "ḃ", "ᶀ", "ᵬ", "ᵦ", "ᵝ", "ᵇ", "ᖯ", "ᕹ", "ᒈ", "ᒃ", "ᒂ", "ᒁ", "ᒀ", "ᑿ", "ᑾ", "ᑳ", "ᑲ", "Ꮟ", "ጌ", "ხ", "ც", "Ⴊ", "Ⴆ", "๖", "๒", "ߕ", "ҍ", "Ҍ", "Ϧ", "ɮ", "ɓ", "ƅ", "Ƅ", "ƀ", "þ"},
	{"a", "ª", "­", "à", "á", "â", "ã", "ä", "å", "ā", "ă", "ą", "Ƌ", "ƌ", "ǎ", "ǟ", "ǡ", "ǻ", "ȁ", "ȃ", "ȧ", "ɐ", "ɑ", "ɒ", "ͣ", "ά", "α", "ߥ", "ค", "ล", "ລ", "შ", "ል", "ᥑ", "ᥲ", "ᵃ", "ᵄ", "ᵅ", "ᶏ", "ᶛ", "ḁ", "ẚ", "ạ", "ả", "ấ", "ầ", "ẩ", "ẫ", "ậ", "ắ", "ằ", "ẳ", "ẵ", "ặ", "ἀ", "ἁ", "ἂ", "ἃ", "ἄ", "ἅ", "ἆ", "ἇ", "ὰ", "ά", "ᾀ", "ᾁ", "ᾂ", "ᾃ", "ᾄ", "ᾅ", "ᾆ", "ᾇ", "ᾰ", "ᾱ", "ᾲ", "ᾳ", "ᾴ", "ᾶ", "ᾷ", "ₐ", "⍺", "ⓐ", "ⱥ", "Ⲁ", "ⲁ", "卂", "ａ", "ﾑ", "aʾ", "à", "á", "â", "ã", "ā", "ă", "ȧ", "ä", "ả", "å", "ǎ", "ȁ", "ȃ", "ạ", "ḁ", "ą", "ὰ", "ά", "ᾱ", "ᾰ", "ἀ", "ἁ", "ᾶ", "ᾳ", "𐐟", "𝐚", "𝑎", "𝒂", "𝒶", "𝓪", "𝔞", "𝕒", "𝖆", "𝖺", "𝗮", "𝘢", "𝙖", "𝚊", "𝛂", "𝛼", "𝜶", "𝝰", "𝞪", "ầ", "ấ", "ẫ", "ẩ", "ằ", "ắ", "ẵ", "ẳ", "ǡ", "ǟ", "ǻ", "ậ", "ặ", "ᾲ", "ᾴ", "ἂ", "ἄ", "ἆ", "ᾀ", "ἃ", "ἅ", "ἇ", "ᾁ", "ᾷ", "ᾂ", "ᾄ", "ᾆ", "ᾃ", "ᾅ", "ᾇ"},
	{"_", "␣", " ̳", "＿", "﹣", "﹏", "﹎", "﹍", "₋", "‗", "ˍ"},
	{"^", "＾", "𝅈", "𝅈", "⌃", "ˆ", "̑", "̭", "˄", "˰"},
	{"]", "༽", "⟧", "︼", "﹂", "﹄", "❳", "︘", "﹈"},
	{"] ", "」", "』", "】", "〗", "〙", "〛", "］"},
	{"[", "༼", "⟦", "︻", "﹁", "﹃", "❲", "︗", "﹇", "𝄕"},
	{" [", "「", "『", "【", "〖", "〘", "〚", "［"},
	{"Z", "򲐵", "򥐵", "򘐵", "򋐵", "񾐵", "񱐵", "񊐵", "𽐵", "𰐵", "🇿", "🆉", "🅩", "🅉", "𝞕", "𝝛", "𝜡", "𝛧", "𝚭", "𝚉", "𝙕", "𝘡", "𝗭", "𝖹", "𝓩", "𝒵", "𝒁", "𝑍", "𝐙", "𖐵", "𐌶", "Ẕ", "Ẓ", "Ž", "Ż", "Ẑ", "Ź", "Ｚ", "Ꙃ", "Ꙁ", "ꓜ", "Ⲍ", "Ɀ", "Ⱬ", "Ⓩ", "ℨ", "ℤ", "Ẕ", "Ẓ", "Ẑ", "Ꮓ", "Ζ", "Ȥ", "Ƶ", "Ž", "Ż", "Ź"},
	{"Y", "Ὗ", "Ὕ", "Ὓ", "🇾", "🆈", "🅨", "🅈", "𝞤", "𝝪", "𝜰", "𝛶", "𝚼", "𝚈", "𝙔", "𝘠", "𝗬", "𝖸", "𝖄", "𝕐", "𝔜", "𝓨", "𝒴", "𝒀", "𝑌", "𝐘", "𑀢", "𐞲", "𐒅", "𐍅", "𐌖", "𐊲", "ϔ", "ϓ", "Ὑ", "Ϋ", "Ῠ", "Ῡ", "Ύ", "Ὺ", "Ỵ", "Ỷ", "Ÿ", "Ẏ", "Ȳ", "Ỹ", "Ŷ", "Ý", "Ỳ", "￥", "Ｙ", "ꝩ", "Ꝩ", "ꓬ", "Ⲩ", "Ⓨ", "⅄", "Ύ", "Ὺ", "Ῡ", "Ῠ", "Ὗ", "Ὕ", "Ὓ", "Ὑ", "Ỿ", "Ỹ", "Ỷ", "Ỵ", "Ỳ", "Ẏ", "ᏺ", "Ᏺ", "Ꮍ", "Ꭹ", "Ұ", "Ү", "ϔ", "ϓ", "ϒ", "Ϋ", "Υ", "Ύ", "ʏ", "Ɏ", "Ȳ", "Ƴ", "Ÿ", "Ŷ", "Ý", "¥"},
	{"X", "Χ", "Ҳ", "Ӽ", "ᕽ", "᙭", "ᚷ", "Ẋ", "Ẍ", "Ⅹ", "Ⓧ", "⤧", "⤨", "⤩", "⤪", "⤭", "⤮", "⤯", "⤰", "⤱", "⤲", "Ⲭ", "ⵝ", "ꓫ", "Ꭓ", "Ｘ", "Ẋ", "Ẍ", "𐊐", "𐊴", "𐌗", "𐌢", "𐍇", "𑀋", "𑀌", "𕰵", "𝐗", "𝑋", "𝑿", "𝒳", "𝓧", "𝔛", "𝕏", "𝖃", "𝖷", "𝗫", "𝘟", "𝙓", "𝚇", "𝚾", "𝛸", "𝜲", "𝝬", "𝞦", "🅇", "🅧", "🆇", "🇽", "𯰵", "𼰵", "񉰵", "񖰵", "񣰵", "񰰵", "񽰵", "򊰵", "򗰵", "򤰵", "򱰵"},
	{"W", "🇼", "🆆", "🅦", "🅆", "𝞧", "𝝭", "𝜳", "𝛹", "𝚿", "𝚆", "𝙒", "𝘞", "𝗪", "𝖶", "𝖂", "𝕎", "𝔚", "𝓦", "𝒲", "𝑾", "𝑊", "𝐖", "𐐎", "Ẉ", "Ẅ", "Ẇ", "Ŵ", "Ẃ", "Ẁ", "￦", "Ｗ", "Ꞷ", "Ꝡ", "ꓪ", "Ⱳ", "Ⓦ", "₩", "Ẉ", "Ẇ", "Ẅ", "Ẃ", "Ẁ", "ᵂ", "ᴡ", "ᗯ", "Ꮤ", "Ꮃ", "Ԝ", "Ψ", "Ŵ"},
	{"V", "Ʌ", "Ѵ", "Ѷ", "Ꮩ", "Ꮴ", "Ṽ", "Ṿ", "Ⅴ", "∇", "Ⓥ", "ⱽ", "ꓥ", "ꓦ", "Ｖ", "Ṽ", "Ṿ", "Ѷ", "𕐵", "𝐕", "𝑉", "𝑽", "𝒱", "𝓥", "𝔙", "𝕍", "𝖁", "𝖵", "𝗩", "𝘝", "𝙑", "𝚅", "𝛁", "𝛻", "𝜵", "𝝯", "𝞩", "🅅", "🅥", "🆅", "🇻", "𯐵", "𼐵", "񉐵", "񖐵", "񣐵", "񰐵", "񽐵", "򊐵", "򗐵", "򤐵", "򱐵"},
	{"U", "Ự", "Ử", "Ữ", "Ứ", "Ừ", "Ǚ", "Ǖ", "Ǘ", "Ǜ", "Ṻ", "Ṹ", "🇺", "🆄", "🅤", "🅄", "𝚄", "𝙐", "𝘜", "𝗨", "𝖴", "𝖀", "𝕌", "𝔘", "𝓤", "𝒰", "𝑼", "𝑈", "𝐔", "𐓶", "𐓎", "𐒩", "𐌵", "Ṵ", "Ṷ", "Ų", "Ṳ", "Ụ", "Ư", "Ȗ", "Ȕ", "Ǔ", "Ű", "Ů", "Ủ", "Ü", "Ŭ", "Ū", "Ũ", "Û", "Ú", "Ù", "Ｕ", "ꓵ", "ꓴ", "Ⓤ", "Ự", "Ữ", "Ử", "Ừ", "Ứ", "Ủ", "Ụ", "Ṻ", "Ṹ", "Ṷ", "Ṵ", "Ṳ", "ᶸ", "ᵁ", "ᴜ", "ᑨ", "ᑧ", "ᑜ", "ᑛ", "ᑚ", "ᑙ", "ᑘ", "ᑗ", "Ꮑ", "Ⴖ", "Ⴎ", "Ս", "Ռ", "Ո", "Մ", "Ա", "Ʉ", "Ȗ", "Ȕ", "Ǜ", "Ǚ", "Ǘ", "Ǖ", "Ǔ", "Ư", "Ų", "Ű", "Ů", "Ŭ", "Ū", "Ũ", "Ü", "Û", "Ú", "Ù"},
	{"T", "򰰵", "򣰵", "򖰵", "򉰵", "񼰵", "񯰵", "񢰵", "񕰵", "񈰵", "𻰵", "𮰵", "🇹", "🆃", "🅣", "🅃", "𝞣", "𝝩", "𝜯", "𝛵", "𝚻", "𝚃", "𝙏", "𝘛", "𝗧", "𝖳", "𝕿", "𝕋", "𝔗", "𝓣", "𝒯", "𝑻", "𝑇", "𝐓", "𔰵", "𑀦", "𐍄", "𐌕", "𐊱", "𐊗", "Ṯ", "Ṱ", "Ţ", "Ț", "Ṭ", "Ť", "Ṫ", "Ｔ", "Ʇ", "ꚑ", "Ꚑ", "ꓕ", "ꓔ", "ⲧ", "Ⲧ", "Ⓣ", "⊥", "₸", "₮", "Ṱ", "Ṯ", "Ṭ", "Ṫ", "ᵀ", "ᴛ", "Ꭲ", "ҭ", "Ҭ", "Τ", "ͳ", "Ͳ", "Ⱦ", "Ț", "Ʈ", "Ƭ", "Ŧ", "Ť", "Ţ"},
	{"S", "Ś", "Ŝ", "Ş", "Š", "Ƨ", "Ș", "Ϩ", "Ѕ", "Տ", "ಽ", "ട", "Ⴝ", "Ⴧ", "Ꭶ", "Ꮥ", "Ꮪ", "ᔆ", "Ჷ", "Ჽ", "Ṡ", "Ṣ", "Ṥ", "Ṧ", "Ṩ", "₴", "Ⓢ", "Ȿ", "ⴧ", "ꓢ", "Ꙅ", "Ꚃ", "ꜱ", "Ꞩ", "꠹", "Ｓ", "Ś", "Ŝ", "Ṡ", "Š", "Ṣ", "Ș", "Ş", "𐊖", "𐌔", "𐍃", "𐐠", "𐑕", "𐒒", "𐒖", "𐒡", "𑀍", "𝐒", "𝑆", "𝑺", "𝒮", "𝓢", "𝔖", "𝕊", "𝕾", "𝖲", "𝗦", "𝘚", "𝙎", "𝚂", "🅂", "🅢", "🆂", "🇸", "Ṥ", "Ṧ", "Ṩ"},
	{"R", "Ṝ", "򰐵", "򣐵", "򖐵", "򉐵", "񼐵", "񯐵", "񈐵", "𮐵", "𡐵", "🇷", "🆁", "🅡", "🅁", "🄬", "𝚁", "𝙍", "𝘙", "𝗥", "𝖱", "𝕽", "𝓡", "𝑹", "𝑅", "𝐑", "𔐵", "𐞪", "𐍂", "𐌺", "𐊯", "Ṟ", "Ŗ", "Ṛ", "Ȓ", "Ȑ", "Ř", "Ṙ", "Ŕ", "Ｒ", "Ꞧ", "ꞟ", "Ꞟ", "ꝶ", "ꓤ", "ꓣ", "Ɽ", "Ⓡ", "℟", "ℝ", "ℜ", "ℛ", "Ṟ", "Ṝ", "Ṛ", "Ṙ", "ᴿ", "ᴚ", "ᴙ", "ᖉ", "ᖈ", "ᖇ", "ᖆ", "Ꮢ", "Ꭱ", "ʶ", "ʁ", "ʀ", "Ɍ", "Ȓ", "Ȑ", "Ʀ", "Ř", "Ŗ", "Ŕ"},
	{"Q", "Ϙ", "ϙ", "Ԛ", "Ⴍ", "Ⴓ", "ℚ", "Ⓠ", "Ꝗ", "Ꝙ", "Ꝺ", "ꟴ", "Ｑ", "𐊭", "𐌒", "𝐐", "𝑄", "𝑸", "𝒬", "𝓠", "𝔔", "𝕼", "𝖰", "𝗤", "𝘘", "𝙌", "𝚀", "🅀", "🅠", "🆀", "🇶"},
	{"P", "򯰵", "򢰵", "򕰵", "򈰵", "񻰵", "񮰵", "񔰵", "񇰵", "𺰵", "𭰵", "🇵", "🅿", "🅟", "🄿", "𝞠", "𝝦", "𝜬", "𝛲", "𝚸", "𝙿", "𝙋", "𝘗", "𝗣", "𝖯", "𝕻", "𝔓", "𝓟", "𝒫", "𝑷", "𝑃", "𝐏", "𓰵", "𑀘", "𐐙", "𐌛", "𐌓", "𐊕", "Ῥ", "Ṗ", "Ṕ", "Ｐ", "ꟼ", "Ꝧ", "Ꝥ", "Ꝕ", "Ꝓ", "Ꝑ", "ꓒ", "ꓑ", "Ⳁ", "Ⲣ", "Ᵽ", "Ⓟ", "ℙ", "℗", "₱", "Ῥ", "Ṗ", "Ṕ", "ᴾ", "ᴩ", "ᴘ", "Ꮲ", "Ҏ", "Ρ", "Ƿ", "Ƥ"},
	{"O", "ᾯ", "ᾭ", "ᾫ", "ᾮ", "ᾬ", "ᾪ", "ᾩ", "Ὧ", "Ὥ", "Ὣ", "ᾨ", "Ὦ", "Ὤ", "Ὢ", "Ὅ", "Ὃ", "Ὄ", "Ὂ", "Ǭ", "Ộ", "Ợ", "Ở", "Ỡ", "Ớ", "Ờ", "Ȫ", "Ȱ", "Ṓ", "Ṑ", "Ṏ", "Ȭ", "Ṍ", "Ổ", "Ỗ", "Ố", "Ồ", "🇴", "🅾", "🅞", "🄾", "𝞨", "𝞡", "𝞞", "𝞗", "𝞋", "𝝮", "𝝧", "𝝤", "𝝝", "𝜴", "𝜭", "𝜪", "𝜣", "𝜗", "𝛺", "𝛳", "𝛰", "𝛩", "𝛝", "𝛀", "𝚹", "𝚶", "𝚯", "𝙾", "𝙊", "𝘖", "𝗢", "𝖮", "𝕺", "𝕆", "𝔒", "𝓞", "𝒪", "𝑶", "𝑂", "𝐎", "𑀣", "𑀞", "𐓫", "𐓪", "𐓃", "𐓂", "𐒠", "𐒆", "𐑴", "𐐬", "𐐄", "𐍈", "𐌏", "𐌈", "𐊸", "𐊫", "𐊨", "𐊒", "ῼ", "Ὡ", "Ὠ", "Ώ", "Ὼ", "Ὁ", "Ὀ", "Ό", "Ὸ", "Ǿ", "Ǫ", "Ọ", "Ơ", "Ȏ", "Ȍ", "Ǒ", "Ő", "Ỏ", "Ö", "Ȯ", "Ŏ", "Ō", "Õ", "Ô", "Ó", "Ò", "Ｏ", "Ꝍ", "Ꝋ", "Ꙫ", "Ꙩ", "ꓳ", "ⵔ", "Ⲟ", "Ⲑ", "Ⓞ", "Ω", "ῼ", "Ώ", "Ὼ", "Ό", "Ὸ", "ᾯ", "ᾮ", "ᾭ", "ᾬ", "ᾫ", "ᾪ", "ᾩ", "ᾨ", "Ὧ", "Ὦ", "Ὥ", "Ὤ", "Ὣ", "Ὢ", "Ὡ", "Ὠ", "Ὅ", "Ὄ", "Ὃ", "Ὂ", "Ὁ", "Ὀ", "Ợ", "Ỡ", "Ở", "Ờ", "Ớ", "Ộ", "Ỗ", "Ổ", "Ồ", "Ố", "Ỏ", "Ọ", "Ṓ", "Ṑ", "Ṏ", "Ṍ", "ᴼ", "Ჿ", "ᱛ", "᱐", "Ꮻ", "Ꮕ", "Ꮎ", "Ꭷ", "Ꭴ", "ഠ", "౦", "௦", "ଠ", "੦", "Օ", "Ө", "Ѳ", "ϴ", "ϑ", "θ", "Ω", "Ο", "Θ", "Ώ", "Ό", "Ȱ", "Ȯ", "Ȭ", "Ȫ", "Ȏ", "Ȍ", "Ǿ", "Ǭ", "Ǫ", "Ǒ", "Ơ", "Ɵ", "Ő", "Ŏ", "Ō", "Ø", "Ö", "Õ", "Ô", "Ó", "Ò"},
	{"N", "Ñ", "Ń", "Ņ", "Ň", "Ŋ", "Ɲ", "Ǹ", "ɴ", "Ͷ", "Ν", "Ҋ", "א", "ᴺ", "ᴻ", "ᶰ", "Ṅ", "Ṇ", "Ṉ", "Ṋ", "ℕ", "ℵ", "Ⓝ", "Ⲛ", "ⲛ", "ꓠ", "Ꞑ", "Ꞥ", "Ｎ", "Ǹ", "Ń", "Ñ", "Ṅ", "Ň", "Ṇ", "Ņ", "Ṋ", "Ṉ", "₦", "𐊏", "𐊪", "𐌽", "𓐵", "𝐍", "𝑁", "𝑵", "𝒩", "𝓝", "𝔑", "𝕹", "𝖭", "𝗡", "𝘕", "𝙉", "𝙽", "𝚴", "𝛮", "𝜨", "𝝢", "𝞜", "🄽", "🅝", "🅽", "🇳", "𭐵", "𺐵", "񇐵", "񔐵", "񮐵", "񻐵", "򈐵", "򕐵", "򢐵", "򯐵"},
	{"M", "🇲", "🅼", "🅜", "🄼", "𝞛", "𝝡", "𝜧", "𝛭", "𝚳", "𝙼", "𝙈", "𝘔", "𝗠", "𝖬", "𝕸", "𝕄", "𝔐", "𝓜", "𝑴", "𝑀", "𝐌", "𐒄", "𐌼", "𐌑", "𐊿", "𐊰", "𐊎", "Ṃ", "Ṁ", "Ḿ", "Ｍ", "ꟽ", "ꓟ", "ⲙ", "Ⲙ", "Ɱ", "Ⓜ", "Ⅿ", "ℳ", "Ṃ", "Ṁ", "Ḿ", "ᴹ", "ᴍ", "Ო", "ᱬ", "ᛖ", "ᙏ", "ᗰ", "Ꮇ", "ӎ", "Ӎ", "ϻ", "Ϻ", "Μ"},
	{"L", "Ĺ", "Ļ", "Ľ", "Ŀ", "Ł", "Ƚ", "ʟ", "˥", "Լ", "լ", "ւ", "Ⱡ", "Ꮁ", "Ꮮ", "ᒣ", "ᒤ", "ᒥ", "ᒦ", "ᒧ", "ᒨ", "ᒩ", "ᒪ", "ᒫ", "ᒬ", "ᒭ", "ᒮ", "ᒯ", "ᒰ", "ᒱ", "ᒲ", "ᒳ", "ᒴ", "ᒵ", "ᒶ", "ᒷ", "ᒸ", "ᒹ", "ᒺ", "ᒻ", "ᒽ", "ᴌ", "ᴦ", "ᴸ", "ᶫ", "Ḷ", "Ḹ", "Ḻ", "Ḽ", "ℒ", "⅂", "⅃", "Ⅼ", "Ⓛ", "Ⳑ", "ⳑ", "ꓡ", "ꓶ", "Ꝇ", "Ꝉ", "Ꞁ", "Ɬ", "Ｌ", "L·", "Ĺ", "Ľ", "Ḷ", "Ļ", "Ḽ", "Ḻ", "𐌋", "𐐛", "𐐹", "𐑃", "𐞜", "𑀉", "𒰵", "𝐋", "𝐿", "𝑳", "𝓛", "𝔏", "𝕃", "𝕷", "𝖫", "𝗟", "𝘓", "𝙇", "𝙻", "𝼄", "🄻", "🅛", "🅻", "🇱", "🰵", "𬰵", "񆰵", "񓰵", "񠰵", "񭰵", "񺰵", "򇰵", "򔰵", "򡰵", "򮰵", "Ḹ"},
	{"K", "🇰", "🅺", "🅚", "🄺", "𝞙", "𝝟", "𝜥", "𝛫", "𝚱", "𝙺", "𝙆", "𝘒", "𝗞", "𝖪", "𝕶", "𝕂", "𝔎", "𝓚", "𝒦", "𝑲", "𝐾", "𝐊", "𐒾", "𐒽", "𐒼", "𐌊", "𐊋", "Ḵ", "Ķ", "Ḳ", "Ǩ", "Ḱ", "Ｋ", "ﻼ", "Ʞ", "Ꞣ", "Ꝃ", "Ꝁ", "ꓘ", "ꓗ", "Ⲕ", "Ⱪ", "Ⓚ", "K", "₭", "Ḵ", "Ḳ", "Ḱ", "ᴷ", "ᴋ", "ᛕ", "Ꮶ", "Ԟ", "Ӄ", "Ҡ", "Ҟ", "Ҝ", "Қ", "Ϗ", "Κ", "Ǩ", "Ƙ", "Ķ"},
	{"J", "򮐵", "򡐵", "򔐵", "򇐵", "񺐵", "񭐵", "񠐵", "񓐵", "񆐵", "𹐵", "𬐵", "🇯", "🅹", "🅙", "🄹", "𝙹", "𝙅", "𝘑", "𝗝", "𝖩", "𝕵", "𝕁", "𝔍", "𝓙", "𝒥", "𝑱", "𝐽", "𝐉", "𒐵", "𑀨", "𑀧", "𐒗", "𐑊", "𐐻", "𐐢", "𐐓", "Ĵ", "Ｊ", "Ʝ", "ꙇ", "Ꙇ", "ꓩ", "ꓙ", "Ⓙ", "ᴶ", "ᴊ", "ᘃ", "ᘂ", "ᒢ", "ᒡ", "ᒠ", "ᒟ", "ᒞ", "ᒝ", "ᒜ", "ᒛ", "ᒚ", "ᒙ", "ᒘ", "ᒗ", "ᒖ", "ᒕ", "ᒔ", "ᒓ", "ᒒ", "ᒑ", "ᒐ", "ᒏ", "ᒎ", "ᒍ", "ᒌ", "ᒋ", "ᒊ", "ᒉ", "Ꮭ", "Ꮣ", "Ꭻ", "Ⴑ", "յ", "Ր", "Ն", "Ղ", "Ը", "Դ", "Ј", "Ϳ", "ɿ", "Ɉ", "Ĵ"},
	{"I", "Ì", "Í", "Î", "Ï", "Ĩ", "Ī", "Ĭ", "Į", "İ", "Ɨ", "Ǐ", "Ȉ", "Ȋ", "ɪ", "Ί", "Ι", "Ϊ", "І", "Ї", "ا", "౹", "Ꮖ", "ᴵ", "ᵻ", "ᶦ", "ᶧ", "Ḭ", "Ḯ", "Ỉ", "Ị", "Ἰ", "Ἱ", "Ἲ", "Ἳ", "Ἴ", "Ἵ", "Ἶ", "Ἷ", "Ῐ", "Ῑ", "Ὶ", "Ί", "ℐ", "ℑ", "Ⅰ", "∣", "Ⓘ", "Ⲓ", "ⵊ", "ⵏ", "ꓲ", "ꞁ", "Ɪ", "ꟾ", "Ｉ", "Ì", "Í", "Î", "Ĩ", "Ī", "Ĭ", "İ", "Ï", "Ỉ", "Ǐ", "Ȉ", "Ȋ", "Ị", "Į", "Ḭ", "Ὶ", "Ί", "Ῑ", "Ῐ", "Ϊ", "Ἰ", "Ἱ", "Ї", "𐊈", "𐊊", "𐊑", "𐊦", "𐌆", "𐌉", "𐌠", "𐌹", "𐒃", "𑀡", "𝐈", "𝐼", "𝑰", "𝓘", "𝕀", "𝕴", "𝖨", "𝗜", "𝘐", "𝙄", "𝙸", "𝚰", "𝛪", "𝜤", "𝝞", "𝞘", "𞸀", "🄸", "🅘", "🅸", "🇮", "Ḯ", "Ἲ", "Ἴ", "Ἶ", "Ἳ", "Ἵ", "Ἷ"},
	{"H", "ᾟ", "ᾝ", "ᾛ", "ᾞ", "ᾜ", "ᾚ", "ᾙ", "Ἧ", "Ἥ", "Ἣ", "ᾘ", "Ἦ", "Ἤ", "Ἢ", "򭰵", "򠰵", "򓰵", "򆰵", "񹰵", "񬰵", "񅰵", "𫰵", "🇭", "🅷", "🅗", "🄷", "𞰵", "𝞖", "𝝜", "𝜢", "𝛨", "𝚮", "𝙷", "𝙃", "𝘏", "𝗛", "𝖧", "𝕳", "𝓗", "𝑯", "𝐻", "𝐇", "𑰵", "𐞖", "𐒎", "𐋏", "ῌ", "Ἡ", "Ἠ", "Ή", "Ὴ", "Ḫ", "Ḩ", "Ḥ", "Ȟ", "Ḧ", "Ḣ", "Ĥ", "Ｈ", "ꟸ", "Ɦ", "Ꜧ", "ꓧ", "ⲏ", "Ⲏ", "Ⱨ", "Ⓗ", "ℍ", "ℌ", "ℋ", "₶", "ῌ", "Ή", "Ὴ", "ᾟ", "ᾞ", "ᾝ", "ᾜ", "ᾛ", "ᾚ", "ᾙ", "ᾘ", "Ἧ", "Ἦ", "Ἥ", "Ἤ", "Ἣ", "Ἢ", "Ἡ", "Ἠ", "Ḫ", "Ḩ", "Ḧ", "Ḥ", "Ḣ", "ᴴ", "ᚺ", "Ꮋ", "ԩ", "Ԩ", "ԋ", "Ԋ", "ӊ", "Ӊ", "ӈ", "Ӈ", "ҥ", "Ҥ", "ң", "Ң", "Η", "Ή", "ʜ", "Ȟ", "Ƕ", "Ħ", "Ĥ"},
	{"G", "Ĝ", "Ğ", "Ġ", "Ģ", "Ɠ", "Ǥ", "Ǧ", "Ǵ", "ɢ", "ʛ", "Ԍ", "ԍ", "Ⴚ", "Ꮆ", "Ꮐ", "Ꮹ", "Ᏻ", "Ᏽ", "ᏻ", "ᏽ", "ᴳ", "Ḡ", "₲", "⅁", "Ⓖ", "ꓖ", "ꓨ", "Ꞡ", "Ｇ", "Ǵ", "Ĝ", "Ḡ", "Ğ", "Ġ", "Ǧ", "Ģ", "𐌾", "𐞒", "𐞔", "𝐆", "𝐺", "𝑮", "𝒢", "𝓖", "𝔊", "𝔾", "𝕲", "𝖦", "𝗚", "𝘎", "𝙂", "𝙶", "🄶", "🅖", "🅶", "🇬"},
	{"F", "򭐵", "򠐵", "򓐵", "򆐵", "񹐵", "񬐵", "񟐵", "񒐵", "񅐵", "𫐵", "🇫", "🅵", "🅕", "🄵", "𞐵", "𝟊", "𝙵", "𝙁", "𝘍", "𝗙", "𝖥", "𝕱", "𝔽", "𝔉", "𝓕", "𝑭", "𝐹", "𝐅", "𑐵", "𐌅", "𐊥", "𐊇", "Ḟ", "Ｆ", "ꟻ", "ꟳ", "Ꞙ", "Ꝼ", "ꜰ", "ꓞ", "ꓝ", "⸁", "Ⓕ", "ⅎ", "Ⅎ", "ℱ", "℉", "₣", "Ḟ", "Ӻ", "Ϝ", "Ƒ"},
	{"E", "È", "É", "Ê", "Ë", "Ē", "Ĕ", "Ė", "Ę", "Ě", "Ǝ", "Ɛ", "Ȅ", "Ȇ", "Ȩ", "Ɇ", "Έ", "Ε", "Ξ", "Σ", "Ѐ", "Ё", "Ӗ", "ཇ", "ཛ", "Ꭼ", "ᴇ", "ᴱ", "ᴲ", "Ḕ", "Ḗ", "Ḙ", "Ḛ", "Ḝ", "Ẹ", "Ẻ", "Ẽ", "Ế", "Ề", "Ể", "Ễ", "Ệ", "Ἐ", "Ἑ", "Ἒ", "Ἓ", "Ἔ", "Ἕ", "Ὲ", "Έ", "ℇ", "ℰ", "⅀", "∃", "∄", "∑", "Ⓔ", "ⱻ", "ⴹ", "ꓰ", "ꓱ", "Ｅ", "È", "É", "Ê", "Ẽ", "Ē", "Ĕ", "Ė", "Ë", "Ẻ", "Ě", "Ȅ", "Ȇ", "Ẹ", "Ȩ", "Ę", "Ḙ", "Ḛ", "È̄", "Ḕ", "Ὲ", "Έ", "Ἐ", "Ἑ", "Ѐ", "Ӗ", "Ё", "Ḕ̄", "𐊆", "𐊤", "𐌄", "𑀚", "𝐄", "𝐸", "𝑬", "𝓔", "𝔈", "𝔼", "𝕰", "𝖤", "𝗘", "𝘌", "𝙀", "𝙴", "𝚬", "𝚵", "𝚺", "𝛦", "𝛯", "𝛴", "𝜠", "𝜩", "𝜮", "𝝚", "𝝣", "𝝨", "𝞔", "𝞝", "𝞢", "🄴", "🅔", "🅴", "🇪", "È̄", "Ề", "Ế", "Ễ", "Ể", "Ḕ", "Ḗ", "Ệ", "Ḝ", "Ἒ", "Ἔ", "Ἓ", "Ἕ", "Ḕ̄"},
	{"D", "Ḍ̛̇", "Ḍ̛̇", "Ḍ̛̇", "Ḍ̛̇", "Ḍ̇", "Ḍ̛", "Ḋ̛", "Ḍ̇", "򬰵", "򟰵", "򒰵", "򅰵", "񸰵", "񫰵", "񞰵", "񑰵", "񄰵", "𷰵", "𪰵", "🇩", "🅳", "🅓", "🄳", "𝙳", "𝘿", "𝘋", "𝗗", "𝖣", "𝕯", "𝔻", "𝔇", "𝓓", "𝒟", "𝑫", "𝐷", "𝐃", "𑀥", "𐰵", "𐓰", "𐓉", "𐓈", "𐌃", "Ḍ̛", "Ḍ̇", "Ḍ̇", "Ḋ̛", "Ḏ", "Ḓ", "Ḑ", "Ḍ", "Ď", "Ḋ", "Ｄ", "ꓷ", "ꓓ", "Ⓓ", "Ⅾ", "ⅅ", "Ḓ", "Ḑ", "Ḏ", "Ḍ", "Ḋ", "ᴰ", "ᴆ", "ᴅ", "ᗭ", "ᗬ", "ᗫ", "ᗪ", "ᗦ", "ᗥ", "ᗤ", "ᗡ", "ᗠ", "ᗟ", "Ꭰ", "Ⴇ", "Ɗ", "Ɖ", "Đ", "Ď", "Ð"},
	{"C", "Ç", "Ć", "Ĉ", "Ċ", "Č", "Ɔ", "Ƈ", "Ȼ", "ʗ", "Ϛ", "Ϲ", "Ͻ", "Ͼ", "Ͽ", "Ҁ", "Ҫ", "Ⴢ", "Ꮯ", "Ꮳ", "ᑐ", "ᑑ", "ᑒ", "ᑓ", "ᑔ", "ᑕ", "ᑖ", "ᑝ", "ᑞ", "ᑟ", "ᑠ", "ᑡ", "ᑢ", "ᑣ", "ᑤ", "ᑥ", "ᑦ", "ᑩ", "ᑪ", "ᒼ", "Ḉ", "₵", "ℂ", "℃", "ℭ", "Ⅽ", "Ↄ", "ↅ", "∁", "Ⓒ", "Ⲥ", "ⵎ", "ꓚ", "ꓛ", "Ꜿ", "Ꞓ", "ꟲ", "Ｃ", "Ć", "Ĉ", "Ċ", "Č", "Ç", "𐊢", "𐌂", "𐐕", "𐐣", "𐐽", "𐒧", "𐒨", "𑀝", "𝐂", "𝐶", "𝑪", "𝒞", "𝓒", "𝕮", "𝖢", "𝗖", "𝘊", "𝘾", "𝙲", "🄫", "🄲", "🅒", "🅲", "🇨", "Ḉ"},
	{"B", "򬐵", "򟐵", "򒐵", "򅐵", "񸐵", "񫐵", "񞐵", "񑐵", "񄐵", "𪐵", "🇧", "🅱", "🅑", "🄱", "𝞑", "𝝗", "𝜝", "𝛣", "𝚩", "𝙱", "𝘽", "𝘉", "𝗕", "𝖡", "𝕭", "𝔹", "𝔅", "𝓑", "𝑩", "𝐵", "𝐁", "𐞄", "𐑂", "𐐺", "𐐵", "𐐚", "𐐒", "𐌱", "𐌁", "𐊡", "𐊂", "Ḇ", "Ḅ", "Ḃ", "Ｂ", "ꞵ", "Ꞵ", "ꞝ", "Ꞝ", "ꞛ", "Ꞛ", "Ꞗ", "ꓭ", "ꓐ", "ⲃ", "Ⲃ", "Ⓑ", "ℬ", "₿", "ẞ", "Ḇ", "Ḅ", "Ḃ", "ᴯ", "ᴮ", "ᴃ", "ᛔ", "ᛒ", "ᙠ", "ᙟ", "ᙞ", "ᙝ", "ᙙ", "ᙘ", "ᙗ", "ᙖ", "ᘀ", "ᗿ", "ᗾ", "ᗺ", "ᗹ", "ᗸ", "ᗷ", "ᏼ", "ᏸ", "Ᏼ", "Ᏸ", "฿", "ϐ", "β", "Β", "ʙ", "Ƀ", "Ɓ", "ß"},
	{"A", "ᾏ", "ᾍ", "ᾋ", "ᾎ", "ᾌ", "ᾊ", "ᾉ", "Ἇ", "Ἅ", "Ἃ", "ᾈ", "Ἆ", "Ἄ", "Ἂ", "Ặ", "Ậ", "Ǻ", "Ǟ", "Ǡ", "Ẳ", "Ẵ", "Ắ", "Ằ", "Ẩ", "Ẫ", "Ấ", "Ầ", "🇦", "🅰", "🅐", "🄰", "𝞐", "𝝖", "𝜜", "𝛢", "𝚨", "𝙰", "𝘼", "𝘈", "𝗔", "𝖠", "𝕬", "𝔸", "𝔄", "𝓐", "𝒜", "𝑨", "𝐴", "𝐀", "𐌀", "𐋎", "𐊠", "ᾼ", "Ἁ", "Ἀ", "Ᾰ", "Ᾱ", "Ά", "Ὰ", "Ą", "Ḁ", "Ạ", "Ȃ", "Ȁ", "Ǎ", "Å", "Ả", "Ä", "Ȧ", "Ă", "Ā", "Ã", "Â", "Á", "À", "Ａ", "ꓯ", "ꓮ", "Ɐ", "Ⓐ", "∀", "Å", "₳", "ᾼ", "Ά", "Ὰ", "Ᾱ", "Ᾰ", "ᾏ", "ᾎ", "ᾍ", "ᾌ", "ᾋ", "ᾊ", "ᾉ", "ᾈ", "Ἇ", "Ἆ", "Ἅ", "Ἄ", "Ἃ", "Ἂ", "Ἁ", "Ἀ", "Ặ", "Ẵ", "Ẳ", "Ằ", "Ắ", "Ậ", "Ẫ", "Ẩ", "Ầ", "Ấ", "Ả", "Ạ", "Ḁ", "ᴬ", "ᴀ", "ᗩ", "ᗌ", "ᗋ", "ᗊ", "ᗉ", "ᗈ", "ᗇ", "ᗆ", "ᗅ", "ᗄ", "Ꮜ", "Ꭿ", "Ꭺ", "Α", "Ά", "Ⱥ", "Ȧ", "Ȃ", "Ȁ", "Ǻ", "Ǡ", "Ǟ", "Ǎ", "Ą", "Ă", "Ā", "Å", "Ä", "Ã", "Â", "Á", "À"},
	{"@", "﹫", "＠"},
	{"?", "𐞴", "𐞳", "？", "﹖", "︖", "⸮", "⸘", "❔", "❓", "␦", "ॽ", "ˤ", "ʢ", "ʡ", "ʕ", "¿"},
	{">", "⊱", "˃", "˲", "ᐅ", "ᐉ", "ᐳ", "ᗒ", "›", "≫", "≻", "≽", "≿", "⊃", "⊐", "⊒", "⋑", "⋗", "⋝", "⋟", "〉", "⍄", "☽", "❭", "❯", "❱", "⟩", "⦒", "⧽", "⩺", "⩼", "⪫", "⫸", "〉", "》", "︾", "﹀", "﹥", "＞", "🢖"},
	{"=", "𐞸", "＝", "﹦", "꞊", "꓿", "゠", "⹀", "≟", "≞", "≝", "≜", "≛", "≚", "≙", "≘", "≗", "≖", "≕", "≔", "≓", "≒", "≑", "≐", "₌", "⁼", "᐀", "˭", "ǂ", "𝄗", "𝄘", "𝄙", "𝄚", "𝄛"},
	{"<", "⊱", "🢔", "＜", "﹤", "︿", "︽", "《", "〈", "⫷", "⪪", "⩻", "⩹", "⧼", "⦑", "⟨", "❰", "❮", "❬", "☾", "⍃", "〈", "⋞", "⋜", "⋖", "⋐", "⊑", "⊏", "⊂", "≾", "≼", "≺", "≪", "‹", "ᚲ", "ᗕ", "ᑉ", "ᐸ", "ᐊ", "˱", "˂"},
	{";", ";", "⁏", "⸵", "︔", "﹔", "；"},
	{":", "𐞁", "：", "﹕", "︰", "︙", "︓", "꞉", "ꓽ", "∶", "⁚", "᛬", "։", "˸", "ː", "𝄈"},
	{"9", "ƍ", "գ", "୧", "୨", "౸", "႙", "ნ", "Ꮽ", "⁹", "₉", "⑨", "⓽", "♇", "❾", "➈", "➒", "㋈", "㍡", "㏨", "ꝯ", "ꝰ", "９", "9日", "9月", "9点", "𝟗", "𝟡", "𝟫", "𝟵", "𝟿", "􅰵", "􈐵", "􊰵", "􍐵", "􏰵"},
	{"8", "𝟾", "𝟴", "𝟪", "𝟠", "𝟖", "8点", "8月", "8日", "８", "㏧", "㍠", "㋇", "➑", "➇", "❽", "⓼", "⑧", "₈", "⁸", "ᴽ", "ზ", "႘", "৪", "Ȣ"},
	{"7", "􏐵", "􌰵", "􊐵", "􇰵", "􅐵", "𝟽", "𝟳", "𝟩", "𝟟", "𝟕", "𐒇", "7点", "7月", "7日", "７", "㏦", "㍟", "㋆", "➐", "➆", "❼", "⓻", "⑦", "₇", "⁷", "⁊", "႗", "٢"},
	{"6", "႖", "მ", "Ꮾ", "⁶", "₆", "⑥", "⓺", "❻", "➅", "➏", "㋅", "㍞", "㏥", "ꝺ", "６", "6日", "6月", "6点", "𝟔", "𝟞", "𝟨", "𝟲", "𝟼"},
	{"5", "􎰵", "􌐵", "􉰵", "􇐵", "􄰵", "𝟻", "𝟱", "𝟧", "𝟝", "𝟓", "5点", "5月", "5日", "５", "㏤", "㍝", "㋄", "➎", "➄", "❺", "⓹", "⑤", "₅", "⁵", "႕", "ཏ", "ट", "ҕ", "Ƽ"},
	{"4", "ʮ", "Ϥ", "႔", "Ⴙ", "Ꮞ", "ᖸ", "⁴", "₄", "④", "⓸", "❹", "➃", "➍", "㋃", "㍜", "㏣", "４", "4日", "4月", "4点", "𝟒", "𝟜", "𝟦", "𝟰", "𝟺"},
	{"3", "􎐵", "􋰵", "􉐵", "􆰵", "􄐵", "𝟹", "𝟯", "𝟥", "𝟛", "𝟑", "3点", "3月", "3日", "３", "Ɜ", "ꝫ", "Ꝫ", "ꝣ", "Ꝣ", "㏢", "㍛", "㋂", "➌", "➂", "❸", "⓷", "③", "↋", "₃", "Ꮛ", "ჳ", "კ", "ვ", "႓", "ဒ", "౩", "Յ", "³"},
	{"2", "𝟸", "𝟮", "𝟤", "𝟚", "𝟐", "2点", "2月", "2日", "２", "㏡", "㍚", "㋁", "➋", "➁", "❷", "⓶", "②", "↊", "₂", "ᘔ", "ᒿ", "ᒾ", "ջ", "²"},
	{"1", "¹", "˦", "႑", "₁", "①", "⓵", "❶", "➀", "➊", "㋀", "㍙", "㏠", "１", "1日", "1月", "1点", "𝟏", "𝟙", "𝟣", "𝟭", "𝟷", "􃰵", "􆐵", "􈰵", "􋐵", "􍰵"},
	{"0", "𝟶", "𝟬", "𝟢", "𝟘", "𝟎", "0点", "０", "㍘", "⓿", "⓪", "₀", "⁰", "႐"},
	{"/", "🙼", "÷", "⁄", "∕", "╱", "⟋", "⤢", "⧸", "Ⳇ", "⼃", "〳", "ノ", "／", "ﾉ", "𝄍", "𝄓"},
	{".", "．", "﹒", "︒", "ꓸ", "。", "․"},
	{",", "𝄒"},
	{"-", "￢", "－", "﹘", "ꟷ", "一", "ー", "⸻", "⸺", "ⲻ", "Ⲻ", "⨬", "⨫", "⨪", "⨩", "➖", "━", "─", "−", "⁻", "⁃", "―", "—", "–", "‒", "‑", "‐", " ", "˗", "¬", "𝄖", "𝄩", "▬"},
	{"+", "♰", "☨", "†", "‡", "✝", "☦", "✝️", "☦️", "☩", "𐊛", "≁", "＋", "﹢", "⨨", "⨧", "⨦", "⨥", "⨤", "⨣", "⨢", "➕", "≁", "₊", "⁺", "᛭", "𝅄"},
	{"+", "𐊛", "≁", "＋", "﹢", "⨨", "⨧", "⨦", "⨥", "⨤", "⨣", "⨢", "➕", "≁", "₊", "⁺", "᛭"},
	{"•", "＊", "❋", "❊", "❉", "❈", "❇", "❆", "❅", "❄", "❃", "❂", "❁", "❀", "✿", "✾", "✽", "✼", "✻", "✺", "✹", "✸", "✷", "✶", "✵", "✴", "✳", "✲", "✱", "✰", "✯", "✮", "✭", "✬", "✫", "✪", "✩", "✨", "✦", "☆", "★", "⋆", "∗", "⁎", "༝", "֎", "֍"},
	{")", "ᴗ", "ᵕ", "⁾", "₎", "﴿", "︶", "︺", "﹚", "﹞", "❩", "❫", "⟯", "◗", "◝", "◞"},
	{") ", "〕", "）"},
	{"(", "﹝", "﹙", "︹", "︵", "﴾", "₍", "⁽", "ᵔ", "ᴖ", "🤇", "⟮", "❪", "❨", "◖", "◜", "◟"},
	{" (", "（", "〔"},
	{"'", "`", " ̔͂", " ̔́", " ̔̀", " ̓͂", " ̓́", " ̓̀", " ̈́", " ̈̀", "῟", "῞", "῝", "῏", "῎", "῍", "΅", "῭", " ̔", " ̓", " ́", "｀", "＇", "ꞌ", "Ꞌ", "‵", "′", "‚", "‛", "’", "‘", "῾", "´", "`", "΅", "῭", "῟", "῞", "῝", "῏", "῎", "῍", "᾿", "᾽", "ᛌ", "ᑊ", "՝", "՜", "՛", "՚", "ՙ", "΅", "΄", "ʹ", "˴", "ˋ", "ˊ", "ˈ", "ʿ", "ʾ", "ʽ", "ʼ", "ʻ", "ʹ", "´"},
	{"&", "🙵", "🙴", "⅋", "ꝸ", "﹠", "＆"},
	{"%", "％", "﹪", "⁒", "٪", "𝄎", "𝄏"},
	{"$", "﹩", "＄"},
	{"#", "＃", "﹟", "♯", "♮"},
	{"!", "！", "﹗", "︕", "ⵑ", "❗", "❕", "ǃ", "¡"},
	{" ", "	", "　", "▓", "▒", "░", "⏎", "≋", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "},
	{"",  "゚", "̀", "́", "̄", "̅", "̈", "̓", "̲", "̳", "̴", "̶", "̷", "̽", "̾", "̀", "́", "͂", "̓", "̈́", "͎", "͓", "҉", "᠎", "​", "︀", "︁", "︂", "︃", "︄", "︅", "︆", "︇", "︈", "︉", "︊", "︋", "︌", "︍", "︎", "﻿", "̈́"}};

void NormalizeString(string &inout str)
{
	if (str.isEmpty()) return;

	string old = str;
	
	str = TrimTotal(str);


	DebugPrint();
	DebugPrint(str);
	//DebugPrint(GetBytes(str));

	if (IsLatinStr(str))
	{
		str.replace("`", "'");
	}
	else
	{
		for (uint i = 0; i < normalizeChars.size(); i++)
		{
			const array<string>@ line = @normalizeChars[i];

			string s = line[0];

			for (uint j = 1; j < line.size(); j++)
			{
				//DebugPrint(formatInt(i) + ":" + formatInt(j));
				str.replace(line[j], s);
			}
		}


		//DebugPrint(str);
		//DebugPrint(GetBytes(str));

		uint len = str.length();
		uint i = 0;
		uint uChar;
		uint8 char;

		while (i < len)
		{
			char = str[i];

			if (char == 0)
			{
				i += 1;

				if (i > len) break;

				continue;
			}

			if (char <= 127)
			{
				i += 1;

				if (i > len) break;
			}
			else if ((char <= 223) && (char >= 194))
			{
				i += 2;

				if (i > len) break;
			}
			else if ((char == 224) ||
					 (char == 237) ||
					((char <= 236) && (char >= 225)) ||
					((char <= 239) && (char >= 238)))
			{
				i += 3;

				if (i > len) break;

				uChar = (((char & 0x0F) << 12) |
				   ((str[i - 2] & 0x3F) << 6)  |
					(str[i - 1] & 0x3F));

				if (((uChar >= 9728) && (uChar <= 9983)) || ((uChar >= 65024) && (uChar <= 65039)))
				{
					str[i - 3] = "•"[0];
					str[i - 2] = "•"[1];
					str[i - 1] = "•"[2];

					continue;
				}
			}
			else if ((char == 240) ||
					 (char == 244) ||
					((char <= 243) && (char >= 241)))
			{
				i += 4;

				if (i > len) break;

				uChar = (((char & 0x07) << 18) |
				   ((str[i - 3] & 0x3F) << 12) |
				   ((str[i - 2] & 0x3F) << 6)  |
					(str[i - 1] & 0x3F));

				if (((uChar >= 127744) && (uChar <= 128767)) || ((uChar >= 129280) && (uChar <= 129535)) || ((uChar >= 129648) && (uChar <= 129791)))
				{
					str[i - 4] = 32;
					str[i - 3] = "•"[0];
					str[i - 2] = "•"[1];
					str[i - 1] = "•"[2];

					continue;
				}
			}
			else
			{
				break;
			}
		}
	}


	//DebugPrint(str);
	//DebugPrint(GetBytes(str));
	
	const array<string> chars = {"!", "'", "\"", "*", "+", ",", "-", ".", ";", "=", "?", "_", "{", "|", "}", "[", "\\", "/", "]", "^", "~", "(", ")", "#", "$", "%", "&", ":", "<", ">"};

	str.replace("•", " • ");

	int len = str.length();

	while (true)
	{
		for (uint i = 0; i < chars.size(); i++)
		{
			str.replace("• " + chars[i], chars[i]);
			str.replace(chars[i] + " •", chars[i]);
		}

		str.replace("  ", " ");
		str.replace("• •", "•");
		str.replace("••", "•");

		str.replace("{ ", "{");
		str.replace(" }", "}");
		str.replace("[ ", "[");
		str.replace(" ]", "]");
		str.replace("( ", "(");
		str.replace(" )", ")");

		str.Trim();
		str.Trim(".");

		int newLen = str.length();

		if (newLen >= 3)
		{
			if ((str[newLen - 3] == "•"[0]) && (str[newLen - 2] == "•"[1]) && (str[newLen - 1] == "•"[2]))
			{
				newLen -= 3;
				str = str.substr(0, newLen);
			}

			if ((str[0] == "•"[0]) && (str[1] == "•"[1]) && (str[2] == "•"[2]))
			{
				newLen -= 3;
				str = str.substr(3);
			}
		}

		if (newLen == len) break;

		len = newLen;
	}
	
		
	if (str.find("\n") > 0)
	{
		array<string> lines = str.split("\n");
		
		str = "";

		for (uint i = 0; i < lines.size(); i++)
		{
			string line = TrimTotal(lines[i]);

			if (!line.isEmpty())
			{
				bool f = false;
				
				for (uint j = 0; j < line.length(); j++)
				{
					uint8 char = line[j];
					
					if ((char != "-"[0]) && (char != "="[0]) && (char != "_"[0]) && (char != "*"[0]) && (char != " "[0]))
					{
						f = true;
						
						break;
					}
				}
				
				if (f)
				{
					len = str.length();
					
					while (true)
					{
						line.Trim();
						line.Trim("/");
						line.Trim("\\");
						//line.Trim("*");
						line.Trim("-");
						line.Trim(",");
						line.Trim(".");
						line.Trim(";");
						line.Trim(":");

						int newLen = line.length();
						
						if (newLen == len) break;

						len = newLen;
					}

					str += line + " • ";
				}
			}
		}
		
		len = str.length();
		
		while (true)
		{
			str.replace("  ", " ");
			str.replace("• •", "•");
			str.replace("••", "•");
			
			str.Trim();

			int newLen = str.length();
			
			if (newLen >= 3)
			{
				if ((str[newLen - 3] == "•"[0]) && (str[newLen - 2] == "•"[1]) && (str[newLen - 1] == "•"[2]))
				{
					newLen -= 3;
					str = str.substr(0, newLen);
				}

				if ((str[0] == "•"[0]) && (str[1] == "•"[1]) && (str[2] == "•"[2]))
				{
					newLen -= 3;
					str = str.substr(3);
				}
			}
			
			if (newLen == len) break;

			len = newLen;
		}
	}
	

	DebugPrint(str);
	//DebugPrint(GetBytes(str));

	if (str.isEmpty()) str = old;
}
