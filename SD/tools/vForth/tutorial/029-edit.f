\
\ 029-edit.f
\ EDIT: the full-screen block editor.
\
\ Tutorial 028 showed how BLOCK storage works underneath.  EDIT is the
\ interactive tool you use to type source and data INTO that storage: a
\ full-screen editor that shows one Screen (16 lines x 64 columns = 2
\ blocks) and lets you move a cursor over it, overtype characters, and
\ run line-oriented commands through PAD.
\
\ EDIT is interactive and needs the real keyboard and a 64-column display,
\ so this tutorial is mostly a usage guide: it documents the keys and the
\ command menu, and gives you a launcher that opens a safe scratch screen.
\ It does not (and cannot) auto-run an editing session.
\
\ EDIT works only in a display mode with at least 64 columns -- the default
\ LAYER12 text mode is fine.  It edits the CURRENT screen (the SCR
\ variable); LIST sets SCR, hence the idiom  n LIST EDIT.
\
\ Starting FORTH (Brodie): Ch.3 "The Editor"  |  vForth screens 815
\ Reference: sec.3 "The Full Screen Editor Utility" (LED at sec.3.3)
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   029 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 029 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 029: EDIT editor loaded. ) CR
.(     Type NEWTASK to unload.         ) CR

NEEDS EDIT

\ ===========================================================================
\ 1. What EDIT is
\ ===========================================================================
\
\   EDIT ( -- )   open the full-screen editor on the current screen (SCR)
\
\ EDIT loaded via NEEDS EDIT pulls in the EDITOR vocabulary (lib/edit.f).
\ Once running it takes over the display: it shows the screen's 16 lines
\ between two column rulers, plus a status frame at the bottom.  You leave
\ it with the [Edit] command key followed by Q (see section 5).
\
\ Because it edits whatever SCR points at, you almost always precede it
\ with LIST, which both prints the screen and sets SCR:
\
\   10 LIST EDIT      \ list screen 10, then edit it
\   EDIT              \ edit whatever screen SCR currently holds

\ ===========================================================================
\ 2. The screen layout
\ ===========================================================================
\
\ When EDIT runs you see:
\
\   Screen # 10
\   +----.----+----.----+----.----+----.----+----.----+----.----+--   <- ruler
\   <line 0, 64 columns>
\   <line 1>
\    ...
\   <line 15>
\   +----.----+----.----+...                                          <- ruler
\    row:  RR   col:  CC   hex:  XX   dec:  DDD   chr:  c              <- status
\    pad:  <current PAD contents>
\    cmd:
\   U-ndo    B-ack    D-el     I-nsert   H-old
\   Q-uit    N-ext    S-hift   R-eplace  P-ut hex byte
\
\ The status line tracks the cursor: its row/col, and the byte under it in
\ hex, decimal, and as a character.  The "pad:" line mirrors PAD -- the
\ scratch buffer the line commands cut and paste through.

\ ===========================================================================
\ 3. Moving the cursor and typing
\ ===========================================================================
\
\ Cursor keys (CAPS SHIFT + 5/6/7/8 on the Spectrum):
\   left   right   up   down     move the cursor; it wraps and beeps at edges
\   ENTER                        move to start of the next line
\   DELETE (CAPS SHIFT + 0)      backspace: pull the rest of the line left
\
\ Typing a printable character OVERTYPES the byte at the cursor and advances
\ one column.  There is no separate "insert mode" -- but you can open a
\ single-character gap on the fly with:
\
\   [BREAK] (CAPS SHIFT + SPACE)  insert one space at the cursor, pushing the
\                                 rest of the line right; then type over the
\                                 fresh space as usual.
\
\ So the two complementary in-line edits are DELETE (close a gap, shift left)
\ and [BREAK] (open a gap, shift right) -- a per-character counterpart to the
\ [Edit] I / D line commands.
\
\ Every keystroke that changes the buffer calls UPDATE automatically, so the
\ screen is marked dirty as you work.  It is NOT written to disk until you
\ FLUSH (see section 6).

\ ===========================================================================
\ 4. The [Edit] command key
\ ===========================================================================
\
\ Press [Edit] (CAPS SHIFT + 1; "Shift + 1" on a PC keyboard) to open the
\ command menu shown at the bottom.  EDIT then waits for one more key:

\ ===========================================================================
\ 5. Command reference (after pressing [Edit])
\ ===========================================================================
\
\   Cursor / navigation
\     N   Next screen      (SCR + 1, cursor home)
\     B   Back one screen  (SCR - 1, cursor home)
\     Q   Quit the editor  (returns to the ok prompt)
\     U   Undo: discard ALL edits to the current screen (clears its dirty
\         flag so the buffer is re-read from disk on next access)
\
\   Line operations -- they all go through PAD (the "pad:" status line)
\     H   Hold:    copy the current row into PAD (like "yank/copy")
\     D   Delete:  copy the current row to PAD, then remove it (rows below
\                  move up; like "cut")
\     I   Insert:  push a blank in and paste PAD into the current row
\                  (rows below move down)
\     R   Replace: overwrite the current row with PAD (paste in place)
\     S   Shift:   shift rows down from the current row (open a blank line)
\
\   Raw byte entry
\     P   Put hex byte: type two hex digits; the byte is stored at the
\         cursor.  This is how you place codes a key cannot type directly --
\         UDG/graphics characters (128-255) or control codes.
\
\ The H/D/I/R pattern is the editor's copy-and-paste model: HOLD or DELETE
\ a line into PAD, move the cursor, then INSERT or REPLACE it elsewhere.

\ ===========================================================================
\ 6. Saving your work
\ ===========================================================================
\
\ Editing changes live in the RAM buffer and are marked dirty (UPDATE).
\ Quitting with [Edit] Q does NOT flush them.  To persist to the SD card:
\
\   FLUSH            \ write all dirty buffers back to !Blocks-64.bin
\   ( or )  SAVE     \ NEEDS SAVE -- shorthand for  UPDATE FLUSH
\
\ To throw edits away instead:
\   [Edit] U inside the editor   (current screen only), or
\   EMPTY-BUFFERS at the prompt  (all buffers, no write).
\
\ Rule of thumb: edit -> [Edit] Q -> FLUSH when satisfied.

\ ===========================================================================
\ 7. A safe launcher
\ ===========================================================================
\
\ Screen 10 (blocks 20-21) is documented as free scratch space.  This word
\ opens it for editing without touching any screen that holds code.
\ Run it from the prompt:  EDIT-SCRATCH
\
\ (Defined, not executed -- INCLUDEing this file must not seize the keyboard.)

: EDIT-SCRATCH  ( -- )   10 LIST EDIT ;

\ A guarded launcher for an arbitrary screen, refusing the system range
\ (screens 0..7 hold metadata and the error messages -- never edit them):

: EDIT-SCREEN  ( screen# -- )
    DUP 8 < IF
        ." Refusing to edit system screen " . CR
    ELSE
        LIST EDIT
    THEN ;

\ ===========================================================================
\ 8. Pitfalls
\ ===========================================================================
\
\ * Persistence is permanent.  Once you FLUSH, the change is in
\   !Blocks-64.bin for good.  Keep edits on scratch screens until sure.
\
\ * Never edit screens 0..7: screen 0/0.5 is system metadata (and block 1
\   is the F_INCLUDE line buffer), screens 4..7 hold the error messages.
\
\ * The block-storage rules from tutorial 028 still apply to anything you
\   type as source: a definition must not straddle the two blocks of a
\   screen, and a stray NUL (0x00) byte silently halts LOAD.  Use P to
\   inspect/replace a suspicious byte if a screen "loads halfway".
\
\ * EDIT needs >= 64 columns.  In a narrower mode the layout breaks; stay
\   in the default LAYER12 text mode.
\
\ * LED (the large-file editor, sec.3.3) is an evolution of EDIT: it
\   inherits the same keys and command menu, but instead of editing block
\   buffers it works directly on the upper 8K RAM pages (the MMU7 region),
\   which is what lets it handle whole source text-files rather than single
\   screens.  Because LED still touches BUFFERs, mixing LED and EDIT in one
\   session can produce spurious "No such block" errors -- pick one editor
\   per task.

\ ===========================================================================
\ 9. Notes on testing
\ ===========================================================================
\
\ EDIT is interactive: it reads the keyboard and drives the display, so it
\ has no automated {..}T tests.  Verify it by hand:
\
\   10 LIST          \ see screen 10 before
\   EDIT-SCRATCH     \ type a few characters, then [Edit] Q
\   FLUSH            \ persist
\   10 LIST          \ confirm the change
