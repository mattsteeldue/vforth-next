\
\ F_CHDIR.f
\

BASE @

\ Given a null-terminated path a, change the working directory of the
\ default drive.
\ Drive defaults to '*' (current drive); include a drive letter in the
\ path to override. Note: this does not change the *default drive*
\ itself, only the working directory on it (see M_GETSETDRV for that).
\ return 0 on success, True flag on error
\
( F_CHDIR  via RST 08 hook $A9 )
CODE F_CHDIR ( a -- f )

    HEX
    DD C, E3 C,         \  ex(sp)ix               \ ix = a, path null-terminated
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer

    3E C, 2A C,         \  ldn   a'|   $2A N,     \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, A9 C,         \  rst   08|   $A9 C,
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
