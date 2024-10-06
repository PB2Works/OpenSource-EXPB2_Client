@echo off
mkdir %appdata%\Adobe
mkdir %appdata%\Adobe\AIR
echo 3 > %appdata%\Adobe\AIR\eulaAccepted
echo If there is no error, you are good to go.
echo If it says "directory already exists", just ignore it
pause