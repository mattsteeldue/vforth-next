\
\ %noname.f
\
.( :NONAME included ) 6 EMIT
\
\ Tipical usage is
\   DEFER print
\   :NONAME . ;   IS print 
\
: :NONAME ( -- cccc )
    ?EXEC

    here                    \ NFA
    [ hex ] A081 ,          \ name is undetectable
    
    latest ,                \ LFA
    
    here swap               \ xt will be left on TOS
    [ ' ' @ ] LITERAL ,     \ CFA

    current @ !
    SMUDGE

    !CSP
    [COMPILE] ]
;

