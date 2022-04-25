\
\ enumerated.f
\
\ Simple enumeration utility
\
.( ENUMERATED )
\
\ Used in the form:
\   
\   n ENUM name_0 name_1 ... name_n
\
\ Here is an example:
\
\  8 ENUMERATED _black _blue _red _magenta _green _cyan _yellow _white
\
\ instead of creating eight constants.
\ See also ENUM.f 
\
: ENUMERATED ( n -- cccc cccc ... )
    0 DO
        I CONSTANT
    LOOP
;
