@echo off
title Mastermind
setlocal EnableDelayedExpansion


set "symbolList=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

:instructions
cls
echo Welcome to Mastermind
echo=
echo Try to guess the unknown symbols in the fewest attempts
echo=
echo Duplicates are allowed
echo=
echo Each answer comments indicates that one of the symbols you entered is:
echo X: Wrong letter
echo Y: Correct letter but wrong position
echo Z: Correct letter and position
echo=
pause


:lengthIn
set "codeLength=4"
cls
echo 0. Exit
echo=
echo Enter nothing to use the default, 4 symbols long
echo=
echo Input the code length :
set /p "codeLength="
if "%codeLength%" == "0" exit
if %codeLength% GEQ 3 if %codeLength% LEQ 15 goto symbolsReset
echo=
echo Invalid code length
echo Code length must be between 3 and 15
pause
goto lengthIn


:symbolsReset
set "symbolList=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :strlen letterMax symbolList
:symbolsNumIn
set /a letterNum=%codeLength%*5/3
set /a letterNum+=%letterNum% %% 2
if %letterNum% GTR %letterMax% set "letterNum=%letterMax%"
cls
echo Current symbol list:
echo=%symbolList%
echo=
echo 1. Customize
echo 0. Back
echo=
echo Enter nothing to use the default, %letterNum% symbols
echo=
echo Input the number of symbols in the code :
set /p "letterNum="
if "%letterNum%" == "0" goto lengthIn
if "%letterNum%" == "1" goto symbolsIn
if %letterNum% GEQ %codeLength% if %letterNum% LEQ %letterMax% goto letterDuplicatePrompt
echo=
echo Invalid code length
echo Code length must be between %codeLength% and %letterMax%
pause
goto symbolsNumIn


:symbolsIn
set "userInput=z"
cls
echo 1. Default
echo 0. Back
echo=
echo Input a minimum of 3 symbols
echo Input custom symbols:
echo=
set /p "userInput="
if "%userInput%" == "0" goto symbolsNumIn
if "%userInput%" == "1" goto symbolsReset
call :strlen return userInput
if %return% LSS 3 (
    echo=
    echo You entered too few symbols
    pause
    goto symbolsIn
)
set "symbolList=!userInput!"
call :strlen return symbolList
cls
echo !symbolList!
echo=
echo %return% Characters
echo=
echo Saved symbols list
pause
goto symbolsNumIn


:letterDuplicatePrompt
set "userInput=Y"
set "letterDuplicate="
cls
echo 0. Back
echo=
echo Enter nothing to use the default, allow duplicates
echo=
echo Allow duplicate symbols in the code?
set /p "userInput=Y/N? "
if "%userInput%" == "0" goto symbolsNumIn
if /i "%userInput%" == "Y" set "letterDuplicate=Y"
if /i "%userInput%" == "N" set "letterDuplicate=N"
if defined letterDuplicate goto attemptNumIn
echo=
echo Invalid choice
pause
goto letterDuplicatePrompt


:attemptNumIn
set /a attemptNum=2 * %codeLength%
set /a attemptNum+=%letterNum% * %codeLength% * 3 / 70
set /a attemptNum+=1
cls
echo 0. Back
echo=
echo Enter nothing to use the default, %attemptNum% Attempts
echo=
echo Input the number of attempts to break the code :
set /p "attemptNum="
set /a attemptNum+=0
if "%attemptNum%" == "0" goto letterDuplicatePrompt
if %attemptNum% GEQ 1 goto gameSetup
echo=
echo Invalid number of attempts
echo Code length must be between %letterNum% and %attemptNumMax%
pause
goto attemptNumIn

:gameSetup
set "attemptEmpty="
set "attemptValid="
set "attemptCorrect="
set "attemptResult="
set "gameStatus="
set "symbolListSpaced="
for /l %%n in (0,1,%letterNum%) do (
    set "symbolListSpaced=!symbolListSpaced! !symbolList:~%%n,1!"
)
for /l %%n in (1,1,%codeLength%) do (
    set "attemptEmpty=!attemptEmpty! "
    set "attemptValid=!attemptValid!."
    set "attemptCorrect=!attemptCorrect!Z"
    set "attemptResult=!attemptResult! "
    set "gameStatus=!gameStatus! "
)
for /l %%n in (1,1,%attemptNum%) do (
    set "userAttempt%%n=.%attemptEmpty%"
    set "attemptResult%%n=%attemptResult%"
)
set "userAttempt=1"
set "codePegs="
if "%letterDuplicate%" == "true" (
    for /l %%c in (1,1,%codeLength%) do (
        set /a tempVar1=!random! %% %letterNum%
        for %%n in (!tempVar1!) do (
            set "codePegs=!codePegs!!symbolList:~%%n,1!"
        )
    )
) else (
    set "tempVar2=!symbolList:~0,%letterNum%!"
    for /l %%c in (1,1,%codeLength%) do (
        call :strlen return tempVar2
        set /a tempVar1=!random! %% !return!
        for %%n in (!tempVar1!) do (
            set "codePegs=!codePegs!!tempVar2:~%%n,1!"
            set "tempVar1=!tempVar2:~0,%%n!"
            set "tempVar2=!tempVar2:~%%n!"
            set "tempVar2=!tempVar1!!tempVar2:~1!"
        )
    )
)
set "codePegs=.%codePegs%"

:gamePlay
set "userInput=."
cls
call :displayBoard
echo=
set /p "userInput=Enter your guess :   "
call :to_upper userInput

if "%userInput%" == "0" goto gameQuitPrompt
set /a tempVar1=%letterNum% * 2
set "tempVar1=!symbolListSpaced:~0,%tempVar1%!"
set "tempVar2=%userInput%"

for %%a in (%tempVar1%) do set "tempVar2=!tempVar2:%%a=.!"
if "%tempVar2%" == "%attemptValid%" goto attemptCheck
echo=
echo Invalid guess
echo=
echo Your guess symbols must be in this array[%letterNum%] :
echo=
echo !symbolList:~0,%letterNum%!
echo=
pause
goto gamePlay

:gameQuitPrompt
set "userInput=."
cls
call :displayBoard
echo=
echo Are you sure you want to quit? Enter Y to quit
set /p "userInput="
call :to_upper userInput
if "%userInput%" == "Y" goto instructions
goto gamePlay

:attemptCheck
set "userAttempt%userAttempt%=.%userInput%"
set "attemptResult="
set "tempVar1=.%userInput%"
set "tempVar2=%codePegs%"
for /l %%n in (%codeLength%,-1,1) do (
    if not "!tempVar1:~%%n,1!!tempVar2:~%%n,1!" == "" (
        if "!tempVar1:~%%n,1!" == "!tempVar2:~%%n,1!" (
            set "tempVar3=!tempVar1:~0,%%n!"
            set "tempVar1=!tempVar1:~%%n!"
            set "tempVar1=!tempVar3!!tempVar1:~1!"
            set "tempVar3=!tempVar2:~0,%%n!"
            set "tempVar2=!tempVar2:~%%n!"
            set "tempVar2=!tempVar3!!tempVar2:~1!"
            set "attemptResult=Z!attemptResult!"
        )
    )
)
call :strlen return tempVar1
set /a return-=1
for /l %%a in (%return%,-1,1) do (
    for /l %%b in (%return%,-1,1) do (
        if not "!tempVar1:~%%a,1!!tempVar2:~%%b,1!" == "" (
            if "!tempVar1:~%%a,1!" == "!tempVar2:~%%b,1!" (
                set "tempVar3=!tempVar1:~0,%%a!"
                set "tempVar1=!tempVar1:~%%a!"
                set "tempVar1=!tempVar3!!tempVar1:~1!"
                set "tempVar3=!tempVar2:~0,%%b!"
                set "tempVar2=!tempVar2:~%%b!"
                set "tempVar2=!tempVar3!!tempVar2:~1!"
                set "attemptResult=Y!attemptResult!"
            )
        )
    )
)
call :strlen return tempVar1
set /a return-=1
for /l %%n in (1,1,%return%) do (
    set "attemptResult=X!attemptResult!"
)
set "attemptResult%userAttempt%=%attemptResult%"

if "!attemptResult%userAttempt%!" == "%attemptCorrect%" goto gameWin
if "%userAttempt%" == "%attemptNum%" goto gameLose
set /a userAttempt+=1
goto gamePlay

:gameWin
set "gameStatus="
for /l %%n in (1,1,%codeLength%) do (
    set "gameStatus=-!gameStatus!"
)

cls
call :displayBoard
echo=
echo You win^^!
pause
goto instructions

:gameLose
set "gameStatus="
for /l %%n in (1,1,%codeLength%) do (
    set "gameStatus=-!gameStatus!"
)

cls
call :displayBoard
echo=
echo You lose^^!
pause
goto instructions

rem Functions

:displayBoard
rem %1 is the board size
set "displayDataA=ÉÍÍÍ"
set "displayDataB=ºÄÄÄ"
set "displayDataC=ÈÍÍÍ"
set "displayDataD=º ? "
set "displayDataE=º %codePegs:~1,1% "
set "displayDataF=Ä"

for /l %%n in (1,1,%attemptNum%) do (
    set "displayData%%n=º !userAttempt%%n:~1,1! "
)
for /l %%n in (2,1,%codeLength%) do (
    set "displayDataA=!displayDataA!ÍÍÍÍ"
    set "displayDataB=!displayDataB!ÅÄÄÄ"
    set "displayDataC=!displayDataC!ÍÍÍÍ"
    set "displayDataD=!displayDataD!³ ? "
    set "displayDataE=!displayDataE!³ !codePegs:~%%n,1! "
    set "displayDataF=!displayDataF!Ä"
)
for /l %%n in (1,1,%attemptNum%) do (
    for /l %%l in (2,1,%codeLength%) do (
        set "displayData%%n=!displayData%%n!³ !userAttempt%%n:~%%l,1! "
    )
)
for /l %%n in (1,1,%attemptNum%) do set "displayData%%n=!displayData%%n!º"

set "displayDataA=%displayDataA%»"
set "displayDataB=%displayDataB%º"
set "displayDataC=%displayDataC%¼"
set "displayDataD=%displayDataD%º"
set "displayDataE=%displayDataE%º"

echo      %displayDataA%     oÄ%displayDataF%Äo
if "%gameStatus:~0,1%" == " " (
    echo  ANS %displayDataD%     ³ %gameStatus% ³
) else echo  ANS %displayDataE%     ³ %gameStatus% ³
for /l %%n in (%attemptNum%,-1,1) do (
    set "tempVar1=   %%n"
    echo      %displayDataB%     ³Ä%displayDataF%Ä³
    echo  !tempVar1:~-3,3! !displayData%%n!     ³ !attemptResult%%n! ³
)
echo      %displayDataC%     oÄ%displayDataF%Äo
goto :EOF


:to_upper   input_var
set "%1= !%1!"
for %%a in (
    A B C D E F G H I J K L M
    N O P Q R S T U V W X Y Z
) do set "%1=!%1:%%a=%%a!"
set "%1=!%1:~1!"
exit /b 0


:strlen   return_var  input_var
set "%~1=0"
if defined %~2 (
    for /l %%b in (12,-1,0) do (
        set /a "%~1+=(1<<%%b)"
        for %%i in (!%~1!) do if "!%~2:~%%i,1!" == "" set /a "%~1-=(1<<%%b)"
    )
    set /a "%~1+=1"
)
exit /b 0
