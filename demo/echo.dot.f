\
\ echo.dot.f
\ 
\ dot command example
\ .echo simply echoes back 
\

needs assembler
needs unlink
needs save-bytes
needs pad"

marker redo

variable org

code echo
  Here  org !

        ld      a'|    h|
        ora      l|
        ldn     a'|  2 N,
        scf
        retf     z|
  Here    
        ld      a'| (hl)|
        ora      a|
        retf     z|
        cpn     $0D   N,
        retf     z|
        cpn    char : N,
        retf     z|
        incx    hl|
        rst     10|
        jr    Back,  \ to the closest Here
        
    c;

decimal

unlink c:/dot/echo
  pad" c:/dot/echo"  
org @ Here over -  \ find start-address & code length
save-bytes

