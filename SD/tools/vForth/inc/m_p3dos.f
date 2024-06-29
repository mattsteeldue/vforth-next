\
\ m_p3dos.f
\
.( M_P3DOS )
\

BASE @

\ NextZXOS call wrapper.
\  n1 = hl or ix register parameter value
\  n2 = de register parameter value 
\  n3 = bc register parameter value
\  n4 =  a register parameter value
\   a = routine address in ROM 3
\ ---- 
\  n5 = hl returned value
\  n6 = de returned value 
\  n7 = bc returned value
\  n8 =  a returned value
\   f
\

CODE m_p3dos ( n1 n2 n3 n4 a -- n5 n6 n7 n8  f )

    HEX 

    D9 C,                       \   exx
    E1 C,                       \   pop hl        ; dos call entry address
    D1 C,                       \   pop de        ; A register argument
    7B C,                       \   ld  a,e
    C1 C,                       \   pop bc        
    D1 C,                       \   pop de       
    E3 C,                       \   ex(sp)hl      ; but save dos call address
    D9 C,                       \  exx
    E1 C,                       \  pop hl         ; dos call entry address

    DD C, E5 C,                 \  push ix
    D5 C,                       \  push de
    C5 C,                       \  push bc
    EB C,                       \  ex de,hl       ; de=dos call entry address

    \ for dot-command compatibility
    E5 C,                       \  push  hl| 
    DD C, E1 C,                 \  pop   ix|

    0E C, 07 C,                 \  ld c,7        ; use 7 RAM bank

    F3 C,                       \  di    
    CF C,                       \  rst 8
    94 C,                       \  # 94
    FB C,                       \  ei

    DD C, 22 C,                 \  ld ($32+ORIGIN), ix ; saves away IX 
    $32 +ORIGIN ,
    
    D9 C,                       \   exx
    C1 C,                       \   pop   bc| 
    D1 C,                       \   pop   de| 
    DD C, E1 C,                 \   pop   ix|
    D9 C,                       \  exx

    E5 C,                       \  push hl 
    D5 C,                       \  push de
    C5 C,                       \  push bc

    26 C, 00 C,                 \  ld h,0
    6F C,                       \  ld l,a
    E5 C,                       \  push hl
    D9 C,                       \   exx
    
    ED C, 62 C,                 \   sbc hl,hl     ; -1 for OK ;  0 for KO but now
    23 C,                       \   inc hl
    E5 C,                       \   push hl

    DD C, E9 C, ( NEXT )        \  jp (ix)

    FORTH
    SMUDGE

BASE !
