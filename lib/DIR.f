\
\ dir.f
\
.( DIR )

BASE @ DECIMAL

: DIR ( -- cccc )
     NOOP
;

NEEDS .PAD
NEEDS HEAP
NEEDS ?ESCAPE
NEEDS SHOW-PROGRESS

\
\ emit a date given a MSDOS format date-number: 16 bits are used this way
\ day :  bits 0-4, values between 1 and 31.
\ month: bits 5-8, values between 1 and 12.
\ year:  bits 9-15, must add 1980.
: .FAT-DATE ( n -- )
    <#  DUP $1F AND 1 MAX 0 # # [CHAR] - HOLD  2DROP \ day
        5 RSHIFT
        DUP $0F AND 1 MAX 12 MIN 0 # # [CHAR] - HOLD  2DROP \ month
        4 RSHIFT
        1980 + 0 # # # #  \ year
     #> TYPE
;

\
\ emit a time given a MSDOS format time-number
\ seconds : bits 0-4, values between 0 and 58, even values only
\ minutes : bits 5-10, values between 0 and 59.
\ hours   : bits 11-15, values between 0 and 23
: .FAT-TIME ( n -- )
    <# \ DUP $1F AND 2* 59 MIN 0 # # [CHAR] : HOLD  2DROP  \ seconds
        5 RSHIFT  
        DUP $3F AND 59 MIN 0 # # [CHAR] : HOLD  2DROP  \ minutes
        6 RSHIFT
        0 # #  \ hours
     #> TYPE
;


\ display number d using seven digit if it is less than 1048576
\ or in KB otherwise.
: .FILE-SIZE ( d -- )
    DUP $10 < IF            \ d       ( less than 1MB )
        7 D.R               \         ( display up to 7 digits )
    ELSE                    \ d
        $400 UM/MOD NIP 0   \ d       ( divide by 1024 )
        5 D.R SPACE         \ 
        [CHAR] K EMIT       \ 
    THEN                    \ 
;

\
\ skip filename
: SKIP-NAME ( a1 -- a2 )
    BEGIN  
        1+ 
        DUP C@ 0=
    UNTIL
;

VARIABLE DIR-SAVE-HP \ HP value before DIR
VARIABLE DIR-SAVE-DP \ DP value berore DIR
VARIABLE DIR-BYTES 0 ,  
VARIABLE DIR-GAP

\
\ emit one line for current directory entry.
\ Usually a lies in heap zone.
: DIR-LIST-ITEM ( a -- )
    DECIMAL                     \ a
    DUP 1+                      \ a a+1
    SKIP-NAME  DUP   >R         \ a a+n         R: a+n
    1+         DUP @ >R         \ a a+n+1       R: a+n time 
    2+         DUP @ >R         \ a a+n+3       R: a+n time date
    OVER C@ $10 AND             \ a a+n+3 f
    IF                          \ a a+n+3
        ."       d" DROP        \ a
    ELSE                        \ a a+n+3
        2+ 2@ SWAP           \ a d
        2DUP DIR-BYTES 2@       \ a d d dt
        D+   DIR-BYTES 2!       \ a d
        .FILE-SIZE              \ a
    THEN                        \ a
    SPACE SPACE                 \ a
    R> .FAT-DATE SPACE          \ a             R: a+n time  
    R> .FAT-TIME SPACE SPACE    \ a             R: a+n 
    1+ R>                       \ a+1 a+n
    OVER - TYPE CR
;

\
\ assume at DIR-SAVE-DP begins an Array of Heap-Pointers that ends at HERE
\ each pointing a Heap area containing a directory entry, previously loaded.
\ emit the complete content of directory
: DIR-LIST ( -- )
    BASE @
    0 0  DIR-BYTES 2!
    HERE DIR-SAVE-DP @ DO
        BEGIN ?ESCAPE NOT UNTIL
        ?TERMINAL IF LEAVE THEN
        I @  FAR  DIR-LIST-ITEM        
    2 +LOOP
    DIR-BYTES 2@ .FILE-SIZE 
    ."  Bytes  "
    HERE  DIR-SAVE-DP @ - 2/ . 
    ." files " 
    BASE !
;


: DIR-SHELL-SORT ( -- )
    HERE 2-  DIR-SAVE-DP @  
    2DUP - DIR-GAP 2+ !
    DO
        DIR-GAP @ 
        DUP DUP + + 2 RSHIFT    
        $FFFE AND 
        DUP DIR-GAP !
        3 < IF
            2 DIR-GAP !
            1   \ flag sorted true
        ELSE
            DIR-GAP @ DUP 18 = SWAP 20 = OR 
            IF 22 DIR-GAP ! THEN
            0   \ flag sorted false
        THEN
        HERE DIR-GAP @ -
        DIR-SAVE-DP @ 
        ?DO                     \ for i between 1 to n-1 inclusive
            I DIR-GAP @ + @ FAR \ element i+gap
            I             @ FAR \ element i
            32 (COMPARE)        \ -1 when a[i+gap] < a[i] 
            0< IF               \ exchange pointers, NOT strings!
                I 2+ @  I  @ 
                I 2+ !  I  ! 
                DROP 0   \ flag sorted false
            THEN
        2 +LOOP
        IF LEAVE THEN   \ leave outer loop if flag is true
        I 8 AND IF [CHAR] . EMIT 8 EMITC THEN \ flashing dot
    LOOP                       \ uses flag-sorted
;

\ accept the following text (without quotes) as the path to be examined
\ this path-name is termporarily kept in PAD
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
    .PAD CR
;

\ This operation requires at least 8K available in HEAP.
\ given a path-name in PAD, open such directory and put in HEAP
\ each entry, Pointers are put at HERE and DP is advanced.
\ This will form a dynamic array starting from DIR-SAVE-DP to HERE -2
: DIR-TO-HEAP ( -- )
    HP@  DIR-SAVE-HP !              \ save HP for future forget/restore
    HERE DIR-SAVE-DP !              \ save DP for future forget/restore
    PAGE-WATERMARK SKIP-HP-PAGE     \ ensure to be at a new 8k page...
    PAD F_OPENDIR 43 ?ERROR >R      \ keep filehandle in R@
    BEGIN
        HERE                        \ use dictionary as temp area
        PAD                         \ wildcard ignored
        R@ F_READDIR 46 ?ERROR
    WHILE
        HERE DUP                    \ a a
        1+ SKIP-NAME                \ a a+n
        HERE - 10 +                 \ a m
        DUP HEAP                    \ a m hp
        DUP >R                      \ a m hp  
        FAR SWAP                    \ a a2 m
        CMOVE
        R> ,                        \ append to array 
    REPEAT
    R>  F_CLOSE DROP
;

\ free space from heap and dictionary
: DIR-FREE
    DIR-SAVE-HP @ HP !
    DIR-SAVE-DP @ DP !
;

\ forward definition to be called by DIR.
: DIR-CCCC
    DIR-PAD
    DIR-TO-HEAP
    DIR-SHELL-SORT
    DIR-LIST
    DIR-FREE
;

\ this allows FORGET DIR to remove this whole package

' DIR-CCCC ' DIR >BODY !

BASE !
