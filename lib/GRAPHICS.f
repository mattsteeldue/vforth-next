\
\ graphics.f
\
.( GRAPHICS )
\
\

NEEDS VALUE  
NEEDS TO  
NEEDS +TO 

NEEDS 2OVER 
NEEDS FLIP 
NEEDS SPLIT

NEEDS IDE_MODE!
NEEDS IDE_MODE@

NEEDS DEFER 
NEEDS IS
NEEDS CHAR+

BASE @

\ for easy development
MARKER GRAPHICS

\ current "color" used in subsequent operations
\
0   VALUE  ATTRIB

\ ____________________________________________________________________
\
\ Graphic mode selector
\ ____________________________________________________________________
\
\ LAYER! ( n -- )
\
\ n can be one of the following (DECIMAL or HEX) value:
\
\ 00 : Layer 0 - Standard Spectrum (ULA) mode, 256 w x 192 h pixels, 8 colours
\      total (2 intensities), 32 x 24 cells, 2 colours per cell
\ 10 : Layer 1 - LoRes (Enhanced ULA) mode, 128 w x 96 h pixels, 256 colours
\      total, 1 colour per pixel
\ 11 : Layer 1,1 – Standard Res (Enhanced ULA) mode, 256 w x 192 h pixels,
\      256 colours total, 32 x 24 cells, 2 colours per cell
\ 12 : Layer 1,2 – Timex HiRes (Enhanced ULA) mode, 512 w x 192 h pixels,
\      256 colours total, only 2 colours on whole screen
\ 13 : Layer 1,3 – Timex HiColour (Enhanced ULA) mode, 256 w x 192 h pixels,
\      256 colours total, 32 x 192 cells, 2 colours per cell
\ 20 : Layer 2 – 256 w x 192 h pixels, 256 colours total, one colour per pixel
\ ____________________________________________________________________


CREATE L-HEX 
    HEX     10 C, 11 C, 12 C, 13 C, 20 C,
CREATE L-DEC
    DECIMAL 10 C, 11 C, 12 C, 13 C, 20 C,

HEX
: LAYER! ( n -- )
    >R
    L-HEX L-DEC 5
    R> (MAP)                    \ translate decimal numbers into hexadecimal
    10 /MOD                     \ split number in tens and units.
    FLIP +                      \ multiply tens by 256 and add units.
    IDE_MODE!                   \ call 01D5 api service via M_P3DOS
;

\ ____________________________________________________________________
\
\ Deferred graphic-primitive definitions. 
\ These definitions are vectored depending on Graphic-Mode.
\ In some modes, they also fit on MMU7 the correct 8k page.
\ ____________________________________________________________________

\ depenging on current Graphic-Mode, determine address of a pixel
DEFER PIXELADD      ( x y -- a )

\ depenging on current Graphic-Mode, set attribute byte
DEFER PIXELATT      ( b a -- )

\ depenging on current Graphic-Mode, determine if pixel is valid
DEFER PIXELCHECK    ( x y -- x y f )

\ depenging on current Graphic-Mode, plot a pixel using current ATTRIB
DEFER PLOT          ( x y -- )

\ In Layer 1,0 and Layer 2, set pixel to transparent ATTRIB
\ In all other Graphic-Mode, reset (unset) the pixel
DEFER UNPLOT        ( x y -- )

\ depending on current Graphic-Mode, return the ATTRIB of a pixel
DEFER POINT         ( x y -- c )

\ to adjust Layer 1,2 circle drawings
DEFER XY-RATIO

\ ____________________________________________________________________
\
.( PIXELCHECK ) \ check for pixel in range 
\ ____________________________________________________________________
\
\ Layer 0
\ This is valid for Layer 1,1  Layer 1,3 and Layer 2 modes too
DECIMAL
: L0-CHECK  ( x y -- x y f )
    2DUP 256 U<                 \ x  y<256
    SWAP 192 U<                 \ y<256   x<192
    AND                         \ y<256 & x<192 
;

\ ____________________________________________________________________
\
\ Layer 1,0
DECIMAL
: L10-CHECK  ( x y -- x y f )
    2DUP 128 U<                 \ x y<128
    SWAP  96 U<                 \ y<128   x<96
    AND                         \ y<128 & x<96
;

\ ____________________________________________________________________
\
\ Layer 1,2 - check for pixel in range 
DECIMAL
: L12-CHECK  ( x y -- x y f )
    2DUP 512 U<                 \ x  y<512
    SWAP 192 U<                 \ y<512   x<192
    AND                         \ y<512 & x<192 
;


\ ____________________________________________________________________
\
.( PIXELADD ) \ deterimine pixel address and fit MMU7 if needed
\ ____________________________________________________________________
\
\ Layer 0 PIXELADD
\ This word exploits the new "pixelad" Z80-N op-code 
\ This is still valid for Layer 1,1  Layer 1,3  modes too
HEX
CODE L0-PIXELADD   ( x y -- a )
    D1 C,           \ pop   de  ; y
    E1 C,           \ pop   hl  ; x
    55 C,           \ ld    d,l ; de is yx
    ED C, 94 C,     \ pixelad
    E5 C,           \ push  hl
    DD C, E9 C,     \ jp   (ix)
    SMUDGE

\ ____________________________________________________________________
\
\ Layer 0 PIXELATT
\ convert Display File address into Attribute address   
CODE L0-PIXELATT    ( b a -- )
    E1 C,           \ pop   hl  ; display file address
    7C C,           \ ld    a, h
    0F C,           \ rrca
    0F C,           \ rrca
    0F C,           \ rrca
    E6 C, 03 C,     \ and   3
    F6 C, 58 C,     \ or    $58    
    67 C,           \ ld    h, a
    D1 C,           \ pop   de
    73 C,           \ ld   (hl), e
    DD C, E9 C,     \ jp   (ix)
    SMUDGE
   
\ ____________________________________________________________________
\
\ Layer 1,0  PIXELADD
HEX
: L10-PIXELADD ( x y -- a )
    SWAP DUP 
    30 < IF 
        0 
    ELSE
        30 - 
        1 
    THEN
    0A + MMU7!                  \ fit at MMU7 page 0A or page 0B
    FLIP 2/ +
    E000 OR                     \ turn into offset from E000h
;

\ ____________________________________________________________________
\
\ Layer 1,2  PIXELADD
HEX
: L12-PIXELADD ( x y -- a )
    DUP 3 RSHIFT 1 AND
    0A + MMU7!
    2/
    L0-PIXELADD
    E000 OR                     \ turn into offset from E000h
;

\ ____________________________________________________________________
\
\ Layer 1,3 PIXELATT
\ convert Display File address into Attribute address   
\ it just fit the correct 8k page on MMU7.
HEX
: L13-PIXELATT   ( b a -- )
    0B MMU7!
    E000 OR C!
;
   

\ ____________________________________________________________________
\
\ Layer 2 PIXELADD
\
HEX 12 REG@ 2*
CONSTANT  L2-RAM-PAGE           \ keeps Layer 2 Active RAM Page

\ given x y coordinates (x: vertical, y: horizontal)
\ fit the correct 8K page at MMU7 and return offset a within it.
HEX
: L2-PIXELADD ( x y -- a )
    OVER FF AND                 \ take x mod 256
    5 RSHIFT                    \ divide by 32
    L2-RAM-PAGE + MMU7!         \ fit correct page at MMU7
    SWAP 1F AND                 \ take x mod 32
    FLIP                        \ fast shift 8 bits
    + E000 OR                   \ turn into offset from E000h
;
   
\ ____________________________________________________________________
\
.( POINT ) \ fetch color/status of pixel x,y 
\ ____________________________________________________________________
\
\ This is valid for Layer 1,0 and Layer 2 mode
: L2-POINT  ( x y -- c )
    PIXELADD C@
;

\ ____________________________________________________________________
\ 
\ This is valid for Layer 0  Layer 1,1  Layer 1,2 and Layer 1,3 modes
HEX
: L0-POINT  ( x y -- c )
    TUCK                        \ y x y
    PIXELADD C@                 \ y b
    SWAP 7 AND                  \ b y mod 7
    LSHIFT 80 AND               \ f
;

\ ____________________________________________________________________
\
.( PLOT ) \ set pixel x,y to color/status kept by ATTRIB

\ ____________________________________________________________________
\
\ This is valid for Layer 0  Layer 1,1  Layer 1,2 and Layer 1,3 modes
\ PIXELCHECK, PIXELADD and PIXELATT are vectorized via DEFER..IS
HEX             
: L0-PLOT       ( x y -- )
    PIXELCHECK                  \ x y f
    IF                          \ x y
        TUCK                    \ y x y
        PIXELADD >R             \ y
        7 AND                   \ n 
        80 SWAP RSHIFT          \ 80>>n
        R@ C@ OR                \ 80>>n|b
        R@ C!
        ATTRIB R> PIXELATT
    ELSE
        2DROP
    THEN
;

\ ____________________________________________________________________
\
\ Layer 2 PLOT
\ This is valid for Layer 1,0 mode.
\ PIXELCHECK and PIXELADD are vectorized via DEFER..IS
DECIMAL
: L2-PLOT  ( x y -- )
    PIXELCHECK               
    IF
        PIXELADD 
        ATTRIB SWAP C!
    ELSE
        2DROP 
    THEN
;

\ ____________________________________________________________________
\
.( UNPLOT ) \ unset pixel x,y if Graphic-Mode permits
\ ____________________________________________________________________
\
\ This is valid for Layer 0  Layer 1,1  Layer 1,2 and Layer 1,3 mode
HEX             
: L0-UNPLOT       ( x y -- )
    PIXELCHECK                  \ x y f
    IF
        TUCK                    \ y x y
        PIXELADD >R             \ y
        7 AND                   \ n 
        7F SWAP RSHIFT      
        R@ C@ AND
        R> C!
    ELSE
        2DROP
    THEN
;

\ ____________________________________________________________________

\ IS-LAYER is a defining word that allows you creating new definitions
\ that massively change vectorized definitions behavior
\ and they also try to change char-size.
HEX
: IS-LAYER
    <BUILDS
        ,           \ XY-RATIO
        ,           \ PIXELATT  
        ,           \ UNPLOT    
        ,           \ PLOT      
        ,           \ POINT     
        ,           \ PIXELADD  
        ,           \ PIXELCHECK
        C,          \ Layer number mode
        C,          \ char-size
    DOES>
        DUP  @  IS  XY-RATIO    CELL+
        DUP  @  IS  PIXELATT    CELL+
        DUP  @  IS  UNPLOT      CELL+
        DUP  @  IS  PLOT        CELL+
        DUP  @  IS  POINT       CELL+
        DUP  @  IS  PIXELADD    CELL+
        DUP  @  IS  PIXELCHECK  CELL+
        DUP C@  LAYER!          CHAR+
            C@  ?DUP IF 1E EMITC EMITC THEN  \ char-size
;        

\ ____________________________________________________________________

HEX
.( LAYER0 )
    00  00          \ 00 char-size means no effect.
    ' L0-CHECK      \ PIXELCHECK
    ' L0-PIXELADD   \ PIXELADD    
    ' L0-POINT      \ POINT       
    ' L0-PLOT       \ PLOT        
    ' L0-UNPLOT     \ UNPLOT      
    ' L0-PIXELATT   \ PIXELATT      
    ' NOOP          \ XY-RATIO  
        IS-LAYER LAYER0  

\ ____________________________________________________________________

.( LAYER10 )
    04  10          \ 04 char-size to allow 64 chars per row
    ' L10-CHECK     \ PIXELCHECK
    ' L10-PIXELADD  \ PIXELADD  
    ' L2-POINT      \ POINT     
    ' L2-PLOT       \ PLOT      
    ' NOOP          \ UNPLOT    
    ' 2DROP         \ PIXELATT (has no meaning for Layer 1,0)
    ' NOOP          \ XY-RATIO  
        IS-LAYER LAYER10 



\ ____________________________________________________________________

.( LAYER11 )
    04  11          \ 04 char-size to allow 64 chars per row
    ' L0-CHECK      \ PIXELCHECK  
    ' L0-PIXELADD   \ PIXELADD    
    ' L0-POINT      \ POINT       
    ' L0-PLOT       \ PLOT        
    ' L0-UNPLOT     \ UNPLOT      
    ' L0-PIXELATT   \ PIXELATT      
    ' NOOP          \ XY-RATIO  
        IS-LAYER LAYER11 


\ ____________________________________________________________________

.( LAYER12 )
    08  12          \ 08 char-size is normal 64 chars per row
    ' L12-CHECK     \ PIXELCHECK
    ' L12-PIXELADD  \ PIXELADD  
    ' L0-POINT      \ POINT     
    ' L0-PLOT       \ PLOT      
    ' L0-UNPLOT     \ UNPLOT    
    ' 2DROP         \ PIXELATT  
    ' 2/            \ XY-RATIO  
        IS-LAYER LAYER12 

\ ____________________________________________________________________

.( LAYER13 )
    04  13          \ 04 char-size to allow 64 chars per row
    ' L0-CHECK      \ PIXELCHECK
    ' L0-PIXELADD   \ PIXELADD  
    ' L0-POINT      \ POINT     
    ' L0-PLOT       \ PLOT      
    ' L0-UNPLOT     \ UNPLOT    
    ' L13-PIXELATT  \ PIXELATT  
    ' NOOP          \ XY-RATIO  
        IS-LAYER LAYER13 

\ ____________________________________________________________________

.( LAYER2 )
    04  20          \ 04 char-size to allow 64 chars per row
    ' L0-CHECK      \ PIXELCHECK
    ' L2-PIXELADD   \ PIXELADD  
    ' L2-POINT      \ POINT     
    ' L2-PLOT       \ PLOT      
    ' NOOP          \ UNPLOT    
    ' 2DROP         \ PIXELATT (has no meaning for Layer 2)
    ' NOOP          \ XY-RATIO  
        IS-LAYER LAYER2  

\ ____________________________________________________________________
\
\ Immediately setup current mode LAYER 1,2.
\
LAYER12

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
    \ determine sx, CX, sy, CY and er
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
        ?TERMINAL IF 2DROP 2DROP EXIT THEN \ useful while debugging
    REPEAT
    2DROP 2DROP
;

\ ____________________________________________________________________
\
.( CIRCLE )
\

\ for each coordinate SX, SY draw all eight pixel around the circumference
\ using PLOT 
: CIRCLE-PART
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
        CIRCLE-PART
        BEGIN
            1 +TO SX
            DIFF 0< IF
                SX  2* 2*  6 + +TO DIFF   \ d += 4x + 6
            ELSE
                -1 +TO SY
                SX SY -  2* 2*  10 + +TO DIFF   \ d += 4(x-y) + 10
            THEN
            CIRCLE-PART
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
        ?TERMINAL IF QUIT THEN
        2DUP PLOT
        R@ + 1FF AND
        2DUP POINT
    UNTIL
    R> DROP 2DROP
;
: PAINT-HIT2 ( x y -- )
    DUP 1 PAINT-HIT 
       -1 PAINT-HIT
;
: PAINT-HITX ( x y d -- )
    >R
    BEGIN
        SWAP R@ + 0FF AND SWAP
        2DUP POINT 0=
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
    
BASE !


