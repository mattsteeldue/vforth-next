\
\ DMA.f
\

.( DMA - zxnDMA support )

NEEDS SPLIT

\ hex literals use the $ prefix and BASE is never changed: in HEX a token
\ such as BB is found first as a word (BB of lib/editor.f, autoexec)

MARKER NO-DMA

\ Port address constant
$6B CONSTANT DMA-PORT

\ Low-level primitives
: DMA! ( b -- )
    DMA-PORT P! ;

: DMA@ ( -- b )
    DMA-PORT P@ ;

: DMA-W ( n -- )
    SPLIT SWAP DMA! DMA! ;

\ WR0 register bytes - direction and parameter bits
$7D CONSTANT DMA-WR0-A2B     \ A->B, append both A addr and length
$79 CONSTANT DMA-WR0-B2A     \ B->A, append both A addr and length

\ WR1 register bytes - Port A configuration
$14 CONSTANT DMA-A-MEM-INCR  \ A=memory, address increments
$24 CONSTANT DMA-A-MEM-FIXED \ A=memory, address fixed

\ WR2 register bytes - Port B configuration
$10 CONSTANT DMA-B-MEM-INCR  \ B=memory, address increments
$28 CONSTANT DMA-B-IO-FIXED  \ B=I/O, address fixed

\ WR4 register bytes - Port B address (continuous mode)
$AD CONSTANT DMA-WR4-CONT    \ continuous mode, append B address

\ WR5 register byte - CE only, stop on end of block
$82 CONSTANT DMA-WR5-DEFAULT

\ WR6 command register bytes
$83 CONSTANT DMA-CMD-DISABLE
$87 CONSTANT DMA-CMD-ENABLE
$8B CONSTANT DMA-CMD-RESET-STATUS
$A7 CONSTANT DMA-CMD-INIT-READ-SEQ
$BB CONSTANT DMA-CMD-READ-MASK
$BF CONSTANT DMA-CMD-READ-STATUS
$C3 CONSTANT DMA-CMD-RESET
$C7 CONSTANT DMA-CMD-RESET-A-TIMING
$CB CONSTANT DMA-CMD-RESET-B-TIMING
$CF CONSTANT DMA-CMD-LOAD
$D3 CONSTANT DMA-CMD-CONTINUE

\ Module state - shadow registers and scratch buffers
VARIABLE DMA-A-ADDR   \ Port A address parameter
VARIABLE DMA-B-ADDR   \ Port B address parameter
VARIABLE DMA-LEN      \ Transfer length parameter

CREATE DMA-FILL-BYTE 1 ALLOT  \ single-byte buffer for FILL operations

\ Helper: write WR0 (direction, addresses, length)
: (DMA-WR0) ( aAddr len dir -- )
    IF
        DMA-WR0-A2B
    ELSE
        DMA-WR0-B2A
    THEN
    DMA!
    SWAP        \ WR0 wants A address first, then length
    DMA-W   \ aAddr (LSB, MSB)
    DMA-W   \ len (LSB, MSB)
;

\ Helper: write WR4 (continuous mode, port B address)
: (DMA-WR4) ( bAddr -- )
    DMA-WR4-CONT DMA!
    DMA-W
;

\ Helper: Load addresses and enable DMA
: (DMA-START)
    DMA-CMD-LOAD DMA!
    DMA-CMD-ENABLE DMA!
;

\ === Public Control Words (WR6 commands) ===

: DMA-DISABLE
    DMA-CMD-DISABLE DMA! ;

: DMA-ENABLE
    DMA-CMD-ENABLE DMA! ;

: DMA-LOAD
    DMA-CMD-LOAD DMA! ;

: DMA-CONTINUE
    DMA-CMD-CONTINUE DMA! ;

: DMA-RESET
    DMA-CMD-RESET DMA! ;

: DMA-RESET-STATUS
    DMA-CMD-RESET-STATUS DMA! ;

: DMA-STATUS ( -- b )
    DMA-CMD-READ-MASK DMA!
    $01 DMA!                   \ read mask: status byte only
    DMA-CMD-INIT-READ-SEQ DMA! \ reset read sequence to first masked reg
    DMA@ ;                     \ read status from DMA port

: DMA-DONE? ( -- flag )
    DMA-STATUS
    $20 AND 0= ;    \ bit 5 = 0 when done

\ === Public Transfer Words (continuous mode) ===

\ Copy from memory to memory
\ A increments over source, B increments over destination
: DMA-COPY ( src dest len -- )
    DMA-CMD-DISABLE DMA!
    DMA-LEN !  DMA-B-ADDR !  DMA-A-ADDR !

    DMA-A-ADDR @ DMA-LEN @ 1 (DMA-WR0)   \ WR0: A->B
    DMA-A-MEM-INCR DMA!                   \ WR1: A memory, increment
    DMA-B-MEM-INCR DMA!                   \ WR2: B memory, increment
    DMA-B-ADDR @ (DMA-WR4)                \ WR4: B address (continuous)
    DMA-WR5-DEFAULT DMA!                  \ WR5: standard config
    (DMA-START)
;

\ Fill destination with constant byte
\ A is fixed on DMA-FILL-BYTE buffer, B increments over destination
: DMA-FILL ( byte dest len -- )
    DMA-CMD-DISABLE DMA!
    DMA-LEN !  DMA-B-ADDR !
    DMA-FILL-BYTE C!
    DMA-FILL-BYTE DMA-A-ADDR !

    DMA-A-ADDR @ DMA-LEN @ 1 (DMA-WR0)   \ WR0: A->B
    DMA-A-MEM-FIXED DMA!                  \ WR1: A memory, fixed
    DMA-B-MEM-INCR DMA!                   \ WR2: B memory, increment
    DMA-B-ADDR @ (DMA-WR4)                \ WR4: B address (continuous)
    DMA-WR5-DEFAULT DMA!                  \ WR5: standard config
    (DMA-START)
;

\ Write from memory to I/O port
\ A increments over source memory, B is fixed on I/O port
: DMA-OUT ( src ioport len -- )
    DMA-CMD-DISABLE DMA!
    DMA-LEN !  DMA-B-ADDR !  DMA-A-ADDR !

    DMA-A-ADDR @ DMA-LEN @ 1 (DMA-WR0)   \ WR0: A->B
    DMA-A-MEM-INCR DMA!                   \ WR1: A memory, increment
    DMA-B-IO-FIXED DMA!                   \ WR2: B I/O, fixed
    DMA-B-ADDR @ (DMA-WR4)                \ WR4: B address (continuous)
    DMA-WR5-DEFAULT DMA!                  \ WR5: standard config
    (DMA-START)
;

\ Read from I/O port to memory
\ A is incremented over destination memory, B is fixed on I/O port
\ Direction is B->A (0)
: DMA-IN ( ioport dest len -- )
    DMA-CMD-DISABLE DMA!
    DMA-LEN !  DMA-A-ADDR !  DMA-B-ADDR !

    DMA-A-ADDR @ DMA-LEN @ 0 (DMA-WR0)   \ WR0: B->A (input)
    DMA-A-MEM-INCR DMA!                   \ WR1: A memory, increment
    DMA-B-IO-FIXED DMA!                   \ WR2: B I/O, fixed
    DMA-B-ADDR @ (DMA-WR4)                \ WR4: B address (continuous)
    DMA-WR5-DEFAULT DMA!                  \ WR5: standard config
    (DMA-START)
;

\ NEEDS guard: defined last so NEEDS DMA succeeds only after a full load
: DMA ;

