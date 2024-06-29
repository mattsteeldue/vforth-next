\
\ f_opendir.f
\
.( F_OPENDIR )
\

BASE @

\ given a z-string address, open a file-handle to the directory
\ Return 0 on success, True flag on error
CODE f_opendir ( a -- fh f )

    HEX 

    DD C, E3 C,         \  ex(sp)ix            \ filespec nul-terminated
    D5 C,               \  push    de|
    C5 C,               \  push    bc|
    06 C, 10 C,         \  ldn     b'|   hex 10   N,
    3E C, 43 C,         \  ldn     a'|   char c   N,

    \ for dot-command compatibility
    E5 C,               \  push  hl| 
    DD C, E1 C,         \  pop   ix|

    F3 C,               \  di    
    CF C, A3 C,         \  rst     08|   HE  a3  C,
    FB C,               \  ei

    5F C,               \  ld      e'|     a|
    16 C, 00 C,         \  ldn     d'|     0  N,
    C1 C,               \  pop     bc|
    D1 C,               \  pop     de|
    DD C, E1 C,         \  pop     ix|
    D5 C,               \  push    de|
    ED C, 62 C,         \  sbchl   hl|
    E5 C,               \  push    hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
