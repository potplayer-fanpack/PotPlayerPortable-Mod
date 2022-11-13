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
%BINDIR%\wget.exe https://t1.daumcdn.net/potplayer/PotPlayer/Codec/v1/OpenCodecSetup64.exe

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

echo "Copying files"
copy /y %TEMPDIR%\PotPlayer64\ffcodec64.dll %TEMPDIR%\PotPlayer64\Module\FFmpeg4\ffcodec64.dll

echo "Renaming files"
move /y %TEMPDIR%\PotPlayer64\Module\FFmpeg4\ffcodec64.dll %TEMPDIR%\PotPlayer64\Module\FFmpeg4\FFmpeg64.dll

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

echo "Copying PotPlayer64 folders/files"
if exist %TEMPDIR%\PotPlayer64 (xcopy /e /r /y %TEMPDIR%\PotPlayer64\* %WORKDIR%PotPlayer64-PortableApps\App\PotPlayer64)

if exist %TEMPDIR% (rd /q /s %TEMPDIR%)

pause
