\ 09-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/09-mathematical-functions-04.txt
\ guide: doc/basic-to-vforth/09-mathematical-functions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT SQR 2

\ --- the translation

\ 09-mathematical-functions.md:264
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
FLOATING
2.0 FSQRT F.                    \ => 1.4142e0
INTEGER
