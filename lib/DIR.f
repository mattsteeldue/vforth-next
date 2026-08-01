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
NEEDS WILDCARD
NEEDS .FAT-DATE
NEEDS .FAT-TIME
NEEDS .FILE-SIZE

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
\ VARIABLE DIR-DRIVE  CHAR C DIR-DRIVE !    \ drive letter used by DIR

.( .)

\
\ emit one line for current directory entry.
\ Usually a lies in heap zone.
: DIR-LIST-ITEM ( a -- )
    CR                          \ a
    DUP 1+                      \ a a+1
    SKIP-NAME  DUP   >R         \ a a+n         R: a+n
    1+         DUP @ >R         \ a a+n+1       R: a+n time 
    2+         DUP @ >R         \ a a+n+3       R: a+n time date
    OVER C@ $10 AND             \ a a+n+3 f
    IF                          \ a a+n+3
        ."       d" DROP        \ a
    ELSE                        \ a a+n+3
        2+ 2@ SWAP              \ a d
        2DUP DIR-BYTES 2@       \ a d d dt
        D+   DIR-BYTES 2!       \ a d
        .FILE-SIZE              \ a
    THEN                        \ a
    SPACE SPACE                 \ a
    R> .FAT-DATE SPACE          \ a             R: a+n time  
    R> .FAT-TIME SPACE SPACE    \ a             R: a+n 
    1+ R>                       \ a+1 a+n
    OVER - TYPE 
;

\
\ assume at DIR-SAVE-DP begins an Array of Heap-Pointers that ends at HERE
\ each pointing a Heap area containing a directory entry, previously loaded.
\ emit the complete content of directory
: DIR-LIST ( -- )
    BASE @ DECIMAL
    0 0  DIR-BYTES 2!
    HERE DIR-SAVE-DP @ DO
        BEGIN ?ESCAPE NOT UNTIL
        ?TERMINAL IF LEAVE THEN
        I @  FAR  DIR-LIST-ITEM        
    2 +LOOP
    CR
    DIR-BYTES 2@ .FILE-SIZE 
    ."  Bytes  "
    HERE  DIR-SAVE-DP @ - 2/ . 
    ." files " 
    BASE !
;


: DIR-SHELL-SORT ( -- )
    HERE 2-  DIR-SAVE-DP @  
    2DUP - DIR-GAP 2+ !
    ?DO
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
            I DIR-GAP @ + @ FAR PAD 32 CMOVE \ element i+gap, copied to PAD:
                                              \ the FAR below may remap MMU7
                                              \ to a different page and
                                              \ invalidate this address
            I             @ FAR              \ element i
            PAD SWAP 32 (COMPARE) \ -1 when a[i+gap] < a[i]
            0< IF               \ exchange pointers, NOT strings!
                I 2+ @  I  @ 
                I 2+ !  I  ! 
                DROP 0   \ flag sorted false
            THEN
            ?TERMINAL IF LEAVE THEN
        2 +LOOP
        IF LEAVE THEN   \ leave outer loop if flag is true
        ?TERMINAL IF LEAVE THEN
        I show-progress \ 8 AND IF [CHAR] . EMIT 8 EMITC THEN \ flashing dot
    LOOP                       \ uses flag-sorted
;

.( .)

\ accept the following text (without quotes) as the path to be examined
\ this path-name is termporarily kept in PAD
: DIR-PAD ( -- cccc )
    HERE                        \ dp
    PAD C/L BLANK               \ dp -- useful for .PAD later
    PAD 1- DP !                 \ dp                          
\   PAD DP !                    \ dp                          
\   DIR-DRIVE C@ C,             \ dp
    BL WORD                     \ dp a
    C@ 1+ ALLOT                 \ dp  
    0 C,                        \ dp    
    DP !
\   [CHAR] : PAD 1+ C!
;

\ This operation requires at least 8K available in HEAP.
\ given a path-name in a, open such directory and put in HEAP each entry
\ matching WILDCARD-SPEC (filtered by NextZXOS itself via F_READDIR's a2 --
\ F_OPENDIR just requests wildcard mode).
\ Pointers are put at HERE and DP is advanced.
\ This will form a dynamic array starting from DIR-SAVE-DP to HERE -2
: DIR-TO-HEAP ( a -- )
    F_OPENDIR                       \ fh f 
    43 ?ERROR >R                    \    -- keep filehandle in R@
    HP@  DIR-SAVE-HP !              \    -- save HP for future forget/restore
    HERE DIR-SAVE-DP !              \    -- save DP for future forget/restore
    PAGE-WATERMARK SKIP-HP-PAGE     \    -- ensure to be at a new 8k page...
    BEGIN
\       here show-progress
        HERE                        \ a  -- use dictionary as temp area
        WILDCARD-SPEC               \ a a2 -- pattern read by F_READDIR
                                     \ (NextZXOS applies the filter here)
        R@ F_READDIR 
        46 ?ERROR      \ n
        ?TERMINAL NOT AND           \ f
    WHILE                           \    -- NextZXOS already filtered by pattern
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

\ given address filespec, process directory
\ It seems that the drive-letter must be always specified 
: DIR-SPEC ( a -- )
    .PAD SPACE
    DIR-TO-HEAP
    HERE DIR-SAVE-DP @ - 
    IF 
        DIR-SHELL-SORT
        SPACE DIR-LIST 
    ELSE
        #43 MESSAGE
    THEN        
    DIR-FREE
    WILDCARD-SPEC 32 -TRAILING TYPE 
    SPACE
;

\ forward definition to be called by DIR.
: DIR-CCCC ( -- cccc )
    DIR-PAD
    PAD 
    DIR-SPEC
;


\ this allows FORGET DIR to remove this whole package

' DIR-CCCC ' DIR >BODY !

BASE !
