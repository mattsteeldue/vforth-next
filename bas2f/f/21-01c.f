\ 21-01c.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/21-01.txt
\ guide: doc/basic-to-vforth/21-optional-features.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 .date
\   20 .time

\ --- the translation

\ 21-optional-features.md:133
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS ASK
ASK uname -m
PAD SWAP TYPE
