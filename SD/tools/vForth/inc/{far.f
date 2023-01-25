\
\ {far.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
 .( <FAR )

BASE @ \ save base status

\
\ given an address E000-FFFF and a page number n (32-39) or 20h-27h)
\ reverse of >FAR: encodes a FAR address compressing
\ to bits 765 of H, lower bits of HL address offset from E000h
CODE <FAR ( a n -- ha )
    HEX
    E1 C,             \     pop     hl   ; page number
    7D C,             \     ld      a, l
    E6 C, 07 C,       \     and     $07  ; questionable: it could be SUB $20
    0F C,             \     rrca                              
    0F C,             \     rrca                              
    0F C,             \     rrca                              
    08 C,             \     ex      af, af'     ; save bits 765
    E1 C,             \     pop     hl   ; address E000-FFFF
    7C C,             \     ld      a, h 
    E6 C, 1F C,       \     and     $1F                       
    67 C,             \     ld      h, a       
    08 C,             \     ex      af, af'     ; retrieve bits 765
    B4 C,             \     or      h
    67 C,             \     ld      h, a       
    E5 C,             \     push    hl     
    DD C, E9 C,       \     jp      (ix)   

    FORTH
    SMUDGE

BASE !
