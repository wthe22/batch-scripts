@echo off
Title Flash Memory
setlocal EnableDelayedExpansion

set "maxQuestionNum=10000"

cls
echo This training will test your momentary vision memory
echo=
echo Setting up, please wait...

call :Speed_Test

set "charNum=0"
set "charList=."
set "userInput=."
set "questionNum=0"
set "questionsTotal=0"

set        "Numbers=0123456789"
set       "Alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set   "Alphanumeric=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "AlphanumericCS=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


:inType
cls
echo 1. Numbers
echo 2. Alphabet
echo 3. Alphanumeric
echo 4. Alphanumeric (Case-Sensitive)
echo=
echo 0. Exit
echo=
set /p "userInput=Input your difficulty type: "
if "%userInput%" == "0" exit
if "%userInput%" == "1" set "charList=Numbers"
if "%userInput%" == "2" set "charList=Alphabet"
if "%userInput%" == "3" set "charList=Alphanumeric"
if "%userInput%" == "4" set "charList=AlphanumericCS"
if not "%charList%" == "." goto inLevel
echo=
echo Invalid choice
pause
goto inType

:inLevel
cls
echo Difficulty type: !charList!
echo=
echo 0. Back
echo=
echo Input your difficulty level [1-75]: 
set /p "charNum="
if "!charNum!" == "0" goto inType
if !charNum! GEQ 1 if !charNum! LEQ 75 goto inQuestionNum
echo=
echo Invalid choice
pause
goto inLevel

:inQuestionNum
cls
echo Level: %charList%[%charNum%]
echo=
echo 0. Back
echo=
echo Max: %maxQuestionNum% Questions
echo Input the number of questions :
set /p "questionsTotal="
if "%questionsTotal%" == "0" goto inLevel
if %questionsTotal% LSS 256 goto gameSetup
if %questionsTotal% GTR %maxQuestionNum% goto inQuestionNum
echo=
echo Are you sure you want [%questionsTotal%] questions? 
echo Enter Y to continue...
set /p "userInput="
if "%userInput%" == "Y" goto gameSetup
if "%userInput%" == "y" goto gameSetup
goto inQuestionNum

:gameSetup
set /a sleepTime=%charNum%*10
set "correctAns=0"
set "questionNum=0"

set "textShow="
for /l %%n in (1,1,%charNum%) do set "textShow=!textShow!X"

cls
echo Memorize this:
echo=
echo %textShow%
echo=
echo You will see the characters you need to memorize in that position.
echo This is just an example.
echo=
echo Level      : %charList%[%charNum%]
echo Questions  : %questionsTotal%
echo=
echo Press any key to start your training
pause > nul

set "time1=%time%"

:genQuestion
set /a questionNum+=1
call :stringRandom %charList% %charNum%
set "textShow=%return%"

title Flash Memory - %charList%[%charNum%] [Q#%questionNum%/%questionsTotal%]
cls
echo Memorize this:
echo=
echo %textShow%

set "time2=%time%"
call :sleep %sleepTime%
call :Time_Subtract %time2% %time%

cls
echo Enter the characters you see for %return%0 ms :
echo=
set /p "userInput="
if not "%charList%" == "AlphanumericCS" call :String_UPPERCASE userInput
if "%userInput%" == "%textShow%" goto correctAns
echo=
echo Wrong answer.
echo=
echo Answer : %textShow%
echo=
pause
goto checkDone

:correctAns
set /a correctAns+=1
echo=
echo Correct answer.
echo=
pause
goto checkDone

:checkDone
if not %questionNum% GEQ %questionsTotal% goto genQuestion

call :Time_Subtract %time1% %time%
set /a avgTimeTaken=%return%/%questionsTotal%
call :Time_CS_Format %return%
set "timeTaken=%return%"
call :Time_CS_Format %avgTimeTaken%
set "avgTimeTaken=%return%"

set /a userScore= %correctAns% * 100 / %questionsTotal%

title Flash Memory
cls
echo Difficulty                 : %charList%[%charNum%]
echo Time taken                 : %timeTaken%
echo Average time per question  : %avgTimeTaken%
echo Total correct answers      : %correctAns%
echo Total questions            : %questionsTotal%
echo Score                      : %userScore%
echo=
pause
goto inType

rem Functions

:String_UPPERCASE
rem %1 is the string name
rem TempVar:
for %%a in (
    A B C D E F G
    H I J K L M N
    O P Q R S T U
    V W X Y Z
) do set "%1=!%1:%%a=%%a!"
goto :EOF

:StrLen [Variable Name]
if not defined %1 set "return=0" & goto :EOF
for /l %%n in (8192,-1,0) do if "!%1:~%%n,1!"=="" set "return=%%n"
goto :EOF

:stringRandom [Array Variable Name] [Length]
call :StrLen %1
set "tempVar1=%return%"
set "return="
for /l %%n in (1,1,%2) do (
    set /a tempVar1=!random! %% %tempVar1%
    for %%r in (!tempVar1!) do set "return=!return!!%1:~%%r,1!"
)
goto :EOF

:Time_Subtract [Start Time] [End Time]
rem Format  : HH:MM:SS.CS
rem TempVar: 1-2
for /f "tokens=1-4 delims=:." %%a in ("%2") do set /a  return=(24%%a %% 24)*360000+1%%b*6000+1%%c*100+1%%d-610100
for /f "tokens=1-4 delims=:." %%a in ("%1") do set /a return-=(24%%a %% 24)*360000+1%%b*6000+1%%c*100+1%%d-610100
if not "%3" == "0" if %return% LSS 0 set /a return+=8640000
goto :EOF

:Time_CS_Format [Time in CS]
rem TempVar: 1-2
set "return="
set /a tempVar1=%1 %% 8640000
for %%n in (360000 6000 100 1) do (
    set /a tempVar2=!tempVar1! / %%n
    set /a tempVar1=!tempVar1! %% %%n
    set "tempVar2=T0!tempVar2!"
    set "return=!return!!tempVar2:~-2,2!:"
)
set "return=%return:~0,-4%.%return:~-3,2%"
goto :EOF

:Speed_Test
set "systemLPS=1500"
:Speed_Test_FxL_Test
set "tempVar1=%time%"
call :Sleep 100
call :Time_Subtract %tempVar1% %time%
if "%return%" == "100" goto :EOF
set /a systemLPS=%systemLPS% * 100 / %return%
goto Speed_Test_FxL_Test

:Sleep [Time in ms]
set /a return=%systemLPS% * %1
for /l %%n in (0,1,%return%) do rem Test > nul
set "return=1"
goto :EOF
