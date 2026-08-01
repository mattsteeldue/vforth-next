\
\ .file-size.f
\
.( .FILE-SIZE )
\
\ display number d using seven digit if it is less than 1048576
\ or in KB otherwise.
: .FILE-SIZE ( d -- )
    DUP $10 < IF            \ d       ( less than 1MB )
        7 D.R               \         ( display up to 7 digits )
    ELSE                    \ d
        $400 UM/MOD NIP 0   \ d       ( divide by 1024 )
        5 D.R SPACE         \
        [CHAR] K EMIT       \
    THEN                    \
;
