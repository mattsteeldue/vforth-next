\
\ parser.dot.f
\

needs assembler
needs save-bytes
needs pad"

marker redo

variable org

\ utility, given an "here" address, return the equivalent starting from $2000
: dot-relative ( a1 -- a2 )
    org @ -  $2000 + 
; 


: rel-AA,   dot-relative assembler AA, ;
: rel-NN,   dot-relative assembler NN, ;
forth 


\ __________________________________________________________
\
\ entry-point at $2000
\
code entry-point 
    Here  org !
        jp  0 AA,
    c;
       
\ print routine
\ input:    hl = z-string address
\ output:   hl = address of ending NUL  
\ modified: a, hl
code print        
    Here    
        ld      a'|  (hl)|
        ora      a|
        retf     z|
        incx    hl|
        rst     10|
        jr    Back,  \ to the closest Here
    c;

\ parse literal string
\ input:    hl = address of first chr inside "
\ output:   hl = address of last chr inside " 
\           de = length of string
\ modified: a, de, hl
code parse-string  
        ldx     de|  0  NN,
    Here    
        incx    hl|
        ld      a'|  (hl)|
        cpn          char  "  N,
        retf     z|
        incx    de|
        jr    Back,  \ to the closest Here
    c;


\ parse Basic command 
\ input:    hl = address of next basic character
\ output:   hl = address of first char after current statement
\ modified: a, hl
code parse  
  Here    
        ld      a'|  (hl)|
        incx    hl|
        ora      a|
        retf     z|
        cpn         $0D  N,
        retf     z|
        cpn         char  :  N,
        retf     z|
        rst     10|

        ld      a'|  (hl)|
        cpn         char  "  N,
        callf    z|    ' parse-string  rel-AA,

        jr    Back,  \ to the closest Here
    c;


create help-message
    ," This is a help example"  

  
code help
        ldx     hl|   help-message rel-NN,
        call    ' print AA,
        
        ret
    c;


code main
        ld      a'|     h|
        ora      l|
        jpf      z|    ' help dot-relative AA,
        call    ' parse AA,
        ret        
    c;   

\ patch the origin jump to main
' main dot-relative  org @ 1+ !


code tester
        push   bc|
        push   de|
        push   ix|
        call ' main AA,
        pop    ix|
        pop    de|
        pop    bc|
        jpix
    c;

\ __________________________________________________________

pad" parser"  
org @ Here over -  \  start-addres & length
save-bytes
