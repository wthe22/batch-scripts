@echo off
prompt $s
title Clock
setlocal EnableDelayedExpansion

set "statusFile=!temp!\BatchScript\Clock.bat"
set "stopKey=asd"
set "bell="

cd /d "%~dp0"

set "GUIDisplay1=1011011111"
set "GUIDisplay2=3222311233"
set "GUIDisplay3=0011111011"
set "GUIDisplay4=3212223232"
set "GUIDisplay5=1011011011"

for %%n in (1 3 5) do (
    set "GUIDisplay%%n=!GUIDisplay%%n:0=     !"
    set "GUIDisplay%%n=!GUIDisplay%%n:1= ²²² !"
)
for %%n in (2 4) do (
    set "GUIDisplay%%n=!GUIDisplay%%n:1=²    !"
    set "GUIDisplay%%n=!GUIDisplay%%n:2=    ²!"
    set "GUIDisplay%%n=!GUIDisplay%%n:3=²   ²!"
)

set parameter=%1
if not defined parameter goto scriptMain
if "!parameter!" == "Main2" goto scriptMain2
if "!parameter!" == "Main2nr" goto scriptMain2_noreset
goto scriptMain

:scriptMain
set "splitScreen=false"

:mainMenu
title Clock
if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=SplashScreen" > "!statusFile!"
)
color 07
cls
echo 1. Show clock
echo 2. Stopwatch
echo 3. Timer
echo 4. Alarm
echo=
echo S. Split screen mode [!splitScreen!]
echo 0. Exit
echo=
echo Which tools do you want to use?
set /p "userInput="
if "!userInput!" == "0" goto cleanUp
if "!userInput!" == "1" goto clockSetup
if "!userInput!" == "2" goto stopwatchStart
if "!userInput!" == "3" goto timerIn
if "!userInput!" == "4" goto alarmIn
if /i "%userInput%" == "S" call :toggleSplit
goto mainMenu

:cleanUp
echo set "scriptStatus=Exit" > "!statusFile!"
exit

:clockSetup
if /i "!splitScreen!" == "true" goto clockSetup_s

:clockSetup_ns
call :displayMake "!time:~0,-3!"
cls
echo Today is %date%
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo 0. Back
echo=
echo Press enter to update...
echo=
set /p "userInput=>"
if "!userInput!" == "0" goto mainMenu
goto clockSetup_ns

:clockSetup_s
echo set "scriptStatus=Clock" > "!statusFile!"
cls
echo 0. Back
echo=
echo What do you want to do?
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
goto clockSetup_s



:stopwatchStart
title Stopwatch
color 1F
if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=ShowText" 
    echo set "displayText=00:00:00.00"
    echo set "displayTitle=Stopwatch"
) > "!statusFile!"
cls
echo 0. Back
echo=
echo Press enter to lap
echo Input "!stopKey!" to stop
echo=
echo Press enter to start stopwatch
echo=
set /p "userInput=>"
if "!userInput!" == "0" goto mainMenu

set "lapCount=1"
set "time1=!time!"
if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=Stopwatch" 
    echo set "time1=!time1!"
) > "!statusFile!"

:stopwatch_Lap
color 2F
cls
echo Stopwatch started at !time1!
echo=
for /l %%n in (1,1,!lapCount!) do echo [!time%%n!] Lap %%n
echo=
echo Press enter to lap
echo Input "!stopKey!" to stop
echo=
set /p "userInput=>"
set /a lapCount+=1
set "time!lapCount!=!time!"
if not "!userInput!" == "!stopKey!" goto stopwatch_Lap

call :difftime !time1! !time%lapCount%!
call :ftime !return!
if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=ShowText" 
    echo set "displayText=!return!"
    echo set "displayTitle=Stopwatch"
) > "!statusFile!"

color 4F
cls
echo Stopwatch started at !time1!
echo=
for /l %%n in (1,1,!lapCount!) do echo [!time%%n!] Lap %%n
echo=
echo Stopwatch stopped at !time%lapCount%!

call :difftime 0:00:00.00 !time1!
set "timeCS2=!return!"
for /l %%n in (2,1,!lapCount!) do (
    for /f "tokens=1-4 delims=:." %%a in ("!time%%n: =!") do (
        set /a timeCS1=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100
    )
    set /a tempVar1=!timeCS1! - !timeCS2!
    if !tempVar1! LSS 0 set /a tempVar1+=8640000
    set "return="
    for %%t in (360000 6000 100 1) do (
        set /a tempVar2=!tempVar1! / %%t
        set /a tempVar1=!tempVar1! %% %%t
        set "tempVar2=?0!tempVar2!"
        set "return=!return!!tempVar2:~-2,2!:"
    )
    set "diffPrev%%n=!return:~0,-4!.!return:~-3,2!"
    set "timeCS2=!timeCS1!"
)
echo=
pause

color 07
cls
echo      Time    ^| Difference  ^| Label
echo=
echo  !time1!   -----------  Start time
set /a "lapCount-=1"
for /l %%n in (2,1,!lapCount!) do echo  !time%%n!   !diffPrev%%n!  Lap %%n
set /a "lapCount+=1"
echo  !time%lapCount%!   !diffPrev%lapCount%!  End time
echo=
pause
goto mainMenu



:timerIn
if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=SplashScreen" 
) > "!statusFile!"
title Timer
cls
echo Range  : 1 - 43200
echo=
echo Timer cannot be more than 12 hours
echo=
echo 0. Back
echo=
echo Input time in seconds  :
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if !userInput! LSS 0 goto timerIn
if !userInput! GTR 43200 goto timerIn

set /a timerCS=!userInput! * 100
call :ftime !timerCS!
set "timerTime=!return!"

if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=ShowText" 
    echo set "displayText=!timerTime!"
    echo set "displayTitle=Timer"
) > "!statusFile!"

call :displayMake "!return!"
cls
if /i "!splitScreen!" == "true" (
    echo Timer countdown    : !timerTime!
) else (
    echo=
    for /l %%n in (1,1,7) do echo=!displayLine%%n!
)
echo=
echo 0. Back
echo=
echo Press enter to start timer...
echo=
set /p "userInput=>"
if "!userInput!" == "0" goto timerIn

set "startTime=!time!"
call :difftime 00:00:00.00 !startTime!
set /a return+=!timerCS!
call :ftime !return!
set "alarmTime=!return!"

if /i "!splitScreen!" == "true" goto timer_s_wait

:timer_ns_update
call :difftime !time! !alarmTime!
if !return! GEQ 4320000 goto timer_ns_stop
call :ftime !return!
call :displayMake "!return!"
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
goto timer_ns_update

:timer_ns_stop
call :displayMake "00:00:00.00"
title Timer
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo    Time's Up^^!^^!^^!
for /l %%n in (1,1,5) do set /p "=!bell!" < nul
echo=
echo Script will switch to stopwatch mode to count overtime
echo Press enter to stop the stopwatch...
pause > nul
goto timer_result

:timer_s_wait
(
    echo set "scriptStatus=Timer" 
    echo set "displayTitle=Timer"
    echo set "alarmTime=!alarmTime!"
) > "!statusFile!"
cls
echo Timer countdown    : !timerTime!
echo=
echo Press enter to stop timer...
pause > nul
echo set "scriptStatus=Unknown" > "!statusFile!"
goto timer_result

:timer_result
set "stopTime=!time!"
call :difftime !startTime! !stopTime!
call :ftime !return!
set "totalTime=!return!"
call :difftime !alarmTime! !stopTime! /n
set "timingText=Early press time"
if !return! GEQ 0 (
    set "timingText=Late press time "
) else set /a "return*=-1"
call :ftime !return!
set "pressTime=!return!"

cls
echo Timer countdown    : !timerTime!
echo !timingText!   : !pressTime!
echo Total time         : !totalTime!
echo=
pause
goto mainMenu

:alarmIn
title Alarm
cls
echo                1/100 Seconds
echo                 Seconds ^|
echo              Minutes ^|  ^|
echo             Hours ^|  ^|  ^|
echo                ^|  ^|  ^|  ^|
echo Time format    HH:MM:SS.SS
echo=
echo 0. Back
echo=
echo Time cannot be more than 12 hours from now
echo=
echo Input time :
set /p "userInput="
if "!userInput!" == "0" goto mainMenu

call :difftime 0:00:00.00 !userInput!
call :ftime !return!
set "alarmTime=!return!"

if /i "!splitScreen!" == "true" (
    echo set "scriptStatus=ShowText" 
    echo set "displayText=!alarmTime!"
    echo set "displayTitle=Alarm"
) > "!statusFile!"

call :displayMake "!alarmTime!"
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo 0. Back
echo=
echo Press enter to start alarm...
echo=
set /p "userInput=>"
if "!userInput!" == "0" goto alarmIn

call :displayMake "!return!"

if /i "!splitScreen!" == "true" goto alarm_s_update

:alarm_ns_update
call :difftime !time! !alarmTime!
if !return! GEQ 4320000 goto alarm_ns_stop
call :ftime !return!
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo !return! away from alarm
timeout /t 1 > nul
goto alarm_ns_update

:alarm_ns_stop
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo    Time's Up^^!^^!^^!
for /l %%n in (1,1,5) do set /p "=!bell!" < nul
echo=
echo Script will switch to stopwatch mode to count overtime
echo Press enter to stop the stopwatch...
pause > nul
goto alarm_result

:alarm_s_update
(
    echo set "scriptStatus=Timer" 
    echo set "displayTitle=Alarm"
    echo set "alarmTime=!alarmTime!"
) > "!statusFile!"
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo Press enter to stop the alarm...
pause > nul
echo set "scriptStatus=Unknown" > "!statusFile!"
goto alarm_result

:alarm_result
set "stopTime=!time!"
call :difftime !alarmTime! !stopTime! /n
set "timingText=Early press time"
if !return! GEQ 0 (
    set "timingText=Late press time "
) else set /a "return*=-1"
call :ftime !return!
set "pressTime=!return!"

cls
echo Alarm time         : !timerTime!
echo !timingText!   : !pressTime!
echo=
pause
goto mainMenu

rem Sound a bell 9x ?
rem Open a file ?
rem Show msgbox ?

rem Screen 2 Scripts =============================================================

:scriptMain2
echo set "scriptStatus=Unknown" > "!statusFile!"
:scriptMain2_noreset
mode 80,15
title Clock - Display Window
cls
echo=
echo        ²²²²²       ²²²
echo      ²²²²²²²²²²    ²²²                                       ²²     ²²
echo    ²²²        ²²   ²²²                                       ²²    ²²
echo   ²²²              ²²²      ²²²²²²²²²          ²²²²²²²²      ²²   ²²
echo  ²²²               ²²²    ²²²²     ²²²²     ²²²²²    ²²²²    ²²  ²²
echo  ²²²               ²²²   ²²²         ²²²   ²²²         ²²²   ²²²²²
echo  ²²²               ²²²   ²²²         ²²²   ²²                ²²²²²
echo   ²²²              ²²²   ²²²         ²²²   ²²                ²²  ²²
echo    ²²²        ²²   ²²²    ²²²²     ²²²²    ²²²         ²²²   ²²   ²²
echo      ²²²²²²²²²²    ²²²      ²²²²²²²²²       ²²²²²    ²²²²    ²²    ²²
echo        ²²²²²       ²²²                         ²²²²²²²²      ²²     ²²
echo=
echo                  http://winscr.blogspot.com/                         by wthe22
goto getStatus

rem Logo 2
mode 80,12
title Clock - Display Window
cls
echo=
echo       ²²²²²²²      ²²²                                     
echo     ²²²²²²²²²²²    ²²²      ²²²²²²²²²        ²²²²²²²²²     ²²    ²²
echo    ²²²       ²²²   ²²²    ²²²²     ²²²²     ²²²     ²²²    ²²   ²²
echo   ²²²              ²²²   ²²²         ²²²   ²²²             ²²  ²²
echo   ²²²              ²²²   ²²²         ²²²   ²²²             ²²²²²
echo    ²²²       ²²²   ²²²    ²²²²     ²²²²     ²²²     ²²²    ²²  ²²
echo     ²²²²²²²²²²²    ²²²      ²²²²²²²²²        ²²²²²²²²²     ²²   ²²
echo       ²²²²²²²      ²²²                                     ²²    ²²
echo=
echo             http://winscr.blogspot.com/                         by wthe22


:getStatus
if exist "!statusFile!" (
    call "!statusFile!"
) else exit

if /i "!scriptStatus!" == "Exit" goto s2_cleanUp
if /i "!scriptStatus!" == "Stopwatch" goto s2_stopwatch
if /i "!scriptStatus!" == "Timer" goto s2_timer
if /i "!scriptStatus!" == "TimerOvertime" goto s2_timerOvertime

timeout /t 1 > nul

if exist "!statusFile!" (
    call "!statusFile!"
) else exit

if /i "!scriptStatus!" == "ShowText" goto s2_showText
if /i "!scriptStatus!" == "Clock" goto s2_clock
if /i "!scriptStatus!" == "SplashScreen" goto scriptMain2
goto getStatus

:s2_cleanUp
del /f /q "!statusFile!"
exit

:s2_showText
echo set "scriptStatus=Unknown" > "!statusFile!"
title !displayTitle!
call :displayMake "!displayText!"
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
goto getStatus

:s2_clock
call :displayMake "!time:~0,-3!"
title Clock
cls
echo Today is %date%
echo=
echo Time   :
for /l %%n in (1,1,7) do echo=!displayLine%%n!
goto getStatus

:s2_stopwatch
call :difftime !time1! !time!
call :ftime !return!
call :displayMake "!return!"
title Stopwatch
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
goto getStatus

:s2_timer
call :difftime !time! !alarmTime!
if !return! GEQ 4320000 (
    for /l %%n in (1,1,5) do set /p "=!bell!" < nul
    echo set "scriptStatus=TimerOvertime" > "!statusFile!"
)
call :ftime !return!
call :displayMake "!return!"
title !displayTitle! - Countdown
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
goto getStatus

:s2_timerOvertime
call :difftime !alarmTime! !time!
call :ftime !return!
call :displayMake "!return!"
title !displayTitle! - Overtime
cls
echo=
for /l %%n in (1,1,7) do echo=!displayLine%%n!
echo=
echo    Time's Up^!^!^!
goto getStatus

rem Display functions

:toggleSplit
if "!splitScreen!" == "true" (
    set "splitScreen=false"
    echo set "scriptStatus=Exit" > "!statusFile!"
) else (
    set "splitScreen=true"
    echo set "scriptStatus=Menu" > "!statusFile!"
    start "" "%~f0" Main2
)
goto :EOF

:displayMake
for /l %%n in (1,1,7) do set "displayLine%%n=           "
set "displayText=%~1"
for /l %%t in (0,1,15) do (
    if defined displayText (
        if "!displayText:~0,1!" == "." (
            for /l %%n in (1,1,6) do set "displayLine%%n=!displayLine%%n!    "
            set "displayLine7=!displayLine7!  @ "
        ) else if "!displayText:~0,1!" == ":" (
            for %%n in (1 3 4 5 7) do set "displayLine%%n=!displayLine%%n!    "
            for %%n in (2 6) do set "displayLine%%n=!displayLine%%n!  @ "
        ) else (
            set /a "tempVar1=5 * !displayText:~0,1! + 0"
            for %%i in (!tempVar1!) do (
                set "displayLine1=!displayLine1! !GUIDisplay1:~%%i,5!"
                set "displayLine2=!displayLine2! !GUIDisplay2:~%%i,5!"
                set "displayLine3=!displayLine3! !GUIDisplay2:~%%i,5!"
                set "displayLine4=!displayLine4! !GUIDisplay3:~%%i,5!"
                set "displayLine5=!displayLine5! !GUIDisplay4:~%%i,5!"
                set "displayLine6=!displayLine6! !GUIDisplay4:~%%i,5!"
                set "displayLine7=!displayLine7! !GUIDisplay5:~%%i,5!"
            )
        )
        set "displayText=!displayText:~1!"
    )
)
goto :EOF

rem Functions

:difftime [start_time] [end_time] [/n]
set "return=0"
for %%t in (%2:00:00:00:00 %1:00:00:00:00) do (
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
