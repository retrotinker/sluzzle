2500 ST=TIMER : TIMER=0
2510 PRINT PR$+"? ";
2520 IN$=""
2530 IF TM>0 AND TIMER>TM THEN 2740
2540 K$=INKEY$
2550 IF K$="" THEN 2530 
2560 TIMER=0
2570 IF ASC(K$)=&H08 THEN 2630
2580 IF ASC(K$)=&H0C THEN 2660
2590 IF ASC(K$)=&H0D THEN 2670
2600 PRINT K$;
2610 IN$=IN$+K$
2620 GOTO 2530
2630 IF LEN(IN$)=0 THEN 2530
2640 IN$=LEFT$(IN$,LEN(IN$)-1)
2650 PRINT K$; : GOTO 2530
2660 PRINT : GOTO 2730
2670 PRINT : IF LEN(IN$)=0 THEN 2730
2680 FOR I=1 TO LEN(IN$)
2690 K=ASC(MID$(IN$,I,1))
2700 IF K<&H30 OR K>&H39 THEN 2730
2710 NEXT I
2720 GOTO 2750
2730 PRINT "?REDO " : GOTO 2510
2740 RV=DV : GOTO 2760
2750 RV=VAL(IN$) : GOTO 2760
2760 NT=TIMER+ST
2770 IF NT>65535 THEN NT=NT-65535
2780 TIMER=NT
2790 RETURN