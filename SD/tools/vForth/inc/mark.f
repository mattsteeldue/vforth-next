\
\
\ mark.f
\
\ print in reverse the text using TYPE
\
.( MARK )

\
NEEDS INVV
NEEDS TRUV
\
\ MARK
: MARK ( a n -- )
    INVV TYPE TRUV
;

DECIMAL
