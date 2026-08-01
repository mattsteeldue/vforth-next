\
\ F_TELLDIR.f
\

BASE @

\ Given an open directory handle h, get the current directory position
\ as a double-cell offset (as used by F_SEEKDIR).
\ return  0 on success, True flag on error
\
( F_TELLDIR  via RST 08 hook $A5 )
CODE F_TELLDIR ( h -- d f )

    HEX
    E1 C,               \  pop   hl|              \ hl = h, directory handle
    DD C, E5 C,         \  push  ix|
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer
    7D C,               \  ld    a'|   l|         \ a = handle

    \ for dot-command compatibility
    E5 C,               \  push  hl|
    DD C, E1 C,         \  pop   ix|

    F3 C,               \  di
    CF C, A5 C,         \  rst   08|   $A5 C,
    FB C,               \  ei

    D9 C,               \  exx                    \ hide bc/de (offset) away
    C1 C,               \  pop   bc|              \ restore Instruction Pointer
    D1 C,               \  pop   de|              \ restore Return Stack Pointer
    DD C, E1 C,         \  pop   ix|               \ restore ix
    D9 C,               \  exx                    \ bring offset back

    D5 C,               \  push  de|              \ d.lo
    C5 C,               \  push  bc|              \ d.hi
    D9 C,               \  exx                    \ restore true ip/rp to view

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
