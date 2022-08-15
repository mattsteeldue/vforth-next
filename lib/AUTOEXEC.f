\
\ autoexec.f
\

\ This is executed a  first COLD start by AUTOEXEC
\ Display System Info

needs .s

CR 7 REG@  3 AND  35   SWAP LSHIFT 0
<# # CHAR . HOLD #S #> TYPE SPACE ." MHz Z80n CPU Speed." CR
SP@ PAD  - U. ." bytes free in Dictionary." CR
 -1 HP @ - U. ." bytes free in Heap." CR
CR

MARKER FORGET-TASK
: ASK-Y/N ( -- )
\ ask Y/n to continue loading 
  ." Autoexec asks: "
  ." Do you wish to load scr# 11 ? (Y/n) "
  CURS
  KEY DUP EMIT
  UPPER
  [ CHAR N ] LITERAL
  = IF 
   ." ok " DROP 
   FORGET-TASK QUIT
  ELSE
   FORGET-TASK
 THEN ;
ASK-Y/N \ to continue loading 
\
\  NextZXOS version
\

CR \ ." Loading the following utilities:" CR

\ NEEDS    S"         Heap Memory Management
\ NEEDS    POINTER
NEEDS    WHERE    \ Line Editor
NEEDS    SEE      \ Decompiler / Inspector
NEEDS    EDIT     \ Full Screen Editor
NEEDS    GREP     \ Screen Search utility
NEEDS    REMOUNT  \ Remount utility
\ NEEDS    ROOM   NEEDS .PAD   NEEDS SAVE
\ NEEDS    LOCATE
\ NEEDS    LED      NEEDS    CAT

11 SCR !
." ok" CR

