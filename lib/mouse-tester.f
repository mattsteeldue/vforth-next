\
\ mouse-TESTER.f
\
.( Mouse Tester )

NEEDS MOUSE
NEEDS CASE
NEEDS .AT


: MOUSE-SHOW ( n1 n2 -- )
    2dup .at 
    ." raw   " mouse-rx @ . mouse-ry @ . mouse-rs @ . 7 spaces cr
    2dup swap 1+ swap .at
    ." delta " mouse-dx @ . mouse-dy @ . mouse-ds @ . 7 spaces cr
    2dup swap 2+ swap .at
    ." coord " mouse-x @ .  mouse-y @ .  mouse-s @ .  7 spaces cr
    2dup swap 3 + swap .at
    ." LASTK " [ hex ] 5C08 C@ .
    mouse 
    dup 1 and if ." ---------- right down " then
    dup 4 and if ." ---------- right up   " then
    dup 2 and if ." ---------- left  down " then
    dup 8 and if ." ---------- left  up   " then
    0=        if ." no event " then
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
        interrupts isr-sync
        0 0 MOUSE-SHOW
        [ HEX ] 
        5C08 C@ IF
        \   interrupts isr-di
            CR 5C08 C@ KEY-EMU-MOUSE  
            MOUSE-REDRAW 0 5C08 c!
        \   interrupts isr-ei   
        THEN
    ?TERMINAL 
    UNTIL
;

DECIMAL

