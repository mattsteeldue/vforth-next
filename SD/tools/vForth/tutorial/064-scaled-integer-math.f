\
\ 064-scaled-integer-math.f
\ Scaled (fixed-point) integer arithmetic, and a Mandelbrot set to prove it.
\
\ The Z80 has no floating-point unit.  vForth does offer a software
\ floating-point pack (tutorial 024), but it is an interpreter running on
\ top of the integer ALU: every operation costs hundreds of T-states.  The
\ classic answer, as old as Forth itself, is not to give up on fractions
\ but to move the decimal point into your own head: a plain 16-bit cell
\ holds the value multiplied by a fixed scale factor, and the arithmetic
\ stays integer arithmetic -- as fast as +, -, and */ can go.
\
\ This tutorial builds the whole toolbox -- representation, the four
\ operations, the signed/unsigned split, the overflow budget -- and then
\ spends it on the canonical stress test: a Mandelbrot set drawn on
\ Layer 2, where every pixel is up to 15 complex multiplications done
\ with nothing but 16-bit integers.
\
\ vForth-specific notes:
\   - */ is the key word: it multiplies into a 32-bit intermediate and
\     then divides back down (see src/F18e.f, */ = */MOD NIP = M* M/MOD).
\     * followed by / is NOT the same thing and silently wraps.
\   - UM* / UM/MOD are the unsigned mixed-precision pair; M* / M/MOD (and
\     therefore */) are the signed ones.  Mixing them up is silent too.
\   - VALUE in vForth is [COMPILE] CONSTANT (inc/value.f), so TO happens
\     to work on a CONSTANT as well.  Do not rely on that: write VALUE
\     when you mean "this will change".
\
\ Starting FORTH (Brodie): Ch.5  |  vForth screens 821-825
\   Brodie's chapter 5 introduces */ and "keeping the decimal point in
\   your head" for percentages and unit conversions.  This tutorial takes
\   the same idea to its conclusion: a full Q8.8 number format.
\ Reference: sec.2.12.11 (mixed-precision and scaling operators),
\            sec.2.12.12 (pictured numeric output), sec.3.x (Layer 2)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   064 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 064 TUTORIAL
\
\ Run it with:  DEMO   (any key returns to the text screen)
\ What it should look like:  tutorial/064-scaled-integer-math.png
\

MARKER NEWTASK

CR
.( --- Tutorial 064: scaled integer arithmetic loaded. ) CR
.(     Type DEMO to draw, NEWTASK to unload.          ) CR

NEEDS VALUE
NEEDS TO
NEEDS S>D
NEEDS J
NEEDS GRAPHICS

\ ===========================================================================
\ 1. The representation: Q8.8
\ ===========================================================================
\
\ Pick a scale factor S and agree, once and for all, that the integer n
\ stored in a cell means the real number n/S.  With S = 256 the cell
\ splits neatly in two halves -- 8 bits of integer part, 8 bits of
\ fraction -- which is why this layout is called Q8.8:
\
\        15                    8 7                     0
\       +-----------------------+-----------------------+
\       |     integer part      |     fraction part     |
\       +-----------------------+-----------------------+
\
\ Range:      -128.00 .. +127.99      Resolution: 1/256 = 0.0039
\
\ S = 256 is not an arbitrary choice.  It is a power of two, so scaling
\ up and down is a shift -- in fact a byte swap, FLIP -- and rounding
\ error never comes from the scale factor itself.

256 CONSTANT Scale                  \ 1.0 is represented by 256

\ CENTI converts "hundredths" -- the readable form used for the window
\ parameters further down -- into scaled units: 220 CENTI is 2.20.

: CENTI  ( n -- n' )        \ n/100 as a scaled value
    Scale 100 */ ;

\   1 CENTI    .   => 2         ( 0.01 is 2/256, rounded down )
\   100 CENTI  .   => 256       ( 1.00 )
\   220 CENTI  .   => 563       ( 2.20 )

\ ===========================================================================
\ 2. Reading a scaled value back
\ ===========================================================================
\
\ A scaled cell printed with . is meaningless to a human: 384 is really
\ 1.5.  Convert back to hundredths and use pictured numeric output
\ (tutorial 014) to put the point back where it belongs.

: .SCALED  ( n -- )         \ print a scaled value as -d.dd
    100 Scale */                    \ hundredths
    DUP ABS S>D                     \ n ud
    <#  #  #  [CHAR] . HOLD  #S  ROT SIGN  #>
    TYPE SPACE ;

\   384 .SCALED    => 1.50
\   -384 .SCALED   => -1.50
\   563 .SCALED    => 2.19      ( 2.20 is not exactly representable )
\
\ That last line is the whole bargain of fixed point, in one example:
\ 2.20 * 256 = 563.2, and the .2 is gone forever.  Every scaled value
\ carries an error of up to 1/256; the errors accumulate as you compute,
\ and it is your job -- not the machine's -- to know whether what is left
\ still answers the question you asked.

\ ===========================================================================
\ 3. The four operations
\ ===========================================================================
\
\ Addition and subtraction are free: the scale factor is linear, so
\ (a/S) + (b/S) = (a+b)/S.  Just use + and - on the scaled cells.
\
\ Multiplication is not, because the scale factor multiplies too:
\ (a/S) * (b/S) = a*b/S^2.  The product carries scale S^2 and must be
\ divided by S once to come home.  Division is the mirror image: the two
\ scales cancel, so the dividend must be scaled up first.
\
\        real            scaled
\        ------------    ---------------------------
\        a + b           a + b
\        a - b           a - b
\        a * b           a * b / S       -> S*
\        a / b           a * S / b       -> S/
\        a * a           a * a / S       -> SQ  (see section 5)

: S*  ( a b -- c )          \ scaled multiply
    Scale */ ;

: S/  ( a b -- c )          \ scaled divide
    Scale SWAP */ ;

\   384 384 S*  .SCALED   => 2.25       ( 1.5 * 1.5 )
\   576 384 S/  .SCALED   => 1.50       ( 2.25 / 1.5 )

\ ===========================================================================
\ 4. Why */ is not * followed by /
\ ===========================================================================
\
\ Both lines below compute a*b/256.  Only one of them is right:
\
\   1000 1000 256 */   .   => 3906
\   1000 1000 * 256 /  .   => 66
\
\ * multiplies two cells into ONE cell: 1000*1000 = 1,000,000 does not
\ fit in 16 bits, so it silently wraps to 16960, and the division then
\ divides the wrong number.  No error, no warning, just a wrong answer.
\
\ */ never forms that single-cell product.  It is defined as
\
\       : */MOD  ( n1 n2 n3 -- rem quot )  >R M* R> M/MOD ;
\       : */     ( n1 n2 n3 -- quot )      */MOD NIP ;
\
\ M* produces a 32-bit double, M/MOD divides it back down to a single.
\ The intermediate is allowed to be huge; only the final quotient has to
\ fit in a cell.  This is the single most important word in scaled
\ arithmetic -- and the reason a Forth with only * and / would be nearly
\ useless for it.
\
\ TRAP -- the order of the three arguments.  */ computes n1*n2/n3, so the
\ divisor is on top.  To convert 3.00 into scaled units you must write
\
\       300 Scale 100 */     => 768      ( 3.00 * 256 / 100 )   RIGHT
\       300 100 Scale */     => 117      ( 3.00 * 100 / 256 )   WRONG
\
\ The wrong form does not crash: it yields a plausible number, roughly a
\ sixth of the right one.  In demo/brot.f this exact slip squeezed the
\ whole view inside the Mandelbrot cardioid, and the program drew an
\ almost entirely black screen.

\ ===========================================================================
\ 5. Signed, unsigned, and the ABS trick
\ ===========================================================================
\
\ vForth has two mixed-precision families:
\
\   UM*    ( u1 u2 -- ud )      unsigned 16x16 -> 32
\   UM/MOD ( ud u1 -- rem q )   unsigned 32/16 -> 16
\   M*     ( n1 n2 -- d )       signed   16x16 -> 32
\   M/MOD  ( d n1 -- rem q )    signed   32/16 -> 16   (used by */)
\
\ Use */ whenever an operand may be negative -- it is the signed path.
\ Reach for the unsigned pair only when you KNOW both operands are
\ non-negative, and a square is exactly such a case: the sign of x is
\ irrelevant to x*x, so ABS first and the unsigned words apply.

: SQ  ( a -- a2 )           \ scaled square, sign-independent
    ABS DUP UM* Scale UM/MOD NIP ;

\   384 SQ  .SCALED   => 2.25
\   -384 SQ .SCALED   => 2.25
\
\ THE OVERFLOW BUDGET.  UM/MOD divides a 32-bit dividend by a 16-bit
\ divisor and returns a 16-bit quotient -- so the quotient MUST fit.
\ Here the quotient is a*a/256, which stays below 65536 only while
\ |a| < 4096, that is while the value being squared is under 16.0.
\ Past that the result is garbage, silently.  Section 6 shows how the
\ Mandelbrot escape test keeps every operand inside that budget without
\ a single explicit range check.

\ ===========================================================================
\ 6. The Mandelbrot set with nothing but integers
\ ===========================================================================
\
\ For each point c of the complex plane, iterate
\
\       z <- z^2 + c        starting from z = 0
\
\ and ask whether |z| stays bounded.  If |z| ever exceeds 2 the point has
\ escaped and will run away to infinity; the number of iterations it
\ survived is what we paint.  Writing z = x + yi and c = cx + cyi:
\
\       x' = x^2 - y^2 + cx
\       y' = 2xy        + cy
\       escaped when   x^2 + y^2 > 4
\
\ There is no square root anywhere: comparing squares is equivalent and
\ far cheaper.  In scaled units the three lines become
\
\       x' = SQ(x) - SQ(y) + cx           SQ already divides by S
\       y' = 2 * S*(x,y)   + cy
\       escaped when  SQ(x) + SQ(y) > 4*S
\
\ 4*S rather than 4, because SQ(x) is itself a scaled value.

VARIABLE ReZ                        \ x, scaled
VARIABLE ImZ                        \ y, scaled
VARIABLE ReC                        \ cx, scaled
VARIABLE ImC                        \ cy, scaled
VARIABLE IDX                        \ iterations survived

15 VALUE MAX-ITER                   \ never more than COLOR-TAB entries
4 Scale * VALUE Mag-Lim             \ escape threshold, scaled

: ITERATE  ( -- n )         \ iterate z from 0 for the current c
    0 ReZ !  0 ImZ !
    MAX-ITER 0 DO
        I IDX !                     \ remember how far we got
        ReZ @ SQ  ImZ @ SQ          ( xx yy )
        2DUP + Mag-Lim > IF  2DROP LEAVE  THEN
        -                           ( x2-y2 )
        ReZ @ ImZ @ S* 2*           ( n1 n2 )       \ 2xy
        ImC @ + ImZ !               ( n1 )
        ReC @ + ReZ !
    LOOP
    IDX @ ;

\ WHY NOTHING OVERFLOWS.  The escape test runs BEFORE the update, so
\ whenever the loop body continues we know x^2 + y^2 <= 4, hence
\ |x| <= 512 and |y| <= 512 in scaled units.  The largest x' the update
\ can then produce is 4*S + |cx| < 1600, comfortably inside the |a|<4096
\ budget SQ demands on the next pass.  A larger escape threshold, or a
\ window far from the origin, would break that chain -- this is the kind
\ of reasoning fixed-point code must carry in its comments, because the
\ machine will not do it for you.

\ ===========================================================================
\ 7. Mapping pixels to the complex plane
\ ===========================================================================
\
\ The window is described in hundredths -- readable, and converted with
\ CENTI at definition time.  H-SPAN is the width of the view; H-ORG is
\ how far LEFT of the origin the view starts, so the left edge sits at
\ -H-ORG.  The defaults frame the classic view: x in -2.20 .. 0.80,
\ y in -1.12 .. 1.13.

300 CENTI VALUE H-SPAN              \ 3.00 wide
220 CENTI VALUE H-ORG               \ left edge at -2.20
225 CENTI VALUE V-SPAN              \ 2.25 tall (256:192 aspect of 3.00)
112 CENTI VALUE V-ORG               \ top edge at -1.12

\ >C converts a pixel column/row into c.  H-RANGE and V-RANGE are the
\ current mode's pixel dimensions, supplied by lib/GRAPHICS.f.
\ i * H-SPAN can reach 255*768 = 195840, far past one cell -- so this is
\ */ territory, not * / territory.

: >C  ( i j -- )            \ pixel column i, row j -> ReC, ImC
    V-SPAN V-RANGE */  V-ORG -  ImC !
    H-SPAN H-RANGE */  H-ORG -  ReC ! ;

\ ===========================================================================
\ 8. Colour: one shade per iteration count
\ ===========================================================================
\
\ Layer 2 is one byte per pixel, RRRGGGBB (tutorial 037).  The table
\ holds MAX-ITER entries, one per possible value of IDX.  Entry 0 is
\ black -- a point that escaped at once -- and so is the LAST entry,
\ reached only by points that never escaped: the set itself, drawn in
\ black, the way Mandelbrot published it.
\
\ Note the % prefix on every literal: it makes each byte readable as
\ three colour fields without switching BASE while the file is loading
\ (tutorial/CLAUDE.md rule 6).

CREATE COLOR-TAB
\    rrrgggbb
    %00000000 C,            \  0  black  -- escaped at once
    %00000001 C,            \  1  darkest blue
    %00000010 C,            \  2
    %00000110 C,            \  3
    %00001010 C,            \  4
    %00101010 C,            \  5
    %01001110 C,            \  6
    %01010010 C,            \  7
    %01110010 C,            \  8
    %01110110 C,            \  9
    %10010110 C,            \ 10
    %10011010 C,            \ 11
    %10111010 C,            \ 12
    %11111111 C,            \ 13  white -- escaped just in time
    %00000000 C,            \ 14  black -- inside the set

\ +COLOR spreads the 14 shades over whatever MAX-ITER happens to be, so
\ the table does not have to grow when you ask for more iterations.  With
\ MAX-ITER 15 the scaling is the identity (n*13/13) and each iteration
\ count gets its own shade.

: +COLOR  ( n -- c )        \ iteration count -> Layer 2 colour byte
    DUP MAX-ITER 1- < IF
        13 MAX-ITER 2 - */          \ escaped: shade 0..13
    ELSE
        DROP 14                     \ never escaped: the set itself
    THEN
    COLOR-TAB + C@ ;

\ ===========================================================================
\ 9. Drawing
\ ===========================================================================
\
\ COORDINATE GOTCHA.  In lib/GRAPHICS.f the primitive is PLOT ( x y -- )
\ where x is checked against V-RANGE and y against H-RANGE: x is the
\ VERTICAL coordinate (the row) and y the horizontal one (the column).
\ The outer loop index J is therefore the x argument and the inner I the
\ y argument -- J I PLOT, not I J PLOT.
\
\ [BREAK] abandons the drawing with LEAVE rather than QUIT, so DEMO still
\ reaches its own clean-up and puts the text screen back.

: BROT  ( -- )
    V-RANGE 0 DO                    \ j: row, imaginary axis
        H-RANGE 0 DO                \ i: column, real axis
            I J >C
            ITERATE +COLOR TO ATTRIB
            J I PLOT                \ ( row column ) -- see gotcha above
        LOOP
        ?TERMINAL IF LEAVE THEN
    LOOP ;

: DEMO  ( -- )
    LAYER2 CLS
    BROT
    KEY DROP
    LAYER12 1 .PAPER CLS ;

\ ===========================================================================
\ 10. Zooming, and where Q8.8 gives up
\ ===========================================================================
\
\ WINDOW takes a centre and a width in hundredths and recomputes all four
\ parameters, keeping the aspect ratio of the current mode.  The default
\ view is exactly  -70 0 300 WINDOW .
\
\ CAUTION: it reads H-RANGE and V-RANGE, which lib/GRAPHICS.f rewrites
\ every time the graphic mode changes (LAYER12 sets H-RANGE to 512, not
\ 256).  Call WINDOW after selecting LAYER2, never before.

: H-WINDOW  ( cx span -- )
    DUP CENTI TO H-SPAN             ( cx span )
    2/ SWAP -  CENTI TO H-ORG ;     \ left edge = cx - span/2

: V-WINDOW  ( cy span -- )
    DUP CENTI TO V-SPAN             ( cy span )
    2/ SWAP -  CENTI TO V-ORG ;     \ top edge = cy - span/2

: WINDOW  ( cx cy span -- )         \ centre and width, in hundredths
    DUP V-RANGE H-RANGE */          ( cx cy span vspan )
    ROT                             ( cx span vspan cy )
    SWAP                            ( cx span cy vspan )
    V-WINDOW                        ( cx span )
    H-WINDOW ;

: ZOOM-DEMO  ( -- )                 \ north bulb, at 2.5x the default
    LAYER2 CLS
    -50 60 120 WINDOW               \ centre -0.50 + 0.60i, 1.20 wide
    BROT
    KEY DROP
    -70 0 300 WINDOW                \ restore the default view
    LAYER12 1 .PAPER CLS ;

\ TWO LIMITS DECIDE HOW FAR YOU CAN ZOOM -- and the first one is not the
\ one people expect.
\
\ ITERATIONS.  MAX-ITER 15 declares "a point that survived 15 rounds is
\ inside".  That is a decent approximation seen from far away, but every
\ step towards the boundary needs more rounds, because the interesting
\ detail lives exactly where points take dozens of iterations to escape.
\ Raising MAX-ITER buys that detail at a proportional cost in time; the
\ colours follow by themselves (see +COLOR).
\
\ RESOLUTION.  Q8.8 resolves 1/256 = 0.0039 of the plane.  At 1.20 across
\ one pixel spans 0.0047, just coarser than that -- which is why
\ ZOOM-DEMO still comes out smooth.  At 0.60 across a pixel is 0.0023:
\ finer than the numbers can distinguish, so neighbouring pixels compute
\ the identical orbit and the picture breaks into flat 2x2 blocks.
\
\ THE TWO LIMITS TOGETHER, worked out on a famous target: the seahorse
\ valley, the fissure at -0.75 where the cardioid and the period-2 disc
\ touch.  Frame it with -75 10 60 WINDOW and MAX-ITER 15 and 95% of the
\ pixels come back "inside" -- a black screen, correctly computed and
\ useless.  MAX-ITER 40 only brings that down to 90%, because at 0.60
\ across the view is genuinely almost all set: the seahorses live in the
\ fissure between the two components, a few thousandths wide.  Seeing
\ them means shrinking the span to about 0.15 -- where one pixel is
\ 0.0006, six times finer than Q8.8 can distinguish, so whole 6x6 blocks
\ of pixels would share one orbit.  In this number format the seahorse
\ valley is simply out of reach: it is not a matter of waiting longer.
\ Q16.16 on double cells (tutorial 015) reaches it, and pays for it in
\ speed -- the same trade, one scale factor further on.

\ ===========================================================================
\ 11. Exercises
\ ===========================================================================
\
\ a) Raise MAX-ITER to 30 and run ZOOM-DEMO again: the boundary of the
\    north bulb gains a whole generation of detail.  COLOR-TAB needs no
\    change -- +COLOR redistributes its 14 shades.  How much longer does
\    the frame take?  Then try -75 10 15 WINDOW and watch the picture
\    break into blocks: that is the Q8.8 wall of section 10, seen.
\ b) Time a full frame with the frame counter of tutorial 032, then
\    replace S* in ITERATE with a hand-written UM* / UM/MOD pair -- both
\    operands there may be negative, so mind the signs -- and time again.
\ c) Dividing by 256 is a byte swap: try rewriting SQ with FLIP and a
\    mask instead of UM/MOD, and measure the frame time again.
\ d) A Julia set is the same loop with c held constant and z started from
\    the pixel.  Two lines of ITERATE change.

\ ===========================================================================
\ 12. Tests
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  100 CENTI               ->  256    }T
\ T{  220 CENTI               ->  563    }T
\ T{  384 384 S*              ->  576    }T   \ 1.5 * 1.5 = 2.25
\ T{  576 384 S/              ->  384    }T   \ 2.25 / 1.5 = 1.5
\ T{  384 SQ                  ->  576    }T
\ T{  -384 SQ                 ->  576    }T   \ sign-independent
\ T{  1000 1000 256 */        ->  3906   }T   \ 32-bit intermediate
\ T{  1000 1000 * 256 /       ->  66     }T   \ wraps: this is the trap
\ T{  0 ReC !  0 ImC !  ITERATE   ->  14 }T   \ origin never escapes
\ T{  512 ReC !  0 ImC !  ITERATE ->  2  }T   \ c = 2.0 escapes at once
\ T{  0 +COLOR                ->  0      }T   \ escaped at once: black
\ T{  13 +COLOR               ->  255    }T   \ last shade: white
\ T{  14 +COLOR               ->  0      }T   \ inside the set: black
