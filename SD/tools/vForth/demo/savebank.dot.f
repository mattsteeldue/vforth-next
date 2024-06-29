\
\ savebank.dot.f
\

needs assembler
needs unlink
needs save-bytes
needs pad"

marker redo

1 constant release?

variable org

: dot-relative ( a1 -- a2 ) release? if org @ -  $2000 + then ; 
: rel-AA,   dot-relative assembler AA, ;
: rel-NN,   dot-relative assembler NN, ;
: return    release? if assembler ret else assembler next then ;
: z" ( -- a ) here 1+ ," ;

\ __________________________________________________________
\
\ entry-point $2000
\
code entry-point 
    Here  org !
        jp  0 AA,
    c;


," Matteo Vitturi (c) 2024"


variable v-mmu7
variable v-sp
variable v-fh
variable v-page
variable v-last


\ __________________________________________________________

code bailout
        ldn     a'|  0 N,
        scf
        ret
    c;

\ __________________________________________________________

code close-bailout
        lda()   v-fh  rel-AA,
        rst     08|     $9B  C,          \ f_close
        jp    ' bailout rel-AA,
    c;

\ __________________________________________________________

\ newline routine
\ input:    none
\ output:   none
\ modified: none
code newline \ 
        ldn     a'|  $0D N,
        rst     10|
        ret
    c;

\ __________________________________________________________

\ print routine
\ input:    hl = z-string address
\ output:   hl = address of ending NUL  
\ modified: a,hl
code display        
    here    
        ld      a'|  (hl)|
        ora      a|
        retf     z|
        incx    hl|
        rst     10|
        jr    Back,  \ to the closest Here
    c;

\ __________________________________________________________

\ help routine
\ input:    none
\ output:   none
z" Save to SD banks from n to m."  -1 allot here
," Usage: .savebank n,m,filespec"  -1 allot $000D ,  $0D swap c!
code help
        ldx     hl|     rel-NN,
        jp      ' display rel-AA,
    c;

\ __________________________________________________________

\ wrong interval
\ input:    none
\ output:   none
z" Wrong interval"  -1 allot $000D , \ add a return-carriage
code wronginterval
        ldx     hl|     rel-NN,
        jp      ' display rel-AA,
    c;

\ __________________________________________________________

\ parse a small integer 0-255.
\ input:    hl = basic source
\ output:   hl = basic source
\           de = small integer number
\ z" Argument must be between 0 and 255"  -1 allot $000D , 
code parseint
        ldx     de|  0  NN,
    Here    
        ld      a'|  (hl)|
        subn    $30   N,
        retf    cy|
        cpn     $0A   N,
        retf    nc|
        ldn     d'|   #10 N,
        mul
        addde,a        
        incx    hl|
        jr           Back,
    c;

\ __________________________________________________________

\ parse onechar routine ignoring blanks
\ input:    hl: address of nextchr
\            a: char to be compared with
\ output:   none
\ modified:  a
code parsechar \ 
        cpa   (hl)|
        incx    hl|
        retf     z|
        jp      ' help rel-AA,
    c;


\ __________________________________________________________

\ skip blanks
\ input:    hl: address of nextchr
\ output:   none
\ modified:  a
code skipblanks
        ldn     a'|   $20  N,
    here        
        cpa   (hl)|
        retf    nz|
        incx    hl|
        jr      Back,
    c;

\ __________________________________________________________
\
\ set MMU7 
code set-mmu7
        nextrega #87 p,   \ nextreg 87,a
        ret
    c;

\ __________________________________________________________
\
\ get MMU7
code get-mmu7
        ldx     bc| $243B NN, 
        ldn     a'| #87 N,
        out(c)  a'|
        inc     b'|
        in(c)   a'|
        ret
    c;

\ __________________________________________________________

code main
        \ if hl is zero display help
        ld      a'|     h|
        ora      l|
        jpf      z|    ' help   rel-AA,

        call    ' skipblanks    rel-AA,

        \ parse an integer number < 256
        call    ' parseint      rel-AA, 
        ld      a'|     e|
        adda     a|
        ld()a   v-page          rel-AA, 
        
        call    ' skipblanks    rel-AA,

        \ parse a comma
        ldn     a'|  char , N,
        call    ' parsechar     rel-AA,

        call    ' skipblanks    rel-AA,

        \ parse an integer number < 256
        call    ' parseint      rel-AA, 
        ld      a'|     e|
        adda     a|
        ld()a   v-last          rel-AA, 

        call    ' skipblanks    rel-AA,

        \ parse a comma
        ldn     a'|  char , N,
        call    ' parsechar     rel-AA,

        call    ' skipblanks    rel-AA,

        \ save mmu7 status
        call    ' get-mmu7      rel-AA,
        ld()a   v-mmu7          rel-AA,
 
        \ verify interval
        lda()   v-page  rel-AA,
        ld      e'|    a|
        lda()   v-last  rel-AA,
        cpa      e|
        jpf     cy|    ' wronginterval rel-AA,

        

        \ f_open using hl string
        push    hl|
        pop     ix|
        ldx     de|    $3FF0    NN,
        ldn     b'|    %0110     N,
        ldn     a'|     char  *  N,
        rst     08|     $9A  C,     \ f_open 
        jpf     cy|    ' bailout rel-AA,
        ld()a   v-fh   rel-AA,
 
        \ stack in safe zone
        ld()x   sp|    v-sp     rel-AA,
        ldx     sp|    $3FF0 NN,
 
        \ calc loop limit
        lda()   v-last   rel-AA,
        ld      c'|     a|
        ld()a   v-page  rel-AA,
        suba     c|
        inc     a'|        
        adda     a|
        ld      b'|     a|

        \ loop on pages
\       Here
\           push    bc|
\
\           lda()   v-page      rel-AA,
\           call    ' set-mmu7  rel-AA,
\           inc     a'|
\           ld()a   v-page      rel-AA,  
\           
\           \ f_write        
\           lda()   v-fh  rel-AA,
\           ldx     bc|  $2000  NN,
\           ldx     hl|  $E000  NN,
\           push    hl|
\           pop     ix|
\           rst     08|     $9E  C,  \ f_write
\
\           pop     bc|
\
\           jpf     cy|    ' close-bailout rel-AA,
\       djnz    back,
 
        \ restore stack 
        ldx()   sp|  v-sp rel-AA,
 
        \ f_close
        lda()   v-fh   rel-AA,
        rst     08|     $9B  C,
 
        \ restore MMU7
        lda()   v-mmu7          rel-AA,
        call ' set-mmu7         rel-AA,

        ret
        c;

\ __________________________________________________________

' main dot-relative org @ 1+ !  \ patch JP instruction

\ __________________________________________________________

code tester ( hl -- carry )
        pop    hl|
        push   bc|
        push   de|
        push   ix|
        call ' main AA,
        pop    ix|
        pop    de|
        pop    bc|
        sbchl  hl|
        push   hl|
        jpix
    c;

create test-string
," 100,101,prova"


\ __________________________________________________________

decimal

unlink c:/dot/savebank
  pad" c:/dot/savebank"  
Org @ Here over -  \  start-addres & length
save-bytes
