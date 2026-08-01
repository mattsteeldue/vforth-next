\
\ F_SEEKDIR.f
\

BASE @

\ Given an open directory handle h and a double-cell offset d (as
\ previously returned by F_TELLDIR), set the current directory position.
\ return 0 on success, True flag on error
\
( F_SEEKDIR  via RST 08 hook $A6 )
CODE F_SEEKDIR ( h d -- f )

    HEX
    D9 C,               \  exx                    \ hide true ip/rp away
    C1 C,               \  pop   bc|              \ bc = d.hi
    D1 C,               \  pop   de|              \ de = d.lo
    E1 C,               \  pop   hl|              \ hl = h, directory handle
    7D C,               \  ld    a'|   l|         \ a = handle

    DD C, E5 C,         \  push  ix|              \ save true ix

    F3 C,               \  di
    CF C, A6 C,         \  rst   08|   $A6 C,
    FB C,               \  ei

    DD C, E1 C,         \  pop   ix|              \ restore true ix
    D9 C,               \  exx                    \ restore true ip/rp to view

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
