@echo off
title Color Contrast Ratio
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "tempPath=!temp!\BatchScript\"
if not exist "!tempPath!" md "!tempPath!"


cls
echo Input minimum contrast ratio:
set /p "min_value="

color 07
cls
title Color Contrast Ratio - Minimum !min_value!
call :display_contrast !min_value!
pause
exit

rem Functions

:display_contrast   minimum
setlocal EnableDelayedExpansion
set "minimum=%~1"
if not defined minimum set "minimum=0"
for /f "tokens=1-2 delims=." %%a in ("!minimum!.0") do (
    set "whole=00%%a"
    set "decimal=%%b000"
)
set "minimum=!whole:~-2,2!!decimal:~0,3!"
set "space=          "
call :capchar DEL
for %%a in (
    %=             0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F  =%
    "0_0F_0000:  01000 01312 04088 04399 01918 02230 05006 11542 05317 02444 15304 16748 05252 06696 19556 21000"
    "1_1F_0016:  01312 01000 03116 03354 01462 01700 03816 08799 04054 01863 11667 12768 04004 05105 14909 16010"
    "2_2F_0154:  04088 03116 01000 01076 02131 01833 01225 02824 01301 01673 03744 04097 01285 01638 04784 05137"
    "3_3F_0170:  04399 03354 01076 01000 02294 00973 01138 02624 01209 01800 03479 03807 01194 01522 04445 04773"
    "4_4F_0046:  01918 01462 02131 02294 01000 01163 02610 06018 02773 01274 07980 08733 02738 03491 10197 10950"
    "5_5F_0061:  02230 01700 01833 01973 01163 01000 02245 05177 02385 01096 06864 07512 02356 03003 08771 09419"
    "6_60_0200:  05006 03816 01225 01138 02610 02245 01000 02306 01062 02048 03057 03346 01049 01338 03907 04195"
    "7_70_0527:  11542 08799 02824 02624 06018 05177 02306 01000 02171 04723 01326 01451 02198 01724 01694 01819"
    "8_80_0216:  05317 04054 01301 01209 02773 02385 01062 02171 01000 02176 02878 03150 01012 01259 03678 03949"
    "9_9F_0072:  02444 01863 01673 01800 01274 01096 02048 04723 02176 01000 06262 06853 02149 02740 08002 08592"
    "A_A0_0715:  15304 11667 03744 03479 07980 06864 03057 01326 02878 06262 01000 01094 02914 02286 01278 01372"
    "B_B0_0787:  16748 12768 04097 03807 08733 07512 03346 01451 03150 06853 01094 01000 03189 02501 01168 01254"
    "C_C0_0213:  05252 04004 01285 01194 02738 02356 01049 02198 01012 02149 02914 03189 01000 01275 03724 03998"
    "D_D0_0285:  06696 05105 01638 01522 03491 03003 01338 01724 01259 02740 02286 02501 01275 01000 02921 03136"
    "E_E0_0928:  19556 14909 04784 04445 10197 08771 03907 01694 03678 08002 01278 01168 03724 02921 01000 01074"
    "F_F0_1000:  21000 16010 05137 04773 10950 09419 04195 01819 03949 08592 01372 01254 03998 03136 01074 01000"
) do for /f "tokens=1* delims=:" %%b in (%%a) do (
    for /f "tokens=1-3 delims=_" %%d in ("%%b") do (
        set "number=      %%f"
        set "number=!number:~-5,2!.!number:~-3,3!"
        call :color_print %%e "!space![%%d] Luminance        !number!!space!"
        echo=
        set "hex=0123456789ABCDEF"
        for %%r in (%%c) do (
            if 1%%r GEQ 1!minimum! (
                set "number=      %%r"
                set "number=!number: 0=  !"
                set "number=!number:~-5,2!.!number:~-3,3!"
                call :color_print %%d!hex:~0,1! "!space![!hex:~0,1!] Contrast Ratio   !number!!space!"
                echo=
            )
            set "hex=!hex:~1!"
        )
    )
    echo=
)
exit /b 0


:color_print   color  text
goto colorPrint
rem This function is too slow
2> nul (
    pushd "!temp_path!" || exit /b 1
     < nul > "%~2_" set /p "=!DEL!!DEL!"
    findstr /l /v /a:%~1 "." "%~2_" nul
    del /f /q "%~2_" > nul
    popd
)
exit /b 0


:colorPrint
pushd "!tempPath!"
(
    set /p "=!DEL!!DEL!" < nul > "%~2_"
    findstr /l /v /a:%~1 "." "%~2_" nul
    del /f /q "%~2_" > nul
) 2> nul
popd
goto :EOF


:capchar   character1  [character2 [...]]
if "%~1" == "*" call :capchar BS TAB LF CR ESC _ DEL DQ NL
if /i "%~1" == "BS" for /f %%a in ('"prompt $h & for %%b in (1) do rem"') do set "BS=%%a"
if /i "%~1" == "TAB" for /f "delims= " %%t in ('robocopy /l . . /njh /njs') do set "TAB=%%t"
if /i "%~1" == "LF" set LF=^
%=REQUIRED=%
%=REQUIRED=%
if /i "%~1" == "CR" for /f %%a in ('copy /z "%ComSpec%" nul') do set "CR=%%a"
if /i "%~1" == "ESC" for /f %%a in ('"prompt $E & for %%b in (1) do rem"') do set "ESC=%%a"
if /i "%~1" == "_" call :capchar "BS" & set "_=_!BS! !BS!"
if /i "%~1" == "DEL" call :capchar "BS" & set "DEL=!BS! !BS!"
if /i "%~1" == "DQ" call :capchar "BS" & set DQ="!BS! !BS!
if /i "%~1" == "NL" call :capchar "LF" & set "NL=^^!LF!!LF!^^"
shift /1
if not "%1" == "" goto capchar
exit /b 0
