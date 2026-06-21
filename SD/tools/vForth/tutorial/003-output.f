\
\ 003-output.f
\ Text output: characters, strings, numbers, and numeric bases.
\
\ vForth routes all output through a current device selected by SELECT
\ (sec.2.12.4).  The default is the upper screen (channel 2).  This tutorial
\ covers the words you will use in everyday code; device switching and
\ the printer stream are left to later tutorials.
\
\ A key distinction: EMIT passes the character through (?EMIT), which
\ interprets control codes ($07 bell, $08 backspace, $09 tab, $0D/$0A CR).
\ EMITC bypasses that filter and sends the raw byte -- use it only when
\ you know the peripheral can handle it directly.
\
\ Starting FORTH (Brodie): Ch.1  |  vForth screens 800-804
\ Reference: sec.2.12.4, 2.9
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   003 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 003 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 003: output loaded. ) CR
.(     Type NEWTASK to unload.   ) CR


\ ===========================================================================
\ 1. Single characters
\ ===========================================================================
\
\ EMIT  ( c -- )   send one character; control codes are interpreted.
\ EMITC ( b -- )   send one raw byte; no control-code processing.
\ SPACE ( -- )     emit one space   (equivalent to BL EMIT)
\ CR    ( -- )     emit a newline   (equivalent to $0D EMIT)
\
\   65 EMIT          => A
\   $41 EMIT         => A
\   7 EMIT           => (bell)
\   SPACE            => (one space)
\   CR               => (newline)


\ ===========================================================================
\ 2. String literals
\ ===========================================================================
\
\ ." cccc"   ( -- )   compile-time: compiles the string for later output.
\                     interpret-time: immediately prints cccc.
\ .( cccc)   ( -- )   identical behaviour to ." but delimited by ) instead
\                     of ".  Useful when the string itself contains a quote,
\                     or inside comments where a closing " would be confusing.
\
\ Both are IMMEDIATE words that compile the string into the definition body
\ when used inside a colon-definition, and print immediately at the prompt.
\
\ Inside a definition:
\   : GREET  ." Hello, vForth!" CR ;
\   GREET              => Hello, vForth!
\
\ At the prompt (interpret mode):
\   ." Hello" CR       => Hello
\   .( Hello) CR       => Hello
\
\ Note: the space after ." or .( is part of the syntax, not the string.


\ ===========================================================================
\ 3. Printing numbers
\ ===========================================================================
\
\ .   ( n -- )    print signed integer followed by a space
\ U.  ( u -- )    print unsigned integer followed by a space
\ .R  ( n w -- )  print n right-aligned in a field w characters wide
\
\   42 .             => 42
\   -1 .             => -1
\   65535 U.         => 65535        (would print -1 with signed .)
\   42 6 .R          =>     42       (right-aligned in 6 chars)
\
\ ? ( a -- ) is shorthand for @ .  --  prints the contents of an address.


\ ===========================================================================
\ 4. Numeric bases (see sec.2.9)
\ ===========================================================================
\
\ BASE is a user variable; HEX, DECIMAL, and (via NEEDS) BINARY and OCTAL
\ change it globally.  Prefix characters override BASE for a single number
\ without changing it permanently:
\
\   $ hex prefix:   $FF .        => 255   (BASE unchanged)
\   # decimal:      #255 .       => 255
\   % binary:       %11111111 .  => 255
\
\ Output also follows BASE:
\   HEX   255 .     => FF
\   DECIMAL
\
\ Best practice: restore DECIMAL explicitly after a HEX block, or use
\ the prefix characters to avoid touching BASE at all.


\ ===========================================================================
\ 5. Whitespace and screen control
\ ===========================================================================
\
\ SPACES ( n -- )   emit n spaces
\ CLS    ( -- )     clear the screen
\
\   5 SPACES         => (five spaces)
\   CLS              => (clear screen)


\ ===========================================================================
\ 6. TYPE and counted strings
\ ===========================================================================
\
\ TYPE ( a n -- )   print n characters starting at address a.
\ COUNT ( a1 -- a2 b )  given a counted-string address, return the text
\                        address a2 and its length byte b.
\
\ A counted string stores the length in the first byte followed by the
\ text bytes.  CREATE with ," builds one in the dictionary:
\
\   CREATE MSG  ," Hello, world!"
\   MSG COUNT TYPE CR      => Hello, world!
\
\ TYPE is the primitive behind ." and .(  --  those compile a counted string
\ and then call TYPE at run-time.


\ ===========================================================================
\ 7. Demonstration words
\ ===========================================================================

: .LABELED  ( n -- )
    \ Print a number with a label: "value = N"
    ." value = " . CR ;

: .HEX-AND-DEC  ( n -- )
    \ Print the same number in hex and decimal.
    ." hex=" HEX DUP . DECIMAL
    ." dec=" . CR ;

: .RULER  ( n -- )
    \ Print a simple ruler of n dashes.
    0 ?DO  [CHAR] - EMIT  LOOP CR ;   \ [CHAR] compiles the ASCII of -
CR
.( Try: 42 .LABELED          ) CR
.( Try: 255 .HEX-AND-DEC     ) CR
.( Try: 20 .RULER            ) CR


\ ===========================================================================
\ 8. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ These test numeric output indirectly via BASE behaviour.
\
\ NEEDS TESTING
\ T{  $FF          -> 255  }T
\ T{  #255         -> 255  }T
\ T{  %11111111    -> 255  }T
