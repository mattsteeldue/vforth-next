\
\ xseed.f
\
\ v-Forth 1.8 - NextZXOS version - 2026-10-25
\ MIT License (c) 1990-2026 Matteo Vitturi
\
\ XSEED ( -- a ): the 32-bit state of XRND, a 2VARIABLE that starts at 0
\ (taken as 1 by XNEXT).  NextBASIC keeps the lower half of its own state
\ in SEED (23670) and the upper half in DivMMC RAM, out of reach: XSEED is
\ all in vForth and leaves SEED alone, so RND, RANDOM and CHOOSE are not
\ disturbed.
\ Reference model: util/next-rnd.py.  planners/archive/NEXTBASIC-RND-PLAN.md
\
.( XSEED )
\
NEEDS 2VARIABLE
\
2VARIABLE XSEED
\
