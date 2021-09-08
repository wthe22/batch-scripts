@goto main


rem Easy Compiler v1.3.1
rem Updated on 2017-08-24
rem Made by wthe22 - http://winscr.blogspot.com/


:main
@echo off
prompt $s
setlocal EnableDelayedExpansion EnableExtensions

rem ======================================== Settings ========================================

rem Add this path to all language search path
rem You can also include your own (portable) SDK path here, each seperated by a semicolon (;)
set "lang_all_searchPath="
set "lang_all_searchPath=!lang_all_searchPath!;*:\Program*Files*"
set "lang_all_searchPath=!lang_all_searchPath!;*:"

rem If your SDK is not detected, you can try this:
:: set "lang_all_searchPath=!lang_all_searchPath!;!path!"

rem You can add / edit existing SDK configuration at the end of this file

rem ======================================== Script Setup ========================================

set "scriptVersion=1.3.1"
set "releaseDate=08/24/2017"

cd /d "%~dp0"
call :getScreenSize
set /a "screenWidth-=1"

call :capchar LF

rem Spaces!
set "spaces=               "

set "setupIsDone="
title Easy Compiler !scriptVersion!
cls

rem Initialize variables
set "lastUsed_action="
set "lang_all_name=All"

echo Reading SDK configurations...
call :parseConfig

if not "%~1" == "" (
    set "selected_file=%~1"
    goto dragAndDropInput
)

echo Finding all SDK files...
call :findSDK
set "setupIsDone=true"
goto mainMenu


:continueSetup
cls
echo Finding all SDK files...
call :findSDK
set "setupIsDone=true"
goto mainMenu

rem ======================================== Main Menu ========================================

:mainMenu
if not defined setupIsDone goto continueSetup
set "userInput=?"
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
set /p "userInput="
echo=
if "!userInput!" == "0" exit
if "!userInput!" == "1" goto inputFile
if "!userInput!" == "2" goto viewAllSDK
if "!userInput!" == "3" goto delFiles_menu
if "!userInput!" == "4" goto repeatLastAction
if /i "!userInput!" == "A" call :aboutScript
goto mainMenu


:repeatLastAction
if "!lastUsed_action!" == "compile/run" goto compileAndRun_lastUsed
if "!lastUsed_action!" == "delFiles" goto delFiles_lastUsed
echo No action found
pause
goto mainMenu

rem ======================================== About Script ========================================

:aboutScript
cls
title Easy Compiler !scriptVersion!
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
echo                Updated on !releaseDate!
echo=
echo  ^>^>   More scripts at http://winscr.blogspot.com/   ^<^<
pause > nul
goto :EOF

rem ======================================== Input File ========================================

:inputFile
cd /d "%~dp0"
set "selected_file=?"
cls
dir /b /o:d "*" 2> nul
echo=
echo 0. Back
echo=
echo Input file address:
set /p "selected_file="
if "!selected_file!" == "0" goto mainMenu
if exist "!selected_file!" goto compileAndRun
echo.
echo File not found
echo Hint : You can drag and drop file to this script
pause > nul
goto inputFile


:dragAndDropInput
echo Determine file type...
call :parseFile || goto dragAndDropInput_fileNotFound
echo Finding !lang_%selected_lang%_name! SDK files...
call :findSDK "!selected_lang!"
goto compileAndRun


:dragAndDropInput_fileNotFound
echo ERROR: Input file not found
pause
goto continueSetup

rem ======================================== Compile / Run File ========================================

:compileAndRun_lastUsed
set "selected_file=!lastUsed_file!"
goto compileAndRun


:compileAndRun
call :parseFile
if not "!lastUsed_action!" == "compile/run" (
    set "lastUsed_file=!selected_file!"
    set "lastUsed_action=compile/run"
)
if not defined selected_sdk goto compileAndRun_noSDK
if /i "!selected_type!" == "Compiled" goto runFile
if /i "!selected_type!" == "Related" goto compileAndRun_noAction
if /i "!selected_type!" == "Source" goto compileFile
echo=
echo ERROR: Unknown file type
pause
exit


:compileAndRun_noAction
cls
call :displayFileInfo
echo=
echo This type of file cannot be compiled or run
pause
if defined setupIsDone (
    goto mainMenu
) else goto continueSetup


:compileAndRun_noSDK
cls
call :displayFileInfo
echo=
echo This script could not find SDK for this language
echo Please add search path or manually set SDK location
pause
if defined setupIsDone (
    goto mainMenu
) else goto continueSetup


:displayFileInfo
echo File address   :
echo !selected_file!
echo=
echo Language       : !lang_%selected_lang%_name!
if "!selected_type!" == "Source"    echo Compiler       : !sdk_%selected_sdk%_name!
if "!selected_type!" == "Compiled"  echo Interpreter    : !sdk_%selected_sdk%_name!
goto :EOF


:parseFile
call :stripDQotes selected_file
set "selected_lang="
set "selected_type="
if not exist "!selected_file!" exit /b 1

for %%f in ("!selected_file!") do set "selected_file=%%~ff"

set "selected_fileExt=_"
for %%f in ("!selected_file!") do set "selected_fileExt=!selected_fileExt!%%~xf"
set "selected_fileExt=!selected_fileExt:~2!"
for %%x in (!selected_fileExt!) do for %%l in (!langList!) do for %%t in (Compiled Source Related) do (
    if not defined selected_lang if not "!lang_%%l_ext%%t: %%x = !" == "!lang_%%l_ext%%t!" (
        set "selected_lang=%%l"
        set "selected_type=%%t"
    )
)
if not defined selected_lang (
    set "selected_lang=Unknown"
    set "selected_type=Compiled"
)
if /i "!selected_type!" == "Source" set "selected_sdk=!lang_%selected_lang%_compilerSDK!"
if /i "!selected_type!" == "Compiled" set "selected_sdk=!lang_%selected_lang%_interpreterSDK!"
exit /b 0

rem ======================================== Compile File ========================================

:compileFile
set "compileParameter="
cls
call :displayFileInfo
echo=
echo Input additional compile parameters:
set /p "compileParameter="

cls
call :displayFileInfo
echo=
echo Compile parameters:
echo=!compileParameter!
echo=
echo Press any key to compile...
pause > nul
echo=

setlocal
for %%c in ("!lang_%selected_lang%_compilerPath!") do set "path=%%~dpc;!path!"
for %%f in ("!selected_file!") do cd /d "%%~dpf"
call :expandPath "!lang_%selected_lang%_compilerPath!" compiler
call :expandPath "!selected_file!" file
if "!selected_sdk!" == "Custom" set "selected_lang="
title Easy Compiler !scriptVersion! - Compiling...
cls
call :displayFileInfo
echo=
echo Additional compile parameters:
echo=!compileParameter!
echo=
set "startTime=!time!"
echo ===============================================================================
call :!selected_sdk!_compile_!selected_lang!
set "errorCode=!errorlevel!"
echo=
echo ===============================================================================
call :difftime !time! !startTime!
call :ftime !return!
title Easy Compiler !scriptVersion!
for %%f in ("!resultFile!") do (
    endlocal
    set "errorCode=%errorCode%"
    set "resultFile=%%~ff"
    set "timeTaken=%return%"
)
if not "!errorCode!" == "0" goto compile_error

set "selected_file=!resultFile!"
echo Compile done in !timeTaken!
pause > nul
echo=
if defined setupIsDone (
    goto compileAndRun
) else goto dragAndDropInput

:compile_error
echo Compile error occured. See above for more details.
echo.
echo Time taken : !timeTaken!
echo Exit code  : !errorCode!
pause > nul
goto mainMenu

rem ======================================== Run File ========================================

:runFile
set "runParameter="
cls
call :displayFileInfo
echo=
echo Input run parameters:
set /p "runParameter="

cls
call :displayFileInfo
echo=
echo Run parameters:
echo=!runParameter!
echo=
echo Press any key to run...
pause > nul
echo=

setlocal
for %%c in ("!lang_%selected_lang%_interpreterPath!") do set "path=%%~dpc;!path!"
for %%f in ("!selected_file!") do cd /d "%%~dpf"
call :expandPath "!lang_%selected_lang%_interpreterPath!" interpreter
call :expandPath "!selected_file!" file
if "!selected_sdk!" == "Custom" set "selected_lang="
title !selected_file!
cls
set "startTime=!time!"
call :!selected_sdk!_run_!selected_lang!
echo=
echo ===============================================================================
call :difftime !time! !startTime!
call :ftime !return!
title Easy Compiler !scriptVersion!
echo Execution done in !return!
echo Exit code  : !errorlevel!
endlocal
pause > nul
if defined setupIsDone (
    goto mainMenu
) else goto continueSetup

rem ======================================== Change SDK ========================================

:viewAllSDK
set "userInput=?"
cls
call :getSDK list
echo=
echo 0. Back
echo=
echo Input the list number :
set /p "userInput="
echo=
if "!userInput!" == "0" goto mainMenu
call :getSDK !userInput!
if defined selected_lang goto findSelectedSDK
goto viewAllSDK


:getSDK
set "selected_lang="
set "selected_type="
set "_listCount=0"
if /i "%~1" == "list" echo   # ^| Language     ^| Type        ^| SDK Used     ^| Path
for %%l in (!langList!) do for %%t in (Compiler Interpreter) do if defined lang_%%l_have_%%t (
    set /a "_listCount+=1"
    if /i "%~1" == "list" (
        set "_display=   !_listCount!"
        set "_display=!_display:~-3,3! ^| !lang_%%l_name!!spaces!"
        set "_display=!_display:~0,18! ^| %%t!spaces!"
        if defined lang_%%l_%%tSDK (
            for %%s in (!lang_%%l_%%tSDK!) do set "_display=!_display:~0,32! ^| !sdk_%%s_shortName!!spaces!"
            set "_display=!_display:~0,47! ^| !lang_%%l_%%tPath!"
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


:findSelectedSDK
echo Finding SDK...
set "foundSDKFiles="
for %%s in (!lang_%selected_lang%_sdkAll!) do (
    set "foundFiles="
    if not "!sdk_%%s_%selected_type%_%selected_lang%!" == "-" (
        call :findSDK_find %%s %selected_type% %selected_lang%
        for /f "tokens=*" %%a in ("!foundFiles!") do set "foundSDKFiles=!foundSDKFiles!%%s@%%a!LF!"
    )
)
goto selectSDK


:selectSDK
set "userInput=?"
cls
echo All found !lang_%selected_lang%_name! !selected_type!s :
echo=
call :getSelectedSDK list
echo=
echo 0. Back
echo.
echo Input list number or a new file address:
set /p "userInput="
echo=
if "!userInput!" == "0" goto viewAllSDK
call :getSelectedSDK !userInput!
if defined selected_file goto changeSDK
call :stripDQotes userInput
if not exist "!userInput!" (
    echo File not found
    pause > nul
    goto selectSDK
)
set "selected_sdk=Custom"
for %%f in ("!userInput!") do set "selected_file=%%~ff"
goto changeSDK


:getSelectedSDK
set "_listCount=0"
set "selected_file="
if /i "%~1" == "list" echo   # ^| Language     ^| Path
for /f "tokens=* tokens=1* delims=@" %%s in ("!foundSDKFiles!") do (
    set /a "_listCount+=1"
    if /i "%~1" == "list" (
        set "_display=   !_listCount!"
        set "_display=!_display:~-3,3! ^| !sdk_%%s_shortName!!spaces!"
        echo !_display:~0,18! ^| %%t
    ) else if /i "%~1" == "!_listCount!" (
        set "selected_sdk=%%s"
        set "selected_file=%%t"
    )
)
goto :EOF


:changeSDK
set "lang_!selected_lang!_!selected_type!SDK=!selected_sdk!"
set "lang_!selected_lang!_!selected_type!Path=!selected_file!"
echo Change successful
pause > nul
goto viewAllSDK

if defined lang_%%l_%%tSDK (
for %%s in (!lang_%%l_%%tSDK!) do set "_display=!_display:~0,32! ^| !sdk_%%s_shortName!!spaces!"
set "_display=!_display:~0,47! ^| !lang_%%l_%%tPath!"

rem ======================================== Delete Compiled Files ========================================

:delFiles_menu
set "userInput=?"
cls
call :getDelExt list
echo.
echo C. Custom
echo 0. Back
echo.
echo Choose which compiled files to delete:
set /p "userInput="
echo=
if "!userInput!" == "0" goto mainMenu
if /i "!userInput!" == "C" goto delFiles_extIn
call :getDelExt !userInput!
if not defined selected_lang goto delFiles_menu
set "delExt_list=!lang_%selected_lang%_extRemove!"
goto delFiles_checkExt


:getDelExt
set "_listCount=0"
set "selected_lang="
for %%l in (all !langList!) do if not "!lang_%%l_extRemove: =!" == "" (
    set /a "_listCount+=1"
    if /i "%~1" == "list" (
        set "_display=   !_listCount!"
        set "_display=!_display:~-3,3!. !lang_%%l_name!!spaces!"
        set "_display=!_display:~0,17!     !lang_%%l_extRemove!"
        if not "!_display:~%screenWidth%!" == "" (
            set "_display=!_display:~0,%screenWidth%!"
            set "_display=!_display:~0,-3!..."
        )
        echo=!_display!
    ) else if "%~1" == "!_listCount!" set "selected_lang=%%l"
)
goto :EOF


:delFiles_extIn
cls
echo 0. Back
echo.
echo Seperate extensions by space ( )
echo.
echo Input file extensions to delete:
set /p "delExt_list="
echo=
if "!delExt_list!" == "0" goto delFiles_menu
goto delFiles_checkExt


:delFiles_lastUsed
set "delExt_list=!lastUsed_delExt!"
goto delFiles_checkExt


:delFiles_checkExt
set "_tempList=!delExt_list!"
set "delExt_list= "
for %%x in (!_tempList!) do set "delExt_list=!delExt_list: %%x = !%%x "
set "_tempList="
set "_extCount=0"
for %%x in (!delExt_list!) do set /a "_extCount+=1"
if "!_extCount!" == "0" goto delFiles_noExt
set "delExt_source="
for %%l in (!langList!) do (
    set "_tempList="
    for %%x in (!lang_%%l_extSource!) do if not "!delExt_list: %%x =!" == "!delExt_list!" set "_tempList=!_tempList! %%x"
    if defined _tempList (
        set "_display=!lang_%%l_name!!spaces!"
        set "delExt_source=!delExt_source!!_display:~0,12! ^| !_tempList!!LF!"
    )
)
goto delFiles_showExt


:delFiles_noExt
echo No extensions listed
pause
goto delFiles_menu


:delFiles_showExt
cd /d "%~dp0"
set "userInput=?"
cls
echo Current directory:
echo=!cd!
echo=
echo Extensions to delete:
echo=!delExt_list!
echo=
if defined delExt_source (
    echo Source code extensions:
    echo !delExt_source!
    echo=
)
echo=
echo Files will be deleted permanently (not to the recycle bin)
echo=
if not defined delExt_source goto delFiles_promptDel

:delFiles_warnSrc
set /p "userInput=Source code extensions found. Continue? Y/N? "
if /i "!userInput!" == "Y" goto delFiles_promptDel
if /i "!userInput!" == "N" goto delFiles_menu
goto delFiles_warnSrc

:delFiles_promptDel
set /p "userInput=Delete files permanently? Y/N? "
if /i "!userInput!" == "Y" goto delFiles_delete
if /i "!userInput!" == "N" goto delFiles_menu
goto delFiles_promptDel


:delFiles_delete
set "lastUsed_action=delFiles"
set "lastUsed_delExt=!delExt_list!"
echo=
echo Deleting files...
echo.
set "delCount=0"
set "failCount=0"
for %%x in (!delExt_list!) do for %%f in ("*.%%x") do (
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
goto mainMenu

rem ======================================== Parse Configuration ========================================

rem Read SDK Configurations from file
rem Rewrite SDK list for each language, sorted descending order according to preferred SDKs
rem Rewrite list of extensions
rem List all extensions type for each language
rem List all language extensions for each type
rem List extensions to remove for each language

:parseConfig
rem Read SDK Configurations from file
set "dataType="
set "labelUsed="
for %%t in (lang sdk) do set "%%tList="
for /f "usebackq tokens=1* delims= " %%a in ("%~f0") do (
    if /i "%%a" == "#end" set "dataType="
    
    if /i "!dataType!" == "lang" set "lang_!labelUsed!_%%a=%%b"
    if /i "!dataType!" == "sdk" for %%s in (!labelUsed!) do (
        set "isParsed="
        for %%t in (compiler interpreter) do if /i "%%a" == "%%t" (
            for /f "tokens=1* delims= " %%l in ("%%b") do (
                set "sdk_%%s_%%t_%%l=%%m"
                set "sdk_%%s_%%tList=!sdk_%%s_%%tList! %%l"
                set "lang_%%l_sdkAll=!lang_%%l_sdkAll! %%s"
                set "isParsed=true"
            )
        )
        if not defined isParsed set "sdk_%%s_%%a=%%b"
    )
    
    for %%t in (lang sdk) do if /i "%%a" == "#%%t" (
        set "dataType=%%t"
        set "labelUsed=%%b"
        set "sdk_%%t_canCompile="
        set "sdk_%%t_canRun="
        set "%%tList=!%%tList! %%b"
    )
)

rem Rewrite SDK list for each language, sorted descending order according to preferred SDKs
for %%l in (!langList!) do (
    set "_tempList= "
    for %%s in (!lang_%%l_sdkAll!) do set "_tempList=!_tempList: %%s = !%%s "
    set "lang_%%l_sdkAll=!_tempList!"
    set "_tempList= "
    for %%d in (!lang_%%l_sdkPreferred!) do for %%s in (!lang_%%l_sdkAll!) do if "%%s" == "%%d" (
        set "_tempList=!_tempList!%%s "
        set "lang_%%l_sdkAll=!lang_%%l_sdkAll: %%s = !"
    )
    set "lang_%%l_sdkAll=!_tempList!!lang_%%l_sdkAll:~1!
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

rem ======================================== Find SDK ========================================

:findSDK
set "_findLang=!langList!"
if not "%~1" == "" set "_findLang=%~1"
set "existingDrives="
for %%l in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do vol %%l: > nul 2> nul && set "existingDrives=!existingDrives! %%l"
for %%l in (!_findLang!) do for %%t in (compiler interpreter) do (
    set "lang_%%l_have_%%t="
    set "lang_%%l_%%tPath="
    for %%s in (!lang_%%l_sdkAll!) do if not defined lang_%%l_%%tPath if defined sdk_%%s_%%t_%%l (
        set "lang_%%l_have_%%t=true"
        if "!sdk_%%s_%%t_%%l!" == "-" (
            set "lang_%%l_%%tSDK=%%s"
        ) else (
            call :findSDK_find %%s %%t %%l
            for /f "tokens=*" %%a in ("!foundFiles!") do set "lang_%%l_%%tPath=%%a"
            if defined lang_%%l_%%tPath (
                set "lang_%%l_%%tSDK=%%s"
                echo [+] !sdk_%%s_name! %%t for !lang_%%l_name!
            ) else echo [-] !sdk_%%s_name! %%t for !lang_%%l_name!
        )
    )
)
goto :EOF


:findSDK_find   sdk_label type lang
set "_path1=!lang_all_searchPath!;!sdk_%~1_searchPath!"
set "_path2=!sdk_%~1_rootFolder!\!sdk_%~1_%~2_%~3!"
for /f "delims=" %%f in ("!sdk_%~1_%~2_%~3!") do set "_path2=!_path2!;%%~nxf"
for %%v in (_path1 _path2) do set ^"%%v=!%%v:;=^
%=REQURED=%
!^"

rem Eliminate duplicate paths in _path1
set "_temp="
for /f "tokens=*" %%a in ("!_path1!") do (
    set "_isListed="
    for /f "tokens=*" %%b in ("!_temp!") do if "%%a" == "%%b" set "_isListed=Y"
    if not defined _isListed set "_temp=!_temp!%%a!LF!"
)
set "_path1=!_temp!"


rem Find SDK
set "_found="
for /f "tokens=*" %%a in ("!_path1!") do for /f "tokens=*" %%b in ("!_path2!") do (
    call :wcdir "%%a\%%b"
    set "_found=!_found!!return!"
)

rem Eliminate duplicate SDK
set "foundFiles="
for /f "tokens=*" %%a in ("!_found!") do (
    set "_isListed="
    for /f "tokens=*" %%b in ("!foundFiles!") do if "%%a" == "%%b" set "_isListed=Y"
    if not defined _isListed set "foundFiles=!foundFiles!%%a!LF!"
)
goto :EOF

rem ======================================== Script Functions ========================================

:expandPath   file_path  [prefix]
set "%~2D=%~d1"
set "%~2A=%~a1"
set "%~2T=%~t1"
set "%~2Z=%~z1"
set "%~2N=%~n1"
set "%~2X=%~x1"
set "%~2P=%~p1"
set "%~2F=%~f1"
exit /b

rem ======================================== Functions ========================================

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


:stripDQotes   variable_name
set _tempvar="!%~1:~1,-1!"
if "!%~1!" == "!_tempvar!" set "%~1=!%~1:~1,-1!"
set "_tempvar="
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

rem ================================================== Language List ==================================================

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
#end

================ C ================
#lang           C
name            C
extCompiled     exe
extRelated      h
extSource       c h
sdkPreferred    MinGW
#end

================ C++ ================
#lang           Cpp
name            C++
extCompiled     exe
extRelated      hpp h
extSource       cpp hpp h
sdkPreferred    MinGW
#end

================ Java ================
#lang           Java
name            Java
extCompiled     class jar
extRelated      form
extSource       java
sdkPreferred    JDK
#end

================ Python ================
#lang           Python
name            Python
extCompiled     py
extRelated      
extSource       py
sdkPreferred    Python
#end

================ Assembly ================
.#lang           Assembly
name            Assembly
extCompiled     exe
extRelated      
extSource       asm
sdkPreferred    
#end

rem ================================================== SDK List ==================================================

========================= Default =========================
#sdk            Default
name            Default
shortName       Default

interpreter     Unknown     -
#end

:Default_run_Unknown
"!selected_file!" !runParameter!
goto :EOF

========================= User Defined =========================
#sdk            Custom
name            User Defined
shortName       User Defined
#end

:Custom_compile_
"!compilerN!!compilerX!" "!selected_file!" !runParameter!
goto :EOF

:Custom_run_
"!interpreterN!!interpreterX!" "!selected_file!" !runParameter!
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

:Cygwin_compile_C
gcc "!fileN!!fileX!" -o "!fileN!.exe" !compileParameter!
set "resultFile=!fileN!.exe"
goto :EOF

:Cygwin_compile_Cpp
g++ "!fileN!!fileX!" -o "!fileN!.exe" !compileParameter!
set "resultFile=!fileN!.exe"
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

:MinGW_compile_C
gcc "!fileN!!fileX!" -o "!fileN!.exe" !compileParameter!
set "resultFile=!fileN!.exe"
goto :EOF

:MinGW_compile_Cpp
g++ "!fileN!!fileX!" -o "!fileN!.exe" !compileParameter!
set "resultFile=!fileN!.exe"
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

:VS_old_compile_C
call vcvarsall.bat x86
cl "!fileN!!fileX!" /out:"!fileN!.exe"
goto :EOF

:VS_old_compile_Cpp
call vcvarsall.bat x86
cl /EHsc "!fileN!!fileX!" /out:"!fileN!.exe"
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

:VS_com_compile_C
call VsDevCmd.bat
cl "!fileN!!fileX!" /out:"!fileN!.exe"
goto :EOF

:VS_com_compile_Cpp
call VsDevCmd.bat
cl /EHsc "!fileN!!fileX!" /out:"!fileN!.exe"
goto :EOF

========================= Java Development Kit =========================
#sdk            JDK
name            Java Development Kit
shortName       Java JDK
searchPath      *:\Program Files*\Java
rootFolder      jdk*

compiler        Java        bin\javac.exe
interpreter     Java        bin\java.exe
#end

:JDK_compile_Java
javac "!fileN!!fileX!"
goto :EOF

:JDK_run_Java
rem The run path is the package path [com.PackageName.ClassName]
java "!fileN!" !runParameter!
goto :EOF

========================= Python 2 =========================
#sdk            Python2
name            Python 2
shortName       Python 2
searchPath      *:
rootFolder      Python2*

interpreter     Python      python.exe
#END

:Python2_run_Python
python "!fileN!!fileX!" !runParameter!
goto :EOF

========================= Python 3 =========================
#sdk            Python3
name            Python 3
shortName       Python 3
searchPath      *:
rootFolder      Python3*

interpreter     Python      python.exe
#END

:Python3_run_Python
python "!fileN!!fileX!" !runParameter!
goto :EOF

========================= WinPython =========================
#sdk            WinPython
name            WinPython
shortName       WinPython
searchPath      *:;*:\Users\*\AppData\Local\Programs\Python
rootFolder      WinPython-*

interpreter     Python      python-*\python.exe
#END

:WinPython_run_Python
python "!fileN!!fileX!" !runParameter!
goto :EOF

========================= Go =========================
#sdk            Go
name            Go
shortName       Go
searchPath      *:
rootFolder      ECGo

compiler        Assembly    GoAsm\Bin\GoLink.exe
#END

:Go_compile_Assembly
GoAsm -fo "!fileN!.obj" "!fileN!!fileX!"
GoLink  /console "!fileN!.obj" kernel32.dll
goto :EOF

rem ====================================================================================================
rem ====================================================================================================

rem ================================================== Notes ==================================================


rem Compile multiple files with Visual Studio
cl /EHsc file1.cpp file2.cpp file3.cpp /link /out:program1.exe