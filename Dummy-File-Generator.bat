@goto main

rem Dummy File Generator 1.1
rem Updated on 2018-03-06
rem Made by wthe22 - http://winscr.blogspot.com/


:main
@echo off
prompt $s
setlocal EnableDelayedExpansion EnableExtensions

rem ======================================== Script Setup ========================================

set "SOFTWARE_NAME=Dummy File Generator"
set "SOFTWARE_VERSION=1.1"
set "SOFTWARE_RELEASE_DATE=03/06/2018"


title !SOFTWARE_NAME! !SOFTWARE_VERSION!

cd /d "%~dp0"

:input_size
set "user_input=0"
cls
echo Smallest unit is KB (Default)
echo Size in Bytes is not allowed
echo=
echo Syntax:
echo GB = G     Supports: + - /
echo MB = M     Not case sensitive
echo KB = K     No unit = defaults to KB
echo=
echo Examples:
echo  512KB =      512  = 1/2mb
echo 1023KB = 1mb -1kb  = 1000 + 23
echo=
echo Input file size:
set /p "user_input="
echo=

set "error=False"
set "make_size=0"
set "user_input=!user_input: =!"
set "user_input=!user_input:+= +!"
set "user_input=!user_input:-= -!"
for %%s in (!user_input!) do (
    set "current_size= %%s"
    set "multiplier="
    set "unit_multiplier=1"
    for %%u in (KB K - MB M - GB G) do if "%%u" == "-" (
        set /a "unit_multiplier*=1024"
    ) else if not defined multiplier (
        set "current_size=!current_size:%%u=!"
        if not " %%s" == "!current_size!" set "multiplier=!unit_multiplier!"
    )
    set "test_num=!current_size!"
    for %%n in (+ - 0 1 2 3 4 5 6 7 8 9 /) do set "test_num=!test_num:%%n=!"
    if "!test_num!" == " " (
        if not defined multiplier set "multiplier=1"
        set /a "make_size+=!multiplier! * !current_size!"
    ) else (
        echo Error: "%%s"
        set "error=True"
    )
)
if /i "!error!" == "True" (
    pause
    goto input_size
)
set "size_name="
set "_temp_size=!make_size!"
for %%u in (KB MB GB) do if not "!_temp_size!" == "0" (
    set /a "_remainder=!_temp_size! %% 1024"
    set /a "_temp_size/=1024"
    if not "!_remainder!" == "0" set "size_name=!_remainder!%%u !size_name!"
)
if not defined size_name set "size_name=0KB"
echo File Size  : !size_name! (!make_size! KB)
echo=
pause
echo=
set "start_time=!time!"
call :make_dummy "dummy_!size_name!"  "!make_size!"
call :difftime !time! !start_time!
echo Time Taken : !return!
exit


:make_dummy   filename  kilobytes
set /a "_result=%~2 + 0"
if "!_result!" == "0" (
    call 2> "%~1"
    exit /b 0
)
set "_child_name=_dummy!random!"
call 2> "!_child_name!"
echo=|set /p "=." > "%~1"
for /l %%n in (1,1,10) do type "%~1" >> "%~1"
for /l %%n in (0,1,31) do if not "!_result!" == "0" (
    set /a "_remainder=!_result! %% 2"
    set /a "_result/=2"
    if "!_result!" == "0" (
        copy /b "%~1" + "!_child_name!" "%~1" > nul
    ) else (
        if "!_remainder!" == "1" type "%~1" >> "!_child_name!"
        type "%~1" >> "%~1"
    )
)
del /f /q "!_child_name!"
exit /b 0


:difftime   end_time  [start_time  [/n]]
set "return=0"
for %%t in (%1:00:00:00:00 %2:00:00:00:00) do for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
    set /a "return+=24%%a %% 24 *360000 +1%%b*6000 +1%%c*100 +1%%d -610100"
    set /a "return*=-1"
)
if /i not "%3" == "/n" if !return! LSS 0 set /a "return+=8640000"
exit /b
