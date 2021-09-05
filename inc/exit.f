\
\ exit.f
\
.( EXIT included. It substitutes ;S ) 6 EMIT
\
\ Used inside colon-definition to return control to caller.
\
CREATE EXIT ( -- )

    ' ;S      >BODY
    ' EXIT    !
