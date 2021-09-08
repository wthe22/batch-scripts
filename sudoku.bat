:__ENTRY__     Entry point
@rem These kinds of labels serves as a bookmark
@goto main


rem Sudoku 3.1.5
rem Updated on 2018-02-08
rem Made by wthe22
rem Visit http://winscr.blogspot.com/ for more scripts!


:restart
endlocal

:main
@echo off
prompt $s
call :setupEndlocal
setlocal EnableDelayedExpansion EnableExtensions

rem ======================================== Settings ========================================
set "dataPath=%~dp0\Data\Sudoku\"

set "defaultScreenWidth=80"
set "defaultScreenHeight=25"

set "useColor=true"   [TRUE or FALSE]
set "solutionCountLimit=5"
set "allowAllSizes=false"   [TRUE or FALSE]

rem See "COLOR /?" for more info
set   "defaultColor=07"     Default color for text
set    "puzzleColor=0E"     Puzzle / Givens 
set  "solvingsColor=07"     Solvings that user/solver entered
set "highlightColor=4E"     Highlighted cells in solver
set "candidateColor=02"     Candidate for answer in solver
set     "errorColor=0C"     Error in solvings


rem ======================================== One-time Setups ========================================

set "scriptVersion=3.1.5"
set "releaseDate=02/08/2018"
set "tempPath=!temp!\BatchScript\Sudoku\"
set "debugFile="

if not exist "!dataPath!" md "!dataPath!"
if not exist "!tempPath!" md "!tempPath!"
cd /d "!dataPath!"


rem Additional Settings
rem bottom_textLines @ GUI Builder
rem sideText_width @ GUI Builder
rem actionLog_lines @ GUI Builder
rem sideText_minHeight @ GUI Builder
rem generateModeCode @ Generator Menu
rem validSizes @ Data Setup

rem Capture backspace character
for /f %%a in ('"prompt $h & echo on & for %%b in (1) do rem"') do (
    set "BS=%%a %%a"
)

rem Capture Carriage Return character
for /f %%a in ('copy /z "%ComSpec%" nul') do set "CR=%%a"

rem Load grid style / GUI
chcp 437 > nul
call :loadGridStyle

rem Setup splash screen
color !defaultColor!
call :changeScreenSize !defaultScreenWidth! !defaultScreenHeight!
title Sudoku !scriptVersion!
cls
call :gridStyle_splashScreen_!gridStyle!

set "puzzlePath=Puzzles\"
set   "savePath=Saves\"
for %%p in (
    puzzlePath
    savePath
) do if not exist "!%%p!" md "!%%p!"

rem BASE string for "SET /P" display to prevent whitespace character from being stripped
rem because it cannot start with a white space character
set "BASE=_!BS!"

set "currentGridStyle="
set "currentGridSize="
set "ALPHABETS=.ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "SYMBOLS= 123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "screenWidth=!defaultScreenWidth!"
set "screenHeight=!defaultScreenHeight!"

call :calcValidSizes
call :setupBlocks 0x0
call :state reset
call :loadDifficulty

call :speedtest
goto mainMenu


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
echo Press any key to exit or continue with modifications
pause > nul
exit

rem ======================================== Main Menu ========================================
:__MAIN_MENU__     Main menu


:mainMenu
set "userInput=?"
call :changeScreenSize !defaultScreenWidth! !defaultScreenHeight!
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
call :gridStyle_splashScreen_!gridStyle!
pause > nul
goto mainMenu


:cleanUp
rd /s /q "!tempPath!" > nul 2> nul
exit

rem ======================================== Settings ========================================
:__SETTINGS__     Script settings


:settings_menu
set "userInput=?"
cls
echo 1. Grid style          !gridStyle_name_%gridStyle%!
echo 2. Use Color           !useColor!
echo=
echo R. Restart script      A fresh start is always good
echo 0. Back
echo=
echo What do you want to change?
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if "!userInput!" == "1" goto settings_gridStyle_menu
if "!userInput!" == "2" call :toggleColor
if /i "!userInput!" == "G" call :toggleGenerate
if /i "!userInput!" == "D" goto settings_debugInfo
if /i "!userInput!" == "R" goto restart
goto settings_menu


:settings_gridStyle_menu
set "userInput=?"
set "selectedGridStyle="
cls
echo Current grid style : !gridStyle_name_%gridStyle%!
echo=
set "menuCount=0"
for %%s in (!gridStyleList!) do (
    set /a "menuCount+=1"
    set "menuCount=  !menuCount!"
    echo !menuCount:~-2,2!. !gridStyle_name_%%s!
)
echo=
echo 0. Back
echo=
echo Input style number:
set /p "userInput="
if "!userInput!" == "0" goto settings_menu
set "menuCount=0"
for %%s in (!gridStyleList!) do (
    set /a "menuCount+=1"
    if "!userInput!" == "!menuCount!" (
        set "selectedGridStyle=%%s"
        goto settings_gridStyle_preview
    )
)
goto settings_gridStyle_menu


:settings_gridStyle_preview
echo=
echo Preview:
echo=

setlocal
call :gridStyle_char_!selectedGridStyle!
set "hB=!hBorder!"
set "vB=!vBorder!"
set "hG=!hGrid!"
echo !ulCorner!!hB!!hB!!hB!!hB!!hB!!hB!!hB!!uEdge!!hB!!hB!!hB!!urCorner!
echo !vB! 1 !vGrid! 2 !vB! !vGrid! !vB! 
echo !vB!!hG!!hG!!hG!!cGrid!!hG!!hG!!hG!!vB!!hG!!cGrid!!hG!!vB! 
echo !vB! 3 !vGrid! 4 !vB! !vGrid! !vB! 
echo !vB!!hB!!hB!!hB!!hB!!hB!!hB!!hB!!cBorder!!hB!!hB!!hB!!vB!
echo !vB!!hG!!hG!!hG!!cGrid!!hG!!hG!!hG!!vB!!hG!!cGrid!!hG!!vB! 
echo !dlCorner!!hB!!hB!!hB!!hB!!hB!!hB!!hB!!dEdge!!hB!!hB!!hB!!drCorner!
echo=
endlocal

:settings_gridStyle_confirm
set /p "userInput=Confirm? Y/N? "
if /i "!userInput!" == "N" goto settings_gridStyle_menu
if /i not "!userInput!" == "Y" goto settings_gridStyle_confirm
set "gridStyle=!selectedGridStyle!"
call :gridStyle_setup_!selectedGridStyle! 2> nul
echo Grid Style successfully changed
goto settings_gridStyle_menu


:settings_debugInfo
call :countVariables
cls
echo Debug Informations
echo=
echo Variables          : !return!
echo Loop Speed         : !loopSpeed!
echo=
pause
goto settings_menu


:toggleColor
if "!useColor!" == "true" (
    set "useColor=false"
) else set "useColor=true"
goto :EOF

rem ======================================== Play Sudoku ========================================
:__PLAY__     Play Sudoku


:play_setup
call :selectSudoku /c
if not defined selected_puzzleArray goto mainMenu

call :matrix create selected_puzzle selected_puzzleArray 1
call :matrix create selected_solvings selected_puzzleArray 1

call :state reset selected_solvings
call :action reset selected_solvings

if defined selected_solvingsArray call :state save selected_solvingsArray

set "sideText="
call :action updateLog

set "startTime=!time!"

:play_updateColor
call :matrix set GUI_color !solvingsColor!
call :matrix color selected_puzzle !puzzleColor!

:play_sudoku
set "sideText="
call :action updateLog
set "sideText=!sideText![Z] Undo!LF![X] Exit!LF![C] Check!LF![T] Toggle Color!LF!"
set "sideText=!sideText![S] Save!LF![L] Load [!stateCount!]!LF![H] Hint!LF!"
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
if not "!selected_puzzle_%cellPos%!" == " " (
    echo That cell is a part of the puzzle...
    pause > nul
)

set "userInput=?"
echo [0] Erase, [X] Cancel
set /p "userInput=Input number      : "
if /i "!userInput!" == "X" goto play_sudoku
call :action mark !cellPos! !userInput!
goto play_updateColor


:play_checkSolvings
set /p "=Checking..." < nul
call :matrix set GUI_color !solvingsColor!
call :checkDuplicate selected_solvings
call :matrix color selected_puzzle !puzzleColor!
call :matrix count selected_solvings " "
set "emptyCells=!return!"

if "!duplicatesFound!" == "0" (
    if "!emptyCells!" == "0" goto play_solved
    echo !CL!Seems good, no duplicates found...
) else (
    echo !CL!Oops^^! There is something wrong... 
    if /i "!useColor!" == "false" echo TIPS: Use color GUI to show errors
)
pause > nul
goto play_sudoku


:play_hint
set /p "=Please wait..." < nul
call :matrix copy selected_solvings temp1
call :solveSudoku temp1 /o
call :matrix delete temp1

if "!solveMethod!" == "Unsolvable" (
    echo !CL!No hint available. Sudoku is too hard for solver
) else echo !CL!Try looking for !solveMethod!
pause > nul
goto play_sudoku


:play_solved
call :difftime !time! !startTime!
call :ftime !return!
set "sideText= !LF!Solved in !return!"
call :parseSideText
call :matrix toArray selected_solvings lastUsed_answerArray

cls
call :displaySudoku selected_solvings
echo Congratulations^^! You solved the puzzle.
pause
goto mainMenu


:play_quit
set "startTime="
call :matrix delete GUI_color
call :matrix delete selected_puzzle
call :matrix toArray selected_solvings lastUsed_solvingsArray
call :matrix delete selected_solvings
call :state reset
echo Solvings saved to memory. You can load it later.
call :save2File /s
goto mainMenu

rem ======================================== Import Sudoku ========================================
:__IMPORT__     Import Sudoku


:import_setup
call :selectSize
if "!userInput!" == "0" goto mainMenu

rem Setup block and grid
call :setupBlocks !selected_size!
call :setupGrid

rem Clear selected
set "selected_puzzleArray="
set "selected_answerArray="
set "selected_solvingsArray="

rem Input sudoku puzzle and answer
call :inputSudoku selected_puzzle
if "!userInput!" == "0" goto import_setup
call :inputSudoku selected_answer selected_puzzle
if "!userInput!" == "0" goto import_setup

rem Input successful
set "lastUsed_file=Imported"
set "lastUsed_name=Imported !blockWidth!x!blockHeight!"
set "lastUsed_size=!blockWidth!x!blockHeight!"
set "lastUsed_puzzleArray=!selected_puzzleArray!"
set "lastUsed_answerArray=!selected_answerArray!"
set "lastUsed_solvingsArray=!selected_solvingsArray!"
cls
call :save2File /p
goto mainMenu


:inputSudoku
set "inputType=puzzle"
if /i "%1" == "selected_answer" set "inputType=answer"
set "%1Array="

:inputSudoku_menu
set "userInput=?"
cls
echo 1. One by one with GUI
echo 2. Array form
if /i "!inputType!" == "answer" echo 3. Skip this step
echo=
echo 0. Back
echo=
echo Choose !inputType! input method :
set /p "userInput="
if "!userInput!" == "0" goto :EOF
if "!userInput!" == "1" goto inputSudoku_GUI_setup
if "!userInput!" == "2" goto inputSudoku_array
if /i "!inputType!" == "answer" if "!userInput!" == "3" goto :EOF
goto inputSudoku_menu


:inputSudoku_GUI_setup
if /i "!inputType!" == "puzzle" (
    call :matrix set %1 " "
    call :matrix set GUI_color !puzzleColor!
) else (
    call :matrix create %1 %2Array 1
    call :matrix set GUI_color !solvingsColor!
    call :matrix color %1 !puzzleColor!
    call :matrix toArray GUI_color originalColor
)
call :action reset %1
set "cellPos=1-1"
set "inputSymbols=0!symbolList!"
set "needsUpdate=true"

:inputSudoku_GUI
if /i "!needsUpdate!" == "true" call :inputSudoku_GUI_update %1 %2
call :inputSudoku_GUI_markCurrent %1 !cellPos!
cls
call :displaySudoku %1
call :inputSudoku_GUI_restoreCurrent %1 !cellPos!
choice /c ZXHIJKLT0!symbolList! /n /m "Input number   : "
set "userInput=!errorlevel!"
if "!userInput!" == "1" call :action undo                   & set "needsUpdate=true"
if "!userInput!" == "2" call :inputSudoku_GUI_cleanup %1 %2 & goto inputSudoku_menu
if "!userInput!" == "3" goto inputSudoku_GUI_check
if "!userInput!" == "4" call :move up
if "!userInput!" == "5" call :move left
if "!userInput!" == "6" call :move down
if "!userInput!" == "7" call :move right
if "!userInput!" == "8" call :toggleColor
if !userInput! LEQ 8 goto inputSudoku_GUI
set /a "userInput=!errorlevel! - 8 - 1"
set "userInput=!inputSymbols:~%userInput%,1!"
call :action mark !cellPos! !userInput!
set "needsUpdate=true"
call :move next
goto inputSudoku_GUI


:inputSudoku_GUI_update
rem Color GUI
if "!inputType!" == "puzzle" (
    call :matrix set GUI_color !puzzleColor!
) else call :matrix create GUI_color originalColor 2
call :checkDuplicate %1 %2

rem Count givens
call :matrix count %1 " "
set /a "cellGivens=!totalCells! - !return!"

rem Update side text
set "sideText="
set "sideText=!sideText!Duplicates  : !duplicatesFound!!LF!"
set "sideText=!sideText!Givens      : !cellGivens!!LF! !LF!"
set "sideText=!sideText![Z] Undo!LF![X] Exit!LF![H] Check / Done!LF!"
set "sideText=!sideText![T] Toggle Color!LF![0] Erase!LF! !LF!Use IJKL to move!LF! !LF!"
set "sideText=!sideText!Characters:!symbolList!!LF!"
call :parseSideText

set "needsUpdate=false"
goto :EOF


:inputSudoku_GUI_markCurrent   matrix_name cellPos
set "_savedValue=!%1_%2!"
set "_savedColor=!GUI_color_%2!"
set "GUI_color_%2=!highlightColor!"
set "%1_%2=X"
goto :EOF


:inputSudoku_GUI_restoreCurrent   matrix_name cellPos
set "%1_%2=!_savedValue!"
set "GUI_color_%2=!_savedColor!"
set "_savedValue="
set "_savedColor="
goto :EOF


:inputSudoku_GUI_check
call :matrix toArray %1 %1Array
if "!duplicatesFound!" == "0" (
    if /i "%1" == "answer" (
        if "!cellGivens!" == "!totalCells!" (
            goto inputSudoku_GUI_done
        ) else echo There are still !return! empty cells...
    ) else if !cellGivens! GEQ !minimumGivens! (
        goto inputSudoku_GUI_done
    ) else echo Too few givens for a valid sudoku
) else echo Duplicates found. Use color to see the duplicates.
pause > nul
goto inputSudoku_GUI


:inputSudoku_GUI_cleanup
call :matrix delete GUI_color
call :matrix delete %1
for %%v in (cellPos cellGivens originalColor inputSymbols duplicatesFound sideText needsUpdate) do set "%%v="
call :parseSideText
goto :EOF


:inputSudoku_array
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
if "!userInput!" == "0" goto inputSudoku_menu
set "%1Array=!userInput!"
set "errorMsg="
call :checkArray %1Array
if "!arrayIsValid!" == "true" goto inputSudoku_array_display
echo=
echo ERROR: !errorMsg!
echo=
pause
goto inputSudoku_array


:inputSudoku_array_display
set "sideText="
call :parseSideText
call :matrix create %1 %1Array 1
cls
call :displaySudoku %1
call :matrix delete %1
if not defined errorMsg goto inputSudoku_done
echo ERROR: !errorMsg!
pause > nul
goto inputSudoku_array


:inputSudoku_GUI_done
call :inputSudoku_GUI_cleanup

:inputSudoku_done
echo Input successful
pause > nul
goto :EOF

rem ======================================== View Sudoku ========================================
:__VIEWER__     View Sudoku


:viewer_setup
call :selectSudoku
if not defined selected_puzzleArray goto mainMenu

call :matrix create selected_puzzle selected_puzzleArray 1
if defined selected_answerArray call :matrix create selected_answer selected_answerArray 1
if defined selected_solvingsArray call :matrix create selected_solvings selected_solvingsArray 1

call :matrix set GUI_color !solvingsColor!
call :matrix color selected_puzzle !puzzleColor!

set "sideText="
call :sudokuInfo selected_puzzle
set "sideText=!sideText! !LF![C] Copy array!LF! !LF!"
set "sideText=!sideText!Press enter to exit!LF!"
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


:viewMatrix matix_name
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
if defined selected_answerArray (
	echo Answer array:
	echo !selected_answerArray: =0!
	echo=
)
if defined selected_solvingsArray (
	echo Solvings array:
	echo !selected_solvingsArray: =0!
	echo=
)
pause
goto :EOF

rem ======================================== Generate Sudoku ========================================
:__GENERATOR__     Generate Sudoku (Menu Only)


:generator_setup
call :selectSize
if "!userInput!" == "0" goto mainMenu

call :setupBlocks !selected_size!

:generator_difficultyIn
set "userInput=?"
cls
call :generator_getDifficulty list
echo=
echo C. Custom
echo 0. Back
echo=
echo Input difficulty level:
set /p "userInput="
if "!userInput!" == "0" goto generator_setup
if /i "!userInput!" == "C" goto generator_custom_setup
call :generator_getDifficulty !userInput!
if defined selectedDifficulty goto generator_difficultySetup
goto generator_difficultyIn


:generator_getDifficulty
set "menuCount=0"
set "selectedDifficulty="
for %%d in (!difficultyList!) do (
    set /a "menuCount+=1"
    if /i "%1" == "list" (
        set "menuCount=   !menuCount!"
        echo !menuCount:~-3,3!. !difficultyName_%%d!
    ) else if "%1" == "!menuCount!" set "selectedDifficulty=%%d"
)
goto :EOF


:generator_custom_setup
set "difficultyName=Custom"
set "methodsUsed=2"
set "minGivens=0"
set "maxGivens=!totalCells!"
set "targetGivens=0"

:generator_custom_menu
cls
echo 1. Givens          !targetGivens!
echo 2. Strategy Used   !methodsUsed!
echo=
echo G. Generate
echo 0. Back
echo=
echo What do you want to customize?
set /p "userInput="
echo=
if "!userInput!" == "0" goto generator_difficultyIn
if "!userInput!" == "1" call :generator_custom_givensIn
if "!userInput!" == "2" call :generator_custom_methodUsedIn
if /i "!userInput!" == "G" goto generator_generateSetup
goto generator_custom_menu


:generator_custom_givensIn
set /p "targetGivens=Input givens (!minGivens!-!maxGivens!): "
if !targetGivens! LSS !minGivens! goto generator_custom_givensIn
if !targetGivens! GTR !maxGivens! goto generator_custom_givensIn
goto :EOF


:generator_custom_methodUsedIn
set /p "methodsUsed=Input strategy used: "
if !methodsUsed! GEQ 2 if !methodsUsed! LEQ 2 goto :EOF
if /i "!methodsUsed!" == "BF" goto :EOF
if /i "!methodsUsed!" == "all" goto :EOF
goto generator_custom_methodUsedIn


:generator_difficultySetup
set "estTime="
set "difficultyName=!difficultyName_%selectedDifficulty%!"
set "%%b=%%c"
set "methodsUsed=2"
set "minGivens=!minCustomGivens!"
set "maxGivens=!totalCells!"
set "targetGivens=0"
call :difficulty_!selectedDifficulty!

:generator_generateSetup
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

set "selected_name=!difficultyName!"
set "lastUsed_file=Generated"
set "lastUsed_name=!selected_name!"
set "lastUsed_size=!blockWidth!x!blockHeight!"
set "userInput=?"
set "generateCount=0"
set "generateTotal=0"

set "lastUsed_puzzleArray="
set "lastUsed_answerArray="
set "lastUsed_solvingsArray="

cls
echo Sudoku size        : !sideLength!x!sideLength! [!blockWidth!x!blockHeight!]
echo Difficulty         : !difficultyName!
echo Strategy Used      : !methodsUsed!
echo Givens             : !minGivens! - !maxGivens!
echo Estimated time     : !minTime! - !maxTime!
echo=
echo 0. Back
echo=
echo Press enter to start generating...
set /p "userInput="
if "!userInput!" == "0" goto generator_difficultyIn

if /i "!userInput:~0,3!" == "gen" set "generateTotal=!userInput:~3!"

set "startTime=!time!"
echo [!time!] Start generating

:generator_startGenerate
set /a "generateCount+=1"
set "startTime2=!time!"

echo=
if not "!generateTotal!" == "0" (
    call :difficulty_!selectedDifficulty!
    echo [!time!] Generating sudoku: !generateCount!/!generateTotal!
)
echo [!time!] Generating answer...
call :generateAnswer selected_puzzle
if "!solutionCount!" == "0" goto generator_badSeed

set /p "=!CL!Swapping numbers..." < nul
set /a "_swapNum=!sideLength! * 3 / 2"
for /l %%n in (0,1,!_swapNum!) do (
    set /a "_value1=!random! %% !sideLength!"
    set /a "_value2=!random! %% !sideLength!"
    for %%x in (!_value1!) do for %%y in (!_value2!) do (
        call :matrix swap selected_puzzle !symbolList:~%%x,1! !symbolList:~%%y,1!
    )
)
set "_swapNum="
call :difftime !time! !startTime2!
call :ftime !return!
echo !CL![!time!] Generate answer done in !return! with !bruteforceCount! loops
call :matrix toArray selected_puzzle lastUsed_answerArray


echo [!time!] Generating puzzle...
set "startTime2=!time!"

set "progressCount=0"
set "currentGivens=!totalCells!"
set "totalBruteforceCount=0"
call :randCellList selected_puzzle /f
for %%c in (!cellList!) do (
    title Sudoku !scriptVersion! - Generating puzzle... #!progressCount!/!totalCells! ^| Givens: !currentGivens!/!targetGivens!
    
    call :matrix copy selected_puzzle selected_solvings
    set "selected_solvings_%%c= "
    
    if /i "!methodsUsed!" == "BF" (
        call :bruteforceSudoku selected_solvings /c
        set /a "totalBruteforceCount+=!bruteforceCount!"
        if "!solutionCount!" == "1" set "selected_puzzle_%%c= "
    ) else (
        set /p "=!CL!Progress: !progressCount!/!totalCells! | Givens: !currentGivens!/!targetGivens!" < nul
        call :solveSudoku selected_solvings !methodsUsed!
        if /i "!sudokuIsValid!,!emptyCells!" == "true,0" set "selected_puzzle_%%c= "
    )
    set /a "progressCount+=1"
    if "!selected_puzzle_%%c!" == " " set /a "currentGivens-=1"
    if "!currentGivens!" == "!targetGivens!" goto generator_generateDone
)
title Sudoku !scriptVersion!

:generator_generateDone
call :difftime !time! !startTime2!
call :ftime !return!
if /i "!methodsUsed!" == "BF" (
    echo !CL![!time!] Generate puzzle done in !return! with !totalBruteforceCount! loops
) else echo !CL![!time!] Generate puzzle done in !return!

echo [!time!] Doing some cleanup...
call :matrix toArray selected_puzzle lastUsed_puzzleArray

if not "!generateTotal!" == "0" goto generateMore

call :matrix delete candidateList
call :matrix delete selected_solvings

echo [!time!] Done
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


:generator_badSeed
echo Bad sudoku seed detected, repeating...
ping localhost /n 3 > nul 2> nul
goto generator_promptGenerate


:generateMore
call :save2File /p /q
if not "!generateCount!" == "!generateTotal!" goto generator_startGenerate

call :difftime !time! !startTime!
call :ftime !return!
set "timeTaken=!return!"

call :matrix delete selected_puzzle

echo [!time!] Done
echo=
echo Total time taken : !timeTaken!
echo=
pause
goto mainMenu

rem ======================================== Solve Sudoku ========================================
:__SOLVER__     Solve Sudoku (Menu Only)


:solver_setup
call :selectSudoku /c
if not defined selected_puzzleArray goto mainMenu

rem Load puzzle, color and side text
call :matrix set GUI_color !solvingsColor!
call :matrix create selected_solvings selected_puzzleArray 1
call :matrix color selected_solvings !puzzleColor!
set "sideText="
call :sudokuInfo selected_solvings
call :parseSideText
if not defined selected_solvingsArray goto solver_showStepsIn

rem Load solvings
call :matrix create selected_solvings selected_solvingsArray 1
call :matrix count selected_solvings " " 
set /a "_solved= !totalCells! - !return! - !cellGivens!"
set "old_sideText=!sideText!"
set "sideText=!sideText!Solved  : !_solved!!LF!"
set "_solved="
call :parseSideText

:solver_savesIn
set "userInput=?"
set "useSaves="
cls
call :displaySudoku selected_solvings
echo Solvings data found
set /p "userInput=Do you want to load this solvings? Y/N? "
if /i "!userInput!" == "Y" (
    set "useSaves=true"
    goto solver_showStepsIn
)
if /i not "!userInput!" == "N" goto solver_savesIn

rem Restore puzzle and side text
call :matrix create selected_solvings selected_puzzleArray 1
set "sideText=!old_sideText!"
call :parseSideText
set "useSaves=false"
goto solver_showStepsIn


:solver_showStepsIn
set "userInput=?"
set /p "userInput=Show solvings steps? Y/N? "
if /i "!userInput!" == "Y" goto solver_showCandidatesIn
if /i "!userInput!" == "N" goto solver_quickSolve
goto solver_showStepsIn


:solver_showCandidatesIn
set "showCandidates="
set /p "userInput=Show candidates? Y/N? "
if /i "!userInput!" == "Y" set "showCandidates=true"
if /i "!userInput!" == "N" set "showCandidates=false"
if defined showCandidates goto solver_showSteps_setup
goto solver_showStepsIn


:solver_quickSolve
cls
call :displaySudoku selected_solvings
echo Press any key to start solving...
pause > nul
echo Solving sudoku...
set "startTime=!time!"
call :solveSudoku selected_solvings
if /i "!sudokuIsValid!" == "false" goto solver_invalidSudoku
if not "!emptyCells!" == "0" goto solver_tooHard

call :difftime !time! !startTime!
call :ftime !return!
set "timeTaken=!return!"
call :matrix toArray selected_solvings lastUsed_answerArray

cls
call :displaySudoku selected_solvings
echo Solve done in !timeTaken!
pause > nul
goto solver_quit


:solver_showSteps_setup
if /i "!showCandidates!" == "true" (
    call :changeScreenSize !showStep_width! !showStep_height!
    call :setupCandidates selected_solvings
    call :matrix set GUI_color !candidateColor!
    if /i "!useSaves!" == "true" (
        call :matrix create selected_solvings selected_solvingsArray 1
        call :matrix color selected_solvings !solvingsColor!
        call :matrix create selected_solvings selected_puzzleArray 1
        call :matrix color selected_solvings !puzzleColor!
        call :matrix create selected_solvings selected_solvingsArray 1
    ) else call :matrix color selected_solvings !puzzleColor!
)

set "sideText="
call :parseSideText
cls
call :displaySudoku selected_solvings /h
echo=
if /i "!showCandidates!" == "true" (
    call :displayCandidates candidateList
    echo=
)
echo Press any key to start solving...
pause > nul


:solver_showSteps
rem Save current matrix
call :matrix copy selected_solvings selected_solvings_old
if /i "!showCandidates!" == "true" (
    call :matrix copy candidateList candidateList_old
)

call :solveSudoku selected_solvings /o

rem Convert cell code and color solved cells
set "solvedCells_converted="
for %%c in (!solvedCells!) do for /f "tokens=1-2 delims=-" %%i in ("%%c") do (
    set "solvedCells_converted=!solvedCells_converted! !ALPHABETS:~%%i,1!%%j"
    set "GUI_color_%%i-%%j=!highlightColor!"
)

cls
call :displaySudoku selected_solvings_old /h
echo=
if /i "!showCandidates!" == "true" (
    call :displayCandidates candidateList_old
)
echo [!solveMethod!] !solvedCells_converted!
pause > nul

rem Restore solved cells color
for %%c in (!solvedCells!) do for /f "tokens=1-2 delims=-" %%i in ("%%c") do (
    set "GUI_color_%%i-%%j=!solvingsColor!"
)

if /i "!sudokuIsValid!" == "true" if not "!solveMethod!" == "Unsolvable" (
    if not "!emptyCells!" == "0" goto solver_showSteps
)

rem Show step cleanup
call :matrix delete selected_solvings_old
if /i "!showCandidates!" == "true" (
    call :matrix delete candidateList_old
)
if /i "!sudokuIsValid!" == "false" goto solver_invalidSudoku
if "!solveMethod!" == "Unsolvable" goto solver_tooHard

rem Solve done
call :matrix toArray selected_solvings lastUsed_answerArray
call :changeScreenSize !screenWidth! !screenHeight!
cls
call :displaySudoku selected_solvings
echo Solve done
pause > nul
goto solver_quit


:solver_invalidSudoku
rem Color last solved cells
for %%c in (!solvedCells!) do for /f "tokens=1-2 delims=-" %%i in ("%%c") do (
    set "GUI_color_%%i-%%j=!highlightColor!"
)
cls
call :displaySudoku selected_solvings /h
echo=
if /i "!showCandidates!" == "true" (
    call :displayCandidates candidateList
)
echo This sudoku is invalid. It has no solutions
echo Last solved: [!solveMethod!] !solvedCells_converted!
pause > nul
goto solver_quit


:solver_tooHard
call :matrix count selected_solvings " " 
set /a "_solved= !totalCells! - !return! - !cellGivens!"
set "sideText=!sideText!Solved  : !_solved!!LF!"
set "_solved="
call :parseSideText
call :matrix toArray selected_solvings lastUsed_solvingsArray
call :changeScreenSize !screenWidth! !screenHeight!
cls
call :displaySudoku selected_solvings
echo This sudoku is either too hard or it is invalid.


:solver_bruteforcePrompt
set "userInput=?"
set /p "userInput=Use bruteforce? Y/N? "
if /i "!userInput!" == "Y" goto solver_solutionCountIn
if /i "!userInput!" == "N" goto solver_quit
goto solver_bruteforcePrompt


:solver_solutionCountIn
set "countSolutions="
set /p "userInput=Count number of solutions? Y/N? "
if /i "!userInput!" == "Y" set "countSolutions=true"
if /i "!userInput!" == "N" set "countSolutions=false"
if defined countSolutions goto solver_startBruteforce
goto solver_solutionCountIn


:solver_startBruteforce
call :matrix create selected_solvings selected_puzzleArray 1
cls
call :displaySudoku selected_solvings
call :matrix delete GUI_color
echo Press any key to start solving...
pause > nul

if /i "!countSolutions!" == "true" (
    call :bruteforceSudoku selected_solvings /sc
) else call :bruteforceSudoku selected_solvings

call :difftime !_endTime! !_startTime!
call :ftime !return!
set "timeTaken=!return!"

set "lastUsed_answerArray=!solution1!"

call :matrix create selected_puzzle selected_puzzleArray 1
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
if defined lastUsed_answerArray (
    call :save2File /p
) else if defined lastUsed_solvingsArray call :save2File /s
goto mainMenu

rem ======================================== Select Sudoku ========================================
:__SELECT__     Select sudoku from file / last used


:selectSudoku [/c]
set "selected_file="
set "selected_name="
set "selected_size="
set "selected_puzzleArray="
set "selected_answerArray="
set "selected_solvingsArray="
pushd "!puzzlePath!"

set "checkSudoku=false"
for %%p in (%*) do if /i "%%~p" == "/c" set "checkSudoku=true"


:selectSudoku_file
set "selected_file="
cls
dir * /b /o:d /p 2> nul
echo=
echo T. Built-in sudoku (This file)
if defined lastUsed_puzzleArray echo L. Last used / entered sudoku
echo 0. Back
echo=
echo Select sudoku file :
set /p "selected_file="
if "!selected_file!" == "0" goto selectSudoku_cleanup
if /i "!selected_file!" == "L" if defined lastUsed_puzzleArray goto selectSudoku_lastUsed
if /i "!selected_file!" == "T" set "selected_file=%~f0"
if exist "!selected_file!" goto selectSudoku_checkFile
echo=
echo File not found
pause > nul
goto selectSudoku_file


:selectSudoku_checkFile
echo=
echo Checking file...
call :stripDQotes selected_file
call :selectSudoku_readFile "!selected_file!"
if not "!listCount!" == "0" goto selectSudoku_list
echo No sudoku data found
pause > nul
goto selectSudoku_file


:selectSudoku_list
set "selectedList=?"
cls
echo Sudoku File    : !selected_file!
echo=
for /l %%n in (1,1,!listCount!) do (
    set "display=  %%n"
    if "!listData%%n!" == "1" (
        echo !display:~-2,2!. [!listSize%%n!] !listName%%n!
    ) else echo !display:~-2,2!. [!listSize%%n!] !listName%%n! [!listData%%n!]
)
set "display="
echo=
echo 0. Back
echo=
echo Select sudoku list:
set /p "selectedList="
set /a "selectedList+=0"
if "!selectedList!" == "0" goto selectSudoku_file
for %%n in (!selectedList!) do if defined listData%%n (
    if "!listData%%n!" == "1" goto selectSudoku_numberOne
    goto selectSudoku_number
) 
goto selectSudoku_list


:selectSudoku_number
set "selectedNumber=?"
cls
echo Sudoku File    : !selected_file!
echo List name      : [!listSize%selectedList%!] !listName%selectedList%!
echo=
echo 0. Back
echo=
echo Input sudoku number (1-!listData%selectedList%!) :
set /p "selectedNumber="
set /a "selectedList+=0"
if "!selectedNumber!" == "0" goto selectSudoku_list
if !selectedNumber! GEQ 1 if !selectedNumber! LEQ !listData%selectedList%! (
    call :selectSudoku_readFile "!selected_file!" !selectedList! !selectedNumber!
    call :checkSelected
)
if "!selectedIsValid!" == "true" goto selectSudoku_cleanup
goto selectSudoku_number


:selectSudoku_numberOne
call :selectSudoku_readFile "!selected_file!" !selectedList! 1
call :checkSelected
if "!selectedIsValid!" == "true" goto selectSudoku_cleanup
goto selectSudoku_list


:selectSudoku_lastUsed
set "selected_name=!lastUsed_name!"
set "selected_size=!lastUsed_size!"
set "selected_file=Unknown"
if defined lastUsed_file set "selected_file=!lastUsed_file!"
set "selected_puzzleArray=!lastUsed_puzzleArray!"
set "selected_answerArray=!lastUsed_answerArray!"
set "selected_solvingsArray=!lastUsed_solvingsArray!"
call :checkSelected
if "!selectedIsValid!" == "true" goto selectSudoku_cleanup
echo Sudoku is invalid
pause > nul
goto selectSudoku_file


:checkSelected
set "selectedIsValid=false"
if not defined selected_puzzleArray goto :EOF
echo=
echo Checking sudoku puzzle...

call :setupBlocks !selected_size!
call :checkArray selected_puzzleArray
if "!arrayIsValid!" == "true" (
    if /i "!checkSudoku!" == "true" if not "!duplicatesFound!" == "0" goto check_error
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


:selectSudoku_cleanup
for /l %%n in (1,1,!listCount!) do (
    for %%t in (Name Data Size) do set "list%%t%%n="
)
set "listCount="
set "checkSudoku="
set "selectedList="
set "selectedNumber="
set "selectedIsValid="
if "!selected_file!" == "0" set "selected_file="
popd
goto :EOF


:selectSudoku_readFile   file [list_number number]
set "listCount=0"
set "currentList=0"
set "isListed=false"
set "selected_puzzleArray="
for /f "usebackq tokens=*" %%o in ("%~f1") do for /f "tokens=1,2* delims= " %%a in ("%%o") do (
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
        if "!isListed!" == "true" set /a "listData%%n+=1"
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
if "!listData%listCount%!" == "0" set /a "listCount-=1"
for %%v in (currentList sizeIsValid isListed newList) do set "%%v="
if "%2,%3" == "," goto :EOF
if defined selected_puzzleArray goto :EOF
echo ERROR: Sudoku #%2:%3 not found in the file.
echo        Maybe file is modified or deleted by another program
goto :EOF

rem ======================================== Select Size ========================================

:selectSize
set "userInput=?"
call :changeScreenSize !defaultScreenWidth! !defaultScreenHeight!
cls
call :getSize list
echo=
echo Default is 3x3
echo=
echo 0. Back
echo=
echo Input sudoku block size  :
set /p "userInput="
if "!userInput!" == "0" goto :EOF
call :getSize !userInput! > nul
call :checkBlockSize !selected_size!
if /i "!sizeIsValid!" == "true" goto :EOF
goto selectSize


:getSize
set "menuCount=0"
set "selected_size="
for %%s in (!availableSizes!) do (
    set /a "menuCount+=1"
    if /i "%~1" == "list" (
        set "menuCount=  !menuCount!"
        for /f "tokens=1-2 delims=Xx" %%a in ("%%s") do (
            set /a "_size=%%a * %%b"
            set "_size=  !_size!"
            echo !menuCount!. [%%s] !_size:~-2,2! x !_size:~-2,2!
        )
    ) else if "%~1" == "!menuCount!" set "selected_size=%%s"
)
set "_size="
goto :EOF

rem ======================================== Action + Log ========================================
:__ACTION_LOG__     User Action + Log


:action   reset|mark|undo|updateLog
if /i "%1" == "RESET" (
    set "actionMatrix=%2"
    set "actionCount=0"
    set "actionLog="
)
if /i "%1" == "MARK" for %%m in (!actionMatrix!) do (
    if "!%%m_%2!" == "%3" goto :EOF
    if "!%%m_%2!,%3" == " ,0" goto :EOF
    set "_markSym="
    for %%s in (!symbolSpaced!) do if /i "%3" == "%%s" set "_markSym=%%s"
    if "%3" == "0" set "_markSym= "
    if defined _markSym (
        set "actionLog=%2-!%%m_%2!-!_markSym!;!actionLog!"
        set "%%m_%2=!_markSym!"
        set /a "actionCount+=1"
        set "_markSym="
    )
)
if /i "%1" == "UNDO" if not "!actionCount!" == "0" (
    for /f "tokens=1-4* delims=-;" %%a in ("!actionLog!") do (
        set "!actionMatrix!_%%a-%%b=%%c"
        set "actionLog=%%e"
        set /a "actionCount-=1"
    )
)
if /i "%1" == "updateLog" (
    set "sideText=!sideText!!log_topBorder!!LF!"
    set "_tempLog=!actionLog!"
    for /l %%n in (1,1,!actionLog_lines!) do if defined _tempLog (
        for /f "tokens=1-4* delims=-;" %%a in ("!_tempLog!") do (
            set "sideText=!sideText!!vBorder! !ALPHABETS:~%%a,1!%%b | %%c -> %%d !vBorder!!LF!"
            set "_tempLog=%%e"
        )
    ) else set "sideText=!sideText!!vBorder!             !vBorder!!LF!"
    set "sideText=!sideText!!log_btmBorder!!LF!"
    set "_tempLog="
)
goto :EOF
rem RESET matrix_name
rem MARK cell_position number
rem UNDO
rem updateLog

rem ======================================== Save to File  ========================================
:__SAVE_TO_FILE__     Save Sudoku to file


:save2File   /P|/S [/Q]
rem /P Save to Puzzle folder
rem /S Save to Saves folder
rem /Q Quiet Mode. Do not prompt user
set "writePath="
set "promptUser=true"
for %%p in (%*) do (
    if /i "%%p" == "/P" set "writePath=!puzzlePath!"
    if /i "%%p" == "/S" set "writePath=!savePath!"
    if /i "%%p" == "/Q" set "promptUser=false"
)
if not defined writePath goto error_unexpected
pushd "!writePath!"
if /i "!promptUser!" == "true" goto save2File_prompt
goto save2File_noPrompt


:save2File_prompt
set "userInput=?"
set /p "userInput=Save to file? Y/N? "
if /i "!userInput!" == "N" goto save2File_cleanup
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
if /i "!selected_file!" == "0" goto save2File_cleanup
call :stripDQotes selected_file
if not exist "!selected_file!" goto save2File_nameIn
echo=
echo File already exist. Sudoku will be added to that file
pause > nul
goto save2File_nameIn


:save2File_nameIn
set "selected_name=!lastUsed_name!"
cls
echo File   : !selected_file!
echo=
echo Name   : !lastUsed_name!
echo Size   : !lastUsed_size!
set /p "=Data   : Puzzle," < nul
if defined lastUsed_answerArray set /p "=!BASE! Answer," < nul
if defined lastUsed_solvingsArray set /p "=!BASE! Solvings," < nul
echo !BS!
echo=
echo Enter nothing to use the name above
echo=
echo Input sudoku name  :
set /p "selected_name="
echo=
goto save2File_write


:save2File_noPrompt
set "selected_file=!lastUsed_file!"
if not defined lastUsed_file set "selected_file=Unknown"
set "selected_name=!lastUsed_name!"
if not defined lastUsed_name (
    set "selected_name=!time: =0!"
    set "selected_name=!selected_name::=!"
    set "selected_name=Saved @!date:~12,2!!date:~4,2!!date:~7,2!_!selected_name:~0,6!"
)
goto save2File_write


:save2File_write
set "saveArray="
for %%a in (puzzle answer solvings) do if defined lastUsed_%%aArray (
    set "saveArray=!saveArray!_!lastUsed_%%aArray!"
) else set "saveArray=!saveArray!_0"
set "saveArray=!saveArray: =0!"
set "saveArray=!saveArray:~1!"

set "writeLabel=true"
if exist "!selected_file!" for /f "usebackq tokens=1,2* delims= " %%a in ("!selected_file!") do (
    if /i "%%a" == "#ENDLIST" set "writeLabel=true"
    if /i "%%a" == "#SUDOKU" if "%%b,%%c" == "!lastUsed_size!,!selected_name!" (
        set "writeLabel=false"
    ) else set "writeLabel=true"
)
if /i "!promptUser!" == "true" echo Saving sudoku [!selected_name!] in [!selected_file!]
(
    if /i "!writeLabel!" == "true" echo #sudoku !lastUsed_size! !selected_name!
    echo !saveArray!
) >> "!selected_file!"
set "writeLabel="
if /i "!promptUser!" == "false" goto save2File_cleanup
echo Done
pause > nul
goto save2File_cleanup


:save2File_cleanup
set "writePath="
set "promptUser="
popd
goto :EOF

rem ======================================== Save / Load State ========================================
:__STATE__     Save / load state of Sudoku


:state   reset|save|load
if /i "%1" == "RESET" (
    for /l %%n in (!stateCount!,-1,1) do (
        for %%v in (array actionLog actionCount) do set "state_%%v%%n="
    )
    set "stateMatrix=%2"
    set "stateCount=0"
)
if /i "%1" == "SAVE" (
    set /a "stateCount+=1"
    if "%2" == "" (
        call :matrix toArray !stateMatrix! state_array!stateCount!
    ) else set "state_array!stateCount!=!%2!"
    set "state_actionLog!stateCount!=!actionLog!"
    set "state_actionCount!stateCount!=!actionCount!"
)
if /i "%1" == "LOAD" (
	if not "!stateCount!" == "0" (
		call :matrix create !stateMatrix! state_array!stateCount! 1
		set "actionLog=!state_actionLog%stateCount%!"
		set "actionCount=!state_actionCount%stateCount%!"
        for %%v in (array actionLog actionCount) do set "state_%%v!stateCount!="
		set /a "stateCount-=1"
	)
)
goto :EOF
rem RESET matrix_name
rem SAVE [array_name]
rem -> Save the provided array to memory instead
rem LOAD

rem ======================================== Solve Sudoku ========================================
:__SOLVE__     Solve Sudoku (not bruteforce)


:solveSudoku   matix_name [methods] [/O]
set "usedMethods=all"
set "solveOnce=false"
if /i "%2" == "/O" (
    set "solveOnce=true"
) else if not "%2" == "" set "usedMethods=%2"
if /i "%3" == "/O" set "solveOnce=true"

rem setupCandidates
for /l %%l in (1,1,!sideLength!) do (
    set "candidateList=!symbolList!"
    for %%n in (!blockList%%l!) do for %%s in (!%1_%%n!) do set "candidateList=!candidateList:%%s= !"
    for %%n in (!blockList%%l!) do set "candidateList_%%n=!candidateList!"
)
set "emptyCells=!totalCells!"
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    for %%s in (!%1_%%i-%%j!) do (
        set /a "emptyCells-=1"
        for %%n in (!rowList%%i!!colList%%j!) do if "!%1_%%n!" == " " set "candidateList_%%n=!candidateList_%%n:%%s= !"
        set "candidateList_%%i-%%j=!candidateMark_%%s!"
    )
)
set "solvedCells="
set "sudokuIsValid=true"

:solveSudoku_loop
rem Eliminate
set "solvedCells= !solvedCells!"
for %%s in (!solvedCells!) do set "solvedCells=!solvedCells: %%s=! %%s"
for %%s in (!solvedCells!) do for /f "tokens=1-3 delims=-" %%i in ("%%s") do (
    set "candidateList_%%i-%%j=!candidateMark_%%k!"
    set "%1_%%i-%%j=%%k"
    set /a "emptyCells-=1"
    for %%c in (!neighbours_%%i-%%j!) do (
        set "candidateList_%%c=!candidateList_%%c:%%k= !"
        if "!candidateList_%%c!" == "!candidateMark_empty!" set "sudokuIsValid=false"
    )
)
set "solvedCells=!solvedCells:~1!"
if defined solvedCells if "!solveOnce!" == "true" goto solveSudoku_done
set "solvedCells="
if /i "!sudokuIsValid!" == "false" goto solveSudoku_error
if "!emptyCells!" == "0" goto solveSudoku_done

rem Solving algorithms starts here


rem Algorithm 1
set "solveMethod=Singles"

for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    if "!%1_%%i-%%j!" == " " (
        set "_remaining=!candidateList_%%i-%%j: =!"
        if defined _remaining (
            if "!_remaining:~1!" == "" set "solvedCells=!solvedCells! %%i-%%j-!_remaining!"
        ) else set "sudokuIsValid=false"
    )
)

if /i "!sudokuIsValid!" == "false" goto solveSudoku_error
if defined solvedCells goto solveSudoku_loop
if !usedMethods! LEQ 1 goto solveSudoku_tooHard


rem Algorithm 2
set "solveMethod=Hidden Singles"

for /l %%i in (1,1,!sideLength!) do for %%l in (rowList%%i colList%%i blockList%%i) do (
    set "symbolSearch= !symbolSpaced!"
    for %%c in (!%%l!) do for %%s in (!%1_%%c!) do set "symbolSearch=!symbolSearch: %%s=!"
    for %%s in (!symbolSearch!) do (
        set "foundCell= "
        for %%c in (!%%l!) do if defined foundCell if not "!candidateList_%%c:%%s=!" == "!candidateList_%%c!" (
            if "!foundCell!" == " " (
                set "foundCell=%%c"
            ) else set "foundCell="
        )
        for %%c in (!foundCell!) do set "solvedCells=!solvedCells! %%c-%%s"
    )
)
set "symbolSearch="
set "foundCell="

if /i "!sudokuIsValid!" == "false" goto solveSudoku_error
if defined solvedCells goto solveSudoku_loop
if !usedMethods! LEQ 2 goto solveSudoku_tooHard


rem Algorithm 3
set "solveMethod=Pairs"

rem set "solveMethod=Naked Pair"

rem naked pairs - remove surroundings
rem 2 cells with the same candidate

rem hidden pairs - identify self
rem 2 candidate only found in 2 cells

rem naked triples
rem 3 cells with total of 3 candidates
rem 3 candidates found only in 3 cells

rem eliminate [list - exeption] [number]

rem 528F7B9CG43E61ADE6000D5400007900C1D4000GF970000007000000D506800000G030000D09E000BD0100F9004000507A000000000000D0005ED000BG0000090B0000A010F2D0G0G36A00C2409D0F0000200G0070A50E000500000060BG942A04005FE00BDA0000D908023B0FG00A00AGF50400C6000B000EB2C0G001540DF8

if /i "!sudokuIsValid!" == "false" goto solveSudoku_error
if defined solvedCells goto solveSudoku_loop
if !usedMethods! LEQ 3 goto solveSudoku_tooHard

rem No Algorithm Left

:solveSudoku_tooHard
set "solveMethod=Unsolvable"
:solveSudoku_error
:solveSudoku_done
goto :EOF


:setupCandidates   matix_name
for /l %%l in (1,1,!sideLength!) do (
    set "candidateList=!symbolList!"
    for %%n in (!blockList%%l!) do for %%s in (!%1_%%n!) do set "candidateList=!candidateList:%%s= !"
    for %%n in (!blockList%%l!) do set "candidateList_%%n=!candidateList!"
)
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    for %%s in (!%1_%%i-%%j!) do (
        for %%n in (!rowList%%i!!colList%%j!) do if "!%1_%%n!" == " " set "candidateList_%%n=!candidateList_%%n:%%s= !"
        set "candidateList_%%i-%%j=!candidateMark_%%s!"
    )
)
goto :EOF

rem ======================================== Bruteforce Sudoku ========================================
:__BRUTEFORCE__     Anything related to bruteforce


:generateAnswer   matix_name
rem Return
set /a "bruteforceLimit= 2 * !totalCells!"
set "maxSolutionCount=1"
call :matrix set %1 " "
set /a "initEmpty=!totalCells! - !initialGivens!"
set /p "=!CL!Initializing..." < nul
goto bruteforceSudoku_setup


:bruteforceSudoku   matix_name [/SC | /C]
set "bruteforceLimit=-1"
set "maxSolutionCount=1"
set "initEmpty=!totalCells!"
if /i "%2" == "/SC" set "maxSolutionCount=!solutionCountLimit!"
if /i "%2" == "/C"  set "maxSolutionCount=2"
set /p "=!CL!Solving..." < nul
goto bruteforceSudoku_setup


:bruteforceSudoku_setup
set "bruteforceCount=0"
set "bruteforceDepth=0"
set "solutionCount=0"
for /l %%n in (1,1,!solutionCountLimit!) do set "solution%%n="
set "_startTime=!time!"

rem setupCandidates
for /l %%l in (1,1,!sideLength!) do (
    set "candidateList=!symbolList!"
    for %%n in (!blockList%%l!) do for %%s in (!%1_%%n!) do set "candidateList=!candidateList:%%s= !"
    for %%n in (!blockList%%l!) do set "candidateList_%%n=!candidateList!"
)
set "emptyCells=!totalCells!"
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    for %%s in (!%1_%%i-%%j!) do (
        set /a "emptyCells-=1"
        for %%n in (!rowList%%i!!colList%%j!) do if "!%1_%%n!" == " " set "candidateList_%%n=!candidateList_%%n:%%s= !"
        set "candidateList_%%i-%%j=!candidateMark_%%s!"
    )
)
set "solvedCells="
set "sudokuIsValid=true"


:bruteforceSudoku_solve
set "prevEmptyCell=!emptyCells!"

rem Algorithm 1 - Singles
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        if "!%1_%%i-%%j!" == " " (
            set "_remaining=!candidateList_%%i-%%j: =!"
            if defined _remaining (
                if "!_remaining:~1!" == "" for %%s in (!_remaining!) do (
                    set "candidateList_%%i-%%j=!candidateMark_%%s!"
                    set "%1_%%i-%%j=%%s"
                    set /a "emptyCells-=1"
                    for %%n in (!neighbours_%%i-%%j!) do (
                        set "candidateList_%%n=!candidateList_%%n:%%s= !"
                        if "!candidateList_%%n!" == "!candidateMark_empty!" goto bruteforceSudoku_backtrack
                    )
                )
            ) else goto bruteforceSudoku_backtrack
        )
    )
)
if not "!emptyCells!" == "!prevEmptyCell!" goto bruteforceSudoku_solve

rem Algorithm 2 - Hidden Singles
for /l %%i in (1,1,!sideLength!) do (
    for %%l in (rowList%%i colList%%i blockList%%i) do (
        set "symbolSearch= !symbolSpaced!"
        for %%c in (!%%l!) do for %%s in (!%1_%%c!) do set "symbolSearch=!symbolSearch: %%s=!"
        for %%s in (!symbolSearch!) do (
            set "foundCell= "
            for %%c in (!%%l!) do if defined foundCell if not "!candidateList_%%c:%%s=!" == "!candidateList_%%c!" (
                if "!foundCell!" == " " (
                    set "foundCell=%%c"
                ) else set "foundCell="
            )
            for %%c in (!foundCell!) do (
                set "candidateList_%%c=!candidateMark_%%s!"
                set "%1_%%c=%%s"
                set /a "emptyCells-=1"
                for %%n in (!neighbours_%%c!) do (
                    set "candidateList_%%n=!candidateList_%%n:%%s= !"
                    if "!candidateList_%%n!" == "!candidateMark_empty!" goto bruteforceSudoku_backtrack
                )
            )
        )
    )
)

set "symbolSearch="
set "foundCell="

rem No Algorithm Left
if "!emptyCells!" == "0" goto bruteforceSudoku_solveDone
if not "!emptyCells!" == "!prevEmptyCell!" goto bruteforceSudoku_solve


:bruteforceSudoku_findNext
if "!bruteforceCount!" == "!bruteforceLimit!" goto bruteforceSudoku_done
if !emptyCells! GTR !initEmpty! goto bruteforceSudoku_initialize

rem Find cell with least candidates (MRV)
set "cellPos=?-?"
set "leastCandidateNum=!sideLength!"
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    if "!%1_%%i-%%j!" == " " (
        set "_remaining=!candidateList_%%i-%%j: =!"
        for /l %%n in (!sideLength!,-1,0) do if "!_remaining:~%%n,1!" == "" set "candidateNum=%%n"
        if !candidateNum! LSS !leastCandidateNum! (
            set "cellPos=%%i-%%j"
            set "leastCandidateNum=!candidateNum!"
        )
    )
)
rem Select a possible candidate for that cell
set "trySymbol=!trySymbol%bruteforceDepth%!"
for %%c in (!cellPos!) do set "_remaining=!candidateList_%%c: =!"
if "!trySymbol!" == "" (
    set "trySymbol= !_remaining:~0,1!"
) else for /l %%n in (0,1,!sideLength0!) do if "!trySymbol!" == "!_remaining:~%%n,1!" (
    set "trySymbol=!_remaining:~%%n,2!"
)
set "trySymbol=!trySymbol:~1!"
if not defined trySymbol goto bruteforceSudoku_backtrack

:bruteforceSudoku_search
rem Try filling the cell with a possible candidate
set "trySymbol!bruteforceDepth!=!trySymbol!"
call :matrix toArray %1 testArray!bruteforceDepth!

rem Set value and eliminate candidates
set "%1_!cellPos!=!trySymbol!"
set /a "emptyCells-=1"
for %%c in (!cellPos!) do for %%s in (!trySymbol!) do (
    set "candidateList_%%c=!candidateMark_%%s!"
    for %%n in (!neighbours_%%c!) do if "!%1_%%n!" == " " set "candidateList_%%n=!candidateList_%%n:%%s= !"
)

set /a "bruteforceCount+=1"
set /a "bruteforceDepth+=1"

if !emptyCells! GTR !initEmpty! (
    set /a "_filledCells=!totalCells! - !emptyCells!"
    set /p "=!CL!Initializing... !_filledCells!/!initialGivens!" < nul
) else set /p "=!CL!Bruteforcing... #!bruteforceCount!:!bruteforceDepth! | Solutions: !solutionCount!" < nul
goto bruteforceSudoku_solve


:bruteforceSudoku_initialize
rem Pick random cell and fill with a random candidate
call :randCellList %1 /e 1
set "cellPos=!cellList:~1!"
for %%c in (!cellPos!) do (
    set "_remaining=!candidateList_%%c: =!"
    for /l %%n in (!sideLength!,-1,0) do if "!_remaining:~%%n,1!" == "" set "candidateNum=%%n"
    set /a "_position=!random! %% !candidateNum!"
    for %%r in (!_position!) do set "trySymbol=!_remaining:~%%r,1!"
)
goto bruteforceSudoku_search


:bruteforceSudoku_solveDone
set /a "solutionCount+=1"
call :matrix toArray %1 solution!solutionCount!
if "!solutionCount!" == "!maxSolutionCount!" goto bruteforceSudoku_done

:bruteforceSudoku_backtrack
if "!bruteforceDepth!" == "0" goto bruteforceSudoku_done
set "trySymbol!bruteforceDepth!="
set "testArray!bruteforceDepth!="
set /a "bruteforceDepth-=1"
call :matrix create %1 testArray!bruteforceDepth! 1

rem setupCandidates
for /l %%l in (1,1,!sideLength!) do (
    set "candidateList=!symbolList!"
    for %%n in (!blockList%%l!) do for %%s in (!%1_%%n!) do set "candidateList=!candidateList:%%s= !"
    for %%n in (!blockList%%l!) do set "candidateList_%%n=!candidateList!"
)
set "emptyCells=!totalCells!"
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    for %%s in (!%1_%%i-%%j!) do (
        set /a "emptyCells-=1"
        for %%n in (!rowList%%i!!colList%%j!) do if "!%1_%%n!" == " " set "candidateList_%%n=!candidateList_%%n:%%s= !"
        set "candidateList_%%i-%%j=!candidateMark_%%s!"
    )
)
set "sudokuIsValid=true"
goto bruteforceSudoku_findNext


:bruteforceSudoku_done
set "_endTime=!time!"
set /p "=!CL!" < nul

rem Delete variables
for /l %%n in (!bruteforceDepth!,-1,0) do (
    set "testArray%%n="
    set "trySymbol!bruteforceDepth!="
)
if "!solutionCount!" == "0" goto :EOF
call :matrix create %1 solution1 1
goto :EOF

rem ======================================== GUI Builder ========================================
:__GUI_BUILDER__     Initialize GUI


:setupGrid
if "!blockWidth!x!blockHeight!" == "!currentGridSize!" (
    if "!gridStyle!" == "!currentGridStyle!" (
        call :changeScreenSize !screenWidth! !screenHeight!
        goto :EOF
    )
)

rem Delete all previous grids
for /l %%n in (1,1,!sideText_height!) do set "sideText%%n="

rem Settings
set "bottom_textLines=4"
set "sideText_width=25"   [GEQ 16]
set /a "actionLog_lines=!blockWidth! + !blockHeight!"
set "sideText_minHeight=2 + !actionLog_lines! + 7"

rem Change GUI size
set "currentGridSize=!blockWidth!x!blockHeight!"
set "currentGridStyle=!gridStyle!"

rem Build sudoku and candidate GUI
call :gridStyle_char_!gridStyle!
for %%v in (
    _smallGridLine _smallBorderLine
    GUI_topBorder GUI_midBorder GUI_btmBorder GUI_midGrid
    _spaceVB _spaceVG
    GUI_colNumbers GUI_sideSpacing
    log_topBorder log_btmBorder
) do set "%%v="
set "_spaceL=  "
for /l %%n in (1,1,3) do (
    set   "_smallGridLine=!_smallGridLine!!hGrid!"
    set "_smallBorderLine=!_smallBorderLine!!hBorder!"
)
set "_gridLine=!_smallGridLine!"
set "_borderLine=!_smallBorderLine!"
for /l %%n in (2,1,!blockWidth!) do (
    set   "_gridLine=!_gridLine!!cGrid!!_smallGridLine!"
    set "_borderLine=!_borderLine!!hBorder!!_smallBorderLine!"
)
for /l %%n in (2,1,!blockHeight!) do (
    set "GUI_topBorder=!GUI_topBorder!!uEdge!!_borderLine!"
    set "GUI_midBorder=!GUI_midBorder!!cBorder!!_borderLine!"
    set "GUI_btmBorder=!GUI_btmBorder!!dEdge!!_borderLine!"
    set   "GUI_midGrid=!GUI_midGrid!!vBorder!!_gridLine!"
)
set "GUI_topBorder=!_spaceL!!ulCorner!!_borderLine!!GUI_topBorder!!urCorner!"
set "GUI_midBorder=!_spaceL!!lEdge!!_borderLine!!GUI_midBorder!!rEdge!"
set "GUI_btmBorder=!_spaceL!!dlCorner!!_borderLine!!GUI_btmBorder!!drCorner!"
set   "GUI_midGrid=!_spaceL!!vBorder!!_gridLine!!GUI_midGrid!!vBorder!"
call :strlen vBorder
for /l %%n in (1,1,!return!) do set "_spaceVB=!_spaceVB! "
call :strlen vGrid
for /l %%n in (1,1,!return!) do set "_spaceVG=!_spaceVG! "
set "GUI_colNumbers=!_spaceL!!_spaceVB!"
for /l %%n in (1,1,!sideLength!) do (
    set "_number=%%n  "
    set "GUI_colNumbers=!GUI_colNumbers! !_number:~0,2!"
    set /a "_isBorder=%%n %% !blockWidth!"
    if "!_isBorder!" == "0" (
        set "GUI_colNumbers=!GUI_colNumbers!!_spaceVB!"
    ) else set "GUI_colNumbers=!GUI_colNumbers!!_spaceVG!"
)

rem Calculate grid size and screen size
call :strlen GUI_colNumbers
set "GUI_width=!return!"
set /a "GUI_height= 2 + 2 * !sideLength!"
set /a "screenWidth=!GUI_width! + !sideText_width! + 3"
set /a "screenHeight=!GUI_height! + !bottom_textLines!"
set /a "minScreenWidth=!sideText_width! * 11 / 5"
set /a "minScreenHeight=!sideText_minHeight! + !bottom_textLines!"
if !screenWidth!  LSS !minScreenWidth!  set  "screenWidth=!minScreenWidth!"
if !screenHeight! LSS !minScreenHeight! set "screenHeight=!minScreenHeight!"
set /a "GUI_hSpacing= (!screenWidth! - !GUI_width! - !sideText_width! - 1) / 2 "
set /a "GUI_vSpacing= (!screenHeight! - !GUI_height! - !bottom_textLines!) / 2"
if !GUI_vSpacing! LSS 0 set "GUI_vSpacing=0"
if !GUI_hSpacing! LSS 0 set "GUI_hSpacing=0"
set /a "sideText_height= !GUI_vSpacing! * 2 + !GUI_height!"

set /a "showStep_width= !GUI_width! + !totalCells! - 3 * !sideLength! + 2"
set /a "showStep_height= 2 * !GUI_height! - !sideLength! + !blockWidth! + 3"
if !showStep_width! LSS !screenWidth! set "showStep_width=!screenWidth!"
if !showStep_height! LSS !screenHeight! set "showStep_height=!screenHeight!"
call :changeScreenSize !screenWidth! !screenHeight!

rem Build spacings
for /l %%n in (1,1,!GUI_hSpacing!) do set "GUI_sideSpacing=!GUI_sideSpacing! "
set "GUI_lineSpacing=!GUI_sideSpacing!!GUI_sideSpacing!"
for /l %%n in (1,1,!GUI_width!) do set "GUI_lineSpacing=!GUI_lineSpacing! "

rem Build log viewer GUI
for /l %%n in (1,1,13) do (
    set "log_topBorder=!log_topBorder!!hBorder!"
    set "log_btmBorder=!log_btmBorder!!hBorder!"
)
set "log_topBorder=!ulCorner!!log_topBorder!!urCorner!"
set "log_btmBorder=!dlCorner!!log_btmBorder!!drCorner!"

rem Create files for color GUI
pushd "!tempPath!"
set /p "=!BS!!BS!" < nul > "   _" 2> nul
for %%s in (X !symbolSpaced!) do (
    set /p "=!BS!!BS!" < nul > " %%s _" 2> nul
)
popd

rem Delete variables
for %%v in (
    _smallGridLine _smallBorderLine _gridLine _borderLine
    _spaceVB _spaceVG _spaceL _number _isBorder currentText
    hGrid cGrid hBorder cBorder uEdge dEdge lEdge rEdge
    ulCorner urCorner dlCorner drCorner
    minScreenWidth minScreenHeight sideText_minHeight
) do set "%%v="
goto :EOF


rem currentGridSize     Current applied grid size
rem currentGridStyle    Current applied grid style
rem screenWidth         Optimal screen width for current grid size
rem screenHeight        Optimal screen height for current grid size


:changeScreenSize   width height
mode %1,%2

rem Setup Clear Line
set "CL="
call :getOS /e
if !return! GEQ 100 (
    for /l %%n in (2,1,%1) do set "CL=!CL! "
    set "CL=!BASE!!CR!!CL!!CR!"
) else for /l %%n in (2,1,%1) do set "CL=!CL!!BS!"
goto :EOF

rem ======================================== Display GUI ========================================
:__GUI_DISPLAY__     Display GUI (with its helper functions)


:displaySudoku   matix_name [/H (Horizontal spacing only)]
pushd "!tempPath!"
setlocal
set "_currentLine=1"

rem Top Vertical Spacing
if /i not "%2" == "/H" for /l %%n in (1,1,!GUI_vSpacing!) do for %%n in (!_currentLine!) do (
    echo=!GUI_lineSpacing!!sideText%%n!
    set /a "_currentLine+=1"
)

rem Sudoku GUI
echo !GUI_sideSpacing!!GUI_colNumbers!!GUI_sideSpacing!!sideText%_currentLine%!
set /a "_currentLine+=1"
echo !GUI_sideSpacing!!GUI_topBorder!!GUI_sideSpacing!!sideText%_currentLine%!
set /a "_currentLine+=1"
for /l %%i in (1,1,!sideLength!) do (
    rem Line with numbers
    set /p "=!BASE!!GUI_sideSpacing!!ALPHABETS:~%%i,1! !vBorder!" < nul
    for /l %%j in (1,1,!sideLength!) do (
        if /i "!useColor!" == "true" (
            findstr /l /v /a:!GUI_color_%%i-%%j! "." " !%1_%%i-%%j! _" nul 2> nul
        ) else set /p "=!BASE! !%1_%%i-%%j! " < nul
        set /a "_isBorder=%%j %% !blockWidth!"
        if "!_isBorder!" == "0" (
            set /p "=!BASE!!vBorder!" < nul
        ) else set /p "=!BASE!!vGrid!" < nul
    )
    for %%n in (!_currentLine!) do echo !BASE!!GUI_sideSpacing!!sideText%%n!
    set /a "_currentLine+=1"
    
    rem Line without numbers
    for %%n in (!_currentLine!) do (
        set /a "_isBorder=%%i %% !blockHeight!"
        if "!_isBorder!" == "0" (
            if "%%i" == "!sideLength!" (
                echo !GUI_sideSpacing!!GUI_btmBorder!!GUI_sideSpacing!!sideText%%n!
            ) else echo !GUI_sideSpacing!!GUI_midBorder!!GUI_sideSpacing!!sideText%%n!
        ) else echo !GUI_sideSpacing!!GUI_midGrid!!GUI_sideSpacing!!sideText%%n!
    )
    set /a "_currentLine+=1"
)

rem Bottom Vertical Spacing
if /i not "%2" == "/N" for /l %%n in (1,1,!GUI_vSpacing!) do for %%n in (!_currentLine!) do (
    echo=!GUI_lineSpacing!!sideText%%n!
    set /a "_currentLine+=1"
)
endlocal
popd
goto :EOF


:displayCandidates   matix_name
rem !candidateColor!
pushd "!tempPath!"
setlocal
for /l %%i in (1,1,!sideLength!) do (
    set /p "=!BASE!!ALPHABETS:~%%i,1! !vBorder!" < nul
    for /l %%j in (1,1,!sideLength!) do (
        if /i "!useColor!" == "true" (
            set /p "=!BS!!BS!" < nul > "!%1_%%i-%%j!_" 2> nul
            findstr /l /v /a:!GUI_color_%%i-%%j! "." "!%1_%%i-%%j!_" nul 2> nul
        ) else set /p "=!BASE!!%1_%%i-%%j!" < nul
        set /a "_isBorder=%%j %% !blockWidth!"
        if "!_isBorder!" == "0" (
            set /p "=!BASE!!vBorder!" < nul
        ) else set /p "=!BASE!!vGrid!" < nul
    )
    echo=
    set /a "_isBorder=%%i %% !blockHeight!"
    if "!_isBorder!" == "0" echo=
)
endlocal
popd
goto :EOF


:parseSideText
if "!sideText!" == "!currentText!" goto :EOF
for /l %%n in (1,1,!sideText_height!) do set "sideText%%n="
set "currentText=!sideText!"
if not defined currentText goto :EOF
set "_currentLine=1"
for %%w in (!sideText_width!) do for /f "delims=" %%t in ("!currentText!") do (
    set "_currentText=%%t"
    for /l %%i in (1,1,!sideText_height!) do if defined _currentText if !_currentLine! LEQ !sideText_height! (
        set "sideText!_currentLine!=!_currentText:~0,%%w!"
        set "_currentText=!_currentText:~%%w!"
        set /a "_currentLine+=1"
    )
)
set "_currentLine="
set "_currentText="
goto :EOF


:sudokuInfo   matix_name
call :matrix count %1 " " 
set /a "cellGivens= !totalCells! - !return!"
set "sideText=!sideText!Sudoku Puzzle Information!LF!"
set "sideText=!sideText!Name    : !selected_name!!LF!"
set "sideText=!sideText!Givens  : !cellGivens!!LF!"
goto :EOF

rem ======================================== Data Setup ========================================
:__DATA_SETUP__     Initialize constants and validate data (no sudoku data modification)


:calcValidSizes
set "validSizes="
set "availableSizes="
for /l %%i in (2,1,4) do for /l %%j in (2,1,4) do (
    set /a "_chars= %%i * %%j"
    if !_chars! LEQ 16 set "validSizes=!validSizes! %%ix%%j"
    if %%i GEQ %%j set "availableSizes=!availableSizes! %%ix%%j"
)
if /i "!allowAllSizes!" == "true" set "availableSizes=!validSizes!"
set "_chars="
goto :EOF


:checkBlockSize   Size(MxN)
set "sizeIsValid=false"
for %%s in (!validSizes!) do (
    if /i "%~1" == "%%s" set "sizeIsValid=true"
)
goto :EOF


:setupBlocks   block_size
if "%1" == "!currentBlockSize!" goto :EOF

rem Delete all previous blocks
for /l %%i in (1,1,!sideLength!) do (
    set "rowList%%i="
    set "colList%%i="
    set "blockList%%i="
    for /l %%j in (1,1,!sideLength!) do (
        set "neighbours_%%i-%%j="
    )
)
for %%s in (!symbolSpaced!) do set "candidateMark_%%s="

rem We assume that the parameters is valid
set "currentBlockSize=%1"
for /f "tokens=1,2 delims=x" %%a in ("%1") do (
    set /a "blockWidth=%%a"
    set /a "blockHeight=%%b"
)

rem Calculate sudoku size
set /a "sideLength=!blockWidth! * !blockHeight!"
set /a "totalCells=!sideLength! * !sideLength!"
set /a "minimumGivens=!totalCells! / 5 + 1"
set /a "initialGivens=!totalCells! * 15 / 100 + 1"
set /a "minCustomGivens=!totalCells! * 4 / 10 + 1"
set /a "maxCustomGivens=!totalCells! - !sideLength!"

rem Special needs for loop starting with 0
set /a "sideLength0=!sideLength! - 1"

rem Clear all variables
for /l %%n in (1,1,!sideLength!) do (
    set "rowList%%n="
    set "colList%%n="
    set "blockList%%n="
    for /l %%n in (1,1,!sideLength!) do (
        set "neighbours_%%i-%%j="
    )
)

rem Define cell blocks
set "blockNumber=1"
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do (
        set "rowList%%i=!rowList%%i! %%i-%%j"
        set "colList%%j=!colList%%j! %%i-%%j"
        set "neighbours_%%i-%%j=!blockNumber!"
        for %%n in (!blockNumber!) do set "blockList%%n=!blockList%%n! %%i-%%j"
        set /a "isBorder=%%j %% !blockWidth!"
        if "!isBorder!" == "0" set /a "blockNumber+=1"
    )
    set /a "isBorder=%%i %% !blockHeight!"
    if not "!isBorder!" == "0" set /a "blockNumber-=!blockHeight!"
)
set "isBorder="

rem Create neighbour list
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    for %%b in (!neighbours_%%i-%%j!) do set "neighbours_%%i-%%j=!rowList%%i!!colList%%j!!blockList%%b! "
    for %%c in (!neighbours_%%i-%%j!) do set "neighbours_%%i-%%j=!neighbours_%%i-%%j: %%c = !%%c "
    set "neighbours_%%i-%%j=!neighbours_%%i-%%j: %%i-%%j = !"
)

rem Create symbol list
set "symbolList=!SYMBOLS:~1,%sideLength%!"
set "symbolSpaced="
for /l %%n in (0,1,!sideLength0!) do set "symbolSpaced=!symbolSpaced! !symbolList:~%%n,1!"

rem Create single candidates for solver
set "_spaces="
for %%s in (!symbolSpaced!) do (
    set "candidateMark_%%s=!_spaces!%%s"
    set "_spaces=!_spaces! "
)
set "candidateMark_empty=!_spaces!"
for %%s in (!symbolSpaced!) do (
    set "candidateMark_%%s=!candidateMark_%%s!!_spaces!"
    set "candidateMark_%%s=!candidateMark_%%s:~0,%sideLength%!"
)
set "_spaces="
goto :EOF


rem sideLength          blockWidth * blockHeight
rem symbolList          List of symbols
rem symbolSpaced        List of symbols, seperated by a space
rem SYMBOLS             Complete list of symbols with a space at the beginning
rem ALPHABETS           Complete list of alphabets with a dot at the beginning
rem rowList[x]          List of cells in that row
rem colList[x]          List of cells in that column
rem blockList[x]        List of cells in that block
rem neighbours_[x,y]    List of neighbours of that cell


:loadDifficulty
set "difficultyList="
for /f "usebackq tokens=1,2* delims=_ " %%a in ("%~f0") do (
    if /i "%%a" == ":difficulty" (
        set "difficultyList=!difficultyList! %%b"
        set "difficultyName_%%b=%%c"
        if "%%c" == "" set "difficultyName=<Undefined>"
    )
)
goto :EOF


:loadGridStyle
set "gridStyleList="
for /f "usebackq tokens=1-4 delims=_ " %%a in ("%~f0") do (
    if /i "%%a_%%b" == ":gridStyle_char" (
        set "gridStyleList=!gridStyleList! %%c"
        set "gridStyle_name_%%c=%%d"
        if "%%d" == "" set "gridStyle_name_%%c=<Undefined>"
    )
)
for /f "tokens=1 delims= " %%a in ("!gridStyleList!") do set "gridStyle=%%a"
goto :EOF

rem ======================================== Data Operations ========================================
:__DATA_OPERATIONS__     Operations that creates / modify sudoku data


:matrix   create|set|copy|swap|color|toArray|delete|count|compare
if /i "%1" == "create" (
    if "!%~3!" == "" goto :EOF
    set "_tempArray=!%3!"
)
if /i "%1" == "toArray" set "%3="
if /i "%1" == "count"   set "return=0"
if /i "%1" == "compare" set "return=0"
for /l %%i in (1,1,!sideLength!) do for /l %%j in (1,1,!sideLength!) do (
    if /i "%1" == "create" (
        set "%2_%%i-%%j=!_tempArray:~0,%4!"
        set "_tempArray=!_tempArray:~%4!"
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
    if /i "%1" == "compare" if not "!%2_%%i-%%j!" == "!%3_%%i-%%j!"  set /a "return+=1"
    if /i "%1" == "color"   if not "!%2_%%i-%%j!" == " "    set "GUI_color_%%i-%%j=%3"
)
goto :EOF
rem CREATE  matix_name source_array data_size
rem SET     matix_name value
rem COPY    source_matix destination_matrix
rem SWAP    matix_name value1 value2
rem COLOR   matix_name color
rem toArray source_matix destination_array
rem DELETE  matix_name
rem COUNT   matix_name value
rem COMPARE matix_name matix_name


:checkArray   array_name
set "arrayIsValid=false"

rem Convert all '0's to space
set "%1=!%1:?= !"
for %%c in ( _ 0 . ) do set "%1=!%1:%%c= !"

set "_tempArray=!%1!@"
set "errorMsg=Array is too short"
if "!_tempArray:~%totalCells%!" == "" goto :EOF

set "errorMsg=Array is too long"
if not "!_tempArray:~%totalCells%!" == "@" goto :EOF

set "errorMsg=Array contains invalid symbols"
set "_tempArray=!_tempArray: =!"
set "_tempArray2=!_tempArray!"
for %%a in (!symbolSpaced!) do set "_tempArray2=!_tempArray2:%%a=!"
if not "!_tempArray2!" == "@" goto :EOF

set "arrayIsValid=true"

set "errorMsg=Too few givens for a valid sudoku"
if "!_tempArray:~%minimumGivens%,1!" == "" goto :EOF

set "errorMsg="
call :matrix create _temp1 %1 1
call :matrix set GUI_color !defaultColor!
call :checkDuplicate _temp1
call :matrix delete _temp1
goto :EOF


:checkDuplicate   matix_name
for /l %%i in (1,1,!sideLength!) do (
    for /l %%j in (1,1,!sideLength!) do  for /l %%n in (%%j,1,!sideLength!) do if not "%%j" == "%%n" (
        if not "!%1_%%i-%%j!" == " " if "!%1_%%i-%%j!" == "!%1_%%i-%%n!" (
            set "GUI_color_%%i-%%j=!errorColor!"
            set "GUI_color_%%i-%%n=!errorColor!"
        )
        if not "!%1_%%j-%%i!" == " " if "!%1_%%j-%%i!" == "!%1_%%n-%%i!" (
            set "GUI_color_%%j-%%i=!errorColor!"
            set "GUI_color_%%n-%%i=!errorColor!"
        )
    )
    for %%a in (!blockList%%i!) do for %%b in (!blockList%%i!) do (
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


:checkCellcode   cell_code
set "cellCode=%1"
set "rowNumber="
for /l %%n in (1,1,!sideLength!) do if not defined rowNumber (
    if /i "!cellCode:~0,1!" == "!ALPHABETS:~%%n,1!" (
        set "rowNumber=%%n"
        set /a "colNumber=!cellCode:~1! + 0" 2> nul
    )
    if /i "!cellCode:~-1,1!" == "!ALPHABETS:~%%n,1!" (
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


:randCellList   matix_name /F|/E [list_size]
set "cellList="
set "tempList="
set "listCount=0"
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
rem /F Filled cells only
rem /E Empty cells only


:move   up|down|left|right|next|back
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
set "cellRow="
set "cellCol="
goto :EOF

rem ======================================== Function Library ========================================
:__FUNCTION_LIBRARY__     Functions imported from Function Library


:rand   minimum maximum
set /a "return=!random!*65536 + !random!*2 + !random!/16384"
set /a "return%%= (%~2) - (%~1) + 1"
set /a "return+=%~1"
exit /b


:strlen  variable_name
set "return=0"
if defined %1 (
    for %%n in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        set /a "return+=%%n"
        for %%l in (!return!) do if "!%1:~%%l,1!" == "" set /a "return-=%%n"
    )
    set /a return+=1
)
exit /b


:difftime   end_time [start_time] [/n]
set "return=0"
for %%t in (%1:00:00:00:00 %2:00:00:00:00) do for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
    set /a "return+=24%%a %% 24 *360000 +1%%b*6000 +1%%c*100 +1%%d -610100"
    set /a "return*=-1"
)
if /i not "%3" == "/n" if !return! LSS 0 set /a "return+=8640000"
exit /b


:ftime   time_in_centiseconds
set /a "_remainder=%~1 %% 8640000"
set "return="
for %%n in (360000 6000 100 1) do (
    set /a "_result=!_remainder! / %%n"
    set /a "_remainder%%= %%n"
    set "_result=?0!_result!"
    set "return=!return!!_result:~-2,2!:"
)
set "return=!return:~0,-4!.!return:~-3,2!"
exit /b


:sleep   milliseconds
set /a "return=!loopSpeed! * %* / 10"
for /l %%n in (1,1,!return!) do call
exit /b


:speedtest
if not defined loopSpeed set "loopSpeed=300"
set "return="
for %%s in (50) do for /l %%n in (1,1,12) do if not "!return!" == "%%s" (
    set "_startTime=!time!"
    call :sleep %%s * 10
    set "return=0"
    for %%t in (!time!:00:00:00:00 !_startTime!:00:00:00:00) do for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
        set /a "return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100"
        set /a "return*=-1"
    )
    if !return! LSS 0 set /a "return+=8640000"
    set /a "loopSpeed=!loopSpeed! * %%s / !return!"
)
set "_startTime="
exit /b


:deleteTempvar
for /f "usebackq tokens=1 delims==" %%v in (`set`) do (
    set ".varname=%%v"
    if "!.varname:~0,1!" == "_" set "%%v="
)
set ".varname="
exit /b


:watchvar   [/i] [/c] [/w]
rem Temp folder address
for %%f in ("!tempPath!\watchvar") do (
    if not exist "%%~f" md "%%~f"
    pushd "%%~f"
)
setlocal

rem Write variable list to file
for %%f in ("varList") do (
    set > "%%~f_raw.txt"
    set "filename_rawTxt=%%~f_raw.txt"
    set "filename_nowTxt=%%~f_now.txt"
    set "filename_oldTxt=%%~f_old.txt"
    set "filename_newTxt=%%~f_new.txt"
    set "filename_delTxt=%%~f_del.txt"
    
    set "filename_rawHex=%%~f_raw.hex"
    set "filename_nowHex=%%~f_now.hex"
    set "filename_oldHex=%%~f_old.hex"
    set "filename_newHex=%%~f_new.hex"
    set "filename_delHex=%%~f_del.hex"
    
    set "filename_log=%%~f.log"
)

rem Get variable name
if exist "!filename_rawHex!" del /f /q "!filename_rawHex!"
certutil -encodehex "!filename_rawTxt!" "!filename_rawHex!" > nul
(
    set "readLine=0"
    set "inputHex=0d 0a"
    for /f "usebackq delims=" %%o in ("!filename_rawHex!") do (
        set "input=%%o"
        set "inputHex=!inputHex! !input:~5,48!"
        set /a "readLine+=1"
        if "!readLine!" == "160" call :watchvar_parseHex
    )
    call :watchvar_parseHex
) > "!filename_nowHex!"
if exist "!filename_nowTxt!" del /f /q "!filename_nowTxt!"
certutil -decodehex "!filename_nowHex!" "!filename_nowTxt!" > nul

rem Parse parameter
set "initialize=false"
set "countOnly=false"
set "writeToFile=false"
if not exist "!filename_oldHex!" set "initialize=true"
for %%p in (%*) do (
    if /i "%%p" == "/I" set "initialize=true"
    if /i "%%p" == "/C" set "countOnly=true"
    if /i "%%p" == "/W" set "writeToFile=true"
)
set "writeMode="
if /i "!writeToFile!" == "true" set "writeMode= ^>^> !filename_log!"

rem Count variable
set "variableCount=0"
for /f "usebackq tokens=*" %%o in ("!filename_nowHex!") do set /a "variableCount+=1"

rem Display variable count (if initialize only)
if /i "!initialize!" == "true" (
    echo Initial variables: !variableCount! %writeMode%
    goto watchvar_cleanup
)

rem Find new variables
set "newCount=0"
call 2> "!filename_newHex!"
for /f "usebackq tokens=*" %%s in ("!filename_nowHex!") do (
    set "found=false"
    for /f "usebackq tokens=*" %%t in ("!filename_oldHex!") do if "%%s" == "%%t" set "found=true"
    if /i "!found!" == "false" (
        echo=%%s
        set /a "newCount+=1"
    )
) >> "!filename_newHex!"
if exist "!filename_newTxt!" del /f /q "!filename_newTxt!"
certutil -decodehex "!filename_newHex!" "!filename_newTxt!" > nul

rem Find deleted variables
set "delCount=0"
call 2> "!filename_delHex!"
for /f "usebackq tokens=*" %%s in ("!filename_oldHex!") do (
    set "found=false"
    for /f "usebackq tokens=*" %%t in ("!filename_nowHex!") do if "%%s" == "%%t" set "found=true"
    if /i "!found!" == "false" (
        echo=%%s
        set /a "delCount+=1"
    )
) >> "!filename_delHex!"
if exist "!filename_delTxt!" del /f /q "!filename_delTxt!"
certutil -decodehex "!filename_delHex!" "!filename_delTxt!" > nul

if "!countOnly!" == "true" (
    echo Variables: !variableCount! [+!newCount!/-!delCount!] %writeMode%
) else (
    echo Variables: !variableCount!
    rem Display new variables
    if not "!newCount!" == "0" (
        set /p "=[+!newCount!] " < nul 
        for /f "usebackq tokens=*" %%o in ("!filename_newTxt!") do set /p "=%%o " < nul 
        echo=
    )

    rem Display deleted variables
    if not "!delCount!" == "0" (
        set /p "=[-!delCount!] " < nul 
        for /f "usebackq tokens=*" %%o in ("!filename_delTxt!") do set /p "=%%o " < nul 
        echo=
    )
) %writeMode%
goto watchvar_cleanup

:watchvar_parseHex
set "inputHex=.!inputHex!"
set "inputHex=!inputHex:  = !"
set "inputHex=!inputHex:0d 0a=_@:!"
set "inputHex=!inputHex:3d=_#:!"
set "inputHex=!inputHex: =!"
set "inputHex=!inputHex:_= !"
set "inputHex=!inputHex:~1!"
set "lastInput="
for %%h in (!inputHex!) do (
    if defined lastInput (
        echo !lastInput! 0d0a
        set "lastInput="
    )
    if /i "%%~dh" == "@:" set "lastInput=%%~nh"
)
set "inputHex="
if defined lastInput set "inputHex=@:!lastInput!"
set "readLine=0"
goto :EOF

:watchvar_cleanup
rem Cleanup
for %%t in (Txt Hex) do (
    if exist "!filename_old%%t!" del /f /q "!filename_old%%t!"
    ren "!filename_now%%t!" "!filename_old%%t!"
)
echo= %writeMode%
endlocal
popd
exit /b


:stripDQotes   variable_name
set _tempvar="!%~1:~1,-1!"
if "!%~1!" == "!_tempvar!" set "%~1=!%~1:~1,-1!"
set "_tempvar="
exit /b


:setupEndlocal
if "!!" == "" exit /b 1
set LF=^
%=REQUIRED=%
%=REQUIRED=%
set ^"NL=^^^%LF%%LF%^%LF%%LF%^^"
set ^"endlocal=for %%# in (1 2) do if %%# == 2 (%NL%
    setlocal EnableDelayedExpansion%NL%
    set "_setCommand==!LF!"%NL%
    for %%v in (!_args!) do set "_setCommand=!_setCommand!%%~v=!%%~v!!LF!"%NL%
    for /F "delims=" %%c in ("!_setCommand!") do if "%%c" == "=" (%NL%
        endlocal%NL%
        endlocal%NL%
    ) else set "%%c"%NL%
) else set _args="
exit /b 0


:getOS   [/n | /e]
for /f "tokens=4-5 delims=. " %%i in ('ver') do set "return=%%i.%%j"
if /i "%~1" == "/N" (
    if "!return!" == "10.0" set "return=Windows 10"
    if "!return!" == "6.3" set "return=Windows 8.1"
    if "!return!" == "6.2" set "return=Windows 8"
    if "!return!" == "6.1" set "return=Windows 7"
    if "!return!" == "6.0" set "return=Windows Vista"
    if "!return!" == "5.2" set "return=Windows XP 64-Bit"
    if "!return!" == "5.1" set "return=Windows XP"
    if "!return!" == "5.0" set "return=Windows 2000"
)
if /i "%~1" == "/E" set "return=!return:.=!"
exit /b

rem ======================================== GUI Pack List ========================================
:__GUI_LIST__     Sudoku GUI Packs


rem ======================================== ASCII GUI Pack ========================================

:gridStyle_char_ASCII   Default
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


:gridStyle_splashScreen_ASCII
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

rem ======================================== UTF8 GUI Pack ========================================

:gridStyle_char_UTF8   Plain
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


:gridStyle_splashScreen_UTF8
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

rem ======================================== Difficulty List ========================================
:__DIFFICULTY_LIST__     Sudoku Difficulty List


:difficulty_beginner   Beginner
set "methodsUsed=2"
set /a "minGivens=!totalCells! * 2 / 3"
set /a "maxGivens=!totalCells! * 3 / 4"
call :rand "!totalCells! * 2 / 3"   "!totalCells! * 3 / 4"
set "targetGivens=!return!"
goto :EOF


:difficulty_easy   Easy
set "methodsUsed=2"
set /a "minGivens=!totalCells! * 2 / 5 + 1"
set /a "maxGivens=!totalCells! * 2 / 3"
call :rand "!totalCells! * 4 / 9"   "!totalCells! * 5 / 9"
set "targetGivens=!return!"
goto :EOF


:difficulty_minEasy   Not so easy
set "methodsUsed=2"
set /a "minGivens=!totalCells! / 5 + 1"
set /a "maxGivens=!totalCells! * 2 / 5 + 1"
set "targetGivens=0"
goto :EOF


::difficulty_medium   Medium
set "methodsUsed=2"
set /a "minGivens=!totalCells! / 5 + 1"
set /a "maxGivens=!totalCells! * 2 / 5 + 1"
set "targetGivens=0"
goto :EOF


:difficulty_random   Random
set "methodsUsed=BF"
set /a "minGivens=!totalCells! / 5 + 1"
set /a "maxGivens=!totalCells! * 2 / 5 + 1"
set "targetGivens=0"
goto :EOF

rem ======================================== Built-in Sudoku ========================================
:__SUDOKU_LIST__     Built-in Sudoku List


rem Add new list:
rem #SUDOKU [Size] [Name]
rem ; Comments

#sudoku 3x3 Easy
900843610810700400000001832067090243008030170500074060750029000080615720201087596_925843617813762459674951832167598243498236175532174968756429381389615724241387596_0
004003000702508091100792050590204300003819542001056870240037068007080904009001000_954163287732548691186792453598274316673819542421356879245937168317685924869421735_0
003009450920060083004502000708000094030007120502090070291605830050078200407203900_163789452925164783874532619718326594639457128542891376291645837356978241487213965_0
084000000091050600020364809017200935902580006000901207260173050178400360543000700_684719523391852674725364819817246935932587146456931287269173458178495362543628791_0
049008301001260000086001002060090215000010000910700684650083009100920500497150823_249578361371269458586341792763894215824615937915732684652483179138927546497156823_0
409070821800502003320800650700025189206010030095403060500238070678004002030067540_459376821861542793327891654743625189286719435195483267514238976678954312932167548_0
730502601596013870010706900002170000680200159100960004400001008021000403000840000_738592641596413872214786935942175386687234159153968724479321568821657493365849217_0
070316005034502081005900000219834057040005300306000008080600030090050800500000210_978316425634572981125948763219834657847165392356729148782691534491253876563487219_0
010060000942005080050024003400650008706403502520701690005038200234017809000006301_317869425942375186658124973491652738786493512523781694165938247234517869879246351_0
400380002080700604700294810930000006546020087108005300370002400050039001092040560_415386972289751634763294815937418256546923187128675349371562498654839721892147563_0
800032005047080032000076009509601000000800001701094806975200013218043060400715098_896132745147589632352476189589621374634857921721394856975268413218943567463715298_0

#sudoku 3x3 Not so easy
080006900007010002002007010090000520050800000200003400006042007570000009000000000_185236974947518632632497815798164523354829761261753498816942357573681249429375186_0
070000060060000035001000020000040008807050200000900000480072000300080007009300100_273495861968217435541836729625741398897653214134928576486172953312589647759364182_0
400600000000073008000009400003060000005800704700000910900020050000000001070000306_427658139519473628638219475143967582295831764786542913961324857354786291872195346_0
269000400007000000000208000080300006090000708702100000000014090030600000100800070_269731485847965132513248967481379526396452718752186349678514293934627851125893674_0
010050000970010008000607050300000002000500900000080074500400609060300000008000020_613854297975213468284697153396741582847532916152986374521478639769325841438169725_0
000000040570003000000000501000002906003600100000079035410000602060005000090000007_182596743574213869639784521751342986923658174846179235415837692367925418298461357_0
000085007001000000700040800060030008038060001009200004000007005600009000500000010_946385127381792546725146893467931258238564971159278364892617435613459782574823619_0
070204060008000003400036080683050000000000000005000039000000207000040000000071946_379284561268517493451936782683759124924163875715428639846395217197642358532871946_0
000030168000002000000000050000800009000094030001007000040700000060020003870060200_724539168518642397396178452432816579657294831981357624245783916169425783873961245_0
920500000300400000000900340007630000000020680000000100079000001001300025000010800_924563718318472569756981342187635294593124687642798153279856431861347925435219876_0

#sudoku 3x3 Medium / Hard
........8.3.2........4.5376..1.5..97.8...954....6....2.4.......2....7.396.9......
.3.29......7.......8.1.32.74....6....2..3......5....8..4.........68..9..5.1.2..6.
2.....1.5..8.97........3.8..94.....6..5..43.....369.......8..1..4...1.23......6.7
......5.6....94.....98.5...3.27......1...2.6.......4.7.8.3.62.5.4...93...........
.1......95......747.....3.....36.....3.....8.4..9..25.9...5......6.97...37.8.4..6
.......399.485.....75..9......5..6.21...9...7...34.8..8.67.......1...7.3........6
.......399.485.....75..9......5..6.21...9...7...34.8..8.67.......1...7.3........6
97..5...2.............18.6.....4..3.45...76.91.6........9...48...718.2......2....

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

#sudoku 4x3 Easy
90300A002050780090B006000A001504B09307000B000A04B00C008A03150610005700C0400871A09032000049C8006A0B9A2635C40880070040000000C90013A20730B4A7005C09_943B8A6C2751785193B246ACCA261574B8935783CB916A24B94C628A7315A612345789CB4C6871AB9532237549C81B6A1B9A2635C47882A75C4931B665C9B813A24731B4A7265C89_0
09800B0350000B0007000C003175A6C0940B08072A010509C009800002B05A4200B00003B09070850000000A0196780006000000000087C4000AB30205A0C37000141203584BC970_498C1B2357A6AB2647591C383175A6C8942B68B72A3145C9C3198564A2B75A429CB76183B49172853A6C2C3AB1967845765834AC2B9187C4691AB35295ABC37286141263584BC97A_0
09A3C4016502064052090008B002600A13002060000040CA0034B600900007000000308000160000205C0C0A052B740300073006A81B1290000700B60000AB6580900A5B0802C034_89A3C4B1657276415239BCA8B5C2678A1349216589734BCAA834B65C9127C7B921A436853B167A48295C9C8A152B746354273C96A81B129843C75AB6437CAB6582916A5B9812C734_0

#sudoku 4x3 Not so easy
0B000080090000429007B0011C00000000700080060400000000700000B040C0AB10500020A00C4B000600B0080000A00316000070000001C0000A6780000006030404000A0510C0_3B7A418C6925684295A7BC311C59B362A478A18B5634C792963572C841BA42C7AB19568327A83C4B951659B4687132ACC316295A784BB521C4938A678A9C17B6235474638A251BC9_0
B409000005060200010630000000000000800000A040507300000C014200006B320700A0000090800000050000027B09002A000010000010000090050006C0080000890407100A00_B439782AC5167285B1C6349A61AC5439B7822891A64B5C735A738C91426B4C6B325789A11BC79583A62435481A627BC9962A4B7C1358C71263A498B5A356C9B8214789B427156A3C_0
803010B00000000080A00607B4200700000000000A009003060040000B050070B02000000A0034090C1600007100800B0350080000A9C10000060A78A0000000030C000900000050_873A16B459C2951C83A246B7B426C795318A5BC26A81974316A84973CB254973B52CA8617A8B34592C162C94716A853B635128CB74A9C1459236BA78A2675B48139C38B9AC176254_0

#sudoku 4x4 Easy
C1004E9B0F73000050030000000000009B000130D04C0620000GA00D005813001GCF50E800900B600005030701800F0D00790CD10G300E026D0820097000000A2CB0000400F58000GE10800A376902B0000A00BC002G0931300D70GF0C1000044020000E00D0B00G00000BC209A6057E060B100000043000D00094A0B8002CF6_C1624E9BGF73A8D55AD3CF861BE2G7499B87G135DA4CE62FEF4GA72D965813CB1GCF5AE8429D7B63B2E56347C18A9FGDA479BCD16G3F5E826D382GF975BEC41A2CB63914ADF58GE7GE148D5A3769F2BC75FAE6BC842GD931389D72GFEC1B6A54492CF86E53D7B1AG83G1DBC2F9A6457EF6AB157G2EC43D98D75E94A3B8G12CF6_0
70809F0G0052BDE005D00A0C07603G000000D07B00002C000ACG6000D0B001800000B94F2G000010GD0F08000B79C50003B0010540FD900G92E0C70D50A06000CG400000001B79D206050000000C00B1090B10C070E0G040D000G0F70004E6C0002000000005100C400052900CD0F70001600C0090285A0E0C000GA000008300_74839F1GCA52BDE6B5D24A8C176E3GF91F96DE7B843G2C5AEACG6523D9BF4187675AB94F2GC3DE18GD1F283E6B79C5A483BCA1654EFD927G92E4C7GD58A16B3FCG4E865AF31B79D2267534E9GD8CAFB1F9AB1DC275E6G843D831GBF7A294E6C5AB27F3D8E6G5149C4EG852913CDAF76B316D7CB49F285AGE5CF9EGA6B147832D_0
070A0000030020000800019000G07FA4F0D100000004830C492000G007CA10057000931E0D0F08020098F520EA00C0B000C0A0006840300GB03000407010EA600D000A00FB760038A500020800D10000600300000G58F0008G00000302E0B156E180BCD040200G79CA000630B107D5FE93000082000060010F071E0000004080_G76A845C13FD2E9B385C619D2EGB7FA4FBD127EA569483GC492E3FGB87CA16D576AG931ECDBF58421498F526EA3GC7BD5ECFADB76842391GB23DC84G7915EA6F2DE95AC1FB76G438A5FBG26834D19CE76C13EB749G58FD2A8G74D9F3A2ECB156E186BCDF4523AG79CAG24639B187D5FE93457G82DFAE6BC1DFB71EA5GC694283_0

#sudoku 4x4 Not so easy
02000B9C003E6100E600005400007900C0D4000GF070000000000000D506800000G030000009E000BD0100F9004000507A000000000000D0005ED000BG0000090B0000A010F2D0G0036A00C240000F0000200G0070A00E00000000006000940004005FE000DA00000908023B0FG00A00AG000400C6000B000002C000015400F8_528F7B9CG43E61ADE63G1D548A2C79BFC1D4A86GF97B53E297ABF32ED5168C4G4FG63785ADC9E21BBDC12EF93748AG567A93G6B152EFC8D4285EDC4ABG61F7398B47E9A613F2D5GCG36AB5C24E9D1F871C294GDF78A5BE63F5ED81736CBG942A347C5FE82BDAG691D918623BEFG74AC5AGF5941DC6832B7E6EB2CAG791543DF8_0
0080760000005900D060400030000G00000000000000C3009000005010G427FE00GC00E9006015004019030A700D000006005C0GF00000EA000E0B07A000F0203000009E0B800FD700EBC00000050030G00F05000000EA00000D0070090C000060000005C0B030010G0200000148D00000580004D0709000000029F3500E4000
0D0006000C47900A02G190E060B07F38006000000000CE00B80AC0000000G0506FBC0007010050000G87E0B040600C00000000F0000E0009E0300000900G0100400030002016000080F0000BD0000A1505D02A080703000G0B000000005806ED06000C000A0D0493F0000E90008000D2002000050E008000000000700G040000
#ENDLIST

#sudoku 3x3 Escargot
1....7.9..3..2...8..96..5....53..9...1..8...26....4...3......1..4......7..7...3..

#sudoku 3x3 Arto Inkala
8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..

#sudoku 3x3 SudokuWiki Unsolvable #28
600008940900006100070040000200610000000000200089002000000060005000000030800001600

#end


rem ======================================== Change Log ========================================
:__CHANGE_LOG__     Version History


rem  3.1.5 (2018-02-08)
rem  - Improved script documentation
rem  
rem  3.1.4 (2017-08-17)
rem  Only bug-fixes
rem  - Fixed regression (from code readability improvements in 3.1.3):
rem      - imported sudoku cannot be used or saved to file
rem      - bug in action log display
rem      - sudoku default name not saved to file
rem  - Fixed bug where sudoku with no name cannot be selected
rem  - Fixed clear line bug again (the fix in 3.1.2 clear line only works in windows 10!)
rem  - Fixed bug when viewing sudoku arrays
rem  
rem  3.1.3 (2017-08-09)
rem  - Fixed regression of candidate color replaced by solving color when using solver
rem  - Fixed regression of import sudoku answer
rem  - Reworked import sudoku answer
rem  - Reworked select size menu
rem  - Improved some code readability
rem  - Re-picked colors to improve contrast
rem  
rem  3.1.2 (2017-07-17)
rem  - Fixed clear line bug on windows 10
rem  - Fixed solving steps
rem  - Added option to show candidates when solving
rem  - Added option to generate custom sudoku
rem  - Reworked difficulty levels for generating sudoku
rem  - Added more built-in sudoku
rem  - Bruteforce sudoku slightly faster
rem  
rem  3.1 (2016-08-19)
rem  - Refactor several labels and codes
rem  - Reworked several menu
rem  
rem  3.0 (2016-08-19)
rem  - Color GUI but it's quite slow because... it is batch script :)
rem  - Fully support 4x4 to 16x16 sudoku size
rem  - Major rework in code
rem  - 2 Grid styles (ASCII art style and normal text style)
rem  - Improved generate sudoku speed (2-4x faster)
rem  - Added support for windows 10
rem  - Added built-in sudoku packs
rem  
rem  2.1 (2015-10-10)
rem  - Added support for 4x4 and 6x6 sudoku (with minor display problems)
rem  - Few menu redesigns
rem  - Improve bruteforce speed (2-3x faster)
rem  
rem  2.0 (2014)
rem  - Merged all menus (Play, Import, View, Solve) to one file
rem  - Major rework in code
rem  - Redesigned some menus
rem  - Bruteforce solver uses bruteforce and solve method (took less than 5mins to solve Arto Inkala)
rem  - Added solution count feature
rem  - Can now generate Sudoku (easy and random difficulty only)
rem  
rem  1.0 (2013-08-23)
rem  - Initial version
rem  - Each menu is written in seperate script
rem  - Bruteforce solver uses pure bruteforce method (took 1h 30min to solve Arto Inkala)
