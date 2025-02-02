REM Description: Run DragonRuby from the parent directory of the current directory
@echo off
cd /d %~dp0
REM if %1 is empty, we assume name of current directory
if "%1"=="" (
  set "1=%~n0"
)
cd ..
dragonruby %1
