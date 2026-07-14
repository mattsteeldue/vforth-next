\
\ L4-pixeladd.f
\
\ Layer 2 640x256 4bpp PIXELADD.
\ Identical vertical-band layout as L22-PIXELADD (320x256), but two pixels
\ share one byte (4bpp), so the horizontal coordinate y must be halved to
\ obtain the byte index: byteX = y >> 1.
\   page    = byteX >> 5   (one 8K page per 32 byte-columns)
\   column  = byteX & 31
\   address = $E000 + column*256 + x      (x = vertical coord, low byte L)
\ Returns the address of the BYTE; the caller (L4-PLOT/L4-POINT/L4-XPLOT)
\ selects the proper nibble from the parity of y.
\
.( L4-PIXELADD )
\
NEEDS GRAPHICS-COMMON    \ for L2-RAM-PAGE assembled-in constant
NEEDS L2-RAM-PAGE

BASE @
HEX
CODE L4-PIXELADD  ( x y -- a )
    D9 C,             \ exx
    D1 C,             \ pop  de     \ horizontal y-coord (0..639, full DE)
    E1 C,             \ pop  hl     \ vertical   x-coord (only L significant)
    06 C, 01 C,       \ ld   b, 1
    ED C, 2A C,       \ bsrl de, b  \ de = y >> 1 = byteX
    4B C,             \ ld   c, e   \ keep low byte of byteX
    06 C, 05 C,       \ ld   b, 5
    ED C, 2A C,       \ bsrl de, b  \ e = byteX >> 5 = which 8K page (0..9)
    7B C,             \ ld   a, e
    27 C,             \ daa         \ DAA trick for fast modulo 10: if A nibble_low > 9,
                      \             \ DAA adds 6 to nibble_low (causing carry to high nibble);
                      \             \ then AND 0F extracts the low nibble = A mod 10.
    E6 C, 0F C,       \ and  0F     \ extract low nibble = page number modulo 10
    C6 C, L2-RAM-PAGE C, \ add  L2-RAM-PAGE
    ED C, 92 C, 57 C, \ nextreg 57, a   \ map the page onto MMU7
    3E C, E0 C,       \ ld   a, E0
    B1 C,             \ or   c
    67 C,             \ ld   h, a
    E5 C,             \ push hl
    D9 C,             \ exx
    DD C, E9 C,       \ next
    SMUDGE            \ c;
BASE !
