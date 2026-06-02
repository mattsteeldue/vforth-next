\
\ exit.f
\
.( EXIT included. It substitutes ;S ) 
\
\ Used inside colon-definition to return control to caller.
\
CREATE EXIT ( -- )

    ' ;S      >BODY
    ' EXIT    !
