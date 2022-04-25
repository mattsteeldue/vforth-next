\
\ hallot.f
\
.( HALLOT )
\
\ heap allot

: HALLOT ( quant --
...
;

\ HEAD ( -- a )  --> to get the address available

\ heap u. 58118 
\ 300 hallot
\ heap u. 57818
\ heap 300 42 fill
\ heap 10 type
\ clear
\ heap u. 58118

\ Header-less words |
\ | : hello ." hi" ;
