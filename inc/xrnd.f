\
\ xrnd.f
\
\ v-Forth 1.8 - NextZXOS version - 2026-10-25
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ XRND ( u -- u2 ): from 0 to u-1, as NextBASIC's RND (n) and %RND n
\ (with %CODE bit 0 clear); 0 XRND and 1 XRND give 0 and take no step.
\ The upper half of the next state is masked to the smallest 2^k-1 not
\ below u-1 and kept only if it is in range: no value is favoured.
\ The numbers are BASIC's only from the same state: see XRANDOMIZE.
\ Reference model: util/next-rnd.py.  planners/archive/NEXTBASIC-RND-PLAN.md
\
.( XRND )
\
NEEDS XSEED
NEEDS XNEXT
\
: XRND  ( u -- u2 )
    DUP 2 U< IF  DROP 0 EXIT  THEN      \ 0 and 1: no step is taken
    1- 0                                \ lim mask
    BEGIN  2DUP SWAP U<  WHILE  2* 1+  REPEAT  \ while mask < lim
    SWAP                                \ mask lim
    BEGIN
        OVER  XSEED 2@ XNEXT  2DUP XSEED 2!  NIP  AND   \ mask lim r
        2DUP U<                         \ lim < r: draw again
    WHILE
        DROP
    REPEAT
    NIP NIP
;
\
