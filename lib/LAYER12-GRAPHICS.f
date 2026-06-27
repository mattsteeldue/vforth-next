\
\ LAYER12-GRAPHICS.f
\
\ Layer 1,2 - Timex HiRes (Enhanced ULA) mode.
\ 512 w x 192 h pixels, 256 colors total,
\ only 2 colors on whole screen.
\
\ Load with:  NEEDS LAYER12-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 1,2 immediately.
\
.( LAYER12-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER12-GRAPHICS      \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER12-GRAPHICS
    NOOP
;

BASE @

\ ____________________________________________________________________
\
\ Layer 1,2 PIXELADD
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
\ POINT - fetch color/status of pixel x,y
HEX
: L0-POINT  ( x y -- c )
    TUCK                        \ y x y
    PIXELADD C@                 \ y b
    SWAP 7 AND                  \ b y mod 7
    LSHIFT 80 AND               \ f
;

\ ____________________________________________________________________
\
\ PLOT - set pixel x,y to color/status kept by ATTRIB
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
\ XPLOT - unset/invert pixel x,y
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
\ Build LAYER12 and activate it
\ PIXELATT has no meaning for Layer 1,2 -> 2DROP
\ XY-RATIO halves the horizontal coordinate -> 2/
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
    00              \ ATTRIB (L12-ATTRIB)

LAYER: LAYER12

LAYER12

BASE !
