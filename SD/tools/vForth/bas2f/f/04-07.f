\ 04-07.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/04-procedures-and-subroutines-07.txt
\ guide: doc/basic-to-vforth/04-procedures-and-subroutines.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 ON ERROR PRINT "outer": ON ERROR: STOP
\   20 PROC inner()
\   30 PRINT "not reached"
\   40 STOP
\   50 DEFPROC inner()
\   60   ON ERROR PRINT "inner ";: ERROR
\   70   PRINT 1/0
\   80 ENDPROC

\ --- the translation

\ 04-procedures-and-subroutines.md:464
NEEDS CATCH
NEEDS THROW
NEEDS [']
: CHECKED/  ( a b -- q )
    DUP 0= IF  -10 THROW  THEN  / ;
: RISKY  ( -- )  1 0 CHECKED/ . ;
: INNER  ( -- )
    ['] RISKY CATCH
    ?DUP IF  ." inner "  THROW  THEN ;
: OUTER  ( -- )
    ['] INNER CATCH
    ?DUP IF  ." outer " .  THEN ;
OUTER                           \ => inner outer -10
\ an error in the guide, it would end the INCLUDE:
\ RISKY                           \ => RISKY? Division by zero.
