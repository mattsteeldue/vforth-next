\
\ thru.f
\
.( THRU )
\
\ Load (interpret) Screens scr1 through scr2 inclusive.
\ Classic Starting FORTH definition: it works because LOAD saves and
\ restores BLK and >IN around INTERPRET, so the DO-LOOP index in I
\ is valid again after each iteration.
\ Do not mix with --> chaining: screens already chained-in by -->
\ would be loaded twice.

: THRU ( scr1 scr2 -- )
    1+ SWAP
    DO
        I LOAD
    LOOP
;
