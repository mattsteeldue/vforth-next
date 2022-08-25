\
\ see.f
\
.( SEE Inspector ) 
\
BASE @ 
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
: DEB-L   ( pfa -- ) ." Lfa: "   LFA DUP U. @ ID. CR ;
: DEB-C   ( pfa -- ) ." Cfa: "   CFA DUP U.  2 CFA NEGATE +  @ U. ;
: DEB-P   ( pfa -- )             CFA 32 DUMP ;
: DEB-LIT ( pfa -- ) CELL+ DUP @ . ;
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
' (LEAVE)  CONSTANT <LE>
' 0BRANCH  CONSTANT <0B>
' LIT      CONSTANT <LIT>
' (.")     CONSTANT <.">
' QUIT     CONSTANT <Q>
' CONSTANT CONSTANT <C>
' VARIABLE CONSTANT <V>
' WARM     CONSTANT <!>
' (;CODE)  CONSTANT <;C>
\
: ?FWD ( pfa -- pfa ) DUP DUP @ U< IF INVV THEN ;
\
: (DELOAD) ( pfa -- pfa )      
    DUP @
    CASE
        <D>   OF DEB-BRN ENDOF
        <+L>  OF DEB-BRN ENDOF
        <L>   OF DEB-BRN ENDOF
        <B>   OF DEB-BRN ENDOF
        <LE>  OF DEB-BRN ENDOF
        <0B>  OF DEB-BRN ENDOF
        <LIT> OF DEB-LIT ENDOF
        <.">  OF DEB-DOT ENDOF
        DUP .WORD
    ENDCASE
; 
\
: DELOAD ( pfa -- pfa ) 
    CR
    BEGIN
        ?FWD    
        (DELOAD)
        CELL+
        TRUV ?TERMINAL      \ exit for BREAK keypress
        OVER @ <AB> = OR    \ or ABORT
        OVER @ <Q>  = OR    \ or QUIT
        OVER @ <;S> = OR    \ or EXIT
        OVER @ <!>  = OR    \ or WARM
        OVER @ <;C> = OR    \ or (;CODE)
    UNTIL 
    (DELOAD)
    
;
\
: (SEE)  ( xt -- )
    BASE @                  \ xt b
    SWAP HEX                \ b  xt
    >BODY                   \ b  a
    DUP DEB-N               \ b  a    
    DUP DEB-L               \ b  a
    DUP DEB-C               \ b  a
    DUP CFA @ <:> =         \ b  a  f
    IF                      \ b  a
        SWAP BASE !         \ a
        DELOAD              \ a
        DROP         
    ELSE                    \ b  a
        HEX DEB-P           \ b
        BASE ! 
    THEN 
;
\
: SEE  ( -- )
  -FIND 0= 0 ?ERROR  
  .   
  CR (SEE) 
;

BASE !

