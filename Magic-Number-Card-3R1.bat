:entry_point
@goto main


:changelog
::  v1.1 (2023-01-08)
::  - Fix program showing incorrect guess after the user choose to play again
::  - Reworked
::
::  v1.0 (2012-09-30)
::  - First release
exit /b 0


:metadata [return_prefix]
set "%~1name=mnc3.1"
set "%~1version=1.1"
set "%~1authors=wthe22"
set "%~1license=The MIT License"
set "%~1description=Magic Number Card 3R1"
set "%~1release_date=01/08/2021"   :: mm/dd/YYYY
set "%~1url=https://github.com/wthe22/batchlib"
set "%~1download_url=https://raw.githubusercontent.com/wthe22/batch-scripts/master/Magic-Number-Card-3R1.bat"
exit /b 0


:config
set "guess_max=95"
set "symbols= XY"
exit /b 0


:main
@setlocal EnableDelayedExpansion EnableExtensions
@echo off
call :metadata SOFTWARE.
call :config
call :play
exit /b 0


:play
set "guess_number=0"
set "card_number=1"
set "card_power=1"

cls
echo !SOFTWARE.description!
echo=
echo Think of a number from 1 to !guess_max!
echo Let me guess your number
pause

call :play.answer
for /f "tokens=* delims=0" %%a in ("!code!") do set "code=%%a"
set "error="
if !guess_number! LSS 1 set "error=true"
if !guess_number! GTR !guess_max! set "error=true"


cls
echo !SOFTWARE.description!
echo=
if defined error (
    echo There is something wrong with the guessing
    echo=
    echo Your number should be between 1 - !guess_max!
    echo Or you should find the number and answer more carefully next time
) else (
    echo Your number  : !guess_number!
    echo Guessing code: !code!
)
echo=
choice /c YN /m "Do you want to play again?"
set "choice=!errorlevel!"
if "!choice!" == "1" goto play
exit /b 0


:play.answer
if !card_power! GTR !guess_max! exit /b 0
cls
echo !SOFTWARE.description! #!card_number!
echo=
call :generate_mnc card !card_power! !guess_max!
call :format_size card 5
call :play.answer.show
set /a "card_power*=3"
goto play.answer


:play.answer.show
cls
echo !card!
echo=
choice /c:YN /m:"Is your number there?"
set "choice=!errorlevel!"
if "!choice!" == "2" (
    set "code=0!code!"
    exit /b 0
)
choice /c !symbols! /m "What symbol is it?"
set "choice=!errorlevel!"
set "code=!choice!!code!"
if "!choice!" == "1" set /a "guess_number+=!card_power!"
if "!choice!" == "2" set /a "guess_number-=!card_power!"
exit /b 0


:generate_mnc <return_var> <power> <max>
set "_return_var=%~1"
set "_power=%~2"
set "_max=%~3"
set "_result="
set /a "next_number=!_power!/2 + 1"
call :generate_mnc._loop
for /f "tokens=* delims=" %%r in ("!_result!") do (
    endlocal
    set "%_return_var%=%%r"
)
exit /b 0
:generate_mnc._loop
for /l %%s in (1,1,2) do (
    for /l %%j in (1,1,!_power!) do (
        if !next_number! GTR !_max! exit /b 0
        set "_result=!_result! !symbols:~%%s,1!!next_number!"
        set /a "next_number+=1"
    )
)
set /a "next_number+=!_power!"
goto generate_mnc._loop


:format_size <input_var> <size>
set "_input_var=%~1"
set "_size=%~2"
set "_spaces="
for /l %%n in (1,1,!_size!) do set "_spaces=!_spaces! "
set "_result="
for %%v in (!%_input_var%!) do (
    set "_value=!_spaces!%%v"
    set "_result=!_result!!_value:~-%_size%,%_size%!"
)
for /f "tokens=* delims=" %%r in ("!_result!") do (
    endlocal
    set "%_input_var%=%%r"
)
exit /b 0




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
