\
\ _noname.f
\
.( :NONAME )
\
\ Tipical usage is
\   DEFER print
\   :NONAME . ;   IS print 
\

BASE @ \ save base status

: :NONAME ( -- cccc )
    ?EXEC

    HERE                    \ NFA to be kept as LATEST via CURRENT @ !
    [ HEX ] A081 ,          \ name is an undetectable space
    LATEST ,                \ compile LFA pointer
    
    HERE                    \ this is xt that will be left on TOS
    
    [ HEX ] 0CD C,          \ compile CALL op-code $CD for direct-thread
    3 CFA NEGATE ALLOT      \ but wipe it out for indirect-thread version
    
    [ ' ' >BODY CELL- @ ] 
    LITERAL ,               \ any colon-definition CFA address to jump to

    SWAP CURRENT @ !        \ save this nameless definition

    !CSP
    [COMPILE] ]
    SMUDGE
;

BASE !
