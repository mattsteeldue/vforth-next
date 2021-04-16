\
\ locate.f
\
.( LOCATE )
\

NEEDS TEXT
NEEDS SEARCH.SCR

\
\
: LOCATE.SCR ( -- f )
    BL WORD @ 14849 = \ this is the sequence ": " for a colon-defnition
    IF 
        SEARCH.SCR    \ then the following word should be a definition-name
    ELSE 
        1             \ to signal it did not found
    THEN
;

\ search for a colon-definition in screen b.
: LOCATE.BLK   ( b -- )
    BLK @ >R 
    >IN @ >R
    0 >IN !  BLK !
    BEGIN
        LOCATE.SCR
        0= IF 
            CLS
            BLK @ B/SCR / 
            LIST 
            QUIT 
        ENDIF
            
        ?TERMINAL \ ?ESCAPE
        IF 
            ." Stop at " BLK ? 
            QUIT 
        THEN
        HERE 1+ C@ 0=
    UNTIL
    R> >IN ! 
    R> BLK !
;
\
\ try to locate where cccc colon-definition is defined
: LOCATE ( -- cccc )
    BL TEXT                 \ accepts a word to PAD
    1000 1 DO
        I 05 MOD 42 + EMIT  \ show some movement during the search
        1 \ I 20 MOD
        IF 
            8 EMIT 
        THEN
        I LOCATE.BLK        \ perform the actual search
    LOOP
    ." Not found. " 
;

\
