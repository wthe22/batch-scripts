prompt $s
@echo off
title Tic Tac Toe
setlocal EnableDelayedExpansion

set dataAddress=BatchScript_Data\TicTacToe
if not exist "%dataAddress%" md "%dataAddress%"
set "logName=AI_Weakness.log"
set "moveLogsAddress=%dataAddress%\%logName%"
set "gameMode=2P"
set "p1Code=X"
set "gameDebug=1"

:setup
set "turnCode=X"
set gameTurnNum=1
for %%a in (A B C) do (
    for /l %%n in (1,1,3) do (
        set "%%a%%n= "
    )
)
for /l %%n in (1,1,9) do (
    set "move%%n="
    set "moveType%%n="
)

:inMode
cls
echo 1. Single Player
echo 2. 2 Players
echo 3. Previous setting
echo 4. Test AI vs. AI
echo 5. Moves Simulator
echo=
echo 0. Exit
echo=
choice /c 012345 /n /m "Choose your mode: "
set /a userInput=%errorlevel%-1
if "%userInput%" == "0" exit
if "%userInput%" == "3" (
    if "%gameMode%"=="AIT" goto testAI
    if "%p1Code%"=="O" if "%gameMode%"=="AI" goto gameAI%AILvl%
    goto viewBoard
)
if "%userInput%" == "4" goto inAILvl
set "gameMode=2P"
set "p1Code=X"
if "%userInput%" == "2" goto viewBoard
if "%userInput%" == "5" goto gameMovesIn
set "gameMode=AI"
cls
echo 1. Very Easy
echo 2. Medium
echo 3. Very Hard
echo=
choice /c 123 /n /m "Choose your difficulty level: "
set "AILvl=%errorlevel%"
goto inTurnCode

:inAILvl
set "gameMode=AIT"
cls
echo 1. Very Easy
echo 2. Medium
echo 3. Very Hard
echo=
choice /c 123 /n /m "Choose AI_1 difficulty level: "
set "AIXLvl=%errorlevel%"
cls
echo 1. Very Easy
echo 2. Medium
echo 3. Very Hard
echo=
choice /c 123 /n /m "Choose AI_2 difficulty level: "
set "AIOLvl=%errorlevel%"

:testAI
cls
call :displayBoard
echo=
echo %turnCode%'s Turn
echo=
echo Press any key to make the AI move...
if "%gameDebug%" == "0" pause > nul
if "%turnCode%"=="X" set "checkRoute=OO XX"
if "%turnCode%"=="O" set "checkRoute=XX OO"
goto gameAI!AI%turnCode%Lvl!

:inTurnCode
cls
set "p1Code=X"
set "turnCode=X"
set "checkRoute=XX OO"
echo X starts first
echo=
choice /c XO /m "What would player 1 play as?"
if %errorlevel% == 2 set "p1Code=O"
if "%p1Code%"=="O" (
    set "checkRoute=OO XX"
    if "%gameMode%"=="AI" goto gameAI%AILvl%
)

:viewBoard
cls
call :displayBoard
echo=
echo %turnCode%'s Turn
echo=
echo Choose the box by typing in the number and the letter respectively. (eg.A1)
set /p "cellCode="
call :String_UPPERCASE cellCode
if "%cellCode%"=="X" goto setup
if "!%cellCode%!"==" " goto markCell
echo=
echo Invalid cell code
pause
goto viewBoard

:gameMovesIn
set "gameMode=S"
cls
echo Input game moves:
echo=
set /p "gameMoves="

set "gameTurnNum=1"
:gameSimulate
set /a tempVar1=(%gameTurnNum%-1) * 3
set "cellCode=!gameMoves:~%tempVar1%,2!"
cls
call :displayBoard
echo=
echo [ Move %gameTurnNum%] [%turnCode% Turn] %cellCode%
echo=
pause
if "%gameTurnNum%" == "9" goto inMode

:markCell
rem Mark the cell
set "%cellCode%=%turnCode%"
set "move%gameTurnNum%=%cellCode%"
if "%cellCode%" == "A1" set "moveType%gameTurnNum%=C"
if "%cellCode%" == "B1" set "moveType%gameTurnNum%=E"
if "%cellCode%" == "C1" set "moveType%gameTurnNum%=C"
if "%cellCode%" == "A2" set "moveType%gameTurnNum%=E"
if "%cellCode%" == "B2" set "moveType%gameTurnNum%=O"
if "%cellCode%" == "C2" set "moveType%gameTurnNum%=E"
if "%cellCode%" == "A3" set "moveType%gameTurnNum%=C"
if "%cellCode%" == "B3" set "moveType%gameTurnNum%=E"
if "%cellCode%" == "C3" set "moveType%gameTurnNum%=C"
set /a gameTurnNum+=1

:gameCheck
rem Check the game
set "gameStatus=Draw"

rem Check for draw
for %%a in (A B C) do (
    for /l %%n in (1,1,3) do (
        if "!%%a%%n!" == " " set "gameStatus=Unknown"
    )
)

rem Check for win
for %%c in (XXX OOO) do (
    for    %%a in (A B C) do if "!%%a1!!%%a2!!%%a3!" == "%%c" set "gameStatus=%turnCode% Win"
    for /l %%n in (1,1,3) do if "!A%%n!!B%%n!!C%%n!" == "%%c" set "gameStatus=%turnCode% Win"
    if "%A1%%B2%%C3%" == "%%c" set "gameStatus=%turnCode% Win"
    if "%A3%%B2%%C1%" == "%%c" set "gameStatus=%turnCode% Win"
)

if not "%gameStatus%" == "Unknown" goto announceGame

:changePlayer
if "%turnCode%" == "X" set "turnCode=T"
if "%turnCode%" == "O" set "turnCode=X"
if "%turnCode%" == "T" set "turnCode=O"

if "%gameMode%" == "2P" goto viewBoard
if "%gameMode%" == "AIT" goto testAI
if "%gameMode%" == "S" goto gameSimulate
if "%p1Code%" == "%turnCode%" goto viewBoard
goto gameAI%AILvl%

:gameAI1
call :genRandomCell
call :genOrBlockWin
if "!%cellCode%!"==" " goto markCell
goto gameAI1

:gameAI2
call :genRandomCell
call :genWinPos
call :genOrBlockWin
if "!%cellCode%!"==" " goto markCell
goto gameAI2

:gameAI3
call :genRandomCell

if %gameTurnNum% == 2 (
    if "%moveType1%" == "O" call :genCornerRandom
    if "%moveType1%" == "C" set "cellCode=B2"
    if "%moveType1%" == "E" set "cellCode=B2"
)
if %gameTurnNum% == 3 (
    if "%moveType2%" == "O" (
        if "%moveType1%" == "E" call :genEquAdjRandom %move1%
        if "%moveType1%" == "C" call :genOpposite %move1%
    )
    if "%moveType2%" == "C" (
        if "%moveType1%" == "O" call :genOpposite %move2%
        if "%moveType1%" == "E" set "cellCode=B2"
        if "%move1%%move2%" == "C2C1" call :genEquAdjACW %move1%
        if "%move1%%move2%" == "C2C3" call :genEquAdjCW %move1%
        if "%move1%%move2%" == "B3C3" call :genEquAdjACW %move1%
        if "%move1%%move2%" == "B3A3" call :genEquAdjCW %move1%
        if "%move1%%move2%" == "A2A3" call :genEquAdjACW %move1%
        if "%move1%%move2%" == "A2A1" call :genEquAdjCW %move1%
        if "%move1%%move2%" == "B1A1" call :genEquAdjACW %move1%
        if "%move1%%move2%" == "B1A3" call :genEquAdjCW %move1%
    )
    if "%moveType2%" == "E" (
        if "%moveType1%" == "O" call :genNeqAdjRandom %move2%
        if "%moveType1%" == "C" call :genEquAdjRandom %move1%
        if "%moveType1%" == "E" call :genCornerRandom
    )
)
if %gameTurnNum% == 4 (
    if "%moveType3%" == "O" (
        rem Checks here...
    )
    if "%moveType3%" == "C" (
        rem OCC Prevention
        if "%B2%" == "%checkRoute:~1,1%" call :genCornerRandom
        if not "%B2%" == "%checkRoute:~1,1%" call :genEdgeRandom
    )
    if "%moveType3%" == "E" (
        call :genCornerRandom
        if "%A1: =%%A2%%A3: =%%B1%%C1: =%" == "XX" if "%cellCode%"=="C3" goto gameAI3
        if "%C1: =%%A1: =%%B1%%C2%%C3: =%" == "XX" if "%cellCode%"=="A3" goto gameAI3
        if "%C3: =%%C1: =%%C2%%A3: =%%B3%" == "XX" if "%cellCode%"=="A1" goto gameAI3
        if "%A3: =%%A1: =%%A2%%B3%%C3: =%" == "XX" if "%cellCode%"=="C1" goto gameAI3
        
        if "%B2%" == " " set "cellCode=B2"
    )
    
)
if %gameTurnNum% == 5 (
    if "%B2%" == " " set "cellCode=B2"
)
call :genOrBlockWin

rem Unlisted Strategies
rem 
rem Unlisted Preventions
rem B1 B3 C2 A2 B2 A3 C3 A1
rem B3 B2 C2 A1 C3 A3 C1
rem C1 B2 B3 A1 C3 A3 C2
rem A3 B2 C2 A1 C3 B3 C1
rem A3 B2 B1 C3 A1 C1 A2
rem 

if "!%cellCode%!"==" " goto markCell
goto gameAI3

goto gameCheck



:announceGame
set "gameMoves=Moves:"
for /l %%n in (1,1,9) do set "gameMoves=!gameMoves! !move%%n!"
if "%gameMode%%AILvl%%p1Code%" == "AI3%gameStatus:~0,1%" goto writeMoves
cls
call :displayBoard
echo=
echo %gameStatus%
echo=
pause
echo=
set "errorlevel=0"
if "%gameDebug%" == "0" choice /c YND /m "Do you want to play again?"
if "%errorlevel%" == "1" goto setup
if "%errorlevel%" == "2" exit
cls
call :displayBoard
echo=
echo %gameMoves%
echo=
pause
if "%gameDebug%" == "0" goto setup
set "turnCode=X"
set gameTurnNum=1
for %%a in (A B C) do (
    for /l %%n in (1,1,3) do (
        set "%%a%%n= "
    )
)
for /l %%n in (1,1,9) do (
    set "move%%n="
    set "moveType%%n="
)
goto testAI

:writeMoves
@echo Game moves: >> %moveLogsAddress%
@echo [%p1Code%] %gameMoves% >> %moveLogsAddress%
@echo ================================================== >> %moveLogsAddress%
@echo= >> %moveLogsAddress%
cls
call :displayBoard
echo=
echo Excellent ^^! Congratulations ^^!
echo You found the weakness of the hardest AI made in this script.
echo=
echo Game moves:
echo [%p1Code%] %gameMoves%
echo=
pause
echo=
choice /c YND /m "Do you want to play again?"
if %errorlevel% == 1 goto setup
rem Functions

:genRandomCell
set /a cellCode=%random% %% 3
if %cellCode% == 0 set "cellCode=A"
if %cellCode% == 1 set "cellCode=B"
if %cellCode% == 2 set "cellCode=C"

set /a cellCode=(%random% %% 3)+1 & set "cellCode=%cellCode%!cellCode!"
rem Random Cell [%cellCode%]
goto :EOF

:genCornerRandom
set /a cellCode=%random% %% 4
if %cellCode% == 0 set "cellCode=A1"
if %cellCode% == 1 set "cellCode=A3"
if %cellCode% == 2 set "cellCode=C1"
if %cellCode% == 3 set "cellCode=C3"
rem Corner random [%cellCode%]
goto :EOF

:genEdgeRandom
set /a cellCode=%random% %% 4
if %cellCode% == 0 set "cellCode=A2"
if %cellCode% == 1 set "cellCode=B1"
if %cellCode% == 2 set "cellCode=B3"
if %cellCode% == 3 set "cellCode=C2"
rem Edge Random [%cellCode%]
goto :EOF

:genOpposite
if "%1" == "A1" set "cellCode=C3"
if "%1" == "B1" set "cellCode=B3"
if "%1" == "C1" set "cellCode=A3"
if "%1" == "A2" set "cellCode=C2"
if "%1" == "B2" set "cellCode=B2"
if "%1" == "C2" set "cellCode=A2"
if "%1" == "A3" set "cellCode=C1"
if "%1" == "B3" set "cellCode=B1"
if "%1" == "C3" set "cellCode=A1"
goto :EOF

:genEquAdjCW
if "%1" == "A1" set "cellCode=C1"
if "%1" == "B1" set "cellCode=C2"
if "%1" == "C1" set "cellCode=C3"
if "%1" == "A2" set "cellCode=B1"
if "%1" == "B2" set "cellCode=B2"
if "%1" == "C2" set "cellCode=B3"
if "%1" == "A3" set "cellCode=A1"
if "%1" == "B3" set "cellCode=A2"
if "%1" == "C3" set "cellCode=A3"
goto :EOF

:genEquAdjACW
if "%1" == "A1" set "cellCode=A3"
if "%1" == "B1" set "cellCode=A2"
if "%1" == "C1" set "cellCode=A1"
if "%1" == "A2" set "cellCode=B3"
if "%1" == "B2" set "cellCode=B2"
if "%1" == "C2" set "cellCode=B1"
if "%1" == "A3" set "cellCode=C3"
if "%1" == "B3" set "cellCode=C2"
if "%1" == "C3" set "cellCode=C1"
goto :EOF

:genEquAdjRandom
set /a tempVar1=%random% %% 2
if %tempVar1% == 0 call :genEquAdjCW %1
if %tempVar1% == 1 call :genEquAdjACW %1
goto :EOF

:genNeqAdjCW
if "%1" == "A1" set "cellCode=B1"
if "%1" == "B1" set "cellCode=C1"
if "%1" == "C1" set "cellCode=C2"
if "%1" == "A2" set "cellCode=A1"
if "%1" == "B2" set "cellCode=B2"
if "%1" == "C2" set "cellCode=C3"
if "%1" == "A3" set "cellCode=A2"
if "%1" == "B3" set "cellCode=A3"
if "%1" == "C3" set "cellCode=B3"
goto :EOF

:genNeqAdjACW
if "%1" == "A1" set "cellCode=A2"
if "%1" == "B1" set "cellCode=A1"
if "%1" == "C1" set "cellCode=B1"
if "%1" == "A2" set "cellCode=A3"
if "%1" == "B2" set "cellCode=B2"
if "%1" == "C2" set "cellCode=C1"
if "%1" == "A3" set "cellCode=B3"
if "%1" == "B3" set "cellCode=C3"
if "%1" == "C3" set "cellCode=C2"
goto :EOF

:genNeqAdjRandom
set /a tempVar1=%random% %% 2
if %tempVar1% == 0 call :genNeqAdjCW %1
if %tempVar1% == 1 call :genNeqAdjACW %1
goto :EOF

:genOrBlockWin
rem Set AI winning position or block opponent winning position
for %%c in (%checkRoute%) do (
    for %%a in (A B C) do if "!%%a1: =!!%%a2: =!!%%a3: =!" == "%%c" (
        for %%n in (1 2 3) do if "!%%a%%n!" == " " set "cellCode=%%a%%n"
    )
    for %%n in (1 2 3) do if "!A%%n: =!!B%%n: =!!C%%n: =!" == "%%c" (
        for %%a in (A B C) do if "!%%a%%n!" == " " set "cellCode=%%a%%n"
    )
    if "%A1: =%%B2: =%%C3: =%" == "%%c" (
        for %%b in (A1 B2 C3) do if "!%%b!" == " " set "cellCode=%%b"
    )
    if "%A3: =%%B2: =%%C1: =%" == "%%c" (
        for %%b in (A3 B2 C1) do if "!%%b!" == " " set "cellCode=%%b"
    )
)
goto :EOF

:genWinPos
rem Set AI  possible winning positions
for %%c in (%checkRoute:~-1,1%) do (
    for %%a in (A B C) do if "!%%a1: =!!%%a2: =!!%%a3: =!" == "%%c" (
        for %%n in (1 2 3) do if "!%%a%%n!" == " " set "cellCode=%%a%%n"
    )
    for %%n in (1 2 3) do if "!A%%n: =!!B%%n: =!!C%%n: =!" == "%%c" (
        for %%a in (A B C) do if "!%%a%%n!" == " " set "cellCode=%%a%%n"
    )
    if "%A1: =%%B2: =%%C3: =%" == "%%c" (
        for %%b in (A1 B2 C3) do if "!%%b!" == " " set "cellCode=%%b"
    )
    if "%A3: =%%B2: =%%C1: =%" == "%%c" (
        for %%b in (A3 B2 C1) do if "!%%b!" == " " set "cellCode=%%b"
    )
)
goto :EOF

:displayBoard
echo     A   B   C
echo   ÉÍÍÍÍÍÍÍÍÍÍÍ»
echo 1 º %A1% ³ %B1% ³ %C1% º
echo   ºÄÄÄoÄÄÄoÄÄÄº
echo 2 º %A2% ³ %B2% ³ %C2% º
echo   ºÄÄÄoÄÄÄoÄÄÄº
echo 3 º %A3% ³ %B3% ³ %C3% º
echo   ÈÍÍÍÍÍÍÍÍÍÍÍ¼
goto :EOF

:String_UPPERCASE
rem %1 is the string name
rem TempVar:
for %%a in (
    A B C D E F G
    H I J K L M N
    O P Q R S T U
    V W X Y Z
) do set "%1=!%1:%%a=%%a!"
goto :EOF
