\
\ F_TRUNCATE.f
\

BASE @

\ Given a null-terminated filespec a (unopened file) and a double-cell
\ new size d, truncate or extend the file to exactly d bytes. Extended
\ parts are zero-filled (unless M_SETCAPS bit 7 has been set).
\ Drive defaults to '*' (current drive); include a drive letter in the
\ path to override.
\ return 0 on success, True flag on error
\
( F_TRUNCATE  via RST 08 hook $AE )
CODE F_TRUNCATE ( a d -- f )

    HEX
    D9 C,               \  exx                    \ hide true ip/rp away
    C1 C,               \  pop   bc|              \ bc = d.hi
    D1 C,               \  pop   de|              \ de = d.lo

    DD C, E3 C,         \  ex(sp)ix               \ ix = a, filespec null-terminated
    3E C, 2A C,         \  ldn   a'|   $2A N,     \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, AE C,         \  rst   08|   $AE C,
    FB C,               \  ei

    D9 C,               \  exx                    \ restore true ip/rp to view

    ED C, 62 C,         \  sbchl hl|              \ (Fc from the call, still intact)
    DD C, E1 C,         \  pop   ix|              \ restore ix
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
