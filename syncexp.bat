:: This file would save the experiment file after running a experiment and you are happy with that.
@echo off
set PARAM1=%~1
git add -A
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do set mytime=%%a:%%b
git commit -m "Complete (sub)Experiment date %mydate% and time %mytime%, with experiment message: %PARAM1% "
git push