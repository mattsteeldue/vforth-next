\ 19-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/19-02.txt
\ guide: doc/basic-to-vforth/19-nextzxos-and-alternatives.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT "Hello"

\ --- the translation

\ 19-nextzxos-and-alternatives.md:237
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: HELLO  ( -- )  ." Hello" CR ;
HELLO
