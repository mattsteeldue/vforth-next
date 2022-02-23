\
\ action-of.f
\
.( ACTION-OF ) 
\
\ Return xt of DEFER define word.
\
\ Used in the form
\  ACTION-OF nnnn
\
: ACTION-OF ( -- xt )
   STATE @ IF
     POSTPONE ['] COMPILE DEFER@
   ELSE
     ' DEFER@
   THEN ; IMMEDIATE