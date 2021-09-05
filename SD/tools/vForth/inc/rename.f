\
\ rename.f
\ 
.( RENAME  included ) 6 EMIT
\
\ old and new word-names must have the same length
\
HEX
\
\ RENAME
: RENAME  ( -- "CCC" "DDD" )
    \ find cccc nfa and name length
    ' >BODY NFA
    DUP C@  [ HEX 1F ] LITERAL  AND
    \ find last character of name and store away
    2DUP + 
    >R
        \ search for dddd and keep it safe
        BL WORD       [ HEX 20 ] LITERAL  ALLOT
        \ get the minimum length
        COUNT  [ HEX 1F ] LITERAL  AND ROT MIN
        >R 
            SWAP 1+
        R>
        \ overwrite cccc name with nnnn 
        CMOVE
        \ correct last character of name
        R@  C@  [ HEX 80 ] LITERAL  OR
    R>      
    C!
    \ free space allocated for dddd.
    [ HEX -20 ] LITERAL ALLOT
;
\  
DECIMAL
\
