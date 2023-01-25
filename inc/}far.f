\
\ }far.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( >FAR )

BASE @ \ save base status

\
\ decode bits 765 of H as one of the 8K-page between 32 and 39 (20h-27h)
\ take lower bits of H and L as an offset from E000h
\ then return address  a  between E000h-FFFFh 
\ and page number n  between 64-71 (40h-47h)
\ For example, in hex: 
\   0000 >FAR  gives  20.E000
\   1FFF >FAR  gives  20.FFFF
\   2000 >FAR  gives  21.E000
\   3FFF >FAR  gives  21.FFFF
\   EFFF >FAR  gives  27.EFFF
\   FFFF >FAR  gives  27.FFFF
CODE >FAR ( ha -- a n )
    HEX
    E1 C,             \     pop     hl 
    7C C,             \     ld      a, h 
    08 C,             \     ex      af, af'     ; save h
    7C C,             \     ld      a, h 
    F6 C, E0 C,       \     or      $E0         ; hl is between E000 and FFFF
    67 C,             \     ld      h, a
    E5 C,             \     push    hl     
    08 C,             \     ex      af, af'     ; retrieve original h
    07 C,             \     rlca           
    07 C,             \     rlca           
    07 C,             \     rlca           
    E6 C, 07 C,       \     and     $07    
    C6 C, 20 C,       \     add     $20    <-- 32
    6F C,             \     ld      l, a   
    26 C, 00 C,       \     ld      h, 0   
    E5 C,             \     push    hl     
    DD C, E9 C,       \     jp      (ix)   

    FORTH
    SMUDGE

BASE !

