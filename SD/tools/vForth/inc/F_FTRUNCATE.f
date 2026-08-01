\
\ F_FTRUNCATE.f
\

BASE @

\ Given an open file handle h and a double-cell new size d, truncate or
\ extend the file to exactly d bytes. Extended parts are zero-filled
\ (unless M_SETCAPS bit 7 has been set). The file position is unaffected.
\ return 0 on success, True flag on error
\
( F_FTRUNCATE  via RST 08 hook $A2 )
CODE F_FTRUNCATE ( h d -- f )

    HEX
    D9 C,               \  exx                    \ hide true ip/rp away
    C1 C,               \  pop   bc|              \ bc = d.hi
    D1 C,               \  pop   de|              \ de = d.lo
    E1 C,               \  pop   hl|              \ hl = h, file handle
    7D C,               \  ld    a'|   l|         \ a = handle

    DD C, E5 C,         \  push  ix|              \ save true ix

    F3 C,               \  di
    CF C, A2 C,         \  rst   08|   $A2 C,
    FB C,               \  ei

    DD C, E1 C,         \  pop   ix|              \ restore true ix
    D9 C,               \  exx                    \ restore true ip/rp to view

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
