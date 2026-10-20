\ 23-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/23-02.txt
\ guide: doc/basic-to-vforth/23-the-memory.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 BANK NEW a: BANK NEW b
\   20 BANK a ERASE 65
\   30 BANK a COPY TO b
\   40 LET c=BANK b PEEK 100: PRINT CHR$ c
\   50 BANK a CLEAR: BANK b CLEAR

\ --- words defined earlier in the guide

\ 23-the-memory.md:128
: PAGE-C!  ( b page off -- )
    $E000 +  SWAP  MMU7@ >R  MMU7!  C!  R> MMU7! ;
: PAGE-C@  ( page off -- b )
    $E000 +  SWAP  MMU7@ >R  MMU7!  C@  R> MMU7! ;
99 60 10 PAGE-C!  60 10 PAGE-C@ .   \ => 99

\ 23-the-memory.md:172
: PAGE-FILL  ( page c -- )
    SWAP  MMU7@ >R  MMU7!  $E000 8192 ROT FILL  R> MMU7! ;
CREATE XBUF 1024 ALLOT
: PAGE-COPY  ( from to -- )
    MMU7@ >R
    8192 0 DO
        OVER MMU7!  $E000 I +  XBUF  1024 CMOVE
        DUP  MMU7!  XBUF  $E000 I +  1024 CMOVE
    1024 +LOOP
    2DROP  R> MMU7! ;

\ --- the translation

\ 23-the-memory.md:264
60 65 PAGE-FILL  60 62 PAGE-COPY
62 100 PAGE-C@ EMIT             \ => A
