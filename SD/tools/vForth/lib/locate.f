\
\ locate.f
\
.( LOCATE ) 
\

NEEDS TEXT
NEEDS COMPARE

\
BASE @
\
HEX

\ search for a colon-definition in screen u.
: LOCATE.BLK   ( u -- )
    BLK @ >R 
    >IN @ >R
    0 >IN !  BLK !
    BEGIN
        BL WORD @ 3A01 = \ this is the sequence ": " for a colon-defnition
        IF
            BL WORD COUNT
            PAD COUNT 
            COMPARE 
            0= IF 
                CLS
                BLK @ B/SCR / 
                LIST 
                ABORT 
            THEN
        THEN
                    
        ?TERMINAL \ ?ESCAPE
        IF 
            CR BLK @ 2/ .
            ABORT
        THEN
        
        HERE 1+ C@ 0=
    UNTIL
    R> >IN ! 
    R> BLK !
;
\
\ try to locate where cccc colon-definition is defined

DECIMAL

: LOCATE ( -- cccc )
    BL TEXT                 \ accepts a word to PAD
    2002 1 DO               \ Block 2001 is bottom part of Screen#1000
        I  6 AND [CHAR] ) + EMIT 8 EMIT
        I LOCATE.BLK        \ perform the actual search
    LOOP
    ." Not found. " 
;

\
BASE !

