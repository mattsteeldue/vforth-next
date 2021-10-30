\
\ roll.f
\

.( ROLL )

NEEDS CODE      \ just to be sure we are fine

HEX

\ Roll the nth item to the top of the stack, moving the others
\ down. Zero based, (eg., 1 ROLL is SWAP, 2 ROLL is ROT).

CODE ROLL  ( n1 n2 .. nk k -- n2 .. nk n1  )
    D9  C,           \  exx                     // we need all registers free
    E1  C,           \  pop     hl              // number of cells to roll
    7C  C,           \  ld      a, h
    B5  C,           \  or       l
    28  C,  13  C,   \  jr      z, Roll_Zero
    29  C,           \      add     hl, hl      // number of bytes to move
    44  C,           \      ld      b, h
    4D  C,           \      ld      c, l
    39  C,           \      add     hl, sp      // address of n1
    7E  C,           \      ld      a, (hl)     // take n1 into a and a'
    23  C,           \      inc     hl
    08  C,           \      ex      af, af'
    7E  C,           \      ld      a, (hl)     // take n1 into a and a'
    54  C,           \      ld      d, h
    5D  C,           \      ld      e, l
    2B  C,           \      dec     hl
    2B  C,           \      dec     hl
    ED  C,  B8  C,   \      lddr
    EB  C,           \      ex      de, hl
    77  C,           \      ld      (hl), a
    2B  C,           \      dec     hl
    08  C,           \      ex      af, af'
    77  C,           \      ld      (hl), a
                     \  Roll_Zero:
    D9  C,           \  exx
    DD  C,  E9  C,   \  jp      (ix)
    
    FORTH
    SMUDGE
    DECIMAL
