\ 18-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/18-03.txt
\ guide: doc/basic-to-vforth/18-sound-and-music.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PLAY "c","e","g"

\ --- the translation

\ 18-sound-and-music.md:322
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS PLAY
S" c" S" e" S" g" 3 PLAY
