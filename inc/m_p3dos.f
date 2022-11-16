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

    D1 C,                       \ pop de        ; dos call entry address
    E1 C,                       \ pop hl        ; A register argument
    7D C,                       \ ld  a,l

    D9 C,                       \ exx

    C1 C,                       \ pop bc        
    D1 C,                       \ pop de       
    E1 C,                       \ pop hl       

    D9 C,                       \ exx

    C5 C,                       \ push bc
    DD C, E5 C,                 \ push ix
    
    0E C, 07 C,                 \ ld c,7        ; use 7 RAM bank
    
    CF C,                       \ rst 8
    94 C,                       \ # 94

    DD C, 22 C,                 \ ld (02A+ORIGIN), ix ; saves away IX 
    HEX 02A +ORIGIN ,
    
    DD C, E1 C,                 \ pop ix        ; retrieve ix
    E3 C,                       \ ex (sp),hl    ; hl argument and retrieve BC

    D5 C,                       \ push de
    C5 C,                       \ push bc

    4D C,                       \ ld c,l        ; restore BC register
    44 C,                       \ ld b,h

    26 C, 00 C,                 \ ld h,0
    6F C,                       \ ld l,a
    E5 C,                       \ push hl
    
    ED C, 62 C,                 \ sbc hl,hl     ; -1 for OK ;  0 for KO but now
    23 C,                       \ inc hl
    E5 C,                       \ push hl

    DD C, E9 C, ( NEXT )        \ jp (ix)

    FORTH
    SMUDGE

BASE !
