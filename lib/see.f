\
\ see.f
\
.( SEE Decompiler ) 
\
DECIMAL
\
NEEDS DUMP
NEEDS INVV
NEEDS TRUV
NEEDS CASE
NEEDS .WORD
NEEDS .S
\

\
: DEB-N   ( pfa -- ) ." Nfa: "   NFA DUP U. C@ . CR ;
: DEB-C   ( pfa -- ) ." Cfa: "   CFA DUP U. @ U. CR ;
: DEB-L   ( pfa -- ) ." Lfa: "   LFA DUP U. @ ID. CR ;
: DEB-P   ( pfa -- ) ." Pfa: "   32 DUMP ;
: DEB-LIT ( pfa -- ) 2+ DUP @ . ;
: DEB-BRN ( pfa -- ) DUP @ .WORD INVV
  DEB-LIT TRUV ;
: DEB-DOT ( pfa -- ) DUP @ .WORD CELL+
  COUNT 2DUP INVV TYPE + CELL-
  TRUV SPACE ;
\
' : @      CONSTANT <:>
' ABORT    CONSTANT <AB>
' EXIT     CONSTANT <;S>
' (?DO)    CONSTANT <D>
' (+LOOP)  CONSTANT <+L>
' (LOOP)   CONSTANT <L>
' BRANCH   CONSTANT <B>
' 0BRANCH  CONSTANT <0B>
' LIT      CONSTANT <LIT>
' (.")     CONSTANT <.">
' QUIT     CONSTANT <Q>
' CONSTANT CONSTANT <C>
' VARIABLE CONSTANT <V>
' WARM     CONSTANT <!>
\
: ?FWD ( pfa -- pfa ) DUP DUP @ U< IF INVV THEN ;
\
: (DELOAD) ( pfa a  -- )      
    DUP @
    CASE
        <D>   OF DEB-BRN ENDOF
        <+L>  OF DEB-BRN ENDOF
        <L>   OF DEB-BRN ENDOF
        <B>   OF DEB-BRN ENDOF
        <0B>  OF DEB-BRN ENDOF
        <LIT> OF DEB-LIT ENDOF
        <.">  OF DEB-DOT ENDOF
        DUP .WORD
    ENDCASE
; 
\
: DELOAD ( pfa -- pfa ) 
    BEGIN
        ?FWD    ( pfa -- )
        (DELOAD)
        CELL+
        TRUV ?TERMINAL      \ exit for BREAK keypress
        OVER @ <AB> = OR    \ or ABORT
        OVER @ <Q>  = OR    \ or QUIT
        OVER @ <;S> = OR    \ or EXIT
        OVER @ <!>  = OR    \ or WARM
    UNTIL 
    (DELOAD)
;
\
: (SEE)  ( xt -- )
    BASE @ SWAP HEX 
    >BODY
    DUP DEB-N  
    DUP DEB-L
    DUP DEB-C  
    DUP CFA @ <:> =
    IF
        DECIMAL DELOAD  DROP BASE !
    ELSE
        SWAP BASE ! DEB-P
    ENDIF 
;
\
: SEE  ( -- )
  -FIND 0= 0 ?ERROR  
  .   
  CR (SEE) 
;



