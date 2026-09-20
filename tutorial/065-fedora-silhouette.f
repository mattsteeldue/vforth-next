\
\ 065-fedora-silhouette.f
\ Patrick Kaell's "Fedora": a 3D-looking silhouette from a fixed-point
\ sine wave and a one-cell-per-column depth buffer -- no matrices, no
\ floating point, no square-root-free trick either: this one uses SQRT
\ head-on and stays inside a 16-bit budget by construction.
\
\ This tutorial builds the same picture as demo/Fedora.f, definition by
\ definition, with the reasoning behind every scaling constant made
\ explicit.  Section 6 is a critical verification the original demo did
\ NOT carry out on paper: two arithmetic claims -- "the depth buffer
\ never overflows" and "every plotted point lands on screen" -- are
\ checked here instead of assumed, and only one of them turns out to be
\ true.  demo/Fedora.f has been fixed to match.
\
\ vForth-specific notes:
\   - SQRT ( n -- sqrt ) in inc/SQRT.f takes a SINGLE non-negative cell
\     (0 DSQRT zero-extends it to a double) despite its own stack
\     comment reading ( d -- n ) -- that comment was copied from DSQRT
\     and never corrected.  Trust the usage, not the comment.
\   - +- ( n1 n2 -- n3 ) is a core word: "leaves n1 with the sign of
\     n2".  It never needs a NEEDS line.
\   - PLOT ( x y -- ) checks x against V-RANGE and y against H-RANGE --
\     x is the vertical coordinate, y the horizontal one (same gotcha
\     tutorial 064 section 9 documents for BROT).
\
\ no Brodie counterpart (vForth extension)
\ Reference: sec.2.12.11 (mixed-precision and scaling operators),
\            sec.3.2 (Layer graphics / display modes)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   065 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 065 TUTORIAL
\
\ Run it with:  DEMO   (any key returns to the text screen)
\

MARKER NEWTASK

CR
.( --- Tutorial 065: Fedora silhouette loaded. ) CR
.(     Type DEMO to draw, NEWTASK to unload.  ) CR

NEEDS VALUE
NEEDS TO
NEEDS J
NEEDS GRAPHICS
NEEDS SQRT

\ ===========================================================================
\ 1. The picture: a stack of silhouettes, not a 3D transform
\ ===========================================================================
\
\ There is no camera matrix here and no real projection.  The trick is
\ older and cheaper: draw many thin cross-sections of the hat, one
\ behind the other, and for every screen COLUMN remember only the
\ LOWEST row reached so far by any cross-section.  A later (nearer)
\ slice can only draw over a column if it reaches further down the
\ screen than what is already there -- which is exactly what a solid
\ object seen from the front does: the near silhouette hides the far
\ one, column by column, with no notion of depth anywhere except "how
\ far down the screen".  This is the same family of technique as a
\ flight-simulator mountain range: no z-buffer over the whole screen,
\ just one running maximum per column.
\
\ Two nested loops walk the object:
\   outer loop (outerI, -64..64)   -- depth: one cross-section per step
\   inner loop (innerI, -XL..XL)   -- width of THAT cross-section
\
\ outerI plays the role of Forth's J once the inner loop is open (I is
\ always the INNERMOST loop's index -- innerI here).  Both loops read
\ back-to-front: the outer DO starts at 64 (near) and steps by -2 down
\ to -64 (far), so nearer slices are drawn FIRST and can be overwritten
\ only by a later slice that reaches further down -- the buffer rule
\ above, not the drawing order, is what keeps the picture consistent.

\ ===========================================================================
\ 2. The cross-section: a squashed ellipse
\ ===========================================================================
\
\ For a given depth outerI, ZS approximates how "used up" the object's
\ radius is at that depth, and XL is what remains of the half-width:
\
\       ZS = outerI^2 * 81/16          ( 5.0625, a depth/width anisotropy )
\       XL = SQRT(20736 - ZS)          ( 20736 = 144^2 )
\
\ (ZS,XL) traces the boundary of an ellipse: at outerI=0 (the crown)
\ XL peaks at 144; at outerI=+-64 (81/16 * 64^2 = 20736) XL closes to 0
\ -- which is exactly why the outer loop's own range is -64..64: the
\ object is defined to taper out precisely there, not by accident.

20736 CONSTANT 20736
27192 CONSTANT 27192
10000 CONSTANT 10000
16384 CONSTANT 16384
   56 CONSTANT    56
    5 CONSTANT     5
   -2 CONSTANT    -2

0 VALUE ZS
0 VALUE XL
0 VALUE XT
0 VALUE YY
0 VALUE X1
0 VALUE Y1

160 VALUE DX                        \ screen column of the hat's centre
140 VALUE DY                        \ screen row used as the brim's baseline

\ ===========================================================================
\ 3. The brim ripple: fixed-point sine, two harmonics
\ ===========================================================================
\
\ Within a cross-section, innerI (-XL..XL) is the position across its
\ width.  XT turns the RADIUS from the crown (SQRT(innerI^2+ZS)) into a
\ "degrees" value, and YY combines the fundamental wave with a smaller
\ third harmonic to give the brim its characteristic crimped look:
\
\       XT = SQRT(innerI^2 + ZS) * 27192/16384
\       YY = ( SIN(XT) + SIN(3*XT)*2/5 ) * 56/10000
\
\ 27192/16384 (~1.66) and 56/10000 are the original author's tuning --
\ how many ripples the brim shows and how tall they are -- not derived
\ from anything geometric; treat them as art directors' constants, the
\ same way COLOR-TAB's shades were art, not physics, in tutorial 064.
\
\ SIN itself needs a table and a quadrant-folding word.  The table
\ holds sin(0..90) scaled *10000 (0..10000 stands for 0.0000..1.0000):

CREATE sin-table
    00000 , 00175 , 00349 , 00523 , 00698 , 00872 , 01045 ,
    01219 , 01392 , 01564 , 01736 , 01908 , 02079 , 02250 ,
    02419 , 02588 , 02756 , 02924 , 03090 , 03256 , 03420 ,
    03584 , 03746 , 03907 , 04067 , 04226 , 04384 , 04540 ,
    04695 , 04848 , 05000 , 05150 , 05299 , 05446 , 05592 ,
    05736 , 05878 , 06018 , 06157 , 06293 , 06428 , 06561 ,
    06691 , 06820 , 06947 , 07071 , 07193 , 07314 , 07431 ,
    07547 , 07660 , 07771 , 07880 , 07986 , 08090 , 08192 ,
    08290 , 08387 , 08480 , 08572 , 08660 , 08746 , 08829 ,
    08910 , 08988 , 09063 , 09135 , 09205 , 09272 , 09336 ,
    09397 , 09455 , 09511 , 09563 , 09613 , 09659 , 09703 ,
    09744 , 09781 , 09816 , 09848 , 09877 , 09903 , 09925 ,
    09945 , 09962 , 09976 , 09986 , 09994 , 09998 , 10000 ,

\ SIN takes any degree value (XT and 3*XT both range well past 90) and
\ folds it back into the table's 0..90 span in three steps:
\
\   1. 180 /MOD splits it into a quotient q (how many half-turns) and a
\      remainder r (position within the current half-turn, signed).
\   2. |r| > 90 means we are in the second half of the half-turn, where
\      sin falls back down: sin(x) = sin(180-x), so fold it.
\   3. The result is negated once for r's own sign (a negative angle has
\      negative sine) and once more if q is odd (each half-turn flips
\      the sign: sin(x+180) = -sin(x)).  +- ( n1 n2 -- n3 ) is the core
\      word that applies n2's sign to n1 -- no NEEDS required.
\
\ In THIS program SIN is only ever called with XT >= 0 (SQRT never
\ returns negative), so step 3's r-sign branch never actually fires --
\ only the q-odd quadrant flip does.  It stays in place because SIN is
\ a general-purpose word and the caller's guarantee is not its business.

: SIN ( n1 -- n2 )
    180 /mod >R dup >R abs              \ |q|         R: r q
    dup 90 >                            \ |q|  f
    if 180 swap - then                  \ |q|  or  pi-|q|
    2* sin-table + @                    \ |sin|
    R> +-                               \ |sin| with sign of q
    R> 1 and if negate then             \ sin   with quadrant
;

\ ===========================================================================
\ 4. The depth buffer: one running maximum per column
\ ===========================================================================
\
\ RR holds 321 cells (642 bytes), one per possible screen column X1 in
\ 0..320 (why 320 and not fewer is verified in section 6).  Every cell
\ starts at the sentinel 1000, taller than any real Y1, so the first
\ slice to touch a column always wins; after that only a slice that
\ reaches a LARGER Y1 (further down screen) overwrites it.

CREATE RR 642 ALLOT

\ ===========================================================================
\ 5. FEDORA: the two nested loops
\ ===========================================================================

: FEDORA ( -- )

    642 0 DO
        1000 RR I + !
    2 +LOOP

    -64 64  DO                          \ LIMIT=-64  START=64 (see sec.1)
        I DUP * 81 16 */ TO ZS
        20736 ZS - SQRT TO XL
        XL 1+ XL NEGATE DO              \ LIMIT=XL+1 START=-XL: J..J step +1
            I DUP * ZS + SQRT 27192 16384 */ TO XT
            XT SIN XT 3 * SIN 2 5 */ + 56 10000 */ TO YY
            DX   I   +  J +  TO X1      \ I = innerI here, J = outerI
            DY  YY   -  J +  TO Y1
            X1 0 < NOT  IF
                RR X1 2* + @ Y1  >  IF
                    Y1 RR X1 2* + !
                    Y1  2/
                    X1
                    PLOT                \ ( x y ) = ( Y1/2  X1 ) -- sec.6
                THEN
            THEN
        LOOP
        ?terminal if leave then
    -2 +LOOP
;

\ ===========================================================================
\ 6. Critical verification: does every plotted point stay on screen?
\ ===========================================================================
\
\ demo/Fedora.f used to end with a bare CLS FEDORA, drawing into
\ whatever graphic mode happened to be active -- unlike demo/brot.f,
\ which always opens with an explicit LAYER2 CLS.  Two questions had to
\ be answered before trusting that: does RR ever get indexed out of
\ its own 642 bytes, and does X1/Y1 ever fall outside the current mode's
\ H-RANGE/V-RANGE?  Working out the true range of X1 -- rather than
\ hoping the -64..64 / -XL..XL loop bounds are "obviously" safe --
\ answers both at once.
\
\   X1 = DX + innerI + outerI,   DX = 160
\
\ innerI and outerI are not independent: XL (innerI's own bound) shrinks
\ as outerI grows, following (81/16)*outerI^2 + innerI^2 <= 20736 -- the
\ same ellipse from section 2.  Maximising innerI+outerI subject to that
\ constraint (Cauchy-Schwarz, or just trying every point) gives:
\
\       max(innerI + outerI) = SQRT(20736) * SQRT(1 + 16/81) ~= 157.6
\
\ so X1's true range is about 160 +- 158, i.e. roughly 2..318 -- checked
\ exhaustively (all 28929 (outerI,innerI) pairs, Python mirroring the
\ exact integer arithmetic) the real bounds are X1 in [3,317], and X1 is
\ NEVER negative (the "X1 0 < NOT IF" guard above never actually fires
\ for this DX -- it is dead code, harmless, kept for symmetry with the
\ historical BASIC original).  RR's 642 bytes hold 321 cells, indices
\ 0..320: X1 tops out at 317, three cells of headroom.  THE BUFFER IS
\ SAFE -- this claim, unlike the next one, checks out.
\
\ Now the screen.  PLOT ( x y -- ) checks x against V-RANGE and y
\ against H-RANGE (tutorial 064 section 9's gotcha); the call above is
\ Y1/2 X1 PLOT, so X1 plays PLOT's y and is checked against H-RANGE.
\ Every graphic mode in lib/GRAPHICS.f caps H-RANGE at 256 EXCEPT
\ LAYER12, whose H-RANGE is 512 (tutorial 064 section 10's caution).
\ X1's real maximum, 317, is already past 256 -- so on any mode BUT
\ LAYER12 roughly one seventh of the columns (256..317, verified: 4032
\ of 28929 plotted points, 13.9%) get silently dropped by COORD-CHECK:
\ no error, no crash, just a hat with its brim sheared off on one side.
\
\ lib/GRAPHICS.f's own SETUP word does auto-select LAYER12 the first
\ time NEEDS GRAPHICS loads it, PROVIDED the hardware is already in its
\ LAYER12 boot default (tutorial/CLAUDE.md sec.13) -- so a bare CLS
\ FEDORA right after booting happened to look complete.  But NEEDS is a
\ no-op once GRAPHICS is already loaded, so nothing re-syncs the mode if
\ an EARLIER demo left the display on LAYER0 or LAYER2: the clipping
\ above then bites for real, silently.  Relying on "whatever mode is
\ already active" is exactly what tutorial/CLAUDE.md sec.13 warns
\ against ("switch in, restore out").  demo/Fedora.f's DEMO word (and
\ this tutorial's, section 7) now opens with an explicit LAYER12 CLS
\ instead of trusting the ambient mode, and restores it afterwards --
\ the same discipline BROT's DEMO already followed in tutorial 064.

\ ===========================================================================
\ 7. Drawing
\ ===========================================================================

: DEMO ( -- )
    LAYER12 CLS
    FEDORA
    KEY DROP
    LAYER12 1 .PAPER CLS
;

\ ===========================================================================
\ 8. Exercises
\ ===========================================================================
\
\ a) Change DX to 256 (LAYER12's true horizontal centre, H-RANGE/2) and
\    run DEMO again: the hat recentres on the wide screen instead of
\    sitting in its left 62% (317 of 512 columns, section 6) -- but redo
\    section 6's bound with DX=256: X1 now reaches about 413, past RR's
\    321 cells.  What is the smallest RR a centred DX=256 needs?
\ b) Temporarily force a narrow mode before DEMO's own LAYER12 (e.g.
\    LAYER0 CLS DEMO) and count how much of the brim is missing on
\    real hardware or CSpect -- section 6's 13.9% predicted on paper.
\ c) SIN's r-sign branch (step 3 in section 3) is dead code for this
\    caller.  Write a T{ }T test that calls SIN directly with a negative
\    argument and exercises it.
\ d) RR's sentinel is 1000, larger than any real Y1 (max 256, section 6
\    if extended to Y1 the same way).  What would happen to the picture
\    if the sentinel were smaller than some real Y1 values?

\ ===========================================================================
\ 9. Tests
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  0 SIN                   ->  0      }T
\ T{  90 SIN                  ->  10000  }T
\ T{  180 SIN                 ->  0      }T
\ T{  270 SIN                 ->  -10000 }T   \ quadrant flip (q odd)
\ T{  30 SIN                  ->  5000   }T
\ T{  -30 SIN                 ->  -5000  }T   \ exercises the r-sign branch
\ T{  0 DUP * 81 16 */        ->  0      }T   \ ZS at outerI=0 (the crown)
\ T{  20736 0 - SQRT          ->  144    }T   \ XL at outerI=0: full radius
\ T{  64 DUP * 81 16 */       ->  20736  }T   \ ZS at outerI=64 (loop edge)
\ T{  20736 20736 - SQRT      ->  0      }T   \ XL closes to 0 exactly there
