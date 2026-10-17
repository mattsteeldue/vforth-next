\ 05-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/05-read-data-restore-05.txt
\ guide: doc/basic-to-vforth/05-read-data-restore.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 FOR i=1 TO 2
\   20   READ n$,p: PRINT n$;" ";p
\   30 NEXT i
\   40 DATA "tea",120,"cake",250

\ --- the translation

\ 05-read-data-restore.md:264
CREATE TEA   120 , ," tea"
CREATE CAKE  250 , ," cake"
: .ITEM  ( addr -- )
    DUP CELL+ COUNT TYPE SPACE
    @ . ;
TEA .ITEM                       \ => tea 120
CAKE .ITEM                      \ => cake 250
