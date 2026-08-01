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

\ relocation: none needed -- this single CODE word never embeds a CALL/JP to
\ another word or a stored address; Back, is a PC-relative jr, already
\ position-independent. See tutorial 057 section 3 / tutorial/CLAUDE.md
\ section 17 for when rel-AA,/rel-NN, would be required instead.
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

