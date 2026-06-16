\
\ 044-mouse.f
\ Mouse input via the Kempston mouse interface and sprite cursor.
\
\ lib/MOUSE.f provides a complete mouse driver that uses the ZX Next
\ interrupt system to poll the mouse ports every video frame.  Sprite
\ slot 0 is used as a hardware mouse cursor (16x16 pixel arrow).
\ The Forth ISR (interrupt service routine) must be enabled; MOUSE
\ sets this up automatically.  Key user-facing words: MOUSE-XY,
\ ?MOUSE, MOUSE, and MOUSE!  to show or hide the cursor.
\
\ Reference: sec.7.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   044 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 044 TUTORIAL
\

\ Auxiliary forget-anchor (NOT named NEWTASK).  It is placed before
\ NEEDS MOUSE so it survives the FORGET-MOUSE marker that NO-MOUSE
\ runs, and can therefore clean up the tutorial afterwards.
MARKER FORGET-TUT

CR
.( --- Tutorial 044: Mouse input loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

NEEDS MOUSE
NEEDS TO

\ Unload word.  Unlike the other tutorials, NEWTASK here is a colon
\ word, not the marker itself.  It first calls NO-MOUSE -- which hides
\ the cursor (0 MOUSE!), disables the custom Forth ISR (ISR-OFF, so the
\ per-frame mouse interrupt no longer fires) and forgets the MOUSE
\ module -- then runs the auxiliary marker FORGET-TUT to forget the
\ rest of this tutorial (and the anchor itself), leaving a clean state.
: NEWTASK  ( -- )
    NO-MOUSE
    FORGET-TUT ;

\ ===========================================================================
\ 1. Initialisation
\ ===========================================================================
\
\ NEEDS MOUSE (loads lib/MOUSE.f) performs the following automatically:
\   1. Allocates a 257-byte interrupt vector table
\   2. Sets the Forth ISR (MOUSE-DELTA) as the interrupt handler
\   3. Uploads the arrow sprite pattern to sprite slot 0
\   4. Enables sprites via Next register $15
\   5. Sets initial mouse position to (40, 40)
\   6. Calls ISR-ON to enable interrupts
\
\ To cleanly unload the mouse driver:
\   NO-MOUSE        \ runs the MARKER cleanup, disables ISR
\
\ To hide the cursor without removing the driver:
\   0 MOUSE!        \ hide
\   -1 MOUSE!       \ show (trueflag = any non-zero)

\ ===========================================================================
\ 2. Mouse position: MOUSE-XY
\ ===========================================================================
\
\   MOUSE-XY ( -- x y )
\
\   x : vertical   distance from top-left corner  (row, 0-255)
\   y : horizontal distance from top-left corner  (col, 0-319)
\
\ MOUSE-XY reads the two variables mouse-x and mouse-y which are
\ updated by the ISR at every frame.  The range reflects the ZX Next
\ display resolution.
\
\ Example:
\   MOUSE-XY . .    \ print current mouse position

\ ===========================================================================
\ 3. Mouse buttons: ?MOUSE and MOUSE
\ ===========================================================================
\
\   ?MOUSE ( -- f )   true if any button event is pending
\
\   MOUSE  ( -- s )   return and clear button event status s
\
\ Button event bits (returned by MOUSE):
\   $0001  right button click-down
\   $0002  left  button click-down
\   $0004  wheel button click-down
\   $0010  wheel rotation up
\   $0100  right button click-up
\   $0200  left  button click-up
\   $0400  wheel button click-up
\   $1000  wheel rotation down
\
\ Example: wait for a left-button click
\   BEGIN  ?MOUSE UNTIL
\   MOUSE
\   $0002 AND IF ." Left button pressed!" CR THEN

\ ===========================================================================
\ 4. MOUSE! -- show or hide the cursor sprite
\ ===========================================================================
\
\   MOUSE! ( f -- )   f=0 hides cursor, f<>0 shows cursor
\
\ The cursor is shown by setting bit 6 ($C0) in the sprite attribute
\ byte 3.  Hiding sets byte 3 to $00 (disabled).

\ ===========================================================================
\ 5. MOUSE-SENS -- sensitivity adjustment
\ ===========================================================================
\
\ mouse-sens is a VARIABLE holding the movement threshold.
\ Default value: 1.  When the raw delta is smaller than this value,
\ the delta is halved (MOUSE-NORM), slowing down small movements.
\
\ To make the mouse faster: 1 mouse-sens !
\ To slow it down: 3 mouse-sens !

\ ===========================================================================
\ 6. Demo: display mouse position continuously
\ ===========================================================================

NEEDS .AT
NEEDS ms

: MOUSE-TRACKER  ( -- )
    CLS
    0 0 .AT  ." Mouse tracker (BREAK to quit)" CR
    -1 MOUSE!         \ show mouse cursor
    BEGIN
        MOUSE-XY
        2 0 .AT
        ." X=" SWAP . ."  Y=" . ."   "
        10 ms
        ?TERMINAL
    UNTIL
    0 MOUSE!          \ hide cursor
    CLS
;

\ ===========================================================================
\ 7. Demo: click counter
\ ===========================================================================

: CLICK-COUNTER  ( -- )
    CLS
    0 0 .AT  ." Click counter (BREAK to quit)" CR
    -1 MOUSE!
    0                 \ click count
    BEGIN
        ?MOUSE IF
            MOUSE
            $0002 AND IF   \ left button down
                1+
                2 0 .AT  ." Clicks: " DUP .  ."   "
            THEN
        THEN
        10 ms
        ?TERMINAL
    UNTIL
    DROP
    0 MOUSE!
    CLS
;

\ ===========================================================================
\ 8. Demo: draw with mouse in Layer 2
\ ===========================================================================

NEEDS GRAPHICS

: MOUSE-DRAW  ( -- )
    LAYER2
    CLS
    0 0 .AT  ." Hold left button to draw. BREAK to quit." CR
    -1 MOUSE!
    255 TO ATTRIB        \ white
    BEGIN
        MOUSE-XY
        MOUSE $0002 AND IF   \ left button held (any click-down)
            OVER OVER PLOT
        ELSE
            2DROP
        THEN
        ?TERMINAL
    UNTIL
    0 MOUSE!
    LAYER0
    CLS
;

\ ===========================================================================
\ 9. Unloading: NEWTASK and NO-MOUSE
\ ===========================================================================
\
\ NO-MOUSE (defined in lib/MOUSE.f) performs the mouse-side cleanup:
\   - 0 MOUSE!   hides the cursor sprite
\   - ISR-OFF    disables the custom Forth ISR (the per-frame mouse
\                interrupt stops firing; interrupts return to mode 1,
\                the standard ROM keyboard interrupt)
\   - FORGET-MOUSE  forgets all mouse definitions (and everything
\                loaded after them, i.e. this tutorial's demos)
\
\ NEWTASK (defined near the top of this file) wraps that: it calls
\ NO-MOUSE first, so the mouse is powered down and the custom
\ interrupts are inhibited, then runs the auxiliary marker FORGET-TUT
\ to forget the remaining tutorial words and the anchor itself.  So a
\ single NEWTASK both shuts the mouse off and unloads the tutorial,
\ leaving the dictionary as it was before 044 was loaded.  Reload with
\ 044 TUTORIAL.

\ ===========================================================================
\ 10. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ Mouse tests require hardware interaction.
\ NEEDS TESTING
\ T{  0 0 =  ->  -1  }T   \ placeholder test
