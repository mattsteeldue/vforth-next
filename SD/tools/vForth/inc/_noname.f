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
\   ?EXEC

    HP@                     \ use HP "NFA" address
    DUP FAR
    [ HEX ] A081 OVER !     \ compile name, an undetectable space
    CELL+
    CURRENT @ @  OVER !     \ compile LFA
    CELL+
    OVER 4 + ,              \ mirror cell: ha of the heap xt cell, as CODE
    HERE SWAP !             \ heap xt cell points to xt
    6 HP +!
    0 skip-hp-page

    HERE                    \ this is xt that will be left on TOS

    [ HEX ] 0CD C,          \ compile CALL op-code $CD for direct-thread

    [ ' ' >BODY CELL- @ ] 
    LITERAL ,               \ any colon-definition CFA address to jump to

    SWAP CURRENT @ !        \ save this nameless definition

    !CSP
    [COMPILE] ]
    SMUDGE
;

BASE !
