@echo off
title Math Root Table
setlocal EnableDelayedExpansion

set "BS="
set safeecho=echo "!BS!

:main
set "rootMin=0"
set "rootMax=0"
set "rootPower=2"

cls
echo This script creates a table to guess the square root of a perfect square
echo This script can also generat table for cube root and others
echo=
set /p "rootPow=Input power of the root:"
echo=
set /p "rootMin=Input minimum number : "
set /p "rootMax=Input maximum number : "

cls
echo Creating the root table...

call :yroot !rootMin! !rootPow!
set /a "ansMin=!return! / 10 * 10"
call :yroot !rootMax! !rootPow!
set /a "ansMax=!return! / 10 * 10 + 10"

set /a "combiNum=!rootPower! %% 4"
if "!combiNum!" == "0" set "combiNum=4"
if "!rootPower!" == "0" set "combiNum=0"

cls
echo Root power     : !rootPow!
echo Combination    : #!combiNum!
echo=
echo Minimum number : !rootMin!
echo Maximum number : !rootMax!
echo=
%safeEcho%Ones       | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
%safeEcho%====================================================
set /p "=Last digit |" < nul
for /l %%n in (0,1,9) do (
    set "tempVar1=1"
    for /l %%p in (1,1,!rootPow!) do set /a "tempVar1*=%%n"
    set /p "=_!BS! !tempVar1:~-1,1! |" < nul
)
echo=
echo=
for /l %%n in (!ansMin!,5,!ansMax!) do (
    set "tempVar1=1"
    for /l %%p in (1,1,!rootPow!) do set /a "tempVar1*=%%n"
    echo %%n     !tempVar1!
)
echo=
pause
goto main

rem Functions

:pow [integer] [power]
set "return=1"
for /l %%p in (1,1,%2) do set /a return*=%1
goto :EOF

:yroot [integer] [power]
set "return=0"
for %%n in (32768 16384 8192 4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    set "tempVar1=1"
    for /l %%p in (1,1,%2) do set /a tempVar1*=!return! + %%n
    if not !tempVar1! LEQ 0 if !tempVar1! LEQ %1 set /a return+=%%n
)
goto :EOF
