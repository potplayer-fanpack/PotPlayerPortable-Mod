:: Downloads video from link in clipboard using yt-dlp and ffmpeg
:: yt-dlp.exe -- https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
:: ffmpeg.exe -- https://github.com/GyanD/codexffmpeg/releases/download/6.1.1/ffmpeg-6.1.1-essentials_build.7z
:: https://t.me/wincmd64

@echo off

:: finds the downloads folder
FOR /F "USEBACKQ TOKENS=2,*" %%a IN (
	`REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /V {374DE290-123F-4565-9164-39C4925E467B}`
) DO (SET DOWNLOADS=%%b)

:: get value from clipboard
for /f "delims=" %%i in ('powershell Get-Clipboard') do set url=%%i

:check
yt-dlp.exe -F -S vext "%url%"
if ERRORLEVEL 1 (
	:: if the url is not read from the buffer - enter manually
	set /p url=Enter the url: 
	echo.
	goto check
)
echo.
set num=
set /p num=Enter ID or videoID+audioID or leave empty for MP4*1080*AVC if available: 
echo.
if not defined num (
	:: hit Enter for best video\audio
	yt-dlp.exe -f "bestvideo[height<=?1080][vcodec^=avc][ext=mp4]+bestaudio[acodec^=mp4a][ext=m4a]/best" "%url%" -P %DOWNLOADS% -o "%%(title).100s.%%(ext)s" --no-part
	if ERRORLEVEL 1 (goto check)
) else (
	yt-dlp.exe -f %num% "%url%" -P %DOWNLOADS% -o "%%(title).100s.%%(ext)s" --no-part
	if ERRORLEVEL 1 (goto check)
)
color 27
explorer %DOWNLOADS%
timeout 2