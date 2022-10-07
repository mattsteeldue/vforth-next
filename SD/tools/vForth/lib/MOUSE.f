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

MARKER NO-MOUSE     \ completely remove MOUSE


DECIMAL 0 CONSTANT MOUSE-SPRITE-ID

\ sprite related ports
\
HEX  303B CONSTANT SPRITE-SLOT-SELECT-PORT
     0057 CONSTANT SPRITE-ATTRIBUTE-PORT
     005B CONSTANT SPRITE-PATTERN-PORT


MARKER NO-MOUSE-DEF

HEX  14 REG@ CONSTANT E3 \ Global Transparency Colour
: ` 00 C, ;  \ Black     
: o 6D C, ;  \ Dark-Grey 
: w B6 C, ;  \ Light-Gray
: M FF C, ;  \ White     
: _ E3 C, ;  \ Transparency

\ Semi-graphical mouse-face definition 10x8-pixels arrow
CREATE MOUSE-FACE 
\ 0 1 2 3 4 5 6 7  \      
\ ---------------  \     
  M ` ` ` _ _ _ _  \  0 
  M M ` ` ` _ _ _  \  1 
  M M M ` ` ` _ _  \  2 
  M M M M ` ` ` _  \  3 
  M M M M M ` ` `  \  4 
  M M M w w ` ` `  \  5 
  M w M M ` ` ` _  \  6 
  w o w M w ` ` `  \  7 
  _ _ w M M ` ` `  \  8 
  _ _ _ w w ` ` `  \  9 

\
\ setup sprite n using 10x8 pixel-data available at address a
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
: MOUSE-UPDATE      ( -- )
    MOUSE-SPRITE-ID       SPRITE-SLOT-SELECT-PORT P!    \ slot
    mouse-y @ split >R      SPRITE-ATTRIBUTE-PORT P!    \ attribute 0
    mouse-x @               SPRITE-ATTRIBUTE-PORT P!    \ attribute 1
            @ R>    01 AND  SPRITE-ATTRIBUTE-PORT P!    \ attribute 2
    MOUSE-SPRITE-ID mouse-flag @ 
                       OR   SPRITE-ATTRIBUTE-PORT P!    \ attribute 3
; 

: mouse! ( f -- )
    if C0 else 00 then
    mouse-flag !
    mouse-update
;

DECIMAL


\ this definition "normalizes" delta number
\ if delta  is less than mouse stated sensibility, it slows down motion
: mouse-norm ( n -- b )
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

\ this definition reads the mouse ports and determines 
\ three variables mouse-rx, mouse-ry, mouse-rs
HEX
: mouse-read ( -- ) 
    0FFDF P@  FLIP  mouse-rx !  \ Kempston mouse Y (vertical) * 256
    0FBDF P@  FLIP  mouse-ry !  \ Kempston mouse X (horizontal) * 256
    0FADF P@        mouse-rs !  \ Kempston mouse Wheel, Buttons
;


DECIMAL
\ this definition compares the latest two mouse-reads
\ to determine some "delta" values.
\ This definition is called by Interrupt-Service-Routine
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
    mouse-dx @ mouse-dy @ 
    if
        mouse-x @ mouse-dx @ +  0 max  255 min  mouse-x !
        mouse-y @ mouse-dy @ +  0 max  319 min  mouse-y !
        MOUSE-UPDATE
    then
    
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

WARNING @ 
0 WARNING !         \ reduce message verbosity
: no-mouse
    0 mouse!
    isr-off
    no-mouse
;


: bye 
    isr-off
    0 mouse!
    bye 
;
WARNING !

ISR-OFF 
' MOUSE-DELTA ISR-XT !
ISR-ON
    

BASE !
