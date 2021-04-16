\
\ search.scr.f
\
.( SEARCH.SCR ) 
\
\ accepts the next word-tex from the current input stream
\ and compare it with the PAD content.
\ This definitions is needed by LOCATE and GREP.

NEEDS COMPARE

\
: SEARCH.SCR ( -- f )
    BL WORD COUNT
    PAD COUNT COMPARE 
;
\
