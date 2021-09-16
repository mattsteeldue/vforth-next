\
\ bsearch.f
\
.( BSEARCH Block search utility ) 
\ search for text word inside the first 1000 screens.

NEEDS TEXT
NEEDS SHOW-PROGRESS
NEEDS SEARCH.SCR

\ For debugging purposes
\ : SEARCH.TRC  BLK @ 6 .R  >IN @ 6 .R ;

: SEARCH.SHOW
    BLK @ B/SCR /MOD  DUP >R   6 .R  B/BUF * >IN @ +
    C/L /MOD  DUP >R           6 .R  PAD C@ 1+ -  6 .R
    R> R> 6 SPACES (LINE) 2/  TYPE   CR 
;
\ 
\ search for text within a signle block
: SEARCH.BLK   ( b -- )
    BLK @ >R 
    >IN @ >R
    0 >IN ! BLK !
    BEGIN
        SEARCH.SCR
        0= IF 
            \ if found, display result in a human readable way
            SEARCH.SHOW 
        ENDIF
        HERE 1+ C@ 0=
    UNTIL
    R> >IN ! 
    R> BLK !
;
\
\ Search the following word and show result
\ search is performed in screens between n and m only
: BSEARCH ( n m -- cccc )
    BL TEXT                     \
    ." ...Searching for "
    PAD COUNT TYPE CR
    
    ." Screen  Line  Char" CR   \ report layout
    
    1+ B/SCR *  SWAP B/SCR *
    DO
        I  SHOW-PROGRESS
        I  SEARCH.BLK
        ?TERMINAL 
        IF 
            ." Stop at " I B/SCR / . LEAVE 
        ENDIF
    LOOP
;
