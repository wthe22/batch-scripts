@rem UTF-8-BOM guard > nul 2> nul
@goto module.entry_point

rem ======================================== Metadata ========================================

:metadata   [prefix]
set "%~1name=ezbuild"
set "%~1version=1.5-a.3"
set "%~1author=wthe22"
set "%~1license=The MIT License"
set "%~1description=Easy Build Tool"
set "%~1release_date=08/23/2019"   :: MM/dd/yyyy
set "%~1url="
set "%~1download_url=https://gist.github.com/wthe22/b7d14e8a09bb8dfaddfa302691c3abff/raw"
exit /b 0


:about
setlocal EnableDelayedExpansion
call :metadata
echo Compiling source code made easy
echo You don't need to type something like this anymore:
echo=
echo    C       gcc    "helloWorld.c"    -o "helloWorld.exe"
echo    Java    javac  "helloWorld.java"
echo=
echo Just input the file name / drag and drop the file or folder (for projects)
echo Then this script will do the typing for you
echo=
echo=
echo Updated on !release_date!
echo=
echo Feel free to use, share, or modify this script for your projects :)
echo Visit http://winscr.blogspot.com/ for more scripts^^!
echo=
echo=
echo Copyright (C) 2019 by !author!
echo Licensed under !license!
endlocal
exit /b 0

rem ======================================== License ========================================

:license
echo Copyright 2019 wthe22
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

rem ======================================== Configurations ========================================

:config
call :config.default
call :config.preferences
exit /b 0


:config.default
set "temp_path=!temp!\BatchScript\!SOFTWARE.name!\!__name__!"

rem Add this path to all language search path (order sensitive)
rem You can also include your own (portable) SDK path here, each seperated by a semicolon (;)
set "Sdk.search_path="
set "Sdk.search_path=!Sdk.search_path!;*:\Program*Files*"
set "Sdk.search_path=!Sdk.search_path!;*:"
set "Sdk.search_path=!Sdk.search_path!;*:\Program*Files*\CodeBlocks"

set "Language.list=unknown c cpp java python assembly"
set "Sdk.list=default manual mingw cygwin vs_com vs_old oracle_jdk cpython2 cpython3 goasm"

rem If your SDK is not detected, you can try this:
rem set "Sdk.search_path=!Sdk.search_path!;!path!"

rem You can add / edit existing SDK configuration at the end of this file

rem Macros to call external module (use absolute paths)
set "batchlib="
exit /b 0


:config.preferences
rem Define your preferences or config modifications here

rem Macros to call external module (use absolute paths)
rem set batchlib="%~dp0batchlib-min.bat" --module=lib %=END=%
exit /b 0

rem ======================================== Changelog ========================================

:changelog
for /f "usebackq tokens=1-2* delims=." %%a in ("%~f0") do (
    if /i "%%a.%%b" == ":changelog.text" (
        echo batchlib %%c
        call :changelog.text.%%c
        echo=
    )
)
exit /b 0


:changelog.latest
for /f "usebackq tokens=1-2* delims=." %%a in ("%~f0") do (
    if /i "%%a.%%b" == ":changelog.text" (
        echo batchlib %%c
        call :changelog.text.%%c
        exit /b 0
    )
)
exit /b 0


:changelog.text.1.5-a.3 (2019-08-23) WIP
echo    Development progress of v1.5
echo    - Updated library and framework version from batchlib 2.0
echo    - New settings format (again)
rem     - Implement repeat_action for delete files
rem     - Add download SDK
exit /b 0

:changelog.text.1.5-a.2 (2019-08-23)
echo    Development progress of v1.5
echo    - Fixed folder not recognized when attempting to compile from menu
echo    - Implemented repeat_action for compile/run
echo    - Added SDK searh path for MinGW in Code::Blocks
exit /b 0

:changelog.text.1.5-a.1 (2019-05-03)
echo    Development progress of v1.5
echo    - Added development plans
exit /b 0

:changelog.text.1.5-a (2019-04-27)
echo    Refactor Update
echo    - added framework from batchlib 2.0-b.2
echo    - new settings format
echo    - Renamed script from 'Easy Compiler' to 'Easy Build Tool'
exit /b 0

rem ======================================== Debug functions ========================================

:exception.raise
@echo=
@echo=
@for %%t in (%*) do @ 1>&2 echo %%~t
@echo=
@echo Press any key to exit...
@pause > nul
@exit

rem ======================================== Main ========================================

:__main__
@call :scripts.main %*
@exit /b %errorlevel%

rem ======================================== Scripts/Entry points ========================================

:scripts.__init__
@exit /b 0

rem ================================ library script ================================

:scripts.lib
@call :%*
@exit /b %errorlevel%

rem ================================ main script ================================

:scripts.main
@set "__name__=main"
@echo off
prompt $$
setlocal EnableDelayedExpansion EnableExtensions
call :metadata SOFTWARE.
title !SOFTWARE.description! !SOFTWARE.version!
cls
echo Loading script...

for %%n in (1 2) do call :fix_eol.alt%%n
call :config

call :capchar LF NL
call :Display.setup

echo Reading configurations...
call :ezbuild.init

if not "%~1" == "" call :build_flow %*
call :main_menu
exit /b %errorlevel%

rem ======================================== User Interfaces ========================================

:ui.__init__
rem User Interfaces
exit /b 0

rem ================================ Main Menu ================================

:main_menu
set "user_input="
title !SOFTWARE.description! !SOFTWARE.version!
cls
echo 1. Compile / run file
echo 2. Change SDK
echo 3. Cleanup files
echo 4. Repeat last action
echo=
echo A. About
echo U. Check for updates
echo 0. Exit
echo=
echo What do you want to do?
set /p "user_input="
echo=
if "!user_input!" == "0" exit /b 0
if "!user_input!" == "1" call :compile_or_run_menu
if "!user_input!" == "2" call :Sdk_change
if "!user_input!" == "3" call :Cleanup
if "!user_input!" == "4" call :repeat_action
if /i "!user_input!" == "A" call :about
if /i "!user_input!" == "U" call :update_script
goto main_menu


:repeat_action
if /i "!last_used.action!" == "compile/run" (
    call :compile_or_execute !last_used.files!
    exit /b 0
)
echo No action found
pause
exit /b 0

rem ================================ Easy Build ================================

:compile_or_run_menu
call :Input.path user_input --exist --description "Input file to compile/run: "
call :build_flow "!user_input!"
exit /b 0

rem ================================ compile_or_execute ================================

:build_flow
call :compile_or_execute %* || exit /b 1
set "last_used.files=!selected.files!"
set "last_used.action=compile/run"
if /i not "!selected.action!" == "compile" exit /b 0
call :check_path --file --exist output_file || exit /b 0
call :Input.yesno user_input --description "Execute file? Y/N? " || exit /b 0
call :compile_or_execute "!output_file!"
exit /b 0


:compile_or_execute
set "selected.files="
set "input_dir="
set "output_file="
for %%f in (%*) do (
    set "_attrib=%%~af"
    set "_attrib=!_attrib:~0,1!"
    if /i "!_attrib!" == "d" (
        if not defined input_dir set "input_dir=%%~ff"
        if not defined output_file set "output_file=%%~ff\%%~nxf"
        set selected.files=!selected.files! "%%~ff\*"
    )
    if /i "!_attrib!" == "-" (
        if not defined input_dir set "input_dir=%%~dpf"
        if not defined output_file set "output_file=%%~dpnf"
        set selected.files=!selected.files! "%%~ff"
    )
)
if not defined input_dir set "input_dir=!cd!"
if not defined output_file set "output_file=output"
rem (!) Check if files are in the same folder?
echo Determining file type...
call :ezbuild.get_type selected. selected.files || (
    pause
    exit /b 0
)
call :ezbuild.get_input_files input_files selected.
set "_type="
for %%t in (
    compiler.compile
    interpreter.execute
) do if ".!selected.action!" == "%%~xt" set "_type=%%~nt"

rem (!) Choose which to execute if multiple executables are found
if "!selected.action!" == "" if not "!_count!" == "1" (
    1>&2 echo error: too many choices to execute, 1 expected & exit /b 1
)

rem Find SDK if it is missing
for %%l in (!selected.language!) do for %%t in (!_type!) do (
    if not defined Language_%%l.%%t.is_cached call :Language.find_sdk %%l
    if not defined Language_%%l.%%t.used ( 1>&2 echo error: could not find %%t for !Language_%%l.name! & exit /b 1 )
)

set "user_parameter="
cls
echo Files:
echo !selected.files!
echo=
echo Input !selected.action! parameter:
set /p "user_parameter="

cls
echo Files:
echo !selected.files!
echo=
echo Target files:
echo !input_files!
echo=
for %%l in (!selected.language!) do for %%t in (!_type!) do (
    echo Language   : !Language_%%l.name!
    echo Action     : !selected.action!
    echo SDK        : !Language_%%l.%%t.used!
)
echo=
echo User parameter:
echo=!user_parameter!
echo=
echo Press any key to !selected.action!...
pause > nul
echo=

set "start_time=!time!"
echo !border_line!
call :ezbuild.execute selected. user_parameter
set "exit_code=!errorlevel!"
echo !border_line!
call :difftime time_taken !time! !start_time!
call :ftime time_taken !time_taken!

title !SOFTWARE.name! !SOFTWARE.version!
if not "!exit_code!" == "0" (
    echo An error occured. See above for more details.
    echo=
)
echo Time taken : !time_taken!
echo Exit code  : !exit_code!
pause
exit /b 0

rem ======================================== Change SDK ========================================

:Sdk_change
:Sdk_change.select_sdk
set "user_input=?"
cls
call :Sdk.get_item list
echo=
echo=
echo R. Reload list
echo S. Show Registered SDK
echo 0. Back
echo=
echo Input the list number :
set /p "user_input="
echo=
if "!user_input!" == "0" goto :EOF
if /i "!user_input!" == "R" call :Sdk_change.reload
if /i "!user_input!" == "S" call :Sdk_change.show_registered
call :Sdk.get_item "!user_input!" && goto Sdk_change.input_path
goto Sdk_change.select_sdk


:Sdk_change.reload
set "start_time=!time!"
cls
for %%s in (!Sdk.list!) do set "Sdk_%%s.is_cached="
call :Language.find_sdk !Language.list!
call :difftime time_taken !time! !start_time!
echo=
echo Time taken : !time_taken!
echo=
pause
goto :EOF


:Sdk_change.show_registered
cls
call :Sdk.show_registered
echo=
echo Global search path: !Sdk.search_path:;=%NL%!
echo=
pause
goto :EOF


:Sdk_change.input_path
set "user_input="
cls
for %%s in (!Language_%selected.language%.%selected.type%.used!) do (
    echo Current SDK
    echo Name : !Sdk_%%s.name!
    echo Path : !Language_%selected.language%.%selected.type%.path!
    echo=
    echo=
)
echo All found !Language_%selected.language%.name! !selected.type!s:
echo=
call :Language.get_path !selected.language! !selected.type! list
echo=
echo 0. Back
echo=
echo Input list number or a new file address:
set /p "user_input="
echo=
if "!user_input!" == "0" goto Sdk_change.select_sdk
set "selected.file=!user_input!"
call :Language.get_path !selected.language! !selected.type! "!user_input!"
call :check_path --file --exist selected.file || goto Sdk_change.input_path
goto Sdk_change.change


:Sdk_change.change
if not defined selected.sdk set "selected.sdk=Manual"
for %%s in (Language_!selected.language!.!selected.type!) do (
    set "%%s.used=!selected.sdk!"
    set "%%s.path=!selected.file!"
    set "%%s.is_cached=true"
)
echo Change successful
pause > nul
goto Sdk_change

rem ================================ Cleanup Files ================================

:Cleanup
:Cleanup.select
set "user_input="
cls
call :Cleanup.get_item list
echo=
echo 0. Back
echo=
echo Choose which type to cleanup:
set /p "user_input="
if "!user_input!" == "0" goto :EOF
call :Cleanup.get_item "!user_input!" && goto Cleanup.cleanup
goto Cleanup.select


:Cleanup.cleanup
set "user_input=?"
cls
echo Current directory:
echo=!cd!
echo=
echo Extensions to delete:
echo=!selected.extensions!
echo=
echo=
echo Files will be deleted permanently (not to the recycle bin)
echo=
call :Input.yesno user_input --description "Delete files permanently? Y/N? " || goto Cleanup.select
set "last_used.action=delete_files"
set "last_used.extensions=!selected.extensions!"
echo=
echo Deleting files...
echo=
set "success_count=0"
set "fail_count=0"
for %%x in (!selected.extensions!) do for %%f in ("*.%%x") do (
    del /f /q "%%~ff" && (
        set /a "success_count+=1"
        echo Deleted    %%~nxf
    ) || (
        set /a "fail_count+=1"
        echo Failed     %%~nxf
    )
)
echo Successfully deleted !success_count! files (!fail_count! failed)
pause > nul
goto :EOF


:Cleanup.get_item   list|number
set "_count=0"
set "selected.extensions="
for %%l in (all !Language.list!) do (
    set /a "_count+=1"
    if /i "%1" == "list" (
        set "_display=   !_count!"
        set "_display=!_display:~-3,3!. !Language_%%l.name!!spaces!"
        set "_display=!_display:~0,17! !Language_%%l.ext.cleanup!"
        echo !_display!
    ) else if "%~1" == "!_count!" set "selected.extensions=!Language_%%l.ext.cleanup!"
)
if /i not "%1" == "list" if not defined selected.extensions exit /b 1
exit /b 0

rem ======================================== Utilities ========================================

:utils.__init__
rem Utility Functions
exit /b 0


:Display.setup
call :get_con_size console_width console_height
set "spaces="
for /l %%n in (1,1,30) do set "spaces=!spaces! "
set "border_line="
for /l %%n in (2,1,!console_width!) do set "border_line=!border_line!="
exit /b 0


:Language.get_path   lang type list|number
if /i "%3" == "list" (
    set "_sdk_found="
    for %%s in (!Language_%1.%2_list!) do (
        call :SDK.find %%s > nul
        if defined Sdk_%%s.root_list (
            call :combi_wcdir --file _found "!Sdk_%%s.root_list!" "!Sdk_%%s.%2.%1!"
        ) else set "_found="
        for /f "tokens=*" %%a in ("!_found!") do set "_sdk_found=!_sdk_found!%%s@%%a!LF!"
    )
    echo   # ^| SDK Name     ^| Path
    echo !border_line!
)
set "selected.file="
set "_count=0"
for /f "tokens=* tokens=1* delims=@" %%s in ("!_sdk_found!") do (
    set /a "_count+=1"
    if /i "%3" == "list" (
        set "_display=   !_count!"
        set "_display=!_display:~-3,3! ^| !Sdk_%%s.short_name!!spaces!"
        echo !_display:~0,18! ^| %%t
    ) else if /i "%~3" == "!_count!" (
        set "selected.sdk=%%s"
        set "selected.file=%%t"
    )
)
if /i not "%3" == "list" if not defined selected.file exit /b 1
exit /b 0


:Sdk.get_item   list|number
set "selected.language="
set "selected.type="
set "_count=0"
if /i "%1" == "list" (
    echo   # ^| Language     ^| Type        ^| SDK Used     ^| Path
    echo=!border_line!
)
for %%l in (!Language.list!) do for %%t in (!Sdk.types!) do if defined Language_%%l.require_%%t (
    set /a "_count+=1"
    if /i "%1" == "list" (
        set "_display=   !_count!"
        set "_display=!_display:~-3,3! ^| !Language_%%l.name!!spaces!"
        set "_display=!_display:~0,18! ^| %%t!spaces!"
        if defined Language_%%l.%%t.used (
            for %%s in (!Language_%%l.%%t.used!) do set "_display=!_display:~0,32! ^| !Sdk_%%s.short_name!!spaces!"
            set "_display=!_display:~0,47! ^| !Language_%%l.%%t.path!"
        ) else (
            set "_display=!_display:~0,32! ^| *NOT FOUND*!spaces!"
            if defined Language_%%l.%%t.is_cached (
                set "_display=!_display:~0,47! ^| *NOT FOUND*"
            ) else set "_display=!_display:~0,47! ^| Please reload to find SDK"
        )
        if not "!_display:~%console_width%!" == "" (
            set "_display=!_display:~0,%console_width%!
            set "_display=!_display:~0,-4!..."
        )
        echo=!_display!
    ) else if /i "%~1" == "!_count!" (
        set "selected.language=%%l"
        set "selected.type=%%t"
    )
)
if /i not "%1" == "list" if not defined selected.language exit /b 1
exit /b 0


:Sdk.show_registered
echo  Language     ^| Type        ^| Registered SDKs
echo !border_line!
for %%l in (!Language.list!) do for %%t in (!Sdk.types!) do if defined Language_%%l.%%t_list (
    set "_display= !Language_%%l.name!!spaces!"
    set "_display=!_display:~0,13! ^| %%t!spaces!"
    set "_display=!_display:~0,27! ^| !Language_%%l.%%t_list!"
    echo !_display!
)
exit /b 0

rem ======================================== Core functions ========================================

:core.__init__
rem Core functions
exit /b 0

rem ================================ Easy Build ================================

:ezbuild.init
call :ezbuild.read_config
call :ezbuild.setup
for %%l in (!Language.list!) do for %%t in (compiler interpreter) do set "Language_%%l.%%t.is_cached="
for %%s in (!Sdk.list!) do set "Sdk_%%s.is_cached="
exit /b 0


:ezbuild.read_config
set "Sdk.types=compiler interpreter"
set "Language.ext_types=source compile execute cleanup related"
for %%l in (!Language.list!) do (
    call :Language_%%l Language_%%l.
    for %%t in (!Language_%%l.requires!) do (
        set "Language_%%l.require_%%t=true"
    )
    set "Language_%%l.requires="
)
for %%s in (!Sdk.list!) do (
    call :Sdk_%%s Sdk_%%s.
    for /f "tokens=* delims=" %%a in ("!Sdk_%%s.sdk_list!") do (
        for /f "tokens=1-2* delims=:" %%b in (%%a) do (
            for %%l in (%%c) do if defined Language_%%l.name (
                set "Language_%%l.sdk_list=!Language_%%l.sdk_list! %%s"
                set "Sdk_%%s.%%b.%%l=%%d"
            ) else call :exeption.raise "ezbuild.read_config: Value Error:" ^
                ^ "At SDK '%%s':" ^
                ^ "Language with label '%%l' does not exist"
        )
    )
    set "Sdk_%%s.sdk_list="
)
exit /b 0


:ezbuild.setup
rem Put preferred SDK first
for %%l in (!Language.list!) do (
    set "Language_%%l.sdk_list=!Language_%%l.preferred_sdk! !Language_%%l.sdk_list!"
)
rem Lock used SDK if force_sdk is defined
for %%l in (!Language.list!) do if defined Language_%%l.force_sdk (
    for %%t in (compiler interpreter) do (
        set "Language_%%l.%%t.used=!Language_%%l.force_sdk!"
    )
)
rem Combine extensions of each language
for %%l in (!Language.list!) do (
    set "Language_%%l.ext.all="
    for %%t in (!Language.ext_types!) do (
        set "Language_%%l.ext.all=!Language_%%l.ext.all! !Language_%%l.ext.%%t!"
    )
)
rem Combine extensions of all languages
set "Language_all.name=All"
for %%t in (all !Language.ext_types!) do (
    set "Language_all.ext.%%t="
    for %%l in (!Language.list!) do (
        set "Language_all.ext.%%t=!Language_all.ext.%%t! !Language_%%l.ext.%%t!"
    )
)
rem Generate cleanup extensions
rem (!) Seems messy
for %%l in (all !Language.list!) do (
    set "Language_%%l.ext.cleanup= !Language_%%l.ext.cleanup! !Language_%%l.ext.execute! "
    for %%t in (source compile) do for %%x in (!Language_all.ext.%%t!) do (
        set "Language_%%l.ext.cleanup=!Language_%%l.ext.cleanup: %%x = !"
    )
)
rem Create list of variable names to compact
set "_var_names="
for %%l in (!Language.list!) do (
    set "_var_names=!_var_names! Language_%%l.sdk_list"
)
for %%l in (all !Language.list!) do (
    for %%t in (all !Language.ext_types!) do (
        set "_var_names=!_var_names! Language_%%l.ext.%%t"
    )
)
rem Compact list
for %%v in (!_var_names!) do if defined %%v (
    if "!%%v: =!" == "" (
        set "%%v="
    ) else (
        set "_temp="
        for %%i in (!%%v!) do set "_temp=%%i !_temp!"
        set "%%v= "
        for %%i in (!_temp!) do set "%%v= %%i!%%v: %%i = !"
    )
)
exit /b 0


:ezbuild.get_type   return_var  file_list_var
set "%~1language="
set "%~1action="
rem Get list of extensions
set "_extensions= "
for %%f in (!%~2!) do (
    set "_extensions=!_extensions: %%~xf = !%%~xf "
)
set "_extensions=!_extensions:.=!"
if "!_extensions: =!" == "" ( 1>&2 echo error: no file extensions found & exit /b 1 )
rem Filter extensions to known types only
set "_temp=!_extensions!"
set "_extensions= "
for %%x in (!Language_all.ext.all!) do (
    if not "!_temp: %%x = !" == "!_temp!" set "_extensions=!_extensions!%%x "
)
if "!_extensions: =!" == "" ( 1>&2 echo error: unknown file extension found & exit /b 1 )
rem Determine language
set "_language="
for %%l in (!Language.list!) do if not defined _language (
    set "_temp=!_extensions!"
    for %%x in (!Language_%%l.ext.all!) do set "_temp=!_temp: %%x = !"
    if "!_temp: =!" == "" set "_language=%%l"
)
if not defined _language ( 1>&2 echo error: language of files are mixed & exit /b 1 )
rem Determine action
set "_action="
for %%l in (!_language!) do for %%t in (execute compile) do (
    set "_temp=!_extensions!"
    for %%x in (!Language_%%l.ext.%%t!) do set "_temp=!_temp: %%x = !"
    if not "!_temp!" == "!_extensions!" set "_action=%%t"
)
if not defined _action ( 1>&2 echo error: this type of file cannot be compiled or executed & exit /b 1 )
set "%~1language=!_language!"
set "%~1action=!_action!"
exit /b 0


:ezbuild.get_input_files   return_var file_info_prefix
rem Filter files to compile/execute
set "%~1="
for %%l in (!%~2language!) do for %%a in (!%~2action!) do (
    for %%f in (!%~2files!) do (
        for %%x in (!Language_%%l.ext.%%a!) do (
            if "%%~xf" == ".%%x" (
                set /a "_count+=1"
                set %~1=!%~1! "%%~nxf"
            )
        )
    )
)
exit /b 0


:ezbuild.execute   file_info_prefix  parameter_var
rem (!) Variables that should be passed:
rem - input_files
rem - input_dir

set "_type="
for %%t in (
    compiler.compile
    interpreter.execute
) do if ".!%~1action!" == "%%~xt" set "_type=%%~nt"
set "exit_code=1"
for %%l in (!%~1language!) do for %%t in (!_type!) do for %%a in (!%~1action!) do (
    for %%f in ("!Language_%%l.%%t.path!") do (
        set "path=%%~dpf;!path!"
        set "!_type!=%%~ff"
    )
    pushd "!input_dir!"
    if "!Language_%%l.%%t.used!" == "Manual" (
        call :Sdk_manual.%%a
    ) else call :Sdk_!Language_%%l.%%t.used!.%%a.%%l
    set "exit_code=!errorlevel!"
    popd
)
exit /b !exit_code!


:Language.find_sdk   lang1 [lang2 [...]]
for %%l in (%*) do if not defined Language_%%l.force_sdk (
    for %%t in (compiler interpreter) do if defined Language_%%l.require_%%t (
        set "Language_%%l.%%t.used="
        set "Language_%%l.%%t.path="
        for %%s in (!Language_%%l.sdk_list!) do if not defined Language_%%l.%%t.path (
            if not defined Sdk_%%s.is_cached call :Sdk.find %%s
            if defined Sdk_%%s.root_list (
                call :combi_wcdir --file _found "!Sdk_%%s.root_list!" "!Sdk_%%s.%%t.%%l!"
            ) else set "_found="
            for /f "tokens=* delims=" %%a in ("!_found!") do set "Language_%%l.%%t.path=%%a"
            if defined Language_%%l.%%t.path (
                set "Language_%%l.%%t.used=%%s"
                echo [+] !Sdk_%%s.name! %%t for !Language_%%l.name!
            ) else echo [-] !Sdk_%%s.name! %%t for !Language_%%l.name!
        )
    ) else set "Language_%%l.%%t.used=default"
    set "Language_%%l.%%t.is_cached=true"
)
exit /b 0


:Sdk.find   sdk1 [sdk2 [...]]
for %%s in (%*) do (
    call :combi_wcdir --directory --semicolon Sdk_%%s.root_list ^
        "!Sdk.search_path!;!Sdk_%%s.search_path!" ^
        "!Sdk_%%s.search_root!"
    if defined Sdk_%%s.root_list (
        echo [+] !Sdk_%%s.name!
    ) else echo [-] !Sdk_%%s.name!
    set "Sdk_%%s.is_cached=true"
)
exit /b 0

rem ======================================== Shortcuts ========================================

:shortcuts.__init__
rem Shortcuts to type less codes

call %batchlib%:extract_func ^
    ^ Input.yesno Input.path ^
    ^ > ezbuild.shortcuts.bat
exit /b 0


:Input.yesno   variable_name  [--d=<desc>]  [--yes=<value>]  [--no=<value>]
setlocal EnableDelayedExpansion EnableExtensions
set "_description=Y/N? "
set "yes.value=Y"
set "no.value=N"
set parse_args.args= ^
    ^ "-d --description     :var:_description" ^
    ^ "-y --yes             :var:yes.value" ^
    ^ "-n --no              :var:no.value"
call :parse_args %*
call :Input.yesno.loop
set "_result="
if /i "!user_input!" == "Y" set "_result=!yes.value!"
if /i "!user_input!" == "N" set "_result=!no.value!"
if defined _result (
    for /f tokens^=*^ delims^=^ eol^= %%a in ("!_result!") do (
        endlocal
        set "%~1=%%a"
        if /i "%user_input%" == "Y" exit /b 0
    )
) else (
    endlocal
    set "%~1="
    if /i "%user_input%" == "Y" exit /b 0
)
exit /b 1

:Input.yesno.loop
echo=
set /p "user_input=!_description!"
if /i "!user_input!" == "Y" exit /b 0
if /i "!user_input!" == "N" exit /b 0
goto Input.yesno.loop


:Input.path  [-o] [-e|-n] [-f|-p] variable_name  [-d=<desc>]
setlocal EnableDelayedExpansion EnableExtensions
for %%v in (_description _is_optional  _require_attrib  _require_exist _prompt_only) do set "%%v="
set parse_args.args= ^
    ^ "-d --description :var:_description" ^
    ^ "-o --optional    :flag:_is_optional=true" ^
    ^ "-e --exist       :flag:_require_exist=true" ^
    ^ "-n --not-exist   :flag:_require_exist=false" ^
    ^ "-f --file        :flag:_require_attrib=-" ^
    ^ "-p --directory   :flag:_require_attrib=d"
call :parse_args %*
set "_options="
if /i "!_require_exist!"  == "true" set "_options=!_options! -e"
if /i "!_require_exist!"  == "false" set "_options=!_options! -n"
if /i "!_require_attrib!"  == "-" set "_options=!_options! -f"
if /i "!_require_attrib!"  == "d" set "_options=!_options! -p"
if not defined _description set "_description=Input %~1: "
call :Input.path.loop
for /f "tokens=* eol= delims=" %%c in ("!user_input!") do (
    endlocal
    set "%~1=%%c"
    set "last_used.file=%%c"
)
exit /b 0

:Input.path.loop
set "user_input="
cls
echo Current directory:
echo=!cd!
echo=
if defined last_used.file (
    echo Previous input:
    echo=!last_used.file!
    echo=
)
if defined last_used.file           echo :P     Use previous input
if defined _is_optional             echo :S     Skip / use default
echo=
echo !_description!
set /p "user_input="
echo=
if not defined user_input goto Input.path.loop
if defined last_used.file   if /i "!user_input!" == ":P" set "user_input=!last_used.file!"
if defined _is_optional     if /i "!user_input!" == ":S" set "user_input="
if defined user_input call :check_path user_input !_options! || (
    pause
    goto Input.path.loop
)
exit /b 0

rem ======================================== Batch Script Library ========================================

:lib.__init__
rem Functions from Batch Script Library (batchlib)

call %batchlib%:extract_func ^
    ^ strip_dquotes difftime ftime check_path combi_wcdir wcdir expand_path expand_multipath ^
    ^ unzip download_file get_con_size capchar fix_eol check_win_eol ^
    ^ > ezbuild.lib.bat
exit /b 0


:strip_dquotes   variable_name
if "!%~1:~0,1!!%~1:~-1,1!" == ^"^"^"^" set "%~1=!%~1:~1,-1!"
exit /b 0


:difftime   return_var  end_time  [start_time] [-n]
set "%~1=0"
for %%t in (%~2:00:00:00:00 %~3:00:00:00:00) do for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
    set /a "%~1+=24%%a %% 24 *360000 +1%%b*6000 +1%%c*100 +1%%d -610100"
    set /a "%~1*=-1"
)
if /i not "%4" == "-n" if "!%~1:~0,1!" == "-" set /a "%~1+=8640000"
exit /b 0


:ftime   return_var  time_in_centiseconds
set "%~1="
setlocal EnableDelayedExpansion
set "_result="
set /a "_remainder=(%~2) %% 8640000"
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


:check_path   variable_name  [-e|-n]  [-f|-p]
setlocal EnableDelayedExpansion EnableExtensions
for %%v in (_require_attrib  _require_exist) do set "%%v="
set parse_args.args= ^
    ^ "-e --exist       :flag:_require_exist=true" ^
    ^ "-n --not-exist   :flag:_require_exist=false" ^
    ^ "-f --file        :flag:_require_attrib=-" ^
    ^ "-p --directory   :flag:_require_attrib=d"
call :parse_args %*
set "_path=!%~1!"
if "!_path:~0,1!!_path:~-1,1!" == ^"^"^"^" set "_path=!_path:~1,-1!"
if "!_path:~-1,1!" == ":" set "_path=!_path!\"
for /f tokens^=1-2*^ delims^=?^"^<^>^| %%a in ("_?_!_path!_") do if not "%%c" == "" ( 1>&2 echo Invalid path & exit /b 1 )
for /f "tokens=1-2* delims=*" %%a in ("_*_!_path!_") do if not "%%c" == "" ( 1>&2 echo Wildcards are not allowed & exit /b 1 )
if "!_path:~1,1!" == ":" (
    if not "!_path::=!" == "!_path:~0,1!!_path:~2!" ( 1>&2 echo Invalid path & exit /b 1 )
) else if not "!_path::=!" == "!_path!" ( 1>&2 echo Invalid path & exit /b 1 )
set "file_exist=false"
for %%f in ("!_path!") do (
    set "_path=%%~ff"
    set "_attrib=%%~af"
)
if defined _attrib (
    set "_attrib=!_attrib:~0,1!"
    set "file_exist=true"
)
if defined _require_exist if not "!file_exist!" == "!_require_exist!" (
    if "!_require_exist!" == "true" 1>&2 echo Input does not exist
    if "!_require_exist!" == "false" 1>&2 echo Input already exist
    exit /b 1
)
if "!file_exist!" == "true" if defined _require_attrib if not "!_attrib!" == "!_require_attrib!" (
    if defined _require_exist (
        if "!_require_attrib!" == "d" 1>&2 echo Input is not a folder
        if "!_require_attrib!" == "-" 1>&2 echo Input is not a file
    ) else (
        if "!_require_attrib!" == "d" 1>&2 echo Input must be a new or existing folder, not a file
        if "!_require_attrib!" == "-" 1>&2 echo Input must be a new or existing file, not a folder
    )
    exit /b 1
)
for /f "tokens=* delims=" %%c in ("!_path!") do (
    endlocal
    set "%~1=%%c"
)
exit /b 0


:combi_wcdir   [-f|-d]  [-s]  return_var  file_path_part1  file_path_part2
setlocal EnableDelayedExpansion EnableExtensions
set "_list_dir=true"
set "_list_file=true"
set "_semicolon="
set parse_args.args= ^
    ^ "-f --file        :flag:_list_dir=" ^
    ^ "-d --directory   :flag:_list_file=" ^
    ^ "-s --semicolon   :flag:_semicolon=true"
call :parse_args %*
set "_path1=%~2"
set "_path2=%~3"
for %%v in (_path1 _path2) do (
    set "%%v=!%%v:/=\!"
    set ^"%%v=!%%v:;=%NL%!^"
    set "_temp="
    for /f "tokens=* delims=" %%a in ("!%%v!") do (
        set "_is_listed="
        for /f "tokens=*" %%b in ("!_temp!") do if "%%a" == "%%b" set "_is_listed=true"
        if not defined _is_listed set "_temp=!_temp!%%a!LF!"
    )
    set "%%v=!_temp!"
)
set "_found="
for /f "tokens=* delims=" %%a in ("!_path1!") do for /f "tokens=* delims=" %%b in ("!_path2!") do (
    set "_result="
    pushd "!temp!"
    call :wcdir.find "%%a\%%b"
    set "_found=!_found!!_result!"
)
set "_result="
for /f "tokens=* delims=" %%a in ("!_found!") do (
    set "_is_listed="
    for /f "tokens=*" %%b in ("!_result!") do if "%%a" == "%%b" set "_is_listed=true"
    if not defined _is_listed set "_result=!_result!%%a!LF!"
)
if defined _result (
    set "%~1="
    for /f "tokens=* delims=" %%r in ("!_result!") do (
        if not defined %~1 (
            endlocal
            set "%~1="
        )
        if "%_semicolon%" == "" (
            set "%~1=!%~1!%%r!LF!"
        ) else set "%~1=!%~1!%%r;"
    )
) else (
    endlocal
    set "%~1="
)
exit /b 0


:wcdir   return_var  file_path  [-f|-d]
set "%~1="
setlocal EnableDelayedExpansion
set "_list_dir=true"
set "_list_file=true"
if "%~3" == "-d" set "_list_file="
if "%~3" == "-f" set "_list_dir="
set "_args=%~2"
set "_args=!_args:/=\!"
set "_result="
pushd "!temp!"
call :wcdir.find "!_args!"
for /f "tokens=* delims=" %%r in ("!_result!") do (
    if not defined %~1 endlocal
    set "%~1=!%~1!%%r!LF!"
)
exit /b 0
:wcdir.find
for /f "tokens=1* delims=\" %%a in ("%~1") do if "%%a" == "*:" (
    for %%l in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do pushd "%%l:\" 2> nul && call :wcdir.find "%%b"
) else if "%%b" == "" (
    if defined _list_dir dir /b /a:d "%%a" > nul 2> nul && ( for /d %%f in ("%%a") do set "_result=!_result!%%~ff!LF!" )
    if defined _list_file dir /b /a:-d "%%a" > nul 2> nul && ( for %%f in ("%%a") do set "_result=!_result!%%~ff!LF!" )
) else for /d %%f in ("%%a") do pushd "%%f\" 2> nul && call :wcdir.find "%%b"
popd
exit /b


:expand_path   prefix  path
set "%~1D=%~d2" Drive Letter
set "%~1A=%~a2" Attributes
set "%~1T=%~t2" Time Stamp
set "%~1Z=%~z2" Size
set "%~1N=%~n2" Name
set "%~1X=%~x2" Extension
set "%~1P=%~p2" Path
set "%~1F=%~f2" Full Path
set "%~1DP=%~dp2" D + P
set "%~1NX=%~nx2" N + X
exit /b 0


:expand_multipath   prefix  file_path1  [file_path2 [...]]
for %%a in (D P N X F DP NX) do set "%~1%%a="
:expand_multipath.loop
set ^"%~1D=!%~1D! "%%~d2"^"
set ^"%~1P=!%~1P! "%%~p2"^"
set ^"%~1N=!%~1N! "%%~n2"^"
set ^"%~1X=!%~1X! "%%~x2"^"
set ^"%~1F=!%~1F! "%%~f2"^"
set ^"%~1DP=!%~1DP! "%%~dp2"^"
set ^"%~1NX=!%~1NX! "%%~nx2"^"
if not "%~3" == "" (
    shift /2
    goto expand_multipath.loop
)
exit /b 0


:unzip   zip_file  destination_folder
if not exist "%~1" ( 1>&2 echo error: zip file does not exist & exit /b 1 )
if not exist "%~2" md "%~2" || ( 1>&2 echo error: create folder failed & exit /b 2 )
for %%s in ("!temp!\unzip.vbs") do (
    > "%%~s" (
        echo zip_file = WScript.Arguments(0^)
        echo dest_path = WScript.Arguments(1^)
        echo=
        echo set ShellApp = CreateObject("Shell.Application"^)
        echo set content = ShellApp.NameSpace(zip_file^).items
        echo ShellApp.NameSpace(dest_path^).CopyHere(content^)
    )
    cscript //nologo "%%~s" "%~f1" "%~f2"
    del /f /q "%%~s"
)
exit /b 0


:download_file   link  save_path
if exist "%~2" del /f /q "%~2"
if not exist "%~dp2" md "%~dp2"
powershell -Command "(New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
if not exist "%~2" exit /b 1
exit /b 0


:get_con_size   return_var_width  return_var_height
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


:capchar   character1  [character2 [...]]
rem Capture everything
if "%~1" == "*" call :capchar BS ESC CR LF NL DEL _ DQ
rem Capture backspace character
if /i "%~1" == "BS" for /f %%a in ('"prompt $h & for %%b in (1) do rem"') do set "BS=%%a"
rem Capture escape character
if /i "%~1" == "ESC" for /f %%a in ('"prompt $E & for %%b in (1) do rem"') do set "ESC=%%a"
rem Capture Carriage Return character
if /i "%~1" == "CR" for /f %%a in ('copy /z "%ComSpec%" nul') do set "CR=%%a"
rem Capture Line Feed character (2 empty lines requred)
if /i "%~1" == "LF" set LF=^
%=REQURED=%
%=REQURED=%
rem Create macro for new line
if /i "%~1" == "NL" call :capchar "LF" & set "NL=^^!LF!!LF!^^"
rem Create macro for erasing character from display
if /i "%~1" == "DEL" call :capchar "BS" & set "DEL=!BS! !BS!"
rem Create base for set /p "=" because it cannot start with a white space character
if /i "%~1" == "_" call :capchar "BS" & set "_=_!BS! !BS!"
rem Create macro for displaying invisible double quote, must be used as %DQ%, not !DQ!
if /i "%~1" == "DQ" call :capchar "BS" & set DQ="!BS! !BS!
rem Shift parameter
shift /1
if not "%1" == "" goto capchar
exit /b 0


:fix_eol   goto_label
:fix_eol.alt1
rem THIS IS REQUIRED
:fix_eol.alt2
for %%n in (1 2) do call :check_win_eol.alt%%n --check-exist 2> nul && (
    call :check_win_eol.alt%%n || (
        echo Converting EOL...
        type "%~f0" | more /t4 > "%~f0.tmp" && (
            move "%~f0.tmp" "%~f0" > nul && (
                echo Convert EOL done
                echo Script will exit. Press any key to continue...
                pause > nul
                exit 0
            )
        )
        echo warning: Convert EOL failed
        exit /b 1
    )
    exit /b 0
)
exit /b 1


:check_win_eol   [--check-exist]
rem The label below is an alternative label if the main label cannot be found
:check_win_eol.alt1
rem THIS IS REQUIRED
:check_win_eol.alt2
for %%f in (-c --check-exist) do if /i "%1" == "%%f" exit /b 0
@call :check_win_eol.test 2> nul && exit /b 0 || exit /b 1
rem  1  DO NOT REMOVE THIS COMMENT SECTION, IT IS IMPORTANT FOR THIS FUNCTION TO WORK CORRECTLY                               #
rem  2  DO NOT MODIFY THIS COMMENT SECTION IF YOU DON'T KNOW WHAT YOU ARE DOING                                               #
rem  3                                                                                                                        #
rem  4  Length of this comment section should be at most 4095 characters if EOL is LF only (Unix)                             #
rem  5  Comment could contain anything, but it is best to set it to empty space                                               #
rem  6  so your code editor won't slow down when scrolling through this section                                               #
rem  7                                                                                                                        #
rem  8                                                                                                                        #
rem  9                                                                                                                        #
rem 10                                                                                                                        #
rem 11                                                                                                                        #
rem 12                                                                                                                        #
rem 13                                                                                                                        #
rem 14                                                                                                                        #
rem 15                                                                                                                        #
rem 16                                                                                                                        #
rem 17                                                                                                                        #
rem 18                                                                                                                        #
rem 19                                                                                                                        #
rem 20                                                                                                                        #
rem 21                                                                                                                        #
rem 22                                                                                                                        #
rem 23                                                                                                                        #
rem 24                                                                                                                        #
rem 25                                                                                                                        #
rem 26                                                                                                                        #
rem 27                                                                                                                        #
rem 28                                                                                                                        #
rem 29                                                                                                                        #
rem 30                                                                                                                        #
rem 31                                                                                                                        #
rem 32  LAST LINE: should be 1 character shorter than the rest                                              DO NOT MODIFY -> #
:check_win_eol.test
@exit /b 0

rem ======================================== Framework ========================================

:framework.__init__
rem Framework of the script

call %batchlib%:extract_func ^
    ^ module.entry_point module.updater module.read_metadata module.is_module module.version_compare ^
    ^ parse_args ^
    ^ > ezbuild.framework.bat
exit /b 0


:module.entry_point   [--module=<name>]  [args]
@if /i not "%~1" == "--module" @goto __main__
@if /i #%1 == #"%~1" @goto __main__
@setlocal DisableDelayedExpansion
@set module.entry_point.args=%*
@setlocal EnableDelayedExpansion
@for /f "tokens=1* delims== " %%a in ("!module.entry_point.args!") do @(
    endlocal
    endlocal
    call :scripts.%%b
)
@exit /b %errorlevel%


:module.updater   <check|upgrade>  script_path
setlocal EnableDelayedExpansion
for %%v in (_force_upgrade _upgrade _download_url) do set "%%v="
set parse_args.args= ^
    ^ "-f --force-upgrade   :flag:_force_upgrade=true" ^
    ^ "-u --upgrade         :flag:_upgrade=true" ^
    ^ "-d --download-url    :var:_download_url"
call :parse_args %*
if defined _force_upgrade set "_upgrade=true"
cd /d "!temp_path!"
set "_downloaded=!cd!\latest_version.bat"
call :module.read_metadata _module. "%~1"  || ( 1>&2 echo error: failed to read module information & exit /b 10 )
if not defined _download_url set "_download_url=!_module.download_url!"
call %batchlib%:download_file "!_download_url!" "!_downloaded!" || ( 1>&2 echo error: download failed & exit /b 20 )
call :module.is_module "!_downloaded!" || ( 1>&2 echo error: failed to read update information & exit /b 30 )
call :module.read_metadata _downloaded. "!_downloaded!"  || ( 1>&2 echo error: failed to read update information & exit /b 31 )
if not defined _downloaded.version ( 1>&2 echo error: failed to read update information & exit /b 32 )
if /i not "!_downloaded.name!" == "!_module.name!" ( 1>&2 echo error: module name does not match & exit /b 40 )
if not defined _force_upgrade (
    call :module.version_compare "!_downloaded.version!" EQU "!_module.version!" && ( echo You are using the latest version & exit /b 99 )
    call :module.version_compare "!_downloaded.version!" GTR "!_module.version!" || ( echo No updates available & exit /b 99 )
)
if defined _show (
    call %batchlib%:diffdate update_age !date:~4! !_downloaded.release_date! 2> nul && (
        echo !_downloaded.description! !_downloaded.version! is now available ^(!update_age! days ago^)
    ) || echo !_downloaded.description! !_downloaded.version! is now available ^(since !_downloaded.release_date!^)
    del /f /q "!_downloaded!"
)
if not defined _upgrade exit /b 0
echo Updating script...
move "!_downloaded!" "%~f1" > nul && (
    echo Update successful
    if "%~f1" == "%~f0" (
        echo Script will exit. Press any key to continue...
        pause > nul
        exit 0
    )
) || ( 1>&2 echo error: update failed & exit /b 1 )
exit /b 0


:module.read_metadata   return_var  script_path
call :module.is_module "%~2" || exit /b 1
for %%v in (
    name version
    author license
    description release_date
    url download_url
) do set "%~1%%v="
call "%~2" --module=lib :metadata "%~1" || exit /b 1
exit /b 0


:module.is_module   file_path
setlocal EnableDelayedExpansion
set /a "_missing=0xF"
for /f "usebackq tokens=* delims=@ " %%a in ("%~f1") do (
    for /f "tokens=1-2 delims= " %%b in ("%%a") do (
        if /i "%%b %%c" == "goto module.entry_point" set /a "_missing&=~0x1"
        if /i "%%b" == ":module.entry_point" set /a "_missing&=~0x2"
        if /i "%%b" == ":metadata" set /a "_missing&=~0x4"
        if /i "%%b" == ":scripts.lib" set /a "_missing&=~0x8"
    )
)
if not "!_missing!" == "0" exit /b 1
set "_callable="
for %%x in (.bat .cmd) do if "%~x1" == "%%x" set "_callable=true"
if not defined _callable exit /b 2
exit /b 0


:module.version_compare   version1 comparison version2
setlocal EnableDelayedExpansion
if /i "%3" == "" exit /b 2
set "_found="
for %%c in (EQU NEQ GTR GEQ LSS LEQ) do if /i "%~2" == "%%c" set "_found=true"
if not defined _found exit /b 2
set "_first=%~1"
set "_second=%~3"
for %%v in (_first _second) do for /f "tokens=1-2 delims=-" %%a in ("!%%v!") do (
    for /f "tokens=1-3 delims=." %%c in ("%%a.0.0.0") do set "%%v=%%c.%%d.%%e"
    set "_normalized="
    if "%%b" == "" set "_normalized=4.0"
    for /f "tokens=1-2 delims=." %%c in ("%%b") do (
        for %%s in (
            "1:a alpha"
            "2:b beta"
            "3:rc c pre preview"
        ) do for /f "tokens=1-2 delims=:" %%n in (%%s) do for %%i in (%%o) do (
            if /i "%%c" == "%%i" (
                if "%%d" == "" (
                    set "_normalized=%%n.0"
                ) else set "_normalized=%%n.%%d"
            )
        )
    )
    if not defined _normalized exit /b 2
    set "%%v=!%%v!.!_normalized!"
)
for %%c in (EQU NEQ) do if /i "%~2" == "%%c" if "!_first!" %~2 "!_second!" ( exit /b 0 ) else exit /b 1
for %%c in (GEQ LEQ) do if /i "%~2" == "%%c" if "!_first!" EQU "!_second!" ( exit /b 0 )
for %%c in (GTR LSS) do if /i "%~2" == "%%c" if "!_first!" EQU "!_second!" ( exit /b 1 )
for /l %%i in (1,1,5) do (
    for %%v in (_first _second) do for /f "tokens=1* delims=." %%a in ("!%%v!") do (
        set "%%v_num=%%a"
        set "%%v=%%b"
    )
    if not "!_first_num!" == "!_second_num!" (
        if !_first_num! %~2 !_second_num! (
            exit /b 0
        ) else exit /b 1
    )
)
endlocal
exit /b 2


:parse_args   %*
set "_store_var="
set "parse_args.argc=1"
set "parse_args.shift="
call :parse_args.loop %*
set /a "parse_args.argc-=1"
set "parse_args._store_var="
set "parse_args._value="
(
    goto 2> nul
    for %%n in (!parse_args.shift!) do shift /%%n
    for %%v in (args shift) do set "parse_args.%%v="
    ( call )
)
exit /b 1
:parse_args.loop
set _value=%1
if not defined _value exit /b
set "_shift="
if defined parse_args._store_var (
    set "!parse_args._store_var!=%~1"
    set "parse_args._store_var="
    set "_shift=true"
)
for %%o in (!parse_args.args!) do for /f "tokens=1-2* delims=:" %%b in (%%o) do (
    for %%f in (%%b) do if /i "!_value!" == "%%f" (
        if /i "%%c" == "flag" set "%%d"
        if /i "%%c" == "var" set "parse_args._store_var=%%d"
        set "_shift=true"
    )
)
if defined _shift (
    set "parse_args.shift=!parse_args.shift! !parse_args.argc!"
) else set /a "parse_args.argc+=1"
shift /1
goto parse_args.loop

rem ======================================== Assets ========================================

:assets.__init__
rem Additional data to bundle
exit /b 0

rem ================================ Advanced Settings ================================
:assets.config.__init__
exit /b 0

rem ============================ Language List ============================

rem ======================== Example ========================

:Language_example
set "%~1name=           Name of language to display
set "%~1ext.source=     Source code file. Will show warning when delete is attempted
set "%~1ext.compile=    Compile this kind of file
set "%~1ext.execute=    Execute this kind of file
set "%~1ext.cleanup=    Files to included when cleaning up (delete file)
set "%~1ext.related=    Associate extensions with language (for language detection for folders)
set "%~1preferred_sdk=  Labels of your most preferred SDKs to the least preferred.
set "%~1force_sdk=      Always use this SDK despite its availability
set "%~1requires=       Requirements to do task. (e.g.: compiler, interpreter)
exit /b 0

rem ======================== Unknown ========================

:Language_unknown
set "%~1name=Unknown"
set "%~1ext.execute=exe"
set "%~1ext.cleanup=obj"
set "%~1force_sdk=default"
set "%~1requires=interpreter"
exit /b 0

rem ======================== C ========================

:Language_c
set "%~1name=C"
set "%~1ext.source=c h"
set "%~1ext.compile=c"
set "%~1ext.execute=exe"
set "%~1ext.cleanup=obj"
set "%~1preferred_sdk=mingw cygwin"
set "%~1requires=compiler"
exit /b 0

rem ======================== C++ ========================

:Language_cpp
set "%~1name=C++"
set "%~1ext.source=cpp hpp h"
set "%~1ext.compile=cpp"
set "%~1ext.execute=exe"
set "%~1ext.cleanup=obj"
set "%~1preferred_sdk=mingw cygwin"
set "%~1requires=compiler"
exit /b 0

rem ======================== Java ========================

:Language_java
set "%~1name=Java"
set "%~1ext.source=java"
set "%~1ext.compile=java"
set "%~1ext.execute=class jar"
set "%~1ext.cleanup=form"
set "%~1preferred_sdk=oracle_jdk"
set "%~1requires=compiler interpreter"
exit /b 0

rem ======================== Python ========================

:Language_python
set "%~1name=Python"
set "%~1ext.source=py pyw"
set "%~1ext.execute=py pyw pyc pyo"
set "%~1preferred_sdk=cpython3"
set "%~1requires=interpreter"
exit /b 0

rem ======================== Assembly ========================

:Language_assembly
set "%~1name=Assembly"
set "%~1ext.source=asm"
set "%~1ext.execute=exe"
set "%~1ext.cleanup=obj"
set "%~1requires=compiler"
exit /b 0

rem ============================ SDK List ============================

rem ======================== Example ========================

:Sdk_example            Label of SDK to use in code. Use this without the dot at front.
set "%~1name=           Name of the Software Development Kit
set "%~1short_name=     Short name of SDK. Maximum 12 characters
set "%~1search_path=    Where to find the root folder
set "%~1search_root=    Definition of root folder
set %~1sdk_list= ^
    ^ "compiler:    cpp     :bin\gcc.exe" !LF!^
    ^ "compiler:    python  :bin\python.exe" !LF!^
    ^ "interpreter: java    :bin\java.exe
exit /b 0


:Sdk_example.compile.cpp
rem Your compile command here
set "output_file=compile_output_file.exe"
exit /b !errorlevel!


:Sdk_example.run.python
rem Your run command here
exit /b !errorlevel!

rem ======================== Default ========================

:Sdk_default
set "%~1name=Default"
set "%~1short_name=Default"
exit /b 0


:Sdk_default.compile.unknown
call :exeption.raise "Sdk_default.compile.Unknown: Configuration Error:" ^
    "Language misconfiguration detected"
exit /b !errorlevel!


:Sdk_default.execute.unknown
%input_files% !user_parameter!
exit /b !errorlevel!

rem ======================== Manual ========================

:Sdk_manual
set "%~1name=Manual"
set "%~1short_name=Manual"
exit /b 0


:Sdk_manual.compile
"!compiler!" !user_parameter!
exit /b !errorlevel!


:Sdk_manual.execute
"!interpreter!" !user_parameter!
exit /b !errorlevel!

rem ======================== MinGW ========================

:Sdk_mingw
set "%~1name=MinGW"
set "%~1short_name=MinGW"
set "%~1search_root=MinGW*"
set %~1sdk_list= ^
    ^ "compiler:    c       :bin\gcc.exe" !LF!^
    ^ "compiler:    cpp     :bin\g++.exe"
exit /b 0


:Sdk_mingw.download   destination_folder
call :download_file "https://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip" "mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip"
call :unzip "mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip" "%~f1"
pushd "%~f1\bin"

mingw-get install gcc g++ mingw32-make
mingw-get install fortran ada java objc gdb
mingw-get install msys-base

set "path=%~f1\bin;!path!"
popd
exit /b 0


:Sdk_mingw.compile.c
set "output_file=!output_file!.exe"
gcc !input_files! -o "!output_file!" !user_parameter!
exit /b !errorlevel!


:Sdk_mingw.compile.cpp
set "output_file=!output_file!.exe"
g++ !input_files! -o "!output_file!" !user_parameter! -std=c++14
exit /b !errorlevel!

rem ======================== Cygwin ========================

:Sdk_cygwin
set "%~1name=Cygwin"
set "%~1short_name=Cygwin"
set "%~1search_root=cygwin*"
set %~1sdk_list= ^
    ^ "compiler:    c       :bin\gcc.exe" !LF!^
    ^ "compiler:    cpp     :bin\g++.exe" !LF!^
    ^ "interpreter: python  :bin\python*.exe"
exit /b 0


:Sdk_cygwin.compile.c
set "output_file=!output_file!.exe"
gcc !input_files! -o "!output_file!" !user_parameter!
exit /b !errorlevel!


:Sdk_cygwin.compile.cpp
set "output_file=!output_file!.exe"
g++ !input_files! -o "!output_file!" !user_parameter! -std=c++14
exit /b !errorlevel!

rem ======================== Visual Studio (Community) ========================

:Sdk_vs_com
set "%~1name=Visual Studio Community"
set "%~1short_name=VS Community"
set "%~1search_root=Microsoft Visual Studio"
set %~1sdk_list= ^
    ^ "compiler:    c cpp   :20*\Community\Common7\Tools\VsDevCmd.bat" !LF!^
    ^ "interpreter: python  :Shared\Python*\python.exe"
exit /b 0


:Sdk_vs_com.compile.c
set "VSCMD_START_DIR=!cd!"
call VsDevCmd.bat
set "output_file=!output_file!.exe"
cl !input_files! /link /out:"!output_file!"
exit /b !errorlevel!


:Sdk_vs_com.compile.cpp
set "VSCMD_START_DIR=!cd!"
call VsDevCmd.bat
set "output_file=!output_file!.exe"
cl /EHsc !input_files! /link /out:"!output_file!"
exit /b !errorlevel!


:Sdk_vs_com.execute.python
python !input_files! !user_parameter!
exit /b !errorlevel!

rem ======================== Visual Studio (Old) ========================

:Sdk_vs_old
set "%~1name=Visual Studio (Old)"
set "%~1short_name=VS (Old)"
set "%~1search_root=Microsoft Visual Studio *"
set %~1sdk_list= ^
    ^ "compiler:    c cpp   :VC\vcvarsall.bat"
exit /b 0


:Sdk_vs_old.compile.c
call vcvarsall.bat x86
set "output_file=!output_file!.exe"
cl !input_files! /link /out:"!output_file!"
exit /b !errorlevel!


:Sdk_vs_old.compile.cpp
call vcvarsall.bat x86
set "output_file=!output_file!.exe"
cl /EHsc !input_files! /link /out:"!output_file!"
exit /b !errorlevel!

rem ======================== Oracle Java Development Kit ========================

:Sdk_oracle_jdk
set "%~1name=Oracle Java Development Kit"
set "%~1short_name=Oracle JDK"
set "%~1search_root=Java/jdk*;jdk*"
set %~1sdk_list= ^
    ^ "compiler:    Java    :bin\javac.exe" !LF!^
    ^ "interpreter: Java    :bin\java.exe"
exit /b 0


:Sdk_oracle_jdk.compile.java
set "output_file=!output_file!.class"
javac !input_files!
exit /b !errorlevel!


:Sdk_oracle_jdk.execute.java
rem The run path is the package path [com.PackageName.ClassName]
java "!filesN!" !user_parameter!
exit /b !errorlevel!

rem ======================== CPython 2 ========================

:Sdk_cpython2
set "%~1name=CPython 2"
set "%~1short_name=Python 2"
set "%~1search_root=Python2*"
set %~1sdk_list= ^
    ^ "interpreter: python  :python.exe"
exit /b 0


:Sdk_cpython2.execute.python
python !input_files! !user_parameter!
exit /b !errorlevel!

rem ======================== CPython 3 ========================

:Sdk_cpython3
set "%~1name=CPython 3"
set "%~1short_name=Python 3"
set "%~1search_root=Python3*"
set %~1sdk_list= ^
    ^ "interpreter: python  :python.exe"
exit /b 0


:Sdk_cpython3.execute.python
python !input_files! !user_parameter!
exit /b !errorlevel!

rem ======================== GoAsm ========================

:Sdk_goasm
set "%~1name=GoAsm"
set "%~1short_name=GoAsm"
set "%~1search_root=GoAsm"
set %~1sdk_list= ^
    ^ "compiler:    assembly  :Bin\GoLink.exe"
exit /b 0


:Sdk_goasm.compile.assembly
GoAsm -fo "!output_file!.obj" !input_files!
GoLink  /console "!output_file!.obj" kernel32.dll
set "output_file=!output_file!.exe"
exit /b !errorlevel!

rem ======================================== End of Script ========================================
:EOF     May be needed if command extenstions are disabled
rem Anything beyond this are not part of the code
exit /b !errorlevel!
