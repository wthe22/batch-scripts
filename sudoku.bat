

@goto scriptStart

rem Updated on 2015-10-10

:errorUnexpected
echo=
echo An unexpected error happened.
echo=
echo Press any key to exit or continue with modifications.
pause > nul
exit

:errorExpected
echo=
echo The feature you used have not been completed yet...
echo=
echo Press any key to exit or continue with modifications.
pause > nul
exit

:scriptStart
@echo off
cd /d "%~dp0"
prompt $s
setlocal EnableDelayedExpansion

set "sudokuBlockWidth=3"
set "sudokuBlockHeight=3"

set "solutionCountMax=20"

set "pathData=BatchScript_Data\Sudoku\"

set "userInput=?"

:sudokuSizeSetup
title Sudoku
cls
call :splashScreen

set "pathPuzzles=%pathData%%sudokuBlockWidth%x%sudokuBlockHeight%\Puzzles\"
set   "pathSaves=%pathData%%sudokuBlockWidth%x%sudokuBlockHeight%\Saves\"

for %%p in (
    pathPuzzles
    pathSaves
) do if not exist "!%%p!" md "!%%p!"

set /a sudokuSize=%sudokuBlockWidth% * %sudokuBlockHeight%
set /a sudokuArea=%sudokuSize% * %sudokuSize%

set "alphabetList=.ABCDEFGHIJKLMNOPQRSTUVWXYZ"

set "rowCode="
set "colCode="
for /l %%n in (1,1,%sudokuSize%) do  set "rowCode=!rowCode! !alphabetList:~%%n,1!"
for /l %%n in (1,1,%sudokuSize%) do  set "colCode=!colCode! %%n"
set "countRow=1"
set "countCol=1"
for /l %%n in (1,1,%sudokuSize%) do for %%r in (!countRow!) do for %%c in (!countCol!) do (
    set "blockRow%%r=!blockRow%%r! !alphabetList:~%%n,1!"
    set "blockCol%%c=!blockCol%%c! %%n"
    set /a tempVar1=%%n %% %sudokuBlockHeight%
    if "!tempVar1!" == "0" set /a countRow+=1
    set /a tempVar1=%%n %% %sudokuBlockWidth%
    if "!tempVar1!" == "0" set /a countCol+=1
)
set "countRow="
set "countCol="
for /l %%n in (1,1,%sudokuSize%) do (
    set /a tempVar1=%%n %% %sudokuBlockHeight%
    if "!tempVar1!" == "0" set "tempVar1=%sudokuBlockHeight%"
    for %%c in (!tempVar1!) do set "block%%nCol=!blockCol%%c!"
    set /a tempVar1=%%n+%sudokuBlockHeight%-1
    set /a tempVar1/=%sudokuBlockHeight%
    for %%r in (!tempVar1!) do set "block%%nRow=!blockRow%%r!"
)
set "allNumList="
set "allNumSpaced="
for /l %%n in (1,1,%sudokuSize%) do (
    set "allNumList=!allNumList!%%n"
    set "allNumSpaced=!allNumSpaced! %%n"
    for %%r in (!block%%nRow!) do for %%c in (!block%%nCol!) do set "block%%r%%c=%%n"
    set "eliminateRow%%n="
    set "eliminateCol%%n="
    set "blockRow%%n="
    set "blockCol%%n="
)
for /l %%t in (1,1,%sudokuBlockHeight%) do for /l %%b in (%%t,%sudokuBlockHeight%,%sudokuSize%) do  for /l %%r in (%%t,%sudokuBlockHeight%,%sudokuSize%) do (
    if not "%%b" == "%%r" set "eliminateRow%%b=!eliminateRow%%b! !block%%rRow!"
)
for /l %%t in (1,%sudokuBlockHeight%,%sudokuSize%) do (
    set /a tempVar1=%%t+%sudokuBlockHeight%-1
    for /l %%b in (%%t,1,!tempVar1!) do  for /l %%c in (%%t,1,!tempVar1!) do (
        if not "%%b" == "%%c" set "eliminateCol%%b=!eliminateCol%%b! !block%%cCol!"
    )
)
rem Display setup
set "boardDisplay1=   "
for /l %%n in (1,1,%sudokuSize%) do set "boardDisplay1=!boardDisplay1! %%n  "
set "tempVar1="
set "tempVar2="
for /l %%n in (1,1,%sudokuBlockWidth%) do (
    set "tempVar1=!tempVar1!ฤฤฤล"
    set "tempVar2=!tempVar2!ออออ"
)
set "boardDisplay2="
for /l %%n in (1,1,%sudokuBlockHeight%) do set "boardDisplay2=!boardDisplay2!!tempVar2:~0,-1!ห"
set "boardDisplay2=%boardDisplay2:~0,-1%"
set "boardDisplay4=  ฬ%boardDisplay2:ห=ฮ%น"
set "boardDisplay5=  ศ%boardDisplay2:ห=ส%ผ"
set "boardDisplay2=  ษ%boardDisplay2%ป"
set "boardDisplay3=  บ"
for /l %%n in (1,1,%sudokuBlockHeight%) do set "boardDisplay3=!boardDisplay3!!tempVar1:~0,-1!บ"
set "boardDisplay3=!boardDisplay3:~0,-1!บ"
set /a boardTextNum=3 + %sudokuSize% * 4

set "clearLine="
set "clearLine=!clearLine!                                                                               !clearLine!"

rem MODE 95,40

timeout /t 1 /nobreak > nul

:sudokuMenu
cls
title Sudoku %sudokuSize%x%sudokuSize% - [%sudokuBlockWidth%x%sudokuBlockHeight%]
echo 1. Play sudoku
echo 2. Input sudoku
echo 3. View sudoku
echo 4. Generate sudoku
echo 5. Solve sudoku
echo=
echo A. About script
echo C. Change sudoku size
echo 0. Exit
echo=
echo What do you want to do?
set /p "userInput="
if "%userInput%" == "0" exit
if "%userInput%" == "1" goto puzzleSetup
if "%userInput%" == "2" goto inputSudoku
if "%userInput%" == "3" goto viewSetup
if "%userInput%" == "4" goto generateSetup
if "%userInput%" == "5" goto solveSetup
if /i "%userInput:~0,1%" == "A" goto aboutScript
if /i "%userInput:~0,1%" == "C" goto sudokuSizeIn
if /i "%userInput%" == "GS" goto genInfo
echo=
echo Invalid choice
pause
goto sudokuMenu

rem ==================================== About =====================================

:aboutScript
cls
call :splashScreen
pause > nul
goto sudokuMenu

:splashScreen
echo                       ฒฒฒฒฒ ฒ   ฒ ฒฒฒฒ  ฒฒฒฒฒ ฒ  ฒฒ ฒ   ฒ
echo                       ฒ     ฒ   ฒ ฒ   ฒ ฒ   ฒ ฒ ฒ   ฒ   ฒ
echo                       ฒฒฒฒฒ ฒ   ฒ ฒ   ฒ ฒ   ฒ ฒฒ    ฒ   ฒ
echo                           ฒ ฒ   ฒ ฒ   ฒ ฒ   ฒ ฒ ฒ   ฒ   ฒ
echo                       ฒฒฒฒฒ ฒฒฒฒฒ ฒฒฒฒ  ฒฒฒฒฒ ฒ  ฒฒ ฒฒฒฒฒ  v2.1
echo=
echo                                ษอออออหอออออหอออออป
echo                                บ ณ8ณ บ ณ ณ3บ ณ9ณ บ
echo                                บ5ณ ณ3บ7ณ ณ บ8ณ4ณ บ
echo                                บ ณ4ณ6บ ณ ณ2บ ณ ณ5บ
echo                                ฬอออออฮอออออฮอออออน
echo                                บ4ณ6ณ1บ ณ ณ7บ ณ ณ9บ
echo                                บ ณ3ณ บ ณ ณ บ ณ1ณ บ
echo                                บ2ณ ณ บ1ณ ณ บ6ณ8ณ3บ
echo                                ฬอออออฮอออออฮอออออน
echo                                บ1ณ ณ บ9ณ ณ บ7ณ2ณ บ
echo                                บ ณ9ณ4บ ณ ณ8บ5ณ ณ1บ
echo                                บ ณ2ณ บ4ณ ณ บ ณ3ณ บ
echo                                ศอออออสอออออสอออออผ
echo=
echo                       ษออออออออออออออออออออออออออออออออออป
echo                       บ          Made by wthe22          บ
echo                       บ   http://winscr.blogspot.com/    บ
echo                       ศออออออออออออออออออออออออออออออออออผ
goto :EOF

rem ================================== Change Size =================================

:sudokuSizeIn
cls
echo This feature is still incomplete: 
echo Text beside sudoku grid may be missing or GUI may not displayed correctly
echo=
echo Available size            2x2 to 3x3
echo Default size              3x3
echo Current size              %sudokuBlockWidth%x%sudokuBlockHeight%
echo=
echo 0. Back
echo=
set /p "userInput=Input sudoku block size : "
if "%userInput%" == "0" goto sudokuMenu
for /f "tokens=1-2 delims=x" %%a in ("%userInput: =%") do (
    if %%a0 GEQ 20 if %%a0 LEQ 30 (
        if %%b0 GEQ 20 if %%b0 LEQ 30 (
            set "sudokuBlockWidth=%%a"
            set "sudokuBlockHeight=%%b"
            goto sudokuSizeSetup
        )
    )
)
echo=
echo Invalid sudoku block size
pause
goto sudokuSizeIn

rem ===================================== Play =====================================

:puzzleSetup
call :selectSudoku Y
if "%userInput%" == "0" goto sudokuMenu
call :actionReset
call :matrix create sudokuPuzzleMatrix sudokuPuzzleArray
call :matrix create sudokuPlayMatrix   sudokuPuzzleArray
call :sudokuInfo sudokuPuzzleMatrix
set "saveActionNum=0"
set "saveActionLog=0000"
set "saveArray3="
cls
call :sudokuBoard sudokuPlayMatrix
pause
:puzzlePlay
call :logUpdate
set "boardText14=[Z] Undo"
set "boardText15=[X] Exit to menu"
set "boardText16=[C] Check"
set "boardText17=[S] Save"
set "boardText18=[L] Load"
set "userInput=?"
cls
call :sudokuBoard sudokuPlayMatrix
set /p "userInput=Input cell code       : "
if /i "%userInput%" == "Z" call :actionUndo sudokuPlayMatrix
if /i "%userInput%" == "X" goto puzzleQuitPrompt
if /i "%userInput%" == "C" goto puzzleCheck
if /i "%userInput%" == "S" call :saveSudoku S Y A sudokuPuzzleArray A sudokuAnswerArray M sudokuPlayMatrix
if /i "%userInput%" == "L" call :loadSudoku
set "cellCode="
for %%r in (%rowCode%) do if /i "%userInput:~0,1%" == "%%r" set "cellCode=%%r"
for /l %%c in (1,1,%sudokuSize%) do if "%userInput:~1%" == "%%c" set "cellCode=!cellCode!%%c"
if defined cellCode if not "%cellCode:~1%" == "" if not "!sudokuPuzzleMatrix%cellCode%!" == " " (
    echo That cell is part of the puzzle...
    pause > nul
    goto puzzlePlay
) else goto puzzleInput
goto puzzlePlay
:puzzleQuitPrompt
set /p "userInput=Do you want to quit? Y? "
if /i not "%userInput%" == "Y" goto puzzlePlay
call :matrix toArray sudokuPlayMatrix sudokuSaveArray
call :promptSave S Y A sudokuPuzzleArray A sudokuAnswerArray A sudokuSaveArray
goto sudokuMenu
:puzzleInput
choice /c C0%allNumList% /n /m "[C] Cancel | Fill 0-%sudokuSize% : "
set "userInput=%errorlevel%"
if "%userInput%" == "1" goto puzzlePlay
set /a userInput-=2
call :actionMark sudokuPlayMatrix %cellCode% %userInput% 
goto puzzlePlay
:puzzleCheck
call :checkValidMatrix P sudokuPlayMatrix
if "%sudokuErrorNum%,%cellEmptyNum%" == "0,0" goto puzzleSolved
if "%sudokuErrorNum%" == "0" (
    echo Seems good, continue solving^^!
) else echo Sudoku contain %sudokuErrorNum% errors...
pause > nul
goto puzzlePlay
:puzzleSolved
cls
call :sudokuBoard sudokuPuzzleMatrix
echo Congratulations, you solved the sudoku
pause > nul
if defined sudokuAnswerArray goto sudokuMenu
call :promptSave P Y A sudokuPuzzleArray M sudokuPlayMatrix
goto sudokuMenu

rem ==================================== Input =====================================

:inputSudoku
call :boardTextClear
:inputPuzzle
set "sudokuName=Input @%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
call :inputSelect P selectedPuzzleArray selectedPuzzleMatrix
if "%userInput%" == "0" goto sudokuMenu
:inputAnswer
call :inputSelect A selectedAnswerArray selectedAnswerMatrix
if "%userInput%" == "0" goto inputPuzzle
set "sudokuPuzzleArray=%selectedPuzzleArray%"
set "sudokuAnswerArray=%selectedAnswerArray%"
call :promptSave P Y A sudokuPuzzleArray A sudokuAnswerArray
goto sudokuMenu

:inputSelect [Type] [Array] [Matrix]
rem Return values
rem 0 - Back
set "%2="
set "userInput=?"
set "cellCode=A1"
call :matrix clear %3
call :actionReset
call :boardTextClear
set "boardText11=[W] Up"
set "boardText12=[A] Left"
set "boardText13=[S] Down"
set "boardText14=[D] Right"
set "boardText16=[Z] Undo"
set "boardText17=[X] Exit to menu"
set "boardText18=[C] Check"
:inputMenu
cls
echo 1. Input one by one with GUI
echo 2. Input in array form
if "%1" == "A" echo 3. Skip this step
echo=
echo 0. Back
echo=
if /i "%1" == "P" echo Choose method to input the puzzle   :
if /i "%1" == "A" echo Choose method to input the answer   :
set /p "userInput="
if "%userInput%" == "0" goto :EOF
if "%userInput%" == "1" goto inputGUI
if "%userInput%" == "2" goto inputArray
if /i "%1" == "A" if "%userInput%" == "3" goto :EOF
echo=
echo Invalid choice
pause
goto inputMenu
:inputGUI
set "cellValue=!%3%cellCode%!"
set "%3%cellCode%=x"
cls
call :sudokuBoard %3
choice /c ZXCWASD0%allNumList% /n /m "Input number of the marked cell : "
set "userInput=%errorlevel%"
set "%3%cellCode%=%cellValue%"
if "%userInput%" == "1" call :actionUndo %3
if "%userInput%" == "2" goto inputSelect
if "%userInput%" == "3" goto inputCheck
if "%userInput%" == "4" call :cellMove U
if "%userInput%" == "5" call :cellMove L
if "%userInput%" == "6" call :cellMove D
if "%userInput%" == "7" call :cellMove R
if %userInput% LEQ 7 goto inputGUI
set /a userInput-=8
if "%1,%userInput%" == "A,0" goto inputGUI
call :actionMark %3 %cellCode% %userInput%
call :cellMove N
goto inputGUI
:inputArray
set "userInput=?"
cls
echo    1 2 3 4 5 6 7 8 9    Example of a sudoku puzzle array:
echo   ษอออออหอออออหอออออป   
echo A บ ณ8ณ บ ณ ณ3บ ณ9ณ บ   1. Input the left to right of the row (A1 to A9)
echo B บ5ณ ณ3บ7ณ ณ บ8ณ4ณ บ   2. Go to the left of the row below (Go to B1)
echo C บ ณ4ณ6บ ณ ณ2บ ณ ณ5บ   3. Repeat until done
echo   ฬอออออฮอออออฮอออออน   
echo D บ4ณ6ณ1บ ณ ณ7บ ณ ณ9บ   You can represent an empty cell using dot ".",
echo E บ ณ3ณ บ ณ ณ บ ณ1ณ บ   space " ", zero "0" and underscore "_"
echo F บ2ณ ณ บ1ณ ณ บ6ณ8ณ3บ   
echo   ฬอออออฮอออออฮอออออน   Sudoku puzzle array (one line):
echo G บ1ณ ณ บ9ณ ณ บ7ณ2ณ บ   .8...3.9.5.37..84..46..2..5
echo H บ ณ9ณ4บ ณ ณ8บ5ณ ณ1บ   461..7..9.3.....1.2..1..683
echo I บ ณ2ณ บ4ณ ณ บ ณ3ณ บ   1..9..72..94..85.1.2.4...3.
echo   สอออออสอออออสอออออผ   
echo=
echo 0. Back
echo=
echo Input the sudoku array :
set /p "userInput="
if "%userInput%" == "0" goto inputSelect
call :checkValidArray userInput
if "%return%" == "0" (
    set "%2=%userInput%"
    goto inputCheck
)
echo Invalid sudoku format
pause
goto inputArray
:inputCheck
if defined %2 call :matrix create %3 %2
call :checkValidMatrix %1 %3
if "%sudokuErrorNum%" == "0" (
    call :matrix toArray %3 %2
    goto :EOF
)
:inputErrorMenu
set "userInput=?"
cls
call :sudokuBoardMini %3
echo Found %sudokuErrorNum% errors on sudoku
echo 1. Fix errors
echo 2. Re-input
echo 3. Ignore
echo 4. View errors
echo=
echo What do you want to do?
set /p "userInput="
if "%userInput%" == "1" goto inputGUI
if "%userInput%" == "2" goto inputSelect
if "%userInput%" == "3" goto :EOF
if "%userInput%" == "4" goto inputErrorView
echo=
echo Invalid choice
pause
goto inputErrorMenu
:inputErrorView
cls
call :sudokuBoardMini %3
echo Sudoku errors  :
echo=%cellInvalidList%
if %cellEmptyNum% GTR 64 echo There are more than 1 solution because there are too few givens
if /i "%1" == "A" if not "%cellEmptyNum%" == "0" echo Found %cellEmptyNum% empty cells on answer
echo=
pause
goto inputErrorMenu

rem ==================================== Viewer ====================================

:viewSetup
call :selectSudoku N
if "%userInput%" == "0" goto sudokuMenu
echo=
echo Preparing sudoku...
call :matrix create sudokuPuzzleMatrix sudokuPuzzleArray
call :checkValidMatrix P sudokuPuzzleMatrix
set "puzzleErrorNum=%sudokuErrorNum%"
if defined sudokuAnswerArray (
    call :matrix create sudokuAnswerMatrix sudokuAnswerArray
    call :checkValidMatrix A sudokuAnswerMatrix
    set "answerErrorNum=!sudokuErrorNum!"
)
if defined sudokuSaveArray (
    call :matrix create sudokuSaveMatrix sudokuSaveArray
    call :checkValidMatrix A sudokuSaveMatrix
    set "saveErrorNum=!sudokuErrorNum!"
)
if defined sudokuPuzzleArray set "sudokuPuzzleArray=%sudokuPuzzleArray: =.%"
if defined sudokuAnswerArray set "sudokuAnswerArray=%sudokuAnswerArray: =.%"
if defined sudokuSaveArray   set   "sudokuSaveArray=%sudokuSaveArray: =.%"

:viewMenu
set "userInput=?"
cls
echo Sudoku name    : %sudokuName%
echo=
if defined sudokuPuzzleArray echo 1. Puzzle
if defined sudokuAnswerArray echo 2. Answer
if defined sudokuSaveArray   echo 3. Save
echo=
echo A. View in array form
echo 0. Back
echo=
echo What do you want to view?
set /p "userInput="
if "%userInput%" == "0" goto sudokuMenu
if "%userInput%" == "1" call :viewSudoku sudokuPuzzleMatrix sudokuPuzzleArray
if "%userInput%" == "2" call :viewSudoku sudokuAnswerMatrix sudokuAnswerArray
if "%userInput%" == "3" call :viewSudoku sudokuSaveMatrix   sudokuSaveArray
if /i "%userInput%" == "A" goto viewArray
goto viewMenu

:viewSudoku
if not defined %2 goto :EOF
echo=
echo Collecting information...
call :sudokuInfo %1
set "boardText17=[C] Copy array to clipboard"
cls
call :sudokuBoard %1
set /p "userInput=Press enter to continue...              |>"
if /i not "%userInput%" == "C" goto viewMenu
set/p "=!%2!" < nul | clip
set "userInput=."
echo Copied array to clipboard
pause > nul
goto viewSudoku

:viewArray
cls
if defined sudokuPuzzleArray (
    echo Puzzle :
    echo [!sudokuPuzzleArray:~0,27!]
    echo [!sudokuPuzzleArray:~27,27!]
    echo [!sudokuPuzzleArray:~54,27!]
    echo=
)
if defined sudokuAnswerArray (
    echo Answer :
    echo [%sudokuAnswerArray:~0,27%]
    echo [%sudokuAnswerArray:~27,27%]
    echo [%sudokuAnswerArray:~54,27%]
    echo=
)
if defined sudokuSaveArray (
    echo Save   :
    echo [%sudokuSaveArray:~0,27%]
    echo [%sudokuSaveArray:~27,27%]
    echo [%sudokuSaveArray:~54,27%]
    echo=
)
echo=
pause
goto viewMenu
rem ==================================== Solve =====================================

:solveSetup
call :selectSudoku Y
if "%userInput%" == "0" goto sudokuMenu
set "solveSaves=N"
if not defined sudokuSaveArray goto solveShowStepIn
:solveSavesIn
set "solveSaves=?"
cls
echo Save data found
echo Do you want to solve the save data with solver?
set /p "solveSaves=Y/N? "
if /i "%solveSaves%" == "Y" goto solveShowStepIn
if /i "%solveSaves%" == "N" goto solveShowStepIn
echo=
echo Invalid choice
pause
goto solveSavesIn
:solveShowStepIn
set "showSteps=?"
cls
echo Do you want to show solving steps?
set /p "showSteps=Y/N? "
if /i "%showSteps%" == "Y" goto solverSolveSetup
if /i "%showSteps%" == "N" goto solverSolveSetup
echo=
echo Invalid choice
pause
goto solveShowStepIn
:solverSolveSetup
if /i "%solveSaves%" == "Y" (
    call :matrix create solverPuzzleMatrix sudokuSaveArray
    call :matrix create solverPlayMatrix sudokuSaveArray
) else (
    call :matrix create solverPuzzleMatrix sudokuPuzzleArray
    call :matrix create solverPlayMatrix sudokuPuzzleArray
)
call :actionReset
call :sudokuInfo solverPuzzleMatrix
cls
call :sudokuBoard solverPuzzleMatrix
echo Press any key to start solving
pause > nul
echo Solving sudoku...
set "time1=%time%"
if /i "%showSteps%" == "Y" (
    mode 95,40
    call :solveSudoku solverPlayMatrix solverUpdate
    mode 80,25
) else call :solveSudoku solverPlayMatrix
call :Time_Subtract %time1% %time%
call :Time_CS_Format %return%
if "%solvedCells%" == "%cellEmptyNum%" goto solveDone
if not "%sudokuErrorNum%" == "0" goto solveError
if /i "%showSteps%" == "Y" (
    mode 95,40
    call :solverUpdate solverPlayMatrix E
    mode 80,25
)
call :sudokuInfo solverPuzzleMatrix
call :matrix find 0 solverPlayMatrix
set /a cellGivenNum= %sudokuArea% - %cellEmptyNum%
set  "boardText6=Givens now     : %cellGivenNum%"
cls
call :sudokuBoard solverPlayMatrix
echo This sudoku is either too hard for solver or it is invalid
choice /c YN /m "Do you want to use bruteforce?"
if "%errorlevel%" == "2" (
    if "%solvedCells%" == "0" goto sudokuMenu
    echo Sudoku saved to memory, you can view or load it later
    choice /c YN /m "Do you want to save this partially solved sudoku?"
    call :matrix toArray solverPlayMatrix sudokuSaveArray
    if "!errorlevel!" == "1" call :saveSudoku S Y A sudokuPuzzleArray A sudokuAnswerArray A sudokuSaveArray
    goto sudokuMenu
)

choice /c YN /m "Do you want to count number of solutions?"
if "%errorlevel%" == "1" set "userInput=Y"
if "%errorlevel%" == "2" set "userInput=N"
cls
call :sudokuBoard solverPlayMatrix
echo Press any key to start bruteforce solving
pause > nul
echo Bruteforcing sudoku...
call :bruteforceSudoku solverPlayMatrix %userInput%
call :sudokuInfo solverPuzzleMatrix
cls
call :sudokuBoard solverPlayMatrix
echo Done in %time2% with %guessesNum% guesses
if "%solutionCount%" == "%solutionCountMax%" (
    echo At least %solutionCount% solutions found
) else echo %solutionCount% solution(s) found
if not "%solutionCount%" == "0" echo First solution found in %solution1Time% with %solution1Guess% guesses
pause > nul
call :matrix toArray solverPlayMatrix sudokuAnswerArray
call :promptSave P Y A sudokuPuzzleArray A sudokuAnswerArray
goto sudokuMenu

:solverUpdate [Matrix] [Method] [Number] [CellCode]
set "tempVar1=%2"
if "%tempVar1:~0,1%" == "1" call :actionMark %1 %4 %3
call :logUpdate
cls
call :sudokuBoard %1
echo ---------------------------------------- Possibilities ----------------------------------------
call :possibilityBoard possibilities
if /i "%2" == "E" echo Solver did not have enough logic to solve sudoku...
if "%2" == "1" echo Single candidate [%4]
if "%2" == "1r" echo Hidden single in row [%4]
if "%2" == "1c" echo Hidden single in column [%4]
if "%2" == "1b" echo Hidden single in box [%4]
pause > nul
goto :EOF

:solveDone
call :checkValidMatrix A solverPlayMatrix
if not "%sudokuErrorNum%" == "0" goto solveError
cls
call :sudokuBoard solverPlayMatrix
if /i "%showSteps%" == "Y" (
    echo Solve done
) else echo Solved in [%return%]
pause > nul
call :matrix toArray solverPlayMatrix sudokuAnswerArray
call :promptSave P Y A sudokuPuzzleArray A sudokuAnswerArray
goto sudokuMenu

:solveError
cls
call :sudokuBoard solverPlayMatrix
echo Found %sudokuErrorNum% errors on sudoku:
echo=%cellInvalidList%
echo=
pause > nul
goto sudokuMenu

rem ================================== Generate ====================================

:generateSetup
set "genEmptyNum=0"
set "generateMode=0"
set /a improveEmptyNum=%sudokuArea%*60/100
:generateLvlIn
set "generateLvl=?"
cls
echo 1. Easy
echo 2. Random (Could range from easy to beyond extreme)
echo=
echo C. Custom
echo 0. Back
echo=
echo Input difficulty level:
set /p "generateLvl="
if "%generateLvl%" == "0" goto sudokuMenu
if /i "%generateLvl%" == "C" goto generateCustomMenu
if %generateLvl% GEQ 1 if %generateLvl% LEQ 2 goto generateStart
echo=
echo Invalid choice
pause
goto generateLvlIn

:generateCustomMenu
cls
echo 1. Number of empty cells [%genEmptyNum%]
echo=
echo 0. Back
echo=
echo What do you want to custom?
set /p "userInput="
if "%userInput%" == "0" goto generateLvlIn
if "%userInput%" == "1" goto generateCustomEmptyNum
set "generateMode=%userInput%"
echo=
echo Invalid choice
pause
goto generateCustomMenu

:generateCustomEmptyNum
set /a minEmptyNum=%sudokuArea%*10/100 + 1
cls
echo Default    : 0 (Maximum number of empty cells available)
echo=
echo Custom     : %minEmptyNum% - %improveEmptyNum%
echo=
echo Input number of empty cells :
set /p "userInput="
if %userInput% GEQ %minEmptyNum% if %userInput% LEQ %improveEmptyNum% (
    set "genEmptyNum=%userInput%"
    goto generateCustomMenu
)
echo=
echo Invalid input
pause
goto generateCustomEmptyNum

:generateStart
cls
echo Sudoku size        : %sudokuSize%x%sudokuSize%   [%sudokuBlockWidth%x%sudokuBlockHeight%]
echo Difficulty level   : %generateLvl%
echo=
set/p "=!clearLine!Generating answer..." < nul
set "time1=%time%"
call :generateSudoku sudokuAnswerMatrix 111
for /l %%n in (1,1,11) do (
    set /a num1=!random! %% %sudokuSize% + 1
    set /a num2=!random! %% %sudokuSize% + 1
    call :matrix switch !num1! !num2!
)
call :matrix toArray sudokuAnswerMatrix sudokuAnswerArray
call :matrix copy sudokuAnswerMatrix sudokuPuzzleMatrix
set "timeAnswer=%time2%"
echo !clearLine!Generate answer done
set "cellEmptyCount=0"
set "genAttempts=0"
goto generatePuzzleLvl%generateLvl%
goto errorUnexpected

:generatePuzzleLvl1
if %genAttempts% GTR %sudokuArea% goto generateLimit
set /a genAttempts+=1
call :cellRandom sudokuPuzzleMatrix N
set "removeCell=%cellCode%"
set "sudokuPuzzleMatrix%removeCell%= "
call :matrix copy sudokuPuzzleMatrix solverPlayMatrix
call :solveSudoku solverPlayMatrix
if not "%solvedCells%" == "%cellEmptyNum%" (
    set "sudokuPuzzleMatrix%removeCell%=!sudokuAnswerMatrix%removeCell%!"
    goto generatePuzzleLvl1
)
set /a cellEmptyCount+=1
set /a progressNum=%cellEmptyCount% * 100 / %improveEmptyNum%
echo|set/p=!clearLine!Generating puzzle... !progressNum!%%
if "%cellEmptyCount%" == "%genEmptyNum%" goto generateDone
if not "%cellEmptyCount%" == "%improveEmptyNum%" goto generatePuzzleLvl1
echo=
set /a tempVar1=%sudokuArea%-%improveEmptyNum%
set "count=0"
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if not "!sudokuPuzzleMatrix%%r%%c!" == " " (
        set "sudokuPuzzleMatrix%%r%%c= "
        call :matrix copy sudokuPuzzleMatrix solverPlayMatrix
        call :solveSudoku solverPlayMatrix
        if not "!solvedCells!" == "!cellEmptyNum!" set "sudokuPuzzleMatrix%%r%%c=!sudokuAnswerMatrix%%r%%c!"
        set /a count+=1
        set /a progressNum=!count! * 100 / %tempVar1%
        echo|set/p=!clearLine!Improving puzzle... !progressNum!%%
    )
)
echo=
goto generateDone

:generatePuzzleLvl2
if %genAttempts% GTR %sudokuArea% goto generateLimit
set /a genAttempts+=1
call :cellRandom sudokuPuzzleMatrix N
set "removeCell=%cellCode%"
set "sudokuPuzzleMatrix%removeCell%= "
call :matrix copy sudokuPuzzleMatrix solverPlayMatrix
call :bruteforceSudoku solverPlayMatrix C
if not "!solutionCount!" == "1" (
    set "sudokuPuzzleMatrix%removeCell%=!sudokuAnswerMatrix%removeCell%!"
    goto generatePuzzleLvl2
)
set /a cellEmptyCount+=1
set /a progressNum=%cellEmptyCount% * 100 / %improveEmptyNum%
echo|set/p=!clearLine!Generating puzzle... !progressNum!%%
if "%cellEmptyCount%" == "%genEmptyNum%" goto generateDone
if not "%cellEmptyCount%" == "%improveEmptyNum%" goto generatePuzzleLvl2
echo=
set /a tempVar1=%sudokuArea%-%improveEmptyNum%
set "count=0"
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if not "!sudokuPuzzleMatrix%%r%%c!" == " " (
        set "sudokuPuzzleMatrix%%r%%c= "
        call :matrix copy sudokuPuzzleMatrix solverPlayMatrix
        call :bruteforceSudoku solverPlayMatrix C
        if not "!solutionCount!" == "1" set "sudokuPuzzleMatrix%%r%%c=!sudokuAnswerMatrix%%r%%c!"
        set /a count+=1
        set /a progressNum=!count! * 100 / %tempVar1%
        echo|set/p=!clearLine!Improving puzzle... !progressNum!%%
    )
)
echo=
goto generateDone

:generateLimit
echo=
echo Generate limit reached, repeating...
call :matrix toArray sudokuPuzzleMatrix sudokuPuzzleArray
echo %sudokuPuzzleArray% >> "%pathData%%sudokuBlockWidth%x%sudokuBlockHeight%\GenLimited.txt"
goto generateStart

:generateDone
echo Preparing sudoku...
call :matrix toArray sudokuPuzzleMatrix sudokuPuzzleArray
call :Time_Subtract %time1% %time%
call :Time_CS_Format %return%
call :Time_Subtract %timeAnswer% %return%
set "genTime=%return%"
call :Time_CS_Format %return%
set "time1=%return%"
set "sudokuName=Level%generateLvl% @%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
call :sudokuInfo sudokuPuzzleMatrix
if /i "%generateMode%" == "G" (
    call :saveSudoku P Y A sudokuPuzzleArray
    goto generateStart
)
set /a tempVar1=%sudokuArea%*25/100
if /i "%generateMode%" == "S" (
    if "%sudokuLevel%" == "2" (
        set "sudokuName=NE_!sudokuName!"
        call :saveSudoku P N A sudokuPuzzleArray
    ) else if %cellGivenNum% LEQ %tempVar1% (
        set "sudokuName=G%cellGivenNum%_!sudokuName!"
        call :saveSudoku P N A sudokuPuzzleArray
    )
    goto generateStart
)

cls
title Sudoku
call :sudokuBoard sudokuPuzzleMatrix
echo=
echo Generate puzzle done in %time1% and selected this sudoku
if /i "%generateMode%" == "P" (
    set /p "userInput=[X] Exit                 "
    if /i "!userInput!" == "X" goto sudokuMenu
    goto generateStart
)
pause
call :promptSave P Y A sudokuPuzzleArray A sudokuAnswerArray
goto sudokuMenu

rem ================================= Generate Info ================================

:genInfo_Solve
set /a sudokuCount+=1
set "selectedName=%sudokuCount%"
set "selectedPuzzleArray=%1"
call :checkValidArray selectedPuzzleArray
if "%return%" == "1" goto list_ToSolve_Error
call :matrix create selectedPuzzleMatrix selectedPuzzleArray
call :checkValidMatrix P selectedPuzzleMatrix
set /a cellGivenNum=%sudokuArea% - %cellEmptyNum%
if not "!sudokuErrorNum!" == "0" goto list_ToSolve_Error
set "sudokuName=%selectedName%"
set "sudokuPuzzleArray=%selectedPuzzleArray%"
call :matrix create solverPuzzleMatrix sudokuPuzzleArray
call :matrix create solverPlayMatrix sudokuPuzzleArray

call :bruteforceSudoku solverPlayMatrix Y

echo Sudoku #%sudokuCount% - %solutionCount%S %cellGivenNum%C %solution1Guess%/%guessesNum%G [%solution1Time%/%time2%]
echo     %sudokuPuzzleArray: =.%_%cellGivenNum%_%solutionCount%_%solution1Guess%/%guessesNum% >> %saveFile%
goto :EOF

:genInfo_Error
echo Sudoku #%sudokuCount% - E
echo     %sudokuPuzzleArray: =.%_E >> %saveFile%
goto :EOF

rem ===================================== Menu =====================================

:selectSudoku [validcheck]
set "selectedName="
set "selectInput=0"
set "userInput=0"
set "selectedPuzzleArray="
set "selectedAnswerArray="
cls
echo 1. Sudoku from list 
echo 2. Custom sudoku file
if defined sudokuPuzzleArray echo 3. Previous used / entered sudoku
echo=
echo 0. Back
echo=
echo Select sudoku  :
set /p "selectInput="
if "%selectInput%" == "0" goto :EOF
if "%selectInput%" == "1" goto selectList
if "%selectInput%" == "2" goto selectCustom
if defined sudokuPuzzleArray if "%selectInput%" == "3" goto selectPrevious
echo=
echo Invalid choice
pause
goto selectSudoku
:checkSelected [validcheck]
echo=
echo Checking sudoku puzzle...
call :checkValidArray selectedPuzzleArray
if "%return%" == "1" goto selectArrayBad
call :matrix create selectedPuzzleMatrix selectedPuzzleArray
if /i "%1" == "Y" (
    call :checkValidMatrix P selectedPuzzleMatrix
    if not "!sudokuErrorNum!" == "0" goto selectMatrixBad
)
if not defined selectedAnswerArray goto selectFindSaves
call :checkValidArray selectedAnswerArray
if "%return%" == "1" goto selectPuzzleOnly
call :matrix create selectedAnswerMatrix selectedAnswerArray
if /i "%1" == "Y" (
    call :checkValidMatrix A selectedAnswerMatrix
    if not "!sudokuErrorNum!" == "0" goto selectPuzzleOnly
    call :matrix compare selectedPuzzleMatrix selectedAnswerMatrix
    if not "!return!" == "0" goto selectPuzzleOnly
)
:selectFindSaves
set "sudokuName=%selectedName%"
if not defined selectedName set "sudokuName=@%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "sudokuPuzzleArray=%selectedPuzzleArray%"
set "sudokuAnswerArray=%selectedAnswerArray%"
set "userInput=1"
if not defined selectedSaveArray (
    set "selectedPuzzleArray="
    if not exist "%pathSaves%%sudokuName%.bat" goto :EOF
    call "%pathSaves%%sudokuName%.bat"
)
if not defined selectedPuzzleArray goto :EOF
if not defined selectedSaveArray goto :EOF
call :checkValidArray selectedPuzzleArray
if "%return%" == "1" goto :EOF
if not "%selectedPuzzleArray%" == "%sudokuPuzzleArray%" goto :EOF
call :array compare sudokuPuzzleArray selectedSaveArray
set "sudokuSaveArray=%selectedSaveArray%"
if "%return%" == "0" goto :EOF
set "sudokuSaveArray="
set "selectedSaveArray="
goto :EOF
:selectPuzzleOnly
echo The answer contain errors 
echo  or the puzzle doesn't match with the answer
echo Script will continue without answer
pause
set "selectedAnswerArray="
goto selectFindSaves
:selectArrayBad
echo Invalid array format detected
echo Cannot use this sudoku
pause
if "%selectInput%" == "1" goto selectList
if "%selectInput%" == "2" goto selectCustom
if "%selectInput%" == "3" goto selectSudoku
goto errorUnexpected
:selectMatrixBad
echo Sudoku puzzle is invalid, it contain errors
pause
set "selectedPuzzleArray="
set "selectedAnswerArray="
if "%selectInput%" == "1" goto selectList
if "%selectInput%" == "2" goto selectCustom
if "%selectInput%" == "3" goto selectSudoku
goto errorUnexpected
:selectPrevious
set "selectedName=!sudokuName!"
set "selectedPuzzleArray=!sudokuPuzzleArray!"
set "selectedAnswerArray=!sudokuAnswerArray!"
set "selectedSaveArray=!sudokuSaveArray!"
goto checkSelected
:selectList
call :list_Default%sudokuBlockWidth%x%sudokuBlockHeight% 2> nul
if "%errorlevel%" == "0" (
    if "%userInput%" == "0" goto selectSudoku
    goto checkSelected
)
echo=
echo ERROR: List not found
pause
goto selectSudoku
:selectCustom
cls
dir "%pathPuzzles%*.bat" /b /o:d /p 2> nul
if "%errorlevel%" == "1" goto selectCustomEmpty
echo=
echo 0. Back
echo=
echo Input file name    :
set /p "userInput="
if "%userInput%" == "0" goto selectSudoku
if exist "%pathPuzzles%%userInput%.bat" goto selectCustomCall
if exist "%pathPuzzles%%userInput%" (
    set "userInput=!userInput:~0,-4!"
    goto selectCustomCall
)
echo=
echo File not found
pause
goto selectCustom
:selectCustomCall
set "selectedName=%userInput%"
call "%pathPuzzles%%userInput%" 2> nul
if defined selectedPuzzleArray goto checkSelected
echo=
echo No sudoku puzzle data found in that file
pause
goto selectCustom
:selectCustomEmpty
echo **** No Files Found ***
echo=
echo No sudoku files found in %pathPuzzles%
echo=
echo 1. Input custom sudoku
echo 2. Refresh
echo=
echo 0. Back
echo=
echo What do you want to do?
set /p "userInput="
if "%userInput%" == "0" goto selectSudoku
if "%userInput%" == "1" goto inputSudoku
if "%userInput%" == "2" goto selectCustom
echo=
echo Invalid choice
pause
goto selectCustomEmpty

:promptSave [Location] [ShowInfo] [Type] [PuzzleArray] [Type] [AnswerArray] [Type] [SaveArray]
cls
echo Data   :
if not "%3" == "" echo - Puzzle
if not "%5" == "" echo - Answer
if not "%7" == "" echo - Play / Save
echo=
echo Save to file?
set /p "userInput=Y/N? "
if /i "%userInput%" == "N" goto :EOF
if /i "%userInput%" == "Y" goto sudokuNameIn
echo=
echo Invalid choice
pause
goto promptSave
:sudokuNameIn
cls
echo Name   : %sudokuName%
echo=
echo Enter nothing to use the name above
echo=
echo Input sudoku name  :
set /p "sudokuName="
if "%1" == "P" if not exist "%pathPuzzles%%sudokuName%.bat" goto saveSudoku
if "%1" == "S" if not exist "%pathSaves%%sudokuName%.bat" goto saveSudoku
echo=
echo Sudoku file with that name exist
echo Overwrite sudoku?
set /p "userInput=Y/N? "
if /i "%userInput%" == "N" goto sudokuNameIn
if /i "%userInput%" == "Y" goto saveSudoku
echo=
echo Invalid choice
pause
goto sudokuNameIn
:saveSudoku [Location] [ShowInfo] [Type] [PuzzleArray] [Type] [AnswerArray] [Type] [SaveArray]
set "pathUsed=%pathData%"
if "%1" == "P" set "pathUsed=%pathPuzzles%"
if "%1" == "S" set "pathUsed=%pathSaves%"
if not exist "%pathUsed%" md "%pathUsed%"
if /i "%3" == "M" if not "%4" == "" call :matrix toArray %4 saveArray1
if /i "%5" == "M" if not "%6" == "" call :matrix toArray %6 saveArray2
if /i "%7" == "M" if not "%8" == "" call :matrix toArray %8 saveArray3
if /i "%3" == "A" set "saveArray1=!%4!"
if /i "%5" == "A" set "saveArray2=!%6!"
if /i "%7" == "A" set "saveArray3=!%8!"
set "saveActionLog=%actionLog%"
set "saveActionNum=%actionNum%"
set "return=2"
if "%saveArray1%%saveArray2%%saveArray3%" == "" goto saveNothing
set "return=1"
if not defined sudokuName set "sudokuName=@%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
for /l %%n in (1,1,3) do if defined saveArray%%n set "saveArray%%n=!saveArray%%n: =0!"
(
    if not "%saveArray1%" == "" echo set "selectedPuzzleArray=%saveArray1%"
    if not "%saveArray2%" == "" echo set "selectedAnswerArray=%saveArray2%"
    if not "%saveArray3%" == "" echo set   "selectedSaveArray=%saveArray3%"
) > "%pathUsed%%sudokuName%.bat"
if not exist "%pathUsed%%sudokuName%.bat" goto saveError
set "selectedPuzzleArray="
set "selectedAnswerArray="
set   "selectedSaveArray="
call "%pathUsed%%sudokuName%.bat"
if not "%selectedPuzzleArray%" == "%saveArray1%" goto saveError
if not "%selectedAnswerArray%" == "%saveArray2%" goto saveError
if not   "%selectedSaveArray%" == "%saveArray3%" goto saveError
set "return=0"
if /i "%2" == "N" goto :EOF
echo Save success: Save as [%sudokuName%]
pause
goto :EOF
:saveError
if /i "%2" == "N" goto :EOF
echo Save failed: Cannot write data to file, saved to memory
pause
goto :EOF
:saveNothing
if /i "%2" == "N" goto :EOF
echo Save failed: All sudoku arrays are empty, nothing to save...
pause
goto :EOF

:loadSudoku
if "%sudokuSaveArray%%saveArray3%" == "" goto loadNothing
set "loadArray=%sudokuSaveArray%"
if defined saveArray3 set "loadArray=%saveArray3%"
call :checkValidArray loadArray
call :matrix create sudokuPlayMatrix loadArray
set "actionLog=%saveActionLog%"
set "actionNum=%saveActionNum%"
goto :EOF
:loadNothing
echo Load failed: No save data found
pause
goto :EOF

rem Functions

:checkDuplicate
set "sudokuErrorNum=0"
set "cellInvalidList="
set "count=0"
for %%r in (%rowCode%) do (
    for /l %%n in (1,1,%sudokuSize%) do set "count%%n=0"
    for /l %%c in (1,1,%sudokuSize%) do set /a count!%1%%r%%c!+=1
    for /l %%n in (1,1,%sudokuSize%) do if !count%%n! GTR 1 (
        for /l %%c in (1,1,%sudokuSize%) do if "!%1%%r%%c!" == "%%n" set "cellInvalidList=!cellInvalidList! %%r%%c"
    )
)
for /l %%c in (1,1,%sudokuSize%) do (
    for /l %%n in (1,1,%sudokuSize%) do set "count%%n=0"
    for %%r in (%rowCode%) do set /a count!%1%%r%%c!+=1
    for /l %%n in (1,1,%sudokuSize%) do if !count%%n! GTR 1 (
        for %%r in (%rowCode%) do if "!%1%%r%%c!" == "%%n" set "cellInvalidList=!cellInvalidList! %%r%%c"
    )
)
for /l %%b in (1,1,%sudokuSize%) do (
    for /l %%n in (1,1,%sudokuSize%) do set "count%%n=0"
    for %%r in (!block%%bRow!) do for %%c in (!block%%bCol!) do set /a count!%1%%r%%c!+=1
    for /l %%n in (1,1,%sudokuSize%) do if !count%%n! GTR 1 (
        for %%r in (!block%%bRow!) do for %%c in (!block%%bCol!) do (
            if "!%1%%r%%c!" == "%%n" set "cellInvalidList=!cellInvalidList! %%r%%c"
        )
    )
)
set /a cellEmptyNum=%count%/3
set "count="
set "tempVar1= !cellInvalidList!"
set "cellInvalidList="
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do (
        if not "!tempVar1:%%r%%c=!" == "!tempVar1!" (
            set /a sudokuErrorNum+=1
            set "cellInvalidList=!cellInvalidList! %%r%%c"
        )
    )
)
goto :EOF

:generateSudoku [Matrix] [Stop]
set "saveStateData=X"
set "previousValue=0"
set "solutionCount=0"
set "guessesNum=16"
set "previousValue=0"
set "solvedCells=0"
set "cellEmptyNum=%sudokuArea%"
set "time3=%time%"
call :matrix clear %1
call :showPossibilities %1
set /a tempVar1=%sudokuArea%*20/100
for /l %%n in (1,1,%tempVar1%) do (
    title Sudoku - Prepaing... [%%n/%tempVar1%]
    call :cellRandom %1 Y
    set "tempVar1=!cellCode:~0,1!"
    for %%r in (!tempVar1!) do for %%c in (!cellCode:~1!) do (
        for /l %%l in (%sudokuSize%,-1,0) do if "!possibilities%%r%%c:~%%l,1!" == "" set "tempVar1=%%l"
        set /a tempVar1=!random! %% !tempVar1!
        for %%l in (!tempVar1!) do set "%1%%r%%c=!possibilities%%r%%c:~%%l,1!"
        for %%e in (!%1%%r%%c!) do for %%s in (!block%%r%%c!) do (
            for %%y in (!block%%sRow!) do for %%x in (!block%%sCol!) do if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
            for %%y in (!eliminateRow%%s!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
            for %%x in (!eliminateCol%%s!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
            set "possibilities%%r%%c=%%e"
        )
        call :matrix toArray %1 saveArray
        set "saveStateData=!saveStateData!!saveArray!!%1%%r%%c!"
    )
)
set "ansSeed=%saveArray%"
call :bruteforceSolve %1 N %2
if "%solutionCount%" == "1" goto :EOF
echo !clearLine!Generate answer too slow, repeating...
goto generateSudoku

:bruteforceSudoku [Matrix] [SolutionCount] [Stop]
set "solutionCount=0"
set "guessesNum=0"
set "saveStateData=X"
set "previousValue=0"
set "time3=%time%"
set "solvedCells=0"
set "cellEmptyNum=%sudokuArea%"
:bruteforceSolve [Matrix] [SolutionCount] [Stop]
set "tempVar1=0"
set "return="
for %%t in (%time% %time3%) do (
    for /f "tokens=1-4 delims=:." %%a in ("%%t") do set /a  tempVar1+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100
    set /a tempVar1*=-1
)
if %tempVar1% LSS 0 set /a return+=8640000
for %%n in (360000 6000 100 1) do (
    set /a tempVar2=!tempVar1! / %%n
    set /a tempVar1=!tempVar1! %% %%n
    set "tempVar2=T0!tempVar2!"
    set "return=!return!!tempVar2:~-2,2!:"
)
set "return=%return:~0,-4%.%return:~-3,2%"
set /a tempVar1=%solvedCells% * 100 / %cellEmptyNum%
title Sudoku - [%return%] Progress #%guessesNum%: %tempVar1%%% ^| Found %solutionCount% solutions

call :solveSudoku %1
if not "%sudokuErrorNum%" == "0" goto bruteforceBack
if "%solvedCells%" == "%cellEmptyNum%" goto bruteforceSolved
:bruteforceNext
set "lpNum=%sudokuSize%"
for %%r in (%rowCode%) do for /l %%c in (1,1,%sudokuSize%) do (
    if "!%1%%r%%c!" == " " for %%l in (!lpNum!) do if "!possibilities%%r%%c:~%%l,1!" == "" (
        set "cellCode=%%r%%c"
        for /l %%n in (1,1,8) do if not "!possibilities%%r%%c:~%%n,1!" == "" set "lpNum=%%n"
    )
)
set "nextValue="
set "tempVar1=!possibilities%cellCode%!"
for /l %%n in (1,1,%sudokuSize%) do set "tempVar1=!tempVar1:%%n= %%n!"
for %%n in (!tempVar1!) do if not defined nextValue if %%n GTR %previousValue% set "nextValue=%%n"
if not defined nextValue goto bruteforceBack
set "saveArray="
for %%r in (%rowCode%) do for /l %%c in (1,1,%sudokuSize%) do set "saveArray=!saveArray!!%1%%r%%c!"
set "previousValue=0"
set "%1%cellCode%=%nextValue%"
set "saveStateData=%saveStateData%%saveArray%%nextValue%"
set /a guessesNum+=1
goto bruteforceSolve
:bruteforceSolved
set /a solutionCount+=1
call :matrix toArray %1 sudokuAnswerArray%solutionCount%
if "%solutionCount%" == "1" (
    call :Time_Subtract %time3% %time%
    call :Time_CS_Format !return!
    set "solution1Time=!return!"
    set "solution1Guess=%guessesNum%"
)
if /i "%2" == "N" goto bruteforceEnd
if /i "%2" == "C" if "%solutionCount%" == "2" goto bruteforceEnd
if "%solutionCount%" == "%solutionCountMax%" goto bruteforceEnd
:bruteforceBack
if "%saveStateData:~-1,1%" == "X" goto bruteforceEnd
set "previousValue=%saveStateData:~-1,1%"
set "saveStateData=%saveStateData:~0,-1%"
set "saveArray=!saveStateData:~-%sudokuArea%,%sudokuArea%!"
set "saveStateData=!saveStateData:~0,-%sudokuArea%!"

set "tempVar1=%saveArray%"
for %%r in (%rowCode%) do for /l %%c in (1,1,%sudokuSize%) do (
    set "%1%%r%%c=!tempVar1:~0,1!"
    set "tempVar1=!tempVar1:~1!"
)

for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if "!%1%%r%%c!" == " " (
        set "possibilities%%r%%c=%allNumList%"
    ) else set "possibilities%%r%%c=!%1%%r%%c!"
)
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if not "!%1%%r%%c!" == " " for %%b in (!block%%r%%c!) do for %%e in (!%1%%r%%c!) do (
        for %%y in (!block%%bRow!) do for %%x in (!block%%bCol!) do (
            if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
        )
        for %%y in (!eliminateRow%%b!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
        for %%x in (!eliminateCol%%b!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
        set "possibilities%%r%%c=%%e"
    )
)
if not "%3" == "" if %guessesNum%0 GEQ %30 goto bruteforceEnd
goto bruteforceNext
:bruteforceEnd
call :Time_Subtract %time3% %time%
call :Time_CS_Format %return%
set "time2=%return%"
title Sudoku
if "%solutionCount%" == "0" (
    set "saveArray=!saveStateData:~1,%sudokuArea%!"
) else set "saveArray=%sudokuAnswerArray1%"
call :matrix create %1 saveArray
goto :EOF

:solveSudoku [Matrix] [UpdateLabel]
set "sudokuErrorNum=0"
set "cellInvalidList="
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if "!%1%%r%%c!" == " " (
        set "possibilities%%r%%c=%allNumList%"
    ) else set "possibilities%%r%%c=!%1%%r%%c!"
)
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if "!%1%%r%%c!" == " " (
        set "possibilities%%r%%c=%allNumList%"
    ) else set "possibilities%%r%%c=!%1%%r%%c!"
)
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if not "!%1%%r%%c!" == " " for %%b in (!block%%r%%c!) do for %%e in (!%1%%r%%c!) do (
        for %%y in (!block%%bRow!) do for %%x in (!block%%bCol!) do (
            if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
        )
        for %%y in (!eliminateRow%%b!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
        for %%x in (!eliminateCol%%b!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
        set "possibilities%%r%%c=%%e"
    )
)
set "solvedCells=0"
set "cellEmptyNum=0"
for %%r in (%rowCode%) do for /l %%c in (1,1,%sudokuSize%) do if "!%1%%r%%c!" == " " set /a cellEmptyNum+=1
:solveLoop
rem Check for singles
set "solvedCellsNow=%solvedCells%"
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do (
        if "!%1%%r%%c!" == " " (
            if defined possibilities%%r%%c (
                if "!possibilities%%r%%c:~1!" == "" (
                    set /a solvedCells+=1
                    if not "%2" == "" call :%2 %1 1 !possibilities%%r%%c! %%r%%c
                    set "%1%%r%%c=!possibilities%%r%%c!"
                    for %%e in (!%1%%r%%c!) do for %%s in (!block%%r%%c!) do (
                        for %%y in (!block%%sRow!) do for %%x in (!block%%sCol!) do if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
                        for %%y in (!eliminateRow%%s!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
                        for %%x in (!eliminateCol%%s!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
                        set "possibilities%%r%%c=%%e"
                    )
                )
            ) else (
                set /a sudokuErrorNum+=1
                set "cellInvalidList=!cellInvalidList! %%r%%c"
            )
        )
    )
)
if "%solvedCells%" == "%cellEmptyNum%" goto :EOF
if not "%sudokuErrorNum%" == "0" goto :EOF
if not "%solvedCells%" == "%solvedCellsNow%" goto solveLoop

rem Check for hidden singles
for %%r in (%rowCode%) do (
    set "numList=%allNumSpaced%"
    for /l %%c in (1,1,%sudokuSize%) do for %%n in (!%1%%r%%c!) do set "numList=!numList: %%n=!"
    for /l %%n in (1,1,%sudokuSize%) do set "count%%n=0"
    for /l %%c in (1,1,%sudokuSize%) do for %%n in (!numList!) do (
        if defined possibilities%%r%%c (
            if not "!possibilities%%r%%c:%%n=!" == "!possibilities%%r%%c!" set /a count%%n+=1
        ) else (
            set /a sudokuErrorNum+=1
            set "cellInvalidList=!cellInvalidList! %%r%%c"
        )
    )
    for %%n in (!numList!) do if "!count%%n!" == "1" (
        for /l %%c in (1,1,%sudokuSize%) do if not "!possibilities%%r%%c:%%n=!" == "!possibilities%%r%%c!" (
            set /a solvedCells+=1
            if not "%2" == "" call :%2 %1 1r %%n %%r%%c
            set "%1%%r%%c=%%n"
            for %%e in (!%1%%r%%c!) do for %%s in (!block%%r%%c!) do (
                for %%y in (!block%%sRow!) do for %%x in (!block%%sCol!) do if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
                for %%y in (!eliminateRow%%s!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
                for %%x in (!eliminateCol%%s!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
                set "possibilities%%r%%c=%%e"
            )
        )
    )
)
for /l %%c in (1,1,%sudokuSize%) do (
    set "numList=%allNumSpaced%"
    for %%r in (%rowCode%) do for %%n in (!%1%%r%%c!) do set "numList=!numList: %%n=!"
    for /l %%n in (1,1,%sudokuSize%) do set "count%%n=0"
    for %%r in (%rowCode%) do for %%n in (!numList!) do (
        if defined possibilities%%r%%c (
            if not "!possibilities%%r%%c:%%n=!" == "!possibilities%%r%%c!" set /a count%%n+=1
        ) else (
            set /a sudokuErrorNum+=1
            set "cellInvalidList=!cellInvalidList! %%r%%c"
        )
    )
    for %%n in (!numList!) do if "!count%%n!" == "1" (
        for %%r in (%rowCode%) do if not "!possibilities%%r%%c:%%n=!" == "!possibilities%%r%%c!" (
            set /a solvedCells+=1
            if not "%2" == "" call :%2 %1 1c %%n %%r%%c
            set "%1%%r%%c=%%n"
            for %%e in (!%1%%r%%c!) do for %%s in (!block%%r%%c!) do (
                for %%y in (!block%%sRow!) do for %%x in (!block%%sCol!) do if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
                for %%y in (!eliminateRow%%s!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
                for %%x in (!eliminateCol%%s!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
                set "possibilities%%r%%c=%%e"
            )
        )
    )
)
for /l %%b in (1,1,%sudokuSize%) do (
    set "numList=%allNumSpaced%"
    for %%r in (!block%%bRow!) do for %%c in (!block%%bCol!) do (
        for %%n in (!%1%%r%%c!) do set "numList=!numList: %%n=!"
    )
    for /l %%n in (1,1,%sudokuSize%) do set "count%%n=0"
    for %%r in (!block%%bRow!) do for %%c in (!block%%bCol!) do for %%n in (!numList!) do (
        if defined possibilities%%r%%c (
            if not "!possibilities%%r%%c:%%n=!" == "!possibilities%%r%%c!" set /a count%%n+=1
        ) else (
            set /a sudokuErrorNum+=1
            set "cellInvalidList=!cellInvalidList! %%r%%c"
        )
    )
    for %%n in (!numList!) do if "!count%%n!" == "1" (
        for %%r in (!block%%bRow!) do for %%c in (!block%%bCol!) do (
            if not "!possibilities%%r%%c:%%n=!" == "!possibilities%%r%%c!" (
                set /a solvedCells+=1
                if not "%2" == "" call :%2 %1 1b %%n %%r%%c
                set "%1%%r%%c=%%n"
                for %%e in (!%1%%r%%c!) do for %%s in (!block%%r%%c!) do (
                    for %%y in (!block%%sRow!) do for %%x in (!block%%sCol!) do if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
                    for %%y in (!eliminateRow%%s!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
                    for %%x in (!eliminateCol%%s!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
                    set "possibilities%%r%%c=%%e"
                )
            )
        )
    )
)
if "%solvedCells%" == "%cellEmptyNum%" goto :EOF
if not "%sudokuErrorNum%" == "0" goto :EOF
if not "%solvedCells%" == "%solvedCellsNow%" goto solveLoop
goto :EOF
rem Check for pairs
rem Pairs
rem 2 Candidates unique in row / col / block
rem Triples
rem 3 Candidates found on 3 cells


for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do for /l %%x in (1,1,%sudokuSize%) do if not "%%c" == "%%x" (
        if "!possibilities%%r%%c!" == "!possibilities%%r%%x!" (
            if not "%2" == "" call :%2 %1 2p !possibilities%%r%%x! %%r%%c %%r%%x
            call :possibilitiesEliminate %1 %%r %%c !%1%%r%%c!
            rem Eliminate the rest in row
        )
    )
)
for /l %%c in (1,1,%sudokuSize%) do (
    for %%r in (%rowCode%) do for %%y in (%rowCode%) do if not "%%r" == "%%y" (
        if "!possibilities%%r%%c!" == "!possibilities%%y%%c!" (
            if not "%2" == "" call :%2 %1 2p !possibilities%%r%%x! %%r%%c %%y%%c
        )
    )
)
for /l %%b in (1,1,%sudokuSize%) do (
    for %%r in (!block%%bRow!) do for %%c in (!block%%bCol!) do (
        for %%y in (!block%%bRow!) do for %%x in (!block%%bCol!) do (
            if "%%r%%c" == "%%y%%x" if "!possibilities%%r%%c!" == "!possibilities%%y%%x!" (
                if not "%2" == "" call :%2 %1 2p !possibilities%%r%%x! %%r%%c %%y%%c
            )
        )
    )
)
if "%solvedCells%" == "%cellEmptyNum%" goto :EOF
if not "%sudokuErrorNum%" == "0" goto :EOF
if not "%solvedCells%" == "%solvedCellsNow%" goto solveLoop
goto :EOF

:possibilitiesEliminate [Matrix] [Row] [Col] [Num]
for %%e in () do for %%s in (!block%%r%%c!) do (
    for %%y in (!block%%sRow!) do for %%x in (!block%%sCol!) do if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
    for %%y in (!eliminateRow%%s!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
    for %%x in (!eliminateCol%%s!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
    set "possibilities%%r%%c=%%e"
)
goto :EOF
:showPossibilities
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if "!%1%%r%%c!" == " " (
        set "possibilities%%r%%c=%allNumList%"
    ) else set "possibilities%%r%%c=!%1%%r%%c!"
)
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do if not "!%1%%r%%c!" == " " for %%b in (!block%%r%%c!) do for %%e in (!%1%%r%%c!) do (
        for %%y in (!block%%bRow!) do for %%x in (!block%%bCol!) do (
            if defined possibilities%%y%%x set "possibilities%%y%%x=!possibilities%%y%%x:%%e=!
        )
        for %%y in (!eliminateRow%%b!) do if defined possibilities%%y%%c set "possibilities%%y%%c=!possibilities%%y%%c:%%e=!
        for %%x in (!eliminateCol%%b!) do if defined possibilities%%r%%x set "possibilities%%r%%x=!possibilities%%r%%x:%%e=!
        set "possibilities%%r%%c=%%e"
    )
)
goto :EOF

:possibilitiesStats
for /l %%n in (1,1,%sudokuSize%) do set "possibilities%%n=0"
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do (
        for /l %%n in (%sudokuSize%,-1,0) do if "!possibilities%%r%%c:~%%n,1!" == "" set "tempVar1=%%n"
        set /a possibilities!tempVar1!+=1
    )
)
goto :EOF

:checkValidMatrix [Type] [MatrixName]
call :checkDuplicate %2
set /a tempVar1=%sudokuArea% - %sudokuArea%*20/100
if %cellEmptyNum% GEQ %tempVar1% set /a sudokuErrorNum+=1
rem Detect too few givens for each number is missing...
if /i "%1" == "A" if not "%cellEmptyNum%" == "0" set /a sudokuErrorNum+=1
goto :EOF

:checkValidArray
set "return=0"
for %%c in (0 . _) do set "%1=!%1:%%c= !"
set "tempVar1=!%1: =0!"
for /l %%c in (1,1,%sudokuSize%) do set "tempVar1=!tempVar1:%%c=0!"
set "tempVar2="
for /l %%n in (1,1,%sudokuArea%) do set "tempVar2=!tempVar2!0"
if "%tempVar1%" == "%tempVar2%" goto :EOF
set "return=1"
goto :EOF

:matrix
set "return=0"
if /i "%1" == "create"  (
    set "tempVar1=!%3!"
    for %%c in (0 . _) do set "tempVar1=!tempVar1:%%c= !"
)
if /i "%1" == "toArray" set "%3="
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do (
        if /i "%1" == "create" (
            set "%2%%r%%c=!tempVar1:~0,1!"
            set "tempVar1=!tempVar1:~1!"
        )
        if /i "%1" == "copy"    set "%3%%r%%c=!%2%%r%%c!"
        if /i "%1" == "clear"   set "%2%%r%%c= "
        if /i "%1" == "delete"  set "%2%%r%%c="
        if /i "%1" == "toArray" set "%3=!%3!!%2%%r%%c!"
        if /i "%1" == "find" (
            if "!%3%%r%%c!" == "%2" set /a return+=1
            if "!%3%%r%%c!%2" == " 0" set /a return+=1
        )
        if /i "%1" == "switch" for %%n in (!%4%%r%%c!) do (
            if "%%n" == "%2" set "%4%%r%%c=%3"
            if "%%n" == "%3" set "%4%%r%%c=%2"
        )
        if /i "%1" == "compare" if not "!%2%%r%%c!" == "!%3%%r%%c!" (
            if not "!%2%%r%%c!" == " " set /a return+=1
        )
    )
)
if /i "%1,%2" == "find,0" set "cellEmptyNum=%return%"
goto :EOF

:array
set "return=0"
set /a tempVar1=%sudokuArea%-1
for /l %%n in (0,1,%tempVar1%) do (
    if /i "%1" == "compare" if not "!%2:~%%n,1!" == "!%3:~%%n,1!" (
        if not "!%2:~%%n,1!" == " " set /a return+=1
    )
)
goto :EOF

:cellMove
for /l %%n in (1,1,%sudokuSize%) do if "!alphabetList:~%%n,1!" == "%cellCode:~0,1%" set /a cellCodeNum=%%n * %sudokuSize% + %cellCode:~1% - %sudokuSize%
set /a tempVar1=%cellCodeNum% %% %sudokuSize%
if /i "%1%tempVar1%" == "L1" goto :EOF
if /i "%1%tempVar1%" == "R0" goto :EOF
if /i "%1" == "U" set /a cellCodeNum-=%sudokuSize%
if /i "%1" == "L" set /a cellCodeNum-=1
if /i "%1" == "D" set /a cellCodeNum+=%sudokuSize%
if /i "%1" == "R" set /a cellCodeNum+=1
if /i "%1" == "N" set /a cellCodeNum+=1
if /i "%1" == "P" set /a cellCodeNum-=1
if %cellCodeNum% LSS 1 goto :EOF
if %cellCodeNum% GTR %sudokuArea% goto :EOF
set /a cellCode=%cellCodeNum% %% %sudokuSize%
if "%cellCode%" == "0" set "cellCode=%sudokuSize%"
set /a cellCodeNum+= %sudokuSize% - 1
set /a cellCodeNum/=%sudokuSize%
for /l %%n in (1,1,%sudokuSize%) do if "%%n" == "%cellCodeNum%" set "cellCode=!alphabetList:~%%n,1!%cellCode%"
goto :EOF

:cellRandom [Matrix] [Empty]
set /a cellCode=(%random% %% %sudokuSize% + 1) * 10 + %random% %% %sudokuSize% + 1
set "cellCode=!alphabetList:~%cellCode:~0,1%,1!%cellCode:~1%"
if /i "%2" == "Y" if not "!%1%cellCode%!" == " " goto cellRandom
if /i "%2" == "N" if "!%1%cellCode%!" == " " goto cellRandom
goto :EOF

:actionReset
set "actionNum=0"
set "actionLog=0000"
goto :EOF
:actionMark [matrixName] [cellCode] [number]
set "actionLog=!actionLog!%2!%1%2!%3"
set "%1%2=%3"
if "%3" == "0" set "%1%2= "
set /a actionNum+=1
goto :EOF
:actionUndo [matrixName]
if "%actionNum%" == "0" goto :EOF
set "%1%actionLog:~-4,2%=%actionLog:~-2,1%"
set "actionLog=%actionLog:~0,-4%"
set /a actionNum-=1
goto :EOF

:boardTextClear
for /l %%n in (1,1,20) do set "boardText%%n="
goto :EOF

:sudokuInfo
call :matrix find 0 %1
set /a cellGivenNum= %sudokuArea% - %cellEmptyNum%
call :boardTextClear
call :matrix copy %1 sudokuRateMatrix
call :solveSudoku sudokuRateMatrix
set "sudokuLevel=1"
if not "%solvedCells%" == "%cellEmptyNum%" set "sudokuLevel=2"
if not "%sudokuErrorNum%" == "0" set "sudokuLevel=E"
rem              1234567890123456789012345678901234567"
set  "boardText1=Sudoku Puzzle Informations"
set  "boardText3=Name           : %sudokuName:~0,20%"
set  "boardText4=                 %sudokuName:~20%"
set  "boardText5=Givens         : %cellGivenNum%"
set  "boardText6=Level          : %sudokuLevel%"
goto :EOF

:logUpdate
call :boardTextClear
set  "boardText1=ษออออออออLOGSออออออออป"
set "tempVar1=%actionLog:~-40,40%"
for /l %%n in (2,1,11) do (
    if not "!tempVar1:~-4,4!" == "0000" (
        set  "boardText%%n=บ  [!tempVar1:~-4,2!]  '!tempVar1:~-2,1!' to '!tempVar1:~-1,1!'  บ"
        set "tempVar1=!tempVar1:~0,-4!"
    ) else set  "boardText%%n=บ                    บ"
)
set "boardText12=สออออออออออออออออออออผ"
goto :EOF

:sudokuBoard
echo %boardDisplay1%   %boardText1%
set "display=%boardDisplay2%"
set "tempVar2=2"
for /l %%s in (1,1,%sudokuSize%) do (
    set "tempVar1=!alphabetList:~%%s,1!"
    for %%r in (!tempVar1!) do (
        for %%b in (!tempVar2!) do echo !display!   !boardText%%b!
        set /a tempVar2+=1
        set "display=%%r บ"
        set "colNum=1"
        for /l %%h in (1,1,%sudokuBlockHeight%) do (
            for /l %%w in (1,1,%sudokuBlockWidth%) do (
                for %%c in (!colNum!) do set "display=!display! !%1%%r%%c! ณ"
                set /a colNum+=1
            )
            set "display=!display:~0,-1!บ"
        )
        for %%b in (!tempVar2!) do echo !display:~0,-1!บ   !boardText%%b!
        set /a tempVar2+=1
        set /a tempVar1=%%s %% %sudokuBlockHeight%
        if "!tempVar1!" == "0" (
            set "display=%boardDisplay4%"
        ) else set "display=%boardDisplay3%"
    )
)
echo %boardDisplay5%   !boardText%tempVar2%!
goto :EOF

:sudokuBoardMini
if "%sudokuBlockWidth%x%sudokuBlockHeight%" == "3x2" goto sudokuBoardMini_3x2
echo    1 2 3 4 5 6 7 8 9    %boardText1%
echo   ษอออออหอออออหอออออป   %boardText2%
echo A บ!%1A1!ณ!%1A2!ณ!%1A3!บ!%1A4!ณ!%1A5!ณ!%1A6!บ!%1A7!ณ!%1A8!ณ!%1A9!บ   %boardText3%
echo B บ!%1B1!ณ!%1B2!ณ!%1B3!บ!%1B4!ณ!%1B5!ณ!%1B6!บ!%1B7!ณ!%1B8!ณ!%1B9!บ   %boardText4%
echo C บ!%1C1!ณ!%1C2!ณ!%1C3!บ!%1C4!ณ!%1C5!ณ!%1C6!บ!%1C7!ณ!%1C8!ณ!%1C9!บ   %boardText5%
echo   ฬอออออฮอออออฮอออออน   %boardText6%
echo D บ!%1D1!ณ!%1D2!ณ!%1D3!บ!%1D4!ณ!%1D5!ณ!%1D6!บ!%1D7!ณ!%1D8!ณ!%1D9!บ   %boardText7%
echo E บ!%1E1!ณ!%1E2!ณ!%1E3!บ!%1E4!ณ!%1E5!ณ!%1E6!บ!%1E7!ณ!%1E8!ณ!%1E9!บ   %boardText8%
echo F บ!%1F1!ณ!%1F2!ณ!%1F3!บ!%1F4!ณ!%1F5!ณ!%1F6!บ!%1F7!ณ!%1F8!ณ!%1F9!บ   %boardText9%
echo   ฬอออออฮอออออฮอออออน   %boardText10%
echo G บ!%1G1!ณ!%1G2!ณ!%1G3!บ!%1G4!ณ!%1G5!ณ!%1G6!บ!%1G7!ณ!%1G8!ณ!%1G9!บ   %boardText11%
echo H บ!%1H1!ณ!%1H2!ณ!%1H3!บ!%1H4!ณ!%1H5!ณ!%1H6!บ!%1H7!ณ!%1H8!ณ!%1H9!บ   %boardText12%
echo I บ!%1I1!ณ!%1I2!ณ!%1I3!บ!%1I4!ณ!%1I5!ณ!%1I6!บ!%1I7!ณ!%1I8!ณ!%1I9!บ   %boardText13%
echo   ศอออออสอออออสอออออผ   %boardText14%
goto :EOF

:sudokuBoardMini_3x2
echo    1 2 3 4 5 6    %boardText1%
echo   ษอออออหอออออป   %boardText2%
echo A บ!%1A1!ณ!%1A2!ณ!%1A3!บ!%1A4!ณ!%1A5!ณ!%1A6!บ   %boardText3%
echo B บ!%1B1!ณ!%1B2!ณ!%1B3!บ!%1B4!ณ!%1B5!ณ!%1B6!บ   %boardText4%
echo   ฬอออออฮอออออน   %boardText5%
echo C บ!%1C1!ณ!%1C2!ณ!%1C3!บ!%1C4!ณ!%1C5!ณ!%1C6!บ   %boardText6%
echo D บ!%1D1!ณ!%1D2!ณ!%1D3!บ!%1D4!ณ!%1D5!ณ!%1D6!บ   %boardText7%
echo   ฬอออออฮอออออน   %boardText8%
echo E บ!%1E1!ณ!%1E2!ณ!%1E3!บ!%1E4!ณ!%1E5!ณ!%1E6!บ   %boardText9%
echo F บ!%1F1!ณ!%1F2!ณ!%1F3!บ!%1F4!ณ!%1F5!ณ!%1F6!บ   %boardText10%
echo   ศอออออสอออออผ   %boardText14%
goto :EOF

:possibilityBoard
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do (
        set "%1%%r%%c=         !%1%%r%%c!"
        set "%1%%r%%c=!%1%%r%%c:~-%sudokuSize%,%sudokuSize%!"
    )
)
echo        1         2         3         4         5         6         7         8         9 
echo   ษอออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออป
echo A บ!%1A1!ณ!%1A2!ณ!%1A3!บ!%1A4!ณ!%1A5!ณ!%1A6!บ!%1A7!ณ!%1A8!ณ!%1A9!บ
echo B บ!%1B1!ณ!%1B2!ณ!%1B3!บ!%1B4!ณ!%1B5!ณ!%1B6!บ!%1B7!ณ!%1B8!ณ!%1B9!บ
echo C บ!%1C1!ณ!%1C2!ณ!%1C3!บ!%1C4!ณ!%1C5!ณ!%1C6!บ!%1C7!ณ!%1C8!ณ!%1C9!บ
echo   ฬอออออออออออออออออออออออออออออฮอออออออออออออออออออออออออออออฮอออออออออออออออออออออออออออออน
echo D บ!%1D1!ณ!%1D2!ณ!%1D3!บ!%1D4!ณ!%1D5!ณ!%1D6!บ!%1D7!ณ!%1D8!ณ!%1D9!บ
echo E บ!%1E1!ณ!%1E2!ณ!%1E3!บ!%1E4!ณ!%1E5!ณ!%1E6!บ!%1E7!ณ!%1E8!ณ!%1E9!บ
echo F บ!%1F1!ณ!%1F2!ณ!%1F3!บ!%1F4!ณ!%1F5!ณ!%1F6!บ!%1F7!ณ!%1F8!ณ!%1F9!บ
echo   ฬอออออออออออออออออออออออออออออฮอออออออออออออออออออออออออออออฮอออออออออออออออออออออออออออออน
echo G บ!%1G1!ณ!%1G2!ณ!%1G3!บ!%1G4!ณ!%1G5!ณ!%1G6!บ!%1G7!ณ!%1G8!ณ!%1G9!บ
echo H บ!%1H1!ณ!%1H2!ณ!%1H3!บ!%1H4!ณ!%1H5!ณ!%1H6!บ!%1H7!ณ!%1H8!ณ!%1H9!บ
echo I บ!%1I1!ณ!%1I2!ณ!%1I3!บ!%1I4!ณ!%1I5!ณ!%1I6!บ!%1I7!ณ!%1I8!ณ!%1I9!บ
echo   สอออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออสอออออออออออออออออออออออออออออผ
for %%r in (%rowCode%) do (
    for /l %%c in (1,1,%sudokuSize%) do (
        set "%1%%r%%c=.!%1%%r%%c!"
        set "%1%%r%%c=!%1%%r%%c: =!"
        set "%1%%r%%c=!%1%%r%%c:~1!"
    )
)
goto :EOF

:Time_Subtract [Start Time] [End Time] [Setting]
rem 0 - Returns non-adjusted value
rem 1 - Fix if the start time is the end time 
rem Format  : HH:MM:SS.CS
set "return=0"
for %%t in (%2 %1) do (
    for /f "tokens=1-4 delims=:." %%a in ("%%t") do set /a  return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100
    set /a return*=-1
)
if %return% LSS 0 (
    if "%3" == "1" set /a return*=-1
    if not "%3" == "0" set /a return+=8640000
)
goto :EOF

:Time_CS_Format [Time in CS] [Setting]
rem 0 - Returns negative time
rem TempVar: 1-2
set "return="
set /a tempVar1=%1 %% 8640000
if "%3" == "0" if %1 LSS 0 (
    set "return=-"
    set /a tempVar1*=-1
)
for %%n in (360000 6000 100 1) do (
    set /a tempVar2=!tempVar1! / %%n
    set /a tempVar1=!tempVar1! %% %%n
    set "tempVar2=T0!tempVar2!"
    set "return=!return!!tempVar2:~-2,2!:"
)
set "return=%return:~0,-4%.%return:~-3,2%"
goto :EOF


rem ==================== SUDOKU LISTS ====================

:genInfo
cls
set "saveFile=%pathData%\%sudokuBlockWidth%x%sudokuBlockHeight%\Solved.txt"
set "sudokuCount=0"
set "sudokuPuzzleArray="
set "sudokuAnswerArray="
set "sudokuSaveArray="
set "startTime=%time%"
echo= >> %saveFile%
for %%s in (
    ........8....89.....67...4.3...6.7.......4.1.56.2....48.3.....1.54....7.2...359.._25_1_2/8 
    .1...9...2.4.....8...3.............2.4.5....9..5.7416.32..5.......6....5.897..2.._24_1_1/2 
) do for /f "tokens=1-2 delims=_" %%a in ("%%s") do call :genInfo_Solve %%a
call :Time_Subtract %startTime% %time%
call :Time_CS_Format %return%
echo=
echo Solved %sudokuCount% sudoku in %return%
echo=
pause
goto sudokuMenu

:list_Default3x3
set "userInput=?"
cls
echo  1 -  4        Easy
echo  5 -  8        Medium
echo  9 - 12        Hard
echo=
echo 0. Back
echo=
echo Input sudoku number    :
set /p "userInput="
if "!userInput!" == "0" goto :EOF
set "tempVar1=0"
for %%s in (
    9.7...1..2..7........2.......6.5..8..2......4.....8.16.....49574..6.3....7.9.....
    2...6.3..7..4....6.1......2.2......3.638..1..5.4......6..9.28.........1......5.3.
    ...3..9..4......6....42...5........9.5...14782.4..61......3....7..65....6....7.8.
    .......1.4.........2...........5.6.4..8...3....1.9....3..4..2...5.1........8.7...
    
    ........8.3.2........4.5376..1.5..97.8...954....6....2.4.......2....7.396.9......
    .3.29......7.......8.1.32.74....6....2..3......5....8..4.........68..9..5.1.2..6.
    2.....1.5..8.97........3.8..94.....6..5..43.....369.......8..1..4...1.23......6.7
    ......5.6....94.....98.5...3.27......1...2.6.......4.7.8.3.62.5.4...93...........
    
    .1......95......747.....3.....36.....3.....8.4..9..25.9...5......6.97...37.8.4..6
    .......399.485.....75..9......5..6.21...9...7...34.8..8.67.......1...7.3........6
    .......399.485.....75..9......5..6.21...9...7...34.8..8.67.......1...7.3........6
    97..5...2.............18.6.....4..3.45...76.91.6........9...48...718.2......2....
    
) do (
    set /a tempVar1+=1
    if "%userInput%" == "!tempVar1!" for /f "tokens=1 delims=_" %%a in ("%%s") do (
        set "selectedPuzzleArray=%%a"
        set "selectedName=List#%userInput%"
    )
)
if defined selectedPuzzleArray goto :EOF
echo=
echo Invalid choice
pause
goto list_Default3x3

:list_Default3x2
set "userInput=?"
cls
echo  1 -  4        Easy
echo  5 -  8        Hard
echo=
echo 0. Back
echo=
echo Input sudoku number    :
set /p "userInput="
if "%userInput%" == "0" goto :EOF
set "tempVar1=0"
for %%s in (
    040000000006060045030000002000053600
    000200000034300401500002260000405000 
    000013000600041060000002036000004000 
    100000000003200050001020000005034100 
    
    003000050004305200000400600000004003 
    040100005004010035000000056040000000 
    000001500030001000002600320005000000 
    000000050006000103003040060401002000 
    
) do (
    set /a tempVar1+=1
    if "%userInput%" == "!tempVar1!" for /f "tokens=1 delims=_" %%a in ("%%s") do (
        set "selectedPuzzleArray=%%a"
        set "selectedName=List#%userInput%"
    )
)
if defined selectedPuzzleArray goto :EOF
echo=
echo Invalid choice
pause
goto list_Default3x2

:list_Default2x3
echo=
echo List not available...
echo Please use custom sudoku, generate sudoku 
echo or play 3x2 size sudoku (similar to 2x3)
pause
goto :EOF

:list_Default2x2
set "userInput=?"
cls
echo List contains 20 sudoku
echo=
echo 0. Back
echo=
echo Input sudoku number    :
set /p "userInput="
if "%userInput%" == "0" goto :EOF
set "tempVar1=0"
for %%s in (
    3000000110000002 
    0010000240000003 
    0030030001000020 
    0004020000300100 
    0200100000004010 
    0000300200004100 
    0004030000000041 
    0000034010020000 
    4000000020040010 
    0000400000010320 
    0000300000020103 
    0004300010000002 
    1000002000402000 
    0000420001030000 
    0010000200030400 
    0001003000000320 
    0100000200304000 
    2000000200013000 
    0203000400003000 
    0020030000420000 
) do (
    set /a tempVar1+=1
    if "%userInput%" == "!tempVar1!" for /f "tokens=1 delims=_" %%a in ("%%s") do (
        set "selectedPuzzleArray=%%a"
        set "selectedName=List#%userInput%"
    )
)
if defined selectedPuzzleArray goto :EOF
echo=
echo Invalid choice
pause
goto list_Default2x2

