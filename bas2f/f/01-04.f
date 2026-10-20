\ 01-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/01-04.txt
\ guide: doc/basic-to-vforth/01-basic-programming-concepts.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 INPUT "Your name? ";n$
\   20 PRINT "Welcome, ";n$;"!"

\ --- the translation

\ 01-basic-programming-concepts.md:395
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: WELCOME  ( -- )
    ." Your name? "  PAD 20 ACCEPT 1-
    CR ." Welcome, "  PAD SWAP TYPE  ." !" ;
