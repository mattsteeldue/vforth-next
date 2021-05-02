\
\ }far.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( >FAR )
\
\ decode bits 765 of H as one of the 8K-page between 64 and 71 (40h-47h)
\ take lower bits of H and L as an offset from E000h
\ then return address  a  between E000h-FFFFh 
\ and page number n  between 64-71 (40h-47h)
\ For example, in hex: 
\   0000 >FAR  gives  40.E000
\   1FFF >FAR  gives  40.FFFF
\   2000 >FAR  gives  41.E000
\   3FFF >FAR  gives  41.FFFF
\   EFFF >FAR  gives  47.EFFF
\   FFFF >FAR  gives  47.FFFF
CODE >FAR ( ha -- a n )
    HEX
    D1 C,             \     pop     de     
    7A C,             \     ld      a, d   
    E6 C, E0 C.       \     and     $E0    
    07 C,             \     rlca           
    07 C,             \     rlca           
    07 C,             \     rlca           
    C6 C, 40 C,       \     add     $40    
    6F C,             \     ld      l, a   
    26 C, 00 C,       \     ld      h, 0   
    7A C,             \     ld      a, d   
    F6 C, E0 C,       \     or      $E0    
    57 C,             \     ld      d, a   
    E5 C,             \     push    hl     
    D5 C,             \     push    de     
    DD C, E9 C,       \     jp      (ix)   
SMUDGE
