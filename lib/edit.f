\
\ edit.f
\
.( EDIT )
\
\ also available via DECIMAL 190 LOAD for backward compatibility
\ Typical usage:
\
\   n LIST EDIT
\


FORTH DEFINITIONS

: EDIT     ( -- )
    NOOP
;


NEEDS INVV
NEEDS TRUV
NEEDS LINE
NEEDS CASE

NEEDS EDITOR

EDITOR DEFINITIONS

BASE @

: KEYB ( -- c )     \ show cursor and wait a keypress
    CURS KEY ;

: KEYBEMIT  ( -- c )    \ and emit it
    KEYB DUP EMIT ;

: KEYBEMITD  ( -- b )       \ and treat it as a hex digit
    KEYBEMIT [ HEX ] 10 [ DECIMAL ] DIGIT DROP ;

\
DECIMAL   0 VARIABLE NROW  NROW !       \ current row
          0 VARIABLE NCOL  NCOL !       \ current columns

: HOMEC   0 NROW ! 0 NCOL ! ;           \ cursor at home (variables only)

: ADDRC   ( -- a )                      \ calc cursor addr
    NROW @ LINE NCOL @ + ;

: TO-SCR  ( row1 col1 -- col2 row2 )    \ translate xy
    0 + SWAP 2 + ;

: AT-XY   ( col row -- )                \ set print position
    22 EMITC  EMITC EMITC ;               \ using standard AT

: HOME 0 0 AT-XY ;                      \ cursor at home (display only)

: BUZZ    7 EMIT ;                      \ sound BEL

: CURC! ( c -- )    \ store chr to current screen position
    ADDRC  C! UPDATE ;

: CURC@ ( -- c )    \ fetch chr from current screen position
    ADDRC  C@ ;
\
: RULER 6 0 DO ." +----.----" LOOP ." +--" ;

\ move cursor
: UPC     NROW @  0 > IF -1  NROW +!  ELSE  BUZZ  THEN ;

: DOWNC   NROW @ 15 < IF  1  NROW +!  ELSE  BUZZ  THEN ;

: LEFTC   NCOL @  0 > IF -1  ELSE  UPC    63 THEN NCOL +! ;

: RIGHTC  NCOL @ 63 < IF  1  ELSE  DOWNC -63 THEN NCOL +! ;

\ display page
: PUTPAGE ." Screen # " SCR @ . CR RULER CR
          L/SCR 0 DO I SCR @ (LINE) TYPE CR LOOP RULER ;

\ refresh current line
: REFRESH                             
    NROW @ SCR @  OVER 0 TO-SCR AT-XY  (LINE) TYPE ;

\ refresh bottom frame
: EDIT-FRAME
    0 19 AT-XY
    INVV ."  row:" TRUV 5 SPACES INVV ."  col:" TRUV 5 SPACES
    INVV ."  hex:" TRUV 5 SPACES INVV ."  dec:" TRUV 6 SPACES
    INVV ."  chr:" TRUV
    CR INVV ."  pad:" TRUV PAD COUNT 59 MIN TYPE
    0 21 AT-XY  INVV ."  cmd:" TRUV
    CR ." U-ndo    B-ack    D-el     I-nsert   H-old"
    CR ." Q-uit    N-ext    S-hift   R-eplace  P-ut hex byte"
    56 0 AT-XY  INVV ."   edit  " TRUV ;

\ refresh numbers
: EDIT-STAT 
    CURC@
    25 19 AT-XY  HEX DUP 3 .R  36 19 AT-XY  DECIMAL DUP 3 .R
    47 19 AT-XY  32 MAX EMIT
    15 19 AT-XY  NCOL @  3 .R  05 19 AT-XY  NROW @      3 .R ;

\ accept two hex digit as a byte for current position
: BYTE ( -- b ) 
    KEYBEMITD  4 LSHIFT
    KEYBEMITD  + ; DECIMAL

\ discard changes on current Screen
: UNDO  ( -- ) 
  B/SCR 0 DO
    SCR @ B/SCR * I +
    BLOCK CELL-
    0 SWAP !
  LOOP ;

HEX
\ exiting editor session
: DONEC             8F 28 +ORIGIN C!    \ reset cursor face
                    5F 2A +ORIGIN C! ;  \ reset cursor face

\ entering editor session
: INITC   CURC@ BL MAX 28 +ORIGIN C!    \ change cursor face
                    8F 2A +ORIGIN C! ;
DECIMAL
\ handle EDIT key options
: CMD    ( c -- )   
    6 21 AT-XY DONEC KEYBEMIT UPPER BL MAX 
    CASE
    [CHAR] P OF BYTE CURC! ENDOF  \ put a byte at cursor
    [CHAR] H OF NROW @ H   ENDOF  \ copy to PAD
    [CHAR] S OF NROW @ S   ENDOF  \ shift down one row
    [CHAR] R OF NROW @ RE  ENDOF  \ replace row from PAD
    [CHAR] I OF NROW @ INS ENDOF  \ insert row from PAD
    [CHAR] D OF NROW @ D   ENDOF  \ delete row + copy to PAD
    [CHAR] N OF  1 SCR +! HOMEC ENDOF  \ next screen
    [CHAR] B OF -1 SCR +! HOMEC ENDOF  \ prev screen
    [CHAR] U OF UNDO BUZZ  ENDOF
    [CHAR] Q OF ."  ok" CR C/L 2 * SPACES
                0 21 AT-XY QUIT ENDOF
    ENDCASE HOME PUTPAGE EDIT-FRAME ;

\ back-space
: DELC    ( -- )    
    NCOL @  0 > IF -1 NCOL +! THEN
    ADDRC DUP 1+ SWAP C/L NCOL @ - 1- CMOVE UPDATE
    BL NROW @ LINE C/L + 1- C! ;

\ insert blank at cursor and shift the rest
: INSC    ( -- )    
    ADDRC DUP 1+      C/L NCOL @ - 1- CMOVE>
    BL ADDRC  C!  UPDATE ;

\ manage control keys
: CTRLC  ( c -- )   
    CASE 08 OF LEFTC  ENDOF      09 OF RIGHTC ENDOF
         10 OF DOWNC  ENDOF      11 OF UPC    ENDOF
         12 OF DELC   REFRESH ENDOF
         13 OF DOWNC 0 NCOL ! ENDOF
       07 OF CMD            ENDOF
    ENDCASE ;
\

FORTH DEFINITIONS

: EDIT-DEF     ( -- )

    EDITOR \ vocabulary

    CLS HOMEC PUTPAGE EDIT-FRAME
    BEGIN
        EDIT-STAT  INITC
        CURC@ NROW @ NCOL @ TO-SCR  2DUP AT-XY
        KEYB  ?TERMINAL IF DROP 0 INSC   REFRESH THEN
        DUP BL < IF
            >R AT-XY EMIT R>  CTRLC
        ELSE
            CURC! AT-XY DROP CURC@ EMIT RIGHTC
        THEN
    AGAIN  \ quit via EDIT-key + Q
;

\ this allows FORGET EDIT to remove this whole package

' EDIT-DEF ' EDIT >BODY !

FORTH DEFINITIONS

BASE !
