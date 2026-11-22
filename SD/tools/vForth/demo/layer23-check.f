\
\ layer23-check.f
\
\ Where does pixel 0,0 land in LAYER23 (Layer 2 640x256, 16 colours)?
\ On CSpect (2026-06-28), and then on the real Next, everything came
\ out shifted to the right; this picture tells a correct screen from a
\ shifted one (planners/LAYER23-PLAN.md).
\
\ At the prompt, one line each:
\   INCLUDE DEMO/LAYER23-CHECK.F
\   CHECK
\ Any key returns to the text screen.
\
\ What a correct screen shows (x = row 0..255, y = column 0..639):
\   - a frame along the four edges of the whole 640x256 area;
\   - a filled 16x32 block in the top-left corner (pixel 0,0);
\   - a diagonal from the top-left corner going down-right;
\   - ticks along the top edge every 64 columns, longer every 128,
\     longest at 320 (the centre);
\   - a circle in the middle, centre 128,320.
\ Confirmed on the real Next 2026-11-18 (demo/layer23-check.png).
\ Before the fix to L23-PIXELADD (an `or a` before its `daa`) only
\ columns 0..255 showed, drawn from column 384 on, and the circle was
\ cut at the edge of that strip.
\

NEEDS LAYER23-GRAPHICS
NEEDS LAYER12

\ LAYER23-GRAPHICS switches to 640x256 at once: back to text before
\ anything else is printed (as in demo/layer22-demo.f).
LAYER12  _BLUE .PAPER

MARKER TASK

DECIMAL

: FRAME ( -- )
    0 639 0 0 DRAW-LINE              \ top
    255 639 255 0 DRAW-LINE          \ bottom
    255 0 0 0 DRAW-LINE              \ left
    255 639 0 639 DRAW-LINE          \ right
;

: CORNER ( -- )                      \ 16 rows x 32 columns at 0,0
    16 0 DO
        I 31 I 0 DRAW-LINE
    LOOP
;

: TICK ( y -- )                      \ a tick down from the top edge
    DUP 320 = IF 48 ELSE
        DUP 128 MOD IF 8 ELSE 24 THEN
    THEN                             \ y len
    SWAP 0 OVER DRAW-LINE ;          \ len y 0 y DRAW-LINE

: TICKS ( -- )
    640 0 DO I TICK 64 +LOOP
;

: CHECK ( -- )
    LAYER23                          \ 640x256, cleared to BACKGROUND
    15 .INK
    FRAME  CORNER  TICKS
    255 255 0 0 DRAW-LINE            \ diagonal from 0,0
    128 320 100 CIRCLE
    KEY DROP
    LAYER12  _BLUE .PAPER  CLS
;
