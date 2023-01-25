\
\ rnd.f  
\
\ RND equivalent
\ random number generator from the sequence n --> (75*(n+1) % 65537)-1
\
\ This piece of code exploits the fact (d % 65537) is equivalent to subtracting 
\ the higher 16-bit part from the lower 16-bit part, but for a boundary 
\ condition resolved by adding 1, depending on which 16-bit part is bigger.
\ 
\
.( RND )
\
BASE @

HEX

\ Input:  HL -- current SEED is passed in HL
\ Output: HL -- next SEED will be HL too
\ 
\     H   L  x
\        75  = 
\ ---------  
\ H   L       <-- first  mul
\     D   E   <-- second mul 
\       +75   <-- add de,a 
\ ---------
\ L   D   E
\   
CODE NEXT-SEED ( n1 -- n2 )
    D9 C,           \ exx
    E1 C,           \ pop  hl
    3E C, 4B C,     \ ld   a, 75
    54 C,           \ ld   d, h
    5F C,           \ ld   e, a   ;  75  
    ED C, 30 C,     \ mul           
    EB C,           \ ex   de, hl
    57 C,           \ ld   d, a   ;  75
    ED C, 30 C,     \ mul  
    ED C, 32 C,     \ add  de, a  ; +75
    7A C,           \ ld   a, d
    ED C, 31 C,     \ add  hl, a  ; sum middle L+D
    55 C,           \ ld   d, l   ; so that product is L D E
    6C C,           \ ld   l, h
    AF C,           \ xor  a
    67 C,           \ ld   h, a   ; and H is always zero.
    EB C,           \ ex   de, hl 
    ED C, 52 C,     \ sbc  hl, de ; this emulates MOD 65537 with carry.
    11 C, FFFF ,    \ ld   de, $FFFF
    ED C, 5A C,     \ adc  hl, de ; subtract 1 if not-carry
    E5 C,           \ push hl       
    D9 C,           \ exx
    DD C, E9 C,     \ jp (ix)
SMUDGE    

DECIMAL

\
\ gives a pseudo-random number between 0 and u-1
: RND ( u -- u2 )
    23670           \ u a         \ address of "SEED" system variable 
    DUP @           \ u a n
    NEXT-SEED       \ u a n       \ n --> (75*(n+1) % 65537)-1  
    TUCK            \ u n a n
    SWAP !          \ u n         \ store back to SEED
    UM* NIP         \ u1
;

BASE !
\
