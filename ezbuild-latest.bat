:entry_point
@goto main


rem ############################################################################
rem License
rem ############################################################################

:license
echo MIT License
echo=
echo Copyright 2017-2023 wthe22
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

rem ############################################################################
rem Changelog
rem ############################################################################

:changelog
::  v1.5dev3 (2023-02-27) WIP
::      Development progress of v1.5
::      - Updated library and framework version from batchlib 3.2dev3
::      - New settings format (again)
::      - Refactor again
::      - Add download SDK
::
::  v1.5dev2 (2019-08-23)
::      Development progress of v1.5
::      - Fixed folder not recognized when attempting to compile from menu
::      - Implemented repeat_action for compile/run
::      - Added SDK searh path for MinGW in Code::Blocks
::
::  v1.5dev1 (2019-05-03)
::      Development progress of v1.5
::      - Added development plans
::
::  v1.5dev (2019-04-27)
::      Refactor Update
::      - added framework from batchlib 2.0-b.2
::      - new settings format
::      - Renamed script from 'Easy Compiler' to 'Easy Build Tool'
::
::  v1.4.2 (2018-03-31)
::
::  v1.3.1 (2017-08-24)
::
::  v1.2.3 (2017-02-1)
::
::  v1.0? (2014-12-31)
::      First publication
exit /b 0


rem ############################################################################
rem Metadata
rem ############################################################################

:metadata [return_prefix]
set "%~1name=ezbuild"
set "%~1version=1.5dev3"
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
echo Copyright (C) 2017-2023 by !author!
echo Licensed under !license!
endlocal
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

set "Language.exclude="
set "Sdk.exclude="

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


rem ############################################################################
rem Main
rem ############################################################################

:main
@if ^"%1^" == "-c" @goto subcommand.call
@setlocal EnableDelayedExpansion EnableExtensions
@echo off
if ^"%1^" == "-h" goto doc.help
if ^"%1^" == "--help" goto doc.help
call :metadata SOFTWARE.
call :config

call :capchar LF

call :main_menu
@exit /b


:subcommand.call -c :<label> [arguments] ...
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


rem ############################################################################
rem User Interfaces
rem ############################################################################

:ui
exit /b 0


:main_menu
set "user_input="
cls
echo !SOFTWARE.description! !SOFTWARE.version!
echo=
echo 1. Compile / run file
echo 2. Show environments
echo=
echo A. About
echo 0. Exit
echo=
echo What do you want to do?
set /p "user_input="
echo=
if "!user_input!" == "0" exit /b 0
if "!user_input!" == "1" call :process_file
if "!user_input!" == "2" call :show_envs
if /i "!user_input!" == "A" (
    cls
    call :about
    echo=
    pause
)
goto main_menu


:show_envs
call :Env.init
for %%e in (!Env.list!) do (
    call :Env.scan Env_%%e.path %%e
)

cls
set Env
echo=
pause
exit /b 0


rem ############################################################################
rem Assets
rem ############################################################################

:assets
rem Additional data to bundle
exit /b 0

rem ################################ Language List ################################

:Language.init
set "Language.list=unknown c cpp java python assembly"
set "Language.ext_types=source compile execute cleanup related"
exit /b 0

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
set "%~1execute=exe"
set "%~1cleanup=obj"
set "%~1force_sdk=default"
set "%~1requires=interpreter"
exit /b 0


:Language_unknown.identify <file> ...
if not ^"%2^" == "" exit /b 3
if not "%~x1" == ".exe" exit /b 3
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
set "%~1preferred_lp=mingw cygwin"
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

rem ################################ Environment List ################################

:Env.init
set Env.list=^
    ^ default cygwin mingw msys2 vs_com vs_old ^
    ^ oracle_jdk cpython2 cpython3 goasm ^
    ^ %=END=%
exit /b 0


:Env.scan <return_var> <env>
setlocal EnableDelayedExpansion
set "_return_var=%~1"
set "_env=%~2"
if not defined _env exit /b 2
call :Env.read "!_env!"
set "_result="
for /f "tokens=* delims=" %%a in ("!Env_%_env%.search_path!") do (
    for /f "tokens=* delims=" %%b in ("!Env_%_env%.search_root!") do (
        call :wcdir _found "%%a\%%b" -d
        set "_result=!_result!!_found!!LF!"
    )
)
if defined _result (
    set "%_return_var%="
    for /f "tokens=* delims=" %%r in ("!_result!") do (
        if not defined %_return_var% (
            endlocal
            set "%_return_var%="
        )
        set "%_return_var%=!%_return_var%!%%r!LF!"
    )
) else (
    endlocal
    set "%_return_var%="
)
exit /b 0


:Env.read <end>
if "%~1" == "" exit /b 2
call :Env_%~1 Env_%~1.
set "Env_%~1.search_path=!Env_%~1.search_path:;=%NL%!"
set "Env_%~1.1search_root=!Env_%~1.1search_root:;=%NL%!"
exit /b 0


rem ======================== Example ========================

:Env_example            Label of SDK to use in code
set "%~1name=           Name of the Software Development Kit
set "%~1short_name=     Short name of SDK. Max 12 characters
set "%~1search_path=    Where to find the root folder
set "%~1search_root=    Definition of root folder
set %~1sdk_list= ^
    ^ "compiler:    cpp     :bin\gcc.exe" !LF!^
    ^ "compiler:    python  :bin\python.exe" !LF!^
    ^ "interpreter: java    :bin\java.exe
exit /b 0

rem ======================== Default ========================

:Env_default
set "%~1name=Default"
set "%~1short_name=Default"
exit /b 0

rem ======================== Cygwin ========================

:Env_cygwin
set "%~1name=Cygwin"
set "%~1short_name=Cygwin"
set "%~1search_path=*:"
set "%~1search_root=cygwin*"
set %~1sdk_list= ^
    ^ "c.compiler:          bin\gcc.exe" !LF!^
    ^ "cpp.compiler:        bin\g++.exe" !LF!^
    ^ "python.interpreter:  bin\python*.exe" !LF!^
    ^ %=END=%
exit /b 0

rem ======================== MinGW ========================

:Env_mingw
set "%~1name=MinGW"
set "%~1short_name=MinGW"
set "%~1search_path=*:;*:\Program*Files*\CodeBlocks"
set "%~1search_root=MinGW*"
exit /b 0


:Env_mingw.download   destination_folder
call :download_file "https://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip" "mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip"
call :unzip "mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip" "%~f1"
pushd "%~f1\bin"
mingw-get install gcc g++ mingw32-make
mingw-get install fortran ada java objc gdb
mingw-get install msys-base
set "path=%~f1\bin;!path!"
popd
exit /b 0

rem ======================== MSYS2 ========================

:Env_msys2
set "%~1name=MSYS2"
set "%~1short_name=MinGW"
set "%~1search_path=*:"
set "%~1search_root=msys64"
exit /b 0

rem ======================== VS Community ========================

:Env_vs_com
set "%~1name=Microsoft Visual C++"
set "%~1short_name=MSVC"
set "%~1search_path=*:\Program*Files*"
set "%~1search_root=Microsoft Visual Studio"
set %~1sdk_list= ^
    ^ "compiler:    c cpp   :20*\Community\Common7\Tools\VsDevCmd.bat" !LF!^
    ^ "interpreter: python  :Shared\Python*\python.exe"
exit /b 0

rem ======================== Visual Studio (Old) ========================

:Env_vs_old
set "%~1name=Visual Studio (Old)"
set "%~1short_name=VS (Old)"
set "%~1search_path=*:\Program*Files*"
set "%~1search_root=Microsoft Visual Studio *"
set %~1sdk_list= ^
    ^ "compiler:    c cpp   :VC\vcvarsall.bat"
exit /b 0

rem ======================== Oracle JDK ========================

:Env_oracle_jdk
set "%~1name=Java Development Kit"
set "%~1short_name=JDK"
set "%~1search_path=*:\Program*Files*"
set "%~1search_root=Java/jdk*;jdk*"
set %~1sdk_list= ^
    ^ "compiler:    Java    :bin\javac.exe" !LF!^
    ^ "interpreter: Java    :bin\java.exe"
exit /b 0

rem ======================== CPython 2 ========================

:Env_cpython2
set "%~1name=CPython 2"
set "%~1short_name=Python 2"
set "%~1search_path=*:\Program*Files*"
set "%~1search_root=Python2*"
set %~1sdk_list= ^
    ^ "interpreter: python  :python.exe"
exit /b 0

rem ======================== CPython 3 ========================

:Env_cpython3
set "%~1name=CPython 3"
set "%~1short_name=Python 3"
set "%~1search_path=*:\Program*Files*"
set "%~1search_root=Python3*"
set %~1sdk_list= ^
    ^ "interpreter: python  :python.exe"
exit /b 0

rem ======================== GoAsm ========================

:Env_goasm
set "%~1name=GoAsm"
set "%~1short_name=GoAsm"
set "%~1search_root=GoAsm"
set %~1sdk_list= ^
    ^ "compiler:    assembly  :Bin\GoLink.exe"
exit /b 0


rem ################################ Language Processor List ################################

:LP.load
set "LP.list=default gcc msvc jdk cpython goasm"
exit /b 0

rem ======================== Default ========================

:LP_default.unknown.execute
%input_files% !user_parameter!
exit /b

rem ========================LP CPython ========================

:LP_cpython.python.execute
python !input_files! !user_parameter!
exit /b !errorlevel!

rem ======================== GCC ========================

:LP_gcc
set "%~1name=GNU Compiler Collection"
set "%~1short_name=GCC"
exit /b 0


:LP_gcc.c.compile
set "output_file=!output_file!.exe"
gcc -static !input_files! -o "!output_file!" !user_parameter!
exit /b


:LP_gcc.cpp.compile
set "output_file=!output_file!.exe"
g++ -static !input_files! -o "!output_file!" !user_parameter! -std=c++14
:: g++ -static !input_files! -o "!output_file!" !user_parameter! -std=c++14
exit /b

rem ======================== MSVC ========================

:LP_msvc
set "%~1name=Microsoft Visual C++"
set "%~1short_name=MSVC"
exit /b 0

:LP_msvc.c.compile
if "!env!" == "vs_old" (
    call vcvarsall.bat x86
) else (
    set "VSCMD_START_DIR=!cd!"
    call VsDevCmd.bat
)
set "output_file=!output_file!.exe"
cl !input_files! /link /out:"!output_file!"
exit /b !errorlevel!


:LP_msvc.cpp.compile
if "!env!" == "vs_old" (
    call vcvarsall.bat x86
) else (
    set "VSCMD_START_DIR=!cd!"
    call VsDevCmd.bat
)
set "output_file=!output_file!.exe"
cl /EHsc !input_files! /link /out:"!output_file!"
exit /b !errorlevel!


:LP_msvc.python.execute
python !input_files! !user_parameter!
exit /b !errorlevel!

rem ======================== JDK ========================

:LP_jdk.java.compile
set "output_file=!output_file!.class"
javac !input_files!
exit /b !errorlevel!


:LP_jdk.java.execute
rem The run path is the package path [com.PackageName.ClassName]
java "!filesN!" !user_parameter!
exit /b !errorlevel!

rem ======================== GoAsm ========================

:LP_goasm.assembly.compile
GoAsm -fo "!output_file!.obj" !input_files!
GoLink  /console "!output_file!.obj" kernel32.dll
set "output_file=!output_file!.exe"
exit /b !errorlevel!

rem ############################################################################
rem Library
rem ############################################################################

:lib.dependencies [return_prefix]
set %~1install_requires= ^
    ^ capchar list_lf2set wcdir ^
    ^ unzip download_file ^
    ^ %=END=%
rem Missing: expand_path expand_multipath fix_eol check_win_eol
exit /b 0


rem ############################################################################
rem End of File
rem ############################################################################

:EOF
@rem DO NOT WRITE ANYTHING YOU NEED TO KEEP BELOW THIS FUNCTION.
@rem ANYTHING BEYOND THIS FUNCTION WILL BE REMOVED WHEN ADDING DEPENDENCIES.
exit /b


:: Automatically Added by batchlib 3.2dev3 on Mon 02/27/2023 21:14:59.03

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


:list_lf2set <return_var> <input_var>
setlocal EnableDelayedExpansion
set "_return_var=%~1"
set "_input_var=%~2"
set LF=^
%=REQUIRED=%
%=REQUIRED=%
(
    ( call )
    for /f "tokens=* delims=" %%a in ("q!LF!!%_input_var%!") do (
        if "!errorlevel!" == "0" (
            endlocal
            set "%_return_var%="
        ) else (
            ( call )
            for /f "tokens=* delims=" %%b in ("!%_return_var%!") do (
                if "!errorlevel!" == "0" (
                    if "%%a" == "%%b" call
                )
            )
            if "!errorlevel!" == "0" (
                set %_return_var%=!%_return_var%!%%a^
%=REQUIRED=%
%=REQUIRED=%
            )
        )
        call
    )
    if "!errorlevel!" == "0" (
        set "%_return_var%="
    )
)
exit /b 0


:wcdir <return_var> <wildcard_path> [-f|-d]
set "%~1="
setlocal EnableDelayedExpansion
set "_list_dir=true"
set "_list_file=true"
if "%~3" == "-d" set "_list_file="
if "%~3" == "-f" set "_list_dir="
set "_args=%~2"
set "_args=!_args:/=\!"
set "_result="
set LF=^
%=REQUIRED=%
%=REQUIRED=%
call :wcdir._find "!_args!"
for /f "tokens=* delims=" %%r in ("!_result!") do (
    if not defined %~1 endlocal
    set %~1=!%~1!%%r^
%=REQUIRED=%
%=REQUIRED=%
)
exit /b 0
#+++

:wcdir._find   wildcard_path
for /f "tokens=1* delims=\" %%a in ("%~1") do if "%%a" == "*:" (
    for %%l in (
        A B C D E F G H I J K L M
        N O P Q R S T U V W X Y Z
    ) do pushd "%%l:\" 2> nul && call :wcdir._find "%%b"
) else if "%%b" == "" (
    if defined _list_dir dir /b /a:d "%%a" > nul 2> nul && (
        for /d %%f in ("%%a") do set "_result=!_result!%%~ff!LF!"
    )
    if defined _list_file dir /b /a:-d "%%a" > nul 2> nul && (
        for %%f in ("%%a") do set "_result=!_result!%%~ff!LF!"
    )
) else for /d %%f in ("%%a") do pushd "%%f\" 2> nul && call :wcdir._find "%%b"
popd
exit /b


:unzip <zip_file> <destination_dir>
setlocal EnableDelayedExpansion
set "_zip_file=%~f1"
set "_dest_path=%~f2"
cd /d "!tmp_dir!" 2> nul || cd /d "!tmp!"
if not exist "!_dest_path!" md "!_dest_path!" || (
    1>&2 echo%0 Fail to create destination directory & exit /b 2
)
> "unzip.vbs" (
    echo zip_file = WScript.Arguments(0^)
    echo dest_path = WScript.Arguments(1^)
    echo=
    echo set ShellApp = CreateObject("Shell.Application"^)
    echo set content = ShellApp.NameSpace(zip_file^).items
    echo ShellApp.NameSpace(dest_path^).CopyHere(content^)
)
set "success="
cscript //nologo "unzip.vbs" "!_zip_file!" "!_dest_path!" && set "success=true"
del /f /q "unzip.vbs"
if not defined success exit /b 3
exit /b 0


:ext_vbscript
cscript > nul
exit /b


:download_file <url> <save_path>
if exist "%~2" del /f /q "%~2"
if not exist "%~dp2" md "%~dp2"
powershell -Command "(New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
if not exist "%~2" exit /b 1
exit /b 0


:ext_powershell
powershell -Command "$PSVersionTable.PSVersion.ToString()"
exit /b


