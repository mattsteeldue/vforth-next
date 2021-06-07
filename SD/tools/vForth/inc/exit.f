\
\ exit.f
\
.( EXIT )
\
\ Used inside colon-definition to return control to caller.
\
: EXIT ( -- )
    COMPILE ;S
; IMMEDIATE
