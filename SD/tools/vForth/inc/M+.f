\
\ M+.f
\
\ add unsigned u to double precision d.
\
.( M+ ) 
\
HEX
    60 C,        \                   ld      h, b           
    69 C,        \                   ld      l, c           
    D1 C,        \                   pop     de             
    C1 C,        \                   pop     bc             
    E3 C,        \                   ex      (sp),hl        
    09 C,        \                   add     hl, bc         
    C1 C,        \                   pop     bc             
    30 C, 01 C,  \                      jr      nc, MPlus_Skip 
    13 C,        \                      inc     de         
                 \ MPlus_Skip:                            
    E5 C,        \                   push    hl             
    D5 C,        \                   push    de             
    DD C, E9 C,  \                   jp      (ix)           
