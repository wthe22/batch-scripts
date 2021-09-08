

@goto main

rem Sudoku v3.0 by wthe22
rem Updated on 2016-08-19
rem Visit http://winscr.blogspot.com/ for more scripts!

:main
@echo off
prompt $s
endlocal 
setlocal EnableDelayedExpansion

rem ======================================== Settings ========================================
set "dataPath=%~dp0\Data\Sudoku\"

set "defaultScreenWidth=80"
set "defaultScreenHeight=25"

set "gridStyle=ASCII" [ASCII or UTF8]
set "useColor=true"  [TRUE or FALSE]

rem See "COLOR /?" for more info
set "defaultColor=07"
set "puzzleColor=0F"
set "solvingsColor=0A"
set "newSolvedColor=3A"
set "candidateColor=0D"
set "errorColor=0C"

set "solutionCountLimit=5"

rem ======================================== One-time Setups ========================================

set "scriptVersion=v3.0"

title Sudoku !scriptVersion!
mode !defaultScreenWidth!,!defaultScreenHeight!
cls
call :splashScreen

if not exist "!dataPath!" md "!dataPath!"
cd /d "!dataPath!"

set "tempPath=!temp!\BatchScript\"
set "puzzlePath=Puzzles\"
set   "savePath=Saves\"
for %%p in (
    tempPath
    puzzlePath
    savePath
) do if not exist "!%%p!" md "!%%p!"

rem Capture backspace character
for /f %%a in ('"prompt $h & echo on & for %%b in (1) do rem"') do (
    set "BS=%%a %%a"
)

rem Capture Carriage Return character
for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"

rem Base for "SET /P" display because it cannot start with a white space
set "base=_!BS!"

rem Setup Clear Line
set "clearLine="
for /l %%n in (2,1,!defaultScreenWidth!) do set "clearLine=!clearLine! "
set "clearLine=!BASE!!CR!!clearLine!!CR!"

color !defaultColor!

set "alphabets=.ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "currentGridStyle=?"
set "screenWidth=!defaultScreenWidth!"
set "screenHeight=!defaultScreenHeight!"
set "stateCount=0"
set "alwaysGenerate=false"

set "blockWidth=0"
set "blockHeight=0"
set "sideLength=0"
call :setupBlocks 0x0

call :speedtest

:mainMenu
set "userInput=?"
mode !defaultScreenWidth!,!defaultScreenHeight!
title Sudoku !scriptVersion!
cls
echo 1. Play sudoku
echo 2. Import sudoku
echo 3. View sudoku
echo 4. Solve sudoku
echo 5. Generate sudoku
echo=
echo A. About script
echo S. Settings
echo 0. Exit
echo=
echo What do you want to do?
set /p "userInput="
if "!userInput!" == "0" goto cleanUp
if "!userInput!" == "1" goto play_setup
if "!userInput!" == "2" goto import_setup
if "!userInput!" == "3" goto viewer_setup
if "!userInput!" == "4" goto solver_setup
if "!userInput!" == "5" goto generator_setup
if /i "!userInput:~0,1!" == "A" goto aboutScript
if /i "!userInput:~0,1!" == "S" goto settings_menu
goto mainMenu


:aboutScript
cls
call :splashScreen
pause > nul
goto mainMenu

rem ======================================== Settings ========================================

:settings_menu
set "userInput=?"
cls
echo=
echo 1. Grid style          !gridStyle!
echo 2. Use Color           !useColor!
echo=
echo R. Restart script      A fresh start is always good
echo 0. Back
echo=
echo What do you want to change?
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if "!userInput!" == "1" goto settings_gridStyle
if "!userInput!" == "2" call :toggleColor
if /i "!userInput!" == "G" call :toggleGenerate
if /i "!userInput!" == "D" goto settings_debugInfo
if /i "!userInput!" == "R" goto main
goto settings_menu


:settings_gridStyle
set "userInput=?"
set "selectedStyle="
cls
echo Current grid style : !gridStyle!
echo=
echo 1. ASCII           Better GUI
echo 2. UTF8            Display correctly in most computers
echo=
echo 0. Back
echo=
echo Input style number:
set /p "userInput="
if "!userInput!" == "0" goto settings_menu
if "!userInput!" == "1" set "selectedStyle=ASCII"
if "!userInput!" == "2" set "selectedStyle=UTF8"
if not defined selectedStyle goto settings_gridStyle
set "gridStyle=!selectedStyle!"
goto settings_menu


:settings_debugInfo
call :countVariables
cls
echo Debug Informations
echo=
echo Variables          : !return!
echo Loop Speed         : !loopSpeed!
echo Always generate    : !alwaysGenerate!
echo=
pause
goto settings_menu


:toggleColor
if "!useColor!" == "true" (
    set "useColor=false"
) else set "useColor=true"
goto :EOF


:toggleGenerate
if "!alwaysGenerate!" == "true" (
    set "alwaysGenerate=false"
) else set "alwaysGenerate=true"
goto :EOF


:error_unexpected
echo=
echo An unexpected error happened.
echo=
echo Press any key to exit or continue with modifications
pause > nul
exit


:error_expected
echo=
echo The feature you used have not been completed yet...
echo=
echo Press any key to exit or continue with modifications.
pause > nul
exit


:cleanUp
pushd "!tempPath!"
del /f /q "*" > nul 2> nul
popd
exit

rem ======================================== Play Sudoku ========================================

:play_setup
call :selectSudoku /c
if not defined selected_puzzleArray goto mainMenu

call :matrix create selected_puzzle selected_puzzleArray
call :matrix create selected_solvings selected_puzzleArray

call :state reset selected_solvings
call :action reset selected_solvings

if defined selected_solvingsArray (
    call :state save
    set "state!stateCount!_array=!selected_solvingsArray!"
)

set "sideText="
call :action updateLog

set "startTime=!time!"

:play_updateColor
call :matrix set GUI_color !solvingsColor!
call :matrix color selected_puzzle !puzzleColor!

:play_sudoku
set "sideText="
call :action updateLog
set "sideText=!sideText![Z] Undo\n[X] Exit\n[C] Check\n[T] Toggle Color\n"
set "sideText=!sideText![S] Save\n[L] Load [!stateCount!]\n[H] Hint\n"
call :parseSideText
set "userInput=?"

cls
call :displaySudoku selected_solvings
set /p "userInput=Input cell code   : "
if /i "!userInput!" == "Z" call :action undo        & goto play_updateColor
if /i "!userInput!" == "X" goto play_quit
if /i "!userInput!" == "C" goto play_checkSolvings
if /i "!userInput!" == "T" call :toggleColor
if /i "!userInput!" == "S" call :state save
if /i "!userInput!" == "L" call :state load         & goto play_updateColor
if /i "!userInput!" == "H" call :play_hint
call :checkCellcode !userInput!
if defined cellPos goto play_fillCell
goto play_sudoku


:play_fillCell
if not "!selected_puzzle_%cellPos%!" == " " goto play_warnPuzzleCell
set "userInput=?"
set /p "userInput=Input number      : "
if /i "!userInput!" == "X" goto play_sudoku
call :action mark !cellPos! !userInput!
goto play_updateColor


:play_warnPuzzleCell
echo That cell is a part of the puzzle...
pause > nul
goto play_sudoku


:play_checkSolvings
call :matrix set GUI_color !solvingsColor!
call :checkDuplicate selected_solvings
call :matrix color selected_puzzle !puzzleColor!
call :matrix count selected_solvings " "
set "emptyCells=!return!"

if "!emptyCells!" == "0" (
    if "!duplicatesFound!" == "0" (
        goto play_solved
    ) else echo Oops^^! There is something wrong...
) else (
    if "!duplicatesFound!" == "0" (
        echo Seems good, Continue solving^^!
    ) else echo Oops^^! There is something wrong...
)
pause > nul
goto play_sudoku


:play_hint
call :matrix copy selected_solvings temp1
call :solveSudoku temp1 /o
if "!solveMethod!" == "Unsolvable" (
    echo No hint available. Sudoku is too hard for solver
) else echo Try looking for !solveMethod!
pause > nul
goto play_sudoku


:play_solved
call :difftime !time! !startTime!
call :ftime !return!
set "sideText=\nSolved in !return!"
call :parseSideText
call :matrix toArray selected_solvings lastUsed_answerArray

cls
call :displaySudoku selected_solvings
echo Congratulations^^! You solved the puzzle.
pause
goto mainMenu


:play_quit
call :matrix toArray selected_solvings lastUsed_solvingsArray
call :state reset
echo Solvings saved to memory. You can load it later.
rem ? Save to file?
pause > nul
goto mainMenu

rem ================================================== Import Sudoku ==================================================

:import_setup
set "selected_puzzleArray="
set "selected_answerArray="
set "selected_solvingsArray="

:import_sizeIn
cls
echo 0. Back
echo=
echo Block size from 2x2 (4x4) to 4x4 (16x16)
echo=
echo Input sudoku block size  :
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
call :checkBlockSize !userInput!
if "!sizeIsValid!" == "false" goto import_sizeIn


call :setupBlocks !userInput!
call :setupGrid

call :inputSudoku puzzle
if "!userInput!" == "0" goto import_sizeIn
call :inputSudoku answer
if "!userInput!" == "0" goto import_sizeIn

rem Input successful
set "lastUsed_file=Imported"
set "lastUsed_name=Imported !blockWidth!x!blockHeight!"
set "lastUsed_size=!blockWidth!x!blockHeight!"
cls
call :save2File /p
goto mainMenu


:inputSudoku
set "selected_%1Array="
set "skippable=false"
if "%1" == "answer" set "skippable=true"

:inputMenu
set "userInput=?"
cls
echo 1. One by one with GUI
echo 2. Array form
if /i "!skippable!" == "true" echo 3. Skip this step
echo=
echo 0. Back
echo=
echo Choose %1 input method :
set /p "userInput="
if "!userInput!" == "0" goto :EOF
if "!userInput!" == "1" goto inputGUI_Setup
if "!userInput!" == "2" goto inputArray
if /i "!skippable!" == "true" if "!userInput!" == "3" goto :EOF
goto inputMenu


:inputGUI_Setup
call :action reset selected_%1
call :matrix set selected_%1 " "
call :matrix set GUI_color !puzzleColor!
set "cellPos=1-1"
set "duplicatesFound=0"
set "cellGivens=0"
set "inputSymbols=0!symbolList!"
call :inputGUI_updateText

:inputGUI
call :inputGUI_markCurrent %1
call :parseSideText
cls
call :displaySudoku selected_%1
call :inputGUI_restoreCurrent %1
choice /c ZXHIJKLT0!symbolList! /n /m "Input number   : "
set "userInput=!errorlevel!"
if "!userInput!" == "1" call :action undo
if "!userInput!" == "2" goto inputMenu
if "!userInput!" == "3" goto inputGUI_check
if "!userInput!" == "4" call :move up
if "!userInput!" == "5" call :move left
if "!userInput!" == "6" call :move down
if "!userInput!" == "7" call :move right
if "!userInput!" == "8" call :toggleColor
if !userInput! LSS 9 goto inputGUI
set /a "userInput=!errorlevel! - 9"
set "userInput=!inputSymbols:~%userInput%,1!"
call :action mark !cellPos! !userInput!
call :matrix set GUI_color !puzzleColor!
call :checkDuplicate selected_%1
call :matrix count selected_%1 " "
set /a "cellGivens=!totalCells! - !return!"
call :inputGUI_updateText
call :move next
goto inputGUI


:inputGUI_updateText
set "sideText="
set "sideText=!sideText!Duplicates  : !duplicatesFound!\n"
set "sideText=!sideText!Givens      : !cellGivens!\n\n"
set "sideText=!sideText![Z] Undo\n[X] Exit\n[H] Check / Done\n"
set "sideText=!sideText![T] Toggle Color\n[0] Erase\n\nUse IJKL to move\n\n"
set "sideText=!sideText!Characters:\n!symbolList!\n"
goto :EOF


:inputGUI_markCurrent
set "cell_value=!selected_%1_%cellPos%!"
set "cell_color=!GUI_color_%cellPos%!"
set "GUI_color_!cellPos!=!solvingsColor!"
set "selected_%1_!cellPos!=X"
goto :EOF


:inputGUI_restoreCurrent
set "selected_%1_!cellPos!=!cell_value!"
set "GUI_color_!cellPos!=!cell_color!"
goto :EOF


:inputGUI_check
call :matrix toArray selected_%1 selected_%1Array
if "!duplicatesFound!" == "0" (
    if /i "%1" == "answer" (
        if "!cellGivens!" == "!totalCells!" (
            goto import_done
        ) else echo There are still !return! empty cells...
    ) else if !cellGivens! GEQ !minimumGivens! (
        goto import_done
    ) else echo Too few givens for a valid sudoku
) else echo Duplicates found. Use color to see the duplicates.
pause > nul
goto inputGUI


:inputArray
set "userInput=?"
cls
echo 1. Input from left to right (A1 to A!sideLength!)
echo 2. Go to first column of next line (Go to B1)
echo 3. Repeat until done
echo=
echo Use dot, space, underscore, zero or 
echo question mark to represent empty cell
echo=
echo Array example (2x2) :
echo ...42....1..4..1
echo=
echo 0. Back
echo=
echo Input the !blockWidth!x!blockHeight! puzzle array : 
set /p "userInput="
if "!userInput!" == "0" goto inputMenu
set "selected_%1Array=!userInput!"
set "errorMsg="
call :checkArray selected_puzzleArray
if "!arrayIsValid!" == "true" goto inputArray_display
echo=
echo ERROR: !errorMsg!
echo=
pause
goto inputArray


:inputArray_display
set "sideText="
call :parseSideText
call :matrix create selected_%1 selected_%1Array
cls
call :displaySudoku selected_%1
call :matrix delete selected_%1
if not defined errorMsg goto import_done
echo ERROR: !errorMsg!
pause > nul
goto inputArray


:import_done
set "lastUsed_%1Array=!selected_%1Array!"
echo Input successful
pause > nul
goto :EOF

rem ================================================== View Sudoku ==================================================

:viewer_setup
call :selectSudoku
if not defined selected_puzzleArray goto mainMenu

call :matrix create selected_puzzle selected_puzzleArray
if defined selected_answerArray call :matrix create selected_answer selected_answerArray
if defined selected_solvingsArray call :matrix create selected_solvings selected_solvingsArray

call :matrix set GUI_color !solvingsColor!
call :matrix color selected_puzzle !puzzleColor!

set "sideText="
call :sudokuInfo selected_puzzle
set "sideText=!sideText!\n[C] Copy array\n\n"
set "sideText=!sideText!Press enter to exit\n"
call :parseSideText

:viewer_menu
set "userInput=?"
cls
echo 1. Puzzle
if defined selected_answerArray echo 2. Answer
if defined selected_solvingsArray echo 3. Solvings
echo=
echo A. View all in array form
echo 0. Back
echo=
echo Which one do you want to view?
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if "!userInput!" == "1" call :viewMatrix selected_puzzle
if "!userInput!" == "2" call :viewMatrix selected_answer
if "!userInput!" == "3" call :viewMatrix selected_solvings
if /i "!userInput!" == "A" call :viewArray
goto viewer_menu


:viewMatrix [Matix_Name]
if not defined %1Array goto :EOF 
set "userInput=?"
cls
call :displaySudoku %1
set /p "userInput=> "
if /i "!userInput!" == "C" (
    set /p "=!%1Array: =0!" < nul | clip
    echo Copied array to clipboard
    pause > nul
)
goto :EOF


:viewArray
cls
echo Puzzle array:
echo !selected_puzzleArray: =0!
echo=
if defined selected_answerArray(
        echo Answer array:
        echo !selected_answerArray: =0!
        echo=
)
if defined selected_solvingsArray(
        echo Solvings array:
        echo !selected_solvingsArray: =0!
        echo=
)
pause
goto :EOF

rem ================================================== Solve Sudoku ==================================================

:solver_setup
call :selectSudoku /c
if not defined selected_puzzleArray goto mainMenu

call :matrix create selected_solvings selected_puzzleArray
call :matrix set GUI_color !solvingsColor!
call :matrix color selected_solvings !puzzleColor!

set "sideText="
call :sudokuInfo selected_solvings
call :parseSideText

if not defined selected_solvingsArray goto solver_showStepsIn


rem Load saved solvings
call :matrix create selected_solvings selected_solvingsArray
call :matrix count selected_solvings " " 
set /a "tempVar1= !totalCells! - !return! - !cellGivens!"
set "sideText=!sideText!Solved  : !tempVar1!\n"
call :parseSideText

:solver_savesIn
set "userInput=?"
cls
call :displaySudoku selected_solvings
echo Solvings data found
set /p "userInput=Do you want to load this solvings? Y/N?"
if /i "!userInput!" == "Y" goto solver_showStepsIn
if /i not "!userInput!" == "N" goto solver_savesIn

call :matrix create selected_solvings selected_puzzleArray
set "sideText="
call :sudokuInfo selected_solvings
call :parseSideText


:solver_showStepsIn
set "userInput=?"
cls
echo Show solvings steps? Y/N?
set /p "userInput="
if /i "!userInput!" == "Y" goto solver_showStepsSetup
if /i "!userInput!" == "N" goto solver_startSolve
goto solver_showStepsIn


:solver_startSolve
cls
call :displaySudoku selected_solvings
echo Press any key to start solving...
pause > nul
echo Solving sudoku...
set "startTime=!time!"
call :solveSudoku selected_solvings
if not "!emptyCells!" == "0" goto solver_cannotSolve

call :difftime !time! !startTime!
call :ftime !return!
set "timeTaken=!return!"
call :matrix toArray selected_solvings lastUsed_answerArray
cls
call :displaySudoku selected_solvings
echo Solve done in !timeTaken!
pause > nul
goto solver_quit


:solver_showStepsSetup
mode !showStep_width!,!showStep_height!
set "sideText="
call :parseSideText

call :matrix set GUI_color !candidateColor!
call :matrix color selected_solvings !puzzleColor!


:solver_showSteps
call :setupCandidates selected_solvings
call :matrix copy candidateList candidateList_old
call :solveSudoku selected_solvings /o

rem Convert cell code and color cells
set "solvedCells_converted="
for %%c in (!solvedCells!) do for /f "tokens=1-2 delims=-" %%x in ("%%c") do (
    set "solvedCells_converted=!solvedCells_converted! !alphabets:~%%x,1!%%y"
    set "GUI_color_%%c=!newSolvedColor!"
)

cls
call :displaySudoku selected_solvings /n
echo=
call :displayCandidates candidateList_old
echo [!solveMethod!] !solvedCells_converted!
pause > nul

for %%c in (!solvedCells!) do set "GUI_color_%%c=!solvingsColor!"
call :matrix delete candidateList_old

if not "!solveMethod!" == "Unsolvable" (
    if not "!emptyCells!" == "0" goto solver_showSteps
) else goto solver_cannotSolve

mode !screenWidth!,!screenHeight!
call :matrix toArray selected_solvings lastUsed_answerArray
cls
call :displaySudoku selected_solvings
echo Solve done
pause > nul
goto solver_quit


:solver_cannotSolve
call :matrix count selected_solvings " " 
set /a "tempVar1= !totalCells! - !return! - !cellGivens!"
set "sideText=!sideText!Solved  : !tempVar1!\n"
call :parseSideText

call :matrix toArray selected_solvings lastUsed_solvingsArray
mode !screenWidth!,!screenHeight!

:solver_bruteforcePrompt
set "userInput=?"
cls
call :displaySudoku selected_solvings
echo This sudoku is either too hard or it is invalid.
set /p "userInput=Use bruteforce? Y/N? "
if /i "!userInput!" == "Y" goto solver_solutionCountIn
if /i "!userInput!" == "N" goto solver_quit
goto solver_bruteforcePrompt


:solver_solutionCountIn
set "countSolutions="
set /p "userInput=Count number of solutions? Y/N? "
if /i "!userInput!" == "Y" set "countSolutions=true"
if /i "!userInput!" == "N" set "countSolutions=false"
if not defined countSolutions goto solver_solutionCountIn


:solver_startBruteforce
call :matrix create selected_solvings selected_puzzleArray
cls
call :displaySudoku selected_solvings
call :matrix delete GUI_color
echo Press any key to start solving...
pause > nul

set "startTime=!time!"

if /i "!countSolutions!" == "true" (
    call :bruteforceSudoku selected_solvings /sc
) else call :bruteforceSudoku selected_solvings

call :difftime !time! !startTime!
call :ftime !return!
set "timeTaken=!return!"

set "lastUsed_answerArray=!solution1!"

call :matrix create selected_puzzle selected_puzzleArray
call :matrix set GUI_color !solvingsColor!
call :matrix color selected_puzzle !puzzleColor!
call :matrix delete selected_puzzle

cls
call :displaySudoku selected_solvings
echo Done in !return! with !bruteforceCount! guesses
if "!solutionCount!" == "!solutionCountLimit!" (
    echo Found at least !solutionCount! solutions
) else echo Found !solutionCount! solutions
pause > nul
goto solver_quit

:solver_quit
call :matrix delete selected_solvings
call :matrix delete GUI_color
rem ? Save to file?
goto mainMenu

rem ================================================== Generate Sudoku ==================================================

:generator_setup

:generator_sizeIn
cls
echo 0. Back
echo=
echo Block size from 2x2 (4x4) to 4x4 (16x16)
echo=
echo Input sudoku block size  :
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
call :checkBlockSize !userInput!
if "!sizeIsValid!" == "false" goto generator_sizeIn

call :setupBlocks !userInput!

:generate_difficultyIn
cls
echo 1. Easy
echo=
echo R. Random
echo C. Custom
echo 0. Back
echo=
echo Input difficulty level:
set /p "puzzleLvl="
if "!puzzleLvl!" == "0" goto generator_sizeIn
if /i "!puzzleLvl!" == "R" goto generateLvl
if /i "!puzzleLvl!" == "C" goto error_expected
if !puzzleLvl! GEQ 1 if !puzzleLvl! LEQ 1 goto generateLvl_setup
goto generate_difficultyIn


:generateCustom_menu
cls
echo 1. Givens      Minimum [40%+1 ~ 90%]
echo=
echo G. Generate
echo 0. Back
echo=
echo What do you want to customize?
set /p "userInput="
if "!userInput!" == "0" goto generate_difficultyIn
if "!userInput!" == "1" goto generateCustom_givens
goto generateCustom_menu


:generateLvl_setup
set "estTime="
if /i "!puzzleLvl!" == "R" goto generateRand
goto generateLvl!puzzleLvl!
goto error_unexpected


:generateRand
set "methodsUsed=bf"
set "puzzleLvl=Random"
if "!sideLength!" == "4"    set "estTime=160 240"
if "!sideLength!" == "6"    set "estTime=776 1363"
if "!sideLength!" == "9"    set "estTime=4513 16385"
goto generate_setup

:generateLvl1
set "methodsUsed=2"
set "puzzleLvl=Easy"
if "!sideLength!" == "4"    set "estTime=98 145"
if "!sideLength!" == "6"    set "estTime=478 636"
if "!sideLength!" == "8"    set "estTime=1987 2643"
if "!sideLength!" == "9"    set "estTime=3550 4724"
if "!sideLength!" == "12"   set "estTime=21888 28992"
if "!sideLength!" == "16"   set "estTime=132865 185773"
goto generate_setup


:generate_setup
set "minTime=???"
set "maxTime=???"
for /f "tokens=1,2 delims= " %%a in ("!estTime!") do (
    set /a "minTime=%%a * 1000 / !loopSpeed!"
    call :ftime !minTime!
    set "minTime=!return!"
    
    set /a "maxTime=%%b * 1000 / !loopSpeed!"
    call :ftime !maxTime!
    set "maxTime=!return!"
)

set "selected_name=!puzzleLvl! !blockWidth!x!blockHeight!"
set "lastUsed_file=Generated"
set "lastUsed_name=!selected_name!"
set "lastUsed_size=!blockWidth!x!blockHeight!"


:generate_reset
set "lastUsed_puzzleArray="
set "lastUsed_answerArray="
set "lastUsed_solvingsArray="

:generate_start
cls
echo Sudoku size        : !sideLength!x!sideLength! [!blockWidth!x!blockHeight!]
echo Difficulty level   : !puzzleLvl!
echo Estimated time     : !minTime! - !maxTime!
echo=
echo Press any key to start generating...
if "!alwaysGenerate!" == "false" pause > nul

echo Generating answer...
set "startTime=!time!"
call :generateAnswer selected_puzzle
if "!solutionCount!" == "0" goto generate_badSeed

set /p "=!clearLine!Swapping numbers..." < nul
for /l %%n in (-4,1,!sideLength!) do (
    set /a "tempVar1=!random! %% !sideLength!"
    set /a "tempVar2=!random! %% !sideLength!"
    for %%x in (!tempVar1!) do for %%y in (!tempVar2!) do (
        call :matrix swap selected_puzzle !symbolList:~%%x,1! !symbolList:~%%y,1!
    )
)
call :difftime !time! !startTime!
call :ftime !return!
echo !clearLine!Generate answer done in !return!

call :matrix toArray selected_puzzle lastUsed_answerArray

echo Generating puzzle...
set "startTime2=!time!"

call :randCellList selected_puzzle /f

set "progressCount=0"
for %%c in (!cellList!) do (
    set /a "progressCount+=1"
    title Sudoku !scriptVersion! - Generating puzzle... #!progressCount!/!totalCells!
    
    call :matrix copy selected_puzzle selected_solvings
    set "selected_solvings_%%c= "
    
    if /i "!methodsUsed!" == "BF" (
        call :bruteforceSudoku selected_solvings /c
        if "!solutionCount!" == "1" set "selected_puzzle_%%c= "
    ) else (
        set /p "=!clearLine!Progress: !progressCount!/!totalCells!" < nul
        call :solveSudoku selected_solvings !methodsUsed!
        if "!emptyCells!" == "0" set "selected_puzzle_%%c= "
    )
)

call :difftime !time! !startTime2!
call :ftime !return!
echo !clearLine!Generate puzzle done in !return!

echo Doing some cleanup...
title Sudoku !scriptVersion!
call :matrix delete candidateList
call :matrix delete selected_solvings
call :matrix toArray selected_puzzle lastUsed_puzzleArray

if "!alwaysGenerate!" == "true" goto generateMore

call :difftime !time! !startTime!
call :ftime !return!
set "timeTaken=!return!"
echo=
echo Total time taken : !timeTaken!
echo=
pause 

call :setupGrid
call :matrix set GUI_color !puzzleColor!

set "sideText="
call :sudokuInfo selected_puzzle
call :parseSideText

cls
call :displaySudoku selected_puzzle
call :matrix delete selected_puzzle
call :matrix delete GUI_color
echo Total time taken : !timeTaken!
call :save2File /p
goto mainMenu

:generate_badSeed
echo Bad sudoku seed detected, repeating...
ping localhost /n 3 > nul 2> nul
goto generate_reset

:generateMore
call :save2File /p /q
goto generate_reset

rem ======================================== Solver ========================================

:generateAnswer [Matix_Name] [Methods]
set "bruteforceCount=0"
set "testCount=0"
set "solutionCount=0"
set "useMethods=all"
if not "%2" == "" set "useMethods=%2"
set "useBruteforce=true"
set "maxSolutionCount=1"
set /a "bruteforceLimit= 2 * !totalCells!"
set "tryVaue="

call :matrix set %1 " "
call :matrix set candidateList "!symbolList!"

set /a "initGivens=!totalCells! * 15 / 100 + 1"
call :randCellList %1 /e !initGivens!
for %%c in (!cellList!) do for /f "tokens=1,2 delims=-" %%x in ("%%c") do (
    set /a "testCount+=1"
    set /p "=!clearLine!Initializing answer...   !testCount!/!initGivens!" < nul
    
    set "tempVar1=!candidateList_%%c: =!"
    for /l %%n in (!sideLength!,-1,0) do if "!tempVar1:~%%n,1!" == "" set "tryValue=%%n"
    set /a "tryValue=!random! %% !tryValue!"
    for %%n in (!tryValue!) do set "tryValue=!tempVar1:~%%n,1!"
    
    for %%s in (!tryValue!) do (
        for %%b in (!blockNum_%%x-%%y!) do for %%p in (!rowList%%x! !colList%%y! !blockList%%b!) do (
            set "candidateList_%%p=!candidateList_%%p:%%s= !"
        )
        set "candidateList_%%c=!candidateMark_%%s!"
    )
    call :matrix toArray %1 testArray!testCount!
    set "tryValue!testCount!=!tryValue!"
    set "%1_%%c=!tryValue!"
)
set /p "=!clearLine!Preparing to bruteforce..." < nul
goto solve_reset


:bruteforceSudoku [Matix_Name] [/SC | /C]
set "bruteforceCount=0"
set "testCount=0"
set "solutionCount=0"
set "useMethods=all"
set "checkOnly=false"
set "useBruteforce=true"
set "maxSolutionCount=1"
set "bruteforceLimit=-1"
set "tryVaue="
if /i "%2" == "/SC" set "maxSolutionCount=!solutionCountLimit!"
if /i "%2" == "/C"  set "maxSolutionCount=2"
set /p "=!clearLine!Preparing to bruteforce..." < nul
for /l %%n in (1,1,!solutionCountLimit!) do set "solution%%n="
goto solve_reset


:solveSudoku [Matix_Name] [Methods] [/O]
set "useBruteforce=false"
set "solveOnce=false"
set "useMethods=all"
if /i "%2" == "/O" (
    set "solveOnce=true"
) else if not "%2" == "" set "useMethods=%2"
if /i "%3" == "/O" set "solveOnce=true"
goto solve_reset


:setupCandidates [Matix_Name]
call :matrix set candidateList "!symbolList!"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        for %%n in (!%1_%%i-%%j!) do (
            for %%b in (!blockNum_%%i-%%j!) do for %%c in (!rowList%%i! !colList%%j! !blockList%%b!) do (
                set "candidateList_%%c=!candidateList_%%c:%%n= !"
            )
            set "candidateList_%%i-%%j=!candidateMark_%%n!"
        )
    )
)
goto :EOF


:solve_reset
rem Show candidates
call :matrix set candidateList "!symbolList!"
set "filledCells=0"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        for %%n in (!%1_%%i-%%j!) do (
            for %%b in (!blockNum_%%i-%%j!) do for %%c in (!rowList%%i! !colList%%j! !blockList%%b!) do (
                set "candidateList_%%c=!candidateList_%%c:%%n= !"
            )
            set "candidateList_%%i-%%j=!candidateMark_%%n!"
            set /a "filledCells+=1"
        )
    )
)
set /a "emptyCells=!totalCells! - !filledCells!"
set "solveError=false"
set "solvedCells="
set "prevEmptyCells=!emptyCells!"

:solve_loop
if not "!prevEmptyCells!" == "!emptyCells!" (
    if "!solveOnce!" == "true" goto solve_done
)
set "prevEmptyCells=!emptyCells!"

rem ? Change?
set "solveMethod=Singles"

for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        if "!%1_%%i-%%j!" == " " (
            set "tempVar1=!candidateList_%%i-%%j: =!"
            if defined tempVar1 (
                if "!tempVar1:~1!" == "" for %%s in (!tempVar1!) do (
                    for %%b in (!blockNum_%%i-%%j!) do for %%c in (!rowList%%i! !colList%%j! !blockList%%b!) do (
                        set "candidateList_%%c=!candidateList_%%c:%%s= !"
                    )
                    set "candidateList_%%i-%%j=!candidateMark_%%s!"
                    set "%1_%%i-%%j=%%s"
                    set /a "emptyCells-=1"
                    if "!solveOnce!" == "true" set "solvedCells=!solvedCells! %%i-%%j"
                )
            ) else set "solveError=true"
        )
    )
)

if "!emptyCells!" == "0" goto solve_done
if "!solveError!" == "true" goto solve_error
if not "!prevEmptyCells!" == "!emptyCells!" goto solve_loop
if !useMethods!0 LEQ 10 goto solve_tooHard


set "solveMethod=Hidden Singles"

for /l %%i in (1,1,!sideLength!) do (
    rem Row
    set "symbolSearch=!symbolSpaced!"
    for /l %%j in (1,1,!sideLength!) do (
        for %%s in (!%1_%%i-%%j!) do set "symbolSearch=!symbolSearch: %%s= !"
    )
    for %%s in (!symbolSearch!) do set "cell_%%s= "
    for /l %%j in (1,1,!sideLength!) do for %%s in (!symbolSearch!) do (
        if not "!candidateList_%%i-%%j:%%s=!" == "!candidateList_%%i-%%j!" (
            if defined cell_%%s if "!cell_%%s!" == " " (
                set "cell_%%s=%%j"
            ) else set "cell_%%s="
        )
    )
    for %%s in (!symbolSearch!) do for %%n in (!cell_%%s!) do for %%b in (!blockNum_%%i-%%n!) do (
        for %%c in (!rowList%%i! !colList%%n! !blockList%%b!) do (
            set "candidateList_%%c=!candidateList_%%c:%%s= !"
        )
        set "candidateList_%%i-%%n=!candidateMark_%%s!"
        set "%1_%%i-%%n=%%s"
        set /a "emptyCells-=1"
        if "!solveOnce!" == "true" set "solvedCells=!solvedCells! %%i-%%n"
    )
    
    rem Column
    set "symbolSearch=!symbolSpaced!"
    for /l %%j in (1,1,!sideLength!) do (
        for %%s in (!%1_%%j-%%i!) do set "symbolSearch=!symbolSearch: %%s= !"
    )
    for %%s in (!symbolSearch!) do set "cell_%%s= "
    for /l %%j in (1,1,!sideLength!) do for %%s in (!symbolSearch!) do (
        if not "!candidateList_%%j-%%i:%%s=!" == "!candidateList_%%j-%%i!" (
            if defined cell_%%s if "!cell_%%s!" == " " (
                set "cell_%%s=%%j"
            ) else set "cell_%%s="
        )
    )
    for %%s in (!symbolSearch!) do for %%n in (!cell_%%s!) do for %%b in (!blockNum_%%n-%%i!) do (
        for %%c in (!rowList%%n! !colList%%i! !blockList%%b!) do (
            set "candidateList_%%c=!candidateList_%%c:%%s= !"
        )
        set "candidateList_%%n-%%i=!candidateMark_%%s!"
        set "%1_%%n-%%i=%%s"
        set /a "emptyCells-=1"
        if "!solveOnce!" == "true" set "solvedCells=!solvedCells! %%n-%%i"
    )
    
    rem Block
    set "symbolSearch=!symbolSpaced!"
    for %%c in (!blockList%%i!) do (
        for %%s in (!%1_%%c!) do set "symbolSearch=!symbolSearch: %%s= !"
    )
    for %%s in (!symbolSearch!) do set "cell_%%s= "
    for %%c in (!blockList%%i!) do for %%s in (!symbolSearch!) do (
        if not "!candidateList_%%c:%%s=!" == "!candidateList_%%c!" (
            if defined cell_%%s if "!cell_%%s!" == " " (
                set "cell_%%s=%%c"
            ) else set "cell_%%s="
        )
    )
    for %%s in (!symbolSearch!) do for %%n in (!cell_%%s!) do for /f "tokens=1,2 delims=-" %%x in ("%%n") do (
        for %%c in (!rowList%%x! !colList%%y! !blockList%%i!) do (
            set "candidateList_%%c=!candidateList_%%c:%%s= !"
        )
        set "candidateList_%%n=!candidateMark_%%s!"
        set "%1_%%n=%%s"
        set /a "emptyCells-=1"
        if "!solveOnce!" == "true" set "solvedCells=!solvedCells! %%n"
    )
)
for %%s in (!symbolSpaced!) do set "cell_%%s= "

if "!emptyCells!" == "0" goto solve_done
if not "!prevEmptyCells!" == "!emptyCells!" goto solve_loop
if !useMethods!0 LEQ 20 goto solve_tooHard

rem set "solveMethod=Naked Pair"

rem naked pairs - remove surroundings
rem 2 cells with the same candidate

rem hidden pairs - identify self
rem 2 candidate only found in 2 cells

rem naked triples
rem 3 cells with total of 3 candidates
rem 3 candidates found only in 3 cells

rem eliminate [list - exeption] [number]

set "solveMethod=Unsolvable"

:solve_tooHard
if /i "!useBruteforce!" == "false" goto :EOF
set "tryValue="
goto bruteforce_findNext


:solve_error
if /i "!useBruteforce!" == "false" goto :EOF
goto bruteforce_backtrack


:solve_done
if /i "!useBruteforce!" == "false" goto :EOF
set /a "solutionCount+=1"
call :matrix toArray %1 solution!solutionCount!
if "!solutionCount!" == "!maxSolutionCount!" goto bruteforce_done
goto bruteforce_backtrack


:bruteforce_findNext
if "!bruteforceCount!" == "!bruteforceLimit!" goto bruteforce_done
set "cellPos=?-?"
set "leastCandidateNum=!sideLength!"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        if "!%1_%%i-%%j!" == " " (
            set "tempVar1=!candidateList_%%i-%%j: =!"
            for /l %%n in (!sideLength_!,-1,0) do if "!tempVar1:~%%n,1!" == "" set "candidateNum=%%n"
            if !candidateNum! LSS !leastCandidateNum! (
                set "cellPos=%%i-%%j"
                set "leastCandidateNum=!candidateNum!"
            )
        )
    )
)
for /l %%n in (0,1,!sideLength_!) do (
    if defined tryValue (
        if "!tryValue!" == "!candidateList_%cellPos%:~%%n,1!" set "tryValue="
    ) else if not "!candidateList_%cellPos%:~%%n,1!" == " " (
        set "tryValue=!candidateList_%cellPos%:~%%n,1!"
    )
)
if not defined tryValue goto bruteforce_backtrack

set /a "testCount+=1"
set /a "bruteforceCount+=1"
call :matrix toArray %1 testArray!testCount!
set "tryValue!testCount!=!tryValue!"
set "%1_!cellPos!=!tryValue!"

set /p "=!clearLine!Bruteforcing... #!bruteforceCount!:!testCount! | Solutions: !solutionCount!" < nul
goto solve_reset


:bruteforce_backtrack
if "!testCount!" == "0" goto bruteforce_done
call :matrix create %1 testArray!testCount!
set "tryValue=!tryValue%testCount%!"
set "testArray!testCount!="
set "tryValue!testCount!="
call :setupCandidates %1
set /a "testCount-=1"
goto bruteforce_findNext


:bruteforce_done
set /p "=!clearLine!" < nul

rem Delete variables
for /l %%n in (!testCount!,-1,1) do (
    set "testArray%%n="
    set "tryValue!testCount!="
)
if "!solutionCount!" == "0" goto :EOF
call :matrix create %1 solution1
goto :EOF

rem ======================================== Cell, Array and Matrix ========================================

:matrix
if /i "%1" == "create" (
    if "!%~3!" == "" goto :EOF
    set "tempArray1=!%3!"
)
if /i "%1" == "toArray" set "%3="
if /i "%1" == "count" set "return=0"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        if /i "%1" == "create" (
            set "%2_%%i-%%j=!tempArray1:~0,1!"
            set "tempArray1=!tempArray1:~1!"
        )
        if /i "%1" == "swap" for %%n in (!%2_%%i-%%j!) do (
            if "%%n" == "%~3" set "%2_%%i-%%j=%~4"
            if "%%n" == "%~4" set "%2_%%i-%%j=%~3"
        )
        if /i "%1" == "set"     set "%2_%%i-%%j=%~3"
        if /i "%1" == "copy"    set "%3_%%i-%%j=!%2_%%i-%%j!"
        if /i "%1" == "toArray" set "%3=!%3!!%2_%%i-%%j!"
        if /i "%1" == "delete"  set "%2_%%i-%%j="
        if /i "%1" == "count"   if     "!%2_%%i-%%j!" == "%~3"  set /a "return+=1"
        if /i "%1" == "color"   if not "!%2_%%i-%%j!" == " "    set "GUI_color_%%i-%%j=%3"
    )
)
goto :EOF
rem CREATE [Matix_Name] [Source_Array]
rem COPY [Source_Matix] [Destination_Matrix]
rem SWAP [Matix_Name] [Number1] [Number2]
rem COLOR [Puzzle_Matix]
rem toArray [Source_Matix] [Destination_Array]
rem DELETE [Matix_Name]
rem COUNT [Matix_Name] [Symbol]
rem COMPARE
goto :EOF


:checkArray [Array_Name]
set "arrayIsValid=false"

rem Convert all '0's to space
set "%1=!%1:?= !"
for %%c in ( _ 0 . ) do set "%1=!%1:%%c= !"

set "tempVar1=!%1!@"
set "errorMsg=Array is too short"
if "!tempVar1:~%totalCells%!" == "" goto :EOF

set "errorMsg=Array is too long"
if not "!tempVar1:~%totalCells%!" == "@" goto :EOF

set "errorMsg=Array contains invalid symbols"
set "tempVar1=!tempVar1: =!"
set "tempVar2=!tempVar1!"
for %%a in (!symbolSpaced!) do set "tempVar1=!tempVar1:%%a=!"
if not "!tempVar1!" == "@" goto :EOF

set "arrayIsValid=true"

set "errorMsg=Too few givens for a valid sudoku"
if "!tempVar2:~%minimumGivens%,1!" == "" goto :EOF

set "errorMsg="
call :matrix create temp1 %1
call :matrix set GUI_color !defaultColor!
call :checkDuplicate temp1
call :matrix delete temp1
goto :EOF


:checkDuplicate [Matix_Name]
for /l %%n in (1,1,!sideLength!) do (
    for /l %%x in (1,1,!sideLength!) do  for /l %%y in (%%x,1,!sideLength!) do if not "%%x" == "%%y" (
        if not "!%1_%%n-%%x!" == " " if "!%1_%%n-%%x!" == "!%1_%%n-%%y!" (
            set "GUI_color_%%n-%%x=!errorColor!"
            set "GUI_color_%%n-%%y=!errorColor!"
        )
        if not "!%1_%%x-%%n!" == " " if "!%1_%%x-%%n!" == "!%1_%%y-%%n!" (
            set "GUI_color_%%x-%%n=!errorColor!"
            set "GUI_color_%%y-%%n=!errorColor!"
        )
    )
    for %%a in (!blockList%%n!) do for %%b in (!blockList%%n!) do (
        if "%%a" LSS "%%b" if not "!%1_%%a!" == " " (
            if "!%1_%%a!" == "!%1_%%b!" (
                set "GUI_color_%%a=!errorColor!"
                set "GUI_color_%%b=!errorColor!"
            )
        )
    )
)
call :matrix count GUI_color !errorColor!
set "duplicatesFound=!return!"
if not "!duplicatesFound!" == "0" set "errorMsg=Sudoku contains !duplicatesFound! duplicate numbers"
goto :EOF


:checkCellcode
set "cellCode=%1"
set "rowNumber="
for /l %%n in (1,1,!sideLength!) do if not defined rowNumber (
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
if !rowNumber! GEQ 1 if !rowNumber! LEQ !sideLength! (
    if !colNumber! GEQ 1 if !colNumber! LEQ !sideLength! (
        set "cellPos=!rowNumber!-!colNumber!"
    )
)
goto :EOF


:randCellList [Matix_Name] [/F (Filled) | /E (Empty)] [Number]
set "cellList="
set "tempList="
set "listCount="
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        set "tempVar1=     %%i-%%j"
        if "!%1_%%i-%%j!" == " " (
            if /i "%2" == "/e" (
                set "tempList=!tempList!!tempVar1:~-5,5!"
                set /a "listCount+=1"
            )
        ) else if /i "%2" == "/f" (
            set "tempList=!tempList!!tempVar1:~-5,5!"
            set /a "listCount+=1"
        )
    )
)
set "tempVar1=1"
if not "%3" == "" set /a "tempVar1=!listCount! - %3 + 1"
for /l %%l in (!listCount!,-1,!tempVar1!) do (
    set /a "tempVar1=!random! %% %%l"
    set /a "tempVar1*=5"
    for %%n in (!tempVar1!) do (
        set "tempVar1=!tempList:~%%n,5!"
        set "cellList=!cellList! !tempVar1: =!"
        set "tempList=!tempList:~%%n!!tempList:~0,%%n!"
        set "tempList=!tempList:~5!"
    )
)
goto :EOF


:move [Up|Down|Left|Right|Next|Back]
for /f "tokens=1,2 delims=-" %%a in ("!cellPos!") do (
    set "cellRow=%%a"
    set "cellCol=%%b"
    if /i "%1" == "back" set /a "cellCol-=1"
    if /i "%1" == "next" set /a "cellCol+=1"
    if !cellCol! LSS 1              set /a "cellRow-=1"
    if !cellCol! GTR !sideLength!   set /a "cellRow+=1"
    if /i "%1" == "up"      set /a "cellRow-=1"
    if /i "%1" == "down"    set /a "cellRow+=1"
    if /i "%1" == "left"    set /a "cellCol-=1"
    if /i "%1" == "right"   set /a "cellCol+=1"
    if !cellRow! LSS 1              set "cellRow=!sideLength!"
    if !cellRow! GTR !sideLength!   set "cellRow=1"
    if !cellCol! LSS 1              set "cellCol=!sideLength!"
    if !cellCol! GTR !sideLength!   set "cellCol=1"
)
set "cellPos=!cellRow!-!cellCol!"
goto :EOF


:checkBlockSize [Size (MxN)]
set "sizeIsValid=false"
for /f "tokens=1,2 delims=Xx" %%a in ("%1") do (
    if %%a GEQ 2 if %%a LEQ 4 if %%b GEQ 2 if %%b LEQ 4 (
        set "sizeIsValid=true"
    )
)
goto :EOF


:setupBlocks
if "%1" == "!currentBlockSize!" goto :EOF

rem Delete all previous blocks
for /l %%n in (1,1,!sideLength!) do (
    set "rowList%%n="
    set "colList%%n="
    set "blockList%%n="
)
call :matrix delete blockList
for %%s in (!symbolSpaced!) do set "candidateMark_%%s="

set "currentBlockSize=%1"
for /f "tokens=1,2 delims=x" %%a in ("%1") do (
    set "blockWidth=%%a"
    set "blockHeight=%%b"
)

rem Calculate sudoku size
set /a "sideLength=!blockWidth! * !blockHeight!"
set /a "totalCells=!sideLength! * !sideLength!"
set /a "minimumGivens=!totalCells! / 5 + 1"

rem Special needs for loop starting with 0
set /a "sideLength_=!sideLength! - 1"

rem Define cell blocks
set "blockNumber=1"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        set "rowList%%i=!rowList%%i! %%i-%%j"
        set "colList%%j=!colList%%j! %%i-%%j"
        set "blockNum_%%i-%%j=!blockNumber!"
        for %%n in (!blockNumber!) do set "blockList%%n=!blockList%%n! %%i-%%j"
        set /a "tempVar1=%%j %% !blockWidth!"
        if "!tempVar1!" == "0" set /a "blockNumber+=1"
    )
    set /a "tempVar1=%%i %% !blockHeight!"
    if not "!tempVar1!" == "0" set /a "blockNumber-=!blockHeight!"
)

rem Create symbol list
set "symbolList=123456789ABCDEFG"
set "symbolList=!symbolList:~0,%sideLength%!"
set "symbolSpaced="
for /l %%n in (0,1,!sideLength_!) do set "symbolSpaced=!symbolSpaced! !symbolList:~%%n,1!"

rem Create single candidates for solver
set "spaces="
for %%s in (!symbolSpaced!) do (
    set "candidateMark_%%s=!spaces!%%s"
    set "spaces=!spaces! "
)
set "candidateMark_empty=!spaces!"
for %%s in (!symbolSpaced!) do (
    set "candidateMark_%%s=!candidateMark_%%s!!spaces!"
    set "candidateMark_%%s=!candidateMark_%%s:~0,%sideLength%!"
)
goto :EOF

rem ================================================== Action Log ==================================================

:action
if /i "%1" == "RESET" (
    set "actionMatrix=%2"
    set "actionCount=0"
    set "actionLog=XXXX"
)
if /i "%1" == "MARK" ( 
    for %%s in (0 !symbolSpaced!) do if /i "%3" == "%%s" (
        set /a "actionCount+=1"
        set "actionLog=%2-!%actionMatrix%_%2!-%3;!actionLog!"
        if "%3" == "0" (
            set "!actionMatrix!_%2= "
        ) else set "!actionMatrix!_%2=%%s"
    )
)
if /i "%1" == "UNDO" (
    if "!actionCount!" == "0" goto :EOF
    for /f "tokens=1* delims=;" %%k in ("!actionLog!") do (
        for /f "tokens=1-4 delims=-" %%a in ("%%k") do (
            set "!actionMatrix!_%%a-%%b=%%c"
            set "actionLog=%%l"
            set /a "actionCount-=1"
        )
    )
)
if /i "%1" == "updateLog" (
    if !sideText_width! LSS 16 goto :EOF
    set "sideText=!sideText!!log_topBorder!\n!log_title!\n!log_midLine!\n"
    set "tempLog=!actionLog!"
    set /a "tempVar1=!blockWidth! + !blockHeight!"
    set /a "tempVar1=!tempVar1! * 3 / 4"
    for /l %%n in (1,1,!tempVar1!) do (
        if /i "!tempLog!" == "XXXX" (
            set "sideText=!sideText!!vBorder!             !vBorder!\n"
        ) else (
            for /f "tokens=1* delims=;" %%k in ("!tempLog!") do (
                for /f "tokens=1-4 delims=-" %%a in ("%%k") do (
                    set "sideText=!sideText!!vBorder! !alphabets:~%%a,1!%%b | %%c -> %%d !vBorder!\n"
                    set "tempLog=%%l"
                )
            )
        )
    )
    set "sideText=!sideText!!log_btmBorder!\n"
)
goto :EOF
rem RESET [Matix_Name]
rem MARK [CellPosition] [Number]
rem UNDO
rem updateLog
goto :EOF

rem ======================================== Save / Load State ========================================

:state
if /i "%1" == "reset" (
    for /l %%n in (!stateCount!,-1,1) do (
        for %%v in (array actionLog actionCount) do set "state%%n_%%v="
    )
    set "stateMatrix=%2"
    set "stateCount=0"
)
if /i "%1" == "save" (
    set /a "stateCount+=1"
    call :matrix toArray !stateMatrix! state!stateCount!_array
    set "state!stateCount!_actionLog=!actionLog!"
    set "state!stateCount!_actionCount=!actionCount!"
)
if /i "%1" == "load" (
        if not "!stateCount!" == "0" (
                call :matrix create !stateMatrix! state!stateCount!_array
                set "actionLog=!state%stateCount%_actionLog!"
                set "actionCount=!state%stateCount%_actionCount!"
        for %%v in (array actionLog actionCount) do set "state!stateCount!_%%v="
                set /a "stateCount-=1"
        )
)
goto :EOF
rem RESET [Matix_Name]
rem SAVE
rem LOAD
goto :EOF

rem ================================================== Select Sudoku ==================================================

:selectSudoku [/c]
set "selected_name="
set "selected_size="
set "selected_puzzleArray="
set "selected_answerArray="
set "selected_solvingsArray="
set "selectedIsValid=false"
set "listCount=0"
pushd "!puzzlePath!"


:selectFile
set "selected_file="
set "selectedNumber=?"
cls
dir * /b /o:d /p 2> nul
echo=
echo T. Built-in sudoku (This file)
if defined lastUsed_puzzleArray echo L. Last used / entered sudoku
echo 0. Back
echo=
echo Select sudoku file :
set /p "selected_file="
echo=
if "!selected_file!" == "0" goto select_cleanup
if /i "!selected_file!" == "L" if defined lastUsed_puzzleArray goto selectLastUsed
if /i "!selected_file!" == "T" set "selected_file=%~f0"
if exist "!selected_file!" (
    if exist "!selected_file:~1,-1!" set "selected_file=!selected_file:~1,-1!"
) else goto selectFile_notFound

call :getList "!selected_file!"
if "!listCount!" == "0" goto selectFile_noSudoku

call :selectList
if "!selectedIsValid!" == "true" goto select_cleanup
goto selectFile


:selectFile_notFound
echo File not found
pause > nul
goto selectFile


:selectFile_noSudoku
echo No sudoku data found
pause > nul
goto selectFile


:selectList
set "selectedList=?"
cls
echo Sudoku File    : !selected_file!
echo=
for /l %%n in (1,1,!listCount!) do (
    set "display=  %%n"
    echo !display:~-2,2!. [!listSize%%n!] !listName%%n! [!listData%%n!]
)
echo=
echo 0. Back
echo=
echo Select sudoku list:
set /p "selectedList="
if "!selectedList!" == "0" goto :EOF
if defined listName!selectedList! call :selectListNumber
if "!selectedIsValid!" == "true" goto :EOF
goto selectList


:selectListNumber
if "!listData%selectedList%!" == "1" goto selectListNum1
set "selectedNumber=?"
cls
echo Sudoku File    : !selected_file!
echo List name      : [!listSize%selectedList%!] !listName%selectedList%!
echo=
echo 0. Back
echo=
echo Input sudoku number (1-!listData%selectedList%!) :
set /p "selectedNumber="
if "!selectedNumber!" == "0" goto :EOF
if !selectedNumber! GEQ 1 if !selectedNumber! LEQ !listData%selectedList%! (
    call :getList "!selected_file!" !selectedList! !selectedNumber!
    call :checkSelected
)
if "!selectedIsValid!" == "true" goto :EOF
goto selectListNumber


:selectListNum1
call :getList "!selected_file!" !selectedList! 1
call :checkSelected
goto :EOF


:selectLastUsed
set "selected_name=!lastUsed_name!"
set "selected_size=!lastUsed_size!"
set "selected_file=Unknown"
set "selected_puzzleArray=!lastUsed_puzzleArray!"
set "selected_answerArray=!lastUsed_answerArray!"
set "selected_solvingsArray=!lastUsed_solvingsArray!"
call :checkSelected
if not "!selectedIsValid!" == "true" goto selectFile
goto select_cleanup


:checkSelected
if not defined selected_puzzleArray goto :EOF
echo=
echo Checking sudoku puzzle...

call :setupBlocks !selected_size!
call :checkArray selected_puzzleArray
if "!arrayIsValid!" == "true" (
    if /i "%1" == "/c" if not "!duplicatesFound!" == "0" goto check_error
) else goto check_error

set "selectedIsValid=true"
call :setupGrid

call :checkArray selected_answerArray
if "!arrayIsValid!" == "false" set "selected_answerArray="
rem ? Check if puzzle matches answer or not
rem ? Find save data of puzzle
call :checkArray selected_solvingsArray
if "!arrayIsValid!" == "false" set "selected_solvingsArray="

rem Set as last used
set "lastUsed_name=!selected_name!"
set "lastUsed_size=!selected_size!"
set "lastUsed_file=!selected_file!"
set "lastUsed_puzzleArray=!selected_puzzleArray!"
set "lastUsed_answerArray=!selected_answerArray!"
set "lastUsed_solvingsArray=!selected_solvingsArray!"
goto :EOF


:check_error
echo ERROR: !errorMsg!
pause > nul
set "selected_name="
set "selected_size="
set "selected_puzzleArray="
set "selected_answerArray="
set "selected_solvingsArray="
goto :EOF


:select_cleanup
popd
for /l %%n in (1,1,!listCount!) do (
    for %%v in (Name Data Size) do set "list%%v%%n="
)
goto :EOF


:getList
set "listCount=0"
set "currentList=0"
set "isListed=false"
set "selected_puzzleArray="
for /f "usebackq tokens=*" %%o in ("%~f1") do (
    for /f "tokens=1,2* delims= " %%a in ("%%o") do (
        if /i "%%a" == "#ENDLIST" set "isListed=false"
        if /i "%%a" == "#SUDOKU" (
            call :checkBlockSize %%b
            if "!sizeIsValid!" == "true" (
                set "isListed=true"
                set "newList=true"
                for /l %%n in (1,1,!listCount!) do if "!listName%%n!,!listSize%%n!" == "%%c,%%b" (
                    set "newList=false"
                    set "currentList=%%n"
                )
                if "!newList!" == "true" (
                    for %%n in (!listCount!) do (
                        if not "!listData%%n!" == "0" set /a "listCount+=1"
                    )
                    set "currentList=!listCount!"
                    set "listName!listCount!=%%c"
                    set "listData!listCount!=0"
                    set "listSize!listCount!=%%b"
                )
            ) else set "isListed=false"
        ) else for %%n in (!currentList!) do (
            if "!isListed!" == "true" if /i not "%%a" == "//" set /a "listData%%n+=1"
            if not defined selected_puzzleArray if "%2,%3" == "%%n,!listData%%n!" (
                for /f "tokens=1-3 delims=_" %%p in ("%%o") do (
                    set "selected_puzzleArray=%%p"
                    set "selected_answerArray=%%q"
                    set "selected_solvingsArray=%%r"
                    set "selected_name=!listName%%n! #!listData%%n!"
                    set "selected_size=!listSize%%n!"
                )
            )
        )
    )
)
if "!listData%listCount%!" == "0" set /a "listCount-=1"
if "%2,%3" == "," goto :EOF
if defined selected_puzzleArray goto :EOF
echo ERROR: Sudoku #%2:%3 not found in the file.
goto error_unexpected

rem ======================================== File Save / Load ========================================

:save2File [/P | /S] [/Q]
set "writePath="
set "promptUser=true"
:save2File_chkParam
if /i "%1" == "/P" set "writePath=!puzzlePath!"
if /i "%1" == "/S" set "writePath=!savePath!"
if /i "%1" == "/Q" set "promptUser=false"
shift
if not "%1" == "" goto save2File_chkParam
pushd "!puzzlePath!"
if not defined writePath goto error_unexpected
if /i "!promptUser!" == "true" goto save2File_prompt


:save2File_noPrompt
set "selected_file=!lastUsed_file!"
if not defined lastUsed_file set "selected_file=Unknown"
set "selected_name=!lastUsed_name!"
if not defined lastUsed_name (
    set "selected_name=0!time: =!"
    set "selected_name=!selected_name::=!"
    set "selected_name=Saved @!date:~12,2!!date:~4,2!!date:~7,2!_!selected_name:~-9,-3!"
)
goto save2File_write


:save2File_prompt
set "userInput=?"
set /p "userInput=Save to file? Y/N? "
if /i "!userInput!" == "N" (
    popd
    goto :EOF
)
if /i not "!userInput!" == "Y" goto save2File_prompt

if not defined lastUsed_file set "lastUsed_file=Unknown"
:save2File_fileIn
set "selected_file=!lastUsed_file!"
cls
dir * /b /o:d /p 2> nul
echo=
echo Default : !lastUsed_file!
echo=
echo Enter nothing to write to file above
echo=
echo 0. Back
echo=
echo Input sudoku file name :
set /p "selected_file="
if /i "!selected_file!" == "0" (
    popd
    goto :EOF
)
if exist "!selected_file!" (
    if exist "!selected_file:~1,-1!" set "selected_file=!selected_file:~1,-1!"
) else goto save2File_nameIn

echo=
echo File already exist. Sudoku will be added to that file
pause > nul
goto save2File_fileIn


:save2File_nameIn
set "userInput=???"
cls
echo File   : !selected_file!
echo=
echo Name   : !lastUsed_name!
echo Size   : !lastUsed_size!
set /p "=Data   : Puzzle," < nul
if defined lastUsed_answerArray set /p "=!base! Answer," < nul
if defined lastUsed_solvingsArray set /p "=!base! Solvings," < nul
echo !BS!
echo=
echo Enter nothing to use the name above
echo=
echo Input sudoku name  :
set /p "selected_name="
goto save2File_write


:save2File_write
set "saveArray=!lastUsed_puzzleArray!"
if not defined lastUsed_puzzleArray set "saveArray=0"
set "saveArray=!saveArray!_!lastUsed_answerArray!"
if not defined lastUsed_answerArray set "saveArray=!saveArray!0"
set "saveArray=!saveArray!_!lastUsed_solvingsArray!"
if not defined lastUsed_solvingsArray set "saveArray=!saveArray!0"
set "saveArray=!saveArray: =0!"

set "isListed=false"
set "listName="
set "listSize="
if exist "!selected_file!" for /f "usebackq tokens=*" %%o in ("!selected_file!") do (
    for /f "tokens=1,2* delims= " %%a in ("%%o") do (
        if /i "%%a" == "#ENDLIST" set "isListed=false"
        if /i "%%a" == "#SUDOKU" (
            set "isListed=true"
            set "listName=%%c"
            set "listSize=%%b"
        )
    )
)
if /i "!promptUser!" == "true" echo Saving sudoku [!selected_name!] in [!selected_file!]
(
    if /i "!isListed!" == "true" (
        if not "!listSize!,!listName!" == "!lastUsed_size!,!selected_name!" (
            echo #sudoku !lastUsed_size! !selected_name!
        )
    ) else echo #sudoku !lastUsed_size! !selected_name!
    echo !saveArray!
) >> "!selected_file!"
popd
if /i "!promptUser!" == "false" goto :EOF
echo Done
pause
goto :EOF

rem ======================================== GUI ========================================

:splashScreen
goto splashScreen_!gridStyle!
goto :EOF


:splashScreen_ASCII
echo                       ฒฒฒฒฒ ฒ   ฒ ฒฒฒฒ  ฒฒฒฒฒ ฒ  ฒฒ ฒ   ฒ
echo                       ฒ     ฒ   ฒ ฒ   ฒ ฒ   ฒ ฒ ฒฒ  ฒ   ฒ
echo                       ฒฒฒฒฒ ฒ   ฒ ฒ   ฒ ฒ   ฒ ฒฒฒ   ฒ   ฒ
echo                           ฒ ฒ   ฒ ฒ   ฒ ฒ   ฒ ฒ ฒฒ  ฒ   ฒ
echo                       ฒฒฒฒฒ ฒฒฒฒฒ ฒฒฒฒ  ฒฒฒฒฒ ฒ  ฒฒ ฒฒฒฒฒ  !scriptVersion!
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


:splashScreen_UTF8
echo "!BS!                 ____   _    _   ___     _____   _   _  _    _
echo "!BS!                //  \\  ||  ||  || \\   //   \\  || //  ||  ||
echo "!BS!                \\___   ||  ||  ||  \\  ||   ||  ||//   ||  ||
echo "!BS!                _   \\  ||  ||  ||  //  ||   ||  ||\\   ||  ||
echo "!BS!                \\__//  \\__//  ||_//   \\___//  || \\  \\__//  !scriptVersion!
echo "!BS!
echo "!BS!                        _______________________________
echo "!BS!                        |        Made by wthe22       |
echo "!BS!                        | http://winscr.blogspot.com/ |
echo "!BS!                        |_____________________________|
goto :EOF


:gridStyle_ASCII
set "hGrid=ฤ"
set "vGrid=ณ"
set "cGrid=ล"
set "hBorder=อ"
set "vBorder=บ"
set "cBorder=ฮ"
set "uEdge=ห"
set "dEdge=ส"
set "lEdge=ฬ"
set "rEdge=น"
set "ulCorner=ษ"
set "urCorner=ป"
set "dlCorner=ศ"
set "drCorner=ผ"
goto :EOF


:gridStyle_UTF8
set "hGrid=-"
set "vGrid=|"
set "cGrid=+"
set "hBorder=="
set "vBorder=||"
set "cBorder=++"
set "uEdge==="
set "dEdge==="
set "lEdge=||"
set "rEdge=||"
set "ulCorner==="
set "urCorner==="
set "dlCorner==="
set "drCorner==="
goto :EOF


:setupGrid
if "!blockWidth!x!blockHeight!" == "!currentGridSize!" (
    mode !screenWidth!,!screenHeight!
    goto :EOF
)

set "currentGridSize=!blockWidth!x!blockHeight!"
set "currentGridStyle=!gridStyle!"

rem Build sudoku n candidate GUI
call :gridStyle_!gridStyle!
for %%v in (
    smallGridLine smallBorderLine
    GUI_topBorder GUI_midBorder GUI_btmBorder GUI_midGrid
    space1 space2
    GUI_colNumbers GUI_sideSpacing
    log_topBorder log_midLine log_btmBorder
) do set "%%v="
set "spacing=  "
for /l %%n in (1,1,3) do (
    set   "smallGridLine=!smallGridLine!!hGrid!"
    set "smallBorderLine=!smallBorderLine!!hBorder!"
)
set "gridLine=!smallGridLine!"
set "borderLine=!smallBorderLine!"
for /l %%n in (2,1,!blockWidth!) do (
    set   "gridLine=!gridLine!!cGrid!!smallGridLine!"
    set "borderLine=!borderLine!!hBorder!!smallBorderLine!"
)
for /l %%n in (2,1,!blockHeight!) do (
    set "GUI_topBorder=!GUI_topBorder!!uEdge!!borderLine!"
    set "GUI_midBorder=!GUI_midBorder!!cBorder!!borderLine!"
    set "GUI_btmBorder=!GUI_btmBorder!!dEdge!!borderLine!"
    set   "GUI_midGrid=!GUI_midGrid!!vBorder!!gridLine!"
)
set "GUI_topBorder=!spacing!!ulCorner!!borderLine!!GUI_topBorder!!urCorner!"
set "GUI_midBorder=!spacing!!lEdge!!borderLine!!GUI_midBorder!!rEdge!"
set "GUI_btmBorder=!spacing!!dlCorner!!borderLine!!GUI_btmBorder!!drCorner!"
set   "GUI_midGrid=!spacing!!vBorder!!gridLine!!GUI_midGrid!!vBorder!"
call :strlen vBorder
for /l %%n in (1,1,!return!) do set "space1=!space1! "
call :strlen vGrid
for /l %%n in (1,1,!return!) do set "space2=!space2! "
set "GUI_colNumbers=!spacing!!space1!"
for /l %%n in (1,1,!sideLength!) do (
    set "tempVar1=%%n  "
    set "GUI_colNumbers=!GUI_colNumbers! !tempVar1:~0,2!"
    set /a "tempVar1=%%n %% !blockWidth!"
    if "!tempVar1!" == "0" (
        set "GUI_colNumbers=!GUI_colNumbers!!space1!"
    ) else set "GUI_colNumbers=!GUI_colNumbers!!space2!"
)

rem Calculate grid size and screen size
call :strlen GUI_colNumbers
set "GUI_width=!return!"
set /a "GUI_height= 2 + 2 * !sideLength!"
set "sideText_width=25"
set /a "screenWidth=!GUI_width! + !sideText_width! + 3"
set /a "screenHeight=!GUI_height! + 3"
if !screenWidth! LSS 54 set "screenWidth=54"
if !screenHeight! LSS 17 set "screenHeight=17"
set /a "GUI_hSpacing= (!screenWidth! - !GUI_width! - !sideText_width! - 1) / 2 "
set /a "GUI_vSpacing= (!screenHeight! - !GUI_height! - 3) / 2"
if !GUI_vSpacing! LSS 0 set "GUI_vSpacing=0"
if !GUI_hSpacing! LSS 0 set "GUI_hSpacing=0"
set /a "sideText_height= !GUI_vSpacing! * 2 + !GUI_height!"
set /a "sideText_size= !sideText_width! * !sideText_height!"

set /a "showStep_width= !GUI_width! + !totalCells! - 3 * !sideLength! + 2"
set /a "showStep_height= 2 * !GUI_height! - !sideLength! + !blockWidth! + 3"
if !showStep_width! LSS !screenWidth! set "showStep_width=!screenWidth!"
if !showStep_height! LSS !screenHeight! set "showStep_height=!screenHeight!"
mode !screenWidth!,!screenHeight!

rem Build spacings
for /l %%n in (1,1,!GUI_hSpacing!) do set "GUI_sideSpacing=!GUI_sideSpacing! "
set "GUI_lineSpacing=!GUI_sideSpacing!!GUI_sideSpacing!"
for /l %%n in (1,1,!GUI_width!) do set "GUI_lineSpacing=!GUI_lineSpacing! "

rem Build log viewer GUI
for /l %%n in (1,1,13) do (
    set "log_topBorder=!log_topBorder!!hBorder!"
    set "log_midLine=!log_midLine!!hGrid!"
    set "log_btmBorder=!log_btmBorder!!hBorder!"
)
set "log_topBorder=!ulCorner!!log_topBorder!!urCorner!"
set     "log_title=!vBorder!     LOGS    !vBorder!"
set   "log_midLine=!vBorder!!log_midLine!!vBorder!"
set "log_btmBorder=!dlCorner!!log_btmBorder!!drCorner!"

rem Create files for color GUI
pushd "!tempPath!"
set /p "=!BS!!BS!" < nul > "   _" 2> nul
for %%s in (X !symbolSpaced!) do (
    set /p "=!BS!!BS!" < nul > " %%s _" 2> nul
)
popd

set "clearLine="
for /l %%n in (2,1,!screenWidth!) do set "clearLine=!clearLine! "
set "clearLine=_!BS!!CR!!clearLine!!CR!"

rem Delete variables
for %%v in (
    smallGridLine smallBorderLine gridLine borderLine
    space1 space2 currentText
    hGrid cGrid hBorder cBorder uEdge dEdge
    ulCorner urCorner dlCorner drCorner
) do set "%%v="
goto :EOF


:displaySudoku [Matix_Name] [/N (No vertical spacing)]
pushd "!tempPath!"
set "currentLine=1"
if /i not "%2" == "/N" for /l %%n in (1,1,!GUI_vSpacing!) do for %%n in (!currentLine!) do (
    echo=!GUI_lineSpacing!!sideText%%n!
    set /a "currentLine+=1"
)
echo !GUI_sideSpacing!!GUI_colNumbers!!GUI_sideSpacing!!sideText%currentLine%!
set /a "currentLine+=1"
echo !GUI_sideSpacing!!GUI_topBorder!!GUI_sideSpacing!!sideText%currentLine%!
set /a "currentLine+=1"
for /l %%i in (1,1,!sideLength!) do (
    set /p "=!base!!GUI_sideSpacing!!alphabets:~%%i,1! !vBorder!" < nul
    for /l %%j in (1,1,!sideLength!) do (
        if "!useColor!" == "true" (
            findstr /l /v /a:!GUI_color_%%i-%%j! "." " !%1_%%i-%%j! _" nul 2> nul
        ) else set /p "=!base! !%1_%%i-%%j! " < nul
        set /a "tempVar1=%%j %% !blockWidth!"
        if "!tempVar1!" == "0" (
            set /p "=!base!!vBorder!" < nul
        ) else set /p "=!base!!vGrid!" < nul
    )
    for %%n in (!currentLine!) do echo !base!!GUI_sideSpacing!!sideText%%n!
    set /a "currentLine+=1"
    for %%n in (!currentLine!) do (
        set /a "tempVar1=%%i %% !blockHeight!"
        if "!tempVar1!" == "0" (
            if "%%i" == "!sideLength!" (
                echo !GUI_sideSpacing!!GUI_btmBorder!!GUI_sideSpacing!!sideText%%n!
            ) else echo !GUI_sideSpacing!!GUI_midBorder!!GUI_sideSpacing!!sideText%%n!
        ) else echo !GUI_sideSpacing!!GUI_midGrid!!GUI_sideSpacing!!sideText%%n!
    )
    set /a "currentLine+=1"
)
if /i not "%2" == "/N" for /l %%n in (1,1,!GUI_vSpacing!) do for %%n in (!currentLine!) do (
    echo=!GUI_lineSpacing!!sideText%%n!
    set /a "currentLine+=1"
)
popd
goto :EOF


:displayCandidates
rem !candidateColor!
pushd "!tempPath!"
for /l %%i in (1,1,!sideLength!) do (
    set /p "=!base!!alphabets:~%%i,1! !vBorder!" < nul
    for /l %%j in (1,1,!sideLength!) do (
        if "!useColor!" == "true" (
            set /p "=!BS!!BS!" < nul > "!%1_%%i-%%j!_" 2> nul
            findstr /l /v /a:!GUI_color_%%i-%%j! "." "!%1_%%i-%%j!_" nul 2> nul
        ) else set /p "=!base!!%1_%%i-%%j!" < nul
        set /a "tempVar1=%%j %% !blockWidth!"
        if "!tempVar1!" == "0" (
            set /p "=!base!!vBorder!" < nul
        ) else set /p "=!base!!vGrid!" < nul
    )
    echo=
    set /a "tempVar1=%%i %% !blockHeight!"
    if "!tempVar1!" == "0" echo=
)
popd
goto :EOF


:parseSideText
if "!sideText!" == "!currentText!" goto :EOF
set "currentText=!sideText!"
for /l %%n in (1,1,!sideText_height!) do set "sideText%%n="
if defined sideText (
    set "newLine=false"
    set "charCount=0"
    set "currentLine=1"
    for /l %%s in (1,1,!sideText_size!) do if defined sideText (
        if !currentLine! LEQ !sideText_height! for %%n in (!currentLine!) do (
            if "!sideText:~0,1!" == "\" (
                set "sideText=!sideText:~1!"
                if "!sideText:~0,1!" == "n" (
                    set "newLine=true"
                ) else set "sideText%%n=!sideText%%n!!sideText:~0,1!"
            ) else set "sideText%%n=!sideText%%n!!sideText:~0,1!"
            set /a "charCount+=1"
            set "sideText=!sideText:~1!"
            if "!charCount!" == "!sideText_width!" set "newLine=true"
            if "!newLine!" == "true" (
                set "charCount=0"
                set /a "currentLine+=1"
                set "newLine=false"
            )
        )
    )
)
set "sideText=!currentText!"
goto :EOF


:sudokuInfo [Matix_Name]
call :matrix count %1 " " 
set /a "cellGivens= !totalCells! - !return!"
set "sideText=!sideText!Sudoku Puzzle Information\n"
set "sideText=!sideText!Name    : !selected_name!\n"
set "sideText=!sideText!Givens  : !cellGivens!\n"
goto :EOF

rem ======================================== Functions ========================================

:strlen [variable_name]
set "return=0"
if defined %1 (
    for %%n in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        set /a return+=%%n
        for %%l in (!return!) do if "!%1:~%%l,1!" == "" set /a return-=%%n
    )
    set /a return+=1
)
goto :EOF


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


:sleep [milliseconds]
set /a "return=!loopSpeed! * %* / 10"
for /l %%n in (1,1,!return!) do call
goto :EOF


:speedtest
if not defined loopSpeed set "loopSpeed=300"
for /l %%n in (1,1,12) do (
    set "tempVar1=!time!"
    call :sleep 50 * 10
    (
        set "return=0"
        for %%t in (!time!:00:00:00:00 !tempVar1!:00:00:00:00) do (
            for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
                set /a "return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100"
            )
            set /a "return*=-1"
        )
        if !return! LSS 0 set /a "return+=8640000"
    )
    if "!return!" == "50" goto :EOF
    set /a "loopSpeed=!loopSpeed! * 50 / !return!"
)
goto :EOF


:countVariables
set "return=0"
for /f "usebackq tokens=*" %%o in (`set`) do set /a "return+=1"
goto :EOF


:displayVariables
set "return=0"
for /f "usebackq tokens=*" %%o in (`set`) do set /a "return+=1"
echo %* ^| Variables : !return!
pause > nul
goto :EOF

rem ======================================== Built-in Sudoku ========================================

rem Add new list:
rem #SUDOKU [Size] [Name]

#sudoku 3x3 Easy
9.7...1..2..7........2.......6.5..8..2......4.....8.16.....49574..6.3....7.9.....
2...6.3..7..4....6.1......2.2......3.638..1..5.4......6..9.28.........1......5.3.
...3..9..4......6....42...5........9.5...14782.4..61......3....7..65....6....7.8.
.......1.4.........2...........5.6.4..8...3....1.9....3..4..2...5.1........8.7...

#sudoku 3x3 Medium / Hard
........8.3.2........4.5376..1.5..97.8...954....6....2.4.......2....7.396.9......
.3.29......7.......8.1.32.74....6....2..3......5....8..4.........68..9..5.1.2..6.
2.....1.5..8.97........3.8..94.....6..5..43.....369.......8..1..4...1.23......6.7
......5.6....94.....98.5...3.27......1...2.6.......4.7.8.3.62.5.4...93...........
.1......95......747.....3.....36.....3.....8.4..9..25.9...5......6.97...37.8.4..6
.......399.485.....75..9......5..6.21...9...7...34.8..8.67.......1...7.3........6
.......399.485.....75..9......5..6.21...9...7...34.8..8.67.......1...7.3........6
97..5...2.............18.6.....4..3.45...76.91.6........9...48...718.2......2....

#sudoku 3x3 Escargot
1....7.9..3..2...8..96..5....53..9...1..8...26....4...3......1..4......7..7...3..

#sudoku 3x3 Arto Inkala
8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..

#sudoku 3x2 Minimum
030000000540000000004160000002006000
006000005010040000000050000420300000
000000004000010500030400500020000030
600000000002025000000500000064300000
000000000032000500200040001600300000
200000000604000030006400000000300500
000000032600000300100000450006000000
300006004000005000000003010540000000
000003010000600000003500050060000020
004000000003050020100000003006000050

#sudoku 2x3 Sample
030000000540000000004160000002006000

#sudoku 2x2 Minimum
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

#sudoku 4x3 Easy
0B000080090000429007B0011C00000000700080060400000000700000B040C0AB10500020A00C4B000600B0080000A00316000070000001C0000A6780000006030404000A0510C0

#sudoku 4x4 Easy
02000B9C003E6100E600005400007900C0D4000GF070000000000000D506800000G030000009E000BD0100F9004000507A000000000000D0005ED000BG0000090B0000A010F2D0G0036A00C240000F0000200G0070A00E00000000006000940004005FE000DA00000908023B0FG00A00AG000400C6000B000002C000015400F8
0080760000005900D060400030000G00000000000000C3009000005010G427FE00GC00E9006015004019030A700D000006005C0GF00000EA000E0B07A000F0203000009E0B800FD700EBC00000050030G00F05000000EA00000D0070090C000060000005C0B030010G0200000148D00000580004D0709000000029F3500E4000
0D0006000C47900A02G190E060B07F38006000000000CE00B80AC0000000G0506FBC0007010050000G87E0B040600C00000000F0000E0009E0300000900G0100400030002016000080F0000BD0000A1505D02A080703000G0B000000005806ED06000C000A0D0493F0000E90008000D2002000050E008000000000700G040000
#ENDLIST

