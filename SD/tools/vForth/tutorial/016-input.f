\
\ 016-input.f
\ Keyboard input: KEY, ACCEPT, CURS
\
\ vForth reads from the keyboard through the current input device.
\ The core provides two words:
\
\   KEY    -- wait for any key and return its ASCII code
\   CURS   -- display a cursor and wait for a keypress
\   ACCEPT -- read a complete line into a buffer with basic editing
\
\ WAIT-KEY (NEEDS) is like KEY but first ensures for no key is pressed
\
\ For interactive programs, KEY is the lowest-level entry point;
\ ACCEPT is the right choice when reading a word or number from
\ the user.  The input stream words (TIB, >IN, BLK) manage how
\ the interpreter reads from its own input; this tutorial covers
\ only the interactive keyboard words.
\
\ Common ASCII codes: 13=CR, 27=ESC, 32=SPACE, 8=backspace.
\ Printable characters: 32-127 ($20-$7F).
\ ZX Spectrum specific: DELETE=12, EDIT=7, depends on ROM.
\
\ Reference: sec.2.12.10
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   016 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 016 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 016: keyboard input loaded. ) CR
.(     Type NEWTASK to unload.            ) CR


\ ===========================================================================
\ 1. KEY  --  wait for a keypress
\ ===========================================================================
\
\ KEY ( -- c )   suspend execution until a key is pressed; return ASCII.
\
\ KEY does not echo the character.  The result is the ASCII code of the
\ key pressed; use EMIT to echo it manually if needed.
\
\   KEY .         => (prints ASCII code of pressed key)
\   KEY EMIT CR   => (echoes the character, then newline)
\
\ Common check patterns:
\   KEY  7 = IF  ." edit"    THEN  CR   \ test for [EDIT]
\   KEY 13 = IF  ." enter"   THEN  CR   \ test for CR/ENTER


\ ===========================================================================
\ 2. CURS  --  display cursor, used before KEY
\ ===========================================================================
\
\ CURS ( -- )   displays a blinking cursor while waiting for a keypress by
\ polling the system-variable FLAGS ($5C3B). Usually associated with KEY.
\
\   CURS KEY .    => ASCII value


\ ===========================================================================
\ 3. ACCEPT  --  read a line of text
\ ===========================================================================
\
\ ACCEPT ( addr maxlen -- len )
\   Read up to maxlen characters from the keyboard into the buffer at
\   addr.  Returns the actual number of characters read (not including
\   the terminating CR).  Provides basic line editing (backspace).
\
\   CREATE BUF  40 ALLOT
\   BUF 40 ACCEPT .         => (number of chars typed)
\   BUF OVER TYPE CR        => (prints the line just entered)
\
\ Note: the buffer is NOT null-terminated by ACCEPT.  Use TYPE with
\ the returned length to print it, not COUNT.


\ ===========================================================================
\ 4. Getting a number from the user
\ ===========================================================================
\
\ A simple approach: ACCEPT into PAD, then use NUMBER

CREATE INPUT-BUF  32 ALLOT

: ?NUMBER  ( addr len -- d f )
    \ Attempt to parse addr/len as a decimal number.
    \ Returns ( n -1 ) on success or ( 0 0 ) on failure.
    \ Uses the current BASE.
    1- 
    IF                          ( a )
        1-
        DUP C@                  ( a c )
        \ check leading minus
        [CHAR] - = IF           ( a )
            1+                  ( a+1 )
            -1                  ( a+1 -1 ) 
        ELSE                    ( a )
             1                  ( a    1 )
        THEN
        SWAP                    ( +1 a )
        0 0 ROT (NUMBER)        ( +1 d a+n )
        DROP                    ( +1 d )
        ROT D+-                 ( +d )
        -1                      ( +d tf )
    ELSE
        DROP  0 0 0             (  d ff )
    THEN
    ;

: ASK-NUMBER  ( -- d )
    \ Prompt the user for a number; return it as a double.
    .( Enter a number: )
    INPUT-BUF 20 ACCEPT
    INPUT-BUF SWAP
    ?NUMBER IF
        ." Got: " 2DUP D. CR
    ELSE
        ." (not a number)" CR
    THEN ;
CR
.( Try: ASK-NUMBER D. ) CR


\ ===========================================================================
\ 5. Simple yes/no prompt
\ ===========================================================================

: YES?  ( -- f )
    \ Ask the user yes (Y) or no (N). Return true for Y.
    BEGIN
        ." (Y/N)? "
        CURS KEY  DUP EMIT  CR
        DUP  UPPER [CHAR] Y =
        OVER UPPER [CHAR] N = OR
    UNTIL
    UPPER [CHAR] Y = ;
    
: REPLY 
    IF ." yes" ELSE ." no" THEN 
    CR ;    

.( Try: YES? REPLY ) CR


\ ===========================================================================
\ 6. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ (Interactive words cannot be tested automatically; use manually.)
\
\ NEEDS TESTING
\ T{  ( interactive: press a key and check result ) }T
