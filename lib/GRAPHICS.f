\
\ graphics.f
\
.( GRAPHICS )
\
\ v-Forth 1.8 - NextZXOS version - build 2025-08-15
\ MIT License (c) 1990-2025 Matteo Vitturi     
\
\ N.B. in this library, x-coord is vertical (from top to bottom)
\      and y-coord is horizontal (from left to right).
\      Both coordinates start from zero.
\      (0,0) is the top-left addressable pixel 
\ N.B.B. Except 320x256 Layer2+ which swaps coordinate in display.

FORTH DEFINITIONS

NEEDS 2OVER 
NEEDS FLIP 

NEEDS VALUE  
NEEDS TO  
NEEDS +TO 

NEEDS DEFER 
NEEDS IS

NEEDS IDE_MODE!
NEEDS IDE_MODE@

MARKER NO-GRAPHICS      \ for easy development

NEEDS .INK     
NEEDS .PAPER   
NEEDS .OVER    
NEEDS .BRIGHT  
NEEDS .FLASH   
NEEDS .AT
NEEDS .INVERSE 
NEEDS .BORDER

\ this allows FORGET GRAPHICS to remove this whole package, see bottom of this source.
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
\
\ 22 : Layer 22 - 320 w x 256 h pixels, 256 colors total, one colour per pixel
\ ____________________________________________________________________
\
\                L0   L11   L12   L13   L10    L2   L22   
\               ---   ---   ---   ---   ---   ---   ---
\ Char-Size       8     4     8     4     4     4     4   
\ V-RANGE       0C0   0C0   0C0   0C0   060   0C0   100
\ H-RANGE       100   100   200   100   080   100   140
\ PIXELADD       L0    L0   L12    L0   L10    L2   L22
\ POINT          L0    L0    L0    L0    L1    L1    L1 
\ PLOT           L0    L0    L0    L0    L1    L2    L1
\ XPLOT          L0    L0    L0    L0    L1    L2    L1
\ PIXELATT       L0    L0    na   L13    na    L2    L1
\ XY-RATIO        1     1    2/     1     1     1     1
\ EDGE            =     =     =     =    L1    L1    L1
\ ____________________________________________________________________
\
\ Default attrib values

    _BLUE   3 LSHIFT  _WHITE  +  VALUE  L0-ATTRIB 
    _BLUE   3 LSHIFT  _WHITE  +  VALUE  L10-ATTRIB 
    _BLUE   3 LSHIFT  _WHITE  +  VALUE  L11-ATTRIB 
                     _YELLOW     VALUE  L12-ATTRIB 
    _BLUE   3 LSHIFT  _WHITE  +  VALUE  L13-ATTRIB 
    %11111110                    VALUE  L20-ATTRIB 
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

\ Deferred definition work differently depending on current Graphic-Mode.

\ current "color" used in subsequent operations
00 VALUE ATTRIB
00 VALUE P-ATTRIB \ address of ATTRIB field inside LAYERs definition

\ determine address of a pixel and fit MMU7 if needed
DEFER PIXELADD      ( x y -- a )

\ set attribute byte at address a
DEFER PIXELATT      ( b a -- )

\ plot a pixel using current ATTRIB
DEFER PLOT          ( x y -- )

\ In Layer 1,0 and Layer 2, invert the pixel value
\ In all other Graphic-Mode, invert or unset the pixel
DEFER XPLOT         ( x y -- )

\ return the ATTRIB of a pixel
DEFER POINT         ( x y -- c )

\ to adjust Layer 1,2 aspect ratio for horizontal coordinate
DEFER XY-RATIO      ( y1 -- y2 )

\ edge rule
DEFER EDGE          ( b -- f )

\ initialize step
DEFER INITIALIZE    ( -- )


\ ____________________________________________________________________
\
.( PIXELADD ) \ deterimine pixel address and fit MMU7 if needed
\ ____________________________________________________________________
\
\ Layer 0 - Layer 1,1 - Layer 1,3 - PIXELADD
\ This word exploits the new "pixelad" Z80-N op-code 
\ This is valid for Layer 0  Layer 1,1  and  Layer 1,3 
\ Standard RAM used is at $4000 or bank 5, 8k-page $0A-0B.
HEX
CODE L0-PIXELADD   ( x y -- a )
    D9 C,           \ exx
    D1 C,           \ pop   de  ; y
    E1 C,           \ pop   hl  ; x
    55 C,           \ ld    d,l ; de is vert, horiz
    ED C, 94 C,     \ pixelad 
    E5 C,           \ push  hl
    D9 C,           \ exx
    DD C, E9 C,     \ jp   (ix)
    SMUDGE
   
\ ____________________________________________________________________
\
\ Layer 1,0  PIXELADD
\ fit the correct 8k page on MMU7 and leaves the address from $E000
\ even if this graphic mode uses 8k-pages $0A and $0B
\
HEX
CODE L10-PIXELADD ( x y -- a ) 
    D9 C,               \ exx
    E1 C,               \ pop  hl|  \ horizontal y-coord, only L is significant
    D1 C,               \ pop  de|  \ vertical   x-coord, only E is significant
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
\ even if this graphic mode uses 8k-pages $0A and $0B and $10-11
HEX
CODE L12-PIXELADD   ( x y -- a )
    D9 C,               \ exx
    D1 C,               \ pop   de      ; y \ horizontal y-coord, lsb of D and E  is significant
    E1 C,               \ pop   hl      ; x \ vertical   x-coord, only L is significant
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
\ fit the correct 8k page on MMU7 and leaves the address from $E000
\ it uses six 8k-pages $12-$17
\
HEX 12 REG@ 2*
CONSTANT  L2-RAM-PAGE           \ keeps Layer 2 Active RAM Page
L2-RAM-PAGE 5 + CONSTANT L2-MAX-PAGE
\ this operation is done only once at compile time, just to save time
\ and setup MMU7! accordingly

CODE L2-PIXELADD ( x y -- a ) 
    HEX
    D9 C,             \ exx
    E1 C,             \ pop  hl|    \ horizontal y-coord, only L is significant
    D1 C,             \ pop  de|    \ vertical   x-coord, only E is significant
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

\
\ Layer 22 PIXELADD - 320x256 resolution
\ fit the correct 8k page on MMU7 and leaves the address from $E000
\ it uses six 8k-pages $12-$1C
CODE L22-PIXELADD  ( y x -- a )
    HEX
    D9 C,             \ exx
    D1 C,             \ pop  de|    \ horizontal y-coord, lsb of D and E are significant
    E1 C,             \ pop  hl|    \ vertical   x-coord, only L is significant
    4B C,             \ ld   c'! e|
    06 C, 05 C,       \ ldn  b'| 5  n,    
    ED C, 2A C,       \ bsrlde,b    \ calc which 8K page must be fitted in MMU7
    7B C,             \ ld   a'| e|
    27 C,             \ daa
    E6 C, 0F C,       \ andn 0F  n,
    C6 C, L2-RAM-PAGE C, \ addn L2-RAM-PAGE n,    \ usually 18 
    ED C, 92 C, 57 C, \ nextrega decimal 87 p, 
    3E C, E0 C,       \ ldn  a'| E0   n,  
    B1 C,             \ ora  c|
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
\ Layer 2 PLOT may use Layer 1 one
\ I ported in machine code for faster execution but no coord-checking is done.
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

\ Layer0 initialize

: L0-INITIALIZE
    ATTRIB COLOR-MASK AND 
    #16 EMITC EMITC 
    ['] (CLS) IS CLS
;

\ ____________________________________________________________________

\ Layer1x initialize

: L1-CLS
    (CLS)
    $1A EMITC 0 EMITC
    0 #26 EMITC EMITC           \ Non-stop scroll
;

: L1-INITIALIZE
    ATTRIB COLOR-MASK AND 
    #16 EMITC EMITC 
    ['] L1-CLS IS CLS
;

\ ____________________________________________________________________

\ Layer2 initialize

: L2-INITIALIZE
    0    $70 REG!    \ Layer 2 Control
    0    $1C REG!    \ Clip window Control
    0    $18 REG!    \ X1
    #255 $18 REG!    \ X2
    0    $18 REG!    \ X3
    #191 $18 REG!    \ X4
    ATTRIB .INK
    #255 ATTRIB - .PAPER
    ['] L1-CLS IS CLS
    L2-RAM-PAGE 5 + TO L2-MAX-PAGE
;

\ ____________________________________________________________________

\ Layer2+ initialize

: L22-CLS
    L2-RAM-PAGE #10 +  
    L2-RAM-PAGE 
    DO
        I MMU7!
        $E000 $2000 $FF ATTRIB - FILL
    LOOP
;


: L22-INITIALIZE
    $10  $70 REG!    \ Layer 2 Control for 320x256
    0    $1C REG!    \ Clip window Control
    0    $18 REG!    \ X1
    #159 $18 REG!    \ X2
    0    $18 REG!    \ X3
    #255 $18 REG!    \ X4
    ATTRIB .INK
    #255 ATTRIB - .PAPER
    ['] L22-CLS IS CLS
    L2-RAM-PAGE 9 + TO L2-MAX-PAGE
;


\ ____________________________________________________________________

DECIMAL
0   VALUE  DX                   \ x-distance between P1 and P2
0   VALUE  DY                   \ y-distance between P1 and P2
0   VALUE  SX                   \ x-direction from P1 to P2
0   VALUE  SY                   \ y-direction from P1 to P2
0   VALUE  DIFF                 \ error at each stage
0   VALUE  ERR
0   VALUE  X0                   \ 
0   VALUE  Y0                   \ 
0   VALUE  X1                   \ 
0   VALUE  Y1                   \ 
0   VALUE  PX
0   VALUE  MX                   \ to be vectored...

\ ____________________________________________________________________

.( LAYER: )

\ LAYER: is a defining word that allows you creating 6 new definitions
\ LAYER0 , LAYER10 , LAYER11 , LAYER12 , LAYER13 , LAYER2 , LAYER2+
\ that in one shot change all vectorized definitions behavior
\ and they also try to change current char-size.
\ At compile-time, data is stored in reverse order than the data given via LAYER:
\ At run-time, all vectors change and then Graphic-Mode is activate and
\ character-size is modified and at last video clipping is performed
HEX
: LAYER:
    CREATE
        ,           \    ATTRIB
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
             ATTRIB P-ATTRIB !  \ save current attrib to previous mode default
        DUP     TO  P-ATTRIB    \ set pointer for later use

        \ setup vector for attribute
        DUP  @  TO  ATTRIB      CELL+   

        \ setup all other vectors
        DUP  @  IS  INITIALIZE  CELL+
        DUP  @  IS  EDGE        CELL+
        DUP  @  IS  XY-RATIO    CELL+
        DUP  @  IS  PIXELATT    CELL+
        DUP  @  IS  XPLOT       CELL+
        DUP  @  IS  PLOT        CELL+
        DUP  @  IS  POINT       CELL+
        DUP  @  IS  PIXELADD    CELL+
        
        \ setup ranges and masks.
        DUP  @  TO  H-RANGE     CELL+
        DUP  @  TO  V-RANGE     CELL+
        DUP C@  TO  COLOR-MASK  1+
        DUP C@  TO  FLAG-MASK   1+

        \ activate this Graphic-Mode
        DUP C@  LAYER!          1+
        
        \ then modify char-size 
            C@  ?DUP IF 1E EMITC EMITC THEN  \ char-size
        \ other initialization
            INITIALIZE
;        

\ ____________________________________________________________________

\ LAYER0 
HEX
    0               \ 00 char-size means no effect.
    00              \ means Layer 0
    1    7          \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD    
    ' L0-POINT      \ POINT   
    ' L0-PLOT       \ PLOT        
    ' L0-XPLOT      \ XPLOT      
    ' L0-PIXELATT   \ PIXELATT      
    ' NOOP          \ XY-RATIO  
    ' NOOP          \ EDGE 
    ' L0-INITIALIZE \ INITIALIZE
    L0-ATTRIB       \ ATTRIB

LAYER: LAYER0  

\ ____________________________________________________________________

\ LAYER11 
HEX
    04              \ 04 char-size to allow 64 chars per row
    11              \ means Layer 1,1
    1    7          \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD    
    ' L0-POINT      \ POINT       
    ' L0-PLOT       \ PLOT        
    ' L0-XPLOT      \ XPLOT      
    ' L0-PIXELATT   \ PIXELATT      
    ' NOOP          \ XY-RATIO  
    ' NOOP          \ EDGE 
    ' L1-INITIALIZE \ INITIALIZE
    L11-ATTRIB      \ ATTRIB

LAYER: LAYER11 

\ ____________________________________________________________________

\ LAYER13 
HEX
    04              \ 04 char-size to allow 64 chars per row
    13              \ means Layer 1,3
    1    7          \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L0-PIXELADD   \ PIXELADD  
    ' L0-POINT      \ POINT     
    ' L0-PLOT       \ PLOT      
    ' L0-XPLOT      \ XPLOT    
    ' L13-PIXELATT  \ PIXELATT  
    ' NOOP          \ XY-RATIO  
    ' NOOP          \ EDGE 
    ' L1-INITIALIZE \ INITIALIZE
    L13-ATTRIB      \ ATTRIB

LAYER: LAYER13 

\ ____________________________________________________________________

\ LAYER10 
HEX
    04              \ 04 char-size to allow 64 chars per row
    10              \ means Layer 1,0
    1  0FF          \ Attribute masks
    60  80          \ V-RANGE and H-RANGE
    ' L10-PIXELADD  \ PIXELADD  
    ' L1-POINT      \ POINT     
    ' L1-PLOT       \ PLOT      
    ' L1-XPLOT      \ XPLOT    
    ' 2DROP         \ PIXELATT  (has no meaning for Layer 1,0)
    ' NOOP          \ XY-RATIO  
    ' L1-EDGE       \ EDGE 
    ' L1-INITIALIZE \ INITIALIZE
    L10-ATTRIB      \ ATTRIB

LAYER: LAYER10 

\ ____________________________________________________________________

\ LAYER12 
HEX
    08              \ 08 char-size is normal 64 chars per row
    12              \ means Layer 1,2
    1 7             \ Attribute masks
    0C0 200         \ V-RANGE and H-RANGE
    ' L12-PIXELADD  \ PIXELADD  
    ' L0-POINT      \ POINT     
    ' L0-PLOT       \ PLOT      
    ' L0-XPLOT      \ XPLOT    
    ' 2DROP         \ PIXELATT  (has no meaning on Layer 1,2)
    ' 2/            \ XY-RATIO  
    ' NOOP          \ EDGE 
    ' L1-INITIALIZE \ INITIALIZE
    L12-ATTRIB      \ ATTRIB

LAYER: LAYER12 

\ ____________________________________________________________________

\ LAYER2 
HEX
    04              \ 04 char-size to allow 64 chars per row
    20              \ means Layer 2,1
    1 0FF           \ Attribute masks
    0C0 100         \ V-RANGE and H-RANGE
    ' L2-PIXELADD   \ PIXELADD  
    ' L1-POINT      \ POINT     
    ' L2-PLOT       \ PLOT      
    ' L2-XPLOT      \ XPLOT    
    ' L2-PLOT       \ PIXELATT  (has no meaning for Layer 2)
    ' NOOP          \ XY-RATIO  
    ' L1-EDGE       \ EDGE 
    ' L2-INITIALIZE \ INITIALIZE
    L20-ATTRIB      \ ATTRIB

LAYER: LAYER2

\ ____________________________________________________________________

\ LAYER2+
HEX
    04              \ 04 char-size to allow 64 chars per row
    20              \ means Layer 2,1 but see for different INITIALIZE
    1 0FF           \ Attribute masks
    100 140         \ V-RANGE and H-RANGE
    ' L22-PIXELADD  \ PIXELADD  
    ' L1-POINT      \ POINT     
    ' L1-PLOT       \ PLOT      
    ' L1-XPLOT      \ XPLOT    
    ' L1-PLOT       \ PIXELATT  (has no meaning for Layer 2)
    ' NOOP          \ XY-RATIO  
    ' L1-EDGE       \ EDGE 
    ' L22-INITIALIZE \ INITIALIZE
    L20-ATTRIB      \ ATTRIB

LAYER: LAYER2+

\ ____________________________________________________________________
\
\ Graphic Words definitions
\ ____________________________________________________________________

\ ____________________________________________________________________
\
NEEDS DRAW-LINE
NEEDS DRAW-CIRCLE

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
        02 OF LAYER2  ENDOF \ or LAYER2+
    ENDCASE     
    DROP DROP DROP
;
SETUP SETUP-DONE    

BASE !

