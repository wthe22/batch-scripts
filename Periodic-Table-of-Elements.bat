@goto main

rem Periodic Table of Elements
rem Updated on 2016-10-02
rem Made by wthe22 - http://winscr.blogspot.com/

:main
@echo off
prompt $s
setlocal EnableDelayedExpansion EnableExtensions

title Periodic Table of Elements

cls
call :displayPeriodicTable
call :readData

:mainMenu
set "userInput=?"
cls
echo 1. Search for element informations
echo 2. View Periodic Table
echo 3. Test your knowledge
echo=
echo 0. Exit
echo=
echo What do you want to do?
set /p "userInput="
if "!userInput!" == "0" exit
if "!userInput!" == "1" goto searchTable
if "!userInput!" == "2" goto viewTable
if "!userInput!" == "3" goto questionTypeIn
goto mainMenu

rem ========================================== Search Periodic Table ===========================================

:searchTable
set "searchKeyword=?"
cls
echo Input search keyword   :
set /p "searchKeyword="

echo=
echo Please wait...
set "resultCount=0"
for %%f in (!searchFields!) do for /l %%n in (1,1,!elementCount!) do (
    set "tempVar1= !elementInfo%%n_%%f!"
    if not "!tempVar1:%searchKeyword%=!" == "!tempVar1!" (
        set /a "resultCount+=1"
        set "searchResult!resultCount!=%%n"
        set "tempVar1=   !resultCount!"
        set "searchDisplay!resultCount!=!tempVar1:~-3,3!. !fieldName%%f! of !elementInfo%%n_3!"
    )
)

:displaySearchResult
cls
echo Search results (!resultCount!):
echo=
for /l %%n in (1,1,!resultCount!) do echo !searchDisplay%%n!
echo=
echo 0. Back
echo=
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if !userInput! GEQ 1 if !userInput! LEQ !resultCount! goto displayElementDetails
goto displaySearchResult


:displayElementDetails
set /a "userInput+=0"
cls
for %%n in (!searchResult%userInput%!) do (
    for /l %%f in (1,1,!fieldCount!) do if defined elementInfo%%n_%%f (
        set "display=!fieldName%%f!                        "
        set "display=!display:~0,23!: !elementInfo%%n_%%f!"
        if "%%f" == "9" set "display=!display! K"
        if "%%f" == "10" set "display=!display! K"
        echo !display!
    )
)
echo=
pause
goto mainMenu

rem ========================================== Periodic Table ===========================================

:viewTable
cls
call :displayPeriodicTable
pause > nul
goto mainMenu


:displayPeriodicTable
echo ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
echo º  ³ 1³ 2³ 3³ 4³ 5³ 6³ 7³ 8³ 9³10³11³12³13³14³15³16³17³18º
echo ºÄÄ+ÄÄ+ÄÄ+ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ+ÄÄ+ÄÄ+ÄÄ+ÄÄ+ÄÄ+ÄÄº
echo º 1³H³                                                ³Heº
echo ºÄÄ+ÄÄÄÄÄÄ                             ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º 2³Li³Be³                             ³ B³ C³ N³ O³ F³Neº
echo ºÄÄ+ÄÄÄÄÄÄ                             ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º 3³Na³Mg³                             ³Al³Si³ P³ S³Cl³Arº
echo ºÄÄ+ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º 4³ K³Ca³Sc³Ti³ V³Cr³Mn³Fe³Co³Ni³Cu³Zn³Ga³Ge³As³Se³Br³Krº
echo ºÄÄ+ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º 5³Rb³Sr³ Y³Zr³Nb³Mo³Tc³Ru³Rh³Pd³Ag³Cd³In³Sn³Sb³Te³ I³Xeº
echo ºÄÄ+ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º 6³Cs³Ba³La³Hf³Ta³ W³Re³Os³Ir³Pt³Au³Hg³Tl³Pb³Bi³Po³At³Rnº
echo ºÄÄ+ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º 7³Fr³Ra³Ac³                                            º
echo ºÄÄ+ÄÄÄÄÄÄÄÄÄ                                            º
echo º              ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º              ³Ce³Pr³Nd³Pm³Sm³Eu³Gd³Tb³Dy³Ho³Er³Tm³Yb³Luº
echo º              ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
echo º              ³Th³Pa³ U³Np³Pu³Am³Cm³Bk³Cf³Es³Fm³Md³No³Lrº
echo ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
goto :EOF

rem ========================================== Test Knowledge ===========================================

:questionTypeIn
set "quizType="
cls
echo 1. Name
echo 2. Symbol
echo 3. Proton Number
echo 4. Relative atomic mass
echo=
echo R. Random (All of above)
echo 0. Exit
echo=
echo Choose question type:
set /p "userInput="
if "!userInput!" == "0" goto mainMenu
if "!userInput!" == "1" set "quizType=3"
if "!userInput!" == "2" set "quizType=2"
if "!userInput!" == "3" set "quizType=1"
if "!userInput!" == "4" set "quizType=4"
if /i "!userInput!" == "R" set "quizType=R"
if defined quizType goto elementRangeIn
goto questionTypeIn

:elementRangeIn
cls
echo  1-36 means from Hydrogen to Krypton
echo 19-54 means from Potassium to Xenon
echo=
echo 0. Back
echo=
echo Input range of elements:
set /p "userInput="
for /f "tokens=1-2 delims=-" %%a in ("!userInput: =!") do (
    if %%a0 GEQ 10 if %%a0 LEQ 2000 (
        if %%b0 GEQ 10 if %%b0 LEQ 2000 (
            set "elementRange=%%a %%b"
            goto totalQuestionsIn
        )
    )
)
goto elementRangeIn


:totalQuestionsIn
cls
echo 0. Back
echo=
echo How many questions do you want? (1-250)
set /p "totalQuestions="
if "!quizType!" == "0" goto elementRangeIn
if !totalQuestions! GEQ 1 if !totalQuestions! LEQ 250 goto generateQuestion_setup
goto totalQuestionsIn

:generateQuestion_setup
set "startTime=!time!"
set "correctAns=0"
set "currentQuestion=0"
set /a "totalQuestions+=0"
set "randomQuiz=false"

cls
if /i "!quizType!" == "R" goto randomQuestion

if "!quizType!" == "3" (
    echo Enter the correct !fieldName2! for each question
) else echo Enter the correct !fieldName3! for each question
echo=

:generateQuestion
set /a "currentQuestion+=1"
title Periodic Table of Elements Quiz - [!currentQuestion!/!totalQuestions!]

call :rand !elementRange!
rem Ask question
if "!quizType!" == "3" (
    set /p "userInput=!elementInfo%return%_2! : "
) else set /p "userInput=!elementInfo%return%_3! : "

rem Check answer
if /i "!userInput!" == "!elementInfo%return%_%quizType%!" (
    set /a "correctAns+=1"
    echo Correct^^!
) else echo Wrong^^! Answer: !elementInfo%return%_%quizType%!
echo=

if not "!currentQuestion!" == "!totalQuestions!" goto generateQuestion
goto quizDone


:randomQuestion
call :rand !elementRange!
set /a "quizType=!random! %% 4 + 1"

rem Ask question
if "!quizType!" == "3" (
    set /p "userInput=!fieldName%quizType%! of !elementInfo%return%_2! : "
) else set /p "userInput=!fieldName%quizType%! of !elementInfo%return%_3! : "

rem Check answer
if /i "!userInput!" == "!elementInfo%return%_%quizType%!" (
    set /a "correctAns+=1"
    echo Correct^^!
) else echo Wrong^^! Answer: !elementInfo%return%_%quizType%!
echo=
if not "!currentQuestion!" == "!totalQuestions!" goto randomQuestion
goto quizDone


:quizDone
call :difftime !time! !startTime!
call :ftime !return!
set /a "score=!correctAns! * 100 / !totalQuestions!"

title Periodic Table of Elements
echo You have done all the questions
echo Press any key to see your score...
pause > nul

cls
echo =============== Results ===============
echo=
echo Time taken         : !return!
echo Correct answers    : !correctAns!
echo Total questions    : !totalQuestions!
echo Your score         : !score!
echo=
pause
goto mainMenu

rem ========================================== Read Periodic Table Data ===========================================

:readData
set "delimsChar=;"
set "fieldCount=10"
set "searchFields=1 2 3 4"

set "readFile=false"
set "elementCount=-1"
for /f "usebackq tokens=*" %%o in ("%~f0") do (
    if /i "%%o" == "#END" set "readFile=false"
    if /i "!readFile!" == "true" (
        set /a "elementCount+=1"
        set "tempVar1=%%o!delimsChar!"
        for %%s in ("        " "    " "  " " ") do set "tempVar1=!tempVar1:%%~s;=;!"
        for /f "tokens=1-10 delims=;" %%a in ("!tempVar1!") do (
            set  "elementInfo!elementCount!_1=%%a"
            set  "elementInfo!elementCount!_2=%%b"
            set  "elementInfo!elementCount!_3=%%c"
            set  "elementInfo!elementCount!_4=%%d"
            set  "elementInfo!elementCount!_5=%%e"
            set  "elementInfo!elementCount!_6=%%f"
            set  "elementInfo!elementCount!_7=%%g"
            set  "elementInfo!elementCount!_8=%%h"
            set  "elementInfo!elementCount!_9=%%i"
            set "elementInfo!elementCount!_10=%%j"
        )
    )
    if "%%o" == "[Element_Info]" set "readFile=true"
)
set "readFile="
for /l %%n in (1,1,!fieldCount!) do (
    set "fieldName%%n=!elementInfo0_%%n!"
    set "elementInfo0_%%n="
)
goto :EOF


rem ========================================== Functions ===========================================

:rand [minimum] [maximum]
set /a return=!random!*65536 + !random!*2 + !random!/16384
set /a return%%= %2 - %1 + 1
set /a return+=%1
goto :EOF


:difftime [end_time] [start_time] [/n]
set "return=0"
for %%t in (%1:00:00:00:00 %2:00:00:00:00) do (
    for /f "tokens=1-4 delims=:." %%a in ("%%t") do (
        set /a "return+=24%%a %% 24 *360000+1%%b*6000+1%%c*100+1%%d-610100"
    )
    set /a "return*=-1"
)
if not "%3" == "/n" if !return! LSS 0 set /a "return+=8640000"
goto :EOF


:ftime [time_in_centisecond]
set /a tempVar1=%1 %% 8640000
set "return="
for %%n in (360000 6000 100 1) do (
    set /a tempVar2=!tempVar1! / %%n
    set /a tempVar1=!tempVar1! %% %%n
    set "tempVar2=?0!tempVar2!"
    set "return=!return!!tempVar2:~-2,2!:"
)
set "return=!return:~0,-4!.!return:~-3,2!"
goto :EOF

rem ========================================== Periodic Table Data ===========================================

[Element_Info]
Proton Number;Element Symbol;Element Name;Relative Atomic Mass;Group Number;Period;Block;Valency;Melting Point;Boiling Point;Density
1   ;H  ;Hydrogen       ;1      ;1      ;1  ;S  ;1      ;13.99  ;20.271 ;0.08988
2   ;He ;Helium         ;4      ;18     ;1  ;S  ;0      ;0.95   ;4.222  ;0.1786 
3   ;Li ;Lithium        ;7      ;1      ;2  ;S  ;1      ;453.65 ;1603   ;0.534  
4   ;Be ;Beryllium      ;9      ;2      ;2  ;S  ;2      ;1560   ;3243   ;1.85   
5   ;B  ;Boron          ;11     ;13     ;2  ;P  ;3      ;2349   ;4200   ;2.08   
6   ;C  ;Carbon         ;12     ;14     ;2  ;P  ;4      ; -     ;3915   ;1.8-2.1
7   ;N  ;Nitrogen       ;14     ;15     ;2  ;P  ;3      ;63.15  ;77.355 ;1.251  
8   ;O  ;Oxygen         ;16     ;16     ;2  ;P  ;2      ;54.36  ;90.188 ;1.429  
9   ;F  ;Fluorine       ;19     ;17     ;2  ;P  ;1      ;53.48  ;85.3   ;1.696  
10  ;Ne ;Neon           ;20     ;18     ;2  ;P  ;0      ;24.56  ;27.104 ;0.9002 
11  ;Na ;Sodium         ;23     ;1      ;3  ;S  ;1      ;370.994;1156.09;0.968  
12  ;Mg ;Magnesium      ;24     ;2      ;3  ;S  ;2      ;923    ;1363   ;1.738  
13  ;Al ;Aluminium      ;27     ;13     ;3  ;P  ;3      ;933.47 ;2743   ;2.7    
14  ;Si ;Silicon        ;28     ;14     ;3  ;P  ;4      ;1687   ;3538   ;2.329  
15  ;P  ;Phosphorus     ;31     ;15     ;3  ;P  ;3      ; ?     ; ?     ;Varies 
16  ;S  ;Sulfur         ;32     ;16     ;3  ;P  ;2      ;388.36 ;717.8  ;2.07   
17  ;Cl ;Chlorine       ;35.5   ;17     ;3  ;P  ;1      ;171.6  ;239.11 ;3.2    
18  ;Ar ;Argon          ;40     ;18     ;3  ;P  ;0      ;83.81  ;87.302 ;1.784  
19  ;K  ;Potassium      ;39     ;1      ;4  ;S  ;1      ;336.7  ;1032   ;0.862  
20  ;Ca ;Calcium        ;40     ;2      ;4  ;S  ;2      ;1115   ;1757   ;1.55   
21  ;Sc ;Scandium       ;45     ;3      ;4  ;D  ;2      ;1814   ;3109   ;2.985  
22  ;Ti ;Titanium       ;48     ;4      ;4  ;D  ;2      ;1941   ;3560   ;4.506  
23  ;V  ;Vanadium       ;51     ;5      ;4  ;D  ;2      ;2183   ;3680   ;6.0    
24  ;Cr ;Chromium       ;52     ;6      ;4  ;D  ;2      ;2180   ;2944   ;7.19   
25  ;Mn ;Manganese      ;55     ;7      ;4  ;D  ;2      ;1519   ;2334   ;7.21   
26  ;Fe ;Iron           ;56     ;8      ;4  ;D  ;2,3    ;1811   ;3134   ;7.874  
27  ;Co ;Cobalt         ;59     ;9      ;4  ;D  ;2      ;1768   ;3200   ;8.9    
28  ;Ni ;Nickel         ;59     ;10     ;4  ;D  ;2      ;1728   ;3003   ;8.908  
29  ;Cu ;Copper         ;64     ;11     ;4  ;D  ;2      ;1357.77;2835   ;8.96   
30  ;Zn ;Zinc           ;65     ;12     ;4  ;D  ;2      ;692.68 ;1180   ;7.14   
31  ;Ga ;Gallium        ;70     ;13     ;4  ;P  ;3      ;302.915;2673   ;5.91   
32  ;Ge ;Germanium      ;73     ;14     ;4  ;P  ;4      ;1211.4 ;3106   ;5.323  
33  ;As ;Arsenic        ;75     ;15     ;4  ;P  ;3      ; -     ;887    ;5.727  
34  ;Se ;Selenium       ;79     ;16     ;4  ;P  ;2      ;494    ;958    ;4.81   
35  ;Br ;Bromine        ;80     ;17     ;4  ;P  ;1      ;265.8  ;332    ;3.1028 
36  ;Kr ;Krypton        ;84     ;18     ;4  ;P  ;0      ;115.78 ;119.93 ;3.749  
37  ;Rb ;Rubidium       ;85     ;1      ;5  ;S  ;       ;       ;       ;       
38  ;Sr ;Strontium      ;88     ;2      ;5  ;S  ;       ;       ;       ;       
39  ;Y  ;Yttrium        ;89     ;3      ;5  ;D  ;       ;       ;       ;       
40  ;Zr ;Zirconium      ;91     ;4      ;5  ;D  ;       ;       ;       ;       
41  ;Nb ;Niobium        ;93     ;5      ;5  ;D  ;       ;       ;       ;       
42  ;Mo ;Molybdenum     ;96     ;6      ;5  ;D  ;       ;       ;       ;       
43  ;Tc ;Technetium     ;98     ;7      ;5  ;D  ;       ;       ;       ;       
44  ;Ru ;Ruthenium      ;101    ;8      ;5  ;D  ;       ;       ;       ;       
45  ;Rh ;Rhodium        ;103    ;9      ;5  ;D  ;       ;       ;       ;       
46  ;Pd ;Palladium      ;106    ;10     ;5  ;D  ;       ;       ;       ;       
47  ;Ag ;Silver         ;108    ;11     ;5  ;D  ;       ;       ;       ;       
48  ;Cd ;Cadmium        ;112    ;12     ;5  ;D  ;       ;       ;       ;       
49  ;In ;Indium         ;115    ;13     ;5  ;P  ;       ;       ;       ;       
50  ;Sn ;Tin            ;119    ;14     ;5  ;P  ;       ;       ;       ;       
51  ;Sb ;Antimony       ;122    ;15     ;5  ;P  ;       ;       ;       ;       
52  ;Te ;Tellurium      ;128    ;16     ;5  ;P  ;       ;       ;       ;       
53  ;I  ;Iodine         ;127    ;17     ;5  ;P  ;       ;       ;       ;       
54  ;Xe ;Xenon          ;131    ;18     ;5  ;P  ;       ;       ;       ;       
55  ;Cs ;Caesium        ;133    ;1      ;6  ;S  ;       ;       ;       ;       
56  ;Ba ;Barium         ;137    ;2      ;6  ;S  ;       ;       ;       ;       
57  ;La ;Lanthanum      ;139    ;n/a    ;6  ;F  ;       ;       ;       ;       
58  ;Ce ;Cerium         ;140    ;n/a    ;6  ;F  ;       ;       ;       ;       
59  ;Pr ;Praseodymiun   ;141    ;n/a    ;6  ;F  ;       ;       ;       ;       
60  ;Nd ;Neodymium      ;144    ;n/a    ;6  ;F  ;       ;       ;       ;       
61  ;Pm ;Promethium     ;145    ;n/a    ;6  ;F  ;       ;       ;       ;       
62  ;Sm ;Samarium       ;150    ;n/a    ;6  ;F  ;       ;       ;       ;       
63  ;Eu ;Europium       ;152    ;n/a    ;6  ;F  ;       ;       ;       ;       
64  ;Gd ;Gadolinium     ;157    ;n/a    ;6  ;F  ;       ;       ;       ;       
65  ;Tb ;Terbium        ;159    ;n/a    ;6  ;F  ;       ;       ;       ;       
66  ;Dy ;Dysprosium     ;163    ;n/a    ;6  ;F  ;       ;       ;       ;       
67  ;Ho ;Holmium        ;165    ;n/a    ;6  ;F  ;       ;       ;       ;       
68  ;Er ;Erbium         ;167    ;n/a    ;6  ;F  ;       ;       ;       ;       
69  ;Tm ;Thulium        ;169    ;n/a    ;6  ;F  ;       ;       ;       ;       
70  ;Yb ;Ytterbium      ;173    ;n/a    ;6  ;F  ;       ;       ;       ;       
71  ;Lu ;Lutertium      ;175    ;n/a    ;6  ;D  ;       ;       ;       ;       
72  ;Hf ;Hafnium        ;179    ;4      ;6  ;D  ;       ;       ;       ;       
73  ;Ta ;Tantalum       ;181    ;5      ;6  ;D  ;       ;       ;       ;       
74  ;W  ;Tungsten       ;184    ;6      ;6  ;D  ;       ;       ;       ;       
75  ;Re ;Rhenium        ;186    ;7      ;6  ;D  ;       ;       ;       ;       
76  ;Os ;Osmium         ;190    ;8      ;6  ;D  ;       ;       ;       ;       
77  ;Ir ;Iridium        ;192    ;9      ;6  ;D  ;       ;       ;       ;       
78  ;Pt ;Platinum       ;195    ;10     ;6  ;D  ;       ;       ;       ;       
79  ;Au ;Gold           ;197    ;11     ;6  ;D  ;       ;       ;       ;       
80  ;Hg ;Mercury        ;201    ;12     ;6  ;D  ;       ;       ;       ;       
81  ;Tl ;Thallium       ;204    ;13     ;6  ;P  ;       ;       ;       ;       
82  ;Pb ;Lead           ;207    ;14     ;6  ;P  ;       ;       ;       ;       
83  ;Bi ;Bismuth        ;208    ;15     ;6  ;P  ;       ;       ;       ;       
84  ;Po ;Polonium       ;209    ;16     ;6  ;P  ;       ;       ;       ;       
85  ;At ;Astatine       ;210    ;17     ;6  ;P  ;       ;       ;       ;       
86  ;Rn ;Radon          ;222    ;18     ;6  ;P  ;       ;       ;       ;       
87  ;Fr ;Francium       ;223    ;1      ;7  ;S  ;       ;       ;       ;       
88  ;Ra ;Radium         ;226    ;2      ;7  ;S  ;       ;       ;       ;       
89  ;Ac ;Actinium       ;227    ;n/a    ;7  ;F  ;       ;       ;       ;       
90  ;Th ;Thorium        ;232    ;n/a    ;7  ;F  ;       ;       ;       ;       
91  ;Pa ;Protactinium   ;231    ;n/a    ;7  ;F  ;       ;       ;       ;       
92  ;U  ;Uranium        ;238    ;n/a    ;7  ;F  ;       ;       ;       ;       
93  ;Np ;Neptunium      ;237    ;n/a    ;7  ;F  ;       ;       ;       ;       
94  ;Pu ;Plutonium      ;244    ;n/a    ;7  ;F  ;       ;       ;       ;       
95  ;Am ;Americium      ;243    ;n/a    ;7  ;F  ;       ;       ;       ;       
96  ;Cm ;Curium         ;247    ;n/a    ;7  ;F  ;       ;       ;       ;       
97  ;Bk ;Berkelium      ;247    ;n/a    ;7  ;F  ;       ;       ;       ;       
98  ;Cf ;Californium    ;251    ;n/a    ;7  ;F  ;       ;       ;       ;       
99  ;Bk ;Einsteinium    ;252    ;n/a    ;7  ;F  ;       ;       ;       ;       
100 ;Fm ;Fermium        ;257    ;n/a    ;7  ;F  ;       ;       ;       ;       
101 ;Md ;Mendelevium    ;258    ;n/a    ;7  ;F  ;       ;       ;       ;       
102 ;No ;Nobelium       ;259    ;n/a    ;7  ;F  ;       ;       ;       ;       
103 ;Lr ;Lawrencium     ;262    ;n/a    ;7  ;D  ;       ;       ;       ;       
104 ;Rf ;Rutherfordium  ;267    ;4      ;7  ;D  ;       ;       ;       ;       
105 ;Db ;Dubnium        ;268    ;5      ;7  ;D  ;       ;       ;       ;       
106 ;Sg ;Seaborgium     ;271    ;6      ;7  ;D  ;       ;       ;       ;       
107 ;Bh ;Bohrium        ;272    ;7      ;7  ;D  ;       ;       ;       ;       
108 ;Hs ;Hassium        ;270    ;8      ;7  ;D  ;       ;       ;       ;       
109 ;Mt ;Meitnerium     ;276    ;9      ;7  ;D  ;       ;       ;       ;       
110 ;Ds ;Darmstadtium   ;281    ;10     ;7  ;D  ;       ;       ;       ;       
111 ;Rg ;Roentgenium    ;280    ;11     ;7  ;D  ;       ;       ;       ;       
112 ;Cn ;Copernicium    ;285    ;12     ;7  ;D  ;       ;       ;       ;       
113 ;Uut;Ununtrium      ;284    ;13     ;7  ;P  ;       ;       ;       ;       
114 ;Fl ;Flerovium      ;289    ;14     ;7  ;P  ;       ;       ;       ;       
115 ;Uup;Ununpentium    ;288    ;15     ;7  ;P  ;       ;       ;       ;       
116 ;Lv ;Livermorium    ;293    ;16     ;7  ;P  ;       ;       ;       ;       
117 ;Uus;Ununseptium    ;294    ;17     ;7  ;P  ;       ;       ;       ;       
118 ;Uuo;Ununoctium     ;294    ;18     ;7  ;P  ;       ;       ;       ;       
#END
