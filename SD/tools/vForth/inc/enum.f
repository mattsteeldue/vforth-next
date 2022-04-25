\
\ enum.f
\
\ Simple enumeration utility
\
.( ENUM )
\
\ Used in the form:
\   
\   ENUM type
\    type name_0
\    type name_1
\    ...
\    type name_n
\
\ Here is an example:
\
\  ENUM color
\   color _black
\   color _blue
\   color _red
\   color _magenta
\   color _green
\   color _cyan
\   color _yellow
\   color _white
\
\ instead of creating eight constants.
\ See also ENUMERATED.f
\
: POSTINC ( a -- x ) \ increment a, return its original value
  DUP @ 1 ROT +!
;

: ENUM
    <BUILDS
        0 ,
    DOES> 
        POSTINC CONSTANT
;
