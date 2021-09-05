\
\ text.f
\
\ accept following text to PAD
\
.( TEXT included ) 6 EMIT
\
\ TEXT
: TEXT ( c -- )     
    HERE C/L 1+ BLANKS 
    WORD PAD C/L 1+ CMOVE 
;
\
