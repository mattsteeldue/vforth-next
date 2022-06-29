\
\ ms.f
\
\
.( ms )

BASE @ \ save base status


( ms delay )
\ ms delay.
\ maximum delay should be n < 8192.
CODE ms ( n -- )       
    HEX

    D9 C,         \   exx
    E1 C,         \   POP     HL|      

    \ if zero then skip to end
    7D C,         \   ld      a'|   l|  
    B4 C,         \   ora      h|        
    28 C, 1D C,   \   JRF     Z'| holdplace

    01 C, 243B ,  \   ldx     bc|     hex 243B NN,
    3E C, 07 C,   \   ldn     a'|     hex 07 N,
    ED C, 79 C,   \   out(c)  a'|
    04 C,         \   inc     b'|
    ED C, 78 C,   \   in(c)   a'|

    E6 C, 03 C,   \   andn    3 N,
    28 C, 04 C,   \   JRF     Z'| holdplace
    29 C,         \   addhl   hl|
    3D C,         \   dec     a'|
    18 C, FA C,   \   jr      back,    

\   ED C, 68 C,   \   in(c)   l'|
\   ED C, 91 C, 7 C, 0 C,   \ nextreg 7,0 : SPEED 0
\   F3 C,         \   DI

                  \   HERE    \ BEGIN,   \
    00 C,         \     NOP              \    4 T              
    06 C, CC C,   \     LDN   B'|  204   \    7 T
    00 C,         \     HERE      NOP  
    10 C, FD C,   \     DJNZ  BACK,      \ 3463 T = (4+13)*203 + 12
    2B C,         \     DECX  HL|        \    6 T
    7D C,         \     LD    A'|   L|   \    4 T
    B4 C,         \     ORA    H|        \    4 T  
    20 C, F5 C,   \   JRF  NZ'| BACK,    \   12 T :      T  ( -5 T on exit)

\   FB C,         \   EI
\   7D C,         \   ld      a'|   l|
\   ED C, 92 C, 7 C,    \ nextreg 7,A : SPEED restored

                  \   HERE DISP, \ THEN,
    D9 C,         \   exx
    DD C, E9 C,   \   JP(IX)

    FORTH
    SMUDGE


BASE !
