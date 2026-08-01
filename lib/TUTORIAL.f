\
\ tutorial.f
\ TUTORIAL  --  launch a tutorial by its sequence number.
\
\ Usage:
\   NEEDS TUTORIAL
\   3 TUTORIAL     ( loads ./tutorial/003-output.f )
\   or
\   3 FILENAME     ( PAD contains such a filename )
\
\ Path strings are allocated in the HEAP via H" (counted z-strings).
\ H" returns a heap-pointer (ha): 3 MSBs encode the 8K page number,
\ lower bits encode the offset from $E000.  FAR decodes ha into a real
\ address and maps the correct page onto MMU7 ($E000-$FFFF).
\
\ TUT-TABLE holds one heap-pointer per tutorial, entry 0 = tutorial 000
\ (000-HELP.f).  The input number maps directly to the file prefix nnn:
\ 30 TUTORIAL loads tutorial/030-ula-display.f.
\ TUTORIAL fetches ha, calls FAR to resolve it, then skips the count
\ byte to obtain a z-string, and passes it to F_OPEN / F_INCLUDE.
\
\ To add a new tutorial: insert a new H" entry at the correct slot
\ and update TUT-MAX if the new entry exceeds the current maximum.
\
\ Reference: sec.2.12.14 (F_OPEN, F_INCLUDE)
\            See also: "Heap memory facility" in vForth PDF documentation
\

.( TUTORIAL )

NEEDS VIEW-FILE-PAD
NEEDS ?ESCAPE
NEEDS HELP

CR
CR .( Use:  n TUTORIAL ) 
CR .(   Import tutorial 'n'.)
CR .(  or:  n VIEW )
CR .(   List source, [EDIT] pause listing.)
CR .(  or:  TUTORIALS )
CR .(   List all tutorial file names, [EDIT] pause, [BREAK] stop.)
CR

\ ---------------------------------------------------------------------------
\ Create stub definition so that you can give FORGET TUTORIAL
\ ---------------------------------------------------------------------------

: TUTORIAL
    NOOP ;

\ ---------------------------------------------------------------------------
\ Path table -- one H" per tutorial, heap-pointer stored in table.
\ H" allocates the counted-z-string in the HEAP and returns ha (not addr).
\ ---------------------------------------------------------------------------

CREATE TUT-TABLE
    H" tutorial/000-HELP.f"            ,
    H" tutorial/001-stack-basics.f"    ,
    H" tutorial/002-stack-ops.f"       ,
    H" tutorial/003-output.f"          ,
    H" tutorial/004-numeric-bases.f"   ,
    H" tutorial/005-defining-words.f"  ,
    H" tutorial/006-control-flow.f"    ,
    H" tutorial/007-loops.f"           ,
    H" tutorial/008-memory.f"          ,
    H" tutorial/009-strings.f"         ,
    H" tutorial/010-create-does.f"     ,
    H" tutorial/011-bit-ops.f"         ,
    H" tutorial/012-return-stack.f"    ,
    H" tutorial/013-case.f"            ,
    H" tutorial/014-pictured-output.f" ,
    H" tutorial/015-double-arith.f"    ,
    H" tutorial/016-input.f"           ,
    H" tutorial/017-defer-is.f"        ,
    H" tutorial/018-vocabularies.f"    ,
    H" tutorial/019-compilation.f"     ,
    H" tutorial/020-standard.f"        ,
    H" tutorial/021-evaluate.f"        ,
    H" tutorial/022-introspection.f"      ,
    H" tutorial/023-structures.f"      ,
    H" tutorial/024-floating-point.f"  ,
    H" tutorial/025-memory-advanced.f" ,
    H" tutorial/026-catch-throw.f"     ,
    H" tutorial/027-assembler.f"       ,
    H" tutorial/028-blocks.f"          ,
    H" tutorial/029-edit.f"            ,
    H" tutorial/030-ula-display.f"     ,
    H" tutorial/031-screen-control.f"  ,
    H" tutorial/032-timing.f"          ,
    H" tutorial/033-beeper.f"          ,
    H" tutorial/034-ay-sound.f"        ,
    H" tutorial/035-keyboard.f"        ,
    H" tutorial/036-graphics-ula.f"    ,
    H" tutorial/037-layer2.f"          ,
    H" tutorial/038-graphics-advanced.f" ,
    H" tutorial/039-sprites.f"         ,
    H" tutorial/040-next-registers.f"  ,
    H" tutorial/041-mmu.f"             ,
    H" tutorial/042-file-io.f"         ,
    H" tutorial/043-filesystem.f"      ,
    H" tutorial/044-mouse.f"           ,
    H" tutorial/045-copper.f"          ,
    H" tutorial/046-bmp-load.f"        ,
    H" tutorial/047-uart.f"            ,
    H" tutorial/048-rpi0.f"            ,
    H" tutorial/049-interrupts.f"      ,
    H" tutorial/050-afxframe.f"        ,
    H" tutorial/051-keyboard-matrix.f" ,
    H" tutorial/052-modular-graphics.f" ,
    H" tutorial/053-more-sprites.f"    ,
    H" tutorial/054-blocks-as-assets.f" ,
    H" tutorial/055-afx-sound-board.f" ,
    H" tutorial/056-layer2-palette.f"  ,
    H" tutorial/057-dot-commands.f"    ,
    H" tutorial/058-layer3-tilemap.f"  ,
    H" tutorial/059-standalone-executables.f" ,
    H" tutorial/060-idiomatic-traps.f" ,
\   H" tutorial/061-dma.f"             ,

60 CONSTANT TUT-MAX


\ ---------------------------------------------------------------------------
\ FILENAME  ( n -- a )
\ copy nth filename to PAD for better persistency
\ ---------------------------------------------------------------------------

: FILENAME ( n -- a )
    CELLS  TUT-TABLE  +  @      \ ha: heap-pointer to counted-z-string
    FAR                         \ a:  real address ($E000+), MMU7 now mapped
    DUP C@ 2+                   \ compute total length including 0x00
    PAD C/L BLANK               \ blanks PAD
    PAD 1- SWAP                 \ PAD is destination 
    CMOVE                       \ move from heap to PAD
    PAD                         \ return z-string address without length
;

: VIEW ( n -- )
    FILENAME    
    VIEW-FILE-PAD ;

    
\ ---------------------------------------------------------------------------
\ TUTORIAL  ( n -- )
\ ---------------------------------------------------------------------------

: LOAD-TUTORIAL  ( n -- )
    DUP  0  <  OVER  TUT-MAX  >  OR  IF
        DROP  ." TUTORIAL: number out of range [0-"
        TUT-MAX  .  ." ]" CR
        EXIT
    THEN
\
    FILENAME 
\
    HERE  1  F_OPEN
    IF  DROP
        ." TUTORIAL: cannot open file" CR  EXIT
    THEN
    F_INCLUDE ;

\ ---------------------------------------------------------------------------
\ TUTORIALS  ( -- )
\ list every tutorial file name straight from TUT-TABLE: each cell holds a
\ heap-pointer (ha) to a counted-string, so FAR COUNT TYPE is all it takes.
\ [EDIT] pauses the listing, [BREAK] stops it -- same technique as DIR-LIST
\ in lib/DIR.f
\ ---------------------------------------------------------------------------

: TUTORIALS ( -- )
    TUT-TABLE  TUT-MAX 1+ CELLS +   \ limit  = TUT-TABLE + (TUT-MAX+1) cells
    TUT-TABLE                       \ index  = TUT-TABLE (entry 0 = tut. 000)
    DO
        BEGIN ?ESCAPE NOT UNTIL
        ?TERMINAL IF LEAVE THEN
        I @  FAR  COUNT  TYPE  CR
    2 +LOOP
;

' LOAD-TUTORIAL 
' TUTORIAL >BODY !
