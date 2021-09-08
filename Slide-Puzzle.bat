@goto main

rem Slide Puzzle
rem Updated on 2016-10-02
rem Made by wthe22 - http://winscr.blogspot.com/

:main
@echo off
prompt $s
setlocal EnableDelayedExpansion EnableExtensions
title Slide Puzzle by wthe22

chcp 437

:controlTypeIn
set "userInput=?"
cls
echo 1. Normal control
echo 2. Reverse control
echo=
echo 0. Exit
echo=
echo Choose your control:
set /p "controlType="
if "!controlType!" == "0" exit
if "!controlType!" == "1" goto gameModeIn
if "!controlType!" == "2" goto gameModeIn
goto controlTypeIn


:mainMenu
:gameModeIn
set "gameMode=?"
cls
echo Control type   : !controlType!
echo=
echo 1. Normal slide puzzle
echo 2. Plan solving mode
echo=
echo 0. Back
echo=
echo Choose game mode:
set /p "gameMode="
if "!gameMode!" == "0" goto controlTypeIn
if "!gameMode!" == "1" goto puzzleSizeIn
if "!gameMode!" == "2" goto puzzleSizeIn
goto controlTypeIn


:puzzleSizeIn
cls
echo Control type   : !controlType!
echo Game mode      : !gameMode!
echo=
echo 0. Back
echo=
echo Input puzzle size:   (Eg: 4x4)
set /p "userInput="
if "!userInput!" == "0" goto controlTypeIn
for /f "tokens=1-2 delims=Xx" %%a in ("!userInput: =!") do (
    if %%a0 GEQ 10 if %%a0 LEQ 2000 (
        if %%b0 GEQ 10 if %%b0 LEQ 2000 (
            set "puzzleRow=%%a"
            set "puzzleCol=%%b"
            goto puzzleReset
        )
    )
)
goto puzzleSizeIn


:puzzleReset
cls
echo Control type   : !controlType!
echo=
echo Puzzle size    : !puzzleRow!x!puzzleCol!
echo=
echo Scrambling puzzle...
echo=


title Slide Puzzle !puzzleRow!x!puzzleCol!
set /a "puzzleArea=!puzzleRow! * !puzzleCol!"

rem Setup Control
rem                                       ULDR
if "!controlType!" == "1" set "controlSet=SDWA"
if "!controlType!" == "2" set "controlSet=WASD"

rem Reset GUI
set "boardDisplay1="
set "boardDisplay2="
for /l %%n in (1,1,!puzzleCol!) do (
    set "boardDisplay1=!boardDisplay1!ÍÍÍÍÍÍ"
    set "boardDisplay2=!boardDisplay2!ÄÄÄÄÄÅ"
)
set "boardDisplay1=!boardDisplay1:~0,-1!"
set "boardDisplay2=!boardDisplay2:~0,-1!"
set "spacing="
for /l %%n in (1,1,5) do set "spacing=!spacing! "
for /l %%n in (1,1,5) do set "displayLine%%n="
if "!gameMode!" == "2" set "displayLine3=[Z] Undo"
set "displayLine4=[X] Quit"
if "!gameMode!" == "2" set "displayLine3=[C] Check"

rem Create Puzzle
set "numList="
set "emptyCell=?"
set /a "numMax=!puzzleArea!-1"
for /l %%n in (1,1,!numMax!) do (
    title Slide Puzzle !puzzleRow!x!puzzleCol! - Preparing... [%%n/!numMax!]
    set "tempVar1=    %%n"
    set "numList=!numList!!tempVar1:~-3,3!"
)
set "inversionSum=0"
for /l %%n in (!numMax!,-1,1) do (
    title Slide Puzzle !puzzleRow!x!puzzleCol! - Generating... [%%n/!numMax!]
    set /a "tempVar1=!random! %% %%n"
    set /a "tempVar1*=3"
    for %%c in (!tempVar1!) do (
        set /a "puzzleCell%%n= !numList:~%%c,3!"
        set "tempVar1=!numList:~%%c!"
        set "numList=!numList:~0,%%c!!tempVar1:~3!"
    )
    for /l %%l in (%%n,1,!numMax!) do if !puzzleCell%%n! GTR !puzzleCell%%l! set /a "inversionSum+=1"
)
set "emptyCell=!puzzleArea!"
set "puzzleCell!emptyCell!= "
set /a "inversionSum=!inversionSum! %% 2"
if "!inversionSum!" == "1" (
    set "tempVar1=!puzzleCell2!"
    set "puzzleCell2=!puzzleCell1!"
    set "puzzleCell1=!tempVar1!"
)

title Slide Puzzle !puzzleRow!x!puzzleCol!
set "startTime=!time!"

if "!gameMode!" == "1" goto puzzleSetup
if "!gameMode!" == "2" goto solveSetup
echo=
echo ERROR: Unknown gamemode
pause
exit

rem ============================================ Play Puzzle Mode ============================================

:puzzleSetup
set "moveCount=0"

:puzzlePlay
cls
call :puzzleBoard
choice /c X!controlSet! /n /m "> "
if "!errorlevel!" == "1" goto promptQuitPuzzle
if "!errorlevel!" == "2" call :move U
if "!errorlevel!" == "3" call :move L
if "!errorlevel!" == "4" call :move D
if "!errorlevel!" == "5" call :move R
call :checkSolved
if "!return!" == "true" goto puzzleSolved
goto puzzlePlay

:promptQuitPuzzle
echo=
choice /c YN /m "Quit the game?"
if "!errorlevel!" == "1" goto mainMenu
goto puzzlePlay


rem ============================================ Plan Solvings Mode ============================================

:solveSetup
set "moveCount=0"
set "moveSolvings="

:solvingIn
cls
call :puzzleBoard
echo=
echo Input solvings:
choice /c ZXC!controlSet! /n /m "!moveSolvings!"
set "userInput=!errorlevel!"
if "!userInput!" == "1" goto undoSolving
if "!userInput!" == "2" goto promptQuitSolving
if "!userInput!" == "3" goto promptSimulate
set /a "movesCount+=1"
if "!userInput!" == "4" set "moveSolvings=!moveSolvings!U"
if "!userInput!" == "5" set "moveSolvings=!moveSolvings!L"
if "!userInput!" == "6" set "moveSolvings=!moveSolvings!D"
if "!userInput!" == "7" set "moveSolvings=!moveSolvings!R"
goto solvingIn


:undoSolving
if "!movesCount!" == "0" goto solvingIn
set /a "movesCount-=1"
set "moveSolvings=!moveSolvings:~0,-1!"
goto solvingIn

:promptQuitSolving
echo=
choice /c YN /m "Quit now?"
if "!errorlevel!" == "1" goto mainMenu
goto solvingIn


:promptSimulate
echo=
choice /c YN /m "Check solvings now?"
if "!errorlevel!" == "2" goto solvingIn

set "moveCount=0"

cls
call :puzzleBoard
echo=
echo Moves :
echo=!moveSolvings!
pause > nul

:simulateSolving
call :checkSolved
if "!return!" == "true" goto puzzleSolved
if not defined moveSolvings goto puzzleUnsolved

set /a "moveCount+=1"
if "!moveSolvings:~0,1!" == "U" call :move U
if "!moveSolvings:~0,1!" == "D" call :move D
if "!moveSolvings:~0,1!" == "L" call :move L
if "!moveSolvings:~0,1!" == "R" call :move R
set "moveSolvings=!moveSolvings:~1!"
cls
call :puzzleBoard
echo=
echo Moves :
echo=!moveSolvings!
pause > nul
goto simulateSolving

rem ============================================ Common Menu ============================================

:puzzleSolved
call :difftime !time! !startTime!
call :ftime !return!
cls
call :puzzleBoard
echo=
echo Congratulations, you solved the puzzle in !return! with !moveCount! moves
pause > nul
goto mainMenu

:puzzleUnsolved
cls
call :puzzleBoard
echo=
echo You failed to solved the puzzle....
pause > nul
goto mainMenu

rem Functions

:checkSolved
set "return=false"
set /a "tempVar1=!puzzleArea!-1"
if not "!emptyCell!" == "!puzzleArea!" goto :EOF
for /l %%n in (!tempVar1!,-1,1) do if not "!puzzleCell%%n!" == "%%n" goto :EOF
set "return=true"
goto :EOF


:move
if "%1" == "U" set /a tempVar1=!emptyCell! - !puzzleCol!
if "%1" == "L" set /a tempVar1=!emptyCell! - 1
if "%1" == "D" set /a tempVar1=!emptyCell! + !puzzleCol!
if "%1" == "R" set /a tempVar1=!emptyCell! + 1
set /a tempVar2=!tempVar1! %% !puzzleCol!
if "%1" == "L" if "!tempVar2!" == "0" goto :EOF
if "%1" == "R" if "!tempVar2!" == "1" goto :EOF
if "%1" == "U" if !tempVar1! LSS 1 goto :EOF
if "%1" == "D" if !tempVar1! GTR !puzzleArea! goto :EOF
set "puzzleCell!emptyCell!=!puzzleCell%tempVar1%!"
set "puzzleCell!tempVar1!= "
set "emptyCell=!tempVar1!"
set /a moveCount+=1
goto :EOF


:puzzleBoard
echo É!boardDisplay1!»!spacing!Moves : !moveCount!
set "lineCount=1"
for /l %%a in (1,1,!puzzleArea!) do (
    set "tempVar1=    !puzzleCell%%a!"
    if !puzzleCell%%a!0 LEQ 90 set "tempVar1=!tempVar1! "
    set "display=!display! !tempVar1:~-3,3! ³"
    set /a tempVar1= %%a %% !puzzleCol!
    if "!tempVar1!" == "0" (
        set /a "lineCount+=1"
        for %%l in (!lineCount!) do echo º!display:~0,-1!º!spacing!!displayLine%%l!
        if not "%%a" == "!puzzleArea!" (
            set /a "lineCount+=1"
            for %%l in (!lineCount!) do echo º!boardDisplay2!º!spacing!!displayLine%%l!
        )
        set "display="
    )
)
echo È!boardDisplay1!¼
goto :EOF
rem Side displays
set /a tempVar2+=1
set "display1=!display1!     Time:"
set "display2=!display2!     !return!"
set "display4=!display4!     Moves:"
set "display5=!display5!     !movesCount!"
goto :EOF


:difftime [end_time] [start_time] [/n]
set "return=0"
for %%t in (%1:00:00:00:00 %2:00:00:00:00) do (
    for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
        set /a "return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100"
    )
    set /a "return*=-1"
)
if not "%3" == "/n" if !return! LSS 0 set /a "return+=8640000"
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


