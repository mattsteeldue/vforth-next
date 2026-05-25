\
\ tutorial.f
\ TUTORIAL  --  launch a tutorial by its sequence number.
\
\ Usage:
\   NEEDS TUTORIAL
\   3 TUTORIAL     ( loads ./tutorial/003-output.f )
\
\ A lookup table of counted-z-strings maps sequence numbers to filenames.
\ The word checks bounds, retrieves the path, opens the file, and calls
\ F_INCLUDE.  No directory scanning required.
\
\ To add a new tutorial: append a new CREATE entry and increment TUT-MAX.
\
\ Reference: sec.2.12.14 (F_OPEN, F_INCLUDE)
\

.( TUTORIAL )

CR
.( Use: n TUTORIAL )
CR
.(   Import tutorial source 'n'.)
CR

\ ---------------------------------------------------------------------------
\ Filename table -- one CREATE per tutorial.
\ Each word, when executed, pushes the address of a counted-z-string
\ (length byte + text + null) suitable for F_OPEN via addr 1+ .
\ ---------------------------------------------------------------------------

CREATE tut-001  ," tutorial/001-stack-basics.f"
CREATE tut-002  ," tutorial/002-stack-ops.f"
CREATE tut-003  ," tutorial/003-output.f"
CREATE tut-004  ," tutorial/004-numeric-bases.f"
CREATE tut-005  ," tutorial/005-defining-words.f"
CREATE tut-006  ," tutorial/006-control-flow.f"
CREATE tut-007  ," tutorial/007-loops.f"
CREATE tut-008  ," tutorial/008-memory.f"
CREATE tut-009  ," tutorial/009-strings.f"
CREATE tut-010  ," tutorial/010-create-does.f"

\ ---------------------------------------------------------------------------
\ Index table -- cell array of PFAs, one per tutorial (1-based indexing).
\ Entry 0 is unused (placeholder) so that  n TUT-TABLE  works directly.
\ ---------------------------------------------------------------------------

CREATE tut-table
    0 ,             \ entry 0: unused
    tut-001 ,
    tut-002 ,
    tut-003 ,
    tut-004 ,
    tut-005 ,
    tut-006 ,
    tut-007 ,
    tut-008 ,
    tut-009 ,
    tut-010 ,

10 CONSTANT TUT-MAX


\ ---------------------------------------------------------------------------
\ TUTORIAL  ( n -- )
\ ---------------------------------------------------------------------------

: TUTORIAL  ( n -- )
    DUP  1  <  OVER  TUT-MAX  >  OR  IF
        DROP  ." TUTORIAL: number out of range (1-"
        TUT-MAX  .  ." )" CR  EXIT
    THEN
    CELLS  tut-table  +  @   \ fetch PFA of the tut-NNN word
    1+                        \ skip count byte: now a z-string
    PAD  1  F_OPEN
    IF  DROP
        ." TUTORIAL: cannot open file" CR  EXIT
    THEN
    F_INCLUDE ;
