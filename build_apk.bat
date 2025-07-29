@echo off
set "GIT_EXECUTABLE=C:\Program Files\Git\mingw64\bin\git.exe"
set "PATH=C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\cmd;%PATH%"
cd /d "D:\time\baby_feeding_timer"
echo Current PATH: %PATH%
echo Checking git...
"C:\Program Files\Git\mingw64\bin\git.exe" --version
echo Running Flutter build...
"D:\time\flutter\bin\flutter.bat" build apk --verbose
echo Build completed
pause