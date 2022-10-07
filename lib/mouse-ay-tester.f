\
\ mouse-ay-TESTER.f
\
.( Mouse AY Tester )

NEEDS .AT
NEEDS CASE
NEEDS MOUSE
NEEDS AY


: MOUSE-SHOW ( n1 n2 -- )
    2dup .at 
    ." rx " mouse-rx @ . mouse-ry @ . mouse-rs @ . 7 spaces cr
    2dup swap 1+ swap .at
    ." dx " mouse-dx @ . mouse-dy @ . mouse-ds @ . 7 spaces cr
    2dup swap 2+ swap .at
    ." -- " mouse-x @ .  mouse-y @ .  mouse-s @ .  7 spaces cr
         swap 3 + swap .at
    ." LASTK " [ hex ] 5C08 C@ .
;


decimal 
: KEY-EMU-MOUSE ( c -- )
    case
    [char] 7 of mouse-x @  2-  mouse-x ! endof
    [char] 8 of mouse-y @  2+  mouse-y ! endof
    [char] 5 of mouse-y @  2-  mouse-y ! endof
    [char] 6 of mouse-x @  2+  mouse-x ! endof
          11 of mouse-x @  2-  mouse-x ! endof
           9 of mouse-y @  2+  mouse-y ! endof
           8 of mouse-y @  2-  mouse-y ! endof
          10 of mouse-x @  2+  mouse-x ! endof
    endcase
;


: MOUSE-TESTER 
    cls
    aysetup
    BEGIN
        interrupts isr-sync
        0 0 MOUSE-SHOW
        mouse-rs @ [ DECIMAL ] 13 = 
        if
            mouse-y @ 2 AY!!           
            15 9 AY!  \ volume
            mouse-x @ 3 rshift 6 AY!
            [ BINARY ] 11111111 
            mouse-x @ 3 rshift if  00010000 - then
            mouse-y @ if  00000010 - then
            [ DECIMAL ] 7 AY!
        else
            shh            
        then
        [ HEX ] 5C08 C@ 
        if 
        \   interrupts isr-di
            CR 5C08 C@ KEY-EMU-MOUSE  
            MOUSE-UPDATE 0 5C08 c!
        \   interrupts isr-ei   
        THEN
        ?TERMINAL 
    UNTIL
    SHH
;

DECIMAL FORTH


