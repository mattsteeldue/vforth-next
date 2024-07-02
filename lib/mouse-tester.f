\
\ mouse-TESTER.f
\
.( Mouse Tester )

NEEDS INTERRUPTS
NEEDS MOUSE
NEEDS CASE
NEEDS .AT

BASE @

variable LAST-CONSUMED-EVENT

: MOUSE-SHOW ( n1 n2 -- )
    2dup               .at 
    ." raw   " mouse-rx @   .  mouse-ry @ 5 .R mouse-rs @ 5 .R 10 spaces cr
    2dup swap 1+  swap .at
    ." delta " mouse-dx @ 5 .R mouse-dy @ 5 .R mouse-ds @ 5 .R 10 spaces cr
    2dup swap 2+  swap .at
    ." coord " mouse-x @  5 .R mouse-y  @ 5 .R mouse-s  @ 5 .R 10 spaces cr
         swap 3 + swap .at
    ." LASTK " $5C08 C@ .
    
    MOUSE \ consume event
    
    ?DUP 
    if
        dup LAST-CONSUMED-EVENT !
    then

    LAST-CONSUMED-EVENT @    

    dup $0001 and if ." right button click-down  " then
    dup $0002 and if ." left  button click-down  " then
    dup $0004 and if ." wheel button click-down  " then
    dup $0010 and if ." wheel forward direction  " then
    dup $0100 and if ." right button click-up    " then
    dup $0200 and if ." left  button click-up    " then
    dup $0400 and if ." wheel button click-up    " then
    dup $1000 and if ." wheel backward direction " then
        0=        if ." no event                 " then
    ."                   "
;


decimal 
: KEY-EMU-MOUSE ( c -- )
    case
    [char] 7 of mouse-x @  1-  mouse-x ! endof
    [char] 8 of mouse-y @  1+  mouse-y ! endof
    [char] 5 of mouse-y @  1-  mouse-y ! endof
    [char] 6 of mouse-x @  1+  mouse-x ! endof
          11 of mouse-x @  2-  mouse-x ! endof
           9 of mouse-y @  2+  mouse-y ! endof
           8 of mouse-y @  2-  mouse-y ! endof
          10 of mouse-x @  2+  mouse-x ! endof
    endcase
;

: MOUSE-TESTER 
    BEGIN
        isr-sync
        0 0 MOUSE-SHOW
        [ HEX ] 
        $5C08 C@ IF
        \   isr-di
            CR $5C08 C@ KEY-EMU-MOUSE  
            MOUSE-REDRAW 0 $5C08 c!
        \   isr-ei   
        THEN
    ?TERMINAL 
    UNTIL
;

BASE !
