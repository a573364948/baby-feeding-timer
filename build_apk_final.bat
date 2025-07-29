@echo off
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot"
set "PATH=C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\cmd;%PATH%"
cd /d "D:\time\baby_feeding_timer"
echo Building APK...
"D:\time\flutter\bin\cache\dart-sdk\bin\dart.exe" "D:\time\flutter\bin\cache\flutter_tools.snapshot" build apk --debug
echo Build completed
pause