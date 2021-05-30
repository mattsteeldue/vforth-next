\
\ case.f
\
\ Case-of structure 
\
.( Case-of structure. )  
\ Used in the form:
\  n0 CASE  n1 OF ... ENDOF
\           ...
\           nz OF ... ENDOF  
\                 ... ( else-part )
\  ENDCASE
\
: CASE ( n0 -- ) \ begin case-of structure
    ?COMP 
    CSP @ 
    !CSP 
    4 
; IMMEDIATE

\
: (OF)  ( n0 nk -- ) \ run-time compiled by OF
    OVER = DUP 
    IF 
        SWAP DROP 
    ENDIF 
;

\
: OF  ( n0 nk -- )
    4 ?PAIRS 
    COMPILE (OF) 
    COMPILE 0BRANCH HERE 0 ,
    5 
; IMMEDIATE

\
: ENDOF  ( -- )
    5 ?PAIRS 
    COMPILE BRANCH HERE 0 ,
    SWAP 2 [COMPILE] THEN 
    4 
; IMMEDIATE

\
: ENDCASE
    4 ?PAIRS 
    COMPILE DROP
    BEGIN 
        SP@ CSP @ -
    WHILE 
        2 [COMPILE] THEN
    REPEAT 
    CSP ! 
; IMMEDIATE
\
