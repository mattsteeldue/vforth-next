\
\ TILE80.f

\ v-Forth 1.8 - NextZXOS version - build 2026-04-19
\ MIT License (c) 1990-2026 Matteo Vitturi     

\ Tilemode 80 columns - 1 color
\
.( TILE80 )
\
\
NEEDS LAYER3

NEEDS PAD"
NEEDS LOAD-BYTES
NEEDS [']
NEEDS CASE

MARKER TASK

\ ______________________________

\ Address of display-file useful
$4000 CONSTANT DISPLAY-FILE

\ screen size, height and width
  #80 CONSTANT T-WIDTH
  #32 CONSTANT T-HEIGHT
T-WIDTH T-HEIGHT * 
      CONSTANT T-SIZE  
      
VARIABLE T-FLAGS
      
\ ______________________________

\ row and col where should go the next emitted character
VARIABLE T-POS
\ ______________________________

\ home
: T-HOME
    0 T-POS !
    0 T-FLAGS !
    PAD" ./LIB/TILE80-charset.bin"
    $5400 #1792 LOAD-BYTES
;

\ ______________________________

\ Scroll text screen one row up.
: T-SCROLL
  [ DISPLAY-FILE T-WIDTH + ]  LITERAL
    DISPLAY-FILE
  [ T-SIZE T-WIDTH - ]  LITERAL
    CMOVE

  [ DISPLAY-FILE T-SIZE + T-WIDTH - ] LITERAL
    T-WIDTH
    BLANK
    T-POS @ T-WIDTH - 0 MAX T-POS !
;

\ ______________________________

\ Clear screen by filling blanks
: T-CLS
    DISPLAY-FILE T-SIZE BLANK
    T-HOME
;

\ ______________________________

: T-XY ( -- a )
    T-POS @ 
    DISPLAY-FILE + 
    \ move cursor ahead
    1 T-POS +!
;

\ ______________________________
\
\ cr or lf
: T-CR
    T-POS @ 
    T-WIDTH /MOD NIP
    1+ T-WIDTH *
    T-POS !
    [ T-SIZE T-WIDTH - ]  LITERAL 
    T-POS @ < IF
        T-SCROLL
    THEN
;

\ ______________________________
\
\ Backspace
: T-BS
    T-POS @ 
    1- 0 MAX
    T-POS !
;

\ ______________________________

\ decode Emit
: T-DECODE ( c1 -- )
    T-FLAGS @ 
    IF
        T-FLAGS @ 
        CASE
            1 OF  T-POS +!           0 T-FLAGS !  ENDOF
            2 OF  T-WIDTH * T-POS !  1 T-FLAGS !  ENDOF
        ENDCASE
    ELSE
        CASE
            $08 OF T-BS ENDOF
            $0A OF T-CR ENDOF
            $0D OF T-CR ENDOF
            $16 OF 2 T-FLAGS ! ENDOF
        ENDCASE
    THEN
;

\ ______________________________

: T-EMITC ( c -- )
    DUP BL < 
    T-FLAGS @  OR
    IF
        T-DECODE
    ELSE
        \ First check if we must scroll one row
        T-SIZE T-POS @ < IF 
             T-SCROLL 
        THEN
        \ Put c at the right location
        T-XY C!
    THEN
;

\ ______________________________

\ vector for emit
: T-EMIT ( c -- 0 )
    T-EMITC
    1 OUT +!
    0
;

\ ______________________________
\ 
\ restore patch
\
: NO-TILE
    TILE-OFF  
    ['] (EMITC)       ['] EMITC >BODY !
    ['] (?EMIT)       ['] EMIT  >BODY !
    ['] (CLS)         ['] CLS   >BODY !
    CLS
;

\ ______________________________
\
: TILE80
    CLS
    ['] T-EMITC       ['] EMITC >BODY !
    ['] T-EMIT        ['] EMIT  >BODY !
    ['] T-CLS         ['] CLS   >BODY !
    TILE-TXT-PALETTE
    TILE-TXT
    T-CLS 
    T-HOME  
\   PAD" ./demo/Layer3-example-txt.bin"
\   $4000 #2560 LOAD-BYTES
\   KEY
\   T-SCROLL
\   T-SCROLL
\   KEY
\   T-CLS
\   T-HOME
\   33 T-EMIT
\   33 T-EMIT
\   
\   
\   KEY
\   NO-TILE
;

