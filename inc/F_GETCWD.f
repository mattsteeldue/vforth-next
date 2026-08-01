\
\ F_GETCWD.f
\

BASE @

\ Given a buffer address buf, get the current working directory for the
\ default drive as a null-terminated path.
\ return 0 on success, True flag on error
\
( F_GETCWD  via RST 08 hook $A8 )
CODE F_GETCWD ( buf -- f )

    HEX
    DD C, E3 C,         \  ex(sp)ix               \ ix = buf, result buffer
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer

    3E C, 2A C,         \  ldn   a'|   $2A N,     \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, A8 C,         \  rst   08|   $A8 C,
    FB C,               \  ei

    C1 C,               \  pop   bc|              \ restore Instruction Pointer
    D1 C,               \  pop   de|              \ restore Return Stack Pointer
    DD C, E1 C,         \  pop   ix|               \ restore ix

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
