\
\ action-of.f
\
.( ACTION-OF ) 
\
\ Return xt of DEFER defined word.
\
\ Used in the form
\  ACTION-OF nnnn
\

NEEDS DEFER@


: ACTION-OF ( -- xt )
   STATE @ IF
     [COMPILE] ['] COMPILE DEFER@
   ELSE
     ' DEFER@
   THEN ; IMMEDIATE
