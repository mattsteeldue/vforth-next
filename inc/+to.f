\
\ +to.f
\
.( +TO )
\
NEEDS [']
NEEDS (TO)
\
\ Used in the form
\   n  +TO  cccc 
\
\ If not compiling, add the value  n  to cccc  
\ At compile-time it compiles a literal pointer to cccc's PFA
\ followed by a plus-store-command  (+!) so that later ...
\ at run-time the literal is used by the ! word to alter cccc value
\ cccc was created via VALUE.
\
: +TO ( n -- cccc )
    ['] +!
    (TO)
;
IMMEDIATE

