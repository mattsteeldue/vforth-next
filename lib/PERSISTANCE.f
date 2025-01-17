\
\ lib/persistance.f
\
\ v-Forth 1.8 - NextZXOS version - build 2025-01-01            
\ MIT License (c) 1990-2025 Matteo Vitturi     
\

.( PERSISTANCE ) 

\ save the complete current vForth status to blocks 

MARKER PERSISTANCE
NEEDS FLIP

\ given a memory address 'a' and a block number 'u'
\ restore data from block to memory
: RESTORE-FROM-BLOCK ( a u -- )
    BLOCK                       \ a a1
    SWAP                        \ a1 a
    B/BUF                       \ a1 a 512
    CMOVE 
;    

\ given a memory address 'a' and a block number 'u'
\ save data from memory to block
: SAVE-TO-BLOCK ( a u -- )
    BLOCK                       \ a a1
    UPDATE                      \ a a1
    B/BUF                       \ a a1 512
    CMOVE 
;    

\ based on flag f save or restore 512 bytes using
\ memory address a and block number u
: MANAGE-RW-BLOCK ( a u f -- )
    IF 
\       ." save to block " decimal u. ." addr " hex u. cr
        SAVE-TO-BLOCK
        $2E EMIT
    ELSE
\       ." restore from block " decimal u. ." addr " hex u. cr
        RESTORE-FROM-BLOCK
        $3C EMIT
    THEN
    decimal
;

\ starting block number where memory is dumped
\ Heap is stored in blocks from 32000 to 32127
\ User data to 32128, core from 32198 to 32415
\
#32000 CONSTANT HEAP-BLOCK-NUM 
#32080 CONSTANT CORE-BLOCK-NUM 

\ based on flag f save or restore the system
: MANAGE-PAGES ( f -- )
    \ manage heap-pages 1K per loop
    \ index counts half-K
    #128 0 DO 
\       i    u. 
        I    2* FLIP      FAR   \ f a
        I    HEAP-BLOCK-NUM +   \ f a u
        2 PICK                  \ f a u f
        MANAGE-RW-BLOCK         \ f
\       i 1+ u. 
        I 1+ 2* FLIP      FAR   \ f a
        I 1+ HEAP-BLOCK-NUM +   \ f a u+1
        2 PICK                  \ f a u f
        MANAGE-RW-BLOCK         \ f
        ?TERMINAL IF LEAVE THEN
    2 +LOOP
\   \ save main memory from $6300 to $D000
    $D0 $63 DO
\       i    u. 
        I    FLIP               \ f a
        I 2/ CORE-BLOCK-NUM +   \ f a u
        2 PICK                  \ f a u f
        MANAGE-RW-BLOCK         \ f
        ?TERMINAL IF LEAVE THEN
    2 +LOOP
    \ save USER zone
    $2E +ORIGIN @               \ f a
    HEAP-BLOCK-NUM 128 +        \ f a u
    ROT                         \ a u f
    MANAGE-RW-BLOCK 
;

: SAVE-SYSTEM    1 MANAGE-PAGES ;
: RESTORE-SYSTEM 1 MANAGE-PAGES ;
