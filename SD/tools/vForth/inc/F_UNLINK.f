\
\ F_UNLINK.f
\

BASE @

\ Given a null-terminated filespec a, delete the file.
\ Drive defaults to '*' (current drive); include a drive letter in the
\ path to override.
\ NOTE: only the base file is deleted, not any associated +3DOS metadata
\ file (use the +3DOS DOS_DELETE call for that, via M_P3DOS).
\ return 0 on success, True flag on error
\
( F_UNLINK  via RST 08 hook $AD )
CODE F_UNLINK ( a -- f )

    HEX
    DD C, E3 C,         \  ex(sp)ix               \ ix = a, filespec null-terminated
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer

    3E C, 2A C,         \  ldn   a'|   $2A N,     \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, AD C,         \  rst   08|   $AD C,
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
