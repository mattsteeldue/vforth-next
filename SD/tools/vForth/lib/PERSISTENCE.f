\
\ lib/persistence.f
\
\ v-Forth 1.8 - NextZXOS version - build 2025-03-15
\ MIT License (c) 1990-2025 Matteo Vitturi     
\

( PERSISTENCE ) 

\ Save the complete current vForth status to blocks 
\ This must be the very first definition loaded just after a COLD start
\ this way these definitions are always at lower address than any subsequent 
\ loading.

\ Use SAVE-SYSTEM one first time to enable it.
\ Use NO-PERSISTENCE to disable.

\ Block-numbers where RAM is dumped to
\ Normal version:
\ User data: 32000
\ Core data: 32001 - 32040
\ Heap data: 32048 - 32175
\ Dot-version:
\ User data: 32200
\ Core data: 32201 - 32040 
\ Heap data: 32291 - 32375


MARKER PERSISTENCE-CLEAN-UP

\ normal version has origin >$4000, dot version <$4000
\ and uses 200 blocks higher than normal version
0 +ORIGIN $4000 > 1+ #200 *
#32000 + CONSTANT PERSISTENCE

\ must be keep track of the latest definition pointer 
' FORTH >BODY CELL+ 
CONSTANT FORTH-POINTER

\ user data pointer
$2E +ORIGIN @
CONSTANT USER-POINTER

\ Disable persistence
: NO-PERSISTENCE
    0 PERSISTENCE BLOCK !
    UPDATE FLUSH
;

.( .)

\ Clear blocks used by persistence
: CLEAR-BLOCKS
    PERSISTENCE #176 +
    PERSISTENCE 
    DO 
        I BLOCK B/BUF ERASE UPDATE
    LOOP    
;
 
\ given a memory address 'a' and a block number 'u'
\ restore data from block to memory
\ any FAR 8k-paging must be done in advance
: RESTORE-FROM-BLOCK ( a u -- )
    BLOCK                       \ a a1
    SWAP                        \ a1 a
    B/BUF CMOVE 
;    

\ given a memory address 'a' and a block number 'u'
\ save data from memory to block
\ any FAR 8k paging must be performed beforehand
: SAVE-TO-BLOCK ( a u -- )
    BLOCK                       \ a a1
    B/BUF CMOVE 
    UPDATE FLUSH
;    

\ based on flag f, save (true) or restore (false) 512 bytes 
\ using memory address a and block number u
: MANAGE-RW-BLOCK ( f a u -- )
    ROT IF                      \ a u f
    \   [ CHAR > ] LITERAL EMIT \ a u
    \   2DUP CR DECIMAL U. HEX U.           
        SAVE-TO-BLOCK
    ELSE
    \   [ CHAR < ] LITERAL EMIT \ a u
    \   2DUP CR DECIMAL U. HEX U.           
        RESTORE-FROM-BLOCK
        \ or COMPARE-BLOCK for test 
    THEN
    \ ?TERMINAL IF ABORT THEN
;

.( .)

\ given flag f and core address, save or restore 512-bytes page
\ block number is computed from FENCE upward. 
: MANAGE-CORE-PAGE ( f a -- )
    DUP FENCE @ - 9 RSHIFT      \ f a b
    PERSISTENCE 1+ +            \ f a u
    MANAGE-RW-BLOCK             \ f
;

\ given flag f and heap address, save or restore 512-bytes page
\ block number is computed using heap-address
: MANAGE-HEAP-PAGE ( f hp -- )
    DUP 9 RSHIFT                \ f hp b
    PERSISTENCE #48 + +         \ f hp u
    SWAP FAR SWAP               \ f a u
    MANAGE-RW-BLOCK   
;

\ manage user data
\ uses single block 32000 (or 32200)
: MANAGE-USER-DATA ( f -- )
    PERSISTENCE BLOCK           \ f blk
    USER-POINTER                \ f blk usr
    ROT DUP >R                  \   blk urs f
    IF                          \   blk usr
        SWAP                    \   usr blk
        \ save forth latest
        FORTH-POINTER @         \   usr blk latest
        USER-POINTER !          \   usr blk 
    THEN                        \   a1  a2       
    #28 CMOVE  \ only 14 user variables are needed
    R> IF
        UPDATE FLUSH 
    ELSE
        \ restore forth latest
        USER-POINTER @
        FORTH-POINTER !
    THEN
;

.( .)

\ based on flag f save or restore the system
: MANAGE-PAGES ( f -- )
    DUP MANAGE-USER-DATA        \ f
    \ manage allocated heap
    HP@ 0                       \ f hp 0
    DO                          \ f
        DUP I MANAGE-HEAP-PAGE  \ f
    B/BUF +LOOP                 \ f
    \ manage dictionary
    HERE FENCE @                \ f a2 a1
    DO                          \ f 
        DUP I MANAGE-CORE-PAGE  \ f
    B/BUF +LOOP
    MANAGE-USER-DATA
;

\ restore the last session if any

: RESTORE-SYSTEM 
    PERSISTENCE BLOCK @ 
    IF
        0 MANAGE-PAGES 
    \   HERE #34 BLANK
        .( ok) QUIT
    ELSE
        PERSISTENCE-CLEAN-UP
    THEN    
;

\ enable persistence and save session

: SAVE-SYSTEM
    1 MANAGE-PAGES 
;

\ patch to BYE to perform a save-system before exiting to basic

  WARNING @ 
0 WARNING !
: BYE
    PERSISTENCE BLOCK @ 
    IF
        SAVE-SYSTEM
    THEN
    BYE
; WARNING !


MARKER AND-CLEAN-UP

\ cleanup screen
: SOME-BLANKS ( n -- )
    0 DO 
        SPACE
    LOOP
;

: SOME-BACKSPACES
    0 DO 
        8 EMITC
    LOOP
;

14 DUP DUP 
SOME-BACKSPACES
SOME-BLANKS 
SOME-BACKSPACES
AND-CLEAN-UP

