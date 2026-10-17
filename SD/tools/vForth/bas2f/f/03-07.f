\ 03-07.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/03-looping-07.txt
\ guide: doc/basic-to-vforth/03-looping.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 LET n=1000: LET c=0
\   20 REPEAT: WHILE n>0
\   30   LET n=INT (n/2): LET c=c+1
\   40 REPEAT UNTIL 0
\   50 PRINT c

\ --- the translation

\ 03-looping.md:332
: HALVINGS  ( n -- count )
    0 SWAP
    BEGIN  DUP 0>  WHILE
        2/  SWAP 1+ SWAP
    REPEAT
    DROP ;
1000 HALVINGS .         \ => 10
0 HALVINGS .            \ => 0
