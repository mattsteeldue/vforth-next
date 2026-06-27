\
\ LAYER2-GRAPHICS.f
\
\ Layer 2 - 256 w x 192 h pixels, 256 colors total, one colour per pixel.
\
\ Load with:  NEEDS LAYER2-GRAPHICS
\ It pulls in GRAPHICS-COMMON and activates Layer 2 immediately.
\
.( LAYER2-GRAPHICS )

NEEDS GRAPHICS-COMMON

MARKER NO-LAYER2-GRAPHICS       \ unload only this mode (keeps GRAPHICS-COMMON)

\ NEEDS guard word for this module
: LAYER2-GRAPHICS
    NOOP
;

\ shared words extracted to inc/ (deduplicated via NEEDS)
NEEDS L1-POINT
NEEDS L1-EDGE
NEEDS L2-RAM-PAGE
NEEDS .BORDER

BASE @

\ ____________________________________________________________________
\
\ Layer 2 INITIALIZE
: L2-INITIALIZE
    RGB-COLORS
    ATTRIB .INK
    BACKGROUND .PAPER
    BACKGROUND .BORDER
;

\ ____________________________________________________________________
\
\ Layer 2 PIXELADD
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
\ Layer 2 PLOT
\ ported in machine code for fast execution
\ out-of-range coordinates are silently skipped (no wrap, no corruption)
CODE L2-PLOT  ( x y -- )
    HEX
    D9 C,             \ exx
    E1 C,             \ pop  hl|    \ horizontal y-coord, only L is significant
    D1 C,             \ pop  de|    \ vertical x-coord, only E is significant
    7C C,             \ ld   a'| h| \ y high byte
    B7 C,             \ ora  a|     \ y in 0..255 ?
    20 C, 1C C,       \ jrnz SKIP   \ out of range -> skip plot
    7A C,             \ ld   a'| d| \ x high byte
    B7 C,             \ ora  a|     \ x in 0..255 ?
    20 C, 18 C,       \ jrnz SKIP
    7B C,             \ ld   a'| e| \ x low byte
    FE C, 0C0 C,      \ cp   0C0    \ x < 192 ?
    30 C, 13 C,       \ jrnc SKIP   \ x >= 192 -> skip plot
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
    77 C,             \ ld(hl)a
    D9 C,             \ SKIP: exx
    DD C, E9 C,       \ next
    SMUDGE            \ c;

\ ____________________________________________________________________
\
\ Layer 2 XPLOT
\ ported in machine code for fast execution
\ out-of-range coordinates are silently skipped (no wrap, no corruption)
CODE L2-XPLOT  ( x y -- )
    HEX
    D9 C,             \ exx
    E1 C,             \ pop  hl|    \ horizontal y-coord, only L is significant
    D1 C,             \ pop  de|    \ vertical x-coord, only E is significant
    7C C,             \ ld   a'| h| \ y high byte
    B7 C,             \ ora  a|     \ y in 0..255 ?
    20 C, 1D C,       \ jrnz SKIP   \ out of range -> skip plot
    7A C,             \ ld   a'| d| \ x high byte
    B7 C,             \ ora  a|     \ x in 0..255 ?
    20 C, 19 C,       \ jrnz SKIP
    7B C,             \ ld   a'| e| \ x low byte
    FE C, 0C0 C,      \ cp   0C0    \ x < 192 ?
    30 C, 14 C,       \ jrnc SKIP   \ x >= 192 -> skip plot
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
    77 C,             \ ld(hl)a
    D9 C,             \ SKIP: exx
    DD C, E9 C,       \ next
    SMUDGE            \ c;

\ ____________________________________________________________________
\
\ Build LAYER2 and activate it
\ PIXELATT reuses L2-PLOT (writes ATTRIB at pixel address)
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
    ' L2-INITIALIZE \ INITIALIZE
    _BLUE           \ BACKGROUND
    0D8             \ ATTRIB (L20-ATTRIB)

LAYER: LAYER2

LAYER2

BASE !
