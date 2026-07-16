\
\ f_chmod.f
\

BASE @

\ Given a null-terminated filespec a1, modify its attributes.
\ attr is the bitmap of attribute values, mask is the bitmap of which
\ attributes to change (1=change, 0=leave alone). Bitmasks are any
\ combination of:
\    A_WRITE     %00000001
\    A_READ      %10000000
\    A_RDWR      %10000001
\    A_HIDDEN    %00000010
\    A_SYSTEM    %00000100
\    A_ARCH      %00100000
\ return 0 on success, True flag on error
( F_CHMOD  via RST 08 hook $AF )
CODE F_CHMOD ( a1 attr mask -- f )

    HEX
    E1 C,               \  pop     hl|      \ hl = mask (TOS)
    7D C,               \  ld      a'|  l|  \ a = mask (stash)
    E1 C,               \  pop     hl|      \ hl = attr (next)
    65 C,               \  ld      h'|  l|  \ h = attr
    6F C,               \  ld      l'|  a|  \ l = mask -- hl = (attr,mask)
    DD C, E3 C,         \  ex(sp)ix         \ ix = a1, filespec nul-term
    D5 C,               \  push    de|      \ save Return Stack Pointer
    C5 C,               \  push    bc|      \ save Instruction Pointer
    44 C,               \  ld      b'|  h|  \ b = attr
    4D C,               \  ld      c'|  l|  \ c = mask

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    3E C, 2A C,         \  ldn     a'|   $2A N,   \ a = '*' (default drive)
    F3 C,               \  di
    CF C, AF C,         \  rst     08|   $AF C,
    FB C,               \  ei

    C1 C,               \  pop     bc|
    D1 C,               \  pop     de|
    DD C, E1 C,         \  pop     ix|

    ED C, 62 C,         \  sbchl   hl|
    E5 C,               \  push    hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
