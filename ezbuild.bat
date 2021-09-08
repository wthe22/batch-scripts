@goto main


rem Easy Compiler v1.4.2
rem Updated on 2018-03-31
rem Made by wthe22 - http://winscr.blogspot.com/


rem ======================================== About Script ========================================

:about_script
cls
title !SOFTWARE_NAME! !SOFTWARE_VERSION!
echo Compiling source code made easy
echo You don't need to type something like this anymore:
echo=
echo    C       gcc    "helloWorld.c"    -o "helloWorld.exe" 
echo    Java    javac  "helloWorld.java"
echo=
echo Just input the file name / drag and drop the file
echo Then this script will do the rest
echo=
echo=
echo                     Made by wthe22
echo                Updated on !SOFTWARE_RELEASE_DATE!
echo=
echo  ^>^>   More scripts at http://winscr.blogspot.com/   ^<^<
pause > nul
goto :EOF

rem ======================================== Entry Point ========================================
:__ENTRY__     Entry Point
@rem These kinds of labels serves as a bookmark


:main
@echo off
prompt $s
setlocal EnableDelayedExpansion EnableExtensions

rem ======================================== Settings ========================================

rem ? searchPath order sensitive
rem Add this path to all language search path
rem You can also include your own (portable) SDK path here, each seperated by a semicolon (;)
set "lang_all_searchPath="
set "lang_all_searchPath=!lang_all_searchPath!;*:\Program*Files*"
set "lang_all_searchPath=!lang_all_searchPath!;*:"

rem If your SDK is not detected, you can try this:
:: set "lang_all_searchPath=!lang_all_searchPath!;!path!"

rem You can add / edit existing SDK configuration at the end of this file

rem ======================================== Script Setup ========================================

set "SOFTWARE_NAME=Easy Compiler"
set "SOFTWARE_VERSION=1.4.2"
set "SOFTWARE_RELEASE_DATE=03/31/2018"

title !SOFTWARE_NAME! !SOFTWARE_VERSION!

cd /d "%~dp0"
call :getScreenSize
set /a "screenWidth-=1"
set "border_line="
for /l %%n in (1,1,!screenWidth!) do set "border_line=!border_line!="

call :capchar LF
set NL=^^^%LF%%LF%^%LF%%LF%

rem Spaces!
set "spaces="
for /l %%n in (1,1,30) do set "spaces=!spaces! "

rem Initialize variables
set "lastUsed_action="
set "setup_done="

cls
echo Reading SDK configurations...
call :Config.parse

if not "%~1" == "" (
    set ^"input_files=%*^"
    call :debug_file.parse_type
    cls
)

echo Finding all SDK files...
call :SDK.find
goto main_menu

rem ======================================== Menu ========================================
:__MENU__     Menu

:main_menu
set "user_input="
cls
echo 1. Compile / run file
echo 2. Change SDK
echo 3. Delete compiled files
echo 4. Repeat last action
echo=
echo A. About
echo 0. Exit
echo=
echo What do you want to do?
set /p "user_input="
echo=
if "!user_input!" == "0" exit
if "!user_input!" == "1" goto debug_file.input
if "!user_input!" == "2" goto lang_sdk.select
if "!user_input!" == "3" goto delete_files.select
if "!user_input!" == "4" goto repeat_action
if /i "!user_input!" == "A" call :about_script
goto main_menu


:repeat_action
if "!lastUsed_action!" == "compile/run" (
    set ^"input_files=!lastUsed_input_files!^"
    call :debug_file.parse_type
    goto main_menu
)
if "!lastUsed_action!" == "delete_files" (
    set "selected_ext=!lastUsed_delExt!"
    goto delete_files.prompt
)
goto main_menu

rem ======================================== Input File ========================================

rem ======================================== Change SDK ========================================

:lang_sdk.select
set "user_input=?"
cls
call :Lang.get_used_sdk list
echo=
echo R. Show Registered SDK
echo 0. Back
echo=
echo Input the list number :
set /p "user_input="
echo=
if "!user_input!" == "0" goto main_menu
if /i "!user_input!" == "R" call :lang_sdk.show_registered
call :Lang.get_used_sdk !user_input!
if defined selected_lang goto lang_sdk.input_path
goto lang_sdk.select


:lang_sdk.show_registered
cls
call :Lang.get_reg_sdk
pause
goto :EOF


:lang_sdk.input_path
set "user_input="
cls
if defined lang_%selected_lang%_%selected_type%_used (
    echo Current SDK:
    echo !lang_%selected_lang%_%selected_type%_path!
    echo=
    echo=
)
echo All found !lang_%selected_lang%_name! !selected_type!s:
echo=
call :Lang.get_sdk_path !selected_lang! !selected_type! list
echo=
echo 0. Back
echo=
echo Input list number or a new file address:
set /p "user_input="
echo=
if "!user_input!" == "0" goto lang_sdk.select
call :Lang.get_sdk_path !selected_lang! !selected_type! !user_input!
if defined selected_file goto lang_sdk.change
call :strip_dquotes user_input
if not exist "!user_input!" (
    echo File not found
    pause > nul
    goto lang_sdk.input_path
)
set "selected_sdk=Custom"
for %%f in ("!user_input!") do set "selected_file=%%~ff"
goto lang_sdk.change


:lang_sdk.change
set "lang_!selected_lang!_!selected_type!_used=!selected_sdk!"
set "lang_!selected_lang!_!selected_type!_path=!selected_file!"
echo Change successful
pause > nul
goto lang_sdk.select

rem ======================================== Delete Compiled Files ========================================

:delete_files.select
set "user_input="
cls
call :Ext.get_item Remove list
echo=
echo C. Custom
echo 0. Back
echo=
echo Choose which compiled files to delete:
set /p "user_input="
echo=
if "!user_input!" == "0" goto main_menu
call :Ext.get_item Remove !user_input!
if /i "!user_input!" == "C" call :delete_files.input_ext || goto delete_files.select
if defined selected_ext goto delete_files.prompt
goto delete_files.select


:delete_files.input_ext
cls
echo 0. Back
echo=
echo Seperate extensions by space
echo=
echo Input file extensions to delete:
set /p "selected_ext="
echo=
if "!selected_ext!" == "0" exit /b 1
exit /b 0


:delete_files.prompt
call :Ext.check_contains Source selected_ext
cd /d "%~dp0"
set "user_input=?"
cls
echo Current directory:
echo=!cd!
echo=
echo Extensions to delete:
echo=!selected_ext!
echo=
if defined ext_contains (
    echo Source code extensions:
    echo !ext_contains!
    echo=
)
echo=
echo Files will be deleted permanently (not to the recycle bin)
echo=

if defined ext_contains (
    call :input_yesno user_input "Source code extensions found. Continue?"
    if /i "!user_input!" == "N" goto delete_files.select
)
call :input_yesno user_input "Delete files permanently?"
if /i "!user_input!" == "N" goto delete_files.select

set "lastUsed_action=delete_files"
set "lastUsed_delExt=!selected_ext!"
echo=
echo Deleting files...
echo=
set "delCount=0"
set "failCount=0"
for %%x in (!selected_ext!) do for %%f in ("*.%%x") do (
    del /f /q "%%~ff" && (
        set /a "delCount+=1"
        echo Deleted    %%~nxf
    ) || (
        set /a "failCount+=1"
        echo Failed     %%~nxf
    )
)
echo Successfully deleted !delCount! files (!failCount! failed)
pause > nul
goto main_menu

rem ======================================== Compile / Run File ========================================

:debug_file.input
cd /d "%~dp0"
set "input_files="
cls
dir /b /o:d "*" 2> nul
echo=
echo 0. Back
echo=
echo Input file address:
set /p "input_files="
echo=
if "!input_files!" == "0" goto main_menu
call :debug_file.parse_type && goto main_menu
echo=
pause
goto debug_file.input


:debug_file.parse_type
set "lastUsed_input_files=!input_files!"
set "lastUsed_action=compile/run"

:debug_file.parse_again
echo Determining file type...
call :File.parse || exit /b 1

if /i "!input_type!" == "Source" set "_tool=compiler"
if /i "!input_type!" == "Compiled" set "_tool=interpreter"

rem ? Initialize
if /i not defined lang_%input_lang%_%_tool%_init (
    echo Finding !lang_%input_lang%_name! SDK files...
    call :SDK.find !input_lang!
)
if not defined lang_!input_lang!_!_tool!_used (
    echo=
    echo error 4: could not find !_tool! for !lang_%input_lang%_name!
    echo          Please add search path or manually set SDK location
    echo=
    pause
    exit /b 2
)


if /i "!input_type!" == "Compiled" call :debug_file.do run
if /i "!input_type!" == "Related" (
    echo error 31: this type of file cannot be compiled or run
    exit /b 1
)
if /i "!input_type!" == "Source" (
    call :debug_file.do compile
    if "!error_code!" == "0" goto debug_file.parse_again
)
goto :EOF


:debug_file.do   compile|run
rem Input parameter
set "additional_parameter="
cls
call :File.display_info
echo=
echo Input %~1 parameter:
set /p "additional_parameter="

rem Confirm action
cls
call :File.display_info
echo=
echo Additional parameter:
echo=!additional_parameter!
echo=
echo Press any key to %~1...
pause > nul
echo=

if /i "%~1" == "run" (
    title !input_display!
    cls
)

call :File.%~1
set "input_files=!result_file!"
set "result_file="

title !SOFTWARE_NAME! !SOFTWARE_VERSION!
if not "!error_code!" == "0" (
    echo Compile error occured. See above for more details.
    echo=
)
echo Time taken : !time_taken!
echo Exit code  : !error_code!
pause > nul
echo=
goto :EOF

rem ======================================== Class ========================================
:__CLASS__     Class Definition


rem ======================================== Config ========================================

rem Read SDK Configurations from file
rem Rewrite SDK list for each language, sorted descending order according to preferred SDKs
rem Rewrite list of extensions
rem List all extensions type for each language
rem List all language extensions for each type
rem List extensions to remove for each language

:Config.parse
rem Read SDK Configurations from file
set "data_type="
set "label_used="
for %%t in (lang sdk) do set "%%tList="
for /f "usebackq tokens=1* delims= " %%a in ("%~f0") do (
    if /i "%%a" == "#end" set "data_type="
    
    if /i "!data_type!" == "lang" (
        if /i "%%a" == "require" (
            for %%p in (%%b) do set "lang_!label_used!_require_%%p=True"
        ) else set "lang_!label_used!_%%a=%%b"
    )
    if /i "!data_type!" == "sdk" for %%s in (!label_used!) do (
        set "isParsed="
        for %%t in (compiler interpreter) do if /i "%%a" == "%%t" (
            for /f "tokens=1* delims= " %%l in ("%%b") do (
                set "sdk_%%s_%%t_%%l=%%m"
                set "sdk_%%s_%%tList=!sdk_%%s_%%tList! %%l"
                set "lang_%%l_sdkList=!lang_%%l_sdkList! %%s"
                set "isParsed=True"
            )
        )
        if not defined isParsed set "sdk_%%s_%%a=%%b"
    )
    
    for %%t in (lang sdk) do if /i "%%a" == "#%%t" (
        set "data_type=%%t"
        set "label_used=%%b"
        set "sdk_%%t_canCompile="
        set "sdk_%%t_canRun="
        set "%%tList=!%%tList! %%b"
    )
)
set "lang_all_name=All"

rem Rewrite SDK list for each language, sorted descending order according to preferred SDKs
for %%l in (!langList!) do (
    set "_tempList= "
    for %%s in (!lang_%%l_sdkList!) do set "_tempList=!_tempList: %%s = !%%s "
    set "lang_%%l_sdkList=!_tempList!"
    set "_tempList= "
    for %%d in (!lang_%%l_sdkPreferred!) do for %%s in (!lang_%%l_sdkList!) do if "%%s" == "%%d" (
        set "_tempList=!_tempList!%%s "
        set "lang_%%l_sdkList=!lang_%%l_sdkList: %%s = !"
    )
    set "lang_%%l_sdkList=!_tempList!!lang_%%l_sdkList:~1!
)

rem Rewrite list of extensions
for %%l in (!langList!) do for %%t in (Compiled Related Source) do (
    set "_ext= "
    for %%x in (!lang_%%l_ext%%t!) do set "_ext=!_ext: %%x = !%%x "
    set "lang_%%l_ext%%t=!_ext!"
)

rem List all extensions type for each language
set "lang_all_extRemove="
for %%l in (!langList!) do (
    set "_tempList="
    for %%t in (Compiled Related Source) do set "_tempList=!_tempList!!lang_%%l_ext%%t!"
    set "_ext= "
    for %%x in (!_tempList!) do set "_ext=!_ext: %%x = !%%x "
    set "lang_%%l_extAll=!_ext!"
    for %%x in (!lang_%%l_extSource!) do set "_ext=!_ext: %%x = !"
    set "lang_%%l_extRemove=!_ext!"
    set "lang_all_extRemove=!lang_all_extRemove!!_ext!"
)

rem List all language extensions for each type
for %%t in (Source Compiled Related) do (
    set "_tempList="
    for %%l in (!langList!) do set "_tempList=!_tempList!!lang_%%l_ext%%t!"
    set "_ext= "
    for %%x in (!_tempList!) do set "_ext=!_ext: %%x = !%%x "
    set "lang_all_ext%%t=!_ext!"
)

rem List extensions to remove for each language
set "_ext= "
for %%x in (!lang_all_extRemove!) do set "_ext=!_ext: %%x = !%%x "
for %%x in (!lang_all_extSource!) do set "_ext=!_ext: %%x = !"
set "lang_all_extRemove=!_ext!"
goto :EOF

rem ======================================== SDK ========================================

:Lang.get_used_sdk
set "selected_lang="
set "selected_type="
set "_listCount=0"
if /i "%~1" == "list" (
    echo   # ^| Language     ^| Type        ^| SDK Used     ^| Path
    echo !border_line!
)
for %%l in (!langList!) do for %%t in (Compiler Interpreter) do if defined lang_%%l_require_%%t (
    set /a "_listCount+=1"
    if /i "%~1" == "list" (
        set "_display=   !_listCount!"
        set "_display=!_display:~-3,3! ^| !lang_%%l_name!!spaces!"
        set "_display=!_display:~0,18! ^| %%t!spaces!"
        if defined lang_%%l_%%t_used (
            for %%s in (!lang_%%l_%%t_used!) do set "_display=!_display:~0,32! ^| !sdk_%%s_shortName!!spaces!"
            set "_display=!_display:~0,47! ^| !lang_%%l_%%t_path!"
        ) else (
            set "_display=!_display:~0,32! ^| *NOT FOUND*!spaces!"
            set "_display=!_display:~0,47! ^| *NOT FOUND*"
        )
        if not "!_display:~%screenWidth%!" == "" (
            set "_display=!_display:~0,%screenWidth%!
            set "_display=!_display:~0,-3!..."
        )
        echo=!_display!
    ) else if /i "%~1" == "!_listCount!" (
        set "selected_lang=%%l"
        set "selected_type=%%t"
    )
)
goto :EOF


:Lang.get_reg_sdk
echo  Language     ^| Registered SDKs
echo !border_line!
for %%l in (!langList!) do (
    set "_display=!lang_%%l_name!!spaces!"
    set "_display= !_display:~0,12! | "
    set "_display2= "
    for %%s in (!lang_%%l_sdkList!) do set "_display2=!_display2!!sdk_%%s_shortName!, "
    set "_display=!_display!!_display2:~1,-2!"
    echo !_display!
)
echo=
echo Search Path: !lang_all_searchPath:;=%NL%!
echo=
goto :EOF


:Lang.get_sdk_path   lang type list|number
set "_listCount=0"
set "selected_file="
if /i "%~3" == "list" (
    set "all_found_files="
    for %%s in (!lang_%~1_sdkList!) do (
        call :SDK.get_file_list %%s %~2 %~1
        for /f "tokens=*" %%a in ("!found_files!") do set "all_found_files=!all_found_files!%%s@%%a!LF!"
    )
    echo   # ^| SDK Name     ^| Path
    echo !border_line!
)    
for /f "tokens=* tokens=1* delims=@" %%s in ("!all_found_files!") do (
    set /a "_listCount+=1"
    if /i "%~3" == "list" (
        set "_display=   !_listCount!"
        set "_display=!_display:~-3,3! ^| !sdk_%%s_shortName!!spaces!"
        echo !_display:~0,18! ^| %%t
    ) else if /i "%~3" == "!_listCount!" (
        set "selected_sdk=%%s"
        set "selected_file=%%t"
    )
)
goto :EOF


:SDK.find   [lang1 [lang2 ...]]
set "_lang_to_find=!langList!"
if not "%~1" == "" set "_lang_to_find=%*"
for %%l in (!_lang_to_find!) do for %%t in (compiler interpreter) do if /i "!lang_%%l_require_%%t!" == "True" (
    set "lang_%%l_%%t_init=True"
    set "lang_%%l_%%t_used="
    set "lang_%%l_%%t_path="
    for %%s in (!lang_%%l_sdkList!) do if not defined lang_%%l_%%t_path if defined sdk_%%s_%%t_%%l (
        call :SDK.get_file_list %%s %%t %%l
        for /f "tokens=*" %%a in ("!found_files!") do set "lang_%%l_%%t_path=%%a"
        if defined lang_%%l_%%t_path (
            set "lang_%%l_%%t_used=%%s"
            echo [+] !sdk_%%s_name! %%t for !lang_%%l_name!
        ) else echo [-] !sdk_%%s_name! %%t for !lang_%%l_name!
    )
)
rem For files that does not need SDK to run
for %%l in (!_lang_to_find!) do (
    if /i "!lang_%%l_require_defaultRun!" == "True" set "lang_%%l_interpreter_used=Default"
)
goto :EOF

sss
:SDK.get_file_list   sdk_label type lang
rem Setup and format path
set "_path1=!lang_all_searchPath!;!sdk_%~1_searchPath!"
set "_path2=!sdk_%~1_rootFolder!\!sdk_%~1_%~2_%~3!"
for /f "delims=" %%f in ("!sdk_%~1_%~2_%~3!") do set "_path2=!_path2!;%%~nxf"
for %%p in (_path1 _path2) do set ^"%%p=!%%p:;=%NL%!^"

rem Eliminate duplicate paths in _path1
set "_temp="
for /f "tokens=*" %%a in ("!_path1!") do (
    set "_is_listed="
    for /f "tokens=*" %%b in ("!_temp!") do if "%%a" == "%%b" set "_is_listed=Y"
    if not defined _is_listed set "_temp=!_temp!%%a!LF!"
)
set "_path1=!_temp!"

rem Find SDK
set "_found="
for /f "tokens=*" %%a in ("!_path1!") do for /f "tokens=*" %%b in ("!_path2!") do (
    call :wcdir "%%a\%%b"
    set "_found=!_found!!return!"
)

rem Eliminate duplicate SDK
set "found_files="
for /f "tokens=*" %%a in ("!_found!") do (
    set "_is_listed="
    for /f "tokens=*" %%b in ("!found_files!") do if "%%a" == "%%b" set "_is_listed=Y"
    if not defined _is_listed set "found_files=!found_files!%%a!LF!"
)
goto :EOF


:File.display_info
echo File address:
echo !input_display!
echo=
echo Language   : !lang_%input_lang%_name!
if "!selected_type!" == "Source"    echo Compiler       : !sdk_%selected_sdk%_name!
if "!selected_type!" == "Compiled"  echo Interpreter    : !sdk_%selected_sdk%_name!
goto :EOF


:File.parse
rem Initialize
set "input_display=!input_files!"
set "input_count=0"
for %%v in (input_files input_dir output_path) do set "%%v="

rem Detect if input is folder
call :expand_path _first !input_display!
if /i "!_firstA:~0,1!" == "d" (
    set input_display="!_firstF!\*"
    set "output_path=!_firstF!"
)

rem Rewrite as full paths
for %%f in (!input_display!) do if exist "%%~ff" (
    set "input_files=!input_files! ^"%%~ff^""
    set /a "input_count+=1"
    if not defined input_dir set "input_dir=%%~dpf"
    if not defined output_path set "output_path=!_firstDP!\%%~nf"
) else (
    echo error 1: File not found 1>&2
    exit /b 1
)
if /i not "!_firstA:~0,1!" == "d" set ^"input_display=!input_files!^"

rem Get extensions
set "input_extensions= "
for %%f in (!input_files!) do set "input_extensions=!input_extensions: %%~xf = !%%~xf "
set "input_extensions=!input_extensions:.=!"
rem Make sure each extension occur only once. Language detection may be affected

rem Detect language
set "input_lang= "
set "_lang_count=0"
for %%l in (!langList!) do (
    set "_temp_ext=!input_extensions!"
    for %%x in (!lang_%%l_extAll!) do set "_temp_ext=!_temp_ext: %%x = !"
    if "!_temp_ext!" == " " (
        set "input_lang=!input_lang! %%l"
        set /a "_lang_count+=1"
    )
)
set "input_lang=!input_lang:~2!"
if "!_lang_count!" == "0" (
    echo error 2: input language is either unknown or mixed 1>&2
    exit /b 2
)
for /f "tokens=1 delims= " %%l in ("!input_lang!") do set "input_lang=%%l"

rem Get input file type
set "input_type= "
set "_type_count=0"
for %%t in (Compiled Source Related) do (
    set "_temp_ext=!input_extensions!"
    for %%x in (!lang_%input_lang%_ext%%t!) do set "input_extensions=!input_extensions: %%x = !"
    if not "!input_extensions!" == "!_temp_ext!" (
        set "input_type=!input_type! %%t"
        set /a "_type_count+=1"
    )
)
set "input_extensions="
set "input_type=!input_type:~2!"
if not "!_type_count!" == "1" (
    echo error 3: mixed file types. usually source code and executable 1>&2
    exit /b 3
)
if /i "!input_type!" == "Compiled" if not "!input_count!" == "1" (
    echo error 11: too many files to run 1>&2
    exit /b 11
)
if /i "!input_type!" == "Source" if not "!_lang_count!" == "1" (
    echo error 21: input matches multiple programming language 1>&2
    exit /b 21
)
exit /b 0


:File.compile
setlocal
for %%c in ("!lang_%input_lang%_compiler_path!") do set "path=%%~dpc;!path!"
cd /d "!input_dir!"
call :expand_path compiler "!lang_%input_lang%_compiler_path!" 
call :expand_multipath file !input_files!
call :expand_path output "!output_path!"
set "result_file="
set "startTime=!time!"
echo !border_line!
if "!lang_%input_lang%_compiler_used!" == "Custom" (
    call :Custom.compile
) else call :!lang_%input_lang%_compiler_used!.compile.!input_lang!
set "error_code=!errorlevel!"
echo=
echo !border_line!
call :difftime !time! !startTime!
call :ftime !return!
for %%f in ("!result_file!") do (
    endlocal
    set "error_code=%error_code%"
    set result_file="%%~ff"
    set "time_taken=%return%"
)
goto :EOF


:File.run
setlocal
for %%c in ("!lang_%input_lang%_interpreter_path!") do set "path=%%~dpc;!path!"
cd /d "!input_dir!"
call :expand_path interpreter "!lang_%input_lang%_interpreter_path!"
call :expand_path file !input_files!
set "startTime=!time!"

if "!lang_%input_lang%_interpreter_used!" == "Custom" (
    call :Custom.run
) else call :!lang_%input_lang%_interpreter_used!.run.!input_lang!
set "error_code=!errorlevel!"
echo=
echo !border_line!
call :difftime !time! !startTime!
call :ftime !return!
for %%f in (0) do (
    endlocal
    set "error_code=%error_code%"
    set "time_taken=%return%"
)
set "result_file="
goto :EOF


:Ext.get_item   type list|number
set "_listCount=0"
set "selected_lang="
for %%l in (all !langList!) do if not "!lang_%%l_ext%~1: =!" == "" (
    set /a "_listCount+=1"
    if /i "%~2" == "list" (
        set "_display=   !_listCount!"
        set "_display=!_display:~-3,3!. !lang_%%l_name!!spaces!"
        set "_display=!_display:~0,17!     !lang_%%l_ext%~1!"
        if not "!_display:~%screenWidth%!" == "" (
            set "_display=!_display:~0,%screenWidth%!"
            set "_display=!_display:~0,-3!..."
        )
        echo=!_display!
    ) else if "%~2" == "!_listCount!" set "selected_ext=!lang_%%l_ext%~1!"
)
goto :EOF


:Ext.check_contains   type variable_name
set "_temp_ext=!%~2!"
set "%~2= "
for %%x in (!_temp_ext!) do set "%~2=!%~2: %%x = !%%x "
set "_ext_count=0"
for %%x in (!%~2!) do set /a "_ext_count+=1"
if "!_ext_count!" == "0" (
    echo No extensions listed
    pause
    goto :EOF
)
set "ext_contains="
for %%l in (!langList!) do (
    set "_temp_ext="
    for %%x in (!lang_%%l_ext%~1!) do if not "!%~2: %%x =!" == "!%~2!" set "_temp_ext=!_temp_ext! %%x"
    if defined _temp_ext (
        set "_display=!lang_%%l_name!!spaces!"
        set "ext_contains=!ext_contains!!_display:~0,12! ^| !_temp_ext!!LF!"
    )
)
goto :EOF

rem ======================================== Script Functions ========================================
:__FUNCTIONS__     Functions only used in this script

:expand_multipath   prefix file_path1 [file_path2 ...]
for %%a in (D P N X F DP NX) do set "%~1%%a="
set "_continue="
for %%f in (%*) do if defined _continue (
    set ^"%~1Ds=!%~1Ds! "%%~df"^"
    set ^"%~1Ps=!%~1Ps! "%%~pf"^"
    set ^"%~1Ns=!%~1Ns! "%%~nf"^"
    set ^"%~1Xs=!%~1Xs! "%%~xf"^"
    set ^"%~1Fs=!%~1Fs! "%%~ff"^"
    set ^"%~1DPs=!%~1DPs! "%%~dpf"^"
    set ^"%~1NXs=!%~1NXs! "%%~nxf"^"
) else set "_continue=True"
exit /b

rem ======================================== Functions ========================================
:__FUNCTION_LIBRARY__     Collection of Functions


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


:strip_dquotes   variable_name
if not "!%~1!" == "" (
    set _tempvar="!%~1:~1,-1!"
    if "!%~1!" == "!_tempvar!" set "%~1=!%~1:~1,-1!"
    set "_tempvar="
)
exit /b


:wcdir   [drive:][path]filename
set "return="
set "_findNext=%~1"
set "_isFile=Y"
if "!_findNext:~-1,1!" == "\" set "_isFile="
call :wcdir_loop
set "_findNext="
set "_isFile="
exit /b 
:wcdir_loop
for /f "tokens=1* delims=\" %%a in ("!_findNext!") do if not "%%a" == "*:" (
    if "%%b" == "" (
        if defined _isFile (
            for /f "delims=" %%f in ('dir /b /a:-d "%%a" 2^> nul') do set "return=!return!%%~ff!LF!"
        ) else for /f "delims=" %%f in ('dir /b /a:d "%%a" 2^> nul') do set "return=!return!%%~ff\!LF!"
    ) else for /d %%f in ("%%a") do pushd "%%~f\" 2> nul && (
        set "_findNext=%%b"
        call :wcdir_loop
        popd
    )
) else for %%l in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do pushd "%%l:\" 2> nul && (
    set "_findNext=%%b"
    call :wcdir_loop
    popd
)
exit /b


:expand_path   prefix file_path
set "%~1D=%~d2"
set "%~1A=%~a2"
set "%~1T=%~t2"
set "%~1Z=%~z2"
set "%~1N=%~n2"
set "%~1X=%~x2"
set "%~1P=%~p2"
set "%~1F=%~f2"
set "%~1DP=%~dp2"
set "%~1NX=%~nx2"
exit /b


:getScreenSize
set "_lineNum=0"
for /f "usebackq tokens=2 delims=:" %%a in (`mode con`) do (
	set /a "_lineNum+=1"
    if "!_lineNum!" == "1" set /a "screenHeight= 0 + %%a + 0"
    if "!_lineNum!" == "2" set /a "screenWidth= 0 + %%a + 0"
)
set "_lineNum="
exit /b


:capchar   character1  [character2] [...]
rem Capture backspace character
if /i "%~1" == "B" for /f %%a in ('"prompt $h & echo on & for %%b in (1) do rem"') do (
    set "B=%%a"
)
rem Generate "backspace"
if /i "%~1" == "BS" call :capchar "B" && set "BS=!B! !B!"
rem Generate "base" for "set /p" output
if /i "%~1" == "BASE" call :capchar "BS" && set BASE="!BS!
rem Capture Carriage Return character
if /i "%~1" == "CR" for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
rem Capture Line Feed character (2 empty lines requred)
if /i "%~1" == "LF" set LF=^
%=REQURED=%
%=REQURED=%
rem Shift parameter
shift /1
if "%~1" == "" exit /b 0
goto capchar


:input_yesno   variable_name  [description]
echo=
if "%~2" == "" (
    set /p "%~1=%~1 Y/N? "
) else set /p "%~1=%~2 Y/N? "
if /i "!%~1!" == "Y" exit /b
if /i "!%~1!" == "N" exit /b
goto input_yesno

rem ================================================== Language List ==================================================
:__LANG_LIST__     Identify programming languages


================ Example ================
.#lang          Specify beginning of list, fill this with label used in the script. Use this without the dot at front.
name            Name of the programming language
extCompiled     Run this kind of file.                  Will be cleaned/deleted unless it is also source code.
extRelated      Cannot compile/run this kind of file.   Will be cleaned/deleted unless it is also source code.
extSource       Compile this kind of file.              Will not be cleaned/deleted.
sdkPreferred    Labels of your most preferred SDKs to the least preferred.
#end            Specify end of definition. Don't forget to add this!

================ Unknown ================
#lang           Unknown
name            Unknown
extCompiled     exe
extRelated      obj
extSource       
sdkPreferred    
require         defaultRun
#end

================ C ================
#lang           C
name            C
extCompiled     exe
extRelated      h
extSource       c h
sdkPreferred    MinGW
require         compiler
#end

================ C++ ================
#lang           Cpp
name            C++
extCompiled     exe
extRelated      hpp h
extSource       cpp hpp h
sdkPreferred    MinGW
require         compiler
#end

================ Java ================
#lang           Java
name            Java
extCompiled     class jar
extRelated      form
extSource       java
sdkPreferred    JDK
require         compiler interpreter
#end

================ Python ================
#lang           Python
name            Python
extCompiled     py
extRelated      
extSource       py
sdkPreferred    Python3
require         interpreter
#end

================ Assembly ================
#lang           Assembly
name            Assembly
extCompiled     exe
extRelated      
extSource       asm
sdkPreferred    
require         compiler
#end

rem ================================================== SDK List ==================================================
:__SDK_LIST__     Codes used to compile / run source codes


========================= Example =========================
.#sdk           Specify beginning of list, fill this with label used in the script. Use this without the dot at front.
name            Name of the Software Development Kit
shortName       Short name of SDK. Maximum 12 characters
searchPath      Where to find the root folder
rootFolder      Name of root folder

compiler        lang1       bin\compiler1.exe
compiler        lang2       bin\compiler2.exe
interpreter     lang1       bin\interpreter1.exe
#end

::sdk_label.compile.lang2
rem Your compile command here
set "result_file=compile_result_file.exe"
goto :EOF

::sdk_label.run.lang1
rem Your run command here
goto :EOF

========================= Default =========================
#sdk            Default
name            Default
shortName       Default
#end

:Default.run.Unknown
"!fileF!" !additional_parameter!
goto :EOF

========================= User Defined =========================
#sdk            Custom
name            User Defined
shortName       User Defined
#end

:Custom.compile
"!compilerNX!" !fileFs! !additional_parameter!
goto :EOF

:Custom.run
"!interpreterNX!" "!fileF!" !additional_parameter!
goto :EOF

========================= MinGW =========================
#sdk            MinGW
name            MinGW
shortName       MinGW
searchPath      *:
rootFolder      MinGW*

compiler        C           bin\gcc.exe
compiler        Cpp         bin\g++.exe
#end


:MinGW.compile.C
gcc !fileNXs! -o "!outputDP!\!outputN!.exe" !additional_parameter!
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF


:MinGW.compile.Cpp
g++ !fileNXs! -o "!outputDP!\!outputN!.exe" !additional_parameter! -std=c++14
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF

========================= Cygwin =========================
#sdk            Cygwin
name            Cygwin
shortName       Cygwin
searchPath      *:
rootFolder      cygwin*

compiler        C           bin\gcc.exe
compiler        Cpp         bin\g++.exe
interpreter     Python      bin\python*.exe
#end


:Cygwin.compile.C
gcc !fileNXs! -o "!outputDP!\!outputN!.exe" !additional_parameter!
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF


:Cygwin.compile.Cpp
g++ !fileNXs! -o "!outputDP!\!outputN!.exe" !additional_parameter! -std=c++14
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF

========================= Visual Studio (Community) =========================
#sdk            VS_com
name            Visual Studio Community
shortName       VS Community
searchPath      *:\Program Files*
rootFolder      Microsoft Visual Studio

compiler        C           20*\Community\Common7\Tools\VsDevCmd.bat
compiler        Cpp         20*\Community\Common7\Tools\VsDevCmd.bat
#end


:VS_com.compile.C
set "VSCMD_START_DIR=!cd!"
call VsDevCmd.bat
cl !fileNXs! /link /out:"!outputDP!\!outputN!.exe"
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF


:VS_com.compile.Cpp
set "VSCMD_START_DIR=!cd!"
call VsDevCmd.bat
cl /EHsc !fileNXs! /link /out:"!outputDP!\!outputN!.exe"
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF

========================= Visual Studio (Old) =========================
#sdk            VS_old
name            Visual Studio (Old)
shortName       VS (Old)
searchPath      *:\Program Files*
rootFolder      Microsoft Visual Studio *

compiler        C           VC\vcvarsall.bat
compiler        Cpp         VC\vcvarsall.bat
#end


:VS_old.compile.C
call vcvarsall.bat x86
cl !fileNXs! /link /out:"!outputDP!\!outputN!.exe"
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF


:VS_old.compile.Cpp
call vcvarsall.bat x86
cl /EHsc !fileNXs! /link /out:"!outputDP!\!outputN!.exe"
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF

========================= Java Development Kit =========================
#sdk            JDK
name            Java Development Kit
shortName       Oracle JDK
searchPath      *:\Program Files*\Java
rootFolder      jdk*

compiler        Java        bin\javac.exe
interpreter     Java        bin\java.exe
#end


:JDK.compile.Java
javac !fileNXs!
set "result_file=!outputDP!\!outputN!.class"
goto :EOF


:JDK.run.Java
rem The run path is the package path [com.PackageName.ClassName]
java "!fileN!" !additional_parameter!
goto :EOF

========================= Python 2 =========================
#sdk            Python2
name            Python 2
shortName       Python 2
searchPath      *:
rootFolder      Python2*

interpreter     Python      python.exe
#END


:Python2.run.Python
python "!fileNX!" !additional_parameter!
goto :EOF

========================= Python 3 =========================
#sdk            Python3
name            Python 3
shortName       Python 3
searchPath      *:
rootFolder      Python3*

interpreter     Python      python.exe
#END


:Python3.run.Python
python "!fileNX!" !additional_parameter!
goto :EOF

========================= WinPython =========================
#sdk            WinPython
name            WinPython
shortName       WinPython
searchPath      *:;*:\Users\*\AppData\Local\Programs\Python
rootFolder      WinPython-*

interpreter     Python      python-*\python.exe
#END


:WinPython.run.Python
python "!fileNX!" !additional_parameter!
goto :EOF

========================= Go =========================
#sdk            Go
name            Go
shortName       Go
searchPath      *:
rootFolder      ECGo

compiler        Assembly    GoAsm\Bin\GoLink.exe
#END


:Go.compile.Assembly
GoAsm -fo "!outputDP!\!outputN!.obj" !fileNXs!
GoLink  /console "!outputDP!\!outputN!.obj" kernel32.dll
set "result_file=!outputDP!\!outputN!.exe"
goto :EOF

rem ====================================================================================================
rem ====================================================================================================

rem ================================================== Notes ==================================================



