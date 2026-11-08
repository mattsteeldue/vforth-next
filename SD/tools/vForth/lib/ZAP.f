\
\ lib/ZAP.f
\

.( ZAP ) 

\ save a few files suitable to be used in a Basic loader 
\ for standalone execution of without vForth itself.

\ Usage:
\ ZAP filename

\ Example:
\ INCLUDE DEMO/CHOMP-CHOMP.F
\ NEEDS ZAP 
\ ZAP GAME
\
\ The image boots straight into cccc and can only leave through BYE:
\ at the end of cccc, and on any error (ERROR, ABORT, ABORT") too.
\ It is saved with WARNING at 0, so an error shows "msg#n" and never
\ looks for the block file. The live session is left as it was.
\
\ The heap is saved one 16K bank per file, as many as HP has reached:
\ cccc-heap.bin is bank 16, cccc-heap1.bin bank 17, and so on to 19.
\ A bank used for data beyond HP is not seen: save it by hand after
\ ZAP, with its BASIC number, e.g.   19 SAVE-BANK
\
\ NEEDS ZAP must come last: the image is the dictionary as it was just
\ before NEEDS ZAP (what the marker NO-ZAP would give back), so ZAP
\ itself, and anything defined after it, stays out of the deliverable.
\
\ Error #14 "Patching the wrong definition": COLD or ABORT are not in
\ the state ZAP expects (e.g. a previous ZAP was interrupted).
\ Error #10 "Wrong array index": SAVE-BANK takes 16, 17, 18 or 19.
\ Error #67 "defined after NEEDS ZAP": the word to launch would not be
\ in the image.  Message #67 is reserved here.

MARKER NO-ZAP

NEEDS [']

BASE @

DECIMAL

VARIABLE LEN
\ a name is 31 characters at most (WIDTH): the longest suffix fits
CREATE FN 48 ALLOT

CREATE S-CORE   ," -core.bin"  
CREATE S-USER   ," -user.bin"  
CREATE S-HEAP   ," -heap.bin"  
\ the digit is set by SAVE-BANK
CREATE S-HEAP-N ," -heap1.bin"

8192 CONSTANT PAGE-SIZE


\ Display FN string
: .FN ( -- )
    FN 48 TYPE CR
;


\ address of the first cell holding xt2
\ in the body of the colon-definition xt1
\ it steps by bytes: an inline string (ERROR has one) shifts the cells
: CELL-OF ( xt1 xt2 -- a )
    SWAP >BODY                  \ xt2 a
    BEGIN
        2DUP @ -
    WHILE
        1+
    REPEAT
    NIP
;


\ The cells a standalone image needs changed:
\ COLD begins with two NOOPs, there to be patched;
\ ERROR ends in QUIT;
\ ABORT ends in NOOP (it was AUTOEXEC at first boot) and QUIT.
' COLD >BODY                    CONSTANT COLD-SLOT
' ERROR ' QUIT CELL-OF          CONSTANT ERROR-SLOT
' ABORT ' QUIT CELL-OF CELL-    CONSTANT ABORT-SLOT

\ the QUIT found in ERROR is the real one if EXIT follows it
ERROR-SLOT CELL+ @ ' EXIT - 14 ?ERROR


\ The dictionary before NEEDS ZAP.  MARKER (L3.asm) keeps in the body
\ of NO-ZAP: VOC-LINK, CURRENT, CONTEXT, the NFA of NO-ZAP itself (HP
\ then) and the LATEST NO-ZAP replaced; DP then is where NO-ZAP starts.
' NO-ZAP >BODY                  CONSTANT ZAP-MARK
' NO-ZAP 2-                     CONSTANT ZAP-LIMIT

\ the live values of the cells ZAP-IMAGE replaces
CREATE ZAP-LIVE-CELLS 12 ALLOT


\ give the session the dictionary of the image: the one before NEEDS
\ ZAP, as NO-ZAP would, but keeping the live values in ZAP-LIVE-CELLS.
\ DP goes down too, so PAD with it: nothing may use PAD meanwhile.
: ZAP-IMAGE ( -- )
    ZAP-LIVE-CELLS >R
    VOC-LINK @  R@        !     ZAP-MARK            @ VOC-LINK !
    CURRENT @   R@ 2+     !     ZAP-MARK 2+         @ CURRENT !
    CONTEXT @   R@ 4 +    !     ZAP-MARK 4 +        @ CONTEXT !
    HP @        R@ 6 +    !     ZAP-MARK 6 +        @ HP !
    DP @        R@ 8 +    !     ZAP-LIMIT             DP !
    CURRENT @ @ R> 10 +   !     ZAP-MARK 8 +        @ CURRENT @ !
;


\ and give the live session its dictionary back
: ZAP-LIVE ( -- )
    ZAP-LIVE-CELLS >R
    R@ 10 + @ CURRENT @ !
    R@ 8 +  @ DP !
    R@ 6 +  @ HP !
    R@ 4 +  @ CONTEXT !
    R@ 2+   @ CURRENT !
    R>      @ VOC-LINK !
;


\ true if COLD or ABORT are not as a live session keeps them
: ?PATCHED ( -- f )
    COLD-SLOT       @ ['] NOOP -
    COLD-SLOT CELL+ @ ['] NOOP - OR
    ABORT-SLOT      @ ['] NOOP - OR
;


\ make the image run xt at COLD and leave through BYE,
\ never through the QUIT prompt
: ZAP-PATCH ( xt -- )
    COLD-SLOT !
    ['] BYE COLD-SLOT CELL+ !
    ['] BYE ERROR-SLOT !
    ['] BYE ABORT-SLOT !
;


\ give the live session its own cells back
: ZAP-UNPATCH ( -- )
    ['] NOOP COLD-SLOT !
    ['] NOOP COLD-SLOT CELL+ !
    ['] QUIT ERROR-SLOT !
    ['] NOOP ABORT-SLOT !
;


\ open file named in FN
\ it creates a new file, or overwrite it
\ return file-handle
: ZAP-OPEN ( -- fh )
    FN PAD 10 - %1110 F_OPEN    \ u f
    \ test for NextZXOS Open error
    41 ?ERROR                   \ u
;


\ given a counted string, compose filename
\ return filehandle
: OPEN-FN ( a -- fh )
    COUNT 1+                \ a1 n      the NUL of ," comes along
    FN LEN @ +              \ a1 n a2
    SWAP CMOVE              
    ZAP-OPEN 
    .FN 
;


\ write chunk, return the error flag only
: WRITE ( a n fh -- f )
    F_WRITE NIP
;


\ close filehandle, then report a write error f, or a close error
: CLOSE-CHECK ( f fh -- )
    F_CLOSE                 \ f1 f2
    SWAP 47 ?ERROR
    42 ?ERROR
;


\ write chunk and close filehandle
: WRITE-CLOSE ( a n fh -- )
    DUP >R WRITE
    R> CLOSE-CHECK
;


\ save core part in file "cccc-core.bin", up to ZAP-LIMIT
\ the patch lasts for the write alone: no error can be raised meanwhile
\ the latest-word cell of CURRENT is in the core: ZAP-IMAGE sets it
: SAVE-CORE ( xt -- )
    S-CORE                  \ xt a
    OPEN-FN >R              \ xt
    ZAP-PATCH ZAP-IMAGE     \
    0 +ORIGIN HERE OVER -   \ a n
    R@ WRITE                \ f
    ZAP-LIVE ZAP-UNPATCH
    R> CLOSE-CHECK
;


\ save user part in file "cccc-user.bin"
\ WARNING is 0 for the write alone, as for the patch in SAVE-CORE
: SAVE-USER ( -- )
    \ no buffer may be left marked for update in the image
    FLUSH
    S-USER                  \ a
    OPEN-FN >R              \
    WARNING @  0 WARNING !  \ w
    ZAP-IMAGE               \ w     DP, HP and the vocabularies
    R0 @ $E000 OVER -       \ w a n
    R@ WRITE                \ w f
    ZAP-LIVE
    SWAP WARNING !          \ f
    R> CLOSE-CHECK
;


\ counted suffix of the file for heap bank u (0 to 3)
: HEAP-SUFFIX ( u -- a )
    DUP IF
        48 + S-HEAP-N 6 + C!
        S-HEAP-N
    ELSE
        DROP S-HEAP
    THEN
;


\ save the 16K bank n (16 to 19, as BASIC numbers them) in file
\ "cccc-heap.bin" for bank 16, "cccc-heapu.bin" for bank 16+u
\ a bank is two 8K pages: each one is mapped just before its write
: SAVE-BANK ( n -- )
    16 -                    \ u
    3 OVER U< 10 ?ERROR
    DUP HEAP-SUFFIX         \ u a
    OPEN-FN >R              \ u
    14 LSHIFT               \ ha
    DUP FAR PAGE-SIZE       \ ha a7 n
    R@ WRITE                \ ha f
    SWAP PAGE-SIZE +        \ f ha
    FAR PAGE-SIZE           \ f a7 n
    R@ WRITE OR             \ f
    R> CLOSE-CHECK
;


\ number of 16K banks the heap of the image takes, HP included: the HP
\ before NEEDS ZAP, the one saved in "cccc-user.bin"
\ a BASIC loader gets the same from the image: INT (hp/16384)+1
: HEAP-BANKS ( -- n )
    ZAP-MARK 6 + @ 14 RSHIFT 1+
;


\ save bank # 16 and successors
: SAVE-HEAP ( -- )
    HEAP-BANKS 0 DO
        I 16 + SAVE-BANK
    LOOP
;


: ZAP ( -- cccc )
    '                       \ xt
    DUP ZAP-LIMIT U< 0= 67 ?ERROR
    ?PATCHED 14 ?ERROR
    FN 48 ERASE
    HERE COUNT LEN !        \ a1
    FN LEN @ CMOVE
    .( SAVE "HEAP" BANK 16 TO ) HEAP-BANKS 15 + . CR
    .( SAVE "CORE" CODE ) ZAP-LIMIT 0 +ORIGIN DUP U. - U. CR
    .( SAVE "USER" CODE ) $E000 R0 @     DUP U. - U. CR
    SAVE-CORE
    SAVE-USER
    SAVE-HEAP
;


BASE !
