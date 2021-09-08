@echo off
title Calendar
setlocal EnableDelayedExpansion

:mainMenu
cls
echo 1. Show monthly calendar
echo 2. Calculate date and time difference
echo=
echo 0. Exit
echo=
echo What do you want to do?
set /p "userInput="
if "!userInput!" == "0" exit
if "!userInput!" == "1" goto dateIn
if "!userInput!" == "2" goto calcDiffDate
goto mainMenu

:dateIn

for /f "tokens=1-3 delims=/" %%a in ("!date:~4!") do (
    set /a "calMonth=13%%a %% 13"
    set /a "calYear=%%c"
)
set "calDate=???"

:yearIn
cls
echo Today is !date!
echo=
echo 0. Back
echo=
echo Input year (1583 - 4000) :
set /p "calYear="
if "!calYear!" == "0" goto mainMenu
if !calYear! GEQ 1583 if !calYear! LEQ 4000 goto monthIn
goto yearIn

:monthIn
cls
echo Today is !date!
echo=
echo 0. Back
echo=
echo Input month number (1 - 12) :
set /p "calMonth="
if "!calMonth!" == "0" goto mainMenu
if !calMonth! GEQ 1 if !calMonth! LEQ 12 goto generateCalendar
goto monthIn

:generateCalendar
if "!calDate!" == "!calMonth!/!calYear!" goto displayCalendar

if !calMonth! LSS 1 (
    set /a "calYear-=1"
    set "calMonth=12"
)
if !calMonth! GTR 12 (
    set /a "calYear+=1"
    set "calMonth=1"
)

set "calDate=!calMonth!/!calYear!"

set /a "leapYear=!calYear! %% 100"
if "!leapYear!" == "0" (
    set /a "leapYear=!calYear! %% 400"
) else set /a "leapYear=!calYear! %% 4"
if "!leapYear!" == "0" (
    set "leapYear=true"
) else set "leapYear=false"

for %%n in (1 3 5 7 8 10 12) do if "!calMonth!" == "%%n" set "monthDays=31"
for %%n in (4 6 9 11) do if "!calMonth!" == "%%n" set "monthDays=30"

if "!calMonth!" == "2" (
    if "!leapYear!" == "true" (
        set "monthDays=29"
    ) else set "monthDays=28"
)

call :dayof !calMonth!/1/!calYear! /n
set /a "tempVar1= 1 - !return!"

set "lineCount=1"
set "itemCount=1"
for /l %%l in (1,1,7) do set "displayLine%%l="
for /l %%n in (!tempVar1!,1,37) do (
    for %%l in (!lineCount!) do (
        set "tempVar1=  %%n"
        if %%n GEQ 1 (
            if %%n LEQ !monthDays! (
                set "displayLine%%l=!displayLine%%l! !tempVar1:~-2,2! "
            ) else if !itemCount! LEQ 7 set "displayLine%%l=!displayLine%%l!    "
        ) else set "displayLine%%l=!displayLine%%l!    "
        
        set /a "itemCount+=1"
        if "!itemCount!" == "8" if not "!displayLine%%l: =!" == "" (
            set "displayLine%%l=บ !displayLine%%l!บ"
            set "itemCount=1"
            set /a "lineCount+=1"
            set "displayLine!lineCount!="
        )
    )
)
set "displayLine!lineCount!=ศอออออออออออออออออออออออออออออผ"
set "spacing=                       "

set "tempVar1=1"
set "monthName="
for %%m in (
    January February March April May June July 
    August September October November December
) do (
    if "!tempVar1!" == "!calMonth!" set "monthName=%%m"
    set /a "tempVar1+=1"
)

:displayCalendar
cls
echo !spacing!     !monthName! !calYear! Calendar
echo !spacing!ษอออออออออออออออออออออออออออออป
echo !spacing!บ Sun Mon Tue Wed Thu Fri Sat บ
echo !spacing!ฬอออออออออออออออออออออออออออออน
for /l %%l in (1,1,7) do echo=!spacing!!displayLine%%l!
echo !spacing!^<-- [P] Previous   [N] Next --^>
echo=
echo 0. Back to menu
echo=
echo What do you want to do?
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if /i "!userInput!" == "N" set /a calMonth+=1
if /i "!userInput!" == "P" set /a calMonth-=1
goto generateCalendar


:calcDiffDate
set "date1=!date:~4!"
set "date2=!date:~4!"

set "time1=!time!"
set "time2=!time!"

cls
echo Date Format      MM/DD/YYYY
echo Current Date     !date1!
echo=
echo                  HH:MM:SS.SS
echo Current Time     !time1!
echo=
echo Input nothing to use the current date / time
echo=
set /p "date1=Input date 1  : "
set /p "time1=Input time 1  : "
echo=
set /p "date2=Input date 2  : "
set /p "time2=Input time 2  : "

call :diffdate !date2! !date1!
set "daysDiff=!return!"
call :difftime !time2! !time1! /n
if !return! LSS 0 (
    set /a "daysDiff-=1"
    set /a "return+=8640000"
)
call :ftime !return!
for /f "tokens=1-4 delims=:." %%a in ("!return!") do (
    set /a "hourDiff=24%%a %% 24"
    set /a "minsDiff=100%%b %% 100" 
    set /a "secsDiff=100%%c %% 100" 
    set /a "csecDiff=100%%d %% 100"
)

call :dayof !date1! /s
set "day1=!return!"
call :dayof !date2! /s
set "day2=!return!"

cls
echo Date and time 1 : !date1! (!day1!) !time1!
echo Date and time 2 : !date2! (!day2!) !time2!
echo=
echo Difference :
echo=
if not "!daysDiff!" == "0" set /p "=!daysDiff! days " < nul
if not "!hourDiff!" == "0" set /p "=!hourDiff! hours " < nul
if not "!minsDiff!" == "0" set /p "=!minsDiff! minutes " < nul
if not "!secsDiff!" == "0" set /p "=!secsDiff! seconds " < nul
if not "!secsDiff!" == "0" set /p "=!csecDiff! centiseconds " < nul
echo=
echo=
pause
goto mainMenu

rem Functions

:difftime [end_time] [start_time] [/n]
set "return=0"
for %%t in (%1:00:00:00:00 %2:00:00:00:00) do (
    for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
        set /a return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100
    )
    set /a return*=-1
)
if not "%3" == "/n" if !return! LSS 0 set /a return+=8640000
goto :EOF

:ftime [time_in_centisecond]
set /a tempVar1=%1 %% 8640000
set "return="
for %%n in (360000 6000 100 1) do (
    set /a tempVar2=!tempVar1! / %%n
    set /a tempVar1=!tempVar1! %% %%n
    set "tempVar2=?0!tempVar2!"
    set "return=!return!!tempVar2:~-2,2!:"
)
set "return=!return:~0,-4!.!return:~-3,2!"
goto :EOF

:diffdate [end_date] [start_date] [days_to_add]
set "return=0"
set "tempVar1=/%1/1/1/1  /%2/1/1/1"
set "tempVar1=!tempVar1:/0=/!"
for %%d in (!tempVar1!) do (
    for /f "tokens=1-3 delims=/" %%a in ("%%d") do (
        set /a "return+= (%%c-1) * 365  +  %%c/4 - %%c/100 + %%c/400"
        set /a "tempVar1=%%c %% 100"
        if "!tempVar1!" == "0" (
            set /a "tempVar1=%%c %% 400"
        ) else set /a "tempVar1=%%c %% 4"
        if "!tempVar1!" == "0" if %%a LEQ 2 set /a "return-=1"
        set /a "return+= 30 * (%%a-1) + %%a / 2 + %%b"
        if %%a GTR 8 set /a "return+=%%a %% 2"
        if %%a GTR 2 set /a "return-=2"
    )
    set /a return*=-1
)
set /a "return+=%3 + 0"
goto :EOF

:dayof [Date]
call :diffdate %1 1 1
set /a return%%=7
if "%2" == "/n" goto :EOF
if "%return%" == "0" set "return=Sunday"
if "%return%" == "1" set "return=Monday"
if "%return%" == "2" set "return=Tuesday"
if "%return%" == "3" set "return=Wednesday"
if "%return%" == "4" set "return=Thursday"
if "%return%" == "5" set "return=Friday"
if "%return%" == "6" set "return=Saturday"
if "%2" == "/s" set "return=!return:~0,3!"
goto :EOF
