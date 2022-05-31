\
\ echo.asm.f
\

\ needs assembler
needs save-bytes

variable org

code echo
  Here  org !
        HEX
        7C C,                   \ ld      a'|    h|
        B5 C,                   \ ora      l|
        C8 C,                   \ retf     z|
  \ Here    
        7E C,                   \ ld      a'| (hl)|
        B7 C,                   \ ora      a|
        C8 C,                   \ retf     z|
        FE C, 0D C,             \ cpn         decimal 13 N,
        C8 C,                   \ retf     z|
        FE C, 3A C,             \ cpn         char    :  N,
        C8 C,                   \ retf     z|
        23 C,                   \ incx    hl|
        D7 C,                   \ rst     10|
        18 C, F3 C,             \ jr    Back,  \ to the closest Here
        
        \ c;

decimal

filename" echo"  
Org @ Here over -  \  start-addres & length
save-bytes

