\
\ LAYER0-GRAPHICS.f
\
\ Layer 0 - Standard Spectrum (ULA) mode.
\ 256 w x 192 h pixels, 8 colors total (2 intensities),
\ 32 x 24 cells, 2 colors per cell.
\
\ Load with:  NEEDS LAYER0-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 0 immediately.
\
.( LAYER0-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER0-GRAPHICS       \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER0-GRAPHICS
    NOOP
;

BASE @

\ ____________________________________________________________________
\
\ Layer 0 PIXELADD
\ This word exploits the new "pixelad" Z80-N op-code.
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

' L0-SET IS PLOTOP       \ usually OR to "set" the pixel
' L0-XOR IS XPLOTOP      \ usually XOR to "xor" the pixel

\ ____________________________________________________________________
\
\ Layer 0 POINT - fetch color/status of pixel x,y
HEX
: L0-POINT  ( x y -- c )
    TUCK                        \ y x y
    PIXELADD C@                 \ y b
    SWAP 7 AND                  \ b y mod 7
    LSHIFT 80 AND               \ f
;

\ ____________________________________________________________________
\
\ Layer 0 PLOT - set pixel x,y to color/status kept by ATTRIB
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
\ Layer 0 XPLOT - unset/invert pixel x,y
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
\ Build LAYER0 and activate it
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
    _BLUE 3 LSHIFT _WHITE +     \ ATTRIB (L0-ATTRIB)

LAYER: LAYER0

LAYER0

BASE !
