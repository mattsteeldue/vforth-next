\
\ mouse.f
\
.( MOUSE )

\ used in the form
\
\   NEEDS MOUSE
\
\ Sprite #0 is overwritten to an arrow shape (see below)
\

NEEDS FLIP
NEEDS SPLIT
NEEDS INTERRUPTS

BASE @

MARKER FORGET-MOUSE     \ completely remove MOUSE disabling Forth ISR


DECIMAL 0 CONSTANT MOUSE-SPRITE-ID

\ sprite related ports
\
HEX  303B CONSTANT SPRITE-SLOT-SELECT-PORT
     0057 CONSTANT SPRITE-ATTRIBUTE-PORT
     005B CONSTANT SPRITE-PATTERN-PORT


MARKER NO-MOUSE-DEF

HEX  14 REG@ CONSTANT E3 \ Global Transparency Colour
: " 00 C, ;  \ Black     
: | 6D C, ;  \ Dark-Grey 
: v B6 C, ;  \ Light-Gray
: M FF C, ;  \ White     
: _ E3 C, ;  \ Transparency

.( MOUSE-FACE ) 

\ Semi-graphical mouse-face definition 10x8-pixels arrow
CREATE MOUSE-FACE 
\ 0 1 2 3 4 5 6 7 8 9 A B C D E F \      
\ ------------------------------- \     
  M | " " _ _ _ _ _ _ _ _ _ _ _ _ \  0 
  M M | " " _ _ _ _ _ _ _ _ _ _ _ \  1 
  M M M | " " _ _ _ _ _ _ _ _ _ _ \  2 
  M M M M | " " _ _ _ _ _ _ _ _ _ \  3 
  M M M M M | " " _ _ _ _ _ _ _ _ \  4 
  M M M M M M | " " _ _ _ _ _ _ _ \  5 
  M M M M M M M | " " _ _ _ _ _ _ \  6 
  M M M M M M M M | " " _ _ _ _ _ \  7 
  M M M M M M M M M | " " _ _ _ _ \  8 
  M M M M M M | " " " " " " _ _ _ \  9 
  M M | v M M | " " " _ _ _ _ _ _ \  A
  M | " v M M v | " " _ _ _ _ _ _ \  B
  | " _ _ v M M | " " _ _ _ _ _ _ \  C
  _ _ _ _ v M M v | " " _ _ _ _ _ \  D
  _ _ _ _ _ M M v | " " _ _ _ _ _ \  E
  _ _ _ _ _ v v | " " " _ _ _ _ _ \  F

\
\ setup sprite n using 10x8 pixel-data available at address a
\
: MOUSE-SPRITE-SET ( a n -- )
    SPRITE-SLOT-SELECT-PORT   P!    \ a 
    [ DECIMAL ] 256 OVER + SWAP      \ a+80 a 
    DO
        16 I + I 
        DO
            I C@  SPRITE-PATTERN-PORT P!
        LOOP
    16 +LOOP
;    

\ directly change Sprite #0
MOUSE-FACE  MOUSE-SPRITE-ID  MOUSE-SPRITE-SET

\ Sprite and Layer System Setup
3 HEX 15 REG!

\ and free some memory
NO-MOUSE-DEF


\ mouse status variables
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
VARIABLE  mouse-x   40   mouse-x   !    \ row from top-side
VARIABLE  mouse-y   40   mouse-y   !    \ cols from left-side
VARIABLE  mouse-s    0   mouse-s   !    \ buttons
VARIABLE  mouse-sens 1   mouse-sens !   \ sensibility

HEX

\ mouse visible C0 or invisible 0
VARIABLE  mouse-flag C0 mouse-flag !

\ re-draw mouse
: MOUSE-REDRAW      ( -- )
    MOUSE-SPRITE-ID       SPRITE-SLOT-SELECT-PORT P!    \ slot
    mouse-y @ split >R      SPRITE-ATTRIBUTE-PORT P!    \ attribute 0
    mouse-x @               SPRITE-ATTRIBUTE-PORT P!    \ attribute 1
              R>    01 AND  SPRITE-ATTRIBUTE-PORT P!    \ attribute 2
    MOUSE-SPRITE-ID mouse-flag @ 
                       OR   SPRITE-ATTRIBUTE-PORT P!    \ attribute 3
; 


\ enable or disable display of arrow
: MOUSE! ( f -- )
    if C0 else 00 then
    mouse-flag !
    mouse-redraw
;

DECIMAL


\ this definition "normalizes" delta number
\ if delta  is less than mouse stated sensibility, it slows down motion
: MOUSE-NORM ( n -- b )
    dup mouse-sens @ <
    if
        2/      \ reduce sensibility.
    then
    dup 0< if
        split 256 - nip
    else
        split nip
    then
;

\ this definition reads the mouse ports and determines the values of
\ the three variables mouse-rx, mouse-ry, mouse-rs
HEX
: MOUSE-READ ( -- ) 
    0FFDF P@  FLIP  mouse-rx !  \ Kempston mouse Y (vertical) * 256
    0FBDF P@  FLIP  mouse-ry !  \ Kempston mouse X (horizontal) * 256
    0FADF P@        mouse-rs !  \ Kempston mouse Wheel, Buttons
;


DECIMAL
\ this definition compares the latest two mouse-reads
\ to determine some "delta" values.
\ This definition is called by Interrupt-Service-Routine
: MOUSE-DELTA ( -- ) 
    \ keeps in stack current raw-data mouse status
    mouse-rx @      
    mouse-ry @      
    mouse-rs @
    
    \ this modify all 3 variables mouse-rx, ry, rs.
    mouse-read      
    
    \ compute delta between current and previous values
    mouse-rs @       -              mouse-ds !   
    mouse-ry @ swap  -  mouse-norm  mouse-dy !   
    mouse-rx @       -  mouse-norm  mouse-dx !   

    \ update xy-coords 
    mouse-dx @ mouse-dy @ or
    if
        mouse-x @ mouse-dx @ +  0 max  255 min  mouse-x !
        mouse-y @ mouse-dy @ +  0 max  319 min  mouse-y !
        mouse-redraw
    then
    
    \ update mouse button-events  
    \ +/-   1 : right button
    \ +/-   2 : left button
    \ +/-   4 : wheel button
    \ +/-  16 : wheel rotation
    mouse-ds @ ?dup 
    if
        dup 0< if abs flip then 
        mouse-s @ 
        or 
        mouse-s !
    then
;


\ return the current mouse position
\ x : vertical distance from top-left corner
\ y : horizontal distance from top-left corner
.( MOUSE-XY ) 

: MOUSE-XY ( -- x y )
    mouse-x @
    mouse-y @
;


\ true-flag if there is a mouse-click event
: ?MOUSE ( -- f )
    mouse-s @ 0= 0=
;


\ return the current status of mouse
\ s :    1  right button click-down event
\   :    2  left  button click-down event
\   :    4  wheel button click-down event
\   :   16  wheel up direction      event
\   :  256  right button click-up   event
\   :  512  left  button click-up   event
\   : 1024  wheel button click-up   event
\   : 4096  wheel down direction    event
.( MOUSE )

: MOUSE
    mouse-s @
    dup if 
        0 mouse-s !
    then
;


: NO-MOUSE  
    0 mouse!
    isr-off
    FORGET-MOUSE
;


WARNING @ 
0 WARNING !         \ reduce message verbosity

: BYE 
    isr-off
    0 mouse!
    bye 
;
WARNING !


ISR-OFF 
    ' MOUSE-DELTA ISR-XT !
ISR-ON
    

BASE !
