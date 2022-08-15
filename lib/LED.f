\
\ LED.f
\
.( LED - Large EDitor )
\
\ Large file EDitor. This source creates a new word LED, an editor that
\ uses all RAM available.
\ Each line can be 85 characters long, so the maximum line number is 17.664.
\ Tipical usage:
\
\   LED      cccc       edit file cccc
\                       file can be saved while editing using EDIT+W command.
\
\   LED-EDIT            re-enter editor on current RAM content
\
\   LED-SAVE            force a save of RAM content to file set by LED-FILE.
\
\   LED-FILE cccc       set LED-FN to cccc, useful to rename file on save.
\

MARKER FORGET-LED \ this allows you to forget all this package.

: KEY CURS KEY ;

NEEDS SHOW-PROGRESS  NEEDS INVV     NEEDS TRUV
NEEDS CASE           NEEDS LINE

DECIMAL

CREATE LED-FN DECIMAL  80 ALLOT \ filename string

0 variable LED-FH      LED-FH !   \ filehandle of open file

 85 CONSTANT COLS/ROW            \ columns per row
  8 1024 *   COLS/ROW / CONSTANT ROWS/PAGE   \ rows per 8K
       512   COLS/ROW / CONSTANT LED-CHARSIZE

1  VARIABLE LED-LN    LED-LN    !        \ line number
1  VARIABLE LED-MAX   LED-MAX   !        \ max line number
0  VARIABLE LED-ROW   LED-ROW   !
0  VARIABLE LED-COL   LED-COL   !
1  VARIABLE LED-HOME  LED-HOME  !        \ first line to display


\ Since 8Kpages #32-39 are used by HEAP, we can use #40-223
\ for this Large-file EDitor
: >>FAR ( row -- n a )
    \ given a row-number ret page+offset
    rows/page /mod  [ DECIMAL ] 40 +
    dup 223 >  if 40 error then  \ out-of-memory
    swap cols/row  * [ HEX ] E000 OR swap ;
\
\ Row-ADdress, prepare MMU7 and return address of row
: LED-RAD  ( row -- a )
    >>FAR MMU7! ;

: LED-CLOSE
    led-fh @ f_close [ DECIMAL ]
    0 led-fh !
    42 ?error
;

\ assumes to read page np from filehandle LED-FH
\ returns actual characters read. 0 means EOF
\ row is stored in 8K-pages RAM 40-223
decimal

: LED-RD1  ( np -- b )
    1 block   \ use block 1 as special buffer  \ np a a
    dup b/buf 2- led-fh @ f_getline >R         \ np a     \ b
    swap led-rad COLS/ROW 2dup blanks          \ a a1 n1
    cmove R>                                   \ b
;

\ write line # np to file
\ n.b. trailing spaces are always removed
: LED-WR1  ( np -- )
    led-rad COLS/ROW -TRAILING                      \ a n
    2DUP  + [ HEX ] 0A  SWAP C!                     \ a n
    2DUP 1+ LED-FH @ F_WRITE [ decimal ] 47 ?ERROR  \ a n n
    DROP  + [ HEX ] 20  SWAP C!                     \
;

\ __________________________________________________________________________

\ accept text from source to be used as filename and keep it in LED-FN counted
\ z-string
DECIMAL
: LED-FILE ( -- cccc )
    bl word dup 1+ c@ if
        led-fn 80 erase
        led-fn over c@ 1+ cmove
    else drop then
;

\ open file and load to RAM
DECIMAL
: LED-OPEN  ( -- )
    led-fn 1+ pad 1
    f_open 43 ?error
    led-fh !
    0 led-ln !
;

\ load filename specified in LED-FH
\ Filehandle must be already open for read
DECIMAL
: LED-READ ( -- )
    begin
        led-ln @  show-progress
        1 led-ln +!
        led-ln @ led-rd1
        ?terminal 1 AND 1- AND
    0= until \ end of file
    led-ln @ 1- led-max !
;

: LED-LOAD ( -- )
    LED-OPEN
    LED-READ
    LED-CLOSE
;

\ save current filename
: LED-SAVE ( -- )
    led-fn 1+ pad [ hex 0C 02 + ] LITERAL
    f_open [ decimal ] 41 ?error
    led-fh  !
    LED-MAX @ 1+ 1 ?DO
        I show-progress
        I LED-WR1
        ?terminal if leave then \ can be interrupted via BREAK
    LOOP
    LED-CLOSE
;

\ __________________________________________________________________________

DECIMAL

: LED-LINE ( n -- a )     \ address of current screen line n
    LED-HOME @ + LED-RAD ;

: LED-PAD ( -- a )          \ dedicated PAD
    HERE 168 + ;

: LED-DISPLAY               \ display current screen
    16 0 DO
        I LED-HOME @ +  LED-MAX @ > IF
            COLS/ROW 1 do [char] # emit loop
        ELSE
            I led-line COLS/ROW TYPE
        THEN
        CR
    LOOP
;

: LED-MOVE ( a n -- )      \ move from a to line n
    led-line COLS/ROW cmove ;

: H ( n -- )               \ hold line to pad
    led-line pad 1+ cols/row dup pad c! cmove ;

: E ( n -- )               \ erase line
    led-line cols/row blanks ;


: RE ( n -- )              \ restore line from pad
    pad 1+ swap led-move ;

: D ( n -- )               \ delete line
    dup H led-max @ dup 1- rot     \  m m-1 n
    ?Do
        i 1+ led-line led-pad cols/row cmove
        led-pad i led-move
    Loop E  -1 led-max +! ;

: S ( n -- )                \ insert blank line
    dup 1- led-max @          \ n n m
    ?do
        i       led-line led-pad cols/row cmove
        led-pad i 1+ led-move
    -1 +Loop 1 led-max +!
    E
;

: INS ( n -- )              \ insert line from pad
    dup S RE ;

DECIMAL   0 VARIABLE NROW    NROW !     \ current row
          0 VARIABLE NCOL    NCOL !     \ current columns

: HOMEC   0 NROW ! 0 NCOL ! ;           \ cursor at home

: ADDRC   ( -- a )                      \ calc cursor addr
    LED-HOME @ NROW @ + LED-RAD NCOL @ + ;

: TO-SCR  ( row1 col1 -- col2 row2 )    \ translate xy
    0 + SWAP 2 + ;

: AT-XY   ( col row -- )                \ set print position
    22 EMITC  EMITC EMITC ;               \ using standard AT.

: HOME 0 0 AT-XY ;                      \ cursor at home

: BUZZ    7 EMIT ;                      \ sound BEL

: CURC! ( c -- )    \ store chr to current screen position

  ADDRC  C! ;

: CURC@ ( -- c )    \ fetch chr from current screen position
    ADDRC  C@ ;


: EDIT-FRAME ( -- )
    0 19 AT-XY
    INVV ."  row:" TRUV 8 SPACES INVV ."  col:" TRUV 5 SPACES
    INVV ."  hex:" TRUV 5 SPACES INVV ."  dec:" TRUV 6 SPACES
    INVV ."  chr:" TRUV
    CR INVV ."  pad:" TRUV PAD COUNT 55 MIN TYPE
    0 21 AT-XY  INVV ."  cmd:" TRUV
    CR ." W-RITE   B-ack    D-el     I-nsert   H-old"
    CR ." Q-uit    N-ext    S-hift   R-eplace  P-ut hex byte"
    COLS/ROW 10 -  0 AT-XY  INVV ."   LED   " TRUV ;


: EDIT-STAT ( -- )
    CURC@
    28 19 AT-XY  HEX DUP 3 .R  39 19 AT-XY  DECIMAL DUP 3 .R
    50 19 AT-XY  32 MAX EMIT
    18 19 AT-XY  NCOL @  3 .R
    05 19 AT-XY  NROW @  LED-HOME @ + 6 .R ;



: RULER COLS/ROW 10 DO
        ." |----.----"  10 +LOOP  ;

: PUTPAGE 0 0 AT-XY LED-FN COUNT TYPE CR RULER CR
          LED-DISPLAY RULER ;

: PREVP   1 led-home @ < if -16 led-home +! else buzz then ;

: NEXTP  HOMEC  16 led-home +! led-max @ led-home @ <
            if PREVP buzz then ;

: UPC    NROW @  0 > IF -1  NROW +!  ELSE  prevp putpage THEN ;

: DOWNC  NROW @ 15 < IF  1  NROW +!  ELSE  nextp putpage THEN ;

: LEFTC  NCOL @  0 > IF -1  ELSE  UPC    80 THEN NCOL +! ;

: RIGHTC NCOL @ 80 < IF  1  ELSE  DOWNC -80 THEN NCOL +! ;

: BYTE ( -- b ) \ accept two hex digit as a byte
    KEY DUP EMIT [ HEX ] 10 DIGIT DROP 4 LSHIFT
    KEY DUP EMIT         10 DIGIT DROP + ; DECIMAL
HEX

: DONEC             8F 26 +ORIGIN C!    \ reset cursor face
                    5F 28 +ORIGIN C! ;  \ reset cursor face

: INITC   CURC@ BL MAX 26 +ORIGIN C!    \ change cursor face
                    8F 28 +ORIGIN C! ;
DECIMAL

: REFRESH                           \ refresh current line
    NROW @ 0 TO-SCR AT-XY COLS/ROW  spaces
    NROW @ 0 TO-SCR AT-XY NROW @ LED-line COLS/ROW type ;

: CMD    ( c -- )   \ handle EDIT key options
    6 21 AT-XY DONEC KEY UPPER BL MAX DUP EMIT CASE
    [CHAR] P OF BYTE CURC! ENDOF  \ put a byte at cursor
    [CHAR] H OF NROW @ H   ENDOF  \ copy to PAD
    [CHAR] S OF NROW @ S   ENDOF  \ shift down one row
    [CHAR] R OF NROW @ RE  ENDOF  \ replace row from PAD
    [CHAR] I OF NROW @ INS ENDOF  \ insert row from PAD
    [CHAR] D OF NROW @ D   ENDOF  \ delete row + copy to PAD
    [CHAR] N OF NEXTP      ENDOF  \ next page
    [CHAR] B OF PREVP      ENDOF  \ prev page
    [CHAR] W OF LED-SAVE   ENDOF
    [CHAR] Q OF ."  ok" CR COLS/ROW 3 * SPACES
                0 21 AT-XY 30 EMITC 8 EMITC  QUIT ENDOF
    ENDCASE PUTPAGE EDIT-FRAME ;

: DELC    ( -- )    \ back-space
    NCOL @  0 > IF -1 NCOL +! THEN
    ADDRC DUP 1+ SWAP COLS/ROW NCOL @ - 1- CMOVE UPDATE
    BL NROW @ LINE COLS/ROW + 1- C! ;

: INSC    ( -- )    \ insert blank at cursor and shift the rest
    ADDRC DUP 1+      COLS/ROW NCOL @ - 1- CMOVE>
    BL ADDRC  C!  UPDATE ;

: CTRLC  ( c -- )   \ manage control keys
    CASE 08 OF LEFTC  ENDOF      09 OF RIGHTC ENDOF
         10 OF DOWNC  ENDOF      11 OF UPC    ENDOF
         12 OF DELC   REFRESH ENDOF
         13 OF DOWNC 0 NCOL ! ENDOF
         07 OF CMD            ENDOF
    ENDCASE ;

: LED-EDIT ( -- )
    30 EMITC LED-CHARSIZE EMITC  \ change chr width
    1 LED-HOME !
    CLS HOMEC PUTPAGE EDIT-FRAME
    BEGIN
        EDIT-STAT  INITC
        CURC@ NROW @ NCOL @ TO-SCR  2DUP AT-XY
        KEY  ?TERMINAL IF DROP 0 INSC   REFRESH THEN
        DUP BL < IF
            >R AT-XY EMIT R>  CTRLC
        ELSE
            CURC! AT-XY DROP CURC@ EMIT RIGHTC
        THEN
    AGAIN  \ quit using EDIT-key + Q
;

: LED
    LED-FILE
    LED-LOAD
    LED-EDIT
;

