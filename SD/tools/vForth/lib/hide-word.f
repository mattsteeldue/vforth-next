\
\ hide-word.f
\
\ Used in the form HIDE-WORD cccc  to prevent -FIND to find  cccc
\ patching the LFA of the definition that folows it.
\ Cannot be used on the LATEST word, obviously
\ And cannot be FORGETted directly
\
\   ##  USE WITH CARE ##
\
: HIDE-WORD ( a -- )
  ' >BODY LFA CONTEXT @
  BEGIN
    @ PFA LFA 2DUP = OVER @ AND
  UNTIL
;
; DECIMAL

