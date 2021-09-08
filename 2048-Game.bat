@goto main

rem 2048 Game v1.1
rem Updated on 2016-09-29
rem Made by wthe22 - http://winscr.blogspot.com/


:main
@echo off
title 2048 by wthe22
prompt $s
cd /d "%~dp0"
setlocal EnableDelayedExpansion EnableExtensions

set "sideLength=4"
set "cellSize=5"
set "hShift=7"


2> nul (
    chcp 437
) && (
    call :ASCII_GUI     This is the default GUI
) || call :UTF8_GUI     Backup GUI, In case ASCII doesn't display correctly


rem Scripts starts here

rem Build GUI
set "hShiftSpace="
for /l %%n in (1,1,!hShift!) do set "hShiftSpace=!hShiftSpace! "
set /a "tempVar1=!cellSize! + 3"
set "tempVar2="
for /l %%n in (1,1,!tempVar1!) do set "tempVar2=!tempVar2! "
set "smallBorderLine=!tempVar2: =%hBorder%!"
set "smallMidSpace=!tempVar2:~1!!vGrid!"
set "smallGridLine=!tempVar2:~1!%cGrid%"
set "smallGridLine=!smallGridLine: =%hGrid%!"

set "borderLine="
set "midSpace="
set "gridLine="
for /l %%n in (1,1,!sideLength!) do (
    set "borderLine=!borderLine!!smallBorderLine!"
    set "midSpace=!midSpace!!smallMidSpace!"
    set "gridLine=!gridLine!!smallGridLine!"
)
set "topLine=!ulCorner!!borderLine:~1!!urCorner!"
set "bottomLine=!dlCorner!!borderLine:~1!!drCorner!"
set "midSpace=!vBorder!!midSpace:~0,-1!!vBorder!"
set "gridLine=!vBorder!!gridLine:~0,-1!!vBorder!"

set "msg_1-3=[X] Exit"
set "msg_1-4=[R] Restart"
set "msg_2-2=Use WASD to control"


:game_instructions
cls
echo How to play:
echo=
echo Use WASD to control
echo=
echo                 UP
echo=
echo                 ^^
echo                 ^|
echo               ษอออป
echo               บ W บ
echo           ษอออฮอออฮอออป
echo Left  ^<-- บ A บ S บ D บ --^> Right
echo           ศอออสอออสอออผ
echo                 ^|
echo                 V
echo=
echo               Down
echo=
pause

:game_setup
call :matrix set numberBoard " "
call :spawnNumber numberBoard
set "gameWon=false"
set "gameScore=0"

:game_continue
if "!gameWon!" == "false" (
    call :find2048
    if "!gameWon!" == "true" goto game_win
)

call :spawnNumber numberBoard
call :matrix copy numberBoard prevBoard

set "prevScore=!gameScore!"
set "difference=0"
for %%d in (Up Left Down Right) do (
    call :move%%d numberBoard
    call :matrix compare numberBoard prevBoard
    set /a "difference+=!return!"
    call :matrix copy prevBoard numberBoard
)
set "gameScore=!prevScore!"
if "!difference!" == "0" goto game_end


:game_display
cls
call :displayBoard numberBoard
echo=
choice /c ZXRWASD /n /m "> "
set "userInput=!errorlevel!"
if "!userInput!" == "1" rem Undo?
if "!userInput!" == "2" goto game_promptQuit
if "!userInput!" == "3" goto game_promptReset
if !userInput! LSS 4 goto game_display
if "!userInput!" == "4" call :moveUp    numberBoard
if "!userInput!" == "5" call :moveLeft  numberBoard
if "!userInput!" == "6" call :moveDown  numberBoard
if "!userInput!" == "7" call :moveRight numberBoard
call :matrix compare numberBoard prevBoard
if "!return!" == "0" goto game_display
goto game_continue


:game_promptQuit
choice /c YN /m "Are you sure you want to quit? "
if "!errorlevel!" == "1" exit
goto game_display


:game_promptReset
choice /c YN /m "Are you sure you want to start over? "
if "!errorlevel!" == "1" goto game_setup
goto game_display


:game_win
cls
call :displayBoard numberBoard
echo=
echo You reached 2048^^! You won the game
echo=
choice /c YN /m "Continue playing? "
if "!errorlevel!" == "1" goto game_continue
goto game_instructions


:game_end
cls
call :displayBoard numberBoard
echo=
echo Game over
echo=
choice /c YN /m "Play again? "
if "!errorlevel!" == "1" goto game_instructions
exit


rem ======================================== Functions ========================================

:matrix
if /i "%1" == "compare" set "return=0"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        if /i "%1" == "set"     set "%2_%%i-%%j=%~3"
        if /i "%1" == "copy"    set "%3_%%i-%%j=!%2_%%i-%%j!"
        if /i "%1" == "delete"  set "%2_%%i-%%j="
        if /i "%1" == "compare" if not "!%2_%%i-%%j!" == "!%3_%%i-%%j!"  set /a "return+=1"
    )
)
goto :EOF
rem SET [Matix_Name] [Source_Array]
rem COPY [Source_Matix] [Destination_Matrix]
rem DELETE [Matix_Name]
rem COUNT [Matix_Name] [Symbol]
rem COMPARE [Matix_Name] [Matix_Name]
goto :EOF


:randEmptyCell [Matix_Name]
set "cellList="
set "tempList="
set "listCount=0"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        set "tempVar1=     %%i-%%j"
        if "!%1_%%i-%%j!" == " " (
            set "tempList=!tempList!!tempVar1:~-5,5!"
            set /a "listCount+=1"
        )
    )
)
if "!listCount!" == "0" goto :EOF
set /a "tempVar1=!random! %% !listCount!"
set /a "tempVar1*=5"
for %%n in (!tempVar1!) do set "cellCode=!tempList:~%%n,5!"
for %%c in (!cellCode!) do set "cellCode=%%c"
goto :EOF


:spawnNumber [Matix_Name]
call :randEmptyCell %1
if "!listCount!" == "0" goto :EOF
set /a "tempVar1=!random! %% 10"
set "%1_!cellCode!=2"
if "!tempVar1!" == "0" set "%1_!cellCode!=4"
goto :EOF

:displayBoard [Matix_Name]
echo !hShiftSpace!!topLine!!hShiftSpace!Score : !gameScore!
set "msg2="
for /l %%i in (1,1,!sideLength!) do (
    set "display=!vBorder!"
    for /l %%j in (1,1,!sideLength!) do (
        set "tempVar1=     !%1_%%i-%%j!"
        set "display=!display! !tempVar1:~-%cellSize%,%cellSize%! !vGrid!"
    )
    set "display=!display:~0,-1!!vBorder!"
    echo !hShiftSpace!!midSpace!!hShiftSpace!!msg_%%i-1!
    echo !hShiftSpace!!display!!hShiftSpace!!msg_%%i-2!
    echo !hShiftSpace!!midSpace!!hShiftSpace!!msg_%%i-3!
    if "%%i" == "!sideLength!" (
        echo !hShiftSpace!!bottomLine!!hShiftSpace!!msg_%%i-4!
    ) else echo !hShiftSpace!!gridLine!!hShiftSpace!!msg_%%i-4!
)
goto :EOF


:find2048 [Matix_Name]
set "gameWon=0"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        if "!%1_%%i-%%j!" == "2048" set "gameWon=true"
    )
)
goto :EOF


:moveUp [Matix_Name]
set "loop1Var=%%j"
set "loop2Var=%%i"
set "loop2=1,1,!sideLength!"
set "loop3=%%i,-1,1"
goto move


:moveDown [Matix_Name]
set "loop1Var=%%j"
set "loop2Var=%%i"
set "loop2=!sideLength!,-1,1"
set "loop3=%%i,1,!sideLength!"
goto move


:moveLeft [Matix_Name]
set "loop1Var=%%i"
set "loop2Var=%%j"
set "loop2=1,1,!sideLength!"
set "loop3=%%j,-1,1"
goto move


:moveRight [Matix_Name]
set "loop1Var=%%i"
set "loop2Var=%%j"
set "loop2=!sideLength!,-1,1"
set "loop3=%%j,1,!sideLength!"
goto move


:move
for /l %loop1Var% in (1,1,!sideLength!) do (
    set "prevNum=-"
    set "prevCell=-"
    for /l %loop2Var% in (%loop2%) do if not "!%1_%%i-%%j!" == " " (
        if "!prevNum!" == "!%1_%%i-%%j!" (
            set /a "tempVar1=!%1_%%i-%%j! * 2"
            set /a "gameScore+=!tempVar1!"
            set "%1_!prevCell!=!tempVar1!"
            set "%1_%%i-%%j= "
            set "prevNum=-"
            set "prevCell=-"
        )
        set "prevNum=!%1_%%i-%%j!"
        set "prevCell=%%i-%%j"
    )
)
for /l %loop1Var% in (1,1,!sideLength!) do (
    for /l %loop2Var% in (%loop2%) do if not "!%1_%%i-%%j!" == " " (
        set "emptyCell="
        for /l %loop2Var% in (%loop3%) do if "!%1_%%i-%%j!" == " " set "emptyCell=%%i-%%j"
        if defined emptyCell (
            set "%1_!emptyCell!=!%1_%%i-%%j!"
            set "%1_%%i-%%j= "
        )
    )
)
goto :EOF

rem ======================================== GUI ========================================

:ASCII_GUI
set "vBorder=บ"
set "hBorder=อ"
set "vGrid=ณ"
set "cGrid=ล"
set "hGrid=ฤ"
set "ulCorner=ษ"
set "urCorner=ป"
set "dlCorner=ศ"
set "drCorner=ผ"
goto :EOF


:UTF8_GUI
set "vBorder=|"
set "hBorder=="
set "vGrid=|"
set "cGrid=+"
set "hGrid=-"
set "ulCorner=+"
set "urCorner=+"
set "dlCorner=+"
set "drCorner=+"
goto :EOF
