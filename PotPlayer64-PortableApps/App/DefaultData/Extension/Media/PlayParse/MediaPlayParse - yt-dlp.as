﻿/*
	yt-dlp media parse (Thanks to "http://www.dvbsupport.net")
*/

bool useDebugPrint = false;

string GetTitle()
{
	return "yt-dlp";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "https://github.com/yt-dlp/yt-dlp/releases";
}

string GetStatus()
{
	return GetTitle();
}

void DebugPrint(string text)
{
	if (useDebugPrint) HostOpenConsole();
	if (useDebugPrint) HostPrintUTF8("[yt-dlp] " + text);
}

bool FileExist(string path)
{
	uintptr pFile = HostFileOpen(path);

	if (pFile == 0)
	{
		return false;
	}
	else
	{
		HostFileClose(pFile);
		return true;
	}
}

string GetFilePath()
{
	string path = "Extension\\yt-dlp.exe";

	if (!FileExist(path))
	{
		path = "Extension\\yt-dlp_min.exe";

		if (!FileExist(path))
		{
			path = "Extension\\yt-dlp_x86.exe";

			if (!FileExist(path))
			{
				path = "Extention\\yt-dlp_x86.exe"; // for some older versions...

				if (!FileExist(path))
				{
					return "";
				}
			}
		}
	}
	return path;
}

bool PlayitemCheck(const string &in path)
{
	path.MakeLower();
	if (path.find("://www.youtube.com/") >= 0) return true;
	if (path.find("://youtu.be/") >= 0) return true;
	if (path.find("://yewtu.be/") >= 0) return true;
	if (path.find("://www.imdb.com/") >= 0) return true;
	if (path.find("://www.filmweb.pl/") >= 0) return true;
	if (path.find("://www.dailymotion.com/") >= 0) return true;
	if (path.find("://twitter.com/") >= 0) return true;
	if (path.find("://www.facebook.com/") >= 0) return true;
	if (path.find("://drive.google.com/") >= 0) return true;
	if (path.find("://www.twitch.tv/") >= 0) return true;
	if (path.find("://clips.twitch.tv/") >= 0) return true;
	if (path.find("://trovo.live/") >= 0) return true;
	if (path.find("://wasd.tv/") >= 0) return true;
	if (path.find("://rumble.com/") >= 0) return true;
	if (path.find("://vimeo.com/") >= 0) return true;
	if (path.find("://www.tiktok.com/") >= 0) return true;
	if (path.find("://www.xnxx.com/") >= 0) return true;
	if (path.find("://www.xvideos.com/") >= 0) return true;
	if (path.find("://rt.pornhub.com/") >= 0) return true;
	if (path.find("://www.pornhub.com/") >= 0) return true;
	return false;

}

string PlayitemParse(const string &in path, dictionary &MetaData, array<dictionary> &QualityList)
{
	string ytdlp = GetFilePath();
	string useragent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";

	string json = HostExecuteProgram(ytdlp, " --user-agent \"" + useragent + "\" --no-check-certificates --no-playlist --all-subs -J -- \"" + path + "\"");
	string ret;

	DebugPrint("HostFileOpen: " + ytdlp);
	DebugPrint("URL: " + path);
	DebugPrint("PlayitemParse: " + json);
	
	if (!json.empty())
	{
		JsonReader reader;
		JsonValue root;

		if (reader.parse(json, root) && root.isObject())
		{
			JsonValue formats = root["formats"];
			
			if (formats.isArray())
			{
				JsonValue url = root["url"];				
				if (url.isString()) ret = url.asString();

				JsonValue title = root["title"];
				if (title.isString()) MetaData["title"] = title.asString();

				JsonValue id = root["id"];
				if (id.isString()) MetaData["vid"] = id.asString();
				
				JsonValue ext = root["ext"];
				if (ext.isString()) MetaData["fileExt"] = ext.asString();
				
				JsonValue uploader = root["uploader"];
				if (uploader.isString()) MetaData["author"] = uploader.asString();
				else
				{
					JsonValue extractor = root["extractor"];
					if (extractor.isString()) MetaData["author"] = extractor.asString();
					else
					{
						JsonValue extractor_key = root["extractor_key"];
						if (extractor_key.isString()) MetaData["author"] = extractor_key.asString();
					}
				}
				
				JsonValue description = root["description"];
				if (description.isString()) MetaData["content"] = description.asString();

				JsonValue webpage_url = root["webpage_url"];
				if (webpage_url.isString()) MetaData["webUrl"] = webpage_url.asString();

				JsonValue thumbnail = root["thumbnail"];
				if (thumbnail.isString()) MetaData["thumbnail"] = thumbnail.asString();

				JsonValue view_count = root["view_count"];
				if (view_count.isString()) MetaData["viewCount"] = view_count.asString();
				else if (view_count.isUInt()) MetaData["viewCount"] = formatInt(view_count.asUInt());

				JsonValue like_count = root["like_count"];
				if (like_count.isString()) MetaData["likeCount"] = like_count.asString();
				else if (like_count.isUInt()) MetaData["likeCount"] = formatInt(like_count.asUInt());
				
				// JsonValue dislike_count = root["dislike_count"];
				// if (dislike_count.isString()) MetaData["dislikeCount"] = dislike_count.asString();
				// else if (dislike_count.isUInt()) MetaData["dislikeCount"] = formatInt(like_count.asUInt());				
				
				JsonValue upload_date = root["upload_date"];
				if (upload_date.isString()) MetaData["date"] = upload_date.asString();

				for(int j = 0, len = formats.size(); j < len; j++)
				{
					JsonValue format = formats[j];
				
					JsonValue protocol = format["protocol"];
					if (!protocol.isString()) continue;
					string _protocol = protocol.asString();
					if (_protocol != "http" && _protocol != "https" && _protocol.substr(0, 4) != "m3u8") continue;

					JsonValue url = format["url"];
					if (!url.isString()) continue;
					if (ret.empty()) ret = url.asString();
					
					if (@QualityList !is null)
					{
						JsonValue ext = format["ext"];
						string _ext;
						if (ext.isString()) _ext = ext.asString();

						string _vcodec;
						JsonValue vcodec = format["vcodec"];
						if (vcodec.isString()) _vcodec = vcodec.asString();

						string _acodec;
						JsonValue acodec = format["acodec"];
						if (acodec.isString()) _acodec = acodec.asString();

						int _width = 0;
						JsonValue width = format["width"];
						if (width.isUInt()) _width = width.asUInt();

						int _height = 0;
						JsonValue height = format["height"];
						if (height.isUInt()) _height = height.asUInt();

						double _fps = 0;
						JsonValue fps = format["fps"];
						if (fps.isDouble()) _fps = fps.asDouble();
						else if (fps.isUInt()) _fps = fps.asUInt();

						double _abr = 0;
						JsonValue abr = format["abr"];
						if (abr.isDouble()) _abr = abr.asDouble();
						else if (abr.isUInt()) _abr = abr.asUInt();

						double _vbr = 0;
						JsonValue vbr = format["vbr"];
						if (vbr.isDouble()) _vbr = vbr.asDouble();
						else if (vbr.isUInt()) _vbr = vbr.asUInt();

						double _tbr = 0;
						JsonValue tbr = format["tbr"];
						if (tbr.isDouble()) _tbr = tbr.asDouble();
						else if (tbr.isUInt()) _tbr = tbr.asUInt();
						
						dictionary item;
						item["url"] = url.asString();
						item["format"] = _ext;
						if (_width > 0 && _height > 0) item["resolution"] = formatInt(_width) + "×" + formatInt(_height);
						
						string bitrate;
						if (_tbr > 0) bitrate = HostFormatBitrate(_tbr * 1000);
						else if (_vbr > 0 && _abr > 0) bitrate = HostFormatBitrate((_abr + _vbr) * 1000);
						else if (_vbr > 0) bitrate = HostFormatBitrate(_vbr * 1000);
						else if (_abr > 0) bitrate = HostFormatBitrate(_abr * 1000);
						
						int itag = 0;
						JsonValue format_id = format["format_id"];
						if (format_id.isUInt()) itag = format_id.asUInt();
						
						string quality;
						if (_vcodec == "none") // audio only...
						{
							double bps = _tbr > 0 ? _tbr : _abr;

							if (bps <= 0) bps = 128;
							if (itag <= 0 || HostExistITag(itag))
							{
								itag = HostGetITag(0, bps, _ext == "mp4", _ext == "webm" || _ext == "m3u8");
								if (itag < 0) itag = HostGetITag(0, bps, true, true);
							}
							if (bps > 0) quality = HostFormatBitrate(bps * 1000);
						}
						else
						{
							if (_acodec == "none") // video only...
							{
								if (itag <= 0 || HostExistITag(itag))
								{							
									itag = HostGetITag(_height, 0, _ext == "mp4", _ext == "webm" || _ext == "m3u8");
									if (itag < 0) itag = HostGetITag(_height, 0, true, true);
								}
								if (_height > 0) quality = formatInt(_height) + "p";
							}
							else
							{
								if (itag <= 0 || HostExistITag(itag))
								{							
									if (_height > 0 && _abr < 1) _abr = 1;
									itag = HostGetITag(_height, _abr, _ext == "mp4", _ext == "webm" || _ext == "m3u8");
									if (itag < 0) itag = HostGetITag(_height, _abr, true, true);
								}
								if (_height > 0) quality = formatInt(_height) + "P";
							}
							if (quality.empty())
							{
								JsonValue format_id = format["format_id"];
								if (format_id.isString()) quality = format_id.asString();
							}
							JsonValue fmt = format["format"];
							if (fmt.isString())
							{							
								string str = fmt.asString();
								if (quality.empty())
								{
									quality = str;
									int p = quality.find(" ");
									if (p > 0) quality = quality.substr(0, p);
								}
								
								int p = str.find("HDR");
								if (p > 0) item["isHDR"] = true;
							}
						}

						if (!bitrate.empty()) item["bitrate"] = bitrate;
						if (!quality.empty()) item["quality"] = quality;
						if (!_vcodec.empty()) item["vcodec"] = _vcodec;
						if (!_acodec.empty()) item["acodec"] = _acodec;
						if (_fps > 0) item["fps"] = _fps;

						while (HostExistITag(itag)) itag++;
						HostSetITag(itag);					
						item["itag"] = itag;

						QualityList.insertLast(item);
					}
				}

				if (@QualityList !is null)
				{				
					JsonValue requested_subtitles = root["requested_subtitles"];
					if (requested_subtitles.isObject())
					{
						array<dictionary> subtitle;					
						array<string> lang_names = requested_subtitles.getKeys();
						
						for(int j = 0, len = lang_names.size(); j < len; j++)
						{
							JsonValue sub = requested_subtitles[lang_names[j]];
						
							if (sub.isObject())
							{
								JsonValue url = sub["url"];
							
								if (url.isString())
								{
									dictionary item;

									item["name"] = lang_names[j];
									item["langCode"] = lang_names[j];
									item["url"] = url.asString();
									subtitle.insertLast(item);								
								}
							}
						}
						if (subtitle.size() > 0) MetaData["subtitle"] = subtitle;
					}
				}
			}
		}
	}
	
	return ret;
}