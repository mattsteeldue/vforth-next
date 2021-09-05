\
\ {far.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
 .( <FAR included s) 6 EMIT
\
\ given an address E000-FFFF and a page number n (32-39) or 20h-27h)
\ reverse of >FAR: encodes a FAR address compressing
\ to bits 765 of H, lower bits of HL address offset from E000h
CODE <FAR ( a n -- ha )
    HEX
    D1 C,             \     pop     de   // page number in e  
    E1 C,             \     pop     hl   // address in hl     
    7B C,             \     ld      a, e                      
    D6 C, 20 C,       \     sub     $20  // reduced to 0-7    
    0F C,             \     rrca                              
    0F C,             \     rrca                              
    0F C,             \     rrca                              
    57 C,             \     ld      d, a // save to d bits 765
    7C C,             \     ld      a, h // drops             
    E6 C, 1F C,       \     and     $1F                       
    B2 C,             \     or      d                         
    67 C,             \     ld      h, a       
    E5 C,             \     push    hl     
    DD C, E9 C,       \     jp      (ix)   
SMUDGE

DECIMAL
