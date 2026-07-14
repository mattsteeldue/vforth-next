\
\ paint.f
\
\ PAINT - flood fill via Scanline Span Fill (Smith 1979).
\ Replaces the old probe-from-seed-column algorithm that failed on any
\ concave shape (analysis and plan in prompts/PAINT-PLAN.md).
\
\ An explicit seed stack keeps the return-stack depth constant, so
\ large areas cannot overflow the return stack as recursion would.
\ The seed stack lives in a dedicated 8K page of expansion RAM,
\ reserved from NextZXOS (service $01BD, IDE_BANK -- see PAINT-ALLOC
\ / PAINT-FREE below) and mapped through MMU7 on each access, the
\ same mechanism lib/LED.f uses for its row paging. This holds 2048
\ seeds (vs. 256 for the previous dictionary-resident $400 ALLOT
\ buffer); on overflow new seeds are silently dropped, which at
\ worst leaves part of a pathological shape (e.g. a fine comb)
\ unfilled.
\
\ This file is pulled in by lib/GRAPHICS.f or lib/GRAPHICS-COMMON.f
\ via NEEDS PAINT: it compiles against the vectored primitives
\ PLOT POINT EDGE and the V-RANGE / H-RANGE values those modules
\ define. Do not load it on a bare system.
\
.( PAINT )
\

\ dedicated 8K page for the seed stack (pages 32-39 are HEAP; 40-47
\ are reserved for purposes such as this one -- see lib/LED.f)
40 CONSTANT PAINT-PAGE

\ seed stack: base address once PAINT-PAGE is mapped onto MMU7;
\ PAINT-MAX is the byte-size bound (2048 seeds of two cells each)
$E000 CONSTANT PAINT-STACK
$2000 CONSTANT PAINT-MAX
VARIABLE PAINT-SP

\ reserve/release PAINT-PAGE via NextZXOS $01BD (IDE_BANK): H:L is
\ passed as one cell (H=0 -> ZX memory, L=reason: 2=reserve, 3=free),
\ DE carries the 8K page id. See the M_P3DOS CODE header (src/F17e.f)
\ for the full ( n1 n2 n3 n4 a -- n5 n6 n7 n8  f ) stack contract.
: PAINT-ALLOC  ( -- )
    2 PAINT-PAGE 0 0 $01BD M_P3DOS
    >R 2DROP 2DROP R>
    IF 40 ERROR THEN            \ out-of-memory: no 8K page available
;

: PAINT-FREE  ( -- )
    3 PAINT-PAGE 0 0 $01BD M_P3DOS
    >R 2DROP 2DROP R>
    DROP
;

VARIABLE PAINT-Y1               \ span bounds on the current row
VARIABLE PAINT-Y2
VARIABLE PAINT-RUN              \ inside-a-free-run flag while seeding

: PAINT-PUSH  ( x y -- )        \ save a seed; silently drop when full
    PAINT-SP @ PAINT-MAX U< IF
        PAINT-PAGE MMU7!             \ MMU7 is shared with PLOT/POINT/EDGE
        PAINT-STACK PAINT-SP @ + 2!
        4 PAINT-SP +!
    ELSE
        2DROP
    THEN
;

: PAINT-POP  ( -- x y tf | ff ) \ tf with a seed, ff when empty
    PAINT-SP @ IF
        -4 PAINT-SP +!
        PAINT-PAGE MMU7!             \ MMU7 is shared with PLOT/POINT/EDGE
        PAINT-STACK PAINT-SP @ + 2@
        -1
    ELSE
        0
    THEN
;

\ widen y towards 0 up to the last free pixel of the row
: (PAINT-YL)  ( x y -- yl )
    BEGIN
        DUP 0> IF
            2DUP 1- POINT EDGE NOT
        ELSE
            0
        THEN
    WHILE
        1-
    REPEAT
    SWAP DROP
;

\ widen y towards H-RANGE up to the last free pixel of the row
: (PAINT-YR)  ( x y -- yr )
    BEGIN
        DUP H-RANGE 1- < IF
            2DUP 1+ POINT EDGE NOT
        ELSE
            0
        THEN
    WHILE
        1+
    REPEAT
    SWAP DROP
;

\ plot the whole span PAINT-Y1..PAINT-Y2 of row x
: (PAINT-SPAN)  ( x -- x )
    PAINT-Y2 @ 1+  PAINT-Y1 @  DO
        DUP I PLOT
    LOOP
;

\ push one seed per free run of row nx inside the span bounds
: (PAINT-ROW)  ( nx -- nx )
    0 PAINT-RUN !
    PAINT-Y2 @ 1+  PAINT-Y1 @  DO
        DUP I POINT EDGE IF
            0 PAINT-RUN !
        ELSE
            PAINT-RUN @ 0= IF
                DUP I PAINT-PUSH
                1 PAINT-RUN !
            THEN
        THEN
    LOOP
;

\ fill the span through one seed, then queue the rows above and below
: (PAINT-SEED)  ( x y -- )
    2DUP POINT EDGE IF
        2DROP EXIT
    THEN
    2DUP (PAINT-YR) PAINT-Y2 !
    OVER >R (PAINT-YL) PAINT-Y1 ! R>
    (PAINT-SPAN)                ( x )
    DUP IF
        DUP 1- (PAINT-ROW) DROP
    THEN
    DUP 1+ V-RANGE U< IF
        DUP 1+ (PAINT-ROW) DROP
    THEN
    DROP
;

: PAINT  ( x y -- )
    PAINT-ALLOC                     \ reserve the 8K seed-stack page
    0 PAINT-SP !
    PAINT-PUSH
    BEGIN
        PAINT-POP
    WHILE
        (PAINT-SEED)
        ?TERMINAL IF 0 PAINT-SP ! THEN  \ [BREAK] empties the seed stack
    REPEAT
    PAINT-FREE                      \ release the 8K seed-stack page
;
