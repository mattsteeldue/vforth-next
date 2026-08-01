\
\ F_REWINDDIR.f
\

BASE @

\ Given an open directory handle h, rewind the directory position back
\ to the start of the directory.
\ return 0 on success, True flag on error
\
( F_REWINDDIR  via RST 08 hook $A7 )
CODE F_REWINDDIR ( h -- f )

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
    CF C, A7 C,         \  rst   08|   $A7 C,
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
