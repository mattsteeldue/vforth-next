\
\ dir.f
\
.( DIR )

NEEDS .PAD

BASE @ DECIMAL

: DIR ( -- cccc )
     NOOP
;

NEEDS ?ESCAPE

\
\ emit a date given a MSDOS format date number
: .FAT-DATE ( n -- )
    <#  DUP $1F AND 1 MAX 0 # # [CHAR] - HOLD  2DROP \ day
        5 RSHIFT
        DUP $0F AND 1 MAX 12 MIN 0 # # [CHAR] - HOLD  2DROP \ month
        4 RSHIFT
        1980 + 0 # # # #  \ year
     #> TYPE
;

\
\ emit a time given a MSDOS format time number
: .FAT-TIME ( n -- )
    <# \ DUP $1F AND 2* 59 MIN 0 # # [CHAR] : HOLD  2DROP  \ seconds
        5 RSHIFT  
        DUP $3F AND 59 MIN 0 # # [CHAR] : HOLD  2DROP  \ minutes
        6 RSHIFT
        0 # #  \ hours
     #> TYPE
;
\
\ emit filename
: .FILENAME ( a1 -- a2 )
    begin  
        DUP C@ ?DUP 
    while 
        emitc 1+ 
    repeat  
;


\ emit filename
: SKIP-NAME ( a1 -- a2 )
    BEGIN  
        1+ 
        DUP C@ 0=
    UNTIL
;


\
\ given a z-string address in PAD, emit the directory content
: DIR-FH  ( fh --  )
    CR >R
    BEGIN
        ?ESCAPE IF
            0                           \ FALSE for the IF after WHILE
            -1                          \ TRUE  for the AND before WHILE
        ELSE
            -1                          \ TRUE for the IF after WHILE
            HERE                        \ use HERE as temp area
            PAD                         \ wildcard ignored
            R@  F_READDIR 
            46 ?ERROR
        THEN
        ?TERMINAL NOT                   \ BREAK stops
        AND
    WHILE
        IF
            HERE                        \ a
            1+ SKIP-NAME DUP >R         \ a+n
            1+        DUP @  >R         \ a+n+1         R: time  
            CELL+     DUP @  >R         \ a+n+3         R: time date
            HERE C@ 16 AND IF           \ a+n+3 
                ." d      " DROP
            ELSE
                CELL+ 2@ SWAP           \ d
                DUP 16 < IF 
                    7 D.R 
                ELSE
                    1024 UM/MOD NIP 0 
                    5 D.R SPACE
                    [CHAR] K EMIT
                THEN
            THEN 
            SPACE DECIMAL                     
            R> .FAT-DATE SPACE              
            R> .FAT-TIME SPACE SPACE
            R> 
            HERE 1+ 
            DO I C@ EMIT LOOP
            CR
        THEN
    REPEAT
    R> 2DROP
;

\
: DIR-PAD ( -- cccc )
    PAD C/L BLANK
    67 ALLOT                        \               
    0 C, HERE                       \ a1            -- now HERE is PAD
    [ CHAR C ] LITERAL C,           \ a1            -- start with C:
    BL WORD DUP C@ 1+ ALLOT         \ a1 a3         -- append cccc
    >R                              \ a1     R: a3  
    0 C,                            \ a1            -- append 0x00
    1- HERE OVER - OVER C!          \ a0            -- fix length byte
    [CHAR] : R> C!                  \ a0     R:     -- put : after C
    HERE - 67 - ALLOT               
    BASE @ >R                       \ save current base
    .PAD
    PAD F_OPENDIR 43 ?ERROR >R      \ keep filehandle in R@
    R@  DIR-FH
    R>  F_CLOSE DROP
    R>  BASE !
;

\ this allows FORGET DIR to remove this whole package

' DIR-PAD ' DIR >BODY !

BASE !
