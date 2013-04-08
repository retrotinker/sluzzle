1500 CLS
1510 GOSUB 1750
1520 PRINT @ 480, "LOADING "+IMAGE$+"...";
1530 LOADM IMAGE$+"/SLZ:"+MID$(STR$(DNUM),2)
1540 CLS : PLAY BEGIN$
1550 GOSUB 1750
1560 RC=USR0(TM)
1570 CLS : IF RC<=0 THEN 1600
1580 PLAY WON$
1590 PRINT @ 448, "GAME WON AFTER"; RC; "MOVES!" : GOTO 1620
1600 PLAY LOST$
1610 PRINT @ 448, "FORFEIT AFTER"; ABS(RC); "MOVES..."
1620 IF TM>0 THEN 1700
1630 INPUT "PLAY AGAIN (Y/N)"; YN$
1640 IF YN$="N" THEN END
1650 IF YN$<>"Y" THEN 1630
1660 INPUT "SAME PICTURE (Y/N)"; YN$
1670 IF YN$="Y" THEN 1540
1680 IF YN$<>"N" THEN 1660
1690 GOTO 1740
1700 ST=TIMER : TIMER=0
1710 IF TIMER<300 THEN 1710
1720 NT=TIMER+300 : IF NT>65535 THEN NT=NT-65535
1730 TIMER=NT
1740 RETURN
1750 PRINT @ 32, "CONTROL GUIDE"
1760 PRINT @ 98, "? - THIS SCREEN"
1770 PRINT @ 162, "H - SHOW HINT"
1780 PRINT @ 226, "I - MOVE LOWER BLOCK UP"
1790 PRINT @ 258, "K - MOVE UPPER BLOCK DOWN"
1800 PRINT @ 290, "J - MOVE BLOCK RIGHT TO LEFT"
1810 PRINT @ 322, "L - MOVE BLOCK LEFT TO RIGHT"
1820 PRINT @ 389, "break ENDS CURRENT GAME"
1830 PRINT @ 455, "ANY KEY STARTS GAME"
1840 RETURN
