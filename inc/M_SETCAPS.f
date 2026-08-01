\
\ M_SETCAPS.f
\

BASE @

\ Set NextZXOS capability flags. a = capabilities to set:
\   bit 7 = 1: do not zero-fill new file data in F_TRUNCATE/F_FTRUNCATE
\           (increases performance of these calls)
\   bits 0..6: reserved, must be zero
\ prev = previous capabilities (save this and restore it via a second
\ M_SETCAPS call once done, so other programs see the original behaviour)
\ return 0 on success, True flag on error (eg on NextZXOS < v1.98M)
\
( M_SETCAPS  via RST 08 hook $91 )
CODE M_SETCAPS ( a -- prev f )

    HEX
    E1 C,               \  pop   hl|              \ hl = a
    DD C, E5 C,         \  push  ix|
    D5 C,               \  push  de|              \ save Return Stack Pointer
    C5 C,               \  push  bc|              \ save Instruction Pointer
    7D C,               \  ld    a'|   l|         \ a = entry value

    \ for dot-command compatibility
    E5 C,               \  push  hl|
    DD C, E1 C,         \  pop   ix|

    F3 C,               \  di
    CF C, 91 C,         \  rst   08|   $91 C,
    FB C,               \  ei

    6B C,               \  ld    l'|   e|         \ l = prev, captured before de is restored

    C1 C,               \  pop   bc|              \ restore Instruction Pointer
    D1 C,               \  pop   de|              \ restore Return Stack Pointer
    DD C, E1 C,         \  pop   ix|               \ restore ix

    26 C, 00 C,         \  ldn   h'|   0 N,       \ h = 0, zero-extend
    E5 C,               \  push  hl|              \ prev

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  Next

    FORTH
    SMUDGE

BASE !
