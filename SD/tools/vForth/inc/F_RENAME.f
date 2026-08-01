\
\ F_RENAME.f
\

BASE @

\ Given a null-terminated source filespec src and a null-terminated
\ destination filespec dest, rename/move the file.
\ Drive defaults to '*' (current drive); include a drive letter in
\ src to override.
\ NOTE: only the base file is renamed, not any associated +3DOS metadata
\ file (use the +3DOS DOS_RENAME call for that, via M_P3DOS).
\ return 0 on success, True flag on error
\
( F_RENAME  via RST 08 hook $B0 )
CODE F_RENAME ( src dest -- f )

    HEX
    D9 C,               \  exx                    \ hide true ip/rp away
    D1 C,               \  pop   de|              \ de = dest, filespec null-terminated

    DD C, E3 C,         \  ex(sp)ix               \ ix = src, filespec null-terminated
    3E C, 2A C,         \  ldn   a'|   $2A N,     \ a = '*' (default drive)

    \ for dot-command compatibility
    DD C, E5 C,         \  push  ix|
    E1 C,               \  pop   hl|

    F3 C,               \  di
    CF C, B0 C,         \  rst   08|   $B0 C,
    FB C,               \  ei

    D9 C,               \  exx                    \ restore true ip/rp to view

    ED C, 62 C,         \  sbchl hl|              \ (Fc from the call, still intact)
    DD C, E1 C,         \  pop   ix|              \ restore ix
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
