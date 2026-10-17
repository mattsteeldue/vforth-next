\ 14-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/14-more-about-print-and-input-02.txt
\ guide: doc/basic-to-vforth/14-more-about-print-and-input.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "How many? ";n
\   20 PRINT n;" doubled is ";n*2

\ --- words defined earlier in the guide

\ 14-more-about-print-and-input.md:98
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
CREATE BUF 80 ALLOT
: INPUT$  ( -- a u )  BUF 80 ACCEPT 1-  BUF SWAP ;
." Your name? " INPUT$ CR ." Hello, " TYPE

\ 14-more-about-print-and-input.md:125
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: INPUT#  ( -- n )  INPUT$ EVALUATE ;
." How many? " INPUT# 2 * .

\ --- the translation

\ 14-more-about-print-and-input.md:258
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: DOUBLE  ( -- )
    ." How many? " INPUT# CR
    DUP . ." doubled is " 2 * . ;
