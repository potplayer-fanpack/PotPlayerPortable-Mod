# My_PotPlayer64
Polish
========

Nadal czekasz na wersję portable? Pobierz archiwum i spakuj swój własny PotPlayer 32/64-bit!

## Spis zawartości
* [Katalog bin](#katalog-bin)
* [Katalog custom](#katalog-custom)
* [Niepotrzebne pliki](#niepotrzebne-pliki)
* [Niepotrzebne foldery](#niepotrzebne-foldery)
* [Plik wsadowy](#plik-wsadowy)
* [Uwagi](#uwagi)

## Katalog bin
Wszystkie pliki znajdujące się w tym katalogu są programami wykonywalnymi, które potrzebne są do poprawnego działania.
- [_7-Zip 22.01 (2022-07-15)_](https://www.7-zip.org/) - pliki 7z.exe i 7z.dll
- [_wget-1.20-win64_](https://eternallybored.org/misc/wget/) - plik wget.exe
- [_The PE file analysis toolkit_](https://github.com/merces/pev) - plik pev.exe

## Katalog custom
W tym katalogu należy umieszczać wszystkie niestandardowe pliki PotPlayer - należy zwrócić uwagę na zachowanie struktury katalogów, np. jak poniżej：
- Module\FFmpeg4\FFmpeg64.dll # biblioteka z pakietu OpenCodec
- Skins\YouTube_TitleBar_Slim_ha2.dsf # skórka
- PotIcons64.dll # niestandardowe ikony
- PotPlayerMini64.ini # plik ustawień dla wersji portable

## Niepotrzebne pliki
W pliku unneeded-files.txt znajduje się lista usuwanych plików, jest ona konfigurowalna - można ją dostosować do własnych potrzeb.

## Niepotrzebne foldery
W pliku unneeded-folders.txt znajduje się lista usuwanych folderów, jest ona konfigurowalna - można ją dostosować do własnych potrzeb.

## Plik wsadowy
Plik wsadowy My_PotPlayer64.bat zawiera skrypt, który po uruchomieniu (podwójne kliknięcie LPM) pobiera najnowszą wersję Public lub Dev odtwarzacza PotPlayer, pakiet kodeków OpenCodec, które następnie wypakowuje do folderu Temp, usuwa zbędne foldery i pliki, przenosi dodatkowe pliki do katalogu odtwarzacza, a następnie pakuje tak przygotowany odtwarzacz do archiwum .zip.

Po zakończeniu działania pliku wsadowego powstaje nowe archiwum o nazwie My_PotPlayer64_wersja_.zip zawierające wersję portable.

## Uwagi
Zwróć uwagę, że w ścieżce skryptu nie ma spacji. 
Obsługiwana jest tylko wersja 64-bitowa, dla wersji 32-bitowej można samodzielnie dostosować skrypt.

Skrypt przeszedł testy w systemie Win11 22H2 64-bit. 
Z indywidualnych przyczyn systemowych, takich jak uprawnienia, itp. możliwe jest, że skrypt nie zostanie uruchomiony.

English
========

Still waiting for the portable version? Download the archive and package your own PotPlayer 32/64-bit!

## Spis zawartości
* [Bin directory](#bin-directory)
* [Custom directory](#custom-directory)
* [Unneeded files](#unneeded-files)
* [Unneeded folders](#unneeded-folders)
* [Batch file](#batch-file)
* [Notes](#notes)

## Bin directory
All files in this directory are executable programs that are needed for proper operation.
- [_7-Zip 22.01 (2022-07-15)_](https://www.7-zip.org/) - 7z.exe and 7z.dll files
- [_wget-1.20-win64_](https://eternallybored.org/misc/wget/) - wget.exe file
- [_The PE file analysis toolkit_](https://github.com/merces/pev) - pev.exe file

## Custom directory
Place all custom PotPlayer files in this directory - be sure to maintain the directory structure, such as the following：
- Module\FFmpeg4\FFmpeg64.dll # library from the OpenCodec package
- Skins\YouTube_TitleBar_Slim_ha2.dsf # skin
- PotIcons64.dll # custom icons
- PotPlayerMini64.ini # settings file for the portable version

## Unneeded files
The unneeded-files.txt file contains a list of deleted files, and it is configurable - you can adjust it to your needs.

## Unneeded folders
The unneeded-folders.txt file contains a list of deleted folders, it is configurable - you can adjust it to your needs.

## Batch file
The batch file My_PotPlayer64.bat contains a script that, when run (double-clicking LMB), downloads the latest version of Public or Dev PotPlayer, the OpenCodec codec package, which it then extracts into the Temp folder, deletes unnecessary folders and files, moves additional files into the player directory, and then packs the player thus prepared into a .zip archive.

After the batch file is finished, a new archive called My_PotPlayer64_version_.zip is created containing the portable version.

## Notes
Note that there are no spaces in the script path. 
Only the 64-bit version is supported, for the 32-bit version you can customise the script yourself.

The script passed the tests on a Win11 22H2 64-bit system. 
For individual system reasons, such as permissions, etc., it is possible that the script will not run.
