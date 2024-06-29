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
    D9 C,               \  exx                
    E1 C,               \  pop     hl|        
    7D C,               \  ld      a'|     l| 
    D1 C,               \  pop     de|        
    DD C, E3 C,         \  ex(sp)ix            \ wildcard spec nul-terminated
    D9 C,               \ exx                 
    D5 C,               \ push    de|         
    C5 C,               \ push    bc|         
    D9 C,               \  exx                

    \ for dot-command compatibility
    E5 C,               \  push  hl| 
    DD C, E1 C,         \  pop   ix|

    F3 C,               \  di    
    CF C, A4 C,         \  rst     08|   hex  A4  C,
    FB C,               \  ei

    5F C,               \  ld      e'|     a| 
    16 C, 00 C,         \  ldn     d'|     0  N,
    D9 C,               \ exx                 
    C1 C,               \ pop     bc|         
    C1 C,               \ pop     de|         
    DD C, E1 C,         \ pop     ix|         
    D9 C,               \  exx                
    D5 C,               \  push    de|        
    ED C, 62 C,         \  sbchl   hl|        
    E5 C,               \  push    hl|        
    DD C, E9 C,         \ Next

    FORTH
    SMUDGE

BASE !
