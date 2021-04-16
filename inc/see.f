\
\ see.f
\
.( SEE Decompiler ) CR
\
DECIMAL
\
NEEDS DUMP
NEEDS INVV
NEEDS TRUV
NEEDS CASE
NEEDS .WORD
\

\
: DEB-N ." Nfa: "   NFA DUP U. C@ . CR ;
: DEB-C ." Cfa: "   CFA DUP U. @ U. CR ;
: DEB-L ." Lfa: "   LFA DUP U. @ ID. CR ;
: DEB-P ." Pfa: " DUMP ;
: DEB-LIT 2+ DUP @ . ;
: DEB-BRN DUP @ .WORD INVV
  DEB-LIT TRUV ;
: DEB-DOT DUP @ .WORD 2+
  COUNT 2DUP INVV TYPE + 2 -
  TRUV SPACE ;
\
' : @      CONSTANT <:>
' ABORT    CONSTANT <AB>
' ;S       CONSTANT <;S>
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
: ?FWD DUP DUP @ U< IF INVV THEN ;
\
: (DELOAD)
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
: DELOAD
    BEGIN
        ?FWD DUP @
        (DELOAD)
        CELL+
        TRUV ?TERMINAL
        OVER @ <AB> = OR
        OVER @ <Q>  = OR
        OVER @ <;S> = OR
        OVER @ <!>  = OR
    UNTIL 
;
\
: (SEE)  ( cfa -- )
    BASE @ SWAP HEX CELL+
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



