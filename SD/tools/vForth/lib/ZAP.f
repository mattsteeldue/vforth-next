\
\ lib/zap.f
\

.( ZAP ) 

\ save a few files suitable to be used in a Basic loader 
\ for standalone execution of without vForth itself.

\ Usage:
\ ZAP filename

\ Example:
\ INCLUDE DEMO/CHOMP-CHOMP.F
\ NEEDS ZAP 
\ ZAP CHOMP-CHOMP

MARKER TASK

BASE @

DECIMAL

VARIABLE LEN
VARIABLE FH
CREATE FN 48 ALLOT

CREATE S-CORE   ," -core.bin"  
CREATE S-USER   ," -user.bin"  
CREATE S-HEAP   ," -heap.bin"  
CREATE S-HEAP-1 ," -heap1.bin"  
CREATE S-HEAP-2 ," -heap2.bin"  
CREATE S-HEAP-3 ," -heap3.bin"  

8192 CONSTANT PAGE-SIZE


\ Display FN string
: .FN ( -- )
    FN 48 TYPE CR
;


\ open file named in FN
\ it creates a new file, or overwrite it
\ return file-handle
: OPEN> ( -- fh )
    FN PAD 10 - %1110 F_OPEN    \ u f
    \ test for NextZXOS Open error
    41 ?ERROR                   \ u
;


\ given a counted string, compose filename
\ return filehandle
: OPEN-FN ( a -- fh )
    COUNT            \ a1 n
    FN LEN @ +              \ a1 n a2
    SWAP CMOVE              
    OPEN> 
    .FN 
;


\ write chunk and close filehandle
: WRITE-CLOSE ( a n fn -- )
    DUP >R F_WRITE 47 ?ERROR  
    R> F_CLOSE 42 ?ERROR
;


\ save core part in file "cccc-core.bin"
: SAVE-CORE ( -- )
    S-CORE                  \ a  
    OPEN-FN >R              \
    0 +ORIGIN HERE OVER -   \ a n
    R> WRITE-CLOSE
;


\ save user part in file "cccc-user.bin"
: SAVE-USER ( -- )
    \ fill 7 buffers with error messages.
    17 8 DO I BLOCK DROP LOOP
    S-USER                  \ a
    OPEN-FN >R              \ 
    R0 @ $E000 OVER -       \ a n
    R> WRITE-CLOSE      
;


\ save bank # 16 and successors
: SAVE-HEAP ( -- )
    \ save bank # 16 
    S-HEAP                  \ a  
    OPEN-FN >R              \
    $0000 FAR PAGE-SIZE     \ a7 n
    R@ F_WRITE 47 ?ERROR
    $2000 FAR PAGE-SIZE     \ a7 n
    R> WRITE-CLOSE
    
\   $4000 HP@ < IF
\       \ save bank # 17
\       S-HEAP-1                \ a  
\       OPEN-FN >R              \ fh
\       $4000 FAR PAGE-SIZE 
\       R@ F_WRITE 47 ?ERROR
\       $6000 FAR PAGE-SIZE 
\       R> WRITE-CLOSE
\   THEN
\
\   $8000 HP@ < IF
\       \ save bank # 18
\       S-HEAP-2                \ a  
\       OPEN-FN >R              \ fh
\       $8000 FAR PAGE-SIZE 
\       R@ F_WRITE 47 ?ERROR
\       $A000 FAR PAGE-SIZE 
\       R> WRITE-CLOSE
\   THEN
\
\   $C000 HP@ < IF
\       \ save bank # 19
\       S-HEAP-3                \ a  
\       OPEN-FN >R              \ fh
\       $C000 FAR PAGE-SIZE 
\       R@ F_WRITE 47 ?ERROR
\       $E000 FAR PAGE-SIZE 
\       R> WRITE-CLOSE
\   THEN
;


: FILENAME ( -- cccc )
    FN 48 ERASE
    BL WORD                 \ a1
    COUNT LEN !             \ a1 
    FN LEN @ CMOVE
;


: ZAP
    '                       \ xt 
    ['] COLD >BODY !
    ['] BYE                 \ 'BYE
    ['] COLD >BODY CELL+ !
    FN 48 ERASE
    HERE COUNT LEN !        \ a1
    FN LEN @ CMOVE
    .( SAVE "HEAP" BANK 16 ) CR
    .( SAVE "CORE" CODE ) HERE 0 +ORIGIN DUP U. - U. CR
    .( SAVE "USER" CODE ) $E000 R0 @     DUP U. - U. CR
    SAVE-CORE
    SAVE-USER
    SAVE-HEAP
;


BASE !
