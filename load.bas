1500 CLS
1510 GOSUB 1700
1520 PRINT @ 480, "LOADING "+IMAGE$+"...";
1530 LOADM IMAGE$+"/SLZ"
1540 CLS : PLAY BEGIN$
1550 GOSUB 1700
1560 RC=USR0(0)
1570 CLS : IF RC<=0 THEN 1600
1580 PLAY WON$
1590 PRINT @ 448, "GAME WON AFTER"; RC; "MOVES!" : GOTO 1620
1600 PLAY LOST$
1610 PRINT @ 448, "FORFEIT AFTER"; ABS(RC); "MOVES..."
1620 INPUT "PLAY AGAIN (Y/N)"; YN$
1630 IF YN$="N" THEN END
1640 IF YN$<>"Y" THEN 1620
1650 INPUT "SAME PICTURE (Y/N)"; YN$
1660 IF YN$="Y" THEN 1540
1670 IF YN$<>"N" THEN 1650
1680 RETURN
1700 PRINT @ 32, "CONTROL GUIDE"
1710 PRINT @ 98, "? - THIS SCREEN"
1720 PRINT @ 162, "H - SHOW HINT"
1730 PRINT @ 226, "I - MOVE LOWER BLOCK UP"
1740 PRINT @ 258, "K - MOVE UPPER BLOCK DOWN"
1750 PRINT @ 290, "J - MOVE BLOCK RIGHT TO LEFT"
1760 PRINT @ 322, "L - MOVE BLOCK LEFT TO RIGHT"
1770 PRINT @ 389, "break ENDS CURRENT GAME"
1780 PRINT @ 455, "ANY KEY STARTS GAME"
1800 RETURN
