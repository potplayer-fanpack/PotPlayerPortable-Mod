@echo on
>nul chcp 1251

for /F "delims=" %%i in ('powershell Get-Clipboard') do set url=%%i
for /F "delims=" %%i in ('yt-dlp.exe -e "%url%"') do set name=%%i
for /F "delims=" %%i in ('yt-dlp.exe --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -f "bv*[height<=?720][vcodec^=avc][ext=mp4]/best" -g "%url%"') do set link1=%%i
for /F "delims=" %%i in ('yt-dlp.exe --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -f "ba*[acodec^=mp4a][ext=m4a]/best" -g "%url%"') do set link2=%%i

set "findpp=%~dp0..\..\.."
if exist "%findpp%\PotPlayerMini.exe" set "namepp=PotPlayerMini.exe"
if exist "%findpp%\PotPlayerMini64.exe" set "namepp=PotPlayerMini64.exe"
for /F "usebackq delims=" %%i in (`2^>nul dir /B /S /A:-D "%findpp%\%namepp%"`) do set "dirpp=%%~dpi"

start /D "%dirpp%" %namepp% "%link1%" "%link2%" /same /title="%name%"
exit