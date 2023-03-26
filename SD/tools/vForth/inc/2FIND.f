\
\ 2find.f
\
.( 2FIND )
\
\ searches the dictionary giving CFA and the heading byte 
\ or zero if not found
: 2find ( a -- cfa b 1 | 0 )
    >r              \
    r@              \ addr
    context @ @     \ addr voc
    (find)          \ cfa b 1   |  0
    
    ?dup            \ cfa b 1 1 |  0
    0=              \ cfa b 1 0 |  1
    If  
        r@          \ addr
        \ latest    \ addr voc
        current @ @
        (find)      \ cfa b 1   |  0 
    Then   
    r> drop    
    ;

