\
\ text.f
\
\ accept following text to PAD
\
.( TEXT )
\
\ TEXT
: TEXT ( c -- )     
    HERE C/L 1+ BLANKS 
    WORD PAD C/L 1+ CMOVE 
;
\
