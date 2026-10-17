\ 13-04.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/13-the-character-set-04.txt
\ guide: doc/basic-to-vforth/13-the-character-set.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT "EVIL"<"evil"

\ --- the translation

\ 13-the-character-set.md:172
NEEDS COMPARE
NEEDS S"
: E1  S" EVIL" S" evil" COMPARE . ;
: E2  S" zoo" S" zoology" COMPARE . ;
: E3  S" AA man" S" AARDVARK" COMPARE . ;
E1 E2 E3                        \ => 0 -1 -1
CASEON
E1                              \ => -1
\ an error in the guide, it would end the INCLUDE:
\ dup                             \ => dup? is undefined.
CASEOFF
