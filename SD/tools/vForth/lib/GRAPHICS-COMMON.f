\
\ GRAPHICS-COMMON.f
\
\ Common core shared by every LAYERxx-GRAPHICS.f module.
\ It holds the colour constants, the mode selector (LAYER!), the
\ coordinate check, the vectored (DEFER) graphic primitives, the
\ LAYER: defining word and the layer-independent high level words
\ (DRAW-LINE, CIRCLE, PAINT, .INK ...).
\
\ End users do NOT load this file directly: they load one specific
\ mode with e.g.  NEEDS LAYER0-GRAPHICS  which pulls this file in.
\
\ N.B. in this library, x-coord is vertical (from top to bottom)
\      and y-coord is horizontal (from left to right).
\      Both coordinates start from zero.
\      (0,0) is the top-left addressable pixel
\
.( GRAPHICS-COMMON )

MARKER NO-GRAPHICS-COMMON       \ unload handle for the whole package

NEEDS VALUE
NEEDS TO
NEEDS +TO

NEEDS 2OVER
NEEDS FLIP
NEEDS INVERT

NEEDS IDE_MODE!
NEEDS IDE_MODE@

NEEDS DEFER
NEEDS IS

\ NEEDS guard word + FORGET anchor (patched to the unload word below)
: GRAPHICS-COMMON
    NOOP
;

BASE @

\ ____________________________________________________________________
\
\ Old-Standard Color definitions
DECIMAL
   00  CONSTANT  _BLACK
   01  CONSTANT  _BLUE
   02  CONSTANT  _RED
   03  CONSTANT  _MAGENTA
   04  CONSTANT  _GREEN
   05  CONSTANT  _CYAN
   06  CONSTANT  _YELLOW
   07  CONSTANT  _WHITE

\ old style attribute mask

   07  CONSTANT  COLOR-MASK
   01  CONSTANT  FLAG-MASK

\ ____________________________________________________________________
\
\ Graphic mode selector
\ ____________________________________________________________________
\
\ LAYER! ( n -- )
\ n can be one of the following (DECIMAL or HEX) value:
\
\ 00 : Layer 0 - Standard Spectrum (ULA) mode, 256 w x 192 h pixels, 8 colors
\      total (2 intensities), 32 x 24 cells, 2 colors per cell
\
\ 10 : Layer 1,0 - LoRes (Enhanced ULA) mode, 128 w x 96 h pixels, 256 colors
\      total, 1 colour per pixel
\
\ 11 : Layer 1,1 - Standard Res (Enhanced ULA) mode, 256 w x 192 h pixels,
\      256 colors total, 32 x 24 cells, 2 colors per cell
\
\ 12 : Layer 1,2 - Timex HiRes (Enhanced ULA) mode, 512 w x 192 h pixels,
\      256 colors total, only 2 colors on whole screen
\
\ 13 : Layer 1,3 - Timex HiColour (Enhanced ULA) mode, 256 w x 192 h pixels,
\      256 colors total, 32 x 192 cells, 2 colors per cell
\
\ 20 : Layer 2 - 256 w x 192 h pixels, 256 colors total, one colour per pixel
\ ____________________________________________________________________
\
\                L0   L11   L12   L13   L10    L2
\               ---   ---   ---   ---   ---   ---
\ Char-Size       8     4     8     4     4     4
\ V-RANGE       0C0   0C0   0C0   0C0   060   0C0
\ H-RANGE       100   100   200   100   080   100
\ PIXELADD       L0    L0   L12    L0   L10    L2
\ POINT          L0    L0    L0    L0    L1    L1
\ PLOT           L0    L0    L0    L0    L1    L2
\ XPLOT          L0    L0    L0    L0    L1    L2
\ PIXELATT       L0    L0    na   L13    na    L2
\ XY-RATIO        1     1    2/     1     1     1
\ EDGE            =     =     =     =    L1    L1
\ ____________________________________________________________________
\
\ map-table to be able to change graphics-mode ignoring what base currently is
CREATE L-HEX
    HEX     10 C, 11 C, 12 C, 13 C, 20 C,
CREATE L-DEC
    DECIMAL 10 C, 11 C, 12 C, 13 C, 20 C,

DECIMAL
: LAYER! ( n -- )
    >R
    L-HEX L-DEC 5
    R>
    (MAP)                       \ translate decimal numbers into hexadecimal
    16 /MOD                     \ split number in "sixteens" and units.
    FLIP +                      \ multiply sixteens by 256 and add units.
    IDE_MODE!                   \ call 01D5 api service via M_P3DOS
;

\ ____________________________________________________________________
\
.( COORD-CHECK ) \ check for pixel in range
\ ____________________________________________________________________
\
DECIMAL
256  VALUE  H-RANGE \ this is y-coord
192  VALUE  V-RANGE \ this is x-coord

\ depenging on current Graphic-Mode, determine if pixel is valid
: COORD-CHECK  ( x y -- x y f )
    2DUP H-RANGE U<
    SWAP V-RANGE U<
    AND
;

\ ____________________________________________________________________
\
\ Deferred graphic-primitive definitions.
\ These definitions are vectored depending on Graphic-Mode.
\ In some modes, they also fit on MMU7 the correct 8k page.
\ Each LAYERxx-GRAPHICS.f resolves these via the LAYER: defining word.
\ ____________________________________________________________________

\ current "color" used in subsequent operations
00 VALUE ATTRIB
00 VALUE P-ATTRIB \ address of ATTRIB field inside LAYERs definition

\ current "background color" when applicable
00 VALUE BACKGROUND 

DEFER INITIALIZE    ( -- ) 

\ depenging on current Graphic-Mode, determine address of a pixel
\ and fit MMU7 if needed
DEFER PIXELADD      ( x y -- a )

\ depenging on current Graphic-Mode, set attribute byte at address a
DEFER PIXELATT      ( b a -- )

\ depenging on current Graphic-Mode, plot a pixel using current ATTRIB
DEFER PLOT          ( x y -- )

\ In Layer 1,0 and Layer 2, invert the pixel value
\ In all other Graphic-Mode, invert or unset the pixel
DEFER XPLOT         ( x y -- )

\ depending on current Graphic-Mode, return the ATTRIB of a pixel
DEFER POINT         ( x y -- c )

\ to adjust Layer 1,2 aspect ratio for horizontal coordinate
DEFER XY-RATIO      ( y1 -- y2 )

\ edge rule
DEFER EDGE          ( b -- f )

\ ____________________________________________________________________

.( LAYER: )

\ LAYER: is a defining word that allows you creating a new definition
\ (LAYER0, LAYER10, LAYER11, LAYER12, LAYER13, LAYER20) that in one
\ shot changes all vectorized definitions behavior and also tries to
\ change current char-size.
HEX
: LAYER:
    <BUILDS
        ,           \    ATTRIB
        ,           \    BACKGROUND
        ,           \ is INITIALIZE
        ,           \ is EDGE
        ,           \ is XY-RATIO
        ,           \ is PIXELATT
        ,           \ is XPLOT
        ,           \ is PLOT
        ,           \ is POINT
        ,           \ is PIXELADD
        ,           \    V-RANGE
        ,           \    H-RANGE
        C,          \    color mask
        C,          \    flag mask
        C,          \    Layer number mode
        C,          \    char-size
    DOES>
        ATTRIB      P-ATTRIB !  \ save current attrib to previous mode default
        DUP     TO  P-ATTRIB    \ set pointer
        DUP  @  TO  ATTRIB      CELL+
        DUP  @  TO  BACKGROUND  CELL+
        DUP  @  IS  INITIALIZE  CELL+
        DUP  @  IS  EDGE        CELL+
        DUP  @  IS  XY-RATIO    CELL+
        DUP  @  IS  PIXELATT    CELL+
        DUP  @  IS  XPLOT       CELL+
        DUP  @  IS  PLOT        CELL+
        DUP  @  IS  POINT       CELL+
        DUP  @  IS  PIXELADD    CELL+
        DUP  @  TO  H-RANGE     CELL+
        DUP  @  TO  V-RANGE     CELL+
        DUP C@  TO  COLOR-MASK  1+
        DUP C@  TO  FLAG-MASK   1+
        DUP C@  LAYER!          1+
            C@  ?DUP IF 1E EMITC EMITC THEN  \ char-size
        INITIALIZE
        CR
;

\ ____________________________________________________________________
\
\ Graphic Words definitions
\ ____________________________________________________________________

DECIMAL
0   VALUE  CX                   \ x-distance between P1 and P2
0   VALUE  CY                   \ y-distance between P1 and P2
0   VALUE  SX                   \ x-direction from P1 to P2
0   VALUE  SY                   \ y-direction from P1 to P2
0   VALUE  DIFF                 \ error at each stage

\ ____________________________________________________________________
\
.( DRAW-LINE )
\
\ given two points (x1,y1) and (x2,y2) and ATTRIB c
\ draw a line using Bresenham's line algorithm
\ Coordinates out-of-range are ignored without error.
\
: DRAW-LINE  ( x2 y2 x1 y1 -- )
    ROT SWAP                    \ x2 x1 y2 y1
    \ determine SX, CX, SY, CY and DIFF
    2OVER - 1 OVER +- TO SX
    ABS               TO CX
    2DUP  - 1 OVER +- TO SY
    ABS NEGATE        TO CY
    CX CY +           TO DIFF
    SWAP -ROT                   \ x2 y2 x1 y1
    \ start drawing
    BEGIN
        \ plot current coordinate
        2DUP PLOT               \ x2 y2 x1 y1
        \ compute while condition
        2OVER 2OVER             \ x2 y2 x1 y1  x2 y2  x1 y1
        ROT -                   \ x2 y2 x1 y1  x2 x1  y1-y2
        -ROT -                  \ x2 y2 x1 y1  y1-y2  x2-x1
        OR                      \ x2 y2 x1 y1  f
        ?TERMINAL 0= AND
    \ stay in loop until final point is reached
    WHILE
        DIFF DUP + >R           \ take twice error
        R@ CY < NOT IF          \ e_xy+e_x > 0
            CY +TO DIFF         \ decrement error by CY
            SWAP SX + SWAP      \ change x coordinate
        THEN
        R> CX > NOT IF          \ e_xy+e_y < 0
            CX +TO DIFF         \ increment error by CX
            SY +
        THEN
    REPEAT
    2DROP 2DROP
;

\ ____________________________________________________________________
\
.( CIRCLE )
\

\ for each coordinate SX, SY draw all eight pixel around the circumference
\ using PLOT
\ https://www.geeksforgeeks.org/bresenhams-circle-drawing-algorithm/

: CIRCLE-EIGHT
    CX SX XY-RATIO +  CY SY  +  PLOT
    CX SX XY-RATIO -  CY SY  +  PLOT
    CX SX XY-RATIO +  CY SY  -  PLOT
    CX SX XY-RATIO -  CY SY  -  PLOT
    CX SY XY-RATIO +  CY SX  +  PLOT
    CX SY XY-RATIO -  CY SX  +  PLOT
    CX SY XY-RATIO +  CY SX  -  PLOT
    CX SY XY-RATIO -  CY SX  -  PLOT
;

: CIRCLE ( x y r -- )
    0 TO SX  TO SY  TO CY  TO CX
    SY IF
        3 SY 2* - TO DIFF   \ d := 3 - 2r
        CIRCLE-EIGHT
        BEGIN
            1 +TO SX
            DIFF 0< IF
                SX  2* 2*  6 + +TO DIFF   \ d += 4x + 6
            ELSE
                SX SY -  2* 2*  10 + +TO DIFF   \ d += 4(x-y) + 10
                -1 +TO SY
            THEN
            CIRCLE-EIGHT
        SY SX < UNTIL
    ELSE
        CX CY PLOT
    THEN
;

\ ____________________________________________________________________
\
.( PAINT )

\
HEX
: PAINT-HIT ( x y d -- )
    >R
    BEGIN
        2DUP PLOT
        R@ + 1FF AND
        2DUP POINT EDGE
    UNTIL
    R> DROP 2DROP
;

: PAINT-HIT2 ( x y -- )
    2DUP 1 PAINT-HIT
        -1 PAINT-HIT
;

: PAINT-HITX ( x y d -- )
    >R
    BEGIN
        SWAP R@ + 0FF AND SWAP
        2DUP POINT EDGE NOT
        ?TERMINAL 0= AND
    WHILE
        2DUP PAINT-HIT2
    REPEAT
    R> DROP 2DROP
;

: PAINT  ( x y -- )
    2DUP PAINT-HIT2
    2DUP 1 PAINT-HITX
        -1 PAINT-HITX
;

\ ____________________________________________________________________
\
\ if passed  f  is zero, then it forgets all this library
\ Typical usage:  0 GRAPHICS-COMMON
HEX
: FGRAPHICS-COMMON ( f -- )
    NOT IF
        12 LAYER!                \ restore Layer 1,2 (vForth default boot mode)
        1E EMITC 8 EMITC         \ restore normal 8x8 char size
        NO-GRAPHICS-COMMON       \ forget the whole package
    THEN
;

\ this allows FORGET GRAPHICS-COMMON  or  0 GRAPHICS-COMMON to remove all
' FGRAPHICS-COMMON ' GRAPHICS-COMMON >BODY !

\ ____________________________________________________________________
\
\ (COLOR)
\ this definition needs 4 params
\  b :  attribute value (in range 0-7)
\  c :  ctrl character between 16 and 21
\  m :  bitmask applied to b to avoid Basic's errors.
\  s :  number of bit to be shifted
: (COLOR)       ( b c m s -- )
  >R                \ b c m             R: s
  ROT OVER AND      \ c m (b&m)         \ masked value, keep mask
  SWAP R@ LSHIFT    \ c (b&m) (m<<s)    \ field position
  INVERT ATTRIB AND \ c (b&m) cleared   \ zero ONLY the field bits in ATTRIB
  OVER R> LSHIFT OR \ c (b&m) ATTRIB'   \ drop (b&m)<<s into the cleared field
  TO ATTRIB         \ c (b&m)
  SWAP EMITC EMITC  \                   \ emit ctrl then masked value
;

DECIMAL

\         ctrl  mask       shift
\ _______________________________________
\
\ Attribute-mode implementations (3-bit ink/paper fields in one byte).
\ These are the historical .INK/.PAPER/... bodies, used by Layer 0/1,1/1,3/1,2.
: (ATTR.INK)      16  COLOR-MASK   0   (COLOR) ;
: (ATTR.PAPER)    17  COLOR-MASK   3   (COLOR) ;
: (ATTR.FLASH)    18  FLAG-MASK    6   (COLOR) ;
: (ATTR.BRIGHT)   19  FLAG-MASK    7   (COLOR) ;
: (ATTR.INVERSE)  20  FLAG-MASK    8   (COLOR) ;
: (ATTR.OVER)     21  FLAG-MASK    8   (COLOR) ;

\ Full-byte (one-colour-per-pixel) implementations, used by Layer 2 and 1,0.
\ Here ATTRIB is a whole 8-bit colour: INK sets it directly, PAPER sets the
\ BACKGROUND colour, and FLASH/BRIGHT/INVERSE/OVER have no meaning.
: (RGB.INK)    ( b -- )  DUP TO ATTRIB      16 EMITC EMITC ;
: (RGB.PAPER)  ( b -- )  DUP TO BACKGROUND  17 EMITC EMITC ;
: (RGB.NULL)   ( b -- )  DROP ;

\ The colour words are vectored: each LAYERxx INITIALIZE installs the proper
\ profile so that interactive use (e.g.  216 .INK ) matches the active layer.
DEFER .INK   DEFER .PAPER   DEFER .FLASH
DEFER .BRIGHT   DEFER .INVERSE   DEFER .OVER

: ATTR-COLORS   ( -- )
    ['] (ATTR.INK)     IS .INK     ['] (ATTR.PAPER)   IS .PAPER
    ['] (ATTR.FLASH)   IS .FLASH   ['] (ATTR.BRIGHT)  IS .BRIGHT
    ['] (ATTR.INVERSE) IS .INVERSE ['] (ATTR.OVER)    IS .OVER ;

: RGB-COLORS    ( -- )
    ['] (RGB.INK)   IS .INK     ['] (RGB.PAPER) IS .PAPER
    ['] (RGB.NULL)  IS .FLASH   ['] (RGB.NULL)  IS .BRIGHT
    ['] (RGB.NULL)  IS .INVERSE ['] (RGB.NULL)  IS .OVER ;

ATTR-COLORS                     \ sensible default before any layer activates

BASE !
