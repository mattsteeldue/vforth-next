\
\ helloworld.dot.f
\

needs assembler
needs unlink
needs save-bytes
needs pad"

.( ! ) CR

marker redo

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

