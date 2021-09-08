@echo off
title Maze
setlocal EnableDelayedExpansion

rem Settings ==========================
set "charDisplay=X"

set  "maxWidth=190"
set "maxHeight=65"

rem ===================================

set "screenHeight=25"
set "screenWidth=80"
for /f "tokens=* usebackq" %%o in (`mode con`) do (
    for /f %%t in ('echo %%o ^| find "Columns"') do (
        for /f "tokens=2 delims=:" %%a in ("%%o") do (
            set "screenWidth=%%a"
        )
    )
)
set  "screenWidth=%screenWidth: =%"

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
echo 0. Exit
echo=
echo Input new screen width :
set /p "screenWidth="
set /a screenWidth+=0
if "%screenWidth%" == "0" exit
if %screenWidth% GTR %maxWidth% goto screenWidthIn
if %screenWidth% LSS 14 goto screenWidthIn
:screenHeightIn
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
echo 0. Back
echo=
echo Input new screen height :
set /p "screenHeight="
set /a screenHeight+=0
if "%screenHeight%" == "0" goto screenWidthIn
if %screenHeight% GTR %maxHeight% goto screenHeightIn
if %screenHeight% LSS 6 goto screenHeightIn

cls
echo Screen Size    %screenWidth%x%screenHeight%
echo=
echo Press any key to generate maze...
pause > nul

:newMaze
cls
echo Screen Size    %screenWidth%x%screenHeight%
echo=
echo Generating maze...

set "time1=%time%"

set /a bgdWidth=%screenWidth% - 1
set /a bgdHeight=%screenHeight% - 2

set /a puzzleWidth=%screenWidth%/2 - 1
set /a puzzleHeight=%screenHeight%/2 - 2 + %screenHeight% %% 2
set /a totalCells=%puzzleWidth% * %puzzleHeight%

for /l %%x in (1,1,%puzzleWidth%) do (
    for /l %%y in (1,1,%puzzleHeight%) do (
        set "maze[%%x][%%y]=3"
        set "visit[%%x][%%y]=0"
    )
)

set /a nextX=%random% %% %puzzleWidth% + 1
set /a nextY=%random% %% %puzzleHeight% + 1
set /a rangeX1=%nextX% - 1
set /a rangeY1=%nextY% - 1
set /a rangeX2=%nextX% + 1
set /a rangeY2=%nextY% + 1
if %rangeX1% LSS 1 set "rangeX1=1"
if %rangeY1% LSS 1 set "rangeY1=1"
if %rangeX2% GTR %puzzleWidth% set "rangeX2=%puzzleWidth%"
if %rangeY2% GTR %puzzleHeight% set "rangeY2=%puzzleHeight%"

set "searchTimes=0"
set "visit[%nextX%][%nextY%]=1"
set "visitedCells=1"

:mazeGen
set /a nextX=%random% %% (%rangeX2%-%rangeX1%+1) + %rangeX1%
set /a nextY=%random% %% (%rangeY2%-%rangeY1%+1) + %rangeY1%
set /a searchTimes+=1
if "!visit[%nextX%][%nextY%]!" == "1" goto mazeGen
set "wallBreak="
set /a tempVar1=%nextX% - 1
if not %tempVar1% LSS 1 if "!visit[%tempVar1%][%nextY%]!" == "1" set "wallBreak=!wallBreak!-1"
set /a tempVar1=%nextY% - 1
if not %tempVar1% LSS 1 if "!visit[%nextX%][%tempVar1%]!" == "1" set "wallBreak=!wallBreak!-2"
set /a tempVar1=%nextX% + 1
if not %tempVar1% GTR %puzzleWidth% if "!visit[%tempVar1%][%nextY%]!" == "1" set "wallBreak=!wallBreak!+1"
set /a tempVar1=%nextY% + 1
if not %tempVar1% GTR %puzzleHeight% if "!visit[%nextX%][%tempVar1%]!" == "1" set "wallBreak=!wallBreak!+2"
if not defined wallBreak goto mazeGen
for /l %%n in (10,-1,0) do if "!wallBreak:~%%n,1!" == "" set "return=%%n"
set /a tempVar1=%random% %% (%return%/2)
set /a tempVar1*=2
set "tempVar1=!wallBreak:~%tempVar1%,2!"
set "next2X=%nextX%"
set "next2Y=%nextY%"
if "%tempVar1%" == "-1" set /a next2X=%nextX% - 1
if "%tempVar1%" == "-2" set /a next2Y=%nextY% - 1
if "%tempVar1:~0,1%" == "-" set /a maze[%next2X%][%next2Y%]-=%tempVar1:~1,1%
if "%tempVar1:~0,1%" == "+" set /a maze[%nextX%][%nextY%]-=%tempVar1:~1,1%

if %nextX% LEQ %rangeX1% set /a rangeX1=%nextX% - 1
if %nextX% GEQ %rangeX2% set /a rangeX2=%nextX% + 1
if %nextY% LEQ %rangeY1% set /a rangeY1=%nextY% - 1
if %nextY% GEQ %rangeY2% set /a rangeY2=%nextY% + 1
if %rangeX1% LSS 1 set "rangeX1=1"
if %rangeY1% LSS 1 set "rangeY1=1"
if %rangeX2% GTR %puzzleWidth% set "rangeX2=%puzzleWidth%"
if %rangeY2% GTR %puzzleHeight% set "rangeY2=%puzzleHeight%"

set "visit[%nextX%][%nextY%]=1"
set /a visitedCells+=1
title Maze Generator - [%visitedCells%/%totalCells%]

if not "%visitedCells%" == "%totalCells%" goto mazeGen

title Maze Generator
echo Creating GUI...
for /l %%n in (1,1,%screenHeight%) do set "bgdOri%%n="
for /l %%y in (1,1,%puzzleHeight%) do (
    set /a tempVar1=%%y*2 - 1
    set /a tempVar2=%%y*2
    set /a tempVar3=%%y*2 + 1
    for /f "tokens=1-3 delims=_" %%a in ("!tempVar1!_!tempVar2!_!tempVar3!") do (
        for /l %%x in (1,1,%puzzleWidth%) do (
            set /a tempVar4=%%x*2 - 1
            set /a tempVar5=%%x*2
            for /f "tokens=1-2 delims=_" %%d in ("!tempVar4!_!tempVar5!") do (
                if "!maze[%%x][%%y]!" == "0" (
                    if "!bgdOri%%a:~%%d,1!" == "Å" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Á!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "Â" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ä!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "´" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ù!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "Ã" set "bgdOri%%a=!bgdOri%%a:~0,%%d!À!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "Ú" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ä!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "¿" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ä!bgdOri%%a:~%%e!"
                    if "!bgdOri%%c:~-1,1!" == "Å" set "bgdOri%%c=!bgdOri%%c:~0,-1!´"
                    if "!bgdOri%%c:~-1,1!" == "Ã" set "bgdOri%%c=!bgdOri%%c:~0,-1!³"
                    if "!bgdOri%%c:~-1,1!" == "Â" set "bgdOri%%c=!bgdOri%%c:~0,-1!¿"
                    if "!bgdOri%%c:~-1,1!" == "Á" set "bgdOri%%c=!bgdOri%%c:~0,-1!Ù"
                    if "!bgdOri%%c:~-1,1!" == "À" set "bgdOri%%c=!bgdOri%%c:~0,-1!³"
                    if "!bgdOri%%c:~-1,1!" == "Ú" set "bgdOri%%c=!bgdOri%%c:~0,-1!³"
                    set "bgdOri%%b=!bgdOri%%b!  "
                    set "bgdOri%%c=!bgdOri%%c! Ú"
                ) else if "!maze[%%x][%%y]!" == "1" (
                    if "!bgdOri%%c:~-1,1!" == "Å" set "bgdOri%%c=!bgdOri%%c:~0,-1!´"
                    if "!bgdOri%%c:~-1,1!" == "Ã" set "bgdOri%%c=!bgdOri%%c:~0,-1!³"
                    if "!bgdOri%%c:~-1,1!" == "Â" set "bgdOri%%c=!bgdOri%%c:~0,-1!¿"
                    if "!bgdOri%%c:~-1,1!" == "Á" set "bgdOri%%c=!bgdOri%%c:~0,-1!Ù"
                    if "!bgdOri%%c:~-1,1!" == "À" set "bgdOri%%c=!bgdOri%%c:~0,-1!³"
                    if "!bgdOri%%c:~-1,1!" == "Ú" set "bgdOri%%c=!bgdOri%%c:~0,-1!³"
                    set "bgdOri%%b=!bgdOri%%b! ³"
                    set "bgdOri%%c=!bgdOri%%c! Ã"
                ) else if "!maze[%%x][%%y]!" == "2" (
                    if "!bgdOri%%a:~%%d,1!" == "Å" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Á!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "Â" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ä!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "´" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ù!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "Ã" set "bgdOri%%a=!bgdOri%%a:~0,%%d!À!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "¿" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ä!bgdOri%%a:~%%e!"
                    if "!bgdOri%%a:~%%d,1!" == "Ú" set "bgdOri%%a=!bgdOri%%a:~0,%%d!Ä!bgdOri%%a:~%%e!"
                    set "bgdOri%%b=!bgdOri%%b!  "
                    set "bgdOri%%c=!bgdOri%%c!ÄÂ"
                ) else if "!maze[%%x][%%y]!" == "3" (
                    set "bgdOri%%b=!bgdOri%%b! ³"
                    set "bgdOri%%c=!bgdOri%%c!ÄÅ"
                )
            )
        )
    )
)
set /a tempVar1=%puzzleWidth%*2
set /a tempVar2=%puzzleHeight%*2
set /a tempVar3=%tempVar2% + 1
for /l %%n in (2,1,%tempVar2%) do (
    if "!bgdOri%%n:~0,1!" == "Ä" (
        set "bgdOri%%n=Ã!bgdOri%%n:~0,-1!"
    ) else set "bgdOri%%n=³!bgdOri%%n:~0,-1!"
    if "!bgdOri%%n:~-1,1!" == "Ä" (
        set "bgdOri%%n=!bgdOri%%n!´"
    ) else set "bgdOri%%n=!bgdOri%%n!³"
)

set "bgdOri1="
set "bgdOri%tempVar3%="
for /l %%n in (1,1,%tempVar1%) do (
    if "!bgdOri2:~%%n,1!" == "³" (
        set "bgdOri1=!bgdOri1!Â"
    ) else set "bgdOri1=!bgdOri1!Ä"
    if "!bgdOri%tempVar2%:~%%n,1!" == "³" (
        set "bgdOri%tempVar3%=!bgdOri%tempVar3%!Á"
    ) else set "bgdOri%tempVar3%=!bgdOri%tempVar3%!Ä"
)
set "bgdOri1=Úº%bgdOri1:~1,-1%¿"
set "bgdOri%tempVar3%=À!bgdOri%tempVar3%:~0,-2!×Ù"


for /l %%n in (1,1,%bgdHeight%) do set "bgdMod%%n=!bgdOri%%n!"
for /l %%n in (1,1,%bgdHeight%) do set "bgdUse%%n=!bgdOri%%n!"

call :StrLen charDisplay
set "charLength=%return%"
set "userMoves=0"

set "charPosY=2"
set "charPosX=1"

set /a effectivePercentage=%totalCells% * 100 / %searchTimes%

call :Time_Subtract %time1% %time%
call :Time_CS_Format %return%

mode %screenWidth%,%screenHeight%
title Maze
cls
echo Screen Size    %screenWidth%x%screenHeight%
echo=
echo == Search evaluation == 
echo Total cells            : %totalCells%
echo Search total           : %searchTimes%
echo Search effectiveness   : %effectivePercentage% %%
echo Generate time          : %return%
echo=
echo Press any key to start solving the maze...
pause > nul

set "time1=%time%"

:bgdUpdate
for /l %%n in (1,1,%bgdHeight%) do set "bgdUse%%n=!bgdMod%%n!"
set /a tempVar1=%charPosX%+%charLength%
set "bgdUse%charPosY%=!bgdUse%charPosY%:~0,%charPosX%!%charDisplay%!bgdUse%charPosY%:~%tempVar1%!"
cls
title Maze - %userMoves% Moves
for /l %%n in (1,1,%bgdHeight%) do echo=!bgdUse%%n!
choice /c wasdm /n /m "Control: WASD , M: Menu"
set "userInput=%errorlevel%"
set /a userMoves+=1
if "%userInput%" == "1" set /a charPosY-=1
if "%userInput%" == "2" set /a charPosX-=1
if "%userInput%" == "3" set /a charPosY+=1
if "%userInput%" == "4" set /a charPosX+=1
if "%userInput%" == "5" goto screenSizeIn
if "!bgdUse%charPosY%:~%charPosX%,1!" == " " goto bgdUpdate
if "!bgdUse%charPosY%:~%charPosX%,1!" == "×" goto mazeSolved
set /a userMoves-=1
if "%userInput%" == "1" set /a charPosY+=1
if "%userInput%" == "2" set /a charPosX+=1
if "%userInput%" == "3" set /a charPosY-=1
if "%userInput%" == "4" set /a charPosX-=1
goto bgdUpdate

:mazeSolved
call :Time_Subtract %time1% %time%
call :Time_CS_Format %return%
set "userInput=."
cls
title Maze
for /l %%n in (1,1,%bgdHeight%) do echo=!bgdUse%%n!
echo Moves: %userMoves%, Time: %return%
set /p "userInput=Press enter to continue... "
goto screenSizeIn

rem Functions

:StrLen
rem %1 is the string name
rem TempVar:
if not defined %1 set "return=0" & goto :EOF
for /l %%n in (8192,-1,0) do if "!%1:~%%n,1!"=="" set "return=%%n"
goto :EOF

:String_UPPERCASE [Variable Name]
for %%a in (
    A B C D E F G
    H I J K L M N
    O P Q R S T U
    V W X Y Z
) do set "%1=!%1:%%a=%%a!"
goto :EOF

:Time_Subtract [Start Time] [End Time]
rem 0 - Returns non-adjusted value
rem 1 - Fix if the start time is the end time 
rem Format  : HH:MM:SS.CS
rem TempVar: 1-2
set "return=0"
for %%t in (%2 %1) do (
    for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
        set /a  return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100
    )
    set /a return*=-1
)
if "%3" == "1" if %return% LSS 0 set /a return*=-1
if not "%3" == "0" if %return% LSS 0 set /a return+=8640000
goto :EOF

:Time_CS_Format [Time in CS]
rem 0 - Returns negative time
rem TempVar: 1-2
set "return="
set /a tempVar1=%1 %% 8640000
if "%3" == "0" if %1 LSS 0 (
    set "return=-"
    set /a tempVar1*=-1
)
for %%n in (360000 6000 100 1) do (
    set /a tempVar2=!tempVar1! / %%n
    set /a tempVar1=!tempVar1! %% %%n
    set "tempVar2=T0!tempVar2!"
    set "return=!return!!tempVar2:~-2,2!:"
)
set "return=%return:~0,-4%.%return:~-3,2%"
goto :EOF
