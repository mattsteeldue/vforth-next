\
\ m_dosversion.f
\
.( M_DOSVERSION )
\

BASE @

\ Get NextZXOS API version/mode information.
\ (doc/NextZXOS_and_esxDOS_APIs.md, M_DOSVERSION hook code $88)
\
\ Entry: none
\ Exit (esxDOS <= 0.8.6): Fc=1, error, A=14 ("no such device")
\ Exit (NextZXOS):        Fc=0, success
\   B='N', C='X'          NextZXOS signature
\   D=major, E=minor      version, BCD format (eg v1.94 -> DE=$0194)
\   H,L='e','n'/'e','s'   language code (English/Spanish)
\   A=0 (Z set) if running in NextZXOS mode; A<>0 (Z reset) in 48K mode
\
( M_DOSVERSION  via RST 08 hook code $88 )
CODE M_DOSVERSION ( -- ver )

    HEX
    DD C, E5 C,     \  push  ix|
    D5 C,           \  push  de|             \ save Return Stack Pointer
    C5 C,           \  push  bc|             \ save Instruction Pointer

    F3 C,           \  di
    CF C, 88 C,     \  rst   08|   $88  c,
    FB C,           \  ei

    D9 C,           \  exx                   \ hide de/hl (version/lang) away
    C1 C,           \  pop   bc|             \ restore Instruction Pointer
    D1 C,           \  pop   de|             \ restore Return Stack Pointer
    DD C, E1 C,     \  pop   ix|
    D9 C,           \  exx                   \ bring version/lang back

    D5 C,           \  push  de|             \ ver = NextZXOS version, BCD

    D9 C,           \  exx                   \ restore true ip/rp to view

    DD C, E9 C,     \  jpix

    FORTH
    SMUDGE

BASE !
