\
\ autoexec.f
\

\ This is executed a  first COLD start by AUTOEXEC
\ Display System Info

\ NEEDS BLANK
\ NEEDS BLANKS

DECIMAL

\ display CPU speed 3.5, 7.0, 14.0 or 28.0 
CR 7 REG@  3 AND  35    \ speed expressed in 100kHz
SWAP LSHIFT             \ multiply by two n times.
0 <# # CHAR . HOLD #S #> TYPE SPACE ." MHz Z80n CPU Speed." CR

\ display Core Version
14 REG@ 1 REG@ DUP 4 RSHIFT SWAP 15 AND SWAP
." Core Version " . 8 EMITC
0 <# CHAR . HOLD # # CHAR . HOLD #> TYPE . CR

\ display memory available
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
\ hp ?

CR \ ." Loading the following utilities:" CR

NEEDS    REMOUNT  \  Remount utility
NEEDS    WHERE    \  Line Editor
NEEDS    EDIT     \  Full Screen Editor
NEEDS    DUMP     
NEEDS    HEAP     \  Heap Memory Management
NEEDS    S"       \  String on heap facility
NEEDS    SEE      \  Decompiler / Inspector

\ NEEDS    POINTER  \  Heap memory Pseudo-Pointer
\ NEEDS    GREP     \  Screen Search utility
\ NEEDS    ROOM   NEEDS .PAD   NEEDS SAVE
\ NEEDS    LOCATE
\ NEEDS    LED      NEEDS    CAT

11 SCR !
." ok" CR
