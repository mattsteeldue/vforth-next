\
\ (compare).f
\
." (COMPARE) "
\
\ Compatibility word. Up to build 2026-10-20 (COMPARE) was the core
\ primitive and COMPARE was built on it; since build 2026-10-28 COMPARE
\ is in the core and (COMPARE) is this colon on it.
\ It compares n bytes at a1 with n bytes at a2: 0 if equal, 1 if a1 is
\ greater, -1 if a1 is less. Case-insensitive unless CASEON.
\
: (COMPARE)  ( a1 a2 n -- b )
    TUCK COMPARE                        \ a1 n a2 n
;
