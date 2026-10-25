\
\ xrandomize.f
\
\ v-Forth 1.8 - NextZXOS version - 2026-10-25
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ XRANDOMIZE ( d -- ): sets the 32-bit state of XRND.  After a reset,
\ NextBASIC's RANDOMIZE 1 corresponds to 1. XRANDOMIZE (or 1 0).
\ Reference model: util/next-rnd.py.  planners/archive/NEXTBASIC-RND-PLAN.md
\
.( XRANDOMIZE )
\
NEEDS XSEED
\
: XRANDOMIZE  ( d -- )
    XSEED 2!
;
\
