\
\ autoexec.f
\

\ This is executed a  first COLD start by AUTOEXEC
\ Display System Info

MARKER FORGET-TASK

\ Set black-yellow color
DECIMAL

0 26 EMITC EMITC       \ non stop scroll
        0  67 REG!     \ Palette Control (ULA first)
       25  64 REG!     \ Palette Index Select (blue paper)
%00000001  65 REG!     \ Palette Data (darker)
       14  64 REG!     \ Palette Index Select (yellow ink)
%11111001  65 REG!     \ Palette Data (lighter)
1 17 EMITC EMITC       \ Paper 1 (blue)


\ Display splash-screen
SPLASH

\ display CPU speed 3.5, 7.0, 14.0 or 28.0 
CR 7 REG@  3 AND  35    \ speed expressed in 100kHz
SWAP LSHIFT             \ multiply by two n times.
0 <# # CHAR . HOLD #S #> TYPE SPACE ." MHz Z80n CPU Speed." CR

\ display Core Version
14 REG@ 1 REG@ DUP 4 RSHIFT SWAP 15 AND SWAP
." Core Version " . 8 EMITC
0 <# CHAR . HOLD # # CHAR . HOLD #> TYPE . CR

NEEDS .FREE-SIZE 

\ display memory available
SP@ PAD  - U. ." bytes free in Dictionary." CR
 -1 HP @ - U. ." bytes free in Heap." CR


\ display free space on default drive
\ d is the number of 512-bytes block free on drive
.FREE-SIZE 


\ we do not have conditional iterpreting, but we can emulate small task
\ wisely using MARKER called as the last-word of a definition
: ASK-Y/N ( -- )
\ ask Y/n to continue loading 
     ." Autoexec asks: "
     ." Do you wish to load utilities ? (Y/n) "
     CURS
     KEY DUP EMIT
     UPPER
     [ CHAR N ] LITERAL
     = IF 
         ." ok " 
         FORGET-TASK 
         QUIT
     ELSE
         FORGET-TASK
    THEN 
;

CR ASK-Y/N \ to continue loading 

\
\  NextZXOS version
\
\ hp ?

CR \ ." Loading the following utilities:" CR

NEEDS    REMOUNT  \  Remount utility
NEEDS    WHERE    \  Line Editor
NEEDS    .S       \  Stack viewer
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

QUIT
