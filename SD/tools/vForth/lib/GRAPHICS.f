\
\ graphics.f
\
.( GRAPHICS )
\
\ N.B. in this library, x-coord is vertical (from top to bottom)
\      and y-coord is horizontal (from left to right).
\      Both coordinates start from zero.
\      (0,0) is the top-left addressable pixel 

MARKER NO-GRAPHICS      \ for easy development

NEEDS VALUE  
NEEDS TO  
NEEDS +TO 

NEEDS 2OVER 
NEEDS FLIP 

NEEDS IDE_MODE!
NEEDS IDE_MODE@

NEEDS DEFER 
NEEDS IS

: GRAPHICS 
    NOOP
;

BASE @

\ ____________________________________________________________________
\
\ Old-Standard Color definitions

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
\ Default attrib values

    _BLUE   3 LSHIFT  _WHITE  +  VALUE  L0-ATTRIB 
    _WHITE  3 LSHIFT  _BLACK  +  VALUE  L10-ATTRIB 
    _BLUE   3 LSHIFT  _WHITE  +  VALUE  L11-ATTRIB 
    00                           VALUE  L12-ATTRIB 
    _WHITE  3 LSHIFT  _BLACK  +  VALUE  L13-ATTRIB 
    HEX 0D8                      VALUE  L20-ATTRIB 
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
\ ____________________________________________________________________

\ current "color" used in subsequent operations
00 VALUE ATTRIB
00 VALUE P-ATTRIB \ address of ATTRIB field inside LAYERs definition

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
\
.( PIXELADD ) \ deterimine pixel address and fit MMU7 if needed
\ ____________________________________________________________________
\
\ Layer 0 PIXELADD
\ This word exploits the new "pixelad" Z80-N op-code 
\ This is valid for Layer 0  Layer 1,1  and  Layer 1,3 
HEX
CODE L0-PIXELADD   ( x y -- a )
    D9 C,           \ exx
    D1 C,           \ pop   de  ; y
    E1 C,           \ pop   hl  ; x
    55 C,           \ ld    d,l ; de is vert,horiz
    ED C, 94 C,     \ pixelad 
    E5 C,           \ push  hl
    D9 C,           \ exx
    DD C, E9 C,     \ jp   (ix)
    SMUDGE
   
\ ____________________________________________________________________
\
\ Layer 1,0  PIXELADD
\
HEX
CODE L10-PIXELADD ( x y -- a ) 
    D9 C,               \ exx
    E1 C,               \ pop  hl|  \ horizontal y-coord, only L is significant
    D1 C,               \ pop  de|  \ vertical x-coord, only E is significant
    7B C,               \ ld   a'| e| 
    D6 C, 30 C,         \ suba hex 30 n,
    30 C, 02 C,         \ jrf  nc'| +2 d,
    C6 C, 30 C,         \ adda hex 30 n,
    5F C,               \ ld e'| a|
    3E C, 0B C,         \ ldn  a'| hex 0B n,
    DE C, 00 C,         \ sbcn 0 n,
    ED C, 92 C, 57 C,   \ nextrega hex 57 p,
    CB C, 25 C,         \ sla   l|
    CB C, 3B C,         \ srl   e|
    CB C, 1D C,         \ rr    l|
    3E C, E0 C,         \ ldn  a'| hex E0 n,
    B3 C,               \ ora  e'|
    67 C,               \ ld   h'| a|
    E5 C,               \ push hl|
    D9 C,               \ exx
    DD C, E9 C,         \ next
    SMUDGE              \ c; 

\ ____________________________________________________________________
\
\ Layer 1,2  PIXELADD
\ fit the correct 8k page on MMU7 and leaves the address from $E000
HEX
CODE L12-PIXELADD   ( x y -- a )
    D9 C,               \ exx
    D1 C,               \ pop   de      ; y
    E1 C,               \ pop   hl      ; x
    CB C, 3A C,         \ srl   d   
    CB C, 1B C,         \ rr    e       ; half y
    7B C,               \ ld   a'| e|   
    0F C,               \ rrca
    0F C,               \ rrca
    0F C,               \ rrca          ; carry has bit 3
    3E C, 0A C,         \ ldn  a'| hex 0A n,
    CE C, 00 C,         \ adcn 0 n,
    ED C, 92 C, 57 C,   \ nextrega hex 57 p,
    55 C,               \ ld    d,l     ; de is vert,horiz
    ED C, 94 C,         \ pixelad
    3E C, E0 C,         \ ldn  a'| hex E0 n,
    B4 C,               \ ora  h|
    67 C,               \ ld   h'| a|
    E5 C,               \ push  hl
    D9 C,               \ exx
    DD C, E9 C,         \ jp   (ix)
    SMUDGE

\ ____________________________________________________________________
\
\ Layer 2 PIXELADD
\
HEX 12 REG@ 2*
CONSTANT  L2-RAM-PAGE           \ keeps Layer 2 Active RAM Page
\ this operation is done only once at compile time, just to save time
\ and setup MMU7! accordingly
CODE L2-PIXELADD ( x y -- a ) 
    HEX
    D9 C,             \ exx
    E1 C,             \ pop  hl|    \ horizontal y-coord, only L is significant
    D1 C,             \ pop  de|    \ vertical x-coord, only E is significant
    7B C,             \ ld   a'| e| \ calc which 8K page must be fitted in MMU7
    07 C,             \ rlca
    07 C,             \ rlca
    07 C,             \ rlca  
    E6 C, 07 C,       \ andn 7  n,
    C6 C, L2-RAM-PAGE C, \ addn L2-RAM-PAGE n,    \ usually 18 
    ED C, 92 C, 57 C, \ nextrega decimal 87 p, 
    3E C, E0 C,       \ ldn  a'| E0   n,  
    B3 C,             \ ora  e|
    67 C,             \ ld   h'| a|
    E5 C,             \ push hl|
    D9 C,             \ exx
    DD C, E9 C,       \ next
    SMUDGE            \ c; 
   
\ ____________________________________________________________________
\
.( PIXELATT ) \ set pixel attribute
\ ____________________________________________________________________
\
\ Layer 0 PIXELATT
\ convert Display File address into Attribute address   
\ and put byte  b  to such an address.
HEX
CODE L0-PIXELATT    ( b a -- )
    D9 C,           \ exx
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
    D9 C,           \ exx
    DD C, E9 C,     \ jp   (ix)
    SMUDGE

\ ____________________________________________________________________
\
\ Layer 1,3 PIXELATT
\ convert Display File address into Attribute address   
\ it fits the correct 8k page on MMU7 and leaves the address from $E000
HEX
: L13-PIXELATT   ( b a -- )
    0B MMU7!
    E000 OR C!
;
   
\ ____________________________________________________________________
\
.( POINT ) \ fetch color/status of pixel x,y 
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
\ This is valid for Layer 1,0 and Layer 2 mode
: L1-POINT  ( x y -- c )
    PIXELADD C@
;

\ ____________________________________________________________________
\
.( EDGE ) \ edge decision
\ ____________________________________________________________________
\
\ This is valid for Layer 0  Layer 1,1  Layer 1,2 and Layer 1,3 modes
HEX
: L0-EDGE  ( b -- f )
    0= NOT
;

\ This is valid for Layer 1,0 and Layer 2 mode
: L1-EDGE  ( b -- f )
    ATTRIB =
;
 
\ ____________________________________________________________________
\
.( PLOT ) \ set pixel x,y to color/status kept by ATTRIB

\
\ ____________________________________________________________________
\
\ pixel operator OR or XOR
DEFER PLOTOP
DEFER XPLOTOP

CODE L0-SET   ( b1 b2 -- b3 )
    HEX
    E1 C,               \ pop   hl    ; b2 byte
    7D C,               \ ld   a'| l| 
    E1 C,               \ pop   hl    ; b1 pattern
    B5 C,               \ ora  l'|
    6F C,               \ ld   l'| a|
    E5 C,               \ push  hl
    DD C, E9 C,         \ jp   (ix)
    SMUDGE

CODE L0-XOR   ( b1 b2 -- b3 )
    HEX
    E1 C,               \ pop   hl    ; byte
    7D C,               \ ld   a'| l| 
    E1 C,               \ pop   hl    ; pattern
    AD C,               \ xora l'|
    6F C,               \ ld   l'| a|
    E5 C,               \ push  hl
    DD C, E9 C,         \ jp   (ix)
    SMUDGE

CODE L0-RES   ( b1 b2 -- b3 )
    HEX
    D9 C,               \ exx
    D1 C,               \ pop   de    ; byte
    E1 C,               \ pop   hl    ; pattern
    7D C,               \ ld   a'| l| 
    2F C,               \ cpl
    A3 C,               \ anda e'|
    6F C,               \ ld   l'| a|
    E5 C,               \ push  hl
    D9 C,               \ exx
    DD C, E9 C,         \ jp   (ix)
    SMUDGE

' L0-SET IS PLOTOP       \ usually OR to "set" the pixel 
' L0-XOR IS XPLOTOP      \ usually OR to "xor" the pixel 

\ ____________________________________________________________________
\
\ This is valid for Layer 0  Layer 1,1  Layer 1,2 and Layer 1,3 modes
\ COORD-CHECK, PIXELADD and PIXELATT are vectorized via DEFER..IS
HEX             
: L0-PLOT       ( x y -- )
    COORD-CHECK                 \ x y f
    IF                          \ x y
        TUCK                    \ y x y
        PIXELADD >R             \ y         R: a
        7 AND                   \ n 
        80 SWAP RSHIFT          \ 80>>n
        R@ C@                   \ b  80>>n
        PLOTOP
        R@ C!                   \ 
        ATTRIB R>               \ b a       R:
        PIXELATT                \ 
    ELSE
        2DROP
    THEN
;

\ ____________________________________________________________________
\
\ Layer 1 PLOT
\ This is valid for Layer 1,0 mode.
\ COORD-CHECK and PIXELADD are vectorized via DEFER..IS
\ DECIMAL
: L1-PLOT  ( x y -- )
    COORD-CHECK               
    IF
        PIXELADD 
        ATTRIB SWAP C!
    ELSE
        2DROP 
    THEN
;

\ ____________________________________________________________________
\
\ Layer 2 PLOT
\ ported in machine code for fast execution
\ no coord-checking is done.
CODE L2-PLOT  ( x y -- )
    HEX
    D9 C,             \ exx
    E1 C,             \ pop  hl|    \ horizontal y-coord, only L is significant
    D1 C,             \ pop  de|    \ vertical x-coord, only E is significant
    7B C,             \ ld   a'| e| \ calc which 8K page must be fitted in MMU7
    07 C,             \ rlca
    07 C,             \ rlca
    07 C,             \ rlca  
    E6 C, 07 C,       \ andn 7  n,
    C6 C, L2-RAM-PAGE C, \ addn L2-RAM-PAGE n,    \ usually 18 
    ED C, 92 C, 57 C, \ nextrega decimal 87 p, 
    3E C, E0 C,       \ ldn  a'| E0   n,  
    B3 C,             \ ora  e|
    67 C,             \ ld   h'| a|
    3A C,             \ lda()
    ' ATTRIB >BODY ,  \     address
    77 C,
    D9 C,             \ exx
    DD C, E9 C,       \ next
    SMUDGE            \ c; 

\ ____________________________________________________________________
\
.( XPLOT ) \ unset pixel x,y if Graphic-Mode permits
\ ____________________________________________________________________
\
\ This is valid for Layer 0  Layer 1,1  Layer 1,2 and Layer 1,3 mode
HEX             
: L0-XPLOT       ( x y -- )
    COORD-CHECK                 \ x y f
    IF
        TUCK                    \ y x y
        PIXELADD >R             \ y
        7 AND                   \ n 
        80 SWAP RSHIFT      
        R@ C@ 
        XPLOTOP
        R> C!
    ELSE
        2DROP
    THEN
;

\ ____________________________________________________________________
\
\ Layer 1 XPLOT
\ This is valid for Layer 1,1 and Layer 2 modes.
\ COORD-CHECK and PIXELADD are vectorized via DEFER..IS
DECIMAL
: L1-XPLOT  ( x y -- )
    COORD-CHECK               
    IF
        PIXELADD 
        DUP C@ 255 XOR SWAP C!
    ELSE
        2DROP 
    THEN
;

\ ____________________________________________________________________
\
\ Layer 2 PLOT
\ ported in machine code for fast execution
\ no coord-checking is done.
CODE L2-XPLOT  ( x y -- )
    HEX
    D9 C,             \ exx
    E1 C,             \ pop  hl|    \ horizontal y-coord, only L is significant
    D1 C,             \ pop  de|    \ vertical x-coord, only E is significant
    7B C,             \ ld   a'| e| \ calc which 8K page must be fitted in MMU7
    07 C,             \ rlca
    07 C,             \ rlca
    07 C,             \ rlca  
    E6 C, 07 C,       \ andn 7  n,
    C6 C, L2-RAM-PAGE C, \ addn L2-RAM-PAGE n,    \ usually 18 
    ED C, 92 C, 57 C, \ nextrega decimal 87 p, 
    3E C, E0 C,       \ ldn  a'| E0   n,  
    B3 C,             \ ora  e|
    67 C,             \ ld   h'| a|
    3A C,             \ lda()
    ' ATTRIB >BODY ,  \     address
    2F C,             \ cpl
    77 C,
    D9 C,             \ exx
    DD C, E9 C,       \ next
    SMUDGE            \ c; 

\ ____________________________________________________________________

.( LAYER: )

\ LAYER: is a defining word that allows you creating 6 new definitions
\ LAYER0 , LAYER10 , LAYER11 , LAYER12 , LAYER13 , LAYER20
\ that in one shot change all vectorized definitions behavior
\ and they also try to change current char-size.
HEX
: LAYER:
    <BUILDS
        ,           \    ATTRIB
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
        CR    
;        

\ ____________________________________________________________________

\ LAYER0 
HEX
    00  00          \ 00 char-size means no effect.
    1 7             \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD    
    ' L0-POINT      \ POINT   
    ' L0-PLOT       \ PLOT        
    ' L0-XPLOT      \ XPLOT      
    ' L0-PIXELATT   \ PIXELATT      
    ' NOOP          \ XY-RATIO  
    ' NOOP          \ EDGE 
    L0-ATTRIB       \ ATTRIB

LAYER: LAYER0  

\ ____________________________________________________________________

\ LAYER11 
HEX
    04  11          \ 04 char-size to allow 64 chars per row
    1 7             \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD    
    ' L0-POINT      \ POINT       
    ' L0-PLOT       \ PLOT        
    ' L0-XPLOT      \ XPLOT      
    ' L0-PIXELATT   \ PIXELATT      
    ' NOOP          \ XY-RATIO  
    ' NOOP          \ EDGE 
    L11-ATTRIB      \ ATTRIB

LAYER: LAYER11 

\ ____________________________________________________________________

\ LAYER13 
HEX
    04  13          \ 04 char-size to allow 64 chars per row
    1 7             \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD  
    ' L0-POINT      \ POINT     
    ' L0-PLOT       \ PLOT      
    ' L0-XPLOT      \ XPLOT    
    ' L13-PIXELATT  \ PIXELATT  
    ' NOOP          \ XY-RATIO  
    ' NOOP          \ EDGE 
    L13-ATTRIB      \ ATTRIB

LAYER: LAYER13 

\ ____________________________________________________________________

\ LAYER10 
HEX
    04  10          \ 04 char-size to allow 64 chars per row
    1 0FF           \ Attribute masks
    60  80          \ V-RANGE and H-RANGE
    ' L10-PIXELADD  \ PIXELADD  
    ' L1-POINT      \ POINT     
    ' L1-PLOT       \ PLOT      
    ' L1-XPLOT      \ XPLOT    
    ' 2DROP         \ PIXELATT  (has no meaning for Layer 1,0)
    ' NOOP          \ XY-RATIO  
    ' L1-EDGE       \ EDGE 
    L10-ATTRIB      \ ATTRIB

LAYER: LAYER10 

\ ____________________________________________________________________

\ LAYER2 
HEX
    04  20          \ 04 char-size to allow 64 chars per row
    1 0FF           \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L2-PIXELADD   \ PIXELADD  
    ' L1-POINT      \ POINT     
    ' L2-PLOT       \ PLOT      
    ' L2-XPLOT      \ XPLOT    
    ' L2-PLOT       \ PIXELATT  (has no meaning for Layer 2)
    ' NOOP          \ XY-RATIO  
    ' L1-EDGE       \ EDGE 
    L20-ATTRIB      \ ATTRIB

LAYER: LAYER2  

\ ____________________________________________________________________

\ LAYER12 
HEX
    08  12          \ 08 char-size is normal 64 chars per row
    1 7             \ Attribute masks
    0C0 200         \ V-RANGE and H-RANGE
    ' L12-PIXELADD  \ PIXELADD  
    ' L0-POINT      \ POINT     
    ' L0-PLOT       \ PLOT      
    ' L0-XPLOT      \ XPLOT    
    ' 2DROP         \ PIXELATT  (has no meaning on Layer 1,2)
    ' 2/            \ XY-RATIO  
    ' NOOP          \ EDGE 
    L12-ATTRIB      \ ATTRIB

LAYER: LAYER12 

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

    
\ if passed  f  is zero, then it forgets all this library
\ Typical usage:  0 GRAPHICS 
: FGRAPHICS ( f -- )
    NOT IF 
        LAYER12 NO-GRAPHICS 
    THEN
;


\ this allows FORGET GRAPHICS to remove this whole package

' FGRAPHICS ' GRAPHICS >BODY !



\ (COLOR)
\ this definition needs 4 params
\  b :  attribute value (in range 0-7)
\  c :  ctrl character between 16 and 21
\  m :  bitmask applied to b to avoid Basic's errors.
\  s :  number of bit to be shifted
: (COLOR)       ( b c m s -- )
  >R                \ b c m             R: s
  DUP R@            \ b c m m  s
  LSHIFT NEGATE     \ b c m m1          \ m1 has 0 only on bits to work on
  ATTRIB AND        \ b c m m1          \ zeroes working ATTRIB bits 
  3 PICK            \ b c m m1 b 
  R>                \ b c m m1 b s
  LSHIFT            \ b c m m1 b1       \ shift attribute value bits
  OR                \ b c m n           \ put them in place
  TO ATTRIB         \ b c m 
  ROT AND           \ c b&m             \ at end, change current attribs
  SWAP EMITC EMITC  \ 
;

DECIMAL

\         ctrl  mask       shift     
\ _______________________________________
\
: .INK      16  COLOR-MASK   0   (COLOR) ;
: .PAPER    17  COLOR-MASK   3   (COLOR) ;
: .FLASH    18  FLAG-MASK    6   (COLOR) ;
: .BRIGHT   19  FLAG-MASK    7   (COLOR) ;
: .INVERSE  20  FLAG-MASK    8   (COLOR) ;
: .OVER     21  FLAG-MASK    8   (COLOR) ;

\ ____________________________________________________________________
\
\ Immediately setup current mode 

MARKER SETUP-DONE 
NEEDS CASE
NEEDS IDE_MODE@
HEX
: SETUP
    IDE_MODE@
    CASE 
        00 OF LAYER0  ENDOF 
        01 OF LAYER10 ENDOF 
        05 OF LAYER11 ENDOF 
        09 OF LAYER12 ENDOF 
        0D OF LAYER13 ENDOF 
        02 OF LAYER2  ENDOF 
    ENDCASE     
    DROP DROP DROP
;
SETUP SETUP-DONE    

BASE !

