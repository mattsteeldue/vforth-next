\
\ autoexec.f 
\
\ v-Forth 1.8 - NextZXOS version - build 2025-03-15
\ MIT License (c) 1990-2025 Matteo Vitturi     
\

\ This is executed at first COLD start by AUTOEXEC to display system info
\ by default, it tries to restore your last session via PERSISTENCE utility
\ if any session has been saved, otherwise, perform the standard splash screen 



\ Display splash-screen
CLS SPLASH CR 

MARKER FORGET-THIS-TASK-1 

\ set current palette idx entry to byte value b
: SET-PALETTE ( b idx -- ) 
    #64 REG!     \ Palette Index Select  
    #65 REG!     \ Palette Data 
; 
\
: EMIT2C EMITC EMITC ;
\ reset default palette control    
  0  67 REG!          \ Palette Control (ULA first)
\ modify blue background and yellow foreground color
  %00000001 #25 SET-PALETTE   \ darker blue paper
  %11111001 #14 SET-PALETTE   \ yellow ink
  1 #17 EMIT2C                \ set it  
  0 #26 EMIT2C                \ Non-stop scroll

FORGET-THIS-TASK-1



\ display Core Version number
  ." Core Version: " 
   1 REG@         \ Core Version register
  DUP 4 RSHIFT SWAP #15 AND SWAP . 8 EMITC
  0 <# CHAR . HOLD # # CHAR . HOLD #> TYPE 
  #14 REG@         \ Core Version (Sub minor number) register
  0 <# # # # #> TYPE 
  CR 

\ display CPU speed 3.5, 7.0, 14.0 or 28.0 MHz
  ." CPU Speed   : " 
  #35                  
  #7 REG@      \ CPU Speed register
  3 AND LSHIFT 
  0 <# # CHAR . HOLD #S #> TYPE SPACE ." MHz"

  CR 

\ display memory available
  ." Dictionary  : "
  SP@ PAD  - U. ." bytes free."   
  CR 
  
  ." Heap        : " \
   -1 HP @ - U. ." bytes free." 
  CR 


\ try restore now
\ move the following line up/down to include less/more display
NEEDS PERSISTENCE RESTORE-SYSTEM \ quits if restored.



MARKER FORGET-THIS-TASK-2
\
\ display free space on default drive
\ .FREE-SIZE gives the number of 512-bytes block free on drive
  ." Free space  : "  \
  NEEDS .FREE-SIZE 
  .FREE-SIZE ." bytes free on default drive." 
  CR

FORGET-THIS-TASK-2

\ we do not have conditional iterpreting, but we can emulate small task
\ wisely using MARKER called as the last-word of a definition

MARKER FORGET-THIS-TASK-3

: ASK-Y/N ( -- ) 
\ ask Y/n to continue loading 
    ." Autoexec asks: " 
    ." Do you wish to load utilities ? (Y/n) " 
    CURS KEY DUP EMIT 
    UPPER 
    [ CHAR N ] LITERAL = 
    IF ( in-key == N )
        ." ok " 
        FORGET-THIS-TASK-3 
        QUIT 
    ELSE 
        FORGET-THIS-TASK-3
    THEN 
; 

CR 
ASK-Y/N \ to continue loading 

\
\  NextZXOS version
\
\ hp ?

CR ." Loading the following utilities:" CR

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

