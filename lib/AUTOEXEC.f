\
\ autoexec.f
\

\ This is executed a  first COLD start by AUTOEXEC
\ Display System Info

\ NEEDS BLANK
\ NEEDS BLANKS

CR 7 REG@  3 AND  35   SWAP LSHIFT 0
<# # CHAR . HOLD #S #> TYPE SPACE ." MHz Z80n CPU Speed." CR
SP@ PAD  - U. ." bytes free in Dictionary." CR
 -1 HP @ - U. ." bytes free in Heap." CR
CR

\ we do not have conditional iterpreting, but we can emulate small task
\ wisely using MARKER called as the last-word of a definition

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

NEEDS    REMOUNT  \  Remount utility
NEEDS    HEAP     \  Heap Memory Management
NEEDS    S"       \  String on heap facility
NEEDS    WHERE    \  Line Editor
NEEDS    EDIT     \  Full Screen Editor
NEEDS    DUMP     
NEEDS    SEE      \  Decompiler / Inspector

\ NEEDS    POINTER  \  Heap memory Pseudo-Pointer
\ NEEDS    GREP     \  Screen Search utility
\ NEEDS    ROOM   NEEDS .PAD   NEEDS SAVE
\ NEEDS    LOCATE
\ NEEDS    LED      NEEDS    CAT

11 SCR !
." ok" CR
