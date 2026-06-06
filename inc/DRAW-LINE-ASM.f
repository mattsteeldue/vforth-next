\
\ draw-line-asm.f
\
.( DRAW-LINE-ASM )
\
NEEDS GRAPHICS

NEEDS ASSEMBLER

MARKER TASK

\ ____________________________________________________________________

.( ROUT-DELTA-X0 )
CODE ROUT-DELTA-X0
    incx    de| \ this instruction must be INC DE when SX > 0,
                \ or DEC DE when SX < 0,
                \ modified at runtime...
    ret
    C;

\ ____________________________________________________________________

.( ROUT-DELTA-Y0 )
CODE ROUT-DELTA-Y0
    inc     c'| \ this instruction must be INC C when SY > 0,
                \ or DEC C when SY < 0,
                \ modified at runtime...
    ret
    C;

\ ____________________________________________________________________

.( ROUT-DELTA-PAGE )
CODE ROUT-DELTA-PAGE
    inc     a'| \ this instruction must be INC A when SX > 0,
                \ or DEC A when SX < 0,
                \ modified at runtime...
    ret
    C;

\ ____________________________________________________________________

.( ROUT-MASK-BOUNDARY )
CODE ROUT-MASK-BOUNDARY
    andn    $1F   N,
    ret
    C;

\ ____________________________________________________________________

.( ROUT-PASS-BOUNDARY )
CODE ROUT-PASS-BOUNDARY
    cpn     0     N,
    ret
    C;

\ ____________________________________________________________________

\ Input:
\   BC  : Y0 pixel coord
\   DE  : X0 pixel coord
\    H  : MX mask for boundary-page check
\    L  : Y1 pixel coord
\   IX  : X1 pixel coord
\  B'C' : DY delta y
\  D'E' : DX delta x
\  H'   : SX sign x
\  L'   : SY sign y

.( ROUT-1 )
CODE ROUT-1

\ compute boundary value for X to check for paging
\   SX 0< IF 0 ELSE MX THEN TO PX
    ld      a'|     h|          \ MX
    ld()a   ' ROUT-MASK-BOUNDARY 1+  AA,  \ Always MX
    ld()a   ' ROUT-PASS-BOUNDARY 1+  AA,  \ defaults PX equals MX when SX>0

\ Patch instructions "inc de" and "inc c" above, to increment X0 and Y0
    exx
     \ check SX
     ld      a'|     h|         \ get SX, then H is free to use
     rla
     ldn     a'|   $13   N,     \ "inc de" when SX>0
     ldn     h'|   $3C   N,     \ "inc a"  when SX>0
     \ if SX < 0
     jrf    nc'|  HOLDPLACE
         xora    a|             \ PX zero  when SX<0
         ld()a   ' ROUT-PASS-BOUNDARY 1+  AA,
         ldn    a'|   $1B   N,  \ "dec de" when SX<0
         inc    h'|             \ "dec a"  when SX<0
     HERE DISP,
     ld()a    ' ROUT-DELTA-X0 AA,
     ld     a'|      h|
     ld()a    ' ROUT-DELTA-PAGE AA,

    \ check SY
     ld      a'|     l|         \ get SY, alternate H'L' are free to use now
     rla
     ldn     a'|   $03   N,     \ inc bc when SY is +1
     jrf    nc'|  HOLDPLACE
         ldn     a'|   $0B   N, \ dec bc when SY is -1
     HERE DISP,
     ld()a     ' ROUT-DELTA-Y0 AA,

    \ save X1 on top of stack.
     push    ix|

    \ compute DIFF := DX + DY
     ldx     ix|  0  NN,
     addix   de|
     addix   bc|
    exx

    \ keep Y1 in alternate accumulator, HL are free to use now
    ld      a'|     l|
    exafaf

\ --BEGIN \ main loop
    HERE  \ resolved by JR BACK, at AGAIN

\ --    ?TERMINAL IF QUIT THEN

\ X0 Y0 PLOT plot current position via MMU7!
\ --    ATTRIB X0 FLIP Y0 + $E000 OR C!
        ld      a'|     e|
        orn     $E0      N,
        ld      h'|     a|
        ld      l'|     c|
        lda()   ' ATTRIB >BODY AA,
        ld   (hl)'|     a|

\ take twice error and compare with deltas
\ --    DIFF 2* TO ERR
        push    ix|
        exx
         pop     hl|
         addhl   hl|

         push    bc|
         addbc, $8000 NN,
         addhl, $8000 NN,

\ --    ERR DY < NOT IF
         anda     a|
         sbchl   bc|
         pop     bc|
        exx
        jrf     cy'| HOLDPLACE \ PASS1

\ verify final x is reached
\ --        X0 X1 = IF EXIT THEN
            pop     hl|
            push    hl|
            anda     a|
            sbchl   de|

            pop     hl|
            retf     z|
            push    hl|

\ decrement error by DY
\ --        DY +TO DIFF
            exx
             addix   bc|
            exx

\ check for X0 crossing page-bound
\ --        X0 MX AND PX = IF
            ld      a'|     e|
            call  ' ROUT-MASK-BOUNDARY  AA,  \ and $1f  for LAYER2 one 8kpage
            call  ' ROUT-PASS-BOUNDARY  AA,  \ cp  0    OR $ff
            jrf    nz'| HOLDPLACE \ NOPAGE

                \ read current page
                ldn     a'| #87 N,
                \ read current MMU7 paging status
                push    bc|
                ldx     bc| HEX 243B NN,
                out(c)  a'|
                inc     b'|
                in(c)   a'|
                pop     bc|
                \   MMU7@ SX +
                call ' ROUT-DELTA-PAGE AA,

                \   L2-RAM-PAGE MAX
                cpn     L2-RAM-PAGE  N,
                pop     hl|
                retf    cy|
                push    hl|
                \   L2-MAX-PAGE MIN
                cpn     L2-RAM-PAGE #10 +  N,
                pop     hl|
                retf    nc|
                push    hl|

                \   MMU7!
                nextrega DECIMAL 87 P,   \ nextreg 87,a
\ --        THEN
\ NOPAGE:
            HERE DISP, \ THEN,

\ --        SX +TO X0 THEN
            call  ' ROUT-DELTA-X0  AA,

\ PASS1:
        HERE DISP, \ THEN,

\ --    DIFF 2* TO ERR          \ take twice error and compare with deltas
        push    ix|
        exx
         pop     hl|
         addhl   hl|

         push    de|
         addhl, $8000 NN,
         addde, $8000 NN,

\ --    ERR DX > NOT IF         \
         exdehl
         anda     a|
         sbchl   de|
         pop     de|
        exx
        jrf     cy'| HOLDPLACE \ PASS2

\ --        Y0 Y1 = IF EXIT THEN
            exafaf
            anda     a|
            sbchl   hl|
            ld      l'|     a|
            sbchl   bc|

            pop     hl|
            retf     z|
            push    hl|
            exafaf

\ --        DX +TO DIFF     \ increment error by DX
            exx
             addix  de|
            exx

\ --        SY +TO Y0 THEN
            call  ' ROUT-DELTA-Y0  AA,

\ PASS2:
        HERE DISP, \ THEN,

\ --AGAIN

    jr      BACK,

    C;

\ ____________________________________________________________________

.( ROUT-0 )
CODE ROUT-0
    push    bc|
    push    de|
    push    ix|

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

    ldx()   bc|     ' Y0   >BODY AA,
    ldx()   de|     ' X0   >BODY AA,
    ldix()          ' X1   >BODY AA,
    lda()           ' MX   >BODY AA,
    ld      h'|    a|
    lda()           ' Y1   >BODY AA,
    ld      l'|    a|

    exx
     ldx()   bc|    ' DY   >BODY AA,
     ldx()   de|    ' DX   >BODY AA,
     lda()          ' SX   >BODY AA,
     ld      h'|    a|
     lda()          ' SY   >BODY AA,
     ld      l'|    a|
    exx

    call    ' ROUT-1 AA,

    pop     ix|
    pop     de|
    pop     bc|
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
