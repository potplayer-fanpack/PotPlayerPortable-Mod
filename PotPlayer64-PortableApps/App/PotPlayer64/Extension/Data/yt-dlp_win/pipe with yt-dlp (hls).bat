@echo off

for /F "delims=" %%i in ('powershell Get-Clipboard') do set url=%%i

set "findpp=%~dp0..\..\.."
if exist "%findpp%\PotPlayerMini.exe" set "namepp=PotPlayerMini.exe"
if exist "%findpp%\PotPlayerMini64.exe" set "namepp=PotPlayerMini64.exe"
for /F "usebackq delims=" %%i in (`2^>nul dir /B /S /A:-D "%findpp%\%namepp%"`) do set "pathpp=%%i"

yt-dlp.exe -o - -S "+res:1080,codec,br" "%url%" | "%pathpp%" -