@prompt $s
@echo off
title Screen Saver
setlocal EnableDelayedExpansion

set  "maxWidth=190"
set "maxHeight=65"

:setup
cls
echo                                       TIPS
echo=
echo                       The screen saver can still continue
echo                          even if you delete the script
echo=
echo                         ===============================
echo                         ^|        Made by wthe22       ^|
echo                         ^| http://winscr.blogspot.com/ ^|
echo                         ===============================
echo=
echo                                Calibrating speed
echo                                 Please wait...

call :Speed_Test

set "screenWidth=25"

for /f "tokens=* usebackq" %%o in (`mode con`) do (
    for /f %%t in ('echo %%o ^| find "Lines"') do (
        for /f "tokens=2 delims=:" %%a in ("%%o") do (
            set "screenHeight=%%a"
        )
    )
    for /f %%t in ('echo %%o ^| find "Columns"') do (
        for /f "tokens=2 delims=:" %%a in ("%%o") do (
            set "screenWidth=%%a"
        )
    )
    for /f %%t in ('echo %%o ^| find "Code page"') do (
        for /f "tokens=2 delims=:" %%a in ("%%o") do (
            set "screenCP=%%a"
        )
    )
)

set  "screenWidth=%screenWidth: =%"
set "screenHeight=%screenHeight: =%"
set "screenCP=%screenCP: =%"

if %screenWidth% GTR %maxWidth% set "screenWidth=%maxWidth%"

set "screenHeight=25"

mode %screenWidth%,%screenHeight%

:menu
cls
title Screen Saver
set "ssMenuNum=0"
for %%s in (
    The.Matrix.a_matrix1a_0.5.2
    The.Matrix.CH_matrix1CH_0.5.2
) do rem These are unused screen savers
for %%s in (
    Spaces_spaces1_5.5
    Spaces.Inverse_spaces2_5.5
    The.Matrix.1S_matrix1_0.5.2
    The.Matrix.2S_matrix1a_0.5.2
    The.Matrix.1F_matrix1b_0.5.2
    The.Matrix.Computer_matrix2_0.5.2
) do (
    for /f "tokens=1-3 delims=_" %%a in ("%%s") do (
        set /a ssMenuNum+=1
        set "tempVar1=%%a"
        set "ssName=!tempVar1:.= !"
        set "ss!ssMenuNum!Label=%%b"
        set "tempVar1=%%c"
        set "ss!ssMenuNum!Param=!tempVar1:.= !"
        echo !ssMenuNum!. !ssName!
    )
)
echo=
echo S. Input screen size
echo 0. Exit
echo=
echo Screen size    %screenWidth%x%screenHeight%               ^| Speed : %systemLPS%
echo=
echo Which type of screen saver do you want?
set /p "userInput="
call :String_UPPERCASE userInput
if "%userInput%" == "0" exit
if "%userInput%" == "S" goto screenSizeIn

if defined ss%userInput%Label goto setup
echo=
echo Screen saver not found
pause
goto menu

:screenSizeIn
:screenWidthIn
cls
echo Set your screen size according
echo  to your screen resolution
echo=
echo Don't force your screen size to extreme
echo  or this script could slow down your computer
echo=
echo Current screen width   : %screenWidth%
echo Current screen height  : %screenHeight%
echo=
echo Input new screen width :
set /p "screenWidth="
set /a screenWidth+=0
if %screenWidth% GTR %maxWidth% goto screenWidthIn
if %screenWidth% LSS 14 goto screenWidthIn
:screenHeigthIn
cls
echo Set your screen size according
echo  to your screen resolution
echo=
echo Don't force your screen size to extreme
echo  or this script could slow down your computer
echo=
echo New screen width       : %screenWidth%
echo Current screen height  : %screenHeight%
echo=
echo Input new screen height :
set /p "screenHeight="
set /a screenHeight+=0
if %screenHeight% GTR %maxHeight% goto screenHeightIn
if %screenHeight% LSS 2 goto screenHeightIn

mode %screenWidth%,%screenHeight%
goto menu

:setup
set "parameter=!ss%userInput%Param!"
cls
title !ss%userInput%Label!
echo Animation Parameter    :
echo=
echo [Delay] [Intensity] [Additional]
echo=
echo Default Parameter      :
echo=
echo %parameter%
echo=
echo 0. Back
echo=
echo Input parameter  :
set /p "parameter="
if "%parameter%" == "0" goto menu
set /a screenHeight-=1
set /a screenWidth-=1
call :!ss%userInput%Label! %parameter%
goto menu

:spaces1
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

rem 4 - Refresh title counter
rem 5 - Reset title counter

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :StrLen strList
set "tempVar2=%return%"
set "tempVar4=1"
set "tempVar5=50"
set /a tempVar1=%systemLPS% * %1
cls
color 02

for /l %%z in (0,0,1) do (
    if "!tempVar4!" == "15" (
        set "titleDisplay=!titleDisplay!."
        set "tempVar4=1"
        set /a tempVar5+=1
    )
    if "!tempVar5!" == "50" (
        set "titleDisplay=Hacking..."
        set "tempVar5=1"
    )
    title !titleDisplay!
    set /a tempVar4+=1
    set "display="
    for /l %%n in (1,1,%screenWidth%) do (
        set /a tempVar3=!random! %% %2
        if not "!tempVar3!" == "0" (
            set /a tempVar3=!random! %% %tempVar2%
            for %%s in (!tempVar3!) do (
                set "display=!display!!strList:~%%s,1!"
            )
        ) else set "display=!display! "
    )
    
    for /l %%n in (0,1,%tempVar1%) do rem Test > nul
    
    set "display=!display:~0,%screenWidth%!"
    echo=!display!
)
goto :EOF

:spaces2
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :StrLen strList
set /a tempVar2=%return%-1
set /a tempVar1=%systemLPS% * %1
cls
title Spaces
color 02
for /l %%z in (0,0,1) do (
    set "display="
    for /l %%n in (1,1,%screenWidth%) do (
        set /a tempVar3=!random! %% %2
        if "!tempVar3!" == "0" (
            set /a tempVar3=!random! %% %tempVar2%
            for %%s in (!tempVar3!) do (
                set "display=!display!!strList:~%%s,1!"
            )
        ) else set "display=!display! "
    )
    
    for /l %%n in (0,1,%tempVar1%) do rem Test > nul
    
    set "display=!display:~0,%screenWidth%!"
    echo=!display!
)
goto :EOF

:matrix1
rem The Matrix with 1 spaces
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :StrLen strList
set "tempVar2=%return%"
set /a tempVar1=%systemLPS% * %1

set "tempVar4="
for /l %%n in (1,1,%screenWidth%) do set "tempVar4=!tempVar4! "
set "display0=%tempVar4: =.%"
for /l %%n in (1,1,%screenHeight%) do set "display%%n=%tempVar4%"
set /a tempVar3=%screenHeight%+1
set "display%tempVar3%=%tempVar4%"
cls
title The Matrix
color 02
for /l %%z in (0,0,1) do (
    for /l %%h in (%screenHeight%,-1,1) do (
        for /l %%w in (0,%3,%screenWidth%) do (
            if "!display%%h:~%%w,1!" == " " (
                set /a tempVar4=%%h-1
                for %%n in (!tempVar4!) do (
                    if not "!display%%n:~%%w,1!" == " " (
                        set /a tempVar3=!random! %% %2
                        if not "!tempVar3!" == "0" (
                            set /a tempVar3=!random! %% %tempVar2%
                            for %%r in (!tempVar3!) do (
                                set "tempVar4=!display%%h:~%%w!"
                                set "display%%h=!display%%h:~0,%%w!!strList:~%%r,1!!tempVar4:~1!"
                            )
                        )
                    )
                )
            )
        )
    )
    for /l %%w in (0,%3,%screenWidth%) do (
        if not "!display%screenHeight%:~%%w,1!" == " " (
            set /a tempVar3=!random! %% %2
            if "!tempVar3!" == "0" (
                set /a tempVar3=!random! %% %2
                if "!tempVar3!" == "0" (
                    for /l %%h in (1,1,%screenHeight%) do (
                        set "tempVar4=.!display%%h:~%%w!"
                        set "display%%h=!display%%h:~0,%%w! !tempVar4:~2!"
                    )
                ) else (
                    set /a tempVar4=%screenHeight% + 1
                    for %%r in (!tempVar4!) do set "tempVar4=!display%%h:~%%w!"
                    for /l %%h in (1,1,%screenHeight%) do (
                        set /a tempVar4=%%h+1
                        for %%r in (!tempVar4!) do (
                            set "tempVar4=!display%%h:~%%w!"
                            set "display%%h=!display%%h:~0,%%w!!display%%r:~%%w,1!!tempVar4:~1!"
                        )
                    )
                    set /a tempVar3=!random! %% %tempVar2%
                    for %%r in (!tempVar3!) do (
                        set "tempVar4=!display%screenHeight%:~%%w!"
                        set "display%screenHeight%=!display%screenHeight%:~0,%%w!!strList:~%%r,1!!tempVar4:~1!"
                    )
                )
            )
        )
    )
    if "0" == "0" (
        for /l %%n in (0,1,%tempVar1%) do rem Test
    ) > nul
    cls
    for /l %%h in (1,1,%screenHeight%) do (
        set "display=!display%%h:~0,%screenWidth%!"
        echo=!display!
    )
)
goto :EOF

:matrix1a
rem The Matrix with 2 spaces
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :StrLen strList
set "tempVar2=%return%"
set /a tempVar1=%systemLPS% * %1
set "tempVar4="
set "tempVar5="
for /l %%n in (1,1,%3) do set "tempVar5=!tempVar5! "
for /l %%n in (1,1,%screenHeight%) do set "tempVar4=!tempVar4! "
for /l %%n in (1,1,%screenWidth%) do set "column%%n=. %tempVar4% "
cls
title The Matrix
color 02
for /l %%z in (0,0,1) do (
    for /l %%h in (1,1,%screenHeight%) do set "display%%h="
    for /l %%n in (1,%3,%screenWidth%) do (
        set /a tempVar3=!random! %% %2
        set "column%%n=!column%%n: =!"
        if not "!tempVar3!" == "0" (
            if "!column%%n:~%screenHeight%,1!" == "" (
                set /a tempVar3=!random! %% %tempVar2%
                for %%r in (!tempVar3!) do set "column%%n=!column%%n!!strList:~%%r,1!"
            ) else (
                set /a tempVar3=!random! %% %2
                if "!tempVar3!" == "0" (
                    set "column%%n=."
                ) else (
                    set /a tempVar3=!random! %% %tempVar2%
                    for %%r in (!tempVar3!) do set "column%%n=!column%%n:~1!!strList:~%%r,1!"
                )
            )
        )
        set "column%%n=!column%%n! %tempVar4%"
        for /l %%h in (1,1,%screenHeight%) do set "display%%h=!display%%h!!column%%n:~%%h,1!%tempVar5%"
    )
    for /l %%n in (0,1,%tempVar1%) do rem Test > nul
    cls
    for /l %%h in (1,1,%screenHeight%) do (
        set "display=!display%%h:~0,%screenWidth%!"
        echo=!display!
    )
)
goto :EOF

:matrix1b
rem The Matrix with 1 spaces and faster speed
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number
rem 4 - Loop Number

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
set /a tempVar1=%systemLPS% * %1
call :StrLen strList
set "tempVar2=%return%"

set "tempVar4= "
for /l %%n in (1,1,%screenWidth%) do set "tempVar4=!tempVar4! " > nul
for /l %%n in (1,1,%screenHeight%) do set "display%%n=%tempVar4%" > nul
for /l %%w in (0,%3,%screenWidth%) do set "frontList=!frontList!   1" > nul
set /a tempVar3=%screenHeight%+1
set "display%tempVar3%=%tempVar4%"
cls
title The Matrix
color 02
for /l %%z in (0,0,1) do (
    set "tempVar4=0"
    for /l %%w in (1,%3,%screenWidth%) do (
        set /a tempVar3=!random! %% %2
        if not "!tempVar3!" == "0" (
            if "!display%screenHeight%:~%%w,1!" == " " (
                set /a tempVar3=!random! %% %tempVar2%
                for %%n in (!tempVar4!) do set "tempVar5=!frontList:~%%n,4!"
                set "tempVar5=!tempVar5: =!"
                set /a tempVar6=%%w+1
                for /f "tokens=1-4 delims=_" %%a in ("!tempVar3!_!tempVar4!_!tempVar5!_!tempVar6!") do (
                    set "display%%c=!display%%c:~0,%%w!!strList:~%%a,1!!display%%c:~%%d!"
                    set /a tempVar3=%%c + 1
                    set "tempVar3=    !tempVar3!"
                    set "tempVar5=!frontList:~%%b!"
                    set "frontList=!frontList:~0,%%b!!tempVar3:~-4,4!!tempVar5:~4!"
                )
            ) else (
                set /a tempVar3=!random! %% %2
                if "!tempVar3!" == "0" (
                    for /l %%h in (1,1,%screenHeight%) do (
                        set "tempVar3=.!display%%h:~%%w!"
                        set "display%%h=!display%%h:~0,%%w! !tempVar3:~2!"
                        for %%n in (!tempVar4!) do (
                            set "tempVar5=!frontList:~%%n!"
                            set "frontList=!frontList:~0,%%n!   1!tempVar5:~4!"
                        )
                    )
                ) else (
                    for /l %%h in (1,1,%screenHeight%) do (
                        set /a tempVar3=%%h+1
                        for %%r in (!tempVar3!) do (
                            set "tempVar3=!display%%h:~%%w!"
                            set "display%%h=!display%%h:~0,%%w!!display%%r:~%%w,1!!tempVar3:~1!"
                        )
                    )
                    set /a tempVar3=!random! %% %tempVar2%
                    for %%r in (!tempVar3!) do (
                        set "tempVar3=!display%screenHeight%:~%%w!"
                        set "display%screenHeight%=!display%screenHeight%:~0,%%w!!strList:~%%r,1!!tempVar3:~1!"
                    )
                )
            )
        )
        set /a tempVar4+=4
    )
    if "0" == "0" (
        for /l %%n in (0,1,%tempVar1%) do rem Test
    ) > nul
    cls
    for /l %%h in (1,1,%screenHeight%) do (
        set "display=!display%%h:~1,%screenWidth%!"
        echo=!display!
    )
)
goto :EOF

:matrix1CH
rem Please use Chinese PRC system locale for this screensaver
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

set "strList="
set "strList=!strList!把吧别八白百不打第动儿发分父机今科海难你女哦人日十娃我"
set "strList=!strList!踏实排鄂博渤瞥闻技拜佛拔丝噢计划拔丝殴握度秒且并亲"

echo %strList%
pause

call :StrLen strList
set "tempVar2=%return%"
set /a tempVar1=%systemLPS% * %1
set /a screenWidth=%screenWidth% / 2 - 1

set "tempVar4="
for /l %%n in (1,1,%screenWidth%) do set "tempVar4=!tempVar4! "
set "display0=%tempVar4: =.%"
for /l %%n in (1,1,%screenHeight%) do set "display%%n=%tempVar4%"
set /a tempVar3=%screenHeight%+1
set "display%tempVar3%=%tempVar4%"
cls
title The Matrix
color 02
for /l %%z in (0,0,1) do (
    for /l %%h in (%screenHeight%,-1,1) do (
        for /l %%w in (0,%3,%screenWidth%) do (
            if "!display%%h:~%%w,1!" == " " (
                set /a tempVar4=%%h-1
                for %%n in (!tempVar4!) do (
                    if not "!display%%n:~%%w,1!" == " " (
                        set /a tempVar3=!random! %% %2
                        if not "!tempVar3!" == "0" (
                            set /a tempVar3=!random! %% %tempVar2%
                            for %%r in (!tempVar3!) do (
                                set "tempVar4=!display%%h:~%%w!"
                                set "display%%h=!display%%h:~0,%%w!!strList:~%%r,1!!tempVar4:~1!"
                            )
                        )
                    )
                )
            )
        )
    )
    for /l %%w in (0,%3,%screenWidth%) do (
        if not "!display%screenHeight%:~%%w,1!" == " " (
            set /a tempVar3=!random! %% %2
            if "!tempVar3!" == "0" (
                set /a tempVar3=!random! %% %2
                if "!tempVar3!" == "0" (
                    for /l %%h in (1,1,%screenHeight%) do (
                        set "tempVar4=.!display%%h:~%%w!"
                        set "display%%h=!display%%h:~0,%%w! !tempVar4:~2!"
                    )
                ) else (
                    for /l %%h in (1,1,%screenHeight%) do (
                        set /a tempVar4=%%h+1
                        for %%r in (!tempVar4!) do (
                            set "tempVar4=!display%%h:~%%w!"
                            set "display%%h=!display%%h:~0,%%w!!display%%r:~%%w,1!!tempVar4:~1!"
                        )
                    )
                    set /a tempVar3=!random! %% %tempVar2%
                    for %%r in (!tempVar3!) do (
                        set "tempVar4=!display%screenHeight%:~%%w!"
                        set "display%screenHeight%=!display%screenHeight%:~0,%%w!!strList:~%%r,1!!tempVar4:~1!"
                    )
                )
            )
        )
    )
    if "0" == "0" (
        for /l %%n in (0,1,%tempVar1%) do rem Test
    ) > nul
    cls
    for /l %%h in (1,1,%screenHeight%) do echo=!display%%h:~0,%screenWidth%!
)
goto :EOF

:matrix2
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :StrLen strList
set "tempVar2=%return%"
set /a tempVar1=%systemLPS% * %1

set "tempVar4="
for /l %%n in (1,1,%screenWidth%) do set "tempVar4=!tempVar4! "
for /l %%n in (1,1,%screenHeight%) do set "display%%n=%tempVar4%"
cls
title The Matrix
color 02
for /l %%z in (0,0,1) do (
    
    if "0" == "0" (
        for /l %%n in (0,1,%tempVar1%) do rem Test
    ) > nul
    cls
    for /l %%h in (1,1,%screenHeight%) do echo=!display%%h:~0,%screenWidth%!
)
goto :EOF

:matrix2a
rem tempVar List
rem 1 - Delay Speed
rem 2 - String Length
rem 3 - Custom random number

set "strList=@#$*:[]/\.,;'=-_+`~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
call :StrLen strList
set "tempVar2=%return%"
set /a tempVar1=%systemLPS% * %1
set "tempVar4="
for /l %%n in (1,1,%screenHeight%) do set "tempVar4=!tempVar4! "
for /l %%n in (1,1,%screenWidth%) do set "column%%n=. %tempVar4% "
cls
title The Matrix
color 02
for /l %%z in (0,0,1) do (
    for /l %%h in (1,1,%screenHeight%) do set "display%%h="
    for /l %%n in (1,%3,%screenWidth%) do (
        set /a tempVar3=!random! %% %2
        set "column%%n=!column%%n: =!"
        if not "!tempVar3!" == "0" (
            if "!column%%n:~%screenHeight%,1!" == "" (
                set /a tempVar3=!random! %% %tempVar2%
                for %%r in (!tempVar3!) do set "column%%n=!column%%n!!strList:~%%r,1!"
            ) else (
                set /a tempVar3=!random! %% %2
                if "!tempVar3!" == "0" (
                    set "column%%n=."
                ) else (
                    set /a tempVar3=!random! %% %tempVar2%
                    for %%r in (!tempVar3!) do set "column%%n=!column%%n:~1!!strList:~%%r,1!"
                )
            )
        )
        set "column%%n=!column%%n! %tempVar4%"
        for /l %%h in (1,1,%screenHeight%) do set "display%%h=!display%%h!!column%%n:~%%h,1! "
    )
    for /l %%n in (0,1,%tempVar1%) do rem Test > nul
    cls
    for /l %%h in (1,1,%screenHeight%) do (
        set "display=!display%%h:~0,%screenWidth%!"
        set "display=!display:~1!"
        echo=!display!
    )
)
goto :EOF

rem Functions

:Math_Random [Minimum Number] [Maximum Number]
set /a return=%2 - %1
for %%r in (%return%) do (
    set /a return=!random! * 32768 + !random!
    if %%r GTR 0 set /a return=!return! %% %%r
    if %%r LSS 0 set /a return=-!return! %% %%r
    if "%%r" == "0" set "return=0"
)
set /a return+=%1
goto :EOF

:StrLen
rem %1 is the string name
rem TempVar:
if not defined %1 set "return=0" & goto :EOF
for /l %%n in (8192,-1,0) do if "!%1:~%%n,1!"=="" set "return=%%n" > nul
goto :EOF
:EOF

:stringRandom
rem %1 is the array variable name
rem %2 is the number of length to be generated
rem TempVar: 0, 4-5; 1-3
call :StrLen %1
set /a tempVar2=%return%-1
set "tempVar1="
for /l %%n in (1,1,%2) do (
    call :Math_Random 0 %tempVar2%
    for %%s in (!return!) do (
        set "tempVar1=!tempVar1!!%1:~%%s,1!"
    )
)
set "return=%tempVar1%"
goto :EOF

:Time_Subtract
rem %1 is time 1
rem %2 is time 2
rem Format  : HH:MM:SS.CS
rem TempVar: 1-2
for /f "tokens=1-4 delims=:." %%a in ("%1") do set /a tempVar1=(24%%a %% 24)*360000+1%%b*6000+1%%c*100+1%%d-610100
for /f "tokens=1-4 delims=:." %%a in ("%2") do set /a tempVar2=(24%%a %% 24)*360000+1%%b*6000+1%%c*100+1%%d-610100
set /a return=%tempVar2%-%tempVar1%
if not "%3" == "0" if %return% LSS 0 set /a return+=8640000
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

:Sleep
rem %1 is the time in centisecond
set /a return=%systemLPS% * %1
if "0" == "0" (
    for /l %%n in (0,1,%return%) do rem Test 
) > nul
set "return=1"
goto :EOF

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
