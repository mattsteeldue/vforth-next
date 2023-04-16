\
\ see.f
\
.( SEE Inspector ) 
\
BASE @ 
DECIMAL
\

\ NEEDS S"
\ NEEDS FAR
NEEDS [']
NEEDS DUMP
NEEDS INVV
NEEDS TRUV
NEEDS CASE
NEEDS .WORD
NEEDS .S
NEEDS FAR
\

\ HP @ 
\ HEX -00F0 HP !

\ display NFA, LFA, CFA report-rows
\ : DEB-NFA ( pfa -- )  S" Nfa: " TYPE NFA DUP U. C@ . CR ;
\ : DEB-LFA ( pfa -- )  S" Lfa: " TYPE LFA DUP U. @ ID. CR ;
\ : DEB-CFA ( pfa -- )  S" Cfa: " TYPE CFA DUP U. 2 CFA NEGATE + @ U. ;

: DEB-NFA ( pfa -- )  ." Nfa: "      NFA DUP U. C@ . CR ;
: DEB-LFA ( pfa -- )  ." Lfa: "      LFA DUP U. @ DUP U. ID. CR ;
: DEB-CFA ( pfa -- )  ." Cfa: "      CFA DUP U. 2 CFA NEGATE + @ U. ;


\ CR HP ? CR

\ HP !

\ display simple DUMP 
: DEB-PFA ( pfa -- )             CFA 24 DUMP ;

\ display current definition ID.
: DEB-W   ( pfa -- pfa   )  DUP @ .WORD ;
\ display current definition ID.
: DEB-N   ( pfa -- pfa   )  DUP @ . ;
\ display literal following LIT
: DEB-L   ( pfa -- pfa   )  DEB-W CELL+ DEB-N ;
\ display offset following any branching definition
: DEB-B   ( pfa -- pfa   )  DEB-W CELL+ INVV DEB-N ;
\ display string given adddress a
: DEB-"   (   a -- u     )  COUNT DUP >R INVV TYPE TRUV SPACE R> ;
\ display old-way compiled string
: DEB."  ( pfa -- pfa    )  DEB-W CELL+ DUP       DEB-" + 1- ;
\ display heap string
: DEB.S  ( pfa -- pfa    )  DEB-W CELL+ DUP @ FAR DEB-" DROP ;
\ a forward definition is reported in inverse-video
: ?FWD ( pfa -- pfa ) DUP DUP @ U< IF INVV THEN ;

\ de-load a single word
: (DELOAD) ( pfa -- pfa )      
    DUP @
    CASE
        ['] (?DO)       OF  DEB-B  ENDOF
        ['] (+LOOP)     OF  DEB-B  ENDOF
        ['] (LOOP)      OF  DEB-B  ENDOF
        ['] (LEAVE)     OF  DEB-B  ENDOF
        ['] 0BRANCH     OF  DEB-B  ENDOF
        ['] BRANCH      OF  DEB-B  ENDOF
        ['] LIT         OF  DEB-L  ENDOF
        ['] (.")        OF  DEB."  ENDOF
      \ ['] (H")        OF  DEB.S  ENDOF
        ['] COMPILE     OF  DEB-W CELL+ INVV DEB-W ENDOF
            DUP .WORD
    ENDCASE
; 

\ iteratively de-load whole definition
: DELOAD ( pfa -- pfa ) 
    CR
    BEGIN
        \ ?FWD    
        (DELOAD)
        CELL+
        TRUV ?TERMINAL      \ exit for BREAK keypress
        OVER @ ['] ABORT   = OR
        OVER @ ['] QUIT    = OR
        OVER @ ['] EXIT    = OR
        OVER @ ['] WARM    = OR
        OVER @ ['] (;CODE) = OR
    UNTIL 
    (DELOAD)
    
;

\ display header and deload
: (SEE)  ( xt -- )
    BASE @                  \ xt b
    SWAP HEX                \ b  xt
    >BODY                   \ b  a
    DUP DEB-NFA             \ b  a    
    DUP DEB-LFA             \ b  a
    DUP DEB-CFA             \ b  a
    DUP CFA @ ['] : @ =     \ b  a  f
    IF                      \ b  a
        SWAP BASE !         \ a
        DELOAD              \ a
        DROP         
    ELSE                    \ b  a
        HEX DEB-PFA           \ b
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

