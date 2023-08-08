\
\ helloworld.dot.f
\

needs assembler
needs save-bytes
needs pad"


variable org

: dot-relative ( a1 -- a2 )
    org @ -  [ hex ] 2000 + 
; 

code helloworld
  Here  org !

  Here  1+
        ldx     hl|   0  NN,
  Here  
        ld      a'| (hl)|
        anda     a|
        retf     z|
        rst     10|
        incx    hl|
        jr    Back,  \ back to the closest Here
        
  Here  1+  dot-relative
        ," Hello, World!"   swap !
        
        c;

decimal

pad" helloworld"  
Org @ Here over -  \  start-addres & length
save-bytes

