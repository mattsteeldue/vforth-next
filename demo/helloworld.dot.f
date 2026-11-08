\
\ helloworld.dot.f
\

needs assembler
needs unlink
needs save-bytes
needs pad"

.( ! ) CR

marker redo

variable release        \ 0 = test in place (debug), 1 = final $2000 build

\ *** BEFORE SAVING THE DOT-COMMAND, RAISE THE RELEASE FLAG ***
\ With release at 0, dot-relative returns the live address: the file saved
\ below would load HL with an address of the vForth dictionary instead of
\ the message at $2000, and .helloworld would print garbage or worse.
\ For the release build write   1 release !   on the line below, then
\ load this file again (redo first, to forget the previous attempt).
\ Check before save-bytes:  org @ .  must be close to HERE, never 0, and
\ the file is 27 bytes long.

variable org
variable msg

: dot-relative ( a1 -- a2 ) release @ if org @ -  $2000 + then ; 
: rel-AA,   dot-relative assembler AA, ;
: rel-NN,   dot-relative assembler NN, ;
: return    release @ if assembler ret else assembler next then ;
: z" ( -- a ) here 1+ ," ;


code helloworld
  Here  org !                   \ save this address to org.
        jr holdplace
  
        z" Hello, World!" msg ! \ address of message "Hello, World!"
        
        here disp,              \ resolve starting jr holdplace
  
        ldx     hl| msg @ rel-NN,    

  Here  ld      a'| (hl)|
        anda     a|
        retf     z|
        rst     10|
        incx    hl|
        jr    Back,  \ back to the closest Here

    c;

decimal

unlink c:/dot/helloworld
  pad" c:/dot/helloworld"  
Org @ Here over -  \  start-addres & length
save-bytes

