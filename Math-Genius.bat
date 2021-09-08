@echo off
Title Math Genius

:reset
endlocal
setlocal EnableDelayedExpansion

set dataAddress=BatchScript_Data\MathGenius\Scores
if not exist "%dataAddress%" md "%dataAddress%"
set "logName=Scores_%username%.log"
set "logsAddress=%dataAddress%\%logName%"

set "questionType1=Add"
set "questionType2=Sub"
set "questionType3=Mul"
set "questionType4=Div"
set "questionType5=Xp2"
set "questionType6=Xp3"
set "questionType7=Rp2"
set "questionType8=Rp3"
set "questionType9=Rgq"

:inQuestionType
set "questionTypeNum=NA"
set "questionType=NA"
cls
echo Choose the type of math question you want to answer
echo 1. Addition
echo 2. Subtraction
echo 3. Multiplication
echo 4. Division
echo 5. Square
echo 6. Cube
echo 7. Square root
echo 8. Cube root
echo 9. Random challenges
echo=
echo 0. Exit
echo=
set /p "questionTypeNum=Type: "
if "%questionTypeNum%" == "0" exit
if %questionTypeNum% geq 1 if %questionTypeNum% leq 9 set "questionType=!questionType%questionTypeNum%!"
if "%questionTypeNum%" == "C" goto clearScore
if "%questionTypeNum%" == "c" goto clearScore
if not %questionType%==NA goto inLevel
echo=
echo Invalid choice
pause
goto inQuestionType

:inLevel
set "questionLevelName=NA"
set "questionLevelNum=NA"

set "questionLevelName1=Very Easy"
set "questionLevelName2=Easy"
set "questionLevelName3=Normal"
set "questionLevelName4=Medium"
set "questionLevelName5=Hard"
set "questionLevelName6=Expert"
set "questionLevelName7=Extreme"

cls
echo Choose the difficulty level
for /l %%n in (1,1,9) do if defined questionLevelName%%n echo %%n. !questionLevelName%%n!
echo 0. Back
echo=
set /p "questionLevelNum=Level: "
set "questionLevelName=!questionLevelName%questionLevelNum%!"
if %questionLevelNum%==0 goto inQuestionType
if not "%questionLevelName%"=="NA" goto inQuestionNum
echo=
echo Invalid Choice
pause 
goto inLevel

:inQuestionNum
set totalQnum=0
cls
set/p "totalQnum=Set the number of %questionLevelName% question = "
if %totalQnum% leq 0 goto ivQnum
if %totalQnum% geq 10000 goto ivQnum
if %totalQnum% geq 500 goto pQnum
goto start

:pQnum
echo=
choice /c YN /m "Are you sure you want %totalQnum% questions? "
if %errorlevel%==1 goto start
goto inQuestionNum

:ivQnum
cls
echo Invalid number
pause
goto inQuestionNum

:start
cls
set "timeStart=%time%"
set "correctAns=0"
set "wrongAns=0"
set "questionNum=0"
set "questionRandom=false"
set "mathOP=3.3"
if "%questionType%"=="Rgq" set "questionRandom=true"
:genQuestion
set /a questionNum=%questionNum%+1
set iAns=x
title Math Genius - [%questionType%:%questionLevelName%] [Q#%questionNum%/%totalQnum%]
set rnGen=0
set rnNum=2

if %questionRandom% == true set /a questionTypeNum=7 * %random% / 32767 + 1
if %questionRandom% == true if %questionLevelNum% leq 4 set /a questionTypeNum=3 * %random% / 32767 + 1

set "questionType=!questionType%questionTypeNum%!"

:rnGenType
set /a rnGen=%rnGen%+1

for %%n in (5 6 7 8) do if "%questionTypeNum%"=="%%n" set rnNum=1
set "rnMin=1" & set "rnMax=30"
set rn=%random%

rem Additions
if "%questionTypeNum%"=="1" (
    set "mathOP=1"
    if "%questionLevelNum%"=="1" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=15"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=15"
    )
    if "%questionLevelNum%"=="2" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=49"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=49"
    )
    if "%questionLevelNum%"=="3" (
        if "%rnGen%"=="1" set "rnMin=10" & set "rnMax=100"
        if "%rnGen%"=="2" set "rnMin=10" & set "rnMax=100"
    )
    if "%questionLevelNum%"=="4" (
        if "%rnGen%"=="1" set "rnMin=10" & set "rnMax=1000"
        if "%rnGen%"=="2" set "rnMin=10" & set "rnMax=1000"
    )
    if "%questionLevelNum%"=="5" (
        if "%rnGen%"=="1" set "rnMin=1000" & set "rnMax=10000"
        if "%rnGen%"=="2" set "rnMin=1000" & set "rnMax=10000"
    )
    if "%questionLevelNum%"=="6" (
        if "%rnGen%"=="1" set "rnMin=10000" & set "rnMax=1000000"
        if "%rnGen%"=="2" set "rnMin=10000" & set "rnMax=1000000"
    )
    if "%questionLevelNum%"=="7" (
        if "%rnGen%"=="1" set "rnMin=1000000" & set "rnMax=1000000000"
        if "%rnGen%"=="2" set "rnMin=1000000" & set "rnMax=1000000000"
    )
    goto rnCheckVarLimit
)

rem Subtractions
if "%questionTypeNum%"=="2" (
    set "mathOP=1"
    if "%questionLevelNum%"=="1" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=15"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=15"
    )
    if "%questionLevelNum%"=="2" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=49"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=49"
    )
    if "%questionLevelNum%"=="3" (
        if "%rnGen%"=="1" set "rnMin=10" & set "rnMax=100"
        if "%rnGen%"=="2" set "rnMin=10" & set "rnMax=100"
    )
    if "%questionLevelNum%"=="4" (
        if "%rnGen%"=="1" set "rnMin=10" & set "rnMax=1000"
        if "%rnGen%"=="2" set "rnMin=10" & set "rnMax=1000"
    )
    if "%questionLevelNum%"=="5" (
        if "%rnGen%"=="1" set "rnMin=1000" & set "rnMax=10000"
        if "%rnGen%"=="2" set "rnMin=1000" & set "rnMax=10000"
    )
    if "%questionLevelNum%"=="6" (
        if "%rnGen%"=="1" set "rnMin=10000" & set "rnMax=1000000"
        if "%rnGen%"=="2" set "rnMin=10000" & set "rnMax=1000000"
    )
    if "%questionLevelNum%"=="7" (
        if "%rnGen%"=="1" set "rnMin=1000000" & set "rnMax=1000000000"
        if "%rnGen%"=="2" set "rnMin=1000000" & set "rnMax=1000000000"
    )
    goto rnCheckVarLimit
)

rem Multiplications
if "%questionTypeNum%"=="3" (
    set "mathOP=2"
    if "%questionLevelNum%"=="1" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=10"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=10"
    )
    if "%questionLevelNum%"=="2" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=25"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=10"
    )
    if "%questionLevelNum%"=="3" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=100"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=50"
    )
    if "%questionLevelNum%"=="4" (
        if "%rnGen%"=="1" set "rnMin=10" & set "rnMax=100"
        if "%rnGen%"=="2" set "rnMin=10" & set "rnMax=100"
    )
    if "%questionLevelNum%"=="5" (
        if "%rnGen%"=="1" set "rnMin=100" & set "rnMax=1000"
        if "%rnGen%"=="2" set "rnMin=100" & set "rnMax=1000"
    )
    if "%questionLevelNum%"=="6" (
        if "%rnGen%"=="1" set "rnMin=1000" & set "rnMax=10000"
        if "%rnGen%"=="2" set "rnMin=1000" & set "rnMax=10000"
    )
    if "%questionLevelNum%"=="7" (
        if "%rnGen%"=="1" set "rnMin=1000" & set "rnMax=46340"
        if "%rnGen%"=="2" set "rnMin=1000" & set "rnMax=46340"
    )
    goto rnCheckVarLimit
)

rem Divisions
if "%questionTypeNum%"=="4" (
    set "mathOP=2"
    if "%questionLevelNum%"=="1" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=10"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=10"
    )
    if "%questionLevelNum%"=="2" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=25"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=25"
    )
    if "%questionLevelNum%"=="3" (
        if "%rnGen%"=="1" set "rnMin=1" & set "rnMax=50"
        if "%rnGen%"=="2" set "rnMin=1" & set "rnMax=50"
    )
    if "%questionLevelNum%"=="4" (
        if "%rnGen%"=="1" set "rnMin=10" & set "rnMax=100"
        if "%rnGen%"=="2" set "rnMin=10" & set "rnMax=100"
    )
    if "%questionLevelNum%"=="5" (
        if "%rnGen%"=="1" set "rnMin=100" & set "rnMax=1000"
        if "%rnGen%"=="2" set "rnMin=100" & set "rnMax=1000"
    )
    if "%questionLevelNum%"=="6" (
        if "%rnGen%"=="1" set "rnMin=1000" & set "rnMax=10000"
        if "%rnGen%"=="2" set "rnMin=100"  & set "rnMax=1000"
    )
    if "%questionLevelNum%"=="7" (
        if "%rnGen%"=="1" set "rnMin=1000" & set "rnMax=46340"
        if "%rnGen%"=="2" set "rnMin=1000" & set "rnMax=46340"
    )
    goto rnCheckVarLimit
)

rem Square
if "%questionTypeNum%"=="5" (
    set "mathOP=3.2"
    if "%questionLevelNum%"=="1" set "rnMin=1" & set "rnMax=10"
    if "%questionLevelNum%"=="2" set "rnMin=1" & set "rnMax=15"
    if "%questionLevelNum%"=="3" set "rnMin=1" & set "rnMax=20"
    if "%questionLevelNum%"=="4" set "rnMin=10" & set "rnMax=30"
    if "%questionLevelNum%"=="5" set "rnMin=10" & set "rnMax=50"
    if "%questionLevelNum%"=="6" set "rnMin=25" & set "rnMax=125"
    if "%questionLevelNum%"=="7" set "rnMin=100" & set "rnMax=625"
    goto rnCheckVarLimit
)

rem Cube
if "%questionTypeNum%"=="6" (
    set "mathOP=3.3"
    if "%questionLevelNum%"=="1" set "rnMin=1" & set "rnMax=10"
    if "%questionLevelNum%"=="2" set "rnMin=1" & set "rnMax=15"
    if "%questionLevelNum%"=="3" set "rnMin=5" & set "rnMax=20"
    if "%questionLevelNum%"=="4" set "rnMin=10" & set "rnMax=25"
    if "%questionLevelNum%"=="5" set "rnMin=15" & set "rnMax=40"
    if "%questionLevelNum%"=="6" set "rnMin=25" & set "rnMax=100"
    if "%questionLevelNum%"=="7" set "rnMin=75" & set "rnMax=500"
    goto rnCheckVarLimit
)

rem Square root
if "%questionTypeNum%"=="7" (
    set "mathOP=3.2"
    if "%questionLevelNum%"=="1" set "rnMin=1" & set "rnMax=10"
    if "%questionLevelNum%"=="2" set "rnMin=1" & set "rnMax=15"
    if "%questionLevelNum%"=="3" set "rnMin=1" & set "rnMax=20"
    if "%questionLevelNum%"=="4" set "rnMin=10" & set "rnMax=30"
    if "%questionLevelNum%"=="5" set "rnMin=10" & set "rnMax=50"
    if "%questionLevelNum%"=="6" set "rnMin=25" & set "rnMax=125"
    if "%questionLevelNum%"=="7" set "rnMin=100" & set "rnMax=625"
    goto rnCheckVarLimit
)

rem Cube root
if "%questionTypeNum%"=="8" (
    set "mathOP=3.3"
    if "%questionLevelNum%"=="1" set "rnMin=1" & set "rnMax=10"
    if "%questionLevelNum%"=="2" set "rnMin=1" & set "rnMax=15"
    if "%questionLevelNum%"=="3" set "rnMin=5" & set "rnMax=20"
    if "%questionLevelNum%"=="4" set "rnMin=10" & set "rnMax=25"
    if "%questionLevelNum%"=="5" set "rnMin=15" & set "rnMax=40"
    if "%questionLevelNum%"=="6" set "rnMin=25" & set "rnMax=100"
    if "%questionLevelNum%"=="7" set "rnMin=75" & set "rnMax=500"
    goto rnCheckVarLimit
)

:rnCheckVarLimit
set "varTest1=0"
if "%mathOP%"=="1"   set /a varTest1=%rnMax% * 2
if "%mathOP%"=="2"   set /a varTest1=%rnMax% * %rnMax%
if "%mathOP%"=="3.2" set /a varTest1=%rnMax% * %rnMax%
if "%mathOP%"=="3.3" set /a varTest1=%rnMax% * %rnMax% * %rnMax%

if %varTest1% geq 0 if %varTest1% leq 2147483647 goto randomizer

title Math Genius - [%questionType%:%questionLevelName%(X)] [Q#%questionNum%/%totalQnum%]

:randomizer
set /a rnRange=%rnMax%-%rnMin%+1
set /a rnRange2=%rnRange%/32767
set /a rnRange1=%rnRange% %% 32767 + 1
set /a rn=%random%*%rnRange2% + (%rnRange1%*%random%/32768) + %rnMin%

if "%rnGen%"=="1" set rn1=%rn%
if "%rnGen%"=="2" set rn2=%rn%
if not %rnGen%==%rnNum% goto rnGenType
goto question%questionType%

:questionAdd
set /a  ans=%rn1% + %rn2%

set/p "ians=%rn1% + %rn2% = "
goto ansCheck

:questionSub
set ans=%rn1%
set /a  rn1=%ans% + %rn2%

set/p "ians=%rn1% - %rn2% = "
goto ansCheck

:questionMul
set /a  ans=%rn1% * %rn2%

set/p "ians=%rn1% * %rn2% = "
goto ansCheck

:questionDiv
set /a  ans=%rn1%
set /a  rn1=%ans% * %rn2%

set/p "ians=%rn1% / %rn2% = "
goto ansCheck

:questionXp2
set /a  ans=%rn1% * %rn1%

set/p "ians=%rn1% ^ 2 = "
goto ansCheck

:questionXp3
if "%questionLevelNum%"=="4" if %random% leq 16383 set "rn1=-%rn1%"
if "%questionLevelNum%"=="5" if %random% leq 16383 set "rn1=-%rn1%"
set /a ans=%rn1%*%rn1%*%rn1%

set/p "ians=%rn1% ^ 3 = "
goto ansCheck

:questionRp2
set "ans=%rn1%"
set /a rn1=%rn1%*%rn1%

set/p "ians=%rn1% ^ (1/2) = "
goto ansCheck

:questionRp3
if "%questionLevelNum%"=="4" if %random% leq 16383 set "rn1=-%rn1%"
if "%questionLevelNum%"=="5" if %random% leq 16383 set "rn1=-%rn1%"
set ans=%rn1%
set /a rn1=%rn1%*%rn1%*%rn1%

set/p "ians=%rn1%^(1/3) = "
goto ansCheck

:ansCheck
if %ians% == #exit goto reset
if %ans% == %ians% goto ansCorrect
goto ansWrong

:ansCorrect
set/a correctAns=%correctAns%+1
echo Correct^^!
goto doneGenQuestion

:ansWrong
set/a wrongAns=%wrongAns%+1
echo Wrong^^!     Ans: %ans%
goto doneGenQuestion

:doneGenQuestion
echo=
if %questionNum% == %totalQnum% goto finish
goto genQuestion

:finish
set timeEnd=%time%

call :difftime timeDiff %timeStart% %timeEnd%
call :ftime timeDiff %timeDiff%

echo You have done all the questions
echo Press any key to see your score and statistics
pause > nul

if "%questionType%"=="add" set "questionTypeName=Addition"
if "%questionType%"=="sub" set "questionTypeName=Subtraction"
if "%questionType%"=="mul" set "questionTypeName=Multiplication"
if "%questionType%"=="div" set "questionTypeName=Division"
if "%questionType%"=="xp2" set "questionTypeName=Square"
if "%questionType%"=="xp3" set "questionTypeName=Cube"
if "%questionType%"=="rp2" set "questionTypeName=Square root"
if "%questionType%"=="rp3" set "questionTypeName=Cube root"
if "%questionRandom%"=="true"  set "questionTypeName=Random Question"

set /a score= %correctAns% * 100 / %totalQnum%

@echo User              : %username% >> %logsAddress%
@echo Date              : %date% >> %logsAddress%
@echo Questions type    : %questionTypeName% >> %logsAddress%
@echo Difficulty        : %questionLevelName% >> %logsAddress%
@echo Time taken        : %timeDiff% >> %logsAddress%
@echo Correct answers   : %correctAns% >> %logsAddress%
@echo Total questions   : %totalQnum% >> %logsAddress%
@echo Score             : %score% >> %logsAddress%
echo ======================================= >> %logsAddress%
@echo= >> %logsAddress%

title Math Genius
cls
echo =============== Results ===============
echo=
echo Questions type     : %questionTypeName%
echo Difficulty         : %questionLevelName%
echo Time taken         : %timeDiff%
echo Correct answers    : %correctAns%
echo Total questions    : %totalQnum%
echo Your score         : %score%
echo=
echo Saved to "%logsAddress%"
pause
goto pPlayAgain

:clearScore
echo=
choice /c YN /m "Are you sure you want to delete your scores?"
if %errorlevel% == 2 goto inQuestionType
del %logsAddress%
echo=
echo Your scores have been deleted.
pause
goto inQuestionType
:pPlayAgain
cls
title Math Genius
choice /c YN /m "Do you want to do another set of question? "
if %errorlevel%==1 goto reset
exit

rem Functions

:difftime   return_var  end_time  [start_time] [--no-fix]
set "%~1=0"
for %%t in (%~2:00:00:00:00 %~3:00:00:00:00) do for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
    set /a "%~1+=24%%a %% 24 *360000 +1%%b*6000 +1%%c*100 +1%%d -610100"
    set /a "%~1*=-1"
)
if /i not "%4" == "--no-fix" if "!%~1:~0,1!" == "-" set /a "%~1+=8640000"
exit /b 0


:ftime   return_var  centiseconds
set "%~1="
setlocal EnableDelayedExpansion
set "_result="
set /a "_remainder=(%~2) %% 8640000"
for %%s in (360000 6000 100 1) do (
    set /a "_digits=!_remainder! / %%s + 100"
    set /a "_remainder%%= %%s"
    set "_result=!_result!!_digits:~-2,2!:"
)
set "_result=!_result:~0,-4!.!_result:~-3,2!"
for /f "tokens=*" %%r in ("!_result!") do (
    endlocal
    set "%~1=%%r"
)
exit /b 0
