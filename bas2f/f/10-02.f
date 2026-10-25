\ 10-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/10-02.txt
\ guide: doc/basic-to-vforth/10-random-numbers.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 PRINT 10+RND (11)

\ --- the translation

\ 10-random-numbers.md:190
: RND-IN  ( lo hi -- n )  OVER - 1+ RND + ;
1 RANDOMIZE
10 20 RND-IN . 10 20 RND-IN . 10 20 RND-IN .        \ => 10 11 19
