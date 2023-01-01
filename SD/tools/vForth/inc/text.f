\
\ text.f
\
\ accept following text to PAD as a counted-string
\ Use .PAD to inspect PAD content
\
.( TEXT )
\
\ TEXT
: TEXT ( c -- )     
    HERE C/L 1+ BLANK 
    WORD 
    PAD C/L 1+ CMOVE 
;
