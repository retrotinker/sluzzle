2000 CLS
2010 PRINT @ 32, "OTHER OPTIONS:"
2020 PRINT @ 101, "1 - SELECT PICTURE DRIVE"
2030 PRINT @ 133, "2 - QUIT SLUZZLE"
2040 PRINT @ 389, "3 - RETURN TO MAIN MENU"
2050 PRINT
2060 INPUT "CHOICE"; C
2070 IF C<1 OR C>3 THEN 2110
2080 IF C=1 THEN 2130
2090 IF C=2 THEN END
2100 IF C=3 THEN 2180
2110 PRINT "?REDO"
2120 GOTO 2060
2130 INPUT "DRIVE NUMBER"; DNUM
2140 CLS
2150 PRINT @ 480, "SCANNING DIRECTORY...";
2160 GOSUB 1000
2170 DRIVE DNUM
2180 RETURN