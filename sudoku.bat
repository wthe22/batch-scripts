:entry_point
@goto main


rem ############################################################################
rem Metadata
rem ############################################################################

:metadata [return_prefix]
set "%~1name=sudoku"
set "%~1version=3.3a"
set "%~1author=wthe22"
set "%~1license=The MIT License"
set "%~1description=Sudoku"
set "%~1release_date=01/09/2023"   :: MM/DD/YYYY
set "%~1url=https://winscr.blogspot.com/2013/08/sudoku.html"
set "%~1download_url=https://raw.githubusercontent.com/wthe22/batch-scripts/master/sudoku.bat"
exit /b 0


:about
setlocal EnableDelayedExpansion
call :metadata
if not defined preferred.style set "preferred.style=lines_n_pipes"
call :Style_!preferred.style!.splash_screen
echo=
echo Updated on !release_date!
echo=
echo Feel free to use, share, or modify this script for your projects :)
echo Visit http://winscr.blogspot.com/ for more scripts^^!
echo=
echo=
echo Copyright (C) 2013 by !author!
echo Licensed under !license!
endlocal
exit /b 0


rem ############################################################################
rem License
rem ############################################################################

:license
echo MIT License
echo=
echo Copyright 2013 wthe22
echo=
echo Permission is hereby granted, free of charge, to any person obtaining a
echo copy of this software and associated documentation files (the "Software"),
echo to deal in the Software without restriction, including without limitation
echo the rights to use, copy, modify, merge, publish, distribute, sublicense,
echo and/or sell copies of the Software, and to permit persons to whom the
echo Software is furnished to do so, subject to the following conditions:
echo=
echo The above copyright notice and this permission notice shall be included in
echo all copies or substantial portions of the Software.
echo=
echo THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
echo OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
echo FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
echo AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
echo LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
echo FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
echo DEALINGS IN THE SOFTWARE.
exit /b 0


rem ############################################################################
rem Documentation
rem ############################################################################

:doc.help
echo usage:
echo    sudoku
echo        Run sudoku in interactive mode
echo=
echo    sudoku (-h^|--help)
echo        Show this help
echo=
echo    sudoku -c :^<label^> [arguments] ...
echo        Call the specified label with arguments
echo=
echo    sudoku solve ^<block_size^> ^<sudoku^>
echo        Solve a sudoku
exit /b 0


rem ############################################################################
rem Configurations
rem ############################################################################

:config
call :config.default
call :config.preference
exit /b 0


:config.default
rem Default/common configurations. DO NOT MODIFY
set "data_dir=%~dp0\data\sudoku\"
set "tmp_dir=!temp!\BatchScript\Sudoku\"

set "default_console_width=80"
set "default_console_height=25"

set "solution_count_limit=5"

set "preferred.style=lines_n_pipes"   [lines_n_pipes, boxchar]
set "use_color=true"   [true, false]

rem See "COLOR /?" for more info
set   "default_color=07"    Default color for text
set    "puzzle_color=07"    Puzzle / Givens
set  "solvings_color=03"    Solvings that user/solver entered
set "highlight_color=4E"    Highlighted cells in solver
set "candidate_color=02"    Candidate for answer in solver
set     "error_color=0C"    Error in solvings
exit /b 0


:config.preference
rem Configurations to change/override
:: set "tmp_dir=%~dp0tmp\tmp"
rem Uncomment this if you have display problems with box character style
:: set "default_codepage=437"
exit /b 0


rem ############################################################################
rem Changelog
rem ############################################################################

:changelog
::  A small release to add CLI functionality and slighty improve usage.
::
::  - Add subcommand to solve sudoku
::  - Add CLI help message
::  - Improve color scheme
::  - Fix reload script not working
::  - Fix console size being too small when solving 2x2 with steps
::  - Fix solver fail to detect some case of invalid sudoku
::  - Add more checking logic and hint when playing sudoku
exit /b 0


rem ############################################################################
rem Debug Tool
rem ############################################################################

:exception.raise
@echo=
@echo=
@for %%t in (%*) do @ 1>&2 echo %%~t
@echo=
@echo Press any key to exit...
@pause > nul
@exit


rem ############################################################################
rem Main
rem ############################################################################

:main
@if ^"%1^" == "-c" @goto subcommand.call
@if ^"%1^" == "--module" @goto subcommand.call.legacy
@setlocal EnableDelayedExpansion EnableExtensions
@echo off
if ^"%1^" == "-h" goto doc.help
if ^"%1^" == "--help" goto doc.help
if ^"%1^" == "" (
    call :main_script
) else call :subcommand.%*
@exit /b


:main.reload
endlocal
goto main


:main_script
call :metadata SOFTWARE.
call :config

title !SOFTWARE.description! !SOFTWARE.version!
cls
echo !SOFTWARE.description! !SOFTWARE.version!
echo=
echo Loading...

for %%p in (
    tmp_dir
    data_dir
) do if defined %%p if not exist "!%%p!" md "!%%p!"

cd /d "!data_dir!"

rem Additional Settings
rem bottomText_lines @ GUI Builder
rem Side_text.width @ GUI Builder
rem Action.display_lines @ GUI Builder
rem sideText_minHeight @ GUI Builder

if defined default_codepage chcp !default_codepage!
color !default_color!
call :Style.load
call :Display.change_size !default_console_width! !default_console_height!

rem Setup splash screen
call :capchar DQ
cls
call :Style_!preferred.style!.splash_screen

set "puzzle_path=Puzzles\"
set "save_path=Saves\"
for %%p in (
    puzzle_path
    save_path
) do if not exist "!%%p!" md "!%%p!"

set "ALPHABET=_ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "SYMBOL=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "con_width=!default_console_width!"
set "con_height=!default_console_height!"
set "applied.style="
set "applied.size="

call :Display.evaluate_color
call :Block_size.init_list 4 4
call :Block_size.setup 0x0
call :State.reset
call :Difficulty.load
call :capchar ESC BASE BACK DQ
call :watchvar --initialize > nul 2> nul
call :main_menu
rd /s /q "!tmp_dir!" > nul 2> nul
exit /b


:subcommand.call -c <label> [arguments]
@(
    setlocal DisableDelayedExpansion
    call set command=%%*
    setlocal EnableDelayedExpansion
    for /f "tokens=1* delims== " %%a in ("!command!") do @(
        endlocal
        endlocal
        call %%b
    )
)
@exit /b


:subcommand.call.legacy --module=lib <label> [arguments]
@if not ^"%2^" == "lib" @(
    1>&2 echo%0: Operation not supported
)
@(
    setlocal DisableDelayedExpansion
    call set command=%%*
    setlocal EnableDelayedExpansion
    for /f "tokens=2* delims== " %%a in ("!command!") do @(
        endlocal
        endlocal
        call %%b
    )
)
@exit /b


:subcommand.solve <block_size> <sudoku>
@setlocal EnableDelayedExpansion EnableExtensions
@echo off
call :metadata SOFTWARE.
call :config

if not exist "!tmp_dir!" md "!tmp_dir!"
cd /d "!tmp_dir!" 2> nul || cd /d "!tmp!"

for %%v in (block_size puzzle_string) do set "%%v="
call :argparse ^
    ^ "#1:store                 :block_size" ^
    ^ "#2:store                 :puzzle_string" ^
    ^ -- %* || exit /b 2
set "SYMBOL=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
call :capchar BASE BACK DQ
call :get_con_size con_width con_height
call :clear_line_macro CL !con_width!
call :Block_size.init_list 4 4
call :Block_size.check !block_size! || (
    1>&2 echo Invalid block size
    exit /b 2
)
call :Block_size.setup !block_size!
call :Array.check puzzle_string || (
    exit /b 2
)
call :Matrix.create solvings puzzle_string 1
set "start_time=!time!"
call :Bruteforce solvings 1>&2
set "end_time=!time!"
call :difftime time_taken !end_time! !start_time!
call :ftime time_taken !time_taken!
echo !CL!Done in !time_taken! with !search_count! guesses 1>&2
call :Matrix.to_array solvings answer_string
echo !answer_string!
exit /b 0


rem ############################################################################
rem User Interfaces
rem ############################################################################

:ui
exit /b 0

rem ================================ Main Menu ================================

:main_menu
call :Display.change_size !default_console_width! !default_console_height!
:main_menu.loop
set "user_input="
title !SOFTWARE.DESCRIPTION! !SOFTWARE.VERSION!
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
set /p "user_input="
if "!user_input!" == "0" exit /b 0
if "!user_input!" == "1" call :Play
if "!user_input!" == "2" call :Import
if "!user_input!" == "3" call :View
if "!user_input!" == "4" call :Solver
if "!user_input!" == "5" call :Generator
if /i "!user_input!" == "A" (
    cls
    call :about
    pause
)
if /i "!user_input!" == "S" goto Settings.menu
goto main_menu.loop


:Settings.menu
set "user_input="
cls
echo 1. Grid style          !Style_%preferred.style%.name!
echo 2. Use Color           !use_color!
echo=
echo R. Reload script      A fresh start is always good
echo U. Update script
echo 0. Back
echo=
echo What do you want to change?
set /p "user_input="
echo=
if "!user_input!" == "0" goto main_menu
if "!user_input!" == "1" call :Settings.Style.menu
if "!user_input!" == "2" call :Settings.toggle_color
if /i "!user_input!" == "D" call :Settings.debug
if /i "!user_input!" == "U" goto Settings.update_script
if /i "!user_input!" == "R" goto main.reload
goto Settings.menu


:Settings.Style.menu
set "user_input="
set "selected.style="
cls
echo Current grid style : !Style_%preferred.style%.name!
echo=
call :menuopts.list Style.list "$n. {Style_$i.name}"
echo=
echo 0. Back
echo=
echo Input style number:
set /p "user_input="
if "!user_input!" == "0" goto :EOF
call :menuopts.get selected.style Style.list "!user_input!" && (
    goto Settings.Style.preview
)
goto Settings.Style.menu


:Settings.Style.preview
echo=
echo Preview:
echo=

setlocal
call :Style_!selected.style!.charset
set "hB=!hBorder!"
set "vB=!vBorder!"
set "hG=!hLine!"
echo !ulCorner!!hB!!hB!!hB!!hB!!hB!!hB!!hB!!uEdge!!hB!!hB!!hB!!urCorner!
echo !vB! 1 !vLine! 2 !vB! !vLine! !vB!
echo !vB!!hG!!hG!!hG!!cLine!!hG!!hG!!hG!!vB!!hG!!cLine!!hG!!vB!
echo !vB! 3 !vLine! 4 !vB! !vLine! !vB!
echo !vB!!hB!!hB!!hB!!hB!!hB!!hB!!hB!!cBorder!!hB!!hB!!hB!!vB!
echo !vB!!hG!!hG!!hG!!cLine!!hG!!hG!!hG!!vB!!hG!!cLine!!hG!!vB!
echo !dlCorner!!hB!!hB!!hB!!hB!!hB!!hB!!hB!!dEdge!!hB!!hB!!hB!!drCorner!
echo=
endlocal
call :Input.yesno -m "Confirm? [y/n] " || goto Settings.Style.menu
echo=
set "preferred.style=!selected.style!"
echo Grid Style successfully changed
pause > nul
goto Settings.Style.menu


:Settings.debug
cls
echo Debug Informations
echo=
echo Temporary path: !tmp_dir!
echo=
call :wait.calibrate
echo=
call :watchvar --name
echo=
pause
goto :EOF


:Settings.toggle_color
if "!use_color!" == "true" (
    set "use_color=false"
) else set "use_color=true"
exit /b 0


:Settings.update_script
cls
echo This process requires internet connection
echo=
echo Note:
echo - Updating will REPLACE current script with the newer version
echo - Saved puzzle, answers, and solving in data folder won't be deleted
echo=
call :updater "%~f0" && (
    echo Script will exit
    exit 0
)
goto Settings.menu

rem ================================ Play Sudoku ================================

:Play
:Play.select_sudoku
call :select_sudoku --validate
if not defined selected.puzzle_array goto :EOF

call :Display.setup
call :Matrix.create selected.solvings selected.puzzle_array 1
call :Matrix.set applied.color "!Color_solvings!"
call :Color.filled_cells selected.solvings "!Color_puzzle!"
call :State.reset selected.solvings
call :Action.reset selected.solvings
if defined selected.solvings_array call :State.save selected.solvings_array
set "_solved_sudoku="
set "start_time=!time!"

:Play.update
call :Color.set --revert
call :Side_text.add --clear
call :Action.update_list
call :Side_text.add ^
    "[Z] Undo" "[X] Exit" "[D] Check / Done" "[T] Toggle Color" ^
    "[S] Save" "[L] Load [!State.count!]" "[H] Hint" " " ^
    "[0] Erase" "[C] Cancel"

:Play.sudoku
set "user_input="
cls
call :Display.sudoku selected.solvings
set /p "user_input=Input cell code   : "
if /i "!user_input!" == "X" goto Play.quit
if /i "!user_input!" == "D" goto Play.check
if /i "!user_input!" == "T" call :Settings.toggle_color
if /i "!user_input!" == "H" call :Play.show_hint
if /i "!user_input!" == "S" call :State.save & goto Play.update
if /i "!user_input!" == "L" call :State.load & goto Play.update
if /i "!user_input!" == "Z" call :Action.undo & goto Play.update
call :Cell.decode cell_index "!user_input!" || goto Play.sudoku

if "!applied.color_%cell_index%!" == "!Color_puzzle!" (
    echo That cell is a part of the puzzle...
    pause > nul
    goto Play.sudoku
)

set "user_input="
set /p "user_input=Input number      : "
if /i "!user_input!" == "C" goto Play.sudoku
call :Action.mark !cell_index! !user_input! || goto Play.sudoku
goto Play.update


:Play.check
< nul set /p "=Checking..."
call :Matrix.get_duplicates selected.solvings
call :Matrix.unmark_duplicates applied.color "!Color_puzzle!"
call :Color.set --revert --error !duplicate_list!
call :Matrix.count empty_cells selected.solvings " "

call :Solve selected.solvings 0 --once


if /i "!is_valid!" == "true" (
    if "!empty_cells!" == "0" goto Play.solved
    echo !CL!Seems good, no duplicates found...
) else (
    if "!duplicates_count!" == "0" (
        echo !CL!Oops^^! There are cells with no candidates...
    ) else (
        echo !CL!Oops^^! There are duplicates found...
        if /i not "!use_color!" == "true" (
            echo TIPS: Use color GUI to show errors
        )
    )
)
pause > nul
goto Play.sudoku


:Play.show_hint
< nul set /p "=Please wait..."
call :Matrix.get_duplicates selected.solvings
call :Matrix.unmark_duplicates applied.color "!Color_puzzle!"
call :Color.set --revert --error !duplicate_list!
if not "!duplicates_count!" == "0" (
    echo !CL!Oops^^! There is something wrong...
    if /i not "!use_color!" == "true" echo TIPS: Use color GUI to show errors
    pause > nul
    goto :EOF
)
call :Matrix.copy selected.solvings _temp
call :Solve _temp --once
call :Matrix.delete _temp
call :Color.set --highlight !error_cells!
if /i "!is_valid!" == "true" (
    if "!solve_method!" == "Unsolvable" (
        echo !CL!No hint available. Sudoku is too hard for solver
    ) else echo !CL!Try looking for !solve_method!
) else (
    echo !CL!There are cells with no candidates
)
pause > nul
goto :EOF


:Play.solved
call :difftime time_taken !time! !start_time!
call :ftime time_taken !time_taken!
call :Matrix.create selected.puzzle selected.puzzle_array 1
call :Side_text.add --clear ^
    --info:selected.puzzle " " ^
    "Start time: !start_time!" " " ^
    "Solved in !time_taken!"
call :Matrix.delete selected.puzzle
call :Matrix.to_array selected.solvings last_used.answer_array
set "_solved_sudoku=true"

cls
call :Display.sudoku selected.solvings
echo Congratulations^^! You solved the sudoku.
pause > nul
goto Play.quit


:Play.quit
set "start_time="
call :Matrix.delete applied.color
call :Matrix.to_array selected.solvings last_used.solvings_array
call :Matrix.delete selected.solvings
call :State.reset
if not defined _solved_sudoku (
    echo Solvings saved to memory. You can load it later.
)
call :save2file --solvings
goto :EOF

rem ================================ Import Sudoku ================================

:Import
for %%v in (puzzle answer solvings) do set "selected.%%v_array="
:Import.select_size
call :select_size || goto :EOF
echo=
echo Preparing...
call :Block_size.setup !selected.size!
call :Display.setup
set "_key_layout= XRTHZIJKL0!SYMBOL:~1,%grid_size%!"
set "Import.type=puzzle"
call :Side_text.add --clear ^
    "Duplicates  : N/A" ^
    "Givens      : N/A" " " ^
    "[Z] Undo" "[0] Erase" "[H] Check / Done" "[T] Toggle Color" "[R] Reset" "[X] Exit" " " ^
    "Use IJKL to move" " " ^
    "Characters:" "!SYMBOL:~1,%grid_size%!"

:Import.setup
call :Import.reset_matrix

:Import.select_method
set "user_input="
cls
echo 1. One by one with GUI
echo 2. Array form
if /i "!Import.type!" == "answer" echo 3. Skip this step
echo=
echo 0. Back
echo=
echo Choose !Import.type! input method:
set /p "user_input="
if "!user_input!" == "0" (
    if "!Import.type!" == "puzzle" goto Import.select_size
    set "Import.type=puzzle"
    goto Import.select_method
)
if "!user_input!" == "1" goto Import.update_matrix
if "!user_input!" == "2" goto Import.array
if /i "!Import.type!" == "answer" if "!user_input!" == "3" goto Import.done
goto Import.select_method


:Import.array
set "user_input="
cls
echo 1. Input from left to right (A1 to A!grid_size!)
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
echo Input the !selected.size! !Import.type! array:
set /p "selected.!Import.type!_array="
echo=
if "!selected.%Import.type%_array!" == "0" goto Import.select_method
call :Array.check selected.!Import.type!_array || (
    pause > nul
    goto Import.array
)
if "!Import.type!" == "answer" call :Array.match selected.answer_array selected.puzzle_array || (
    echo The answer did not match the puzzle
    pause > nul
)
call :Import.reset_matrix
call :Matrix.create imported selected.!Import.type!_array 1
goto Import.update_matrix


:Import.update_matrix
call :Matrix.get_duplicates imported
if "!Import.type!" == "answer" (
    call :Matrix.unmark_duplicates applied.color "!Color_puzzle!"
)
call :Color.set --revert --error !duplicate_list!
call :Matrix.count empty_cells imported " "
set /a "given_cells=!total_cells! - !empty_cells!"

rem Update side text
set "Side_text.line1=Duplicates  : !duplicates_count!"
if "!Import.type!" == "puzzle" (
    set "Side_text.line2=Givens      : !given_cells!"
) else set "Side_text.line2=Empty       : !empty_cells!"

:Import.matrix
call :Color.set --highlight !cell_index!
cls
call :Display.sudoku imported
choice /c !_key_layout! /n /m "Input number   : "
set "user_input=!_key_layout:~%errorlevel%,1!"
call :Color.set --pop
if /i "!user_input!" == "X" goto Import.select_method
if /i "!user_input!" == "R" call :Import.reset_matrix & goto Import.update_matrix
if /i "!user_input!" == "Z" call :Action.undo & goto Import.update_matrix
if /i "!user_input!" == "H" goto Import.check_matrix
if /i "!user_input!" == "I" call :Cell.move cell_index up
if /i "!user_input!" == "J" call :Cell.move cell_index left
if /i "!user_input!" == "K" call :Cell.move cell_index down
if /i "!user_input!" == "L" call :Cell.move cell_index right
if /i "!user_input!" == "T" call :Settings.toggle_color
call :Action.mark !cell_index! !user_input! || goto Import.matrix
call :Cell.move cell_index next
goto Import.update_matrix


:Import.reset_matrix
if /i "!Import.type!" == "puzzle" (
    call :Matrix.set imported " "
    call :Matrix.set applied.color "!Color_puzzle!"
) else (
    call :Matrix.create imported selected.puzzle_array 1
    call :Matrix.set applied.color "!Color_solvings!"
    call :Color.filled_cells imported "!Color_puzzle!"
)
call :Color.set --reset
call :Action.reset imported
set "cell_index=1-1"
exit /b 0


:Import.check_matrix
if "!duplicates_count!" == "0" (
    if /i "!Import.type!" == "puzzle" goto Import.matrix_success
    if "!given_cells!" == "!total_cells!" goto Import.matrix_success
    echo There are still !return! empty cells...
) else echo Duplicates found. Use color to see the duplicates.
pause > nul
goto Import.matrix


:Import.matrix_success
call :Matrix.to_array imported selected.!Import.type!_array
for %%v in (cell_index given_cells duplicates_count) do set "%%v="
goto Import.success


:Import.success
echo Input successful
pause > nul
if /i "!Import.type!" == "answer" goto Import.done
set "Import.type=answer"
goto Import.setup


:Import.done
call :Side_text.add --clear
call :Matrix.delete imported
call :Matrix.delete applied.color
set "selected.file=Imported"
set "selected.name=Imported @!date:~10,4!-!date:~4,2!-!date:~7,2!"
for %%v in (
    file name size
    puzzle_array answer_array solvings_array
) do set "last_used.%%v=!selected.%%v!"

call :save2file --puzzle
goto :EOF

rem ================================ View Sudoku ================================

:View
:View.setup
call :select_sudoku
if not defined selected.puzzle_array goto :EOF

call :Display.setup
call :Matrix.create selected.puzzle selected.puzzle_array 1
if defined selected.answer_array call :Matrix.create selected.answer selected.answer_array 1
if defined selected.solvings_array call :Matrix.create selected.solvings selected.solvings_array 1

call :Matrix.set applied.color "!Color_solvings!"
call :Color.filled_cells selected.puzzle "!Color_puzzle!"

call :Side_text.add --clear --info:selected.puzzle " " ^
    "[C] Copy array" " " ^
    "Press enter to exit"

:View.menu
set "user_input="
cls
echo 1. Puzzle
if defined selected.answer_array echo 2. Answer
if defined selected.solvings_array echo 3. Solvings
echo=
echo A. View all in array form
echo 0. Back
echo=
echo Which one do you want to view?
set /p "user_input="
if "!user_input!" == "0" goto :EOF
if "!user_input!" == "1" call :View.matrix selected.puzzle
if defined selected.answer_array    if "!user_input!" == "2" call :View.matrix selected.answer
if defined selected.solvings_array  if "!user_input!" == "3" call :View.matrix selected.solvings
if /i "!user_input!" == "A" call :View.array selected
goto View.menu


:View.matrix   name
set "user_input="
cls
call :Display.sudoku %~1
set /p "user_input=> "
if /i "!user_input!" == "C" (
    < nul set /p "=!%~1_array: =0!" | clip
    echo Copied array to clipboard
    pause > nul
)
exit /b 0


:View.array   name
cls
echo Puzzle array:
echo !%~1.puzzle_array: =0!
echo=
if defined %~1.answer_array (
    echo Answer array:
    echo !%~1.answer_array: =0!
    echo=
)
if defined %~1.solvings_array (
    echo Solvings array:
    echo !%~1.solvings_array: =0!
    echo=
)
pause
exit /b 0

rem ================================ Generate Sudoku ================================

:Generator
:Generator.setup
call :select_size || goto :EOF

call :Block_size.setup !selected.size!

:Generator.difficultyIn
set "user_input="
cls
call :menuopts.list Difficulty.list "$n. {Difficulty_$i.name}"
echo=
echo C. Custom
echo 0. Back
echo=
echo Input difficulty level:
set /p "user_input="
if "!user_input!" == "0" goto Generator.setup
if /i "!user_input!" == "C" goto Generator.custom_setup
call :menuopts.get selected.difficulty Difficulty.list "!user_input!" && (
    goto Generator.difficultySetup
)
goto Generator.difficultyIn


:Generator.custom_setup
set "difficultyName=Custom"
set "method_used=2"
set "min_givens=0"
set "max_givens=!total_cells!"
set "targetGivens=0"

:Generator.custom_menu
cls
echo 1. Givens          !targetGivens!
echo 2. Strategy Used   !method_used!
echo=
echo G. Generate
echo 0. Back
echo=
echo What do you want to customize?
set /p "user_input="
echo=
if "!user_input!" == "0" goto Generator.difficultyIn
if "!user_input!" == "1" call :Generator.custom_givensIn
if "!user_input!" == "2" call :Generator.custom_methodUsedIn
if /i "!user_input!" == "G" goto Generator.generateSetup
goto Generator.custom_menu


:Generator.custom_givensIn
set /p "targetGivens=Input givens (!min_givens!-!max_givens!): "
if !targetGivens! LSS !min_givens! goto Generator.custom_givensIn
if !targetGivens! GTR !max_givens! goto Generator.custom_givensIn
goto :EOF


:Generator.custom_methodUsedIn
set /p "method_used=Input strategy used: "
if !method_used! GEQ 2 if !method_used! LEQ 2 goto :EOF
if /i "!method_used!" == "BF" goto :EOF
if /i "!method_used!" == "all" goto :EOF
goto Generator.custom_methodUsedIn


:Generator.difficultySetup
set "estTime="
set "difficultyName=!Difficulty_%selected.difficulty%.name!"
set "method_used=2"
set "min_givens=!min_custom_givens!"
set "max_givens=!total_cells!"
set "targetGivens=0"
call :difficulty_!selected.difficulty!

:Generator.generateSetup
set "minTime=???"
set "maxTime=???"
for /f "tokens=1,2 delims= " %%a in ("!estTime!") do (
    set /a "minTime=%%a * 1000 / !loopSpeed!"
    call :ftime minTime !minTime!

    set /a "maxTime=%%b * 1000 / !loopSpeed!"
    call :ftime maxTime !maxTime!
)

set "selected.name=!difficultyName!"
set "last_used.file=Generated"
set "last_used.name=!selected.name!"
set "last_used.size=!block_width!x!block_height!"
set "user_input="
set "generateCount=0"
set "generateTotal=0"

set "last_used.puzzle_array="
set "last_used.answer_array="
set "last_used.solvings_array="

call :Display.setup
cls
echo Sudoku size        : !grid_size!x!grid_size! [!block_width!x!block_height!]
echo Difficulty         : !difficultyName!
echo Strategy Used      : !method_used!
echo Givens             : !min_givens! - !max_givens!
echo Estimated time     : !minTime! - !maxTime!
echo=
echo 0. Back
echo=
echo Press enter to start generating...
set /p "user_input="
if "!user_input!" == "0" goto Generator.difficultyIn

if /i "!user_input:~0,3!" == "gen" set "generateTotal=!user_input:~3!"

set "start_time=!time!"
echo [!time!] Start generating

:Generator.startGenerate
set /a "generateCount+=1"
set "start_time2=!time!"

echo=
if not "!generateTotal!" == "0" (
    call :difficulty_!selected.difficulty!
    echo [!time!] Generating sudoku: !generateCount!/!generateTotal!
)
echo [!time!] Generating answer...
call :generate_answer selected.puzzle
if "!solution_count!" == "0" goto Generator.badSeed

< nul set /p "=!CL!Swapping numbers..."
set /a "_count=!grid_size! * 3 / 2"
for /l %%n in (1,1,!_count!) do (
    set /a "_value1=!random! %% !grid_size! + 1"
    set /a "_value2=!random! %% !grid_size! + 1"
    for %%x in (!_value1!) do for %%y in (!_value2!) do (
        call :Matrix.swap selected.puzzle !SYMBOL:~%%x,1! !SYMBOL:~%%y,1!
    )
)
set "_count="
call :difftime time_taken !time! !start_time2!
call :ftime time_taken !time_taken!
echo !CL![!time!] Generate answer done in !time_taken! with !search_count! loops
call :Matrix.to_array selected.puzzle last_used.answer_array


echo [!time!] Generating puzzle...
set "start_time2=!time!"

set "progressCount=0"
set "currentGivens=!total_cells!"
set "totalBruteforceCount=0"
call :Cell.random selected.puzzle --filled
for %%c in (!cell_list!) do (
    title Sudoku !SOFTWARE.VERSION! - Generating puzzle... #!progressCount!/!total_cells! ^| Givens: !currentGivens!/!targetGivens!

    call :Matrix.copy selected.puzzle selected.solvings
    set "selected.solvings_%%c= "

    if /i "!method_used!" == "BF" (
        call :Bruteforce selected.solvings --validate
        set /a "totalBruteforceCount+=!search_count!"
        if "!solution_count!" == "1" set "selected.puzzle_%%c= "
    ) else (
        < nul set /p "=!CL!Progress: !progressCount!/!total_cells! | Givens: !currentGivens!/!targetGivens!"
        call :Solve selected.solvings !method_used!
        if /i "!is_valid!,!empty_cells!" == "true,0" set "selected.puzzle_%%c= "
    )
    set /a "progressCount+=1"
    if "!selected.puzzle_%%c!" == " " set /a "currentGivens-=1"
    if "!currentGivens!" == "!targetGivens!" goto Generator.generateDone
)
title Sudoku !SOFTWARE.VERSION!

:Generator.generateDone
call :difftime time_taken !time! !start_time2!
call :ftime time_taken !time_taken!
if /i "!method_used!" == "BF" (
    echo !CL![!time!] Generate puzzle done in !time_taken! with !totalBruteforceCount! loops
) else echo !CL![!time!] Generate puzzle done in !time_taken!

echo [!time!] Doing some cleanup...
call :Matrix.to_array selected.puzzle last_used.puzzle_array

if not "!generateTotal!" == "0" goto Generator.next

call :Matrix.delete candidate_list
call :Matrix.delete selected.solvings

echo [!time!] Done
call :difftime time_taken !time! !start_time!
call :ftime time_taken !time_taken!
echo=
echo Total time taken : !time_taken!
echo=
pause

call :Matrix.set applied.color "!Color_puzzle!"
call :Side_text.add --clear --info:selected.puzzle

cls
call :Display.sudoku selected.puzzle
call :Matrix.delete selected.puzzle
call :Matrix.delete applied.color
echo Total time taken : !timeTaken!
call :save2file --puzzle
goto :EOF


:Generator.badSeed
echo Bad sudoku seed detected, repeating...
ping localhost /n 3 > nul 2> nul
goto Generator.promptGenerate


:Generator.next
call :save2file --puzzle --quiet
if not "!generateCount!" == "!generateTotal!" goto Generator.startGenerate

call :difftime time_taken !time! !start_time!
call :ftime time_taken !time_taken!

call :Matrix.delete selected.puzzle

echo [!time!] Done
echo=
echo Total time taken : !time_taken!
echo=
pause
goto :EOF

rem ================================ Solve Sudoku ================================

:Solver
:Solver.setup
call :select_sudoku --validate
if not defined selected.puzzle_array goto :EOF

rem Load puzzle, color and side text
call :Display.setup
call :Matrix.set applied.color "!Color_solvings!"
call :Matrix.create selected.solvings selected.puzzle_array 1
call :Color.filled_cells selected.solvings "!Color_puzzle!"
call :Side_text.add --clear --info:selected.solvings
if defined selected.solvings_array (
    rem Load solvings
    call :Matrix.create selected.solvings selected.solvings_array 1
    call :Matrix.count empty_cells selected.solvings " "
    set /a "_solved= !total_cells! - !empty_cells! - !given_cells!"
    call :Side_text.add "Solved  : !_solved!"
    set "_solved="

    cls
    call :Display.sudoku selected.solvings
    echo Solvings data found
    call :Input.yesno use_saves -m "Do you want to load this solvings? [y/n] " -y="true" -n="" || (
        rem Restore puzzle and side text if user entered 'N'
        call :Matrix.create selected.solvings selected.puzzle_array 1
        call :Side_text.add --clear --info:selected.solvings
    )
)
call :Input.yesno -m "Show solvings steps? [y/n] " || goto Solver.quickSolve
call :Input.yesno show_candidates -m "Show candidates? [y/n] " -y="true" -n=""
goto Solver.showSteps_setup


:Solver.quickSolve
cls
call :Display.sudoku selected.solvings
echo Press any key to start solving...
pause > nul
echo Solving sudoku...
set "start_time=!time!"
call :Solve selected.solvings
if /i "!is_valid!" == "false" goto Solver.invalidSudoku
if not "!empty_cells!" == "0" goto Solver.too_hard

call :difftime time_taken !time! !start_time!
call :ftime time_taken !time_taken!
call :Matrix.to_array selected.solvings last_used.answer_array

cls
call :Display.sudoku selected.solvings
echo Solve done in !time_taken!
pause > nul
goto Solver.quit


:Solver.showSteps_setup
if defined show_candidates (
    call :Display.change_size !showStep_width! !showStep_height!
    call :setup_candidates selected.solvings candidate_list
    call :Matrix.set applied.color "!Color_candidate!"
    if defined use_saves (
        call :Matrix.create selected.solvings selected.solvings_array 1
        call :Color.filled_cells selected.solvings "!Color_solvings!"
        call :Matrix.create selected.solvings selected.puzzle_array 1
        call :Color.filled_cells selected.solvings "!Color_puzzle!"
        call :Matrix.create selected.solvings selected.solvings_array 1
    ) else call :Color.filled_cells selected.solvings "!Color_puzzle!"
)

call :Side_text.add --clear
cls
call :Display.sudoku selected.solvings /h
echo=
if defined show_candidates (
    call :Display.candidates candidate_list
    echo=
)
echo Press any key to start solving...
pause > nul


:Solver.showSteps
rem Save current matrix
call :Matrix.copy selected.solvings selected.solvings_old
if defined show_candidates (
    call :Matrix.copy candidate_list candidate_list_old
)

call :Solve selected.solvings --once

rem Convert cell code and color solved cells
set "solved_cells_converted="
for %%c in (!solved_cells!) do for /f "tokens=1-2 delims=-+" %%i in ("%%c") do (
    set "solved_cells_converted=!solved_cells_converted! !ALPHABET:~%%i,1!%%j"
    set "applied.color_%%i-%%j=!Color_highlight!"
)

cls
call :Display.sudoku selected.solvings_old /h
echo=
if defined show_candidates (
    call :Display.candidates candidate_list_old
)
echo [!solve_method!] !solved_cells_converted!
pause > nul

rem Restore solved cells color
for %%c in (!solved_cells!) do for /f "tokens=1-2 delims=-+" %%i in ("%%c") do (
    set "applied.color_%%i-%%j=!Color_solvings!"
)

if /i "!is_valid!" == "true" if not "!solve_method!" == "Unsolvable" (
    if not "!empty_cells!" == "0" goto Solver.showSteps
)

rem Show step cleanup
call :Matrix.delete selected.solvings_old
if defined show_candidates (
    call :Matrix.delete candidate_list_old
)
if /i "!is_valid!" == "false" goto Solver.invalidSudoku
if "!solve_method!" == "Unsolvable" goto Solver.too_hard

rem Solve done
call :Matrix.to_array selected.solvings last_used.answer_array
call :Display.change_size !con_width! !con_height!
cls
call :Display.sudoku selected.solvings
echo Solve done
pause > nul
goto Solver.quit


:Solver.invalidSudoku
rem Color last solved cells
for %%c in (!solved_cells!) do for /f "tokens=1-2 delims=-" %%i in ("%%c") do (
    set "applied.color_%%i-%%j=!Color_highlight!"
)
cls
call :Display.sudoku selected.solvings /h
echo=
if defined show_candidates (
    call :Display.candidates candidate_list
)
echo This sudoku is invalid. It has no solutions
echo Last solved: [!solve_method!] !solved_cells_converted!
pause > nul
goto Solver.quit


:Solver.too_hard
call :Matrix.count empty_cells selected.solvings " "
set /a "_solved= !total_cells! - !empty_cells! - !given_cells!"
call :Side_text.add "Solved  : !_solved!"
set "_solved="
call :Matrix.to_array selected.solvings last_used.solvings_array
call :Display.change_size !con_width! !con_height!
cls
call :Display.sudoku selected.solvings
echo This sudoku is either too hard or it is invalid.

call :Input.yesno -m "Use bruteforce? [y/n] " || goto Solver.quit
call :Input.yesno count_solutions -m "Count number of solutions? [y/n] " -y="true" -n=""

call :Matrix.create selected.solvings selected.puzzle_array 1
cls
call :Display.sudoku selected.solvings
call :Matrix.delete applied.color
echo Press any key to start solving...
pause > nul

set "start_time=!time!"
if defined count_solutions (
    call :Bruteforce selected.solvings --solution-count
) else call :Bruteforce selected.solvings
call :difftime time_taken !time! !start_time!
call :ftime time_taken !time_taken!

set "last_used.answer_array=!solution1!"

call :Matrix.create selected.puzzle selected.puzzle_array 1
call :Matrix.set applied.color "!Color_solvings!"
call :Color.filled_cells selected.puzzle "!Color_puzzle!"
call :Matrix.delete selected.puzzle

cls
call :Display.sudoku selected.solvings
echo Done in !time_taken! with !search_count! guesses
if "!solution_count!" == "!solution_count_limit!" (
    echo Found at least !solution_count! solutions
) else echo Found !solution_count! solutions
pause > nul
goto Solver.quit


:Solver.quit
call :Matrix.delete selected.solvings
call :Matrix.delete applied.color
if defined last_used.answer_array (
    call :save2file --puzzle
) else if defined last_used.solvings_array call :save2file --puzzle
goto :EOF

rem ================================ Select Sudoku ================================

:select_sudoku [--validate]
rem Select sudoku from file / last used
set "_require_validate="
for %%a in (%*) do if /i "%%a" == "--validate" set "_require_validate=true"
set "_data_vars=file name size puzzle_array answer_array solvings_array"
for %%v in (!_data_vars!) do set "selected.%%v="
pushd "!puzzle_path!"
set "Category.item_count=0"
goto select_sudoku.file


:select_sudoku.file
set "selected.file="
cls
dir * /b /o:d /p 2> nul
echo=
echo T. Built-in sudoku (This file)
if defined last_used.puzzle_array echo L. Last used / entered sudoku
echo 0. Back
echo=
echo Select sudoku file :
set /p "selected.file="
echo=
if "!selected.file!" == "0" (
    for %%v in (!_data_vars!) do set "selected.%%v="
    goto select_sudoku.cleanup
)
if defined last_used.puzzle_array if /i "!selected.file!" == "L" goto select_sudoku.last_used
if /i "!selected.file!" == "T" set "selected.file=%~f0"
call :check_path --exist --file selected.file && (
    echo=
    echo Checking file...
    call :strip_dquotes selected.file
    call :Sudoku_file.read "!selected.file!"
    if not "!Category.item_count!" == "0" goto select_sudoku.category
    echo No sudoku data found
)
pause > nul
goto select_sudoku.file


:select_sudoku.last_used
for %%v in (!_data_vars!) do set "selected.%%v=!last_used.%%v!"
if not defined last_used.file set "selected.file=Unknown"
call :select_sudoku.check && goto select_sudoku.cleanup
echo Sudoku is invalid
pause > nul
goto select_sudoku.file


:select_sudoku.category
set "selected.category="
cls
echo Sudoku File    : !selected.file!
echo=
call :Category.get_item list
echo=
echo 0. Back
echo=
echo Select sudoku list:
set /p "selected.category="
echo=
if "!selected.category!" == "0" goto select_sudoku.file
call :Category.get_item "!selected.category!" && (
    set "selected.size=!Category_%selected.category%.size!"
    for %%c in (!selected.category!) do if "!Category_%%c.item_count!" == "1" (
        set "selected.number=1"
        call :select_sudoku.check && ( goto select_sudoku.cleanup ) || ( pause > nul )
    ) else goto select_sudoku.number
)
goto select_sudoku.category


:select_sudoku.number
cls
echo Sudoku File    : !selected.file!
echo Category       : [!Category_%selected.category%.size!] !Category_%selected.category%.name!
echo=
echo 0. Back
echo=
echo Input sudoku number (1-!Category_%selected.category%.item_count!) :
set /p "selected.number="
echo=
if "!selected.number!" == "0" goto select_sudoku.category
if !selected.number! GEQ 1 if !selected.number! LEQ !Category_%selected.category%.item_count! (
    call :select_sudoku.check && ( goto select_sudoku.cleanup ) || ( pause > nul )
)
goto select_sudoku.number


:select_sudoku.check
echo Reading file...
call :Sudoku_file.read "!selected.file!" !selected.category! !selected.number!
if not defined selected.puzzle_array exit /b 1

echo Checking sudoku puzzle...
call :Block_size.setup !selected.size!
call :Array.check selected.puzzle_array && (
    if defined _require_validate (
        call :Matrix.create _temp selected.puzzle_array 1
        call :Matrix.set applied.color "!Color_default!"
        call :Matrix.get_duplicates _temp
        call :Matrix.delete _temp
        if not "!duplicates_count!" == "0" exit /b 1
    )
) ||  exit /b 1
call :Array.check selected.answer_array 2> nul || set "selected.answer_array="
rem ? Check if puzzle matches answer or not
rem ? Find save data of puzzle
call :Array.check selected.solvings_array 2> nul || set "selected.solvings_array="
for %%v in (!_data_vars!) do set "last_used.%%v=!selected.%%v!"
exit /b 0


:select_sudoku.cleanup
for /l %%i in (1,1,!Category.item_count!) do (
    for %%t in (name item_count size) do set "Category_%%i.%%t="
)
set "Category.item_count="
set "_require_validate="
set "selected.category="
set "selected.number="
if "!selected.file!" == "0" set "selected.file="
popd
goto :EOF

rem ================================ Select Size ================================

:select_size
set "user_input="
call :Display.change_size !default_console_width! !default_console_height!
cls
call :Block_size.get_item list
echo=
echo Default is 3x3
echo=
echo 0. Back
echo=
echo Input sudoku block size  :
set /p "user_input="
if "!user_input!" == "0" exit /b 1
call :Block_size.get_item "!user_input!" && exit /b 0
goto select_size

rem ======================================== Save to File  ========================================

:save2file   <--puzzle | --solvings> [--quiet]
rem Save Sudoku to file
rem --puzzle    Save to Puzzle folder
rem --solvings  Save to Saves folder
rem --quiet     Quiet Mode. Do not prompt user
set "writePath="
set "promptUser=true"
for %%p in (%*) do (
    if /i "%%p" == "--puzzle" set "writePath=!puzzle_path!"
    if /i "%%p" == "--solvings" set "writePath=!save_path!"
    if /i "%%p" == "--quiet" set "promptUser=false"
)
if not defined writePath call :exception.raise "save2file: Assertion Error:" "Save path is not defined"
pushd "!writePath!"
if /i "!promptUser!" == "true" goto save2file.prompt
goto save2file.noPrompt


:save2file.prompt
call :Input.yesno -m "Save to file? [y/n] " || goto save2file.cleanup

if not defined last_used.file set "last_used.file=Unknown"
:save2file.fileIn
set "selected.file=!last_used.file!"
cls
dir * /b /o:d /p 2> nul
echo=
echo Default : !last_used.file!
echo=
echo Enter nothing to write to file above
echo=
echo 0. Back
echo=
echo Input sudoku file name :
set /p "selected.file="
if /i "!selected.file!" == "0" goto save2file.cleanup
call :strip_dquotes selected.file
if not exist "!selected.file!" goto save2file.nameIn
echo=
echo File already exist. Sudoku will be added to that file
pause > nul
goto save2file.nameIn


:save2file.nameIn
set "selected.name=!last_used.name!"
cls
echo File   : !selected.file!
echo=
echo Name   : !last_used.name!
echo Size   : !last_used.size!
< nul set /p "=Data   : Puzzle,"
if defined last_used.answer_array < nul set /p "=!BASE! Answer,"
if defined last_used.solvings_array < nul set /p "=!BASE! Solvings,"
echo !BACK!
echo=
echo Enter nothing to use the name above
echo=
echo Input sudoku name  :
set /p "selected.name="
echo=
goto save2file.write


:save2file.noPrompt
set "selected.file=!last_used.file!"
if not defined last_used.file set "selected.file=Unknown"
set "selected.name=!last_used.name!"
if not defined last_used.name (
    set "selected.name=!time: =0!"
    set "selected.name=!selected.name::=!"
    set "selected.name=Saved @!date:~10,4!-!date:~4,2!-!date:~7,2!_!selected.name:~0,6!"
)
goto save2file.write


:save2file.write
set "save_array="
for %%a in (puzzle answer solvings) do if defined last_used.%%a_array (
    set "save_array=!save_array!_!last_used.%%a_array!"
) else set "save_array=!save_array!_0"
set "save_array=!save_array: =0!"
set "save_array=!save_array:~1!"

set "writeLabel=true"
if exist "!selected.file!" for /f "usebackq tokens=1,2* delims= " %%a in ("!selected.file!") do (
    if /i "%%a" == "#end" set "writeLabel=true"
    if /i "%%a" == "#sudoku" if "%%b,%%c" == "!last_used.size!,!selected.name!" (
        set "writeLabel=false"
    ) else set "writeLabel=true"
)
if /i "!promptUser!" == "true" echo Saving sudoku [!selected.name!] in [!selected.file!]
(
    if /i "!writeLabel!" == "true" echo #sudoku !last_used.size! !selected.name!
    echo !save_array!
) >> "!selected.file!"
set "writeLabel="
if /i "!promptUser!" == "false" goto save2file.cleanup
echo Done
pause > nul
goto save2file.cleanup


:save2file.cleanup
set "writePath="
set "promptUser="
popd
goto :EOF

rem ======================================== Utilities ========================================

:utils
rem Utility Functions
exit /b 0

rem ================================ Solve Sudoku ================================

:Solve   matix_name  [methods]  [--once]
set "usedMethods=all"
set "_solve_once="
set "_argc=0"
for %%a in (%*) do (
    set "_set_cmd="
    set /a "_argc+=1"
    if /i "%%a" == "--once" set "_set_cmd=_solve_once=true"
    if defined _set_cmd (
        set "!_set_cmd!"
        shift /!_argc!
        set /a "_argc-=1"
    )
)
if not "%~2" == "" set "usedMethods=%~2"

call :setup_candidates %1 candidate_list
call :Matrix.count empty_cells %1 " "
set "solved_cells="
set "error_cells="
set "is_valid=true"

:Solve.loop
rem Remove candidates
set "solved_cells= !solved_cells!"
for %%s in (!solved_cells!) do set "solved_cells=!solved_cells: %%s=! %%s"
for %%s in (!solved_cells!) do for /f "tokens=1,2 delims=+" %%c in ("%%s") do (
    set "%~1_%%c=%%d"
    set "candidate_list_%%c=!candidate_mark_%%d!"
    for %%a in (!Cells_adj%%c!) do set "candidate_list_%%a=!candidate_list_%%a:%%d= !"
    set /a "empty_cells-=1"
)
for %%c in (!Cells_all!) do if "!candidate_list_%%c!" == "!candidate_mark_empty!" (
    set "error_cells=!error_cells! %%c"
)
if defined error_cells set "is_valid=false"
if /i "!is_valid!" == "false" goto Solve.error
set "solved_cells=!solved_cells:~1!"
if defined solved_cells if defined _solve_once goto Solve.done
set "solved_cells="
if "!empty_cells!" == "0" goto Solve.done
if !usedMethods! LEQ 0 goto Solve.too_hard

rem Solving algorithms starts here


rem Algorithm 1
set "solve_method=Singles"
for %%c in (!Cells_all!) do if "!%~1_%%c!" == " " (
    set "_remaining=!candidate_list_%%c: =!"
    if "!_remaining:~1!" == "" set "solved_cells=!solved_cells! %%c+!_remaining!"
)
if defined solved_cells goto Solve.loop
if !usedMethods! LEQ 1 goto Solve.too_hard


rem Algorithm 2
set "solve_method=Hidden Singles"
for /l %%i in (1,1,!grid_size!) do for %%l in (Cells_row%%i Cells_col%%i Cells_blk%%i) do (
    set "symbol_search= !symbol_spaced!"
    for %%c in (!%%l!) do for %%s in (!%~1_%%c!) do set "symbol_search=!symbol_search: %%s=!"
    for %%s in (!symbol_search!) do (
        set "_cell= "
        for %%c in (!%%l!) do if defined _cell if not "!candidate_list_%%c:%%s=!" == "!candidate_list_%%c!" (
            if "!_cell!" == " " (
                set "_cell=%%c"
            ) else set "_cell="
        )
        for %%c in (!_cell!) do set "solved_cells=!solved_cells! %%c+%%s"
    )
)
set "symbol_search="
if defined solved_cells goto Solve.loop
if !usedMethods! LEQ 2 goto Solve.too_hard


rem Algorithm 3
set "solve_method=Naked Pair"

rem Note:
rem - code refactor required to implement function
rem - should be based on eliminated candidate count

rem naked pairs - remove surroundings
rem 2 cells with the same candidate

rem hidden pairs - identify self
rem 2 candidate only found in 2 cells

rem naked triples
rem 3 cells with total of 3 candidates
rem 3 candidates found only in 3 cells

rem eliminate [list - exeption] [number]

if defined solved_cells goto Solve.loop
if !usedMethods! LEQ 3 goto Solve.too_hard


rem No Algorithm Left
:Solve.too_hard
set "solve_method=Unsolvable"
:Solve.error
:Solve.done
goto :EOF


rem ======================================== Bruteforce Sudoku ========================================

:generate_answer   matix_name
rem Return
set /a "search_limit= 2 * !total_cells!"
set "max_solutions=1"
call :Matrix.set %1 " "
set /a "init_empty=!total_cells! - !initial_givens!"
< nul set /p "=!CL!Initializing..."
goto Bruteforce.setup


:Bruteforce   matix_name  [--solution-count | --validate]
set "search_limit=-1"
set "max_solutions=1"
set "init_empty=!total_cells!"
if /i "%2" == "--solution-count" set "max_solutions=!solution_count_limit!"
if /i "%2" == "--validate"  set "max_solutions=2"
< nul set /p "=!CL!Solving..."
goto Bruteforce.setup


:Bruteforce.setup
set "search_count=0"
set "_depth=0"
set "max_depth=0"
set "solution_count=0"
for /l %%n in (1,1,!solution_count_limit!) do set "solution%%n="

call :setup_candidates %1 candidate_list
call :Matrix.count empty_cells %1 " "
goto Bruteforce.solve

:Bruteforce.init_value
rem Pick random cell and fill with a random candidate
call :Cell.random %1 --empty 1
set "_cell=!cell_list:~1!"
for %%c in (!_cell!) do (
    set "_remaining=!candidate_list_%%c: =!"
    for /l %%n in (!grid_size!,-1,0) do if "!_remaining:~%%n,1!" == "" set "_count=%%n"
    set /a "_index=!random! %% !_count!"
    for %%r in (!_index!) do set "try_symbol=!_remaining:~%%r,1!"
)
goto Bruteforce.prepare_search


:Bruteforce.pick_value
if "!search_count!" == "!search_limit!" goto Bruteforce.done

rem Find cell with least candidates (MRV)
set "_cell=?-?"
set "_min_count=!grid_size!"
for %%c in (!Cells_all!) do if "!%1_%%c!" == " " (
    set "_remaining=!candidate_list_%%c: =!"
    for /l %%n in (!grid_size!,-1,0) do if "!_remaining:~%%n,1!" == "" set "_count=%%n"
    if !_count! LSS !_min_count! (
        set "_cell=%%c"
        set "_min_count=!_count!"
    )
)
rem Select a possible candidate for that cell
set "try_symbol=!try_symbol%_depth%!"
for %%c in (!_cell!) do set "_remaining= !candidate_list_%%c: =!"
if "!try_symbol!" == "" (
    set "try_symbol=!_remaining:~0,2!"
) else for /l %%n in (1,1,!grid_size!) do if "!try_symbol!" == "!_remaining:~%%n,1!" (
    set "try_symbol=!_remaining:~%%n,2!"
)
set "try_symbol=!try_symbol:~1!"
if not defined try_symbol goto Bruteforce.backtrack
goto Bruteforce.prepare_search

:Bruteforce.prepare_search
rem Try filling the cell with a possible candidate
set "try_symbol!_depth!=!try_symbol!"
call :Matrix.to_array %1 depth_array!_depth!

rem Set value and eliminate candidates
set "%1_!_cell!=!try_symbol!"
set /a "empty_cells-=1"
for %%c in (!_cell!) do for %%s in (!try_symbol!) do (
    set "candidate_list_%%c=!candidate_mark_%%s!"
    for %%n in (!Cells_adj%%c!) do if "!%1_%%n!" == " " set "candidate_list_%%n=!candidate_list_%%n:%%s= !"
)

set /a "search_count+=1"
set /a "_depth+=1"
if !_depth! GTR !max_depth! set "max_depth=!_depth!"

if !empty_cells! GTR !init_empty! (
    set /a "_filledCells=!total_cells! - !empty_cells!"
    < nul set /p "=!CL!Initializing... !_filledCells!/!initial_givens!"
) else < nul set /p "=!CL!Bruteforcing... #!search_count!, depth: !_depth!/!max_depth! | Solutions: !solution_count!"
goto Bruteforce.solve


:Bruteforce.solve
set "prev_empty_cells=!empty_cells!"

rem Algorithm 1 - Singles
for %%c in (!Cells_all!) do if "!%~1_%%c!" == " " (
    set "_remaining=!candidate_list_%%c: =!"
    if defined _remaining (
        if "!_remaining:~1!" == "" for %%s in (!_remaining!) do (
            set "%~1_%%c=%%s"
            set "candidate_list_%%c=!candidate_mark_%%s!"
            set /a "empty_cells-=1"
            for %%a in (!Cells_adj%%c!) do (
                set "candidate_list_%%a=!candidate_list_%%a:%%s= !"
                if "!candidate_list_%%a!" == "!candidate_mark_empty!" goto Bruteforce.backtrack
            )
        )
    ) else goto Bruteforce.backtrack
)
if not "!empty_cells!" == "!prev_empty_cells!" goto Bruteforce.solve

rem Algorithm 2 - Hidden Singles
for /l %%i in (1,1,!grid_size!) do for %%l in (Cells_row%%i Cells_col%%i Cells_blk%%i) do (
    set "symbol_search= !symbol_spaced!"
    for %%c in (!%%l!) do for %%s in (!%1_%%c!) do set "symbol_search=!symbol_search: %%s=!"
    for %%s in (!symbol_search!) do (
        set "_cell= "
        for %%c in (!%%l!) do if defined _cell if not "!candidate_list_%%c:%%s=!" == "!candidate_list_%%c!" (
            if "!_cell!" == " " (
                set "_cell=%%c"
            ) else set "_cell="
        )
        for %%c in (!_cell!) do (
            set "%~1_%%c=%%s"
            set "candidate_list_%%c=!candidate_mark_%%s!"
            set /a "empty_cells-=1"
            for %%a in (!Cells_adj%%c!) do (
                set "candidate_list_%%a=!candidate_list_%%a:%%s= !"
                if "!candidate_list_%%a!" == "!candidate_mark_empty!" goto Bruteforce.backtrack
            )
        )
    )
)

set "symbol_search="

rem No Algorithm Left
if "!empty_cells!" == "0" goto Bruteforce.solve_done
if not "!empty_cells!" == "!prev_empty_cells!" goto Bruteforce.solve
if !empty_cells! GTR !init_empty! goto Bruteforce.init_value
goto Bruteforce.pick_value


:Bruteforce.solve_done
set /a "solution_count+=1"
call :Matrix.to_array %1 solution!solution_count!
if "!solution_count!" == "!max_solutions!" goto Bruteforce.done

:Bruteforce.backtrack
if "!_depth!" == "0" goto Bruteforce.done
set "try_symbol!_depth!="
set "depth_array!_depth!="
set /a "_depth-=1"
call :Matrix.create %1 depth_array!_depth! 1

call :setup_candidates %1 candidate_list
call :Matrix.count empty_cells %1 " "
goto Bruteforce.pick_value


:Bruteforce.done
< nul set /p "=!CL!"

rem Delete variables
for /l %%n in (!_depth!,-1,0) do (
    set "depth_array%%n="
    set "try_symbol!_depth!="
)
if "!solution_count!" == "0" goto :EOF
call :Matrix.create %1 solution1 1
goto :EOF


:setup_candidates   source_matix  candidate_matrix
for /l %%l in (1,1,!grid_size!) do (
    set "candidate_list=!SYMBOL:~1,%grid_size%!"
    for %%n in (!Cells_blk%%l!) do for %%s in (!%~1_%%n!) do set "candidate_list=!candidate_list:%%s= !"
    for %%c in (!Cells_blk%%l!) do set "%~2_%%c=!candidate_list!"
)
for /l %%i in (1,1,!grid_size!) do for /l %%j in (1,1,!grid_size!) do (
    for %%s in (!%~1_%%i-%%j!) do (
        for %%n in (!Cells_row%%i!!Cells_col%%j!) do if "!%~1_%%n!" == " " set "%~2_%%n=!%~2_%%n:%%s= !"
        set "%~2_%%i-%%j=!candidate_mark_%%s!"
    )
)
goto :EOF

rem ======================================== Color ========================================

:Color.set   [--clear] [--<color_type>] --pop [cell [...]]
set "_color=!Color_highlight!"
for %%a in (%*) do (
    set "_apply=true"
    for %%c in (!Color.list!) do if /i "%%a" == "--%%c" (
        set "_color=!Color_%%c!"
        set "_apply="
    )
    if /i "%%a" == "--reset" (
        set "Color.change_list="
        set "Color.change_count=0"
        set "_apply="
    )
    if /i "%%a" == "--revert" (
        for /l %%i in (1,1,!Color.change_count!) do (
            for /f "tokens=1-2* delims= " %%b in ("!Color.change_list!") do (
                set "applied.color_%%b=%%c"
                set "Color.change_list=%%d"
            )
        )
        set "Color.change_list="
        set "Color.change_count=0"
        set "_apply="
    )
    if /i "%%a" == "--pop" (
        for /f "tokens=1-2* delims= " %%b in ("!Color.change_list!") do (
            set "applied.color_%%b=%%c"
            set "Color.change_list=%%d"
        )
        set /a "Color.change_count-=1"
        set "_apply="
    )
    if defined _apply (
        set "Color.change_list=%%~a !applied.color_%%~a! !Color.change_list!"
        set "applied.color_%%~a=!_color!"
        set /a "Color.change_count+=1"
    )
)
set "_item="
goto :EOF


:Color.filled_cells   matix_name  color
for %%c in (!Cells_all!) do if not "!%~1_%%c!" == " " set "applied.color_%%c=%~2"
exit /b 0

rem ======================================== Array ========================================

:Array.check   array_name
set "%1=!%1:?= !"
for %%c in ( _ 0 . ) do set "%1=!%1:%%c= !"
set "_temp_array=!%1!@"
if "!_temp_array:~%total_cells%!" == "" 1>&2 echo Array is too short & exit /b 1
if not "!_temp_array:~%total_cells%!" == "@" 1>&2 echo Array is too long & exit /b 1
set "_temp_array=!_temp_array: =!"
for %%s in (!symbol_spaced!) do set "_temp_array=!_temp_array:%%s=!"
if not "!_temp_array!" == "@" 1>&2 echo Array contains invalid symbols & exit /b 1
exit /b 0


:Array.match   derived_array  source_array
rem ? Fill derived array with source array
exit /b 0

rem ======================================== Matrix ========================================

:Matrix.create   matix_name  source_array  data_size
if "!%~2!" == "" goto :EOF
set "_temp_array=!%~2!"
for %%c in (!Cells_all!) do (
    set "%~1_%%c=!_temp_array:~0,%~3!"
    set "_temp_array=!_temp_array:~%~3!"
)
exit /b 0

:Matrix.set   matix_name  value
for %%c in (!Cells_all!) do set "%~1_%%c=%~2"
exit /b 0

:Matrix.copy   source_matix  destination_matrix
for %%c in (!Cells_all!) do set "%~2_%%c=!%~1_%%c!"
exit /b 0

:Matrix.swap   matix_name  value1  value2
for %%c in (!Cells_all!) do for %%n in (!%~1_%%c!) do (
    if "%%n" == "%~2" set "%~1_%%c=%~3"
    if "%%n" == "%~3" set "%~1_%%c=%~2"
)
exit /b 0

:Matrix.to_array   source_matix  destination_array
set "%~2="
for %%c in (!Cells_all!) do set "%~2=!%~2!!%~1_%%c!"
exit /b 0

:Matrix.delete   matix_name
for %%c in (!Cells_all!) do set "%~1_%%c="
exit /b 0

:Matrix.count   return_var  matix_name  value
set "%~1=0"
for %%c in (!Cells_all!) do if "!%~2_%%c!" == "%~3" set /a "%~1+=1"
exit /b 0

:Matrix.compare   return_var  matix1  matix2
set "%~1=0"
for %%c in (!Cells_all!) do if not "!%~2_%%c!" == "!%~3_%%c!" set /a "%~1+=1"
exit /b 0

:Matrix.get_duplicates   matix_name
set "duplicate_list= "
for /l %%i in (1,1,!grid_size!) do (
    for /l %%j in (1,1,!grid_size!) do  for /l %%n in (%%j,1,!grid_size!) do if not "%%j" == "%%n" (
        if not "!%1_%%i-%%j!" == " " if "!%1_%%i-%%j!" == "!%1_%%i-%%n!" (
            set "duplicate_list=!duplicate_list!%%i-%%j %%i-%%n "
        )
        if not "!%1_%%j-%%i!" == " " if "!%1_%%j-%%i!" == "!%1_%%n-%%i!" (
            set "duplicate_list=!duplicate_list!%%j-%%i %%n-%%i "
        )
    )
    for %%a in (!Cells_blk%%i!) do for %%b in (!Cells_blk%%i!) do if not "%%a" == "%%b" (
        if not "!%1_%%a!" == " " if "!%1_%%a!" == "!%1_%%b!" (
            set "duplicate_list=!duplicate_list!%%a %%b "
        )
    )
)
for %%c in (!duplicate_list!) do set "duplicate_list=!duplicate_list: %%c = !%%c "
set "duplicates_count=0"
for %%c in (!duplicate_list!) do set /a "duplicates_count+=1"
exit /b 0

:Matrix.unmark_duplicates   matix_name  value
for %%c in (!Cells_all!) do if "!%~1_%%c!" == "%~2" set "duplicate_list=!duplicate_list: %%c = !"
set "duplicates_count=0"
for %%c in (!duplicate_list!) do set /a "duplicates_count+=1"
exit /b 0
rem Unmark if matrix contains the given value

rem ======================================== File ========================================

:Sudoku_file.read   file_path  [category  number]
set "_read="
set "Category.item_count=0"
set "Category_0.item_count="
for /f "usebackq tokens=*" %%a in ("%~f1") do for /f "tokens=1-2* delims= " %%b in ("%%a") do (
    if /i "%%b" == "#sudoku" set "_read="
    if /i "%%b" == "#end" set "_read="
    if /i "%%b" == "#endlist" set "_read="
    if defined _read for %%i in (!_current_category!) do (
        set /a "Category_%%i.item_count+=1"
        if "%~2,%~3" == "%%i,!Category_%%i.item_count!" for /f "tokens=1-3 delims=_" %%p in ("%%a") do (
            set "selected.puzzle_array=%%p"
            set "selected.answer_array=%%q"
            set "selected.solvings_array=%%r"
            set "selected.name=!Category_%%i.name! #!Category_%%i.item_count!"
            set "selected.size=!Category_%%i.size!"
        )
    )
    if /i "%%b" == "#sudoku" call :Block_size.check %%c && (
        set "_read=true"
        set "_current_category="
        for /l %%n in (1,1,!Category.item_count!) do if "%%d,%%c" == "!Category_%%n.name!,!Category_%%n.size!" (
            set "_current_category=%%n"
        )
        if not defined _current_category (
            for %%n in (!Category.item_count!) do if not "!Category_%%n.item_count!" == "0" set /a "Category.item_count+=1"
            set "_current_category=!Category.item_count!"
            set "Category_!_current_category!.name=%%d"
            set "Category_!_current_category!.size=%%c"
            set "Category_!_current_category!.item_count=0"
        )
    ) || set "_read="
)
set "_read="
set "_current_category="
if "%~2,%~3" == "," exit /b 0
if defined selected.puzzle_array exit /b 0
call :exception.raise "Sudoku_file.read: Assertion Error:" ^
    "Sudoku category %~2 #%~3 is not found" ^
    "Maybe sudoku file is modified by another program"
exit /b 1


:Category.get_item   list|number
set "selected.category="
if /i "%1" == "list" (
    for /l %%i in (1,1,!Category.item_count!) do (
        set "_count=  %%i"
        if "!Category_%%i.item_count!" == "1" (
            echo !_count:~-2,2!. [!Category_%%i.size!] !Category_%%i.name!
        ) else echo !_count:~-2,2!. [!Category_%%i.size!] !Category_%%i.name! [!Category_%%i.item_count!]
    )
) else if defined Category_%~1.name (
    set "selected.category=%~1"
) else exit /b 1
exit /b 0

rem ======================================== Block size ========================================

:Block_size.init_list   max_symbols
set "Block_size.list="
for /l %%i in (2,1,%~1) do for /l %%j in (2,1,%~2) do (
    set /a "_size= %%i * %%j"
    if !_size! LEQ 26 if %%i GEQ %%j set "Block_size.list=!Block_size.list! %%ix%%j"
)
set "_size="
goto :EOF


:Block_size.get_item   list|number
set "_count=0"
set "selected.size="
for %%s in (!Block_size.list!) do (
    set /a "_count+=1"
    if /i "%1" == "list" (
        set "_count=  !_count!"
        for /f "tokens=1-2 delims=Xx" %%a in ("%%s") do (
            set /a "_size=%%a * %%b"
            set "_size=  !_size!"
            echo !_count!. [%%s] !_size:~-2,2! x !_size:~-2,2!
        )
    ) else if "%~1" == "!_count!" set "selected.size=%%s"
)
set "_size="
if /i not "%1" == "list" if not defined selected.size exit /b 1
exit /b 0


:Block_size.check   block_size
for %%s in (!Block_size.list!) do if /i "%~1" == "%%s" exit /b 0
exit /b 1


:Block_size.setup   block_size
if "%~1" == "!applied.block_size!" exit /b 0

rem Delete all previous blocks
for /l %%i in (1,1,!grid_size!) do (
    set "Cells_row%%i="
    set "Cells_col%%i="
    set "Cells_blk%%i="
    for /l %%j in (1,1,!grid_size!) do set "Cells_adj%%i-%%j="
)
for %%s in (!symbol_spaced!) do set "candidate_mark_%%s="

rem We assume that the parameters is valid
set "applied.block_size=%~1"
for /f "tokens=1,2 delims=x" %%a in ("%~1") do (
    set /a "block_width=%%a"
    set /a "block_height=%%b"
)

rem Calculate sudoku size
set /a "grid_size=!block_width! * !block_height!"
set /a "total_cells=!grid_size! * !grid_size!"
set /a "minimum_givens=!total_cells! / 5 + 1"
set /a "initial_givens=!total_cells! * 15 / 100 + 1"
set /a "min_custom_givens=!total_cells! * 4 / 10 + 1"
set /a "max_custom_givens=!total_cells! - !grid_size!"

rem Define cell groups
set "Cells_all="
for /l %%i in (1,1,!grid_size!) do (
    set "Cells_row%%i="
    set "Cells_col%%i="
    set "Cells_blk%%i="
)
set "_block=1"
for /l %%i in (1,1,!grid_size!) do (
    for /l %%j in (1,1,!grid_size!) do (
        set "Cells_all=!Cells_all! %%i-%%j"
        set "Cells_row%%i=!Cells_row%%i! %%i-%%j"
        set "Cells_col%%j=!Cells_col%%j! %%i-%%j"
        set "Cells_adj%%i-%%j=!_block!"
        for %%n in (!_block!) do set "Cells_blk%%n=!Cells_blk%%n! %%i-%%j"
        set /a "_edge=%%j %% !block_width!"
        if "!_edge!" == "0" set /a "_block+=1"
    )
    set /a "_edge=%%i %% !block_height!"
    if not "!_edge!" == "0" set /a "_block-=!block_height!"
)
set "_edge="

rem Define adjacent cells
for /l %%i in (1,1,!grid_size!) do for /l %%j in (1,1,!grid_size!) do (
    for %%b in (!Cells_adj%%i-%%j!) do set "Cells_adj%%i-%%j=!Cells_blk%%b!!Cells_row%%i!!Cells_col%%j! "
    for %%c in (!Cells_adj%%i-%%j!) do set "Cells_adj%%i-%%j=!Cells_adj%%i-%%j: %%c = !%%c "
    set "Cells_adj%%i-%%j=!Cells_adj%%i-%%j: %%i-%%j = !"
)

rem Create symbol list
set "symbol_spaced="
for /l %%n in (1,1,!grid_size!) do set "symbol_spaced=!symbol_spaced! !SYMBOL:~%%n,1!"

rem Create single candidates for solver
set "_spaces="
for %%s in (!symbol_spaced!) do (
    set "candidate_mark_%%s=!_spaces!%%s"
    set "_spaces=!_spaces! "
)
set "candidate_mark_empty=!_spaces!"
for %%s in (!symbol_spaced!) do (
    set "candidate_mark_%%s=!candidate_mark_%%s!!_spaces!"
    set "candidate_mark_%%s=!candidate_mark_%%s:~0,%grid_size%!"
)
set "_spaces="
goto :EOF

rem SYMBOL              Complete list of symbols with a space at the beginning
rem ALPHABET            Complete list of alphabets with a dot at the beginning
rem grid_size           block_width * block_height
rem symbol_spaced       List of valid symbols, excluding 0, seperated by a space. Eg: [1 2 3 4] for 2x2
rem Cells_row[x]        List of cells in that row
rem Cells_col[x]        List of cells in that column
rem Cells_blk[x]        List of cells in that block
rem Cells_adj[x,y]      List of neighbours of that cell, excluding the cell itself

rem ======================================== Display ========================================

:Display.evaluate_color
set "Color.list=default puzzle solvings highlight candidate error"
set "ansi_esc_seq_support="
call :get_os _version
for /f "tokens=1 delims=." %%a in ("!_version!") do (
    if %%a GEQ 10 set "ansi_esc_seq_support=true"
)
for %%t in (!Color.list!) do if defined ansi_esc_seq_support (
    call :color2seq Color_%%t "!%%t_color!"
) else set "Color_%%t=!%%t_color!"
exit /b 0


:Display.setup
if "!block_width!x!block_height!" == "!applied.size!" (
    if "!preferred.style!" == "!applied.style!" (
        call :Display.change_size !con_width! !con_height!
        goto :EOF
    )
)

rem Delete all previous grids
call :Side_text.add --clear

rem Settings
set "bottomText_lines=4"
set "Side_text.width=25"   [GEQ 16]
set "min_con_width=64"
set /a "Action.display_lines=!block_width! + !block_height!"
set "sideText_minHeight=2 + !Action.display_lines! + 11"

rem Change GUI size
set "applied.size=!block_width!x!block_height!"
set "applied.style=!preferred.style!"

rem Build sudoku and candidate GUI
call :Style_!preferred.style!.charset
for %%v in (
    _small_line _small_border
    Grid_top Grid_border Grid_bottom Grid_line Grid_margin
    Log_top Log_bottom
) do set "%%v="
set "_left_margin=  "
for /l %%n in (1,1,3) do (
    set "_small_line=!_small_line!!hLine!"
    set "_small_border=!_small_border!!hBorder!"
)
set "_line=!_small_line!"
set "_border=!_small_border!"
for /l %%n in (2,1,!block_width!) do (
    set   "_line=!_line!!cLine!!_small_line!"
    set "_border=!_border!!hBorder!!_small_border!"
)
for /l %%n in (2,1,!block_height!) do (
    set "Grid_top=!Grid_top!!uEdge!!_border!"
    set "Grid_border=!Grid_border!!cBorder!!_border!"
    set "Grid_bottom=!Grid_bottom!!dEdge!!_border!"
    set "Grid_line=!Grid_line!!vBorder!!_line!"
)
set "Grid_top=!_left_margin!!ulCorner!!_border!!Grid_top!!urCorner!"
set "Grid_border=!_left_margin!!lEdge!!_border!!Grid_border!!rEdge!"
set "Grid_bottom=!_left_margin!!dlCorner!!_border!!Grid_bottom!!drCorner!"
set "Grid_line=!_left_margin!!vBorder!!_line!!Grid_line!!vBorder!"
call :strlen vBorder_len vBorder
call :strlen vLine_len vLine
set "Grid_numbers=!_left_margin!"
for /l %%n in (1,1,!vBorder_len!) do set "Grid_numbers=!Grid_numbers! "
for /l %%n in (1,1,!grid_size!) do (
    set "_number=%%n  "
    set "Grid_numbers=!Grid_numbers! !_number:~0,2!"
    set /a "_edge=%%n %% !block_width!"
    if "!_edge!" == "0" (
        set "_spaces=!vBorder_len!"
    ) else set "_spaces=!vLine_len!"
    for /l %%n in (1,1,!_spaces!) do set "Grid_numbers=!Grid_numbers! "
)

rem Calculate grid size and screen size
call :strlen GUI_width Grid_numbers
set /a "GUI_height= 2 + 2 * !grid_size!"
set /a "con_width=!GUI_width! + !Side_text.width! + 3"
set /a "con_height=!GUI_height! + !bottomText_lines!"
set /a "min_con_height=!sideText_minHeight! + !bottomText_lines!"
if !con_width!  LSS !min_con_width!  set  "con_width=!min_con_width!"
if !con_height! LSS !min_con_height! set "con_height=!min_con_height!"
set /a "GUI_hSpacing= (!con_width! - !GUI_width! - !Side_text.width! - 1) / 2 "
set /a "GUI_vSpacing= (!con_height! - !GUI_height! - !bottomText_lines!) / 2"
if !GUI_vSpacing! LSS 0 set "GUI_vSpacing=0"
if !GUI_hSpacing! LSS 0 set "GUI_hSpacing=0"
set /a "Side_text.height= !GUI_vSpacing! * 2 + !GUI_height!"

set /a "showStep_width= !GUI_width! + !total_cells! - 3 * !grid_size! + 2"
set /a "showStep_height=!con_height! + !grid_size! + !block_width!"
if !showStep_width! LSS !con_width! set "showStep_width=!con_width!"
if !showStep_height! LSS !con_height! set "showStep_height=!con_height!"
call :Display.change_size !con_width! !con_height!

rem Build spacings
for /l %%n in (1,1,!GUI_hSpacing!) do set "Grid_margin=!Grid_margin! "
set "Grid_empty_line=!Grid_margin!!Grid_margin!"
for /l %%n in (1,1,!GUI_width!) do set "Grid_empty_line=!Grid_empty_line! "

rem Build log viewer GUI
for /l %%n in (1,1,13) do (
    set "Log_top=!Log_top!!hBorder!"
    set "Log_bottom=!Log_bottom!!hBorder!"
)
set "Log_top=!ulCorner!!Log_top!!urCorner!"
set "Log_bottom=!dlCorner!!Log_bottom!!drCorner!"

if not defined ansi_esc_seq_support (
    pushd "!tmp_dir!"
    < nul set /p "=!BACK!!BACK!" > "   _" 2> nul
    for %%s in (X !symbol_spaced!) do (
        < nul set /p "=!BACK!!BACK!" > " %%s _" 2> nul
    )
    popd
)
rem Delete variables
for %%v in (
    _small_line _small_border _line _border
    vBorder_len vLine_len _left_margin _number _edge
    hLine cLine hBorder cBorder uEdge dEdge lEdge rEdge
    ulCorner urCorner dlCorner drCorner
    min_con_width min_con_height sideText_minHeight
) do set "%%v="
goto :EOF


:Display.sudoku   matix_name [/H (Horizontal spacing only)]
setlocal
pushd "!tmp_dir!"
set "_line_count=1"

rem Top Vertical Spacing
if /i not "%2" == "/H" for /l %%n in (1,1,!GUI_vSpacing!) do for %%n in (!_line_count!) do (
    echo=!Grid_empty_line!!Side_text.line%%n!
    set /a "_line_count+=1"
)

rem Sudoku GUI
echo !Grid_margin!!Grid_numbers!!Grid_margin!!Side_text.line%_line_count%!
set /a "_line_count+=1"
echo !Grid_margin!!Grid_top!!Grid_margin!!Side_text.line%_line_count%!
set /a "_line_count+=1"
for /l %%i in (1,1,!grid_size!) do (
    rem Line with numbers
    < nul set /p "=!BASE!!Grid_margin!!ALPHABET:~%%i,1! !vBorder!"
    for /l %%j in (1,1,!grid_size!) do (
        if /i "!use_color!" == "true" (
            if defined ansi_esc_seq_support (
                < nul set /p "=!ESC!!applied.color_%%i-%%j! !%1_%%i-%%j! !ESC!!Color_default!"
            ) else findstr /l /v /a:!applied.color_%%i-%%j! "." " !%1_%%i-%%j! _" nul 2> nul
        ) else < nul set /p "=!BASE! !%1_%%i-%%j! "
        set /a "_edge=%%j %% !block_width!"
        if "!_edge!" == "0" (
            < nul set /p "=!BASE!!vBorder!"
        ) else < nul set /p "=!BASE!!vLine!"
    )
    for %%n in (!_line_count!) do echo !BASE!!Grid_margin!!Side_text.line%%n!
    set /a "_line_count+=1"

    rem Line without numbers
    for %%n in (!_line_count!) do (
        set /a "_edge=%%i %% !block_height!"
        if "!_edge!" == "0" (
            if "%%i" == "!grid_size!" (
                echo !Grid_margin!!Grid_bottom!!Grid_margin!!Side_text.line%%n!
            ) else echo !Grid_margin!!Grid_border!!Grid_margin!!Side_text.line%%n!
        ) else echo !Grid_margin!!Grid_line!!Grid_margin!!Side_text.line%%n!
    )
    set /a "_line_count+=1"
)

rem Bottom Vertical Spacing
if /i not "%2" == "/N" for /l %%n in (1,1,!GUI_vSpacing!) do for %%n in (!_line_count!) do (
    echo=!Grid_empty_line!!Side_text.line%%n!
    set /a "_line_count+=1"
)
popd
endlocal
exit /b 0


:Display.candidates   matix_name
rem !Color_candidate!
pushd "!tmp_dir!"
setlocal
for /l %%i in (1,1,!grid_size!) do (
    < nul set /p "=!BASE!!ALPHABET:~%%i,1! !vBorder!"
    for /l %%j in (1,1,!grid_size!) do (
        if /i "!use_color!" == "true" (
            if defined ansi_esc_seq_support (
                < nul set /p "=!ESC!!applied.color_%%i-%%j!!%1_%%i-%%j!!ESC!!Color_default!"
            ) else (
                < nul set /p "=!BACK!!BACK!" > "!%1_%%i-%%j!_" 2> nul
                findstr /l /v /a:!applied.color_%%i-%%j! "." "!%1_%%i-%%j!_" nul 2> nul
            )
        ) else < nul set /p "=!BASE!!%1_%%i-%%j!"
        set /a "_edge=%%j %% !block_width!"
        if "!_edge!" == "0" (
            < nul set /p "=!BASE!!vBorder!"
        ) else < nul set /p "=!BASE!!vLine!"
    )
    echo=
    set /a "_edge=%%i %% !block_height!"
    if "!_edge!" == "0" echo=
)
endlocal
popd
goto :EOF


:Display.change_size   width  height
if "!applied.con_width!,!applied.con_height!" == "%~1,%~2" exit /b 0
mode %~1,%~2
set "applied.con_width=%~1"
set "applied.con_height=%~2"
call :clear_line_macro CL !applied.con_width!
exit /b 0

rem ======================================== Action ========================================

:Action.reset   matrix_name
set "Action.matrix=%~1"
set "Action.count=0"
set "Action.list="
exit /b 0


:Action.mark   cell_index  number
for %%m in (!Action.matrix!) do (
    if "!%%m_%~1!" == "%~2" goto :EOF
    if "!%%m_%~1!,%~2" == " ,0" goto :EOF
    set "_sym="
    for %%s in (!symbol_spaced!) do if /i "%~2" == "%%s" set "_sym=%%s"
    if "%~2" == "0" set "_sym= "
    if defined _sym (
        set "Action.list=%~1-!%%m_%~1!-!_sym!-!Action.list!"
        set "%%m_%~1=!_sym!"
        set /a "Action.count+=1"
    )
)
if not defined _sym exit /b 1
set "_sym="
exit /b 0


:Action.undo
if "!Action.count!" == "0" exit /b 0
for /f "tokens=1-4* delims=-" %%a in ("!Action.list!") do (
    set "!Action.matrix!_%%a-%%b=%%c"
    set "Action.list=%%e"
)
set /a "Action.count-=1"
exit /b 0


:Action.update_list
call :Side_text.add "!Log_top!"
set "_temp_list=!Action.list!"
for /l %%n in (1,1,!Action.display_lines!) do if defined _temp_list (
    for /f "tokens=1-4* delims=-" %%a in ("!_temp_list!") do (
        call :Side_text.add "!vBorder! !ALPHABET:~%%a,1!%%b | %%c -> %%d !vBorder!"
        set "_temp_list=%%e"
    )
) else call :Side_text.add "!vBorder!             !vBorder!"
call :Side_text.add "!Log_bottom!"
set "_temp_list="
exit /b 0

rem ======================================== State ========================================

:State.reset   matrix_name
for /l %%n in (!State.count!,-1,1) do (
    for %%v in (array actionLog Action.count) do set "State_%%n.%%v="
)
set "stateMatrix=%~1"
set "State.count=0"
exit /b 0


:State.save   [matix_name]
set /a "State.count+=1"
if "%~1" == "" (
    call :Matrix.to_array !stateMatrix! State_!State.count!.array
) else set "State_!State.count!.array=!%~1!"
set "State_!State.count!.actionLog=!actionLog!"
set "State_!State.count!.Action.count=!Action.count!"
exit /b 0


:State.load
if "!State.count!" == "0" exit /b 0
call :Matrix.create !stateMatrix! State_!State.count!.array 1
set "actionLog=!State_%State.count%.actionLog!"
set "Action.count=!State_%State.count%.Action.count!"
for %%v in (array actionLog Action.count) do set "State_!State.count!.%%v="
set /a "State.count-=1"
exit /b 0

rem ======================================== Side_text ========================================

:Side_text.add   [--clear] [--info:matrix_name] [text [...]]
for %%w in (!Side_text.width!) do for %%a in (%*) do (
    set "_text=%%~a"
    if /i "!_text:~0,7!" == "--info:" for /f "tokens=1* delims=:" %%b in ("%%a") do (
        call :Matrix.count empty_cells %%~c " "
        set /a "given_cells= !total_cells! - !empty_cells!"
        call :Side_text.add "Puzzle Information" ^
            "Name    : !selected.name!" ^
            "Givens  : !given_cells!"
    )
    if /i "%%a" == "--clear" (
        for /l %%h in (1,1,!Side_text.height!) do set "Side_text.line%%h="
        set "Side_text.pointer=1"
        set "_text="
    )
    for /l %%h in (!Side_text.pointer!,1,!Side_text.height!) do if defined _text (
        set "Side_text.line%%h=!_text:~0,%%w!"
        set "_text=!_text:~%%w!"
        set /a "Side_text.pointer+=1"
    )
)
set "_text="
goto :EOF

rem ======================================== Cell ========================================

:Cell.decode   return_var  cell_code
set "_code=%~2"
set "_row="
set "_col="
for /l %%n in (1,1,!grid_size!) do if not defined _row (
    if /i "!_code:~0,1!" == "!ALPHABET:~%%n,1!" (
        set "_row=%%n"
        set /a "_col=!_code:~1!" 2> nul || exit /b 1
    )
    if /i "!_code:~-1,1!" == "!ALPHABET:~%%n,1!" (
        set "_row=%%n"
        set /a "_col=!_code:~0,-1!" 2> nul || exit /b 1
    )
)
set "%~1="
for %%n in ("!_row!" "!_col!") do (
    if %%~n LSS 1 exit /b 1
    if %%~n GTR !grid_size! exit /b 1
)
set "%~1=!_row!-!_col!"
exit /b 0


:Cell.random   matix_name <--filled | --empty> [list_size]
set "cell_list="
set "_list="
set "_count=0"
for %%c in (!Cells_all!) do (
    set "_cell="
    if /i "%2" == "--empty" if "!%~1_%%c!" == " " set "_cell=%%c"
    if /i "%2" == "--filled" if not "!%~1_%%c!" == " " set "_cell=%%c"
    for %%d in (!_cell!) do (
        set "_cell=     %%c"
        set "_list=!_list!!_cell:~-5,5!"
        set /a "_count+=1"
    )
)
set "_index=1"
if not "%3" == "" set /a "_index=!_count! - %3 + 1"
for /l %%l in (!_count!,-1,!_index!) do (
    set /a "_index=!random! %% %%l"
    set /a "_index*=5"
    for %%n in (!_index!) do (
        set "_index=!_list:~%%n,5!"
        set "cell_list=!cell_list! !_index: =!"
        set "_list=!_list:~%%n!!_list:~0,%%n!"
        set "_list=!_list:~5!"
    )
)
exit /b 0


:Cell.move   variable_name  up|down|left|right|next|back
for /f "tokens=1,2 delims=-" %%a in ("!%~1!") do (
    set "_row=%%a"
    set "_col=%%b"
    if /i "%~2" == "back"   set /a "_col-=1"
    if /i "%~2" == "next"   set /a "_col+=1"
    if !_col! LSS 1             set /a "_row-=1"
    if !_col! GTR !grid_size!   set /a "_row+=1"
    if /i "%~2" == "up"     set /a "_row-=1"
    if /i "%~2" == "down"   set /a "_row+=1"
    if /i "%~2" == "left"   set /a "_col-=1"
    if /i "%~2" == "right"  set /a "_col+=1"
    if !_row! LSS 1             set "_row=!grid_size!"
    if !_row! GTR !grid_size!   set "_row=1"
    if !_col! LSS 1             set "_col=!grid_size!"
    if !_col! GTR !grid_size!   set "_col=1"
)
set "%~1=!_row!-!_col!"
goto :EOF

rem ############################################################################
rem Library
rem ############################################################################

:lib.dependencies [return_prefix]
set %~1install_requires= ^
    ^ rand strlen strip_dquotes ^
    ^ difftime ftime diffdate ^
    ^ check_path watchvar download_file ^
    ^ get_os hex2str capchar color2seq ^
    ^ clear_line_macro get_con_size ^
    ^ updater argparse ^
    ^ %=END=%
exit /b 0


:lib.legacy_support
    :__init__ > nul 2> nul
    @goto module.entry_point
    :module.entry_point   [--module=<name>]  [args]
    :scripts.lib
exit /b 0


:menuopts.list <list_var> <text_fmt>
setlocal EnableDelayedExpansion
set "_list_var=%~1"
set "_text_fmt=%~2"
call set "_text_fmt=%%_text_fmt:{=^!%%"
call set "_text_fmt=%%_text_fmt:}=^!%%"
set "_count=0"
for %%n in (!%_list_var%!) do (
    set "_text=!_text_fmt!"
    set /a "_count+=1"
    set "_count=   !_count!"
    for %%i in ("!_count!") do set "_text=!_text:$n=%%~i!"
    set "_text=!_text:$i=%%n!"
    call :menuopts.list._display
)
exit /b 0
#+++

:menuopts.list._display
echo %_text%
exit /b 0
#+++

:menuopts.get <return_var> <list_var> <number>
setlocal EnableDelayedExpansion
set "_return_var=%~1"
set "_list_var=%~2"
set "_number=%~3"
set "_count=0"
set "_result="
for %%n in (!%_list_var%!) do if not defined _result (
    set /a "_count+=1"
    if "!_number!" == "!_count!" set "_result=%%n"
)
for /f "tokens=1* delims= " %%q in ("Q !_result!") do (
    endlocal
    set "%_return_var%=%%r"
    if not defined %_return_var% exit /b 3
)
exit /b 0


rem ======================================== Assets ========================================

:assets
rem Additional data to bundle
exit /b 0

rem ======================================== Style ========================================

:Style.load
set "Style.list=lines_n_pipes boxchar"
set "Style_lines_n_pipes.name=Lines & Pipes"
set "Style_boxchar.name=Box Characters"
set "_found="
if defined preferred.style for %%s in (!Style.list!) do if /i "!preferred.style!" == "%%s" set "_found=true"
if not defined _found set "preferred.style="
if not defined preferred.style for %%s in (!Style.list!) do set "preferred.style=%%s"
exit /b 0


rem ======================== Lines & Pipes ========================

:Style_lines_n_pipes.charset
set "hLine=-"
set "vLine=|"
set "cLine=+"
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


:Style_lines_n_pipes.splash_screen
echo %DQ%                 ____   _    _   ___     _____   _   _  _    _
echo %DQ%                //  \\  ||  ||  || \\   //   \\  || //  ||  ||
echo %DQ%                \\___   ||  ||  ||  \\  ||   ||  ||//   ||  ||
echo %DQ%                _   \\  ||  ||  ||  //  ||   ||  ||\\   ||  ||
echo %DQ%                \\__//  \\__//  ||_//   \\___//  || \\  \\__//  !SOFTWARE.VERSION!
echo %DQ%
echo %DQ%                        _______________________________
echo %DQ%                        |        Made by wthe22       |
echo %DQ%                        | http://winscr.blogspot.com/ |
echo %DQ%                        |_____________________________|
goto :EOF

rem ======================== Box Characters ========================

:Style_boxchar.charset
rem            UTF8 ANSI   ALT+KEY
set hLine=      C4  CE94    0196
set vLine=      B3  C2B3    0179
set cLine=      C5  CE95    0197
set hBorder=    CD  CE9D    0205
set vBorder=    BA  CE8A    0186
set cBorder=    CE  CE9E    0206
set uEdge=      CB  CE9B    0203
set dEdge=      CA  CE9A    0202
set lEdge=      CC  CE9C    0204
set rEdge=      B9  CE89    0185
set ulCorner=   C9  CE99    0201
set urCorner=   BB  C2BB    0187
set dlCorner=   C8  CE98    0200
set drCorner=   BC  CE8C    0188
for %%v in (
    hLine vLine cLine
    hBorder vBorder cBorder
    uEdge dEdge lEdge rEdge
    ulCorner urCorner dlCorner drCorner
) do for /f "tokens=1" %%c in ("!%%v!") do set "%%v=%%c"
call :hex2str ^
    ^ hLine vLine cLine ^
    ^ hBorder vBorder cBorder ^
    ^ uEdge dEdge lEdge rEdge ^
    ^ ulCorner urCorner dlCorner drCorner ^
    ^ %=END=%
exit /b 0


:Style_boxchar.splash_screen
call 2> "!tmp_dir!\_boxchar.hex"
for %%h in (
    B2B2B2B2B220B2202020B220B2B2B2B22020B2B2B2B2B220B22020B2B220B2202020B20D0A.name
    B22020202020B2202020B220B2202020B220B2202020B220B220B2B22020B2202020B20D0A.name
    B2B2B2B2B220B2202020B220B2202020B220B2202020B220B2B2B2202020B2202020B20D0A.name
    20202020B220B2202020B220B2202020B220B2202020B220B220B2B22020B2202020B20D0A.name
    B2B2B2B2B220B2B2B2B2B220B2B2B2B22020B2B2B2B2B220B22020B2B220B2B2B2B2B2202021534F4654574152455F56455253494F4E210D0A.name
    6563686F3D0D0A
    C9CDCDCDCDCDCBCDCDCDCDCDCBCDCDCDCDCDBB0D0A.sudoku
    BA20B338B320BA20B320B333BA20B339B320BA0D0A.sudoku
    BA35B320B333BA37B320B320BA38B334B320BA0D0A.sudoku
    BA20B334B336BA20B320B332BA20B320B335BA0D0A.sudoku
    CCCDCDCDCDCDCECDCDCDCDCDCECDCDCDCDCDB90D0A.sudoku
    BA34B336B331BA20B320B337BA20B320B339BA0D0A.sudoku
    BA20B333B320BA20B320B320BA20B331B320BA0D0A.sudoku
    BA32B320B320BA31B320B320BA36B338B333BA0D0A.sudoku
    CCCDCDCDCDCDCECDCDCDCDCDCECDCDCDCDCDB90D0A.sudoku
    BA31B320B320BA39B320B320BA37B332B320BA0D0A.sudoku
    BA20B339B334BA20B320B338BA35B320B331BA0D0A.sudoku
    BA20B332B320BA34B320B320BA20B333B320BA0D0A.sudoku
    C8CDCDCDCDCDCACDCDCDCDCDCACDCDCDCDCDBC0D0A.sudoku
    6563686F3D0D0A
    C9CDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDBB0D0A.textbox
    BA202020202020202020204D6164652062792077746865323220202020202020202020BA0D0A.textbox
    BA202020687474703A2F2F77696E7363722E626C6F6773706F742E636F6D2F20202020BA0D0A.textbox
    C8CDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDCDBC0D0A.textbox
) do (
    if /i "%%~xh" == ".name" < nul set /p "=6563686F2020202020202020202020202020202020202020202020"
    if /i "%%~xh" == ".sudoku" < nul set /p "=6563686F2020202020202020202020202020202020202020202020202020202020202020"
    if /i "%%~xh" == ".textbox" < nul set /p "=6563686F2020202020202020202020202020202020202020202020"
    echo=%%~nh
) >> "!tmp_dir!\_boxchar.hex"
if exist "!tmp_dir!\_boxchar.bat" del /f /q "!tmp_dir!\_boxchar.bat"
certutil -decodehex "!tmp_dir!\_boxchar.hex" "!tmp_dir!\_boxchar.bat" > nul 2> nul
call "!tmp_dir!\_boxchar.bat"
goto :EOF


rem ======================================== Difficulty ========================================

:Difficulty.load
set "Difficulty.list=beginner practice easy random"
set "Difficulty_beginner.name=Beginner"
set "Difficulty_practice.name=Easy Practice"
set "Difficulty_easy.name=Easy"
set "Difficulty_random.name=Random"
exit /b 0


:Difficulty_beginner
set "method_used=2"
set /a "min_givens=!total_cells! * 2 / 3"
set /a "max_givens=!total_cells! * 3 / 4"
call :rand targetGivens "!total_cells! * 2 / 3"   "!total_cells! * 3 / 4"
exit /b 0


:Difficulty_practice
set "method_used=2"
set /a "min_givens=!total_cells! * 2 / 5 + 1"
set /a "max_givens=!total_cells! * 2 / 3"
call :rand targetGivens "!total_cells! * 4 / 9"   "!total_cells! * 5 / 9"
exit /b 0


:Difficulty_easy
set "method_used=2"
set /a "min_givens=!total_cells! / 5 + 1"
set /a "max_givens=!total_cells! * 2 / 5 + 1"
set "targetGivens=0"
exit /b 0


:Difficulty_random
set "method_used=BF"
set /a "min_givens=!total_cells! / 5 + 1"
set /a "max_givens=!total_cells! * 2 / 5 + 1"
set "targetGivens=0"
exit /b 0

rem ================================ Built-in Sudoku ================================
:assets.sudoku.__init__
exit /b 0


rem Add new list:
rem #sudoku [Size] [Name]
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
#end

#sudoku 3x3 Escargot
1....7.9..3..2...8..96..5....53..9...1..8...26....4...3......1..4......7..7...3..

#sudoku 3x3 Arto Inkala
8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..

#sudoku 3x3 SudokuWiki Unsolvable #28
600008940900006100070040000200610000000000200089002000000060005000000030800001600
#end


rem ############################################################################
rem End
rem ############################################################################

:EOF
@rem DO NOT WRITE ANYTHING YOU NEED TO KEEP BELOW THIS FUNCTION.
@rem ANYTHING BEYOND THIS FUNCTION WILL BE REMOVED WHEN ADDING DEPENDENCIES.
exit /b


:: Automatically Added by batchlib 3.0b3 on Mon 09/20/2021 20:09:32.32

:rand <return_var> <minimum> <maximum>
set /a "%~1=((!random!<<16) + (!random!<<1) + (!random!>>14)) %% ((%~3)-(%~2)+1) + (%~2)"
exit /b 0


:strip_dquotes <input_var>
if "!%~1:~0,1!!%~1:~-1,1!" == ^"^"^"^" set "%~1=!%~1:~1,-1!"
exit /b 0


:difftime <return_var> <end_time> [start_time] [--no-fix]
set "%~1=0"
for %%t in ("%~2.0" "%~3.0") do for /f "tokens=1-4 delims=:., " %%a in ("%%~t.0.0.0.0") do (
    set /a "%~1+=(1%%a*2-2%%a)*360000 + (1%%b*2-2%%b)*6000 + (1%%c*2-2%%c)*100 + (1%%d*2-2%%d)*100/(2%%d-1%%d)"
    set /a "%~1*=-1"
)
if /i not "%4" == "--no-fix" if "!%~1:~0,1!" == "-" set /a "%~1+=8640000"
exit /b 0


:ftime <return_var> <centiseconds>
setlocal EnableDelayedExpansion
set "_result="
set /a "_remainder=%~2"
for %%s in (360000 6000 100 1) do (
    set /a "_digits=!_remainder! / %%s + 100"
    set /a "_remainder%%= %%s"
    set "_result=!_result!!_digits:~-2,2!:"
)
set "_result=!_result:~0,-4!.!_result:~-3,2!"
for /f "tokens=*" %%r in ("!_result!") do (
    endlocal
    set "%~1=%%r"
)
exit /b 0


:diffdate <return_var> <end_date> [start_date]
setlocal EnableDelayedExpansion
set "_difference=0"
set "_args=/%~2"
if "%~3" == "" (
    set "_args=!_args! /1/01/1970"
) else set "_args=!_args! /%~3"
set "_args=!_args:/ =/!"
set "_args=!_args:/0=/!"
for %%d in (!_args!) do for /f "tokens=1-3 delims=/" %%a in ("%%d") do (
    set /a "_difference+=(%%c-1970)*365 + (%%c/4 - %%c/100 + %%c/400 - 477) + (336 * (%%a-1) + 7) / 11 + %%b - 2"
    if %%a LEQ 2 set /a "_difference+=2-(((%%c %% 4)-8)/-8)*((((%%c %% 400)-512)/-512)+((((%%c %% 100)-128)/-128)-1)/-1)"
    set /a "_difference*=-1"
)
for /f "tokens=*" %%r in ("!_difference!") do (
    endlocal
    set "%~1=%%r"
)
exit /b 0


:check_path [-e|-n] [-f|-d] <path_var>
setlocal EnableDelayedExpansion EnableExtensions
for %%v in (_require_attrib  _require_exist) do set "%%v="
call :argparse ^
    ^ "#1:store                     :_path_var" ^
    ^ "-e,--exist:store_const       :_require_exist=true" ^
    ^ "-n,--not-exist:store_const   :_require_exist=false" ^
    ^ "-f,--file:store_const        :_require_attrib=-" ^
    ^ "-d,--directory:store_const   :_require_attrib=d" ^
    ^ -- %* || exit /b 2
set "_path=!%_path_var%!"
if "!_path:~0,1!!_path:~-1,1!" == ^"^"^"^" set "_path=!_path:~1,-1!"
if not defined _path ( 1>&2 echo%0: Path not defined & exit /b 3 )
set "_temp=!_path!"
if "!_path:~1,1!" == ":" set "_temp=!_path:~0,1!!_path:~2!"
for /f tokens^=1-2*^ delims^=:?^"^<^>^| %%a in ("Q?_!_temp!_") do (
    if not "%%c" == "" ( 1>&2 echo%0: Invalid path characters & exit /b 3 )
)
for /f "tokens=1-2* delims=*" %%a in ("Q*_!_temp!_") do (
    if not "%%c" == "" ( 1>&2 echo%0: Wildcards are not allowed & exit /b 3 )
)
if "!_path:~1!" == ":" set "_path=!_path!\"
set "_file_exist=false"
for %%f in ("!_path!") do (
    set "_path=%%~ff"
    set "_attrib=%%~af"
)
if defined _attrib (
    set "_attrib=!_attrib:~0,1!"
    set "_file_exist=true"
)
if "!_attrib!" == "d" (
    for %%f in ("!_path!\.") do set "_path=%%~ff"
)
if defined _require_exist if not "!_file_exist!" == "!_require_exist!" (
    if "!_require_exist!" == "true" 1>&2 echo%0: Input does not exist
    if "!_require_exist!" == "false" 1>&2 echo%0: Input already exist
    exit /b 2
)
if "!_file_exist!" == "true" if defined _require_attrib if not "!_attrib!" == "!_require_attrib!" (
    if defined _require_exist (
        if "!_require_attrib!" == "d" 1>&2 echo%0: Input is not a folder
        if "!_require_attrib!" == "-" 1>&2 echo%0: Input is not a file
    ) else (
        if "!_require_attrib!" == "d" 1>&2 echo%0: Input must be a new or existing folder, not a file
        if "!_require_attrib!" == "-" 1>&2 echo%0: Input must be a new or existing file, not a folder
    )
    exit /b 2
)
for /f "tokens=* delims=" %%c in ("!_path!") do (
    endlocal
    set "%_path_var%=%%c"
)
exit /b 0


:watchvar [-i] [-n]
setlocal EnableDelayedExpansion EnableExtensions
cd /d "!tmp_dir!" 2> nul || cd /d "!tmp!"
for %%d in ("watchvar") do (
    if not exist "%%~d" md "%%~d"
    cd /d "%%~d"
)
for %%x in (txt hex) do (
    if exist "old.%%x" del /f /q "old.%%x"
    if exist "latest.%%x" ren "latest.%%x" "old.%%x"
)
(
    endlocal
    set > "%cd%\latest.txt"
    setlocal EnableDelayedExpansion EnableExtensions
    cd /d "%cd%"
)
for %%v in (_init_only  _list_names) do set "%%v="
call :argparse ^
    ^ "-i,--initialize:store_const  :_init_only=true" ^
    ^ "-n,--name:store_const        :_list_names=true" ^
    ^ -- %* || exit /b 2
rem Convert to hex and format
call :hexlify "latest.txt" > "latest.hex.tmp"
> "latest.hex" (
    for /f "usebackq tokens=*" %%o in ("latest.hex.tmp") do (
        set "_hex=%%o"
        set "_hex=!_hex:3d=#_!"
        set "_hex=!_hex: =!"
        for /f "tokens=1* delims=#" %%a in ("!_hex!") do (
            set "_hex=%%a 3d %%b"
            set "_hex=!_hex:#=3d!"
            set "_hex=!_hex:_=!"
        )
        echo=!_hex!
    )
)

rem Count variable
set "_var_count=0"
for /f "usebackq tokens=*" %%o in ("latest.hex") do set /a "_var_count+=1"

if defined _init_only (
    echo Initial variables: !_var_count!
    exit /b 0
)

set "_new_sym=+"
set "_deleted_sym=-"
set "_changed_sym=~"
set "_new_hex_=6E6577"
set "_deleted_hex=64656C65746564"
set "_changed_hex=6368616E676564"
set "_states=new deleted changed"

rem Compare variables
for %%s in (!_states!) do set "_%%s_count=0"
> "changes.hex" (
    for /f "usebackq tokens=1-3 delims= " %%a in ("latest.hex") do (
        set "_old_value="
        for /f "usebackq tokens=1-3 delims= " %%x in ("old.hex") do if "%%a" == "%%x" set "_old_value=%%z"
        if defined _old_value (
            if not "%%c" == "!_old_value!" (
                set /a "_changed_count+=1"
                echo !_changed_hex!20 %%a 0D0A
            )
        ) else (
            echo !_new_hex_!20 %%a 0D0A
            set /a "_new_count+=1"
        )
    )
    for /f "usebackq tokens=1 delims= " %%a in ("old.hex") do (
        set "_value_found="
        for /f "usebackq tokens=1 delims= " %%x in ("latest.hex") do if "%%a" == "%%x" set "_value_found=true"
        if not defined _value_found (
            echo !_deleted_hex!20 %%a 0D0A
            set /a "_deleted_count+=1"
        )
    )
)
if exist "changes.txt" del /f /q "changes.txt"
certutil -decodehex "changes.hex" "changes.txt" > nul

if defined _list_names (
    echo Variables: !_var_count!
    for %%s in (!_states!) do if not "!_%%s_count!" == "0" (
         < nul set /p "=[!_%%s_sym!!_%%s_count!] "
        for /f "usebackq tokens=1* delims= " %%a in ("changes.txt") do (
            if "%%a" == "%%s" < nul set /p "=%%b "
        )
        echo=
    )
) else echo Variables: !_var_count! [+!_new_count!/~!_changed_count!/-!_deleted_count!]
exit /b 0


:hex2str <var> ...
setlocal EnableDelayedExpansion
cd /d "!tmp_dir!" 2> nul || cd /d "!tmp!"
set "_var_count=0"
for %%v in (%*) do (
    set /a "_var_count+=1"
    set "_hex2str_!_var_count!=%%v"
)
> ".hex2str._unfilled" (
    for %%v in (%*) do echo set "%%v="
)
call :hexlify ".hex2str._unfilled" > ".hex2str._unfilled.hex"
> ".hex2str.bat.hex" (
    set "_var_count=0"
    for /f "usebackq tokens=* delims=" %%a in (".hex2str._unfilled.hex") do (
        set /a "_var_count+=1"
        for %%i in (!_var_count!) do for %%v in (!_hex2str_%%i!) do (
            set "_hex=%%a"
            echo !_hex:~0,-8!!%%v!!_hex:~-8,8!
        )
    )
)
if exist ".hex2str.bat" del /f /q ".hex2str.bat"
certutil -decodehex ".hex2str.bat.hex" ".hex2str.bat" > nul 2> nul
for %%f in (".hex2str.bat") do (
    endlocal
    call "%%~ff"
)
exit /b 0


:hexlify <input_file> <output_file> [--eol hex]
setlocal EnableDelayedExpansion EnableExtensions
for %%v in (_input_file _output_file) do set "%%v="
set "_eol=0d 0a"
call :argparse ^
    ^ "#1:store         :_input_file" ^
    ^ "#2:store         :_output_file" ^
    ^ "-e,--eol:store   :_eol" ^
    ^ -- %* || exit /b 2
for %%v in (_input_file _output_file) do for %%f in ("!%%v!") do set "%%v=%%~ff"
call :strlen _eol_len _eol
cd /d "!tmp_dir!" 2> nul || cd /d "!tmp!"
if exist "raw_hex" del /f /q "raw_hex"
certutil -encodehex "!_input_file!" "raw_hex" > nul || (
    1>&2 echo%0: encode failed exit /b 3
)
rem Group hex according to EOL
set "_hex="
for /f "usebackq tokens=1*" %%a in ("raw_hex") do (
    set "_input=%%b"
    set "_hex=!_hex! !_input:~0,48!"
    if not "!_hex:~7680!" == "" call :hexlify._format
)
call :hexlify._format
echo=!_hex!
exit /b 0
#+++

:hexlify._format
set "_hex=!_hex!$"
set "_hex=!_hex:  = !"
set _hex=!_hex:%_eol%=%_eol%^
%=REQUIRED=%
!
for /f "tokens=*" %%a in ("!_hex!") do (
    set "_hex=%%a"
    if /i "!_hex:~-%_eol_len%,%_eol_len%!" == "%_eol%" echo !_hex!
)
if not "!_hex:~7680!" == "" (
    < nul set /p "=!_hex:~0,-3!"
    set "_hex=!_hex:~-3,3!"
)
set "_hex=!_hex:~0,-1!"
exit /b


:strlen <return_var> <input_var>
set "%~1=0"
if defined %~2 (
    for /l %%b in (12,-1,0) do (
        set /a "%~1+=(1<<%%b)"
        for %%i in (!%~1!) do if "!%~2:~%%i,1!" == "" set /a "%~1-=(1<<%%b)"
    )
    set /a "%~1+=1"
)
exit /b 0


:color2seq <return_var> <color>
set "%~1=%~2"
set "%~1=[!%~1:~0,1!;!%~1:~1,1!m"
for %%t in (
    0--40-30  1--44-34  2--42-32  3--46-36
    4--41-31  5--45-35  6--43-33  7--47-37
    8-100-90  9-104-94  A-102-92  B-106-96
    C-101-91  D-105-95  E-103-93  F-107-97
) do for /f "tokens=1-3 delims=-" %%a in ("%%t") do (
    set "%~1=!%~1:[%%a;=[%%b;!"
    set "%~1=!%~1:;%%am=;%%cm!"
)
exit /b 0


:clear_line_macro <return_var> <width>
setlocal EnableDelayedExpansion
set "_return_var=%~1"
set "_width=%~2"
if not defined _width set "_width=80"
call :capchar CR BACK
call :get_os _os
for /f "tokens=1 delims=. " %%a in ("!_os!") do set "_os=%%a"
set "_result="
if !_os! GEQ 10 (
    for /l %%n in (1,1,%_width%) do set "_result=!_result! "
    set "_result=_!CR!!_result!!CR!"
) else for /l %%n in (1,1,%_width%) do set "_result=!_result!!BACK!"
for /f "tokens=1-2 delims=:" %%q in ("Q:!_result!:Q") do (
    endlocal
    set "%_return_var%=%%r"
)
exit /b 0


:capchar <char> ...
setlocal EnableDelayedExpansion
for %%v in (
    BEL BS ESC TAB CR LF
    BASE BACK DQ NL
) do set "%%v="
for %%a in (%*) do set "%%a=true"
for %%a in (
    "BASE: BS"
    "BACK: BS"
    "DQ: BS"
    "NL: LF"
) do for /f "tokens=1* delims=:" %%b in (%%a) do (
    if defined %%b for %%v in (%%c) do set "%%v=true"
)
endlocal & (
if /i "%BEL%" == "true" for /f "usebackq delims=" %%a in (
    `forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo 0x07"`
) do set "BEL=%%a"
if /i "%CR%" == "true" for /f %%a in ('copy /z "%ComSpec%" nul') do set "CR=%%a"
if /i "%LF%" == "true" set LF=^
%=REQUIRED=%
%=REQUIRED=%
if /i not "%BS%" == "" for /f %%a in ('"prompt $H & for %%b in (1) do rem"') do set "BS=%%a"
if /i not "%TAB%" == "" for /f "delims= " %%t in ('robocopy /l . . /njh /njs') do set "TAB=%%t"
if /i not "%ESC%" == "" for /f %%a in ('"prompt $E & for %%b in (1) do rem"') do set "ESC=%%a"
if /i not "%BASE%" == "" set "BASE=_!BS! !BS!"
if /i not "%BACK%" == "" set "BACK=!BS! !BS!"
if /i not "%DQ%" == "" set DQ="!BS! !BS!
if /i not "%NL%" == "" set "NL=^^!LF!!LF!^^"
)
exit /b 0


:get_os <return_var> [--name]
for /f "tokens=4 delims=[] " %%v in ('ver') do set "%~1=%%v"
if /i "%~2" == "--name" (
    for /f "tokens=1-2 delims=." %%a in ("!%~1!") do set "%~1=%%a.%%b"
    if "!%~1!" == "10.0" set "%~1=Windows 10"
    if "!%~1!" == "6.3" set "%~1=Windows 8.1"
    if "!%~1!" == "6.2" set "%~1=Windows 8"
    if "!%~1!" == "6.1" set "%~1=Windows 7"
    if "!%~1!" == "6.0" set "%~1=Windows Vista"
    if "!%~1!" == "5.2" set "%~1=Windows XP 64-Bit"
    if "!%~1!" == "5.1" set "%~1=Windows XP"
    if "!%~1!" == "5.0" set "%~1=Windows 2000"
)
exit /b 0


:get_con_size <width_return_var> <height_return_var>
setlocal EnableDelayedExpansion
set "_index=0"
for /f "usebackq tokens=2 delims=:" %%a in (`call ^| mode con`) do (
    set /a "_index+=1"
    if "!_index!" == "1" set /a "_height=%%a"
    if "!_index!" == "2" set /a "_width=%%a"
)
set "_index="
for /f "tokens=1-2 delims=x" %%a in ("!_width!x!_height!") do (
    endlocal
    set "%~1=%%a"
    set "%~2=%%b"
)
exit /b 0


:updater [-n] [-y] [-f] [-u url] <script_path>
setlocal EnableDelayedExpansion
for %%v in (_assume_yes _notify_only _force _dl_url) do set "%%v="
call :argparse ^
    ^ "#1:store                     :_this" ^
    ^ "-n,--notify-only:store_const :_notify_only=true" ^
    ^ "-y,--yes:store_const         :_assume_yes=true" ^
    ^ "-f,--force:store_const       :_force=true" ^
    ^ "-u,--download-url:store      :_dl_url" ^
    ^ -- %* || exit /b 2
for %%f in ("!_this!") do set "_this=%%~ff"
cd /d "!tmp_dir!" 2> nul || cd /d "!tmp!"
set "_other=!cd!\.updater.downloaded.bat"
call "!_this!" -c :metadata _this. || (
    1>&2 echo%0: Fail to read metadata & exit /b 3
)
if not defined _dl_url set "_dl_url=!_this.download_url!"
if not defined _dl_url (
    1>&2 echo%0: No download url found & exit /b 3
)
call :download_file "!_dl_url!" "!_other!" || (
    1>&2 echo%0: Download failed & exit /b 3
)
call "!_other!" -c :metadata _other. || (
    1>&2 echo%0: Fail to read downloaded metadata & exit /b 4
)
if not "!_other.name!" == "!_this.name!" (
    1>&2 echo%0: warning: Script name is different: '!_this.name!' and '!_other.name!'
)
call :parse_version _this._p_ver "!_this.version!"
call :parse_version _other._p_ver "!_other.version!"
if "!_other._p_ver!" LSS "!_this._p_ver!" (
    echo No updates are available
) else if "!_other._p_ver!" == "!_this._p_ver!" (
    echo You are using the latest version
) else (
    echo !_this.name! !_this.version! upgradable to !_other.name! !_other.version!
)
if not defined _force (
    if "!_other._p_ver!" LEQ "!_this._p_ver!" exit /b 5
)
if defined _notify_only exit /b 0
if not defined _assume_yes (
    call :Input.yesno -d "N" -m "Proceed with update? [y/N] " || exit /b 5
)
(
    copy /b /y /v "!_other!" "!_this!" > nul
) && (
    echo Update success
    exit /b 0
) || exit /b 6
exit /b 1


:download_file <url> <save_path>
if exist "%~2" del /f /q "%~2"
if not exist "%~dp2" md "%~dp2"
powershell -Command "(New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
if not exist "%~2" exit /b 1
exit /b 0


:ext.powershell
powershell -Command "$PSVersionTable.PSVersion.ToString()"
exit /b


:parse_version <return_var> <version>
set "%~1="
setlocal EnableDelayedExpansion
set "_version=#%~2"
set "_version=!_version:+=+#!"
for /f "tokens=1* delims=+" %%a in ("!_version!") do (
    set "_public=%%a"
    set "_local=+%%b"
    if "!_local!" == "+" (
        set "_local="
    ) else set "_local=!_local:+#=+!"
)
for %%t in (
    " ="
    ".= " "-=" "_="
    "alpha=a"
    "beta=b"
    "preview=c" "pre=c" "rc=c"
    "post=p" "rev=p" "r=p"
    "dev=d"
) do set "_public=!_public:%%~t!"
for %%s in (a b c p d) do (
    set "_public=!_public:%%s= %%s!"
    set "_public=!_public:%%s =%%s!"
)
set "_public=!_public:~1!"
set "_result="
set "_buffer="
for %%s in (!_public!) do (
    set "_segment=%%s"
    set "_type="
    set "_number="
    if "!_segment:~0,1!" GTR "9" (
        for %%t in (
            "D:p"
            "Ba:a" "Bb:b" "Bc:c"
            "A:d"
        ) do for /f "tokens=1-2 delims=:" %%a in (%%t) do (
            if "!_segment:~0,1!" == "%%b" set "_type=%%a"
        )
        set "_number=!_segment:~1!"
    )
    if not defined _type (
        set "_type=E"
        set "_number=!_segment!"
    )
    if not defined _number set "_number=0"
    set "_evaluated="
    set /a "_evaluated=!_number!" || ( 1>&2 echo error: failed to evaluate number & exit /b 2 )
    set /a "_number=!_evaluated!" || ( 1>&2 echo error: failed to evaluate number & exit /b 2 )
    set "_number=000!_number!"
    set "_number=!_number:~-3,3!"
    if not "!_type!" == "E" set "_buffer="
    set "_buffer=!_buffer!!_type!!_number!"
    if not "!_type!,!_number!" == "E,000" (
        set "_result=!_result!!_buffer!"
        set "_buffer="
    )
)
set "_result=F000!_result!C"
if defined _local (
    set "_local=!_local:~1!"
    set "_is_number="
    if defined _local (
        set "_temp=_!_local!"
        for %%c in (
            a b c d e f g h i j k l m
            n o p q r s t u v w x y z
            0 1 2 3 4 5 6 7 8 9 .
        ) do set "_temp=!_temp:%%c=!"
        if not "!_temp!" == "_" ( 1>&2 echo error: invalid local version identifier & exit /b 2 )

        set "_temp=_!_local!"
        for /l %%n in (0,1,9) do set "_temp=!_temp:%%n=!"
        if "!_temp!" == "_" set "_is_number=true"
    )
    if defined _is_number (
        for %%p in (10) do (
            for /l %%n in (1,1,%%p) do set "_local=0!_local!"
            set "_local=!_local:~-%%p,%%p!"
        )
        set "_local=B!_local!"
    ) else set "_local=A!_local!"
    set "_result=!_result!+!_local!"
)
for /f "tokens=*" %%r in ("!_result!") do (
    endlocal
    set "%~1=%%r"
)
exit /b 0


:Input.yesno [-m message] [-y value] [-n value] [-d default] [return_var]
setlocal EnableDelayedExpansion EnableExtensions
for %%v in (_return_var _message) do set "%%v="
set "_yes_value=Y"
set "_no_value=N"
call :argparse ^
    ^ "#1:store             :_return_var" ^
    ^ "-m,--message:store   :_message" ^
    ^ "-y,--yes:store       :_yes_value" ^
    ^ "-n,--no:store        :_no_value" ^
    ^ "-d,--default:store   :_default" ^
    ^ -- %* || exit /b 2
if not defined _message set "_message=Input !_return_var!? [y/n] "
call :Input.yesno._loop || exit /b 4
set "_result="
if /i "!user_input:~0,1!" == "Y" set "_result=!_yes_value!"
if /i "!user_input:~0,1!" == "N" set "_result=!_no_value!"
set "_result=^!!_result!"
set "_result=!_result:^=^^^^!"
set "_result=%_result:!=^^^!%"
for /f "delims= eol=" %%a in ("!_result!") do (
    endlocal
    if not "%_return_var%" == "" (
        set "%_return_var%=%%a"
        set "%_return_var%=!%_return_var%:~1!"
    )
    if /i "%user_input:~0,1%" == "Y" exit /b 0
    if /i "%user_input:~0,1%" == "N" exit /b 5
)
exit /b 1
#+++

:Input.yesno._loop
for /l %%# in (1,1,10) do for /l %%# in (1,1,10) do (
    set "user_input="
    set /p "user_input=!_message!"
    if defined _default (
        if not defined user_input set "user_input=!_default!"
    )
    if /i "!user_input:~0,1!" == "Y" exit /b 0
    if /i "!user_input:~0,1!" == "N" exit /b 0
)
echo%0: Too many invalid inputs
exit /b 1


:argparse [-i] [-s] <spec> ... -- [arg] ...
setlocal EnableDelayedExpansion
set LF=^
%=REQUIRED=%
%=REQUIRED=%
call :argparse._read_opts %* || exit /b 2
call :argparse._read_spec %* || exit /b 2
call :argparse._validate_specs || exit /b 2
call :argparse._generate_instructions %* || exit /b 3
call :argparse._exec_instructions || exit /b 3
exit /b 0
#+++

:argparse._read_opts %* -> {_shifts}
set "_._name=argparse"
for %%v in (_ignore_unknown _stop_nonopt) do set "_.%%v="
call :argparse._read_opts._parse ^
    ^ "-n,--name:store                  :_._name" ^
    ^ "-i,--ignore-unknown :store_const :_._ignore_unknown=true" ^
    ^ "-s,--stop-nonopt:store_const     :_._stop_nonopt=true" ^
    ^ -- %*
set "_shifts=!_opt_shifts!"
for %%v in (_name _ignore_unknown _stop_nonopt) do set "%%v=!_.%%v!"
exit /b 0
#+++

:argparse._read_opts._parse %* -> {_shifts}
set "_shifts=0"
call :argparse._read_spec %*
call :argparse._validate_specs || exit /b 2
set "_self_shifts=!_shifts!"
set "_ignore_unknown="
set "_stop_nonopt=true"
call :argparse._generate_instructions %* || exit /b 3
set /a "_opt_shifts=!_shifts! - !_argc! - !_self_shifts!"
call :argparse._exec_instructions || exit /b 3
exit /b 0
#+++

:argparse._read_spec %* {_shifts*} -> {_specs}
for /l %%n in (1,1,!_shifts!) do shift /1
set "_specs="
for /l %%# in (1,1,10) do for /l %%# in (1,1,10) do (
    call set _value=%%1
    if not defined _value (
        1>&2 echo argparse: Missing -- seperator
        exit /b 2
    )
    if "!_value!" == "--" (
        set /a "_shifts+=1"
        exit /b 0
    )
    call set _value=%%~1
    for /f "tokens=1-2* delims=: " %%b in ("!_value!") do (
        set "_specs=!_specs!%%b:%%c:%%d!LF!"
    )
    shift /1
    set /a "_shifts+=1"
)
exit /b 1
#+++

:argparse._generate_instructions %* {_shifts*} {_specs} -> {_instructions} {_argc}
for /l %%i in (1,1,!_shifts!) do shift /1
set "_instructions="
set "_argc=0"
set "_stop_opt_parsing="
for /l %%# in (1,1,20) do for /l %%# in (1,1,20) do (
    call set _value=%%1
    if not defined _value exit /b 0
    set "_op="
    set "_for_next_use="
    set "_parse_opt="
    if not defined _stop_opt_parsing if "!_value!" == "--" (
        set "_stop_opt_parsing=true"
        set "_op=pass"
    )
    if not defined _stop_opt_parsing (
        if "!_value:~0,1!" == "-" set "_parse_opt=true"
    )
    if defined _parse_opt (
        for /f "tokens=1-2* delims=:" %%b in ("!_specs!") do ( rem
        ) & if not defined _op ( rem
            for %%f in (%%b) do if "!_value!" == "%%f" set _op="%%c:%%d"
            if defined _op (
                for %%a in (store append) do if "%%c" == "%%a" (
                    set "_for_next_use=true"
                )
            )
        )
        if not defined _ignore_unknown if not defined _op (
            1>&2 echo !_name!: Unknown option '!_value!'
            exit /b 3
        )
    )
    if not defined _op (
        if defined _stop_nonopt (
            if not defined _stop_opt_parsing set "_stop_opt_parsing=true"
        )
        set /a "_argc+=1"
        for /f "tokens=1* delims=:" %%a in ("!_specs!") do ( rem
        ) & if not defined _op (
            for %%t in (# #!_argc!) do (
                if "%%a" == "%%t" set _op="%%b"
            )
        )
    )
    if defined _for_next_use (
        set "_instructions=!_instructions! shift"
        shift /1
        set /a "_shifts+=1"
        call set _value=%%1
        if not defined _value (
            1>&2 echo !_name!: Expected argument for last option
            exit /b 2
        )
    )
    set "_instructions=!_instructions! !_op! shift"
    shift /1
    set /a "_shifts+=1"
)
echo argparse: Too many arguments
exit /b 1
#+++

:argparse._exec_instructions {_instructions}
(
    for /l %%i in (1,1,2) do goto 2> nul
    for %%i in (%_instructions%) do ( rem
    ) & for /f "tokens=1* delims=:" %%c in ("%%~i") do (
        if /i "%%c" == "append" (
            call set %%d=^!%%d^! %%1
            set "%%d=!%%d:^^=^!"
        )
        if /i "%%c" == "store" (
            call set "%%d=.%%~1"
            set "%%d=!%%d:^^=^!"
            set "%%d=!%%d:~1!"
        )
        if /i "%%c" == "append_const" (
            for /f "tokens=1* delims==" %%v in ("%%d") do set "%%v=!%%v!%%w"
        )
        if /i "%%c" == "store_const" set "%%d"
        if /i "%%c" == "shift" shift /1
    )
    ( call )
)
exit /b 2
#+++

:argparse._validate_specs {_specs}
setlocal EnableDelayedExpansion
set "_alphanum=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
if not defined _specs (
    1>&2 echo argparse: No specs were provided
    exit /b 2
)
set "_all_specs= "
for /f "tokens=1-2* delims=:" %%b in ("!_specs!") do (
    set "_spec=%%b"
    if "!_spec:~0,1!" == "#" (
        if not "!_all_specs: %%b = !" == "!_all_specs!" (
            1>&2 echo argparse: Positional argument '%%b' already defined
            exit /b 2
        )
        set "_pos=!_spec:~1!"
        if defined _pos (
            set "_invalid="
            if !_pos! LSS 1 set "_invalid=true"
            if !_pos! GTR 400 set "_invalid=true"
            if defined _invalid (
                1>&2 echo argparse: Invalid positional argument '%%b'
                exit /b 2
            )
        )
        set "_all_specs=!_all_specs!%%b "
    ) else for %%o in (%%b) do (
        if not "!_all_specs: %%o = !" == "!_all_specs!" (
            1>&2 echo argparse: Flag '%%o' already defined
            exit /b 2
        )
        set "_flag=%%o"
        for /f "tokens=* delims=-" %%f in ("!_flag!") do set "_flag=%%f"
        if "!_flag!" == "%%o" set "_flag="
        if not defined _flag (
            1>&2 echo argparse: Invalid flag '%%o'
            exit /b 2
        )
        set "_all_specs=!_all_specs!%%o "
    )
    set "_invalid=true"
    for %%a in (
        store store_const append append_const
    ) do if "%%c" == "%%a" set "_invalid="
    if defined _invalid (
        1>&2 echo argparse: Invalid action '%%c'
        exit /b 2
    )
    set "_invalid="
    for /f "tokens=1* delims==" %%v in ("%%d.") do (
        if "%%v" == "." (
            1>&2 echo argparse: Spec '%%b' have no destination variable
            exit /b 2
        )
        set "_needs_value=?"
        for %%a in (store append) do if "%%c" == "%%a" set "_needs_value="
        for %%a in (store_const append_const) do if "%%c" == "%%a" set "_needs_value=true"
        if defined _needs_value if "%%w" == "" (
            1>&2 echo argparse: Spec '%%b' with action '%%c' requires a value to set
            exit /b 2
        )
        if not defined _needs_value if not "%%w" == "" (
            1>&2 echo argparse: Spec '%%b' with action '%%c' must not set any value
            exit /b 2
        )
    )
)
exit /b 0


