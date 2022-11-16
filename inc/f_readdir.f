\
\ f_readdir.f
\
.( F_READDIR )
\

BASE @

\ Given a pad address a1, a filter z-string a2 and a file-handle fh
\ fetch the next available entry of the directory.
\ Return 1 as ok or 0 to signal end of data then 
\ return 0 on success, True flag on error
CODE f_readdir ( a1 a2 fh -- n f )

    HEX 

    E1 C,               \ POP     HL|
    7D C,               \ LD      A'|     L|
    D1 C,               \ POP     DE|
    DD C, E3 C,         \ EX(SP)IX            \ wildcard spec nul-terminated
    C5 C,               \ PUSH    BC|
    CF C, A4 C,         \ RST     08|   HEX  A4  C,
    5F C,               \ LD      E'|     A|
    16 C, 00 C,         \ LDN     D'|     0  N,
    C1 C,               \ POP     BC|
    DD C, E1 C,         \ POP     IX|
    D5 C,               \ PUSH    DE|
    ED C, 62 C,         \ SBCHL   HL|
    E5 C,               \ PUSH    HL|
    DD C, E9 C,         \ Next

    FORTH
    SMUDGE

BASE !
