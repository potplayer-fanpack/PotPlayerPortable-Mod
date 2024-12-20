@echo off
setlocal enabledelayedexpansion

:: Dev/Public
set SOURCE=Public

set WORKDIR=%~dp0
set TEMPDIR=%WORKDIR%temp
set BINDIR=%WORKDIR%bin

if exist %TEMPDIR% (rd /q /s %TEMPDIR%)
if not exist %TEMPDIR% (md %TEMPDIR%)

echo "Downloading PotPlayerSetup64.exe"
if exist %WORKDIR%PotPlayerSetup64.exe (del /q /s /f %WORKDIR%PotPlayerSetup64.exe)
if "%SOURCE%"=="Dev" (%BINDIR%\wget.exe https://t1.daumcdn.net/potplayer/beta/PotPlayerSetup64.exe)
if "%SOURCE%"=="Public" (%BINDIR%\wget.exe https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe)

echo "Downloading OpenCodecSetup64.exe"
if exist %WORKDIR%OpenCodecSetup64.exe (del /q /s /f %WORKDIR%OpenCodecSetup64.exe)
%BINDIR%\wget.exe https://t1.daumcdn.net/potplayer/PotPlayer/Codec/v3/OpenCodecSetup64.exe

echo "Extracting PotPlayerSetup64.exe"
%BINDIR%\7z.exe x %WORKDIR%PotPlayerSetup64.exe -o%TEMPDIR%\PotPlayer64 -y

echo "Extracting OpenCodecSetup64.exe"
%BINDIR%\7z.exe x %WORKDIR%OpenCodecSetup64.exe -o%TEMPDIR%\PotPlayer64 -y

echo "Deleting NSIS temporary files"
for /d /r %TEMPDIR%\PotPlayer64 %%i in ($*) do (
    if exist %%i (
        rd /q /s %%i
    )
)

echo "Renaming folders"
move /y %TEMPDIR%\PotPlayer64\Module\FFmpeg60 %TEMPDIR%\PotPlayer64\Module\FFmpeg61

echo "Deleting unneeded folders"
for /f "delims=" %%i in (%WORKDIR%unneeded-folders.txt) do (
    for /d /r %TEMPDIR%\PotPlayer64 %%a in (%%i) do (
        if exist %%a (
            rd /q /s %%a
        )
    )
)

echo "Deleting unneeded files"
for /f "delims=" %%i in (%WORKDIR%unneeded-files.txt) do (
    for /d /r %TEMPDIR%\PotPlayer64 %%a in (%%i) do (
        if exist %%a (
            del /q /s /f %%a
        )
    )
)

echo "Adding custom folders/files"
if exist %WORKDIR%custom (xcopy /e /r /y %WORKDIR%custom\* %TEMPDIR%\PotPlayer64)

echo "Getting PotPlayer version"
for /f "delims=" %%a in ('%BINDIR%\pev.exe -p %TEMPDIR%\PotPlayer64\PotPlayer64.dll') do set VERSION=%%a

echo "Repacking PotPlayer"
if exist %WORKDIR%PotPlayer64Portable_%SOURCE%_%VERSION%.zip (del /q /s /f %WORKDIR%PotPlayer64Portable_%SOURCE%_%VERSION%.zip)
%BINDIR%\7z.exe a -tzip -r %WORKDIR%PotPlayer64Portable_%SOURCE%_%VERSION%.zip %TEMPDIR%\*

if exist %TEMPDIR% (rd /q /s %TEMPDIR%)

pause
