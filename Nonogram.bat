@goto main

rem Nonogram
rem Updated on 2016-10-04
rem Made by wthe22 - http://winscr.blogspot.com/


:main
@echo off
prompt $s
cd /d "%~dp0"
setlocal EnableDelayedExpansion EnableExtensions

title Nonogram

set     "symbol_empty= "
set  "symbol_solution=²"
set "symbol_eliminate=X"

2> nul (
    chcp 437
) && (
    call :ASCII_GUI     This is the default GUI
) || call :UTF8_GUI     Backup GUI, In case ASCII doesn't display correctly


rem ========================================== Setup =========================================

set "alphabets=.ABCDEFGHIJKLMNOPQRSTUVWXYZ"

set "hSpacing=5"

set "displayText3=[X] Exit"
set "displayText4=[C] Check"
set "displayText5=[R] Reset"
set "displayText6=[E] New puzzle"
set "displayText7=[S] Switch mark"
set "displayText9= !symbol_%currentMark%!  Current mark"



:puzzle_sizeIn
set "userInput=7x7"
cls
echo Size can be from 3x3 to 26x32
echo=
echo Default is 7x7
echo=
echo 0. Exit
echo=
echo Input puzzle size:
set /p "userInput="
if "!userInput!" == "0" exit
for /f "tokens=1-2 delims=Xx" %%a in ("!userInput: =!") do (
    if %%a0 GEQ 30 if %%a0 LEQ 320 (
        if %%b0 GEQ 30 if %%b0 LEQ 260 (
            set /a "puzzleRow=%%a"
            set /a "puzzleCol=%%b"
            goto puzzle_densityIn
        )
    )
)
goto puzzle_sizeIn


:puzzle_densityIn
set "puzzleDensity=1/2"
cls
echo Nonogram size  : !puzzleRow!x!puzzleCol!
echo=
echo Default is 1/2
echo Valid range    : 10%% - 90%%
echo=
echo 0. Back
echo=
echo Input puzzle density (in fractions):
set /p "puzzleDensity="
if "!puzzleDensity!" == "0" goto puzzle_sizeIn
set /a "tempVar1=100 * !puzzleDensity!"
if !tempVar1! GEQ 10 if !tempVar1! LEQ 90 goto puzzle_instructions
goto puzzle_sizeIn



:puzzle_instructions
cls
echo How to play:
echo=
echo Input cell code to mark cell 
echo Cell code can be in any order and it is case-insensitive
echo=
echo Eg: c2, A1, 5b, 3F
echo=
echo=
echo Mark cells with symbols:
echo=
echo Solution       !symbol_solution!
echo=
echo Eliminated     !symbol_eliminate!
echo=
pause

:puzzle_generate
echo=
echo Generating puzzle...

call :buildGUI
call :matrix set answerBoard "!symbol_empty!"
call :drawRandom answerBoard
call :clues count answerBoard
call :clues format answerBoard
call :clues copy answerBoard solvingsBoard

set "currentMark=solution"
set "displayText9= !symbol_%currentMark%!  Current mark"
set "startTime=!time!"

:puzzle_reset
call :matrix set solvingsBoard "!symbol_empty!"

:puzzle_play
set "userInput=?"
cls
call :displayBoard solvingsBoard
echo=
set /p "userInput=Input cell code   : "
if /i "!userInput!" == "X" goto puzzle_quitPrompt
if /i "!userInput!" == "C" goto puzzle_checkSolvings
if /i "!userInput!" == "R" goto puzzle_resetPrompt
if /i "!userInput!" == "E" goto puzzle_newPrompt
if /i "!userInput!" == "S" call :switchMark
call :checkCellcode !userInput!
if defined cellPos call :toggleMark solvingsBoard !cellPos!
goto puzzle_play


:puzzle_newPrompt
set /p "userInput=Generate new puzzle? Y/N? "
if /i "!userInput!" == "Y" goto puzzle_generate
goto puzzle_play


:puzzle_resetPrompt
set /p "userInput=Reset the board? Y/N? "
if /i "!userInput!" == "Y" goto puzzle_reset
goto puzzle_play


:puzzle_quitPrompt
set /p "userInput=Exit to menu? Y/N? "
if /i "!userInput!" == "Y" goto puzzle_sizeIn
goto puzzle_play


:puzzle_checkSolvings
call :clues count solvingsBoard
call :clues format solvingsBoard
call :clues compare solvingsBoard answerBoard
if "!return!" == "0" goto puzzle_solved

call :clues copy answerBoard solvingsBoard
echo=
echo There is something wrong...
pause > nul
goto puzzle_play


:puzzle_solved
call :difftime !time! !startTime!
call :ftime !return!
call :matrix replace solvingsBoard "!symbol_eliminate!" "!symbol_empty!"
cls
call :displayBoard solvingsBoard
echo=
echo Congratulations^^! You solved the puzzle in !return!
echo=
pause
goto puzzle_sizeIn


rem ========================================== Puzzle Functions =========================================

:matrix
if /i "%1" == "create" (
    if "!%~3!" == "" goto :EOF
    set "tempArray1=!%3!"
)
if /i "%1" == "toArray" set "%3="
if /i "%1" == "compare" set "return=0"
for /l %%i in (1,1,!puzzleRow!) do (
    for /l %%j in (1,1,!puzzleCol!) do (
        if /i "%1" == "create" (
            set "%2_%%i-%%j=!tempArray1:~0,1!"
            set "tempArray1=!tempArray1:~1!"
        )
        if /i "%1" == "swap" for %%n in (!%2_%%i-%%j!) do (
            if "%%n" == "%~3" set "%2_%%i-%%j=%~4"
            if "%%n" == "%~4" set "%2_%%i-%%j=%~3"
        )
        if /i "%1" == "replace" (
            if "!%2_%%i-%%j!" == "%~3" set "%2_%%i-%%j=%~4"
        )
        if /i "%1" == "set"     set "%2_%%i-%%j=%~3"
        if /i "%1" == "copy"    set "%3_%%i-%%j=!%2_%%i-%%j!"
        if /i "%1" == "toArray" set "%3=!%3!!%2_%%i-%%j!"
        if /i "%1" == "delete"  set "%2_%%i-%%j="
    )
)
goto :EOF
rem CREATE [Matix_Name] [Source_Array]
rem SET [Matix_Name] [Source_Array]
rem COPY [Source_Matix] [Destination_Matrix]
rem SWAP [Matix_Name] [Number1] [Number2]
rem toArray [Source_Matix] [Destination_Array]
rem DELETE [Matix_Name]
rem COUNT [Matix_Name] [Symbol]
goto :EOF


:drawRandom [Matix_Name]
set /a "randTreshold=32768 * !puzzleDensity!"
for /l %%i in (1,1,!puzzleRow!) do (
    for /l %%j in (1,1,!puzzleCol!) do (
        if !random! GEQ !randTreshold! (
            set "%1_%%i-%%j=!symbol_empty!"
        ) else set "%1_%%i-%%j=!symbol_solution!"
    )
)
goto :EOF


:clues
if /i "%1" == "count" goto countClues
if /i "%1" == "format" goto formatClues
if /i "%1" == "compare" set "return=0"
for %%t in (Row Col) do (
    for /l %%i in (1,1,!puzzle%%t!) do (
        if /i "%1" == "copy"    set "%3_clue%%t%%i=!%2_clue%%t%%i!"
        if /i "%1" == "delete"  set "%2_clue%%t%%i="
        if /i "%1" == "compare" if not "!%2_clue%%t%%i!" == "!%3_clue%%t%%i!"  set /a "return+=1"
    )
)
goto :EOF

:countClues COUNT [Matix_Name]
for /l %%i in (1,1,!puzzleRow!) do (
    set "%2_clueRow%%i="
    set "currentCount=0"
    for %%c in (!tempVar1!) do for /l %%j in (1,1,!puzzleCol!) do (
        if not "!%2_%%i-%%j!" == "!symbol_solution!" (
            if not "!currentCount!" == "0" (
                set "%2_clueRow%%i=!%2_clueRow%%i! !currentCount!"
                set "currentCount=0"
            )
        ) else set /a "currentCount+=1"
    )
    if not "!currentCount!" == "0" set "%2_clueRow%%i=!%2_clueRow%%i! !currentCount!"
)
for /l %%j in (1,1,!puzzleCol!) do (
    set "%2_clueCol%%j="
    set "currentCount=0"
    for %%c in (!tempVar1!) do for /l %%i in (1,1,!puzzleRow!) do (
        if not "!%2_%%i-%%j!" == "!symbol_solution!" (
            if not "!currentCount!" == "0" (
                set "%2_clueCol%%j=!%2_clueCol%%j! !currentCount!"
                set "currentCount=0"
            )
        ) else set /a "currentCount+=1"
    )
    if not "!currentCount!" == "0" set "%2_clueCol%%j=!%2_clueCol%%j! !currentCount!"
)
goto :EOF


:checkCellcode
set "cellCode=%1"
set "rowNumber="
for /l %%n in (1,1,!puzzleRow!) do if not defined rowNumber (
    if /i "!cellCode:~0,1!" == "!alphabets:~%%n,1!" (
        set "rowNumber=%%n"
        set /a "colNumber=!cellCode:~1! + 0" 2> nul
    )
    if /i "!cellCode:~-1,1!" == "!alphabets:~%%n,1!" (
        set "rowNumber=%%n"
        set /a "colNumber=!cellCode:~0,-1! + 0" 2> nul
    )
)
set "cellPos="
if !rowNumber! GEQ 1 if !rowNumber! LEQ !puzzleRow! (
    if !colNumber! GEQ 1 if !colNumber! LEQ !puzzleCol! (
        set "cellPos=!rowNumber!-!colNumber!"
    )
)
goto :EOF


:formatClues
for /l %%i in (1,1,!puzzleRow!) do (
    set "%2_clueRow%%i=!rowClueSpace!!%2_clueRow%%i!"
    set "%2_clueRow%%i=!%2_clueRow%%i:~-%rowClueSize%,%rowClueSize%!"
)
for /l %%j in (1,1,!puzzleCol!) do (
    set "tempVar1=!%2_clueCol%%j!"
    set "%2_clueCol%%j="
    for %%n in (!tempVar1!) do (
        set "tempVar1=  %%n"
        set "%2_clueCol%%j=!%2_clueCol%%j! !tempVar1:~-2,2!"
    )
    set "%2_clueCol%%j=!colClueSpace!!%2_clueCol%%j!"
    set "%2_clueCol%%j=!%2_clueCol%%j:~-%colClueSize%,%colClueSize%!"
)
goto :EOF


:toggleMark
if "!%1_%2!" == "!symbol_empty!" (
    set "%1_%2=!symbol_%currentMark%!"
) else set "%1_%2=!symbol_empty!"
goto :EOF


:switchMark
if /i "!currentMark!" == "solution" (
    set "currentMark=eliminate"
) else set "currentMark=solution"
set "displayText9= !symbol_%currentMark%!  Current mark"
goto :EOF

rem ========================================== GUI Functions =========================================

:ASCII_GUI
set "vBorder=º"
set "hBorder=Í"
set "cBorder=Î"
set "vGrid=³"
set "hGrid=Ä"
set "cGrid=Å"
set "dEdge=Ê"
set "rEdge=¹"
set "ulCorner=É"
set "urCorner=»"
set "dlCorner=È"
set "drCorner=¼"
goto :EOF


:UTF8_GUI
set "vBorder=|"
set "hBorder=="
set "cBorder=+"
set "vGrid=|"
set "hGrid=-"
set "cGrid=+"
set "dEdge=+"
set "rEdge=+"
set "ulCorner=+"
set "urCorner=+"
set "dlCorner=+"
set "drCorner=+"
goto :EOF


:buildGUI
for %%v in (
    rowClueSpace colClueSpace sideSpacing
    smallBorder smallGrid colNumbers
    topBorder midBorder btmBorder midGrid
) do set "%%v="

set /a "rowClueItems=(!puzzleCol!+1) / 2"
set /a "rowClueSize=!rowClueItems! * 2 - 1"
for /l %%n in (1,1,!rowClueSize!) do set "rowClueSpace=!rowClueSpace! "
set /a "colClueItems=(!puzzleRow!+1) / 2"
set /a "colClueSize=!colClueItems! * 3"
for /l %%n in (1,1,!colClueSize!) do set "colClueSpace=!colClueSpace! "
for /l %%n in (1,1,!hSpacing!) do set "sideSpacing=!sideSpacing! "

for /l %%n in (1,1,4) do (
    set "smallGrid=!smallGrid!!hGrid!"
    set "smallBorder=!smallBorder!!hBorder!"
)
set "smallGrid=!smallGrid:~1!!cGrid!"
for /l %%n in (1,1,!puzzleCol!) do (
    set "midGrid=!midGrid!!smallGrid!"
    set "midBorder=!midBorder!!smallBorder!"
)
set "midBorder=!midBorder:~1!"
for /l %%n in (1,1,!puzzleCol!) do (
    set "tempVar1=  %%n"
    set "colNumbers=!colNumbers! !tempVar1:~-2,2! "
)
set "colNumbers= !rowClueSpace!!colNumbers!"
set "topBorder= !rowClueSpace!!ulCorner!!midBorder!!urCorner!"
set "btmBorder=!dlCorner!!rowClueSpace: =%hBorder%!!dEdge!!midBorder!!drCorner!"
set "midGrid=!vBorder!!rowClueSpace: =%hGrid%!!vBorder!!midGrid:~0,-1!!vBorder!"
set "midBorder=!ulCorner!!rowClueSpace: =%hBorder%!!cBorder!!midBorder!!rEdge!"
goto :EOF


:displayBoard [Matix_Name]
echo !topBorder!!sideSpacing!!displayText1!
set "lineCount=1"
for /l %%i in (1,1,!colClueItems!) do (
    set "display=!vBorder!"
    set /a "tempVar1=(%%i-1) * 3"
    for %%n in (!tempVar1!) do for /l %%j in (1,1,!puzzleCol!) do (
        set "display=!display!!%1_clueCol%%j:~%%n,3!!vGrid!"
    )
    set "display= !rowClueSpace!!display:~0,-1!!vBorder!"
    set /a "lineCount+=1"
    for %%l in (!lineCount!) do echo !display!!sideSpacing!!displayText%%l!
)
set /a "lineCount+=1"
for %%l in (!lineCount!) do echo !midBorder!!sideSpacing!!displayText%%l!
for /l %%i in (1,1,!puzzleRow!) do (
    set "display=!vBorder!!%1_clueRow%%i!!vBorder!"
    for /l %%j in (1,1,!puzzleCol!) do set "display=!display! !%1_%%i-%%j! !vGrid!"
    set "display=!display:~0,-1!!vBorder!
    set /a "lineCount+=1"
    for %%l in (!lineCount!) do echo !display! !alphabets:~%%i,1! !sideSpacing:~3!!displayText%%l!
    set /a "lineCount+=1"
    for %%l in (!lineCount!) do if "%%i" == "!puzzleRow!" (
        echo !btmBorder!!sideSpacing!!displayText%%l!
    ) else echo !midGrid!!sideSpacing!!displayText%%l!
)
echo !colNumbers!
goto :EOF

rem ========================================== Functions =========================================

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

