\
\ mouse.f
\
.( MOUSE )

NEEDS DEFER
NEEDS FLIP
NEEDS SPLIT
NEEDS INTERRUPTS

MARKER NO-MOUSE

BASE @

\ ______________________________________________________

HEX  303B CONSTANT SPRITE-SLOT-SELECT-PORT
     0057 CONSTANT SPRITE-ATTRIBUTE-PORT
     005B CONSTANT SPRITE-PATTERN-PORT

HEX  14 REG@ CONSTANT E3 \ Global Transparency Colour

\ ______________________________________________________
\
\ setup sprite #0

DECIMAL 0 CONSTANT MOUSE-SPRITE-ID

\ setup sprite n using 8x8 pixel-data available at address a
\
: MOUSE-SPRITE-SET ( a n -- )
    SPRITE-SLOT-SELECT-PORT   P!    \ a 
    [ DECIMAL ] 80 OVER + SWAP      \ a+80 a 
    DO
        8 I + I 
        DO
            I C@  SPRITE-PATTERN-PORT P!
        LOOP
        8 0 DO
            E3  SPRITE-PATTERN-PORT P!
        LOOP
    8 +LOOP
    6 0 DO
        [ DECIMAL ]
        16 0 DO
            E3  SPRITE-PATTERN-PORT P!
        LOOP
    LOOP
;    

\ 8x8 arrow
CREATE MOUSE-FACE 
HEX
\  0     1     2     3      4     5     6     7 
\ _________________________________________________
\
  FF C, 00 C, 00 C, 00 C,  E3 C, E3 C, E3 C, E3 C, \  0
  FF C, FF C, 00 C, 00 C,  00 C, E3 C, E3 C, E3 C, \  1
  FF C, FF C, FF C, 00 C,  00 C, 00 C, E3 C, E3 C, \  2
  FF C, FF C, FF C, FF C,  00 C, 00 C, 00 C, E3 C, \  3
  FF C, FF C, FF C, FF C,  FF C, 00 C, 00 C, 00 C, \  4
  FF C, FF C, FF C, B6 C,  B6 C, 00 C, 00 C, 00 C, \  5
  FF C, B6 C, FF C, FF C,  00 C, 00 C, 00 C, E3 C, \  6
  B6 C, 6D C, B6 C, FF C,  B6 C, 00 C, 00 C, 00 C, \  7
  E3 C, E3 C, B6 C, FF C,  FF C, 00 C, 00 C, 00 C, \  8
  E3 C, E3 C, E3 C, B6 C,  B6 C, 00 C, 00 C, 00 C, \  9
\ _________________________________________________
\ 
\      0 1 2 3 4 5 6 7
\     ----------------
\  0 | #     
\  1 | # #     
\  2 | # # #     
\  3 | # # # #     
\  4 | # # # # #     
\  5 | # # #     
\  6 | #   # #   
\  7 |       # #        
\  8 |       # #            
\  9 |                
\ ______________________________________________________
\

: NEW-FACE
    MOUSE-FACE  MOUSE-SPRITE-ID  MOUSE-SPRITE-SET
;


\ mouse status
\
\ lastest raw-data read from mouse
VARIABLE  mouse-rx   0   mouse-rx  !
VARIABLE  mouse-ry   0   mouse-ry  !
VARIABLE  mouse-rs   0   mouse-rs  !

\ difference between the two lastest raw-data 
VARIABLE  mouse-dx   0   mouse-dx  !
VARIABLE  mouse-dy   0   mouse-dy  !
VARIABLE  mouse-ds   0   mouse-ds  !

\ mouse event tracking
VARIABLE  mouse-x  100   mouse-x   !   \ row from top-side
VARIABLE  mouse-y  100   mouse-y   !   \ cols from left-side
VARIABLE  mouse-s    0   mouse-s   !   \ buttons

HEX

VARIABLE  mouse-flag C0 mouse-flag !

: mouse! ( f -- )
    if C0 else 00 then
    mouse-flag !
;


: MOUSE-UPDATE      ( n -- )
    MOUSE-SPRITE-ID       SPRITE-SLOT-SELECT-PORT P!    \ slot
    mouse-y @ split >R      SPRITE-ATTRIBUTE-PORT P!    \ attribute 0
    mouse-x @               SPRITE-ATTRIBUTE-PORT P!    \ attribute 1
            @ R>    01 AND  SPRITE-ATTRIBUTE-PORT P!    \ attribute 2
    MOUSE-SPRITE-ID mouse-flag @ 
                       OR   SPRITE-ATTRIBUTE-PORT P!    \ attribute 3
; 

DECIMAL


\ this definition "normalizes" raw-data number
: mouse-norm ( n1 -- n2 )
    dup 0< if
        split 256 - nip
    else
        split nip
    then
    2/      \ reduce sensibility.
;

\ this definition reads the mouse ports and determines 
\ three variables mouse-rx, mouse-ry, mouse-rs
HEX
: mouse-read ( -- ) 
    0FFDF P@  FLIP  mouse-rx !  \ Kempston mouse Y (vertical)
    0FBDF P@  FLIP  mouse-ry !  \ Kempston mouse X (horizontal)
    0FADF P@        mouse-rs !  \ Kempston mouse Wheel, Buttons
;


DECIMAL
\ this definition compares the latest two mouse-reads
\ to determine some "delta" values.
: mouse-delta ( -- ) 
    \ keeps in stack current raw-data mouse status
    mouse-rx @      
    mouse-ry @
    mouse-rs @
    
    mouse-read      \ this modify all 3 mouse-rx, ry, rs.
    
    \ compute delta
    mouse-rs @       -              mouse-ds !   
    mouse-ry @ swap  -  mouse-norm  mouse-dy !   
    mouse-rx @       -  mouse-norm  mouse-dx !   

    \ update xy-coords 
    mouse-x @ mouse-dx @ +  0 max  255 min  mouse-x !
    mouse-y @ mouse-dy @ +  0 max  319 min  mouse-y !
    MOUSE-UPDATE
    
    \ update mouse events  -2, -1, 1, 2
    mouse-ds @ ?dup 
    if
        dup 0< if 2* 2* abs  then 
        mouse-s @ 
        or 
        mouse-s !
    then
;


\ return the current mouse position
\ x : vertical distance from top-left corner
\ y : horizontal distance from top-left corner
: MOUSE-XY ( -- x y )
    mouse-x @
    mouse-y @
;


\ true-flag if there is a mouse-click event
: ?MOUSE ( -- f )
    mouse-s @ 0= 0=
;


\ return the current status of mouse
\ s : 1 right button click-down event
\   : 2 right button click-up   event
\   : 4 left  button click-down event
\   : 8 left  button click-up   event
: MOUSE
    mouse-s @
    dup if 
        0 mouse-s !
    then
;

WARNING @ 0 WARNING !

: no-mouse
    isr-off
    no-mouse
;


: bye 
    isr-off
    0 mouse!
    bye 
;


WARNING !

NEW-FACE

3 HEX 15 REG!

ISR-OFF 
' MOUSE-DELTA ISR-XT !
ISR-ON
    
BASE !
