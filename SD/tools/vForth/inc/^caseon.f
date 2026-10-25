\
\ ?caseon.f
\
.( ?CASEON )
\
\ True if vForth is case-sensitive (after CASEON), false after CASEOFF.
\ CASEON and CASEOFF patch the first byte of the uppercase routine:
\ $C9 (ret) skips the folding, $00 (nop) lets it run. Their code is
\   ld a, n      3E n
\   ld (nn), a   32 lo hi
\ so the address of that byte is the cell at CASEON's xt + 3.
\ It is read once, at compile time.
\
: ?CASEON ( -- f )
    [ ' CASEON 3 + @ ] LITERAL C@ $C9 =
;
