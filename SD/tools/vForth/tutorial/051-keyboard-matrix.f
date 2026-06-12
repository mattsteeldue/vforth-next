\
\ 051-keyboard-matrix.f
\ Direct keyboard-matrix scanning: KEY-DOWN?, KEY-SCAN, GET-KEY and
\ redefinable game keys (KEYBOARD.f).
\
\ Tutorial 035 covered the high-level keyboard path: KEY blocks for a
\ character through the ROM and the Forth input stream, honouring CAPS
\ LOCK and the SYMBOL/extended shift modes.  This tutorial covers the
\ opposite, low-level path: reading the 8x5 key matrix straight off
\ port $FE, the classic ZX Spectrum way.  Raw scanning gives you three
\ things KEY cannot: it never blocks, it sees several keys held at the
\ same time, and it is fast enough to poll once per frame -- exactly
\ what a game needs.  The price is that you get raw matrix positions,
\ not ASCII: no CAPS LOCK, no shift folding, no input channel.
\
\ All words come from inc/KEYBOARD.f, loaded with NEEDS KEYBOARD.  Each
\ of the 40 keys has a fixed index 0..39 (see the map in section 2).
\
\ Reference: sec.3.14
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   051 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 051 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 051: keyboard matrix loaded. ) CR
.(     Type NEWTASK to unload.            ) CR

NEEDS KEYBOARD
NEEDS .AT

\ ===========================================================================
\ 1. Why scan the matrix instead of using KEY
\ ===========================================================================
\
\ KEY ( -- c )       core, BLOCKS until a key, returns one ASCII code.
\ KEY-SCAN ( -- n )  KEYBOARD, RETURNS AT ONCE, gives a matrix index.
\
\ Reach for the matrix words when you need any of:
\   - non-blocking polling (a loop that keeps running with no key down),
\   - several keys at once (e.g. UP and FIRE together in a game),
\   - per-frame speed without the ROM scanner in the way.
\
\ Reach for core KEY (tutorial 035) when you simply want to read a
\ character of text with CAPS LOCK and shifts already applied for you.

\ ===========================================================================
\ 2. The key index map (0..39)
\ ===========================================================================
\
\ Port $FE is read with the HIGH address byte selecting one half-row;
\ the low 5 bits report that row's keys, ACTIVE LOW (0 bit = pressed).
\ KEYBOARD.f numbers the keys row by row:
\
\   port    bit0   bit1  bit2  bit3  bit4    indices
\   $FEFE   CAPS   Z     X     C     V        0.. 4
\   $FDFE   A      S     D     F     G        5.. 9
\   $FBFE   Q      W     E     R     T       10..14
\   $F7FE   1      2     3     4     5       15..19
\   $EFFE   0      9     8     7     6       20..24
\   $DFFE   P      O     I     U     Y       25..29
\   $BFFE   ENTER  L     K     J     H       30..34
\   $7FFE   SPACE  SYMB  M     N     B       35..39
\
\ The two shift keys live at index 0 (CAPS SHIFT) and 36 (SYMBOL SHIFT).
\ A few handy indices used below:  Q=10  A=5  O=26  P=25  SPACE=35.

\ ===========================================================================
\ 3. Testing one key: KEY-DOWN?
\ ===========================================================================
\
\   KEY-DOWN? ( n -- f )   true if key index n is held right now.
\
\ It never waits.  Because it answers about ONE key, several calls can
\ report several keys held together -- impossible with a single KEY.
\
\ Hold SPACE (index 35) while running:
\   35 KEY-DOWN? .    => -1   (held)
\   35 KEY-DOWN? .    =>  0   (not held)
\
\ Under the hood KEY-DOWN? is KEY#>RM (split the index into a port and
\ a column mask) followed by KEY-PRESSED? (read the port, test the bit):
\   12 KEY#>PORT .    => 64510  ( = $FBFE, the Q-W-E-R-T row )
\   12 KEY#>MASK .    => 4      ( = $04, column for E )

\ ===========================================================================
\ 4. Finding any pressed key: KEY-SCAN and labels
\ ===========================================================================
\
\   KEY-SCAN ( -- n )   lowest pressed index, or NO-KEY (255) if none.
\   NO-KEY   ( -- 255 ) the "nothing pressed" sentinel.
\   .KEY     ( n -- )   print a key's label (CAPS/SYMB/ENTER/SPACE or char).
\
\ KEY-SCAN walks indices 0..39 and stops at the FIRST one held, so when
\ two keys are down it reports only the lower index.  For independent
\ keys (a game) test each with KEY-DOWN?; for "which key did the user
\ tap" use KEY-SCAN.

\ Show, live, the key currently held -- quit by pressing BREAK.
\ ?TERMINAL is the core non-blocking BREAK test (tutorial 035).
: WATCH-KEYS  ( -- )
    CLS
    ." Hold any key (BREAK to quit):" CR
    BEGIN
        2 0 .AT                     \ rewrite the status line in place
        KEY-SCAN                    ( n )
        DUP NO-KEY = IF
            DROP ." (none)         "  \ trailing spaces erase the old label
        ELSE
            ." key " DUP . ." = " .KEY ."          "
        THEN
        ?TERMINAL
    UNTIL
    CR CR ." Done." CR ;

\ ===========================================================================
\ 5. A debounced press: GET-KEY
\ ===========================================================================
\
\   GET-KEY     ( -- n )   wait for release, then for a fresh press.
\   WAIT-NOKEY  ( -- )     block until the whole keyboard is released.
\   WAIT-NEWKEY ( -- n )   block until some key goes down, return it.
\
\ GET-KEY is the matrix equivalent of "press any key": it first drains
\ any key still held (WAIT-NOKEY) so an earlier press cannot leak
\ through, then waits for one clean new press (WAIT-NEWKEY).  This is
\ the no-bounce read you want for menus and "press a key to continue".

\ Press any key; echo its index and label.  Press ENTER (index 30) to stop.
: ASK-KEYS  ( -- )
    CLS
    ." Tap keys; ENTER quits." CR
    BEGIN
        GET-KEY                     ( n )
        DUP ." -> " DUP . ." (" .KEY ." )" CR
        #30 =                       ( f )   \ ENTER index
    UNTIL
    ." Bye." CR ;

\ ===========================================================================
\ 6. Redefinable game keys: KEY#>RM, KEY-PRESSED?
\ ===========================================================================
\
\ A game must not re-scan all 40 keys every frame, and it must let the
\ player choose the controls.  The pattern: capture each control once as
\ a (port mask) pair, store it, then test it per frame with a single
\ port read.
\
\   KEY#>RM      ( n -- port mask )   freeze an index into a fast pair.
\   KEY-PRESSED? ( port mask -- f )   true if that pair's key is down.
\
\ Storage for four controls (VARIABLE holds the port, one its mask):
VARIABLE UP-PORT    VARIABLE UP-MASK
VARIABLE DN-PORT    VARIABLE DN-MASK
VARIABLE LF-PORT    VARIABLE LF-MASK
VARIABLE RT-PORT    VARIABLE RT-MASK

\ Helper: ask for one control, store its (port mask) pair.
\ Takes the addresses of the port and mask cells to fill.
: BIND-KEY  ( port-addr mask-addr -- )
    GET-KEY                         ( pa ma n )
    DUP ." set to " .KEY CR         ( pa ma n )
    KEY#>RM                         ( pa ma port mask )
    ROT !                           ( pa port )   \ mask -> mask-addr (ma)
    SWAP ! ;                        ( )           \ port -> port-addr (pa)

\ Let the player choose all four controls (defaults: Q/A/O/P, see map).
: DEFINE-KEYS  ( -- )
    CLS ." Define your controls." CR
    ." UP    key: " UP-PORT UP-MASK BIND-KEY
    ." DOWN  key: " DN-PORT DN-MASK BIND-KEY
    ." LEFT  key: " LF-PORT LF-MASK BIND-KEY
    ." RIGHT key: " RT-PORT RT-MASK BIND-KEY ;

\ Read a stored control: true while its key is held.
: UP?     ( -- f )  UP-PORT @ UP-MASK @ KEY-PRESSED? ;
: DOWN?   ( -- f )  DN-PORT @ DN-MASK @ KEY-PRESSED? ;
: LEFT?   ( -- f )  LF-PORT @ LF-MASK @ KEY-PRESSED? ;
: RIGHT?  ( -- f )  RT-PORT @ RT-MASK @ KEY-PRESSED? ;

\ A tiny "game loop": show which controls are held, BREAK to quit.
\ Note UP? and RIGHT? can both be true at once -- try a diagonal.
: PLAY  ( -- )
    CLS ." Hold your keys (BREAK to quit):" CR
    BEGIN
        2 0 .AT                      \ redraw the 4-char status in place
        UP?     IF ." U" ELSE ." ." THEN
        DOWN?   IF ." D" ELSE ." ." THEN
        LEFT?   IF ." L" ELSE ." ." THEN
        RIGHT?  IF ." R" ELSE ." ." THEN
        ?TERMINAL
    UNTIL
    CR CR ." Game over." CR ;

\ Full demo: define controls, then run the loop.
\   DEMO
: DEMO  ( -- )
    DEFINE-KEYS PLAY ;

\ ===========================================================================
\ 7. Caveats
\ ===========================================================================
\
\ - ACTIVE LOW: a pressed key reads as a 0 bit.  KEY-DOWN? / KEY-PRESSED?
\   already invert this for you (0= turns 0 into a true flag).
\ - RAW matrix, no ASCII: SYMBOL SHIFT (index 36) and CAPS SHIFT (0) are
\   reported as plain keys, never folded into a character.  Use core KEY
\   (tutorial 035) when you want text.
\ - KEY-SCAN reports only the LOWEST held index; for two-key combos test
\   each key with KEY-DOWN? / KEY-PRESSED? instead.
\ - GET-KEY blocks (it waits for release then press); KEY-SCAN and the
\   ?-words do not.  Pick blocking vs polling to match your loop.

\ ===========================================================================
\ 8. Tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ The pure index-arithmetic words are deterministic and can be checked
\ without a keypress; KEY-DOWN?, KEY-SCAN and GET-KEY need real keys.
\
\ NEEDS TESTING
\ T{   0 KEY#>PORT  ->  $FEFE  }T   \ CAPS-shift row
\ T{  12 KEY#>PORT  ->  $FBFE  }T   \ Q-W-E-R-T row
\ T{  12 KEY#>MASK  ->  4      }T   \ E is column 2 -> $04
\ T{  12 KEY#>RM    ->  $FBFE 4 }T  \ port and mask together
\ T{     NO-KEY     ->  255    }T   \ the empty-scan sentinel
