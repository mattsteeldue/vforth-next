\
\ KEYBOARD.f
\
\ Direct keyboard-matrix scanning, the classic ZX Spectrum way.
\
\ The 40 keys are read through port $FE: the HIGH byte of the address
\ bus selects one of 8 half-rows, the low 5 bits returned by P@ report
\ the 5 keys of that row (a 0 bit = key pressed, active low).  Each key
\ gets a progressive index 0..39, row by row:
\
\   row  port    bit0   bit1  bit2  bit3  bit4    indices
\   $FE  $FEFE   CAPS   Z     X     C     V        0.. 4
\   $FD  $FDFE   A      S     D     F     G        5.. 9
\   $FB  $FBFE   Q      W     E     R     T       10..14
\   $F7  $F7FE   1      2     3     4     5       15..19
\   $EF  $EFFE   0      9     8     7     6       20..24
\   $DF  $DFFE   P      O     I     U     Y       25..29
\   $BF  $BFFE   ENTER  L     K     J     H       30..34
\   $7F  $7FFE   SPACE  SYMB  M     N     B       35..39
\
\ Index 0 (CAPS SHIFT) and 36 (SYMBOL SHIFT) are the two shift keys.
\
\ Two ways to use it, both shown below:
\
\ 1) Index scan (menus, "press any key"):
\      KEY-SCAN          \ -- n (0..39) or NO-KEY (255) if none
\      GET-KEY DUP .KEY  \ wait a debounced press, print its label
\
\ 2) Redefine-keys for a game (fast per-frame polling).
\    Capture the chosen key as a (port mask) pair and store it; then
\    in the game loop test it with a single port read:
\
\      VARIABLE UP-PORT   VARIABLE UP-MASK
\      ." Press UP : "  GET-KEY KEY#>RM   ( port mask )
\      UP-MASK !  UP-PORT !
\      ...
\      UP-PORT @ UP-MASK @ KEY-PRESSED?  IF  ( move up )  THEN
\
.( KEYBOARD )

\ Half-row select bytes (the namesake table loaded by NEEDS KEYBOARD).
CREATE KEYBOARD  ( -- a )
    $FE C,  $FD C,  $FB C,  $F7 C,  $EF C,  $DF C,  $BF C,  $7F C,
\
#255 CONSTANT NO-KEY            \ KEY-SCAN result when nothing is pressed

\ index -> 16-bit port that selects its half-row ( e.g. 12 -> $FBFE )
: KEY#>PORT  ( n -- port )
    #5 /  KEYBOARD +  C@  8 LSHIFT  $FE + ;

\ index -> single-bit column mask ( column 0..4 -> $01..$10 )
: KEY#>MASK  ( n -- mask )
    #5 MOD  #1 SWAP LSHIFT ;

\ index -> the (port mask) pair used for fast polling / storage
: KEY#>RM    ( n -- port mask )
    DUP KEY#>PORT  SWAP KEY#>MASK ;

\ true if the key described by a stored (port mask) pair is down now
: KEY-PRESSED?  ( port mask -- f )
    SWAP P@  AND  0= ;          \ active low: pressed -> bit 0 -> 0= true

\ true if key index n is down now
: KEY-DOWN?  ( n -- f )
    KEY#>RM  KEY-PRESSED? ;

\ scan all 40 keys, return the lowest pressed index, or NO-KEY if none
: KEY-SCAN  ( -- n )
    0
    BEGIN  DUP #40 <  WHILE
        DUP KEY-DOWN?  IF  EXIT  THEN
        1+
    REPEAT
    DROP  NO-KEY ;

\ block until the whole keyboard is released (debounce helper)
: WAIT-NOKEY   ( -- )
    BEGIN  KEY-SCAN  NO-KEY =  UNTIL ;

\ block until some key is pressed, return its index
: WAIT-NEWKEY  ( -- n )
    BEGIN  KEY-SCAN  DUP NO-KEY =  WHILE  DROP  REPEAT ;

\ debounced read: wait for release, then for a fresh press
: GET-KEY      ( -- n )
    WAIT-NOKEY  WAIT-NEWKEY ;

\ label of each key, indexed 0..39 (special keys flagged by code)
CREATE KEY-NAMES  ( -- a )
    $00 C,  CHAR Z C,  CHAR X C,  CHAR C C,  CHAR V C,   \  0.. 4
    CHAR A C,  CHAR S C,  CHAR D C,  CHAR F C,  CHAR G C, \  5.. 9
    CHAR Q C,  CHAR W C,  CHAR E C,  CHAR R C,  CHAR T C, \ 10..14
    CHAR 1 C,  CHAR 2 C,  CHAR 3 C,  CHAR 4 C,  CHAR 5 C, \ 15..19
    CHAR 0 C,  CHAR 9 C,  CHAR 8 C,  CHAR 7 C,  CHAR 6 C, \ 20..24
    CHAR P C,  CHAR O C,  CHAR I C,  CHAR U C,  CHAR Y C, \ 25..29
    $0D C,  CHAR L C,  CHAR K C,  CHAR J C,  CHAR H C,    \ 30..34
    $20 C,  $01 C,  CHAR M C,  CHAR N C,  CHAR B C,       \ 35..39

\ print the label of key index n
: .KEY  ( n -- )
    KEY-NAMES +  C@                  ( c )
    DUP $00 =  IF  DROP  ." CAPS"   EXIT  THEN
    DUP $01 =  IF  DROP  ." SYMB"   EXIT  THEN
    DUP $0D =  IF  DROP  ." ENTER"  EXIT  THEN
    DUP $20 =  IF  DROP  ." SPACE"  EXIT  THEN
    EMIT ;

