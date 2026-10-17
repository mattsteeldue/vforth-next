\ 01-05.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/01-basic-programming-concepts-05.txt
\ guide: doc/basic-to-vforth/01-basic-programming-concepts.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 ON ERROR PRINT "Cannot share among ";n: ON ERROR: STOP
\   20 INPUT n
\   30 PRINT 100/n

\ --- the translation

\ 01-basic-programming-concepts.md:229
NEEDS CATCH
NEEDS THROW
NEEDS [']
: SHARE  ( n -- )
    DUP 0= IF  -10 THROW  THEN
    100 SWAP / . ;
: TRY  ( n -- )
    ['] SHARE CATCH
    ?DUP IF  ." There was an error! " .  DROP  THEN ;
4 TRY                           \ => 25
0 TRY                           \ => There was an error! -10
