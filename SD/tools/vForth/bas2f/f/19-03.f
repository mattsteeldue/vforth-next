\ 19-03.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/19-03.txt
\ guide: doc/basic-to-vforth/19-nextzxos-and-alternatives.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 MKDIR "games"
\   20 CD "games"
\   30 SAVE "maze.dat" CODE 32768,1024
\   40 CD ".."
\   50 CAT "games"

\ --- the translation

\ 19-nextzxos-and-alternatives.md:285
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS MAKEDIR  NEEDS CD  NEEDS DIR
NEEDS PAD"  NEEDS SAVE-BYTES
MAKEDIR games
CD games
PAD" maze.dat" 32768 1024 SAVE-BYTES
CD ..
DIR games
