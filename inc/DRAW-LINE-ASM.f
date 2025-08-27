\
\ draw-line.f  
\
.( DRAW-LINE-ASM )
\
NEEDS ASSEMBLER
NEEDS GRAPHICS

MARKER TASK

\ ____________________________________________________________________

.( ROUT-DELTA-X0 )
CODE ROUT-DELTA-X0
    INCX    DE| \ this instruction must be INC DE when SX > 0, or DEC DE when SX < 0, modified at runtime...
    RET
    C;

\ ____________________________________________________________________

.( ROUT-DELTA-Y0 )
CODE ROUT-DELTA-Y0
    INC     C'| \ this instruction must be INC C when SY > 0, or DEC C when SY < 0, modified at runtime...
    RET
    C;

\ ____________________________________________________________________

.( ROUT-MASK-BOUNDARY )
CODE ROUT-MASK-BOUNDARY
    ANDN    $1F   N,
    RET
    C;

\ ____________________________________________________________________

.( ROUT-PASS-BOUNDARY )
CODE ROUT-PASS-BOUNDARY
    CPN     0     N,
    RET
    C;

\ ____________________________________________________________________

.( ROUT-DELTA-PAGE )
CODE ROUT-DELTA-PAGE
    INC     A'| \ this instruction must be INC A when SX > 0, or DEC A when SX < 0, modified at runtime...
    RET
    C;

\ ____________________________________________________________________

\ Input: 
\   BC  : Y0 
\   DE  : X0 
\    H  : MX mask for boundary-page check
\    L  : Y1 
\   IX  : X1    
\  B'C' : DY   
\  D'E' : DX
\  H'   : SX    
\  L'   : SY 

.( ROUT-1 )
CODE ROUT-1

\ compute boundary value for X to check for paging
\   SX 0< IF 0 ELSE MX THEN TO PX
    LD      A'|     H|          \ MX
    LD()A    ' ROUT-MASK-BOUNDARY 1+  AA,  \ Always MX
    LD()A    ' ROUT-PASS-BOUNDARY 1+  AA,  \ defaults PX equals MX when SX>0

\ Patch instructions "inc de" and "inc c"  here above used to increment X0 and Y0
    EXX
     \ check SX
     LD      A'|     H|         \ get SX, then H is free to use
     RLA
     LDN     A'|   $13   N,     \ "inc de" when SX>0
     LDN     H'|   $3C   N,     \ "inc a"  when SX>0
     \ if SX < 0
     JRF    NC'|  HOLDPLACE
         XORA    A|             \ PX zero  when SX<0
         LD()A   ' ROUT-PASS-BOUNDARY 1+  AA,
         LDN    A'|   $1B   N,  \ "dec de" when SX<0
         INC    H'|             \ "dec a"  when SX<0
     HERE DISP,        
     LD()A    ' ROUT-DELTA-X0 AA, 
     LD     A'|      H|
     LD()A    ' ROUT-DELTA-PAGE AA, 
    
    \ check SY
     LD      A'|     L|         \ get SY, alternate H'L' are free to use now
     RLA
     LDN     A'|   $03   N,     \ inc bc when SY is +1
     JRF    NC'|  HOLDPLACE  
         LDN     A'|   $0B   N, \ dec bc when SY is -1
     HERE DISP,        
     LD()A     ' ROUT-DELTA-Y0 AA,

    \ save X1 on top of stack.
     PUSH    IX|

    \ compute DIFF := DX + DY    
     LDX     IX|  0  NN,
     ADDIX   DE|
     ADDIX   BC|
    EXX

    \ keep Y1 in alternate accumulator, HL are free to use now
    LD      A'|     L|
    EXAFAF

\ --BEGIN \ main loop
    HERE  \ resolved by JR BACK, at AGAIN
 
\ --    ?TERMINAL IF QUIT THEN 

\ plot current position via MMU7!
\ --    ATTRIB X0 FLIP Y0 + $E000 OR C!
        LD      A'|     E|
        ORN     $E0      N,
        LD      H'|     A|
        LD      L'|     C|
        LDA()   ' ATTRIB >BODY AA,          
        LD   (HL)'|     A|

\ take twice error and compare with deltas        
\ --    DIFF 2* TO ERR          
        PUSH    IX|
        EXX
         POP     HL|
         ADDHL   HL|

         PUSH    BC|
         ADDBC, $8000 NN,   
         ADDHL, $8000 NN,   
       
\ --    ERR DY < NOT IF    
         ANDA     A|
         SBCHL   BC|
         POP     BC|
        EXX
        JRF     CY'| HOLDPLACE \ PASS1 
 
\ verify final x is reached
\ --        X0 X1 = IF EXIT THEN
            POP     HL|
            PUSH    HL|
            ANDA     A|
            SBCHL   DE|

            POP     HL|
            RETF     Z|
            PUSH    HL|

\ decrement error by DY
\ --        DY +TO DIFF     
            EXX
             ADDIX   BC|
            EXX

\ check for X0 crossing page-bound
\ --        X0 MX AND PX = IF 
            LD      A'|     E|
            CALL  ' ROUT-MASK-BOUNDARY  AA,  \ and $1f  for LAYER2 one 8kpage
            CALL  ' ROUT-PASS-BOUNDARY  AA,  \ cp  0    OR $ff
            JRF    NZ'| HOLDPLACE \ NOPAGE
    
                \ read current page 
                LDN     A'| #87 N,
                \ read current MMU7 paging status
                PUSH    BC|
                LDX     BC| HEX 243B NN, 
                OUT(C)  A'|
                INC     B'|
                IN(C)   A'|
                POP     BC|
                \   MMU7@ SX + 
                CALL ' ROUT-DELTA-PAGE AA,

                \   L2-RAM-PAGE MAX
                CPN     L2-RAM-PAGE  N,
                POP     HL|
                RETF    CY|
                PUSH    HL|
                \   L2-MAX-PAGE MIN
                CPN     L2-RAM-PAGE #10 +  N,
                POP     HL|
                RETF    NC|
                PUSH    HL|

                \   MMU7! 
                NEXTREGA DECIMAL 87 P,   \ nextreg 87,a
\ --        THEN
\ NOPAGE:
            HERE DISP, \ THEN,     
 
\ --        SX +TO X0 THEN
            CALL  ' ROUT-DELTA-X0  AA,
        
\ PASS1:                
        HERE DISP, \ THEN, 
 
\ --    DIFF 2* TO ERR          \ take twice error and compare with deltas
        PUSH    IX|
        EXX
         POP     HL|
         ADDHL   HL|

         PUSH    DE|
         ADDHL, $8000 NN,       
         ADDDE, $8000 NN,   

\ --    ERR DX > NOT IF         \ 
         EXDEHL
         ANDA     A|
         SBCHL   DE|
         POP     DE|
        EXX
        JRF     CY'| HOLDPLACE \ PASS2
 
\ --        Y0 Y1 = IF EXIT THEN
            EXAFAF
            ANDA     A|
            SBCHL   HL|
            LD      L'|     A|
            SBCHL   BC|

            POP     HL|
            RETF     Z|
            PUSH    HL|
            EXAFAF
                                
\ --        DX +TO DIFF     \ increment error by DX
            EXX
             ADDIX  DE|
            EXX

\ --        SY +TO Y0 THEN
            CALL  ' ROUT-DELTA-Y0  AA,

\ PASS2:
        HERE DISP, \ THEN, 
 
\ --AGAIN
    
    JR      BACK,

    C;
        
\ ____________________________________________________________________

.( ROUT-0 )
CODE ROUT-0
    PUSH    BC|
    PUSH    DE|
    PUSH    IX|

\ Prepares register for call
\   BC  : Y0   
\   DE  : X0 
\    H  : MX mask for boundary check
\    L  : Y1 
\   IX  : X1    
\  B'C' : DY   
\  D'E' : DX
\  H'   : SX    
\  L'   : SY 

    LDX()   BC|     ' Y0   >BODY AA, 
    LDX()   DE|     ' X0   >BODY AA, 
    LDIX()          ' X1   >BODY AA, 
    LDA()           ' MX   >BODY AA, 
    LD      H'|    A|
    LDA()           ' Y1   >BODY AA, 
    LD      L'|    A|

    EXX
     LDX()   BC|    ' DY   >BODY AA, 
     LDX()   DE|    ' DX   >BODY AA, 
     LDA()          ' SX   >BODY AA, 
     LD      H'|    A|               
     LDA()          ' SY   >BODY AA, 
     LD      L'|    A|
    EXX

    CALL    ' ROUT-1 AA,   

    POP     IX|
    POP     DE| 
    POP     BC|
    NEXT
    C;

\ ____________________________________________________________________

\ given two points (x1,y1) and (x0,y0) and ATTRIB preset to c
\ draw a line using Bresenham's line algorithm
\ Coordinates out-of-range are ignored without error.
\ 
.( DRAW-LINE-ASM )
: DRAW-LINE-ASM  ( x1 y1 x0 y0 -- )
    TO Y0 \ -- de
    TO X0 \ --  c
    TO Y1 \ --  a'
    TO X1 \ -- (sp)
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
    X0 Y0 PIXELADD DROP

    ROUT-0
;
