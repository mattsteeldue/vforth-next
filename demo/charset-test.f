\
\ charset-test.f
\
\ Isolated check of the NextZXOS window control codes 30/31, before
\ building the Stage 3 (font in RAM) work of the chomp-chomp revision --
\ see prompts/CHOMP-CHOMP-PLAN.md Part 5, risk noted in 5.4.
\
\ Code 30,n sets the current character width (n pixels) and is already
\ used elsewhere in the repo.  Code 31,n installs a replacement font of
\ size n, taken from the address the system variable CHARS points to,
\ and is NOT exercised anywhere else in this repo -- this is the one to
\ verify before relying on it.
\
\ INCLUDE this file, then:
\   TEST-A          patches the letter A to a solid block and prints it
\   RESTORE-ROM-FONT brings the ROM font back
\
\ MARKER FORGET-CHARSET-TEST removes everything this file defines.

MARKER FORGET-CHARSET-TEST

decimal
23606 constant CHARS-VAR        \ $5C36 -- pointer to the active font
$3C00 constant ROM-CHARS

variable saved-chars
create my-font   768 allot      \ codes 32-127, 8 bytes each

\ remember the ROM font pointer and copy the ROM bitmaps into my-font
: save-rom-font ( -- )
    CHARS-VAR @ saved-chars !
    CHARS-VAR @ 256 + my-font 768 cmove ;

\ point CHARS at my-font and activate it as the 8-pixel character set
: install-my-font ( -- )
    my-font 256 - CHARS-VAR !
    31 emitc 8 emitc ;

\ put the ROM pointer back and reactivate it
: restore-rom-font ( -- )
    saved-chars @ CHARS-VAR !
    31 emitc 8 emitc ;

\ overwrite the letter A's bitmap (offset (65-32)*8 = 264) with a solid
\ block, an unmistakable difference from the ROM glyph
: patch-A-block ( -- )
    my-font 264 +
    8 0 do
        255 over i + c!
    loop drop ;

\ run the whole check: prints A before and after the patch
: test-a ( -- )
    cr ." before: " [char] A emit cr
    save-rom-font
    patch-A-block
    install-my-font
    cr ." after patch, should look like a solid block: "
    [char] A emit cr
    ." if it does, codes 30/31 work as documented." cr
    ." type RESTORE-ROM-FONT to undo." cr ;
