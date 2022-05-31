\
\ echo.dot.f
\

needs assembler
needs save-bytes

variable org

code echo
  Here  org !

        ld      a'|    h|
        ora      l|
        retf     z|
  Here    
        ld      a'| (hl)|
        ora      a|
        retf     z|
        cpn         decimal 13 N,
        retf     z|
        cpn         char    :  N,
        retf     z|
        incx    hl|
        rst     10|
        jr    Back,  \ to the closest Here
        
        c;

decimal

filename" echo"  
Org @ Here over -  \  start-addres & length
save-bytes

