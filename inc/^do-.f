\
\ ^do.f
\
.( ?DO- )
\
NEEDS BACK
NEEDS BEGIN
NEEDS WHILE
NEEDS REPEAT
NEEDS THEN

( ?DO- )
\ peculiar version of BACK fitted for ?DO and LOOP
: ?DO-
    BACK
    BEGIN
        SP@ CSP @ -
        \ DUP 0= 
    WHILE
        2+ [COMPILE] THEN 
    REPEAT 
    ?CSP CSP !      
    ;


