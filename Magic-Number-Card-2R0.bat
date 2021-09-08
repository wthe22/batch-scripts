@echo off
title Magic Number Card 2.0
setlocal EnableDelayedExpansion

set "guessMaxNum=95"


rem Setup
if !guessMaxNum! GTR 3276 set "guessMaxNum=3276"
set /a maxNumbers=!guessMaxNum!/2

:instructions
cls
echo Think of a number from 1 to !guessMaxNum!
echo Let me guess your number...
echo=
pause

set "guessNumber=0"
set "guessCode="
set "cardNumber=1"
set "cardPower=1"

:nextCard
cls
title Magic Number Card 2.0 #!cardNumber!

set "cardDisplay="
for /l %%n in (0,1,!maxNumbers!) do (
    set /a nextNumber= %%n / !cardPower! * !cardPower! + !cardPower! + %%n
    if !nextNumber! GTR !guessMaxNum! goto displayCard
    set "nextNumber=     !nextNumber!"
    set "cardDisplay=!cardDisplay!!nextNumber:~-5,5!"
)

:displayCard
set "userInput=?"
cls
echo !cardDisplay!
echo=
echo Is there your number?
set /p "userInput=Y/N? "
if /i "!userInput!" == "Y" (
    set "guessCode=1!guessCode!"
) else if /i "!userInput!" == "N" (
    set "guessCode=0!guessCode!"
) else goto displayCard
set /a guessNumber+=!cardPower! * !guessCode:~0,1!
set /a cardNumber+=1
set /a cardPower*=2
if not !cardPower! GTR !guessMaxNum! goto nextCard

title Magic Number Card 2.0
for /l %%n in (0,1,11) do if "!guessCode:~0,1!" == "0" set "guessCode=!guessCode:~1!"
if not defined guessCode set "guessCode=0"

if "!guessNumber!" == "0" goto guessError
if !guessNumber! GTR !guessMaxNum! goto guessError

cls
echo Your number is:
echo !guessNumber!
echo=
echo Binary :
echo !guessCode!
echo=
pause
goto instructions

:guessError
cls
echo Your number is out of range or you entered something wrong
echo=
echo Make sure your number is from 1 to !guessMaxNum!
echo Or you should find the number more carefully next time
echo=
echo Probably your number is !guessNumber!
echo=
echo In binary : !guessCode!
echo=
pause
goto instructions
