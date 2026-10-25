\
\ xnext.f
\
\ v-Forth 1.8 - NextZXOS version - 2026-10-25
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ XNEXT ( d1 -- d2 ): one step of the generator of NextBASIC's RND since
\ NextZXOS, Marsaglia's xorshift on 32 bits with the shifts 8, 9 and 23:
\   x ^= x<<8   x ^= x>>9   x ^= x<<23     (a state 0 is taken as 1)
\ Period 2^32-1.
\ Reference model: util/next-rnd.py.  planners/archive/NEXTBASIC-RND-PLAN.md
\
.( XNEXT )
\
\ The 32-bit state is D:E:H:L, D the highest byte: hi in DE, lo in HL.
CODE XNEXT  ( d1 -- d2 )
    $D9 C,          \ exx
    $D1 C,          \ pop  de       ; hi
    $E1 C,          \ pop  hl       ; lo
    $7C C,          \ ld   a, h
    $B5 C,          \ or   l
    $B2 C,          \ or   d
    $B3 C,          \ or   e
    $20 C, $01 C,   \ jr   nz, +1
    $2C C,          \ inc  l        ; 0 is taken as 1
    \ x ^= x<<8
    $7A C,          \ ld   a, d
    $AB C,          \ xor  e
    $57 C,          \ ld   d, a
    $7B C,          \ ld   a, e
    $AC C,          \ xor  h
    $5F C,          \ ld   e, a
    $7C C,          \ ld   a, h
    $AD C,          \ xor  l
    $67 C,          \ ld   h, a
    \ x ^= x>>9, a byte at a time from the bottom
    $7B C,          \ ld   a, e
    $0F C,          \ rrca          ; Cy = bit 0 of E
    $7C C,          \ ld   a, h
    $1F C,          \ rra
    $AD C,          \ xor  l        ; and Cy = 0
    $6F C,          \ ld   l, a
    $7A C,          \ ld   a, d
    $0F C,          \ rrca          ; Cy = bit 0 of D
    $7B C,          \ ld   a, e
    $1F C,          \ rra
    $AC C,          \ xor  h
    $67 C,          \ ld   h, a
    $7A C,          \ ld   a, d
    $1F C,          \ rra           ; Cy = 0 from the xor
    $AB C,          \ xor  e
    $5F C,          \ ld   e, a
    \ x ^= x<<23: L, shifted right by one, onto D; its bit 0 onto E
    $7C C,          \ ld   a, h
    $0F C,          \ rrca          ; Cy = bit 0 of H
    $7D C,          \ ld   a, l
    $1F C,          \ rra
    $AA C,          \ xor  d
    $57 C,          \ ld   d, a
    $7D C,          \ ld   a, l
    $0F C,          \ rrca
    $E6 C, $80 C,   \ and  $80
    $AB C,          \ xor  e
    $5F C,          \ ld   e, a
    $E5 C,          \ push hl       ; lo
    $D5 C,          \ push de       ; hi
    $D9 C,          \ exx
    $DD C, $E9 C,   \ jp (ix)
    SMUDGE
\
