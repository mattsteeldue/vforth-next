\
\ helloworld.asm.f
\

\ needs assembler
needs unlink
needs save-bytes
needs pad"

marker redo

variable org

: dot-relative ( a1 -- a2 )
    org @ -  [ hex ] 2000 + 
; 

code helloworld
      Here  org !
            HEX
    \ Here  1+
            21 c, 200B ,        \ ldx     hl|   0  NN,
    \ Here  
            7E C,               \ ld      a'| (hl)|
            A7 C,               \ anda     a|
            C8 C,               \ retf     z|
            D7 C,               \ rst     10|
            23 C,               \ incx    hl|
            18 C, F9 C,         \ jr    Back,  \ back to the closest Here
            
      \ Here  1+  dot-relative
            ," Hello, World!"   \ swap !
        
            \ c;

decimal

pad" helloworld"  
Org @ Here over -  \  start-addres & length
save-bytes

