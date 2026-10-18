\ 12-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/12-04.txt
\ guide: doc/basic-to-vforth/12-conditions.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR n=0 TO 2
\   20   PRINT n;" item";("s" AND n<>1)
\   30 NEXT n

\ --- words defined earlier in the guide

\ 12-conditions.md:123
NEEDS S"
: ITEMS  ( n -- )
    DUP .  ." item"  S" s" ROT 1 <> AND TYPE ;
1 ITEMS                         \ => 1 item
3 ITEMS                         \ => 3 items

\ --- the translation

\ 12-conditions.md:240
: COUNTS  ( -- )  3 0 DO  I ITEMS SPACE  LOOP ;
COUNTS                          \ => 0 items 1 item 2 items
