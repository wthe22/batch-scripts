@goto main

rem Easy Compiler v1.2.3
rem Updated on 2017-02-1

:aboutScript
cls
title Easy Compiler !scriptVersion! by wthe22
echo Compiling source code made easy
echo You don't need to type something like this anymore:
echo.
echo    C       gcc -o "helloWorld.exe" "helloWorld.c"
echo    Java    javac  "helloWorld.java"
echo.
echo Just input the file name / drag and drop the file
echo Then this script will do the rest
echo.
echo.
echo                Updated on 2017-02-01
echo.
echo  ^>^>   More scripts at http://winscr.blogspot.com/   ^<^<
pause > nul
goto mainMenu

rem You can add / edit existing SDK configuration at the end of this file

:main
@echo off
prompt $s
setlocal EnableDelayedExpansion EnableExtensions

rem Add this path to all language search path

rem Include %path% - Causes very slow search, but have the highest change of detecting SDK.
rem                  If you don't include this, script might not detect unusual SDK path.
rem You can also include your own SDK path here, each seperated by a semicolon (;)

set "all_searchPath=%~d0\Data\SDK\;C:\Program_Files\"



rem ======================================== Script Setup ========================================

set "scriptVersion=v1.2.3"

set "tempPath=!temp!\BatchScript\Easy Compiler\"
if not exist "!tempPath!" md "!tempPath!"
set "SDKListFile=!tempPath!SDK List.txt"

title Easy Compiler !scriptVersion!

rem Read SDK configuration from this file
echo Reading SDK configurations...
set "langCount=0"
set "readFile=false"
for /f "usebackq tokens=*" %%o in ("%~f0") do for /f "tokens=1* delims= " %%a in ("%%o") do (
    set "output=%%o"
    if /i        "%%a" == "#END" set "readFile=false"
    if /i "!readFile!" == "true" set "lang_%%a!langCount!=%%b"
    if "!output:~0,1!!output:~-1,1!" == "[]" (
        set /a "langCount+=1"
        set "lang_displayName!langCount!=!output:~1,-1!"
        set "readFile=true"
    )
)
set "readFile="

rem Combine all extensions
for %%t in (source compiled related) do (
    set "all_%%tExt= "
    for /l %%n in (1,1,!langCount!) do (
        set "tempVar1= !lang_%%tExt%%n!"
        set "tempVar1=!tempVar1:;= !"
        set "lang_%%tExt%%n= "
        for %%x in (!tempVar1!) do (
            set "all_%%tExt=!all_%%tExt: %%x = !%%x "
            set "lang_%%tExt%%n=!lang_%%tExt%%n: %%x = !%%x "
        )
    )
)


rem Create list of compiled file extensions
set "all_buildExt=!all_compiledExt!!all_relatedExt:~1!"
for %%x in (!all_sourceExt!) do (
    set "all_buildExt=!all_buildExt: %%x = !"
)
for /l %%n in (1,1,!langCount!) do (
    set "lang_buildExt%%n=!lang_compiledExt%%n!!lang_relatedExt%%n:~1!"
    for %%x in (!lang_sourceExt%%n!) do (
        set "lang_buildExt%%n=!lang_buildExt%%n: %%x = !"
    )
)


rem Find SDK of all languages
echo Finding SDK...
for %%t in (compiler runApp) do (
    for /l %%n in (1,1,!langCount!) do (
        call :findSDK %%n %%t
        set "%%t="
        set "%%t%%n="
        set "fileCount=0"
        for /f "usebackq tokens=*" %%o in ("!SDKListFile!") do (
            set /a "fileCount+=1"
            set "%%t=%%o"
            if "!fileCount!" == "!lang_default%%t%%n!" set "%%t%%n=%%o"
        )
        if not defined %%t%%n set "%%t%%n=!%%t!"
		for %%f in ("!%%t%%n!") do set "path=!path!;%%~dpf;"
    )
    set "%%t="
)
del /f /q "!SDKListFile!" 2> nul


rem Build GUI
call :getScreenSize
set "tempVar1= "
for /l %%n in (3,1,!screenWidth!) do set "tempVar1=!tempVar1! "
set "GUI_smallLine=!tempVar1: =-!"
set "GUI_doubleLine=!tempVar1: ==!"


cd /d "%~dp0"

if "%~1" == "" goto mainMenu

rem Parse parameter
set "selectedFile=%~1"
goto compileAndRunFile

rem ======================================== Main Menu ========================================

:mainMenu
set "userInput=?"
cls
echo 1. Compile / run file
echo 2. Change SDK
echo 3. Delete compiled files
echo 4. Repeat last action
echo.
echo A. About
echo 0. Exit
echo.
echo What do you want to do?
set /p "userInput="
if "!userInput!" == "0" exit
if "!userInput!" == "1" goto inputFile
if "!userInput!" == "2" goto viewAllSDK
if "!userInput!" == "3" goto delFilesMenu
if "!userInput!" == "4" goto repeatLastAction
if /i "!userInput!" == "A" goto aboutScript
goto mainMenu


:repeatLastAction
set "selectedFile=!lastUsedFile!"
if "!lastAction!" == "compile/run" goto compileAndRunFile
if "!lastAction!" == "delFiles" (
    set "delExtList=!lastExtList!"
    goto delFiles_check
)
echo.
echo No last action found.
pause > nul
goto mainMenu

rem ======================================== Input and Parse File ========================================

:inputFile
cd /d "%~dp0"
:inputFile_prompt
set "userInput=?"
cls
dir /b /o:d "*" 2> nul
echo.
echo 0. Back
echo.
echo Input file address:
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if exist "!userInput!" (
    set selectedFile=!userInput!
    goto compileAndRunFile
)
echo.
echo File not found
echo Hint : You can drag and drop file to this script
pause > nul
goto inputFile_prompt

:compileAndRunFile
set "lastAction=compile/run"

set tempVar1="!selectedFile:~1,-1!"
if "!selectedFile!" == "!tempVar1!" set "selectedFile=!selectedFile:~1,-1!"

for %%f in ("!selectedFile!") do set "lastUsedFile=%%~ff"

:parseFile
set "errorMsg=File not found"
if not exist "!selectedFile!" goto displayCompileRunError

set "errorMsg="
for %%f in ("!selectedFile!") do (
    set "selectedFile=%%~ff"
    set "selectedExt=.%%~xf"
    set "selectedExt=!selectedExt:~2!"
    for %%x in (!selectedExt!) do for /l %%n in (1,1,!langCount!) do (
        set "selectedLang=%%n"
        if not "!lang_compiledExt%%n: %%x = !" ==  "!lang_compiledExt%%n!" goto runSetup
        if not   "!lang_sourceExt%%n: %%x = !" ==  "!lang_sourceExt%%n!"   goto compileSetup
        if not  "!lang_relatedExt%%n: %%x = !" ==  "!lang_relatedExt%%n!"  set "errorMsg=This file type cannot be directly executed"
    )
)
set "selectedLang=?"
if not defined errorMsg set "errorMsg=Unknown file type"
goto displayCompileRunError

:displayFileInfo
echo File address   :
echo !selectedFile!
echo.
echo Language   : !lang_displayName%selectedLang%!
echo.
goto :EOF

:displayCompileRunError
cls
call :displayFileInfo
echo ERROR  : !errorMsg!
pause > nul
goto mainMenu

rem ======================================== Compile File ========================================

:compileSetup
set "errorMsg=No !lang_displayName%selectedLang%! compiler found"
if not exist "!compiler%selectedLang%!" goto displayCompileRunError

cls
call :displayFileInfo
echo Press any key to start compiling...
pause > nul

set "compiler=!compiler%selectedLang%!"
cls
title Easy Compiler !scriptVersion! - Compiling...
set "startTime=!time!"
call :compile!lang_labelName%selectedLang%!
call :difftime !time! !startTime!
call :ftime !return!
echo.
echo ===============================================================================
title Easy Compiler !scriptVersion!
if not "!errorlevel!" == "0" goto compileError
echo Compile done in !return!
pause > nul
goto parseFile

:compileError
echo Compile error occured. See above for more details.
echo.
echo Time taken : !return!
echo Exit code  : !errorlevel!
pause > nul
goto mainMenu

rem ======================================== Run File ========================================

:runSetup
set "errorMsg=No !lang_displayName%selectedLang%! run application found"
if defined lang_runAppPath!selectedLang! if not exist "!runApp%selectedLang%!" goto displayCompileRunError

:runParameterIn
set "userParameter="
cls
call :displayFileInfo
echo Input run parameter:
set /p "userParameter="

:runPrompt
cls
call :displayFileInfo
echo Parameter  :
echo.!userParameter!
echo.
echo Press any key to run this file...
pause > nul
set "runApp=!runApp%selectedLang%!"

cls
title !selectedFile!
set "startTime=!time!"
call :run!lang_labelName%selectedLang%!
call :difftime !time! !startTime!
call :ftime !return!
echo.
echo ===============================================================================
title Easy Compiler !scriptVersion!
echo DONE
echo.
echo Time Taken : !return!
echo Exit code  : !errorlevel!
pause > nul
goto mainMenu

rem ======================================== Change SDK ========================================

:viewAllSDK
set "userInput=?"
set "listCount=0"
cls
for %%t in (compiler runApp) do (
    echo !GUI_doubleLine!
    if /i "%%t" == "compiler"   echo   # ^| Compiler     ^| Path
    if /i "%%t" == "runApp"     echo   # ^| Run App      ^| Path
    echo !GUI_smallLine!
    for /l %%n in (1,1,!langCount!) do if defined lang_%%tPath%%n (
        set /a "listCount+=1"
        set "display=  !listCount!"
        set "display= !display:~-2,2! ^| !lang_displayName%%n!            "
        set "display=!display:~0,18! ^|"
        if defined %%t%%n (
            echo !display! !%%t%%n!
        ) else echo !display! NOT FOUND
    )
    echo.
)
echo 0. Back
echo.
echo Input the list number :
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if !userInput! GEQ 1 if !userInput! LEQ !listCount! goto changeSDK
goto viewAllSDK


:changeSDK
echo.
echo Finding SDK...
set "listCount=0"
for %%t in (compiler runApp) do (
    for /l %%n in (1,1,!langCount!) do if defined lang_%%tPath%%n (
        set /a "listCount+=1"
        if "!listCount!" == "!userInput!" (
            set "selectedLang=%%n"
            set "selectedType=%%t"
            call :findSDK %%n %%t
        )
    )
)
:changeSDK_in
set "userInput=?"
cls
echo All found !lang_displayName%selectedLang%! !selectedType!s :
echo.
set "fileCount=0"
for /f "usebackq tokens=*" %%o in ("!SDKListFile!") do (
    set /a "fileCount+=1"
    set "fileCount=  !fileCount!"
    echo !fileCount:~-2,2!. %%o
)
echo.
echo 0. Back
echo.
echo Input list number or a new file address:
set /p "userInput="
if "!userInput!" == "0" goto viewAllSDK
set "fileCount=0"
for /f "usebackq tokens=*" %%o in ("!SDKListFile!") do (
    set /a "fileCount+=1"
    if "!userInput!" == "!fileCount!" set "userInput=%%o"
)
if not exist "!userInput!" goto changeSDK_in
for %%f in ("!userInput!") do (
    set "!selectedType!!selectedLang!=%%~ff"
    set "path=!path!;%%~dpf;"
)
echo.
echo Change successful
pause > nul
goto viewAllSDK

rem ======================================== Delete Compiled Files ========================================

:delFilesMenu
set "userInput=?"
cls
echo  1. All
set "menuCount=1"
for /l %%n in (1,1,!langCount!) do if not "!lang_buildExt%%n!" == " " (
    set /a "menuCount+=1"
    set "menuCount=  !menuCount!"
    echo !menuCount:~-2,2!. !lang_displayName%%n!
)
echo.
echo C. Custom
echo 0. Back
echo.
echo Choose which language compiled files to delete:
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if /i "!userInput!" == "C" goto delFiles_in
if !userInput! GEQ 1 if !userInput! LEQ !menuCount! goto delFiles_getList
goto delFilesMenu

:delFiles_in
cls
echo 0. Back
echo.
echo Seperate extensions by space ( )
echo.
echo Input file extensions to delete:
set /p "delExtList="
if "!delExtList!" == "0" goto delFilesMenu
set "delExtList= !delExtList! "
goto delFiles_check

:delFiles_getList
if "!userInput!" == "1" (
    set "delExtList=!all_buildExt!"
    goto delFiles_check
)
set "menuCount=1"
for /l %%n in (1,1,!langCount!) do if not "!lang_buildExt%%n!" == " " (
    set /a "menuCount+=1"
    if "!menuCount!" == "!userInput!" (
        set "delExtList=!lang_buildExt%%n!"
    )
)
goto delFiles_check

:delFiles_check
set "delExtCount=0"
set "tempVar1=!delExtList!"
set "delExtList= "
for %%x in (!tempVar1!) do (
    set /a "delExtCount+=1"
    set "delExtList=!delExtList: %%x = !%%x "
)
if "!delExtCount!" == "0" (
    echo.
    echo No extensions are listed. Nothing to delete...
    pause
    goto delFilesMenu
)

set "sourceExtList="
for %%x in (!all_sourceExt!) do (
    if not "!delExtList: %%x = !" == "!delExtList!" (
        set "sourceExtList=!sourceExtList! %%x"
    )
)
if not defined sourceExtList goto delFiles_prompt

:delFiles_sourcePrompt
set "userInput=?"
cls
echo Extensions to delete:
echo.!delExtList!
echo.
echo Source code extensions:
echo !sourceExtList!
echo.
echo WARNING: Source code extensions are included.
echo.
set /p "userInput=Do you want to exclude source code extensions? Y/N? "
if /i "!userInput!" == "N" goto delFiles_prompt
if /i not "!userInput!" == "Y" goto delFiles_sourcePrompt
for %%x in (!all_sourceExt!) do (
    set "delExtList=!delExtList: %%x = !"
)
goto delFiles_check

:delFiles_prompt
cd /d "%%~dp0"
set "userInput=?"
cls
echo Current directory:
echo.!cd!
echo.
echo Extensions:
echo.!delExtList!
echo.
if defined sourceExtList (
    echo Source code extensions:
    echo !sourceExtList!
    echo.
)
echo ===============================================================================
echo.
echo Note : Files deleted will not go into the recycle bin
echo.
echo Permanently delete all files with these extensions?
set /p "userInput=Y/N? "
if /i "!userInput!" == "Y" goto delFiles_delete
if /i "!userInput!" == "N" goto delFilesMenu
goto delFiles_prompt

:delFiles_delete
set "lastAction=delFiles"
set "lastExtList=!delExtList!"
echo.
echo Deleting files...
echo.
set "delCount=0"
set "failCount=0"
for %%x in (!delExtList!) do (
    for %%f in ("*.%%x") do (
        del /f /q "%%~ff" && (
            set /a "delCount+=1"
            echo Deleted    %%~ff
        ) || (
            set /a "failCount+=1"
            echo Failed     %%~ff
        )
    )
)
echo Successfully deleted !delCount! files (!failCount! failed)
pause > nul
goto mainMenu

rem ======================================== Functions ========================================

:findSDK [language_number] [type]
set "searchPath1=!lang_searchPath%1!;!all_searchPath!"
set "searchPath2=!lang_%2Path%1!"
rem. > "!SDKListFile!"
if "!searchPath1!" == ";" goto :EOF
if not defined searchPath2 goto :EOF
:findSDK_loop
for /f "tokens=1* delims=;" %%a in ("!searchPath1!") do (
    for /f "tokens=1* delims=;" %%c in ("!searchPath2!") do (
        call :findFile "%%a\%%c" >> "!SDKListFile!"
        set "searchPath2=%%d"
        if not defined searchPath2 (
            set "searchPath1=%%b"
            set "searchPath2=!lang_%2Path%1!"
        )
    )
)
if defined searchPath1 goto findSDK_loop
goto :EOF

:findFile
if "%~1" == "" goto :EOF
set "tempVar2=%~1"
:findFile_loop
for /f "tokens=1* delims=\" %%a in ("!tempVar2!") do set "tempVar1=%%a" & set "tempVar2=%%b"
if defined tempVar2 (
    for /d %%f in ("!tempVar1::=:\!") do (
        setlocal
        cd /d "%%~f" 2> nul && call :findFile_loop
        endlocal
    )
) else for /f "delims=" %%f in ('dir /b /a:-d "!tempVar1!" 2^> nul') do echo %%~ff
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

:getScreenSize
set "tempVar1=0"
for /f "usebackq tokens=*" %%o in (`mode con`) do (
	set /a "tempVar1+=1"
    for /f "tokens=2 delims= " %%a in ("%%o") do (
        if "!tempVar1!" == "3" set /a "screenHeight= 0 + %%a + 0"
        if "!tempVar1!" == "4" set /a "screenWidth= 0 + %%a + 0"
    )
)
goto :EOF

rem ================================================== Compile Settings ==================================================

rem ================================================== Example ==================================================

- [Language name here]
labelName       Label of this language used in this script. For example XXX
searchPath      Where to search for compiler and run application
compilerPath    path\may\contain\*wildcards*\compiler.exe
runAppPath      path\may\contain\*wildcards*\runApp.exe
sourceExt       Extensions of source code
compiledExt     Extensions of compiled codes            Files with this extensions will be deleted when clean builds
relatedExt      Extensions related to compiled codes    Files with this extensions will be deleted when clean builds
defaultCompiler Compiler number which you prefer to use.        You can get this number from SDK list. Default is 0
defaultRunApp   Run Application number which you prefer to use. You can get this number from SDK list. Default is 0
#END

:compileXXX
rem How to compile the code...
"!compiler!" "!fileF!"
set "fileAddress=!fileD!!fileP!!fileN!.class"
goto :EOF

:runXXX
rem How to run the code...
goto :EOF

rem ================================================== Unknown ==================================================

[Unknown]
labelName       Unknown
compiledExt     exe
relatedExt      obj
#END

rem OBJ - Visual Studio Object

:runUnknown
"!selectedFile!" !userParameter!
goto :EOF

rem ================================================== Batch Script ==================================================

- [Batch Script]
labelName       BatchScript
sourceExt       bat cmd
compiledExt     bat cmd
#END

:runBatchScript
"!selectedFile!" !userParameter!
goto :EOF

rem ================================================== C ==================================================

[C]
labelName       C
searchPath      C:\;C:\Program Files*\
compilerPath    cygwin*\bin\gcc.exe;MinGW*\bin\gcc.exe;Microsoft Visual Studio *\VC\vcvarsall.bat
runAppPath      
sourceExt       c
compiledExt     exe
relatedExt      
defaultCompiler 0
defaultRunApp   0
#END

:compileC
for %%c in (!compiler!) do (
    if /i "%%~nc" == "gcc"      	goto compileC_gcc
	if /i "%%~nc" == "vcvarsall"	goto compileC_vcvarsall
)
set "errorMsg=Compile method for this compiler is missing"
goto displayCompileRunError

:compileC_gcc
setlocal
for %%c in ("!compiler!") do set "path=!path!;%%~dpc"
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    "!compiler!" -o "%%~nf.exe" "%%~nxf"
    endlocal
    set "selectedFile=%%~dpnf.exe"
)
goto :EOF

:compileC_vcvarsall
rem Visual Studio compile method 
setlocal
call "!compiler!" x86
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    cl "%%~nxf"
    endlocal
    set "selectedFile=%%~dpnf.exe"
)
goto :EOF

rem Compile multiple files with Visual Studio
cl       file1.c   file2.c   file3.c   /link /out:program1.exe 

rem ================================================== C++ ==================================================

[C++]
labelName       Cpp
searchPath      C:\;C:\Program Files*\
compilerPath    cygwin*\bin\g++.exe;MinGW*\bin\g++.exe;Microsoft Visual Studio *\VC\vcvarsall.bat
runAppPath      
sourceExt       cpp
compiledExt     exe
relatedExt      
defaultCompiler 0
defaultRunApp   0
#END

:compileCpp
for %%c in (!compiler!) do (
    if /i "%%~nc" == "g++"      	goto compileCpp_gpp
	if /i "%%~nc" == "vcvarsall"	goto compileCpp_vcvarsall
)
set "errorMsg=Compile method for this compiler is missing"
goto displayCompileRunError

:compileCpp_gpp
setlocal
for %%c in ("!compiler!") do set "path=!path!;%%~dpc"
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    "!compiler!" -o "%%~nf.exe" "%%~nxf"
    endlocal
    set "selectedFile=%%~dpnf.exe"
)
goto :EOF

:compileCpp_vcvarsall
rem Visual Studio compile method 
setlocal
call "!compiler!" x86
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    cl /EHsc "%%~nxf"
    endlocal
    set "selectedFile=%%~dpnf.exe"
)
goto :EOF

rem Compile multiple files with Visual Studio
cl /EHsc file1.cpp file2.cpp file3.cpp /link /out:program1.exe 

rem ================================================== Java ==================================================

[Java]
labelName       Java
searchPath      C:\Program Files*\Java\
compilerPath    jdk*\bin\javac.exe
runAppPath      jdk*\bin\java.exe
sourceExt       java
compiledExt     class jar
relatedExt      form
defaultCompiler 0
defaultRunApp   0
#END

:compileJava
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    "!compiler!" "%%~nxf"
    set "selectedFile=%%~dpnf.class"
)
goto :EOF

:runJava
rem The run path is the package path [com.PackageName.ClassName]
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    "!runApp!" "%%~nf" !userParameter!
)
goto :EOF

rem ================================================== Python ==================================================

[Python]
labelName       Python
searchPath      C:\;C:\Users\!username!\AppData\Local\Programs\Python\
runAppPath      Python*\python.exe;WinPython-*\python-*\python.exe
sourceExt       py
compiledExt     py
relatedExt      
defaultRunApp   0
#END

:runPython
for %%f in ("!selectedFile!") do (
    cd /d "%%~dpf"
    "!runApp!" "%%~ff" !userParameter!
)
goto :EOF

rem ====================================================================================================
