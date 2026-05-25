TUTORIAL CONVENTIONS
====================
Rules and formalisms agreed during the vForth tutorial development session.
To be saved as a project file so Claude can reference it in future sessions.


1. LANGUAGE
-----------
- Interaction with the author: Italian.
- All source code, comments, and documentation: English only.
- Character encoding: 7-bit ASCII strictly.
  Allowed bytes: 0x20-0x7E, tab (0x09), LF (0x0A), CR (0x0D), 0x7F.
  No UTF-8, no BOM, no smart quotes, no em-dash (use --).
- Line width: maximum 80 columns. Enforced with:
    awk 'length > 80 {print NR": "length" cols: "$0}' filename.f
- ASCII check enforced with Python:
    python3 -c "
    data=open('f','rb').read()
    bad=[(i,b) for i,b in enumerate(data) if b>0x7E and b!=0x7F]
    print('OK' if not bad else bad[:5])
    "


2. FILE NAMING
--------------
- Tutorial files: NNN-slug.f  (three-digit zero-padded sequence number).
  Examples: 001-stack-basics.f, 010-create-does.f
- Stored in: tutorial/
- inc/ files: plain slug.f, lowercase.  Example: tutorial.f


3. FILE STRUCTURE (each tutorial .f)
-------------------------------------
a) Header block (backslash comments):
   - Filename
   - One-paragraph narrative description
   - vForth-specific notes if any
   - Reference to PDF section(s): sec.N.NN
   - Load and unload instructions

b) MARKER immediately after header:
     MARKER NO-SLUG-NAME

c) CR before banner (for clean output when INCLUDEd):
     CR
     .( --- Tutorial NNN: title loaded. ) CR
     .(     Type NO-SLUG-NAME to unload.   ) CR

d) NEEDS lines (if required) immediately after MARKER banner.
   NEEDS is always at interpreter level -- never inside a definition.

e) Numbered sections with separator lines:
     \ =========================================================================
     \ N. Section title
     \ =========================================================================

f) Interactive examples in comments using => notation:
     \   42 .    => 42

g) Demonstration words (short, named with a leading dot or descriptive name).

h) Commented-out test block at end:
     \ NEEDS TESTING
     \ T{  expr  ->  expected  }T


4. COMMENT STYLE
----------------
- Narrative description: several lines in the file header.
- Section intro: free prose comments explaining the concept.
- Inline stack comments on non-obvious lines, using the style:
    word    ( before -- after )
- Step-by-step stack comments on complex definitions, one per line:
    : SAME-STRING?  ( a1 n1 a2 n2 -- f )
        ROT         ( a1 a2 n2 n1 )
        OVER        ( a1 a2 n2 n1 n2 )
        <> IF       ( a1 a2 n2 )
            2DROP   ( a1 )
            DROP    ( )
            FALSE   ( ff )
        ELSE
            (COMPARE) 0=
        THEN ;
- Line comments only on obscure lines, not on self-evident ones.
- Reference to PDF section in file header, not on individual words.


5. STACK NOTATION
-----------------
- Standard: ( before -- after ) with TOS on the right.
- pfa is shown explicitly in DOES> definitions:
    DOES>  ( index pfa -- addr )
- double-cell items: d (signed), ud (unsigned), shown as two cells.
- flag: f (any non-zero = true), ff (false = 0), tf (true = -1 = $FFFF).


6. NUMERIC LITERALS
-------------------
- Preferred: prefix characters in source: $FF  %11111111  #255
- Normal usage: global base switch for output only: 255 HEX . DECIMAL
- Discouraged: global base switch during compilation or file loading.
- NEEDS BINARY / NEEDS OCTAL at interpreter level only, never inside
  a definition.
- Sign after prefix: #-33 correct; -#33 wrong.
- Double literals: any punctuation in a number makes it double (32-bit).


7. VFORTH-SPECIFIC RULES
-------------------------
- ," produces a counted-z-string: length byte + text + null byte ($00).
  The null enables direct use with NextZXOS C-style string API calls.
  This is a deliberate vForth extension for host OS compatibility.
- VARIABLE initialises to 0, takes no initial value on the stack
  (standard since v1.52; old code passing a value before VARIABLE is wrong).
- NEEDS is interpreter-only; never call it inside a colon-definition.
- INCLUDE is interpreter-only; same constraint.
- VALUE requires NEEDS VALUE; TO requires NEEDS TO (separate inc/ files).
- The step-by-step stack comment style (rule 4 above) is preferred for
  definitions with more than two stack-manipulation operations.


8. CREATE...DOES> CONVENTIONS
------------------------------
- DOES> pushes PFA as the deepest new stack item.
- Caller arguments sit above PFA at DOES> entry.
- Array usage: index precedes the array name:
    42  0 SCORES  !    ( not: 42 SCORES 0 ! )
    0 SCORES  @ .
- Stack comment for DOES> shows pfa explicitly and rightmost:
    DOES>  ( index pfa -- addr )
- Never nest CREATE...DOES>.


9. PRIMITIVE vs HIGHER-LEVEL WORDS
-----------------------------------
- Prefer core primitives over words requiring NEEDS when both are
  available and equally readable.
- (COMPARE) ( a1 a2 n -- b ) is the core primitive; use it instead of
  COMPARE ( a1 b1 a2 b2 -- n ) which requires NEEDS.
- Source of truth for core membership: F18e.f (not the PDF alone).
  When in doubt: grep for the word in F18e.f before writing NEEDS.



10. PHILOSOPHY NOTES (to include in narrative where relevant)
--------------------------------------------------------------
- The art of stack manipulation goes hand in hand with the art of
  factoring: a word needing more than two or three shuffle operations
  should be split into smaller definitions, each taking the minimum
  number of parameters it actually needs.
  Readable Forth code is flat and narrow, not deep and twisted.
- NEEDS is a load-time tool, not a run-time tool.
- Changing BASE for output is fine; changing BASE during source loading
  or compilation is error-prone and should be avoided.
