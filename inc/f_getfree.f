\
\ f_getfree.f
\

BASE @

\ Given a drive specifier "*"=default, "$"=system
\ return free space on drive
\ return 0 on success, True flag on error
( F_GETFREE  via RST 08 hook code test )
code F_GETFREE ( b -- d f )     \ Get free space on drive.

    HEX 
    E1 C,               \  pop   hl|
    DD C, E5 C,         \  push  ix|
    D5 C,               \  push  de|
    C5 C,               \  push  bc|
    7D C,               \  ld    a'|   l|

    F3 C,               \  di    
    CF C, B1 C,         \  rst   08|   $B1  c,
    FB C,               \  ei

    D9 C,               \  exx
    C1 C,               \  pop   bc| 
    D1 C,               \  pop   de| 
    DD C, E1 C,         \  pop   ix|
    D9 C,               \  exx
    D5 C,               \  push  de|
    C5 C,               \  push  bc|
    D9 C,               \  exx

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  jpix

    FORTH
    SMUDGE

BASE !
