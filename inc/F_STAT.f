\
\ f_stat.f
\

BASE @

\ Given a null-terminated filespec a1 (unopened file, not a handle) and an
\ 11-byte buffer address buf, get file information/status.
\ return 0 on success, True flag on error
\ The following details are returned in the 11-byte buffer:
\ +0(1) '*'
\ +1(1) $81
\ +2(1) file attributes (MS-DOS format)
\ +3(2) timestamp (MS-DOS format)
\ +5(2) datestamp (MS-DOS format)
\ +7(4) file size in bytes
( F_STAT  via RST 08 hook $AC )
CODE F_STAT ( a1 buf -- f )

    HEX
    E1 C,               \  pop     hl|            \ hl = buf (11-byte buffer)
    DD C, E3 C,         \  ex(sp)ix               \ ix = a1, filespec nul-term
    D5 C,               \  push    de|            \ save Return Stack Pointer
    C5 C,               \  push    bc|            \ save Instruction Pointer
    EB C,               \  exdehl                 \ de = buf; hl = old RSP

    3E C, 2A C,         \  ldn     a'|   $2A N,   \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, AC C,         \  rst     08|   $AC C,
    FB C,               \  ei

    C1 C,               \  pop     bc|
    D1 C,               \  pop     de|            \ de = RSP restored
    DD C, E1 C,         \  pop     ix|

    ED C, 62 C,         \  sbchl   hl|
    E5 C,               \  push    hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
