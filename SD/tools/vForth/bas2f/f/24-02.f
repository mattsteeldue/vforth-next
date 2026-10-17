\ 24-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/24-the-system-variables-02.txt
\ guide: doc/basic-to-vforth/24-the-system-variables.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 POKE 23658,% PEEK 23658^8
\   20 IF % PEEK 23658&8 THEN PRINT "CAPS LOCK on": STOP
\   30 PRINT "CAPS LOCK off"

\ --- the translation

\ 24-the-system-variables.md:147
: CAPS  ( -- )  23658 C@ 8 XOR 23658 C! ;
: .CAPS  ( -- )
    ." CAPS LOCK "  23658 C@ 8 AND IF ." on" ELSE ." off" THEN ;
CAPS .CAPS                      \ => CAPS LOCK on
CAPS .CAPS                      \ => CAPS LOCK off
