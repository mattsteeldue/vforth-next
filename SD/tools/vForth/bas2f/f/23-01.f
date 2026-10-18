\ 23-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/23-01.txt
\ guide: doc/basic-to-vforth/23-the-memory.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 BANK NEW b
\   20 BANK b POKE 10,99
\   30 BANK b POKE 20,77
\   40 LET x=BANK b PEEK 10: LET y=BANK b PEEK 20
\   50 PRINT x,y
\   60 BANK b CLEAR

\ --- words defined earlier in the guide

\ 23-the-memory.md:128
: PAGE-C!  ( b page off -- )
    $E000 +  SWAP  MMU7@ >R  MMU7!  C!  R> MMU7! ;
: PAGE-C@  ( page off -- b )
    $E000 +  SWAP  MMU7@ >R  MMU7!  C@  R> MMU7! ;
99 60 10 PAGE-C!  60 10 PAGE-C@ .   \ => 99

\ 23-the-memory.md:146
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: NEW-PAGE  ( -- page )
    1 0 0 0 $01BD M_P3DOS  40 ?ERROR  2DROP NIP 255 AND ;
: FREE-PAGE  ( page -- )
    3 SWAP 0 0 $01BD M_P3DOS  44 ?ERROR  2DROP 2DROP ;

\ --- the translation

\ 23-the-memory.md:240
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: TRY-PAGE  ( -- )
    NEW-PAGE
    99 OVER 10 PAGE-C!
    77 OVER 20 PAGE-C!
    DUP 10 PAGE-C@ .  DUP 20 PAGE-C@ .  CR
    FREE-PAGE ;
TRY-PAGE
