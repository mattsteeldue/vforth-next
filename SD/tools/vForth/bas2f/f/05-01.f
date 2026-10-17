\ 05-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/05-read-data-restore-01.txt
\ guide: doc/basic-to-vforth/05-read-data-restore.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 READ w,h,d
\   20 PRINT w*h*d
\   30 DATA 2,3,4

\ --- the translation

\ 05-read-data-restore.md:173
CREATE BOX  2 , 3 , 4 ,
BOX @  BOX CELL+ @ *  BOX 2 CELLS + @ * .       \ => 24
