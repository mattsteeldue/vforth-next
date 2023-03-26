\
\ _noname.f
\
.( :NONAME )
\
\ Tipical usage is
\   DEFER  print
\   :NONAME . ;   IS print 
\
\ This is just a quick'n'dirty implementation of :NONAME

NEEDS FAR
NEEDS HP@
NEEDS SKIP-HP-PAGE

BASE @ \ save base status

: :NONAME ( -- cccc ) ( -- xt )
    ?EXEC

    \ detect if this is 1.7, 
    [ ' LIT <NAME 0< ] LITERAL
    IF
        HP@                     \ use HP "NFA" address 
        DUP FAR
        [ HEX ] A081 OVER !     \ compile name 
        CELL+
        CURRENT @ @  OVER !     \ compile LFA
        CELL+
        HERE SWAP !
        6 HP +!
        0 skip-hp-page
    ELSE
        HERE                    \ NFA to be kept as LATEST via CURRENT @ !
        [ HEX ] A081 ,          \ name is an undetectable space
        LATEST ,                \ compile LFA pointer
    THEN
    
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
