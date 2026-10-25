\
\ parse.f
\
.( PARSE )
\
\ Parse the text up to the delimiter c from the input stream, without
\ skipping leading delimiters as WORD does: the text may be empty, so
\ that  S" "  is the empty string and not the rest of the line.
\ a n is the text inside the input buffer, where WORD reads it (the
\ block BLK, BLOCK 1 during INCLUDE, or TIB); >IN moves past the
\ delimiter. The 0x00 that ends the input stops the text too, and is
\ left there for the interpreter. During INCLUDE the line is padded with
\ blanks to 510 characters: a text with no delimiter ends with them.
\
: PARSE ( c -- a n )
    >R
    BLK @ IF  BLK @ BLOCK  ELSE  TIB @  THEN
    >IN @ +  0                  \ a 0          R: c
    BEGIN
        2DUP + C@               \ a n ch
        DUP R@ = 0= AND         \ a n f        neither c nor 0x00
    WHILE
        1+
    REPEAT
    R> DROP
    2DUP + C@ IF  DUP 1+  ELSE  DUP  THEN
    >IN +!                      \ a n          skip the delimiter too
;
