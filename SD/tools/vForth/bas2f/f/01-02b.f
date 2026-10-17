\ 01-02b.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/01-basic-programming-concepts-02.txt
\ guide: doc/basic-to-vforth/01-basic-programming-concepts.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 REM inches to millimetres
\   20 INPUT "Inches? ";i
\   30 PRINT i;" in = ";i*25.4;" mm"
\   40 GO TO 20

\ --- words defined earlier in the guide

\ 01-basic-programming-concepts.md:337
: >MM  ( inches -- mm )  254 10 */ ;
12 >MM .                        \ => 304

\ --- the translation

\ 01-basic-programming-concepts.md:348
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
: INPUT#  ( -- n )
    PAD 1+ 20 ACCEPT  1- PAD C!
    BL PAD COUNT + C!
    PAD NUMBER DROP ;
: CONVERT  ( -- )
    BEGIN
        CR ." Inches? " INPUT#
    ?DUP WHILE
        DUP . ." in = " >MM . ." mm"
    REPEAT ;
