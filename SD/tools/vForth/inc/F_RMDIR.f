\
\ F_RMDIR.f
\

BASE @

\ Given a null-terminated path a, remove a directory.
\ Drive defaults to '*' (current drive); include a drive letter in the
\ path to override.
\ return 0 on success, True flag on error
\
( F_RMDIR  via RST 08 hook $AB )
CODE F_RMDIR ( a -- f )

    HEX
    DD C, E3 C,         \  ex(sp)ix               \ ix = a, path null-terminated
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer

    3E C, 2A C,         \  ldn   a'|   $2A N,     \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, AB C,         \  rst   08|   $AB C,
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
