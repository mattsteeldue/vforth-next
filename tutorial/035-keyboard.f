\
\ 035-keyboard.f
\ Keyboard input: KEY, WAIT-KEY, ?ESCAPE and a simple menu demo.
\
\ KEY is a core Forth word that waits for a keypress and returns its
\ ASCII code.  WAIT-KEY (NEEDS WAIT-KEY) polls the hardware port
\ directly, first waiting for any key to be released, then for one
\ to be pressed.  ?ESCAPE (NEEDS ?ESCAPE) checks whether the user
\ is holding CAPS SHIFT + 1 (the [EDIT] combination) without
\ blocking.  These three words cover most keyboard interaction needs.
\
\ Note: ASK (NEEDS ASK) is a high-level word that sends text to a
\ connected Raspberry Pi Zero and is not a general keyboard reader.
\
\ Reference: sec.7.3
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   035 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 035 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 035: Keyboard input loaded. ) CR
.(     Type NEWTASK to unload.          ) CR

NEEDS WAIT-KEY
NEEDS ^escape
NEEDS CASE

\ ===========================================================================
\ 1. KEY -- wait for a keypress
\ ===========================================================================
\
\   KEY ( -- c )   core word, no NEEDS required
\
\ KEY suspends execution until the user presses a key, then returns
\ its ASCII code.  Most keys map to standard 7-bit ASCII:
\   Letters   A-Z  -> $41-$5A (uppercase)
\   Digits    0-9  -> $30-$39
\   ENTER          -> $0D
\   BACKSPACE      -> $0C  (DELETE on ZX Spectrum)
\   SPACE          -> $20
\
\ Example:
\   KEY .    \ wait for key and print its code
\   KEY EMIT \ wait for key and display it

\ ===========================================================================
\ 2. WAIT-KEY -- hardware-level keypress detection
\ ===========================================================================
\
\   WAIT-KEY ( -- )   NEEDS WAIT-KEY
\
\ WAIT-KEY polls port $FE directly.  It does not use the Spectrum
\ ROM or the Forth input stream.  The sequence is:
\   1. Wait until all keys are released  (port $FE bits 0-4 all 1)
\   2. Wait until any key is pressed     (some bit goes 0)
\
\ WAIT-KEY does NOT modify the Stack
\
\ WAIT-KEY is useful when you want guaranteed no-bounce detection
\ without going through the ROM keyboard scanner.

\ ===========================================================================
\ 3. ?ESCAPE -- non-blocking BREAK check
\ ===========================================================================
\
\   ?ESCAPE ( -- f )   NEEDS ?ESCAPE
\
\ ?ESCAPE checks whether both CAPS SHIFT (port $FE, high nibble $FE)
\ and [1] (port $FE, high nibble $F7) are pressed simultaneously.
\ Returns a non-zero flag if the [EDIT] combination is detected.
\
\ Use this to provide a clean exit from long-running loops:
\
\   BEGIN
\       \ ... do work ...
\       ?ESCAPE
\   UNTIL
\
\ ?TERMINAL is the core equivalent that detects BREAK instead and is
\ used internally by drawing primitives.

\ ===========================================================================
\ 4. Key codes reference
\ ===========================================================================
\
\ Selected ASCII codes on the ZX Spectrum keyboard:
\
\   $08  CAPS SHIFT + 5  (cursor left / delete)
\   $09  CAPS SHIFT + 8  (cursor right / tab)
\   $0A  CAPS SHIFT + 6  (cursor down)
\   $0B  CAPS SHIFT + 7  (cursor up)
\   $0C  DELETE / backspace
\   $0D  ENTER
\   $1B  ESCAPE  (if available)
\   $20  SPACE
\   $41..$5A  A..Z
\   $61..$7A  a..z  (CAPS LOCK active)
\   $30..$39  0..9

\ ===========================================================================
\ 5. Demo: echo keys until BREAK
\ ===========================================================================

: ECHO-KEYS  ( -- )
    CLS
    ." Press keys (BREAK to quit):" CR
    BEGIN
        KEY
        DUP EMIT
        SPACE
        DUP .
        CR
        ?ESCAPE
    UNTIL
    CR ." Done." CR
;

\ ===========================================================================
\ 6. Demo: simple text menu
\ ===========================================================================

: SHOW-MENU  ( -- )
    CLS
    ." === Main Menu ===" CR
    ." 1  Option one"    CR
    ." 2  Option two"    CR
    ." 3  Option three"  CR
    ." Q  Quit"          CR
    ." Press a key: "
;

: DO-MENU  ( -- )
    BEGIN
        SHOW-MENU
        KEY
        CASE
            [CHAR] 1 OF  CR ." You chose option one."   ENDOF
            [CHAR] 2 OF  CR ." You chose option two."   ENDOF
            [CHAR] 3 OF  CR ." You chose option three." ENDOF
            [CHAR] Q OF  CR ." Goodbye!"                ENDOF
            [CHAR] q OF  CR ." Goodbye!"                ENDOF
            CR ." Unknown key."
        ENDCASE
        CR
        [CHAR] Q = SWAP [CHAR] q = OR
    UNTIL
;

\ ===========================================================================
\ 7. Demo: wait for a specific key
\ ===========================================================================

\ Wait until the user presses ENTER (ASCII $0D).
: WAIT-ENTER  ( -- )
    ." Press ENTER to continue..." CR
    BEGIN
        KEY $0D =
    UNTIL
;

\ ===========================================================================
\ 8. Demo: yes/no prompt
\ ===========================================================================

: YES-OR-NO  ( -- f )
    \ Returns true if Y or y, false if N or n.
    ." (Y/N)? "
    BEGIN
        KEY
        DUP [CHAR] Y =  OVER [CHAR] y =  OR
        OVER [CHAR] N =  OVER [CHAR] n =  OR  OR
    UNTIL
    [CHAR] Y =  SWAP [CHAR] y =  OR
;

\ ===========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ KEY and WAIT-KEY require user interaction and cannot be tested
\ automatically.  ?ESCAPE can only be tested on real hardware.
\
\ NEEDS TESTING
\ T{  [CHAR] Y  ->  89  }T   \ ASCII Y
\ T{  [CHAR] Q  ->  81  }T   \ ASCII Q
