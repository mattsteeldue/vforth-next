\
\ ;s.f
\
.( ;S is obsolete: prefer EXIT ) 6 EMIT
\
\ Used inside colon-definition to return control to caller.
\
CREATE ;S ( -- )

    ' EXIT  >BODY
    ' ;S    !

