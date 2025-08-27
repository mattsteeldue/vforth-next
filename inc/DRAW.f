\
\ draw.f  
\
.( DRAW )
\
NEEDS ASSEMBLER
NEEDS GRAPHICS

MARKER TASK

\ given two points (x1,y1) and (x0,y0) and an 8-bit color
\ draw a line using Bresenham's line algorithm
\ Out-of-range affects the fourth 16K-bank adjacent to the first three.
\ 

.( ROUT-1 )
\ Input: H=y0, L=x0, B=y1, C=x1, A=attribute byte
\ Draw from hl to bc inclusive
\ Horizontal,verticaL is the mnemonic rule here.
\ exit: DE is the address of last pixel
\       HL is the coord of last pixel plotted.
CODE ROUT-1

\       push    bc|             \ Horizontal,verticaL

        exafaf        

        ldar                    \ remember if interrupts were enabled.
        push    af|
        di                      \ because we use MMU0.
        
\ compute which 8K page must be fitted in MMU7    
\ three MSB of H are added to twice register "Layer 2 Active RAM Bank"
        ld      a'|     l|      \ verticaL

        exx

        rlca
        rlca
        rlca  
        andn 7  n,
        
\ ask hardware registers for RAM Bank
        ldn     d'| $12    N,   \ Layer 2 Active RAM Bank
        ldx     bc| $243B NN, 
        out(c)  d'|
        inc     b'|
        in(c)   e'|
        adda     e| \ add RAM Bank
        adda     e| \ twice to get 8K-RAM page
        nextrega #80 P, 
        exafaf

\ c' keep the attribute
        ld      C'|     a|     

        exx

\ Find address of current position (HL) via MMU0!
\ Given:  HL pixel coordinates (Horiz,verticaL)
\ Compute: DE address between $0000 and $1FFF
\ Constraint: MMU0 must be set beforehand.
        ld      a'|     l|      \ verticaL
        andn    $1F  N,
        ld      d'|     a|
        ld      e'|     h|      

\ Plot pixel with color C'
        exx
        ld      a'|     C|
        exx
        ld(x)a  de|

\       pop     bc|

        ldx     de| $0101 NN, 
\ de holds the direction of the x and y steps
\ d'e' holds the mask for boundary match for paging
        exx
        ldx     DE| $1F1F NN,   
        exx
    
\ going left (-1) or righe (+1)
        ld      a'|   b|
        suba     h|
        jrf      nc'| HOLDPLACE \ x2x1
            dec      d'|
            dec      d'|        \ sy
            neg
        HERE DISP,
\ x2x1        
        ld      b'|   a|        \ b holds the number of steps in horizontal

\ going up (-1) or down (+1)
        ld      a'|   c|
        suba     l|            
        jrf     nc'| HOLDPLACE  \ y2y1
            exx
            ldn     E'|   0 N,
            exx
            dec     e'|
            dec     e'|
            neg
        HERE DISP,
\ y2y1    
        ld      c'|   a|        \ c holds the number of steps in vertical
        
\ check that isn't a point
        ora      b|
        jrf     z'| HOLDPLACE   \ quit

\ save current coord and free hl (coords are exchanged with counters)
        push    hl|             
        
\ store the direction of a diagonal step, 0101, 01FF, FF01, FFFF
        ld      h'|   d|
        ld      l'|   e| 
      \ ld()hl  DIASTP  AA, \    (DIASTP),hl \ salva sx sy
        push    hl|
        exx
        pop     HL|
        exx

        ldn     l'| 0 N,  
        
\ decide between vertical and horizontal steps 
\ depending on which is bigger between b and c
        ld      a'|   c|
        cpa      b|             \ set carry flag if b>c for later
        jrf    cy'| HOLDPLACE   \ bbc
            ld      h'|   l|    \ 
            ld      l'|   e|
            ld      c'|   b|    \ swap b and c
            ld      b'|   a|
\ bbc     
        HERE DISP,    
        
\ store the v/h step 0100, FF00, 0001, 00FF
      \ ld()hl   VHSTP AA, \   (VHSTP),hl
        push    hl|
        pop     ix|

\ now b>=c, take b-c straight steps and c diagonal steps
        ld      h'|   b|        \ h is total steps
        ld      a'|   b|
        srl      a|
        ld      l'|   a|        \ l is half total steps

\ loop
    HERE
\ nxtstp  
        ld      a'|   l|
        adda     c|
\ decide on a diagonal or a straight steps this time
        jrf    cy'| HOLDPLACE \ diag
            cpa      b|
        
        jrf    cy'| HOLDPLACE \ verhor
\ diag  
        SWAP HERE DISP,  
        
            suba     b|
            ld      l'|   a|
          \ ldx()   de|   DIASTP AA,
            exx
            push    HL|
            exx
            pop     de|
          
        jr      HOLDPLACE \ step

\ verhor  
        SWAP HERE DISP,

            ld      l'|   a|
          \ ldx()   de|   VHSTP  AA,
            push    ix|
            pop     de|

\ step    
        HERE DISP,

        ex(sp)hl

\ paging happens when vertical coordinate passes boundary
        ld     a'|   l| 
        exx
        anda    D|   \ $1F  for masking
        cpa     E|   \ $1F or ZERO for bound check.
        exx    
        jrf    nz'| HOLDPLACE
    
            exafaf
            adda     e|
            nextrega #80 p,
            exafaf
        
        HERE DISP, \ THEN,           
\ end-paging

\ make the step along  x - horizontal
        ld      a'|   h|
        adda     d|
        ld      h'|   a|
\ make the step along  y - vertical
        ld      a'|   l|
        adda     e|
        ld      l'|   a|

\ the actual plot
\       push    bc|

\ plot current position via MMU0!
\       call    plot(Horiz,verticaL)
        ld      a'|     l|      \ verticaL
        andn    $1F  N,
        ld      d'|     a|
        ld      e'|     h|      
        exx
        ld      a'|     c|
        exx
        ld(x)a  de|

\       pop     bc|

\ retrieve counter
        ex(sp)hl
        dec     h'|             
        jrf    nz'| BACK, \ nxtstp
        pop     hl|
    
\ quit   
HERE DISP,   

\ restore ROM paging.
        nextreg #80 P, $FF N,

\ restore interrupt status
        pop     af|
        
        jpf     PO|  HERE 3 + AA,
        
        ei    
        ret                        
    C;



    
\ ____________________________________________________________________

.( ROUT-0 )
\ H=y0, L=x0, B=y1, c=x1
CODE ROUT-0
    PUSH    BC|
    PUSH    DE|
    PUSH    IX|

    LDA()           ' Y0   >BODY AA,    \ horizontal
    LD      H'|     A| 
    LDA()           ' X0   >BODY AA,    \ vertical
    LD      L'|     A|          
    LDA()           ' Y1   >BODY AA,    \ horozontal
    LD      B'|     A|  
    LDA()           ' X1   >BODY AA,    \ vertical
    LD      C'|     A| 
    LDA()           ' ATTRIB >BODY AA,    \ attrib

    CALL    ' ROUT-1 AA,   

    POP     IX|
    POP     DE| 
    POP     BC|
    NEXT
    C;

\ ____________________________________________________________________

\ given two points p1(x1,y1) and p0(x0,y0) and ATTRIB preset to c
\ draw a line using Bresenham's line algorithm from p0 to p1.
\ Coordinates out-of-range are ignored without error.
\
.( DRAW )
: DRAW  ( x1 y1 x0 y0 -- )
    TO Y0   \ -- de
    TO X0   \ --  c
    TO Y1   \ --  a'
    TO X1   \ -- (sp)
    \ compute sign SX, delta DX, sign SY, delta DY and total DIFF
    1 X1 X0 - 
    DUP ABS         TO DX
    +-              TO SX
    1 Y1 Y0 - 
    DUP ABS NEGATE  TO DY
    +-              TO SY
    DX DY +         TO DIFF
    \ compute boundary value for X to check for paging
    $1F TO MX
    SX 0< IF 0 ELSE MX THEN TO PX
    \ setup page for first pixel
\   X0 Y0 PIXELADD DROP
    ROUT-0
; 

