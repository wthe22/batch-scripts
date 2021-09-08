@echo off
setlocal EnableDelayedExpansion


rem Settings
set "guessMaxNum=95"
set "sym1=X"
set "sym2=Y"
rem ====================

set "guessNumber=0"
set "cardNumber=1"
set "cardPower=1"

:setup
cls
title Magic Number Card 3.1
echo Think of a number from 1 to %guessMaxNum%
echo Let me guess your number
pause

:genMNC
cls
title Magic Number Card 3.1 #%cardNumber%
echo Generating the card...

set "card="
set "symNum=1"
set /a nextNumber=%cardPower%/2 + %cardPower% %% 2
set "loop1=1"
:genCard
set "display=    !sym%symNum%!%nextNumber%"
set "card=%card%%display:~-5,5%"
:genNum
if %loop1% == %cardPower% goto loop1Reset
set /a loop1+=1
goto genNumDone
:loop1Reset
set "loop1=1"
set /a symNum+=1
if %symNum% == 3 goto loop2Reset
goto genNumDone
:loop2Reset
set "symNum=1"
set /a nextNumber+=%cardPower%
goto genNumDone
:genNumDone
set /a nextNumber+=1
if %nextNumber% GTR %guessMaxNum% goto displayMNC
goto genCard

:displayMNC
cls
echo %card%
echo=
choice /c:YN /m:"Is your number there?"
set "choice=%errorlevel%"
if %choice%==2 set "guessNumber_Code=0%guessNumber_Code%" & goto nextMNC
choice /c:%sym1%%sym2% /m:"What symbol is it?"
set "choice=%errorlevel%"
if %choice%==1 set "guessNumber_Code=1%guessNumber_Code%" & set /a guessNumber+=%cardPower%
if %choice%==2 set "guessNumber_Code=2%guessNumber_Code%" & set /a guessNumber-=%cardPower%
:nextMNC
set /a cardNumber+=1
set /a cardPower*=3
if %cardPower% gtr %guessMaxNum% goto setupResult
goto genMNC

:setupResult
title Magic Number Card 3R.X
if %guessNumber% lss 1 goto resultError
if %guessNumber% gtr %guessMaxNum% goto resultError

:codeKill0
if %guessNumber_Code:~0,1%==0 set "guessNumber_Code=%guessNumber_Code:~1%" & goto codeKill0

cls
echo Your number  : %guessNumber%
echo Guessing code: %guessNumber_Code%
echo=
pause
goto pPlayAgain

:resultError
cls
echo Your number  : %guessNumber%
echo There is something wrong with the guessing
echo Your answers show that your number is not in any cards
echo Your number is also not between 1 - %guessMaxNum%
echo=
echo Your number should be between 1 - %guessMaxNum%
echo Or you should find the number more carefully next time
echo=
pause
goto pPlayAgain

:pPlayAgain
cls
choice /c:YN /m:"Do you want to play again?"
if %errorlevel%==1 goto setup
exit

   X1   Y2   X4   Y5   X7   Y8  X10  Y11  X13  Y14  X16  Y17  X19  Y20  X22  Y23
  X25  Y26  X28  Y29  X31  Y32  X34  Y35  X37  Y38  X40  Y41  X43  Y44  X46  Y47
  X49  Y50  X52  Y53  X55  Y56  X58  Y59  X61  Y62  X64  Y65  X67  Y68  X70  Y71
  X73  Y74  X76  Y77  X79  Y80  X82  Y83  X85  Y86  X88  Y89  X91  Y92  X94  Y95

   X2   X3   X4   Y5   Y6   Y7  X11  X12  X13  Y14  Y15  Y16  X20  X21  X22  Y23
  Y24  Y25  X29  X30  X31  Y32  Y33  Y34  X38  X39  X40  Y41  Y42  Y43  X47  X48
  X49  Y50  Y51  Y52  X56  X57  X58  Y59  Y60  Y61  X65  X66  X67  Y68  Y69  Y70
  X74  X75  X76  Y77  Y78  Y79  X83  X84  X85  Y86  Y87  Y88  X92  X93  X94  Y95

   X5   X6   X7   X8   X9  X10  X11  X12  X13  Y14  Y15  Y16  Y17  Y18  Y19  Y20
  Y21  Y22  X32  X33  X34  X35  X36  X37  X38  X39  X40  Y41  Y42  Y43  Y44  Y45
  Y46  Y47  Y48  Y49  X59  X60  X61  X62  X63  X64  X65  X66  X67  Y68  Y69  Y70
  Y71  Y72  Y73  Y74  Y75  Y76  X86  X87  X88  X89  X90  X91  X92  X93  X94  Y95
