@goto main

rem Guessing using Binary Search
rem Made by wthe22
rem Published on 2013-05-25
rem Blog    : http://winscr.blogspot.com/
rem Github  : https://github.com/wthe22/batch-scripts


:main
@echo off
title Guessing using Binary Search
setlocal EnableDelayedExpansion

set "guessMin=1"
set "guessMax=1000"

:minMaxIn
cls
echo Input nothing to use default
echo=
set /p "guessMin=Input minimum number   : "
if !guessMin! LSS 0 goto minMaxIn
set /p "guessMax=Input maximum number   : "
if !guessMin! LSS !guessMax! goto guessSetup
echo=
echo Invalid minimum / maximum number
echo Minimum number must be smaller than the maximum number
echo=
pause
goto minMaxIn

:guessSetup
set /a "guessRange=!guessMax! - !guessMin! + 1"

set "numPow=1"
set "guessAttemptMax=2"
for /l %%n in (0,1,31) do (
    if !guessRange! GEQ !numPow! set "guessAttemptMax=%%n"
    set /a numPow*=2
)
set /a "guessAttemptMax+=1"

cls
echo Choose a number from !guessMin! - !guessMax!
echo=
echo I wil guess your number in !guessAttemptMax! attempts or less ^^!
echo=
pause

set "guessNowMin=!guessMin!"
set "guessNowMax=!guessMax!"
set "guessAttempts=0"
set "guessLog=Start"
set "guessCode="

:guessGen
set /a "guessAttempts+=1"
set /a "guessTry=(!guessNowMin!+!guessNowMax!) / 2"
set "guessLog=!guessLog! !guessTry!,"

if "!guessNowMin!" == "!guessNowMax!" goto guessCorrect
if !guessNowMin! GTR !guessNowMax! goto guessError

:guessAsk
cls
echo Attempt #!guessAttempts!
echo Your number possibility is between !guessNowMin! - !guessNowMax!
echo=
choice /c YN /m "Is your number !guessTry!?"
if "!errorlevel!" == "1" goto guessCorrect

if "!guessTry!" == "!guessNowMin!" goto guessTooLow
if "!guessTry!" == "!guessNowMax!" goto guessTooHigh

if !guessAttempts! GEQ !guessAttemptMax! goto guessError

cls
echo Attempt #!guessAttempts!
echo Your number possibility is between !guessNowMin! - !guessNowMax!
echo=
choice /c YN /m "Is !guessTry! too high?"
if "!errorlevel!" == "1" goto guessTooHigh
goto guessTooLow

:guessTooLow
set /a "guessNowMin=!guessTry!+1"
set "guessCode=!guessCode!1"
goto guessGen

:guessTooHigh
set /a "guessNowMax=!guessTry!-1"
set "guessCode=!guessCode!0"
goto guessGen

:guessCorrect
set "guessLog=!guessLog:~0,-1!"

cls
echo Found your number  : !guessTry!
echo Number of guess    : !guessAttempts!
echo Guessing code      : !guessCode!
echo=
echo Guesses:
echo !guessLog!
echo=
pause
exit

:guessError
set "guessLog=!guessLog:~0,-1!"

cls
echo Something is wrong!
echo That is the !guessAttemptMax!th attempt and we still can't find your number
echo Maybe you entered something wrong OR 
echo your number is out of the range (!guessMin! - !guessMax!)
echo=
echo The last attempt     : !guessTry!
echo Number guessing code : !guessCode!
echo=
echo Guesses:
echo !guessLog!
echo=
pause
exit

