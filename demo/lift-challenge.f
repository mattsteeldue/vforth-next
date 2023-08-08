\
\ lift-challenge.f
\ 
\ Matteo Vitturi 2023

needs mouse                 \ mouse cursor interface
needs flip                  \ swap hi and lo bytes of 16-bits integer
needs .at                   \ to print at x y position on the screen
needs ms                    \ milliseconds
needs dump                  \ for debug purposes
needs .s                    \ for debug purposes


marker task

6 constant  FLOORS          \ how many floors

\ __________________________

.( cabinet )

hex
  \ door status  
  0 constant  CLOSE  
  1 constant  OPEN          

  \ button type  
  0 constant  DOWN  
  1 constant  UP            

  \ lift engine status
 40 constant  ENGINE-UP
  0 constant  ENGINE-HALT 
-40 constant  ENGINE-DOWN 

  \ mouse related constants
 24 constant  MOUSE-X-OFFSET
 46 constant  MOUSE-Y-1STRIP


decimal
100 constant DELTA_T        \ delta t in ms
  5 DELTA_T * constant TIMEOUT        

\ array of floor-names
create      floor-name      
    ,"  T "
    ,"  1 "
    ,"  2 "
    ,"  3 "
    ,"  4 "
    ,"  5 "
    ,"  6 "
    ,"  7 "
    ,"  8 "
5 constant floor-name-len    


\ __________________________

.( floor-commands )

\ how many commands at floor' keyboard
2 constant  FLOOR-COMMANDS  
create      command-name
    ,"  UP "
    ,"  DN "


\ __________________________

variable    current-floor   \ 256 * the number of current floor
variable    cabinet-door    \ status of cabinet door CLOSE OPEN
variable    engine          \ engine status


variable    button-timeout
    FLOORS cells allot
    \ initialize
    button-timeout FLOORS 1+ cells erase


\ array of requested floors
variable    requested-floor \ cabinet : 256 * number of requested floor
    FLOORS cells allot
    \ initialize
    requested-floor FLOORS 1+ cells erase


variable    requested-dir   \ floor   : requested direction 
    FLOORS cells allot
    \ initialize
    requested-dir FLOORS 1+ cells erase


\ __________________________

.( buttons )

\ button "n" pressed inside cabinet
\ if its timeout was already started, don't do anything
: cab-action ( n -- )
    dup                         \ n n
    cells button-timeout + >R   \ n             R: a
    R@ @ 0=                     \ n f
    if
        TIMEOUT R@ !
    then
    R> drop 
    drop
;


\ decrease button timeout, only if it is non-zero
: decrease-timeout ( n -- )
    dup                         \ n n
    cells button-timeout + >R   \ n             R: a
    R@  @                       \ n t
    if                          \ n
        DELTA_T negate R@ +!    \ n
        R@ @ 0 > not            \ n f
        \ when hit zero, start action
        if   
            0 R@ !
            dup flip requested-floor !
        then
    then                        
    R> drop 
    drop    
;



\ "dir" button pressed at this "floor"
: floor-action ( dir floor -- )
    cells requested-dir + !
;



\ __________________________

.( display )

: display-lift ( -- )
    cabinet-door @ 
    OPEN =
    if
        ." [__]"    \ open door
    else
        ." _][_"    \ closed door
    then
;


: display-lift-or-well ( n -- )
    [ hex ] 7F OR
    current-floor @ 
    [ hex ] 7F OR
    = 
    if
        display-lift
    else
        4 spaces
    then
;


: display-beam ( n -- )
    ." ---------|"
    display-lift-or-well
    ." |---------"
;


: display-floor ( n -- )
    floor-name-len * floor-name + count type
    6 spaces [char] | emit
    display-lift-or-well
    [char] | emit 9 spaces
;


: small-dump ( a -- )
    FLOORS 1+ cells over + swap (dmp)
;    


: display ( -- )
    0 0 .at
    FLOORS 0 do
        
        FLOORS i - 1- 
        8 lshift        
        [ decimal ] 128 + 
        display-beam  cr
        
        FLOORS i - 1- 
        dup 8 lshift 
        swap
        display-floor cr
        
    loop
    -1 display-beam cr
;


\ convert vertical pixel to button position
: mouse-vertical-decode ( n1 -- n2 )
    MOUSE-X-OFFSET - 4 rshift FLOORS swap - 1-
;

: dashboard ( -- )
    cr 
    hex
    ." mouse            " mouse-xy . dup .
       mouse-vertical-decode . 
    ." engine           " engine ? cr
    ." cabinet-door     " cabinet-door ? cr
    ." current-floor    " current-floor ? cr
    ." requested-floor  " requested-floor small-dump cr
    ." requested-dir    " requested-dir   small-dump cr
    ." button-timeout   " button-timeout  small-dump cr
    ." stack            " .s  
;
    
\ __________________________

.( mouse )


\ 
: check-mouse
    ?mouse
    if
        0 mouse-s !
        mouse-xy 

        \ cabinet button        
        MOUSE-Y-1STRIP <
        if
            mouse-vertical-decode
            dup -1 > 
            if
                cab-action
            else
                drop    
            then
        else
            DROP
        then
    then
;


\ __________________________

.( run )

: ?at-requested-floor  ( -- f )
    requested-floor @   [ hex ] 7F OR
    current-floor @     [ hex ] 7F OR
    =
;


: start-engine ( -- )
    cabinet-door @ OPEN = if
        \ don't start, but close doors 
        CLOSE cabinet-door !
    then
    \ decide what direction activate engine            
    requested-floor @  
    current-floor @  
    <
    if 
        ENGINE-DOWN 
    else 
        ENGINE-UP 
    then
    engine !    
;


: compute ( -- )
    \ halt engine if door opens   (for safety)     
    cabinet-door @ OPEN = if ENGINE-HALT engine       ! then

    \ open door when engine halts (for arrival)
    engine       @ ENGINE-HALT = if OPEN cabinet-door ! then

    engine @  current-floor +!  \ this should be a probe in a real thing

    ?at-requested-floor 
    if 
        \ stop engine when arrived
        ENGINE-HALT engine ! 
        
        \ decrease all timeouts only when doors are open
        cabinet-door @ OPEN = 
        if 
            FLOORS 0 do
                i decrease-timeout
            loop
        then
    else
        start-engine 
      \ start-engine
    then
;
        

: frame ( -- )
    display
    compute
    \ dashboard 
;
 
 
: run ( -- )
    cls
    0 mouse-s !
    begin
        check-mouse
        frame
        DELTA_T ms
        ?terminal
    until
;


decimal

ENGINE-HALT engine !
OPEN cabinet-door !


