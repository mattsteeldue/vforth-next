\ 
\ udg+.f
\

.( UDG+ )

needs flip
needs between


decimal


\ determine the UDG character code
: UDG+ ( c1 -- c2 )
   upper 79 + ;


\ compile an UDG literal
: [UDG] ( -- )
   char UDG+ [compile] literal ;
   IMMEDIATE


\ convert a counted-string at address a in UDG
\ by converting each character between A and U in their UDG correspondants
: UDGize ( a -- )
    count over + swap do
        i c@ upper [char] A [char] U
    between if
            i c@ upper UDG+ i c!
        then
    loop ;


\ Like type but for UDG
: Gtype ( a c -- )
    over + swap ?do
    i c@ emitc loop ;


\ Utility: display all UDGs
: UDGs
    [char] V [char] A do
    i UDG+ emitc loop ;


\ given c return UDG address
: UDG@ ( c -- a )
   upper 65 - 8 * 23675 @ + ;
   \ given c print binary repres.


\ udg utility: display binary representation
: .UDG ( c -- )
    base @
    UDG@ dup 8 + swap 
    do
        cr
        i c@ flip
        8 0 do
            dup 0< if
                143
            else
                46
            then
            emitc
            2*
        loop
        drop
        i c@ hex space .
    loop 
    base !
; 

