\
\ f_opendir.f
\
.( F_OPENDIR )
\

BASE @

\ given a z-string address, open a file-handle to the directory
\ Return 0 on success, True flag on error
CODE f_opendir ( a -- fh f )

    HEX 

    DD C, E3 C,         \ EX(SP)IX            \ filespec nul-terminated
    C5 C,               \ PUSH    BC|
    06 C, 10 C,         \ LDN     B'|   HEX 10   N,
    3E C, 43 C,         \ LDN     A'|   CHAR C   N,
    CF C, A3 C,         \ RST     08|   HEX  A3  C,
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
