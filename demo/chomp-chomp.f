\ 
\ chomp-chomp.f
\
\ This is a simple pac-man like game. 
\ Arrorw keys or Cursor Joystick should work.
\ 
\ It uses old-fashion UDG's and standard ROM-BEEP
\
\
\ .( Chomp-Chomp GAME ) 
\
\ MARKER FORGET-CHOMP-CHOMP      \ Used to remove the program
\ 
\ FORTH DEFINITIONS 

\ BASE @                  \ save current base, restored at end

\ CASEOFF                 \ ignore case for this source

\ FLUSH EMPTY-BUFFERS     \ ensure no i/o operation due to BLOCKs

\ NEEDS GRAPHICS          \ this provides LAYERs and INK/PAPER/BRIGHT
NEEDS VALUE
NEEDS TO
NEEDS LAYER11
NEEDS LAYER12
NEEDS .INK
NEEDS .PAPER
NEEDS .BRIGHT

NEEDS .AT
NEEDS .BORDER
\ NEEDS .PERM

NEEDS SPEED!            \ Sinclair ZX Spectrum Next - Run up to 28 MHz
NEEDS CHOOSE            \ Brodie's random numbers

NEEDS CASE              \ useful syntax CASE-OF
NEEDS J                  \ outer loop index, used once by find-pills
NEEDS <>                 \ used by MAZE-CHECK (Stage 4)

NEEDS BLEEP


\ wait for next interrupt, to sync video frame
CODE sync-vid HEX
    76 C,              \ halt
    DD C, E9 C,        \ jp (ix)
    smudge
    \

\ add n to byte at address a
: c+! ( n a )
    tuck c@ + swap c! ;

\ add n to double at address a
: d+! ( n a )
  tuck 2@      \ a n d
  rot s>d d+  \ a d+n
  rot 2! ;

decimal

\ utility: print in binary
: b.     ( n -- )
  base @ swap 2 base !
  8 .r  base ! ;

\ double equals
: D= ( d1 d2 -- f )
  rot =      \ l1 l2 h2=h1
  swap rot   \ h1=h2 l2 l1
  = and ;

\ true if n between a and b
: between ( n a b -- f )
  rot tuck < 0= \ a n b>n
  swap rot < 0= \ b>n n>a
  and ;

\ print six chacacters
: six-emitc ( c1 c2 c3 c4 c5 c6 -- )
  emitc emitc emitc
  emitc emitc emitc ;

\ emit 12 characters
\ This used to begin with sync-vid, which made the game speed a side
\ effect of how many sprites were drawn: 5 sprites = 5 frames = ~10Hz.
\ Pacing is now in one place, see pace below.
: sync-emit ( c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 -- )
  emitc emitc emitc emitc
  emitc emitc emitc emitc
  emitc emitc emitc emitc ;

\
decimal 
23560  constant  LASTK    \ system variable : last key pressed
       variable  total 0 ,
       variable  score 0 ,
\ How many plain dots the maze loaded right now holds -- counted by
\ find-pills, which already walks the whole maze.  A phase is complete
\ when score has caught up with total and every dot is worth one, so
\ this is what total gets primed with: the count used to be hard-coded
\ at 180 (the compiled maze's), which silently soft-locks any maze
\ drawn with a different number of dots -- score steps over total
\ instead of landing on it, and the level never ends.
       variable  maze-dots
       variable  high-score 0 ,
       variable  counting
       variable  lives
       variable  hunt

\ Timing.  ticks is the single time base of the game: it drives the ghost
\ speed accumulators, the scatter/chase timer and the colour cycles.
\ tick-frames is how many 50Hz video frames one game tick lasts -- 5
\ reproduces the cadence the game had when every sprite drawn cost a frame.
       variable  ticks
       variable  tick-frames
5 tick-frames !

\ one game tick: advance the clock, then wait tick-frames video frames.
\ sync-vid is a halt, so it waits for the 50Hz interrupt regardless of
\ the CPU clock -- SPEED! does not change the game cadence.
: pace ( -- )
  1 ticks +!
  tick-frames @ 0 ?do sync-vid loop ;

\ pacman eat a pill
: pill-on
  -1 hunt !
  10  total d+!
  0 counting ! ;

\ sound a bip
: bip ( n1 n2 -- n3 n4 )
  beep-pitch
  bleep-calc
  swap ;

\ double literal
: 2lit ( n1 n2 -- )
  [compile] literal
  [compile] literal
; immediate 


\ cursor keys
char  8  value    key-right
char  5  value    key-left
char  7  value    key-up
char  6  value    key-down

\ cursor keys
      9  value    key+right
      8  value    key+left
     11  value    key+up
     10  value    key+down


.( UDG )

decimal

\ determine the UDG character code
: UDG+ ( c1 -- c2 )
   upper 79 + ;

\ compile and UDG literal
: [UDG] ( -- )
   char UDG+ [compile] literal ;
   IMMEDIATE

\ given c return UDG address
: UDG@ ( c -- a )
   upper 65 - 8 * 23675 @ + ;
   \ given c print binary repres.

\ udg utility: display binary representation
: .UDG ( c -- )
    cr UDG@ dup 8 + swap do
        i c@ b.     cr
    loop ; 

\ convert a counted-string at address a in UDG: each character
\ between A and W becomes its UDG correspondant (see UDG+); '.' (the
\ small dot) becomes the V UDG instead -- V is not a real wall/pill
\ letter, it is a 22nd slot appended to UDG_1 on purpose for this, and
\ W a 23rd one (the one-cell island wall the maze alphabet lacked).
: UDGize ( a -- )
    count over + swap do
        i c@ [char] . = if
            [udg] V i c!
        else
            i c@ upper [char] A [char] W
        between if
                i c@ upper UDG+ i c!
            then
        then
    loop ;

\ Like type but for UDG
: Gtype ( a c -- )
    over + swap ?do
    i c@ emitc loop ;

\ Utility: display all UDGs
: UDGs
    [char] Z 1+ [char] A do
    i UDG+ emitc loop ;



\ UDG - User Defined Graphic characters
create UDG_1
hex
\ FF00 , 0000 , 0000 , 0000 , \ A
%00000000  C, 
%11111111  C,
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,

\ 0000 , 0000 , 0000 , 00FF , \ B
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,
%11111111  C,
%00000000  C,

\ FF00 , 0000 , 0000 , 00FF , \ C
%00000000  C,
%11111111  C,
%00000000  C,
%00000000  C,
%00000000  C,
%00000000  C,
%11111111  C,
%00000000  C,

\ F800 , 0204 , 0202 , 0202 , \ D
%00000000  C,
%11111000  C,
%00000100  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,

\ 1F00 , 4020 , 4040 , 4040 , \ E
%00000000  C,
%00011111  C,
%00100000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,

\ 3F00 , 8040 , 4080 , 003F , \ F
%00000000  C,
%00111111  C,
%01000000  C,
%10000000  C,
%10000000  C,
%01000000  C,
%00111111  C,
%00000000  C,

\ FC00 , 0102 , 0201 , 00FC , \ G
%00000000  C,
%11111100  C,
%00000010  C,
%00000001  C,
%00000001  C,
%00000010  C,
%11111100  C,
%00000000  C,

\ 0202 , 0202 , 0402 , 00F8 , \ H
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000100  C,
%11111000  C,
%00000000  C,

\ 4040 , 4040 , 2040 , 001F , \ I
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%00100000  C,
%00011111  C,
%00000000  C,

\ 0202 , 0202 , 0202 , 0202 , \ J
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
%00000010  C,
\ 
\ hex
\ 1800 , 4224 , 4242 , 4242 , \ K
%00000000  C,
%00011000  C,
%00100100  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,

\ 4242 , 4242 , 2442 , 0018 , \ L
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%00100100  C,
%00011000  C,
%00000000  C,

\ 4040 , 4040 , 4040 , 4040 , \ M
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,
%01000000  C,

\ 4242 , 4242 , 4242 , 4242 , \ N
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,
%01000010  C,

\ 0000 , 7C38 , 7C7C , 0038 , \ O
%00000000  C,
%00000000  C,
%00111000  C,
%01111100  C,
%01111100  C,
%01111100  C,
%00111000  C,
%00000000  C,

\ 3E1C , 0F1F , 3E1F , 001C , \ P
%00011100  C,
%00111110  C,
%00011111  C,
%00001111  C,
%00011111  C,
%00111110  C,
%00011100  C,
%00000000  C,

\ 2200 , 7F77 , 3E7F , 001C , \ Q
%00000000  C,
%00100010  C,
%01110111  C,
%01111111  C,
%01111111  C,
%00111110  C,
%00011100  C,
%00000000  C,

\ 1C00 , 7C3E , 7C78 , 1C3E , \ R
%00000000  C,
%00011100  C,
%00111110  C,
%01111100  C,
%01111000  C,
%01111100  C,
%00111110  C,
%00011100  C,

\ 3800 , FE7C , EEFE , 0044 , \ S
%00000000  C,
%00111000  C,
%01111100  C,
%11111110  C,
%11111110  C,
%11101110  C,
%01000100  C,
%00000000  C,

\ 7E38 , DB5A , FFFF , 93FF , \ T
%00111000  C,
%01111110  C,
%01011010  C,
%11011011  C,
%11111111  C,
%11111111  C,
%11111111  C,
%10010011  C,

\ 0602 , 140A , EE24 , 66EE , \ U
%00000010  C,
%00000110  C,
%00001010  C,
%00010100  C,
%00100100  C,
%11101110  C,
%11101110  C,
%01100110  C,

\ V is the 22nd slot, one past the classic A-U/144-164 range, added to
\ give '.' (the small dot) its own UDG instead of the plain ROM
\ period.  Nothing in the ROM/NextZXOS print routine caps the UDG
\ lookup at 21 entries -- it just reads 8 bytes at (code-144)*8 from
\ the table UDG points to, so extending the table and using code 165
\ ('V') is safe.  A small centered dot, 2x2 pixels.
%00000000  C,
%00000000  C,
%00000000  C,
%00011000  C,
%00011000  C,
%00000000  C,
%00000000  C,
%00000000  C,

\ W is the 23rd slot (code 166), added for the second batch of mazes.
\ A wall cell strokes each of its edges that faces open floor, and the
\ fourteen letters A-N are exactly the fourteen ways to do that with at
\ least one edge left open -- the fifteenth, all four edges at once, was
\ missing, so a one-cell island could not be drawn at all.  This is it:
\ K's top arc over L's bottom arc.
%00000000  C,
%00011000  C,
%00100100  C,
%01000010  C,
%01000010  C,
%00100100  C,
%00011000  C,
%00000000  C,

\ X, Y, Z are the 24th-26th slots (codes 167-169), one fruit type per
\ maze level (see FRUIT-GLYPH below) -- same trick as V/W: the UDG
\ table has no real upper bound, only the alphabet A-N/O.../W is
\ meaningful to UDGize (maze data), these three never appear in maze
\ text and are only ever poked into a sprite's FACE field directly.
\ X: orange -- a plain filled disc with a small stem.
%00000000  C,
%00111000  C,
%01111100  C,
%11111110  C,
%11111110  C,
%01111100  C,
%00111000  C,
%00000000  C,

\ Y: banana -- a diagonal curved band.
%00000010  C,
%00000110  C,
%00001110  C,
%00011100  C,
%00111000  C,
%01110000  C,
%11000000  C,
%00000000  C,

\ Z: apple -- filled disc like the orange, but with a wider stem/leaf
\ notch on top so the two are told apart even though both are round.
%00011000  C,
%00100000  C,
%01101110  C,
%11111111  C,
%11111111  C,
%01111110  C,
%00111100  C,
%00000000  C,

UDG_1 5C7B ! \ UDG


.( maze )
decimal
21 constant maze-h
21 constant maze-w
create maze-run
24 21 * allot
create maze-base



( Chomp.f - maze )
\ maze definition
," EAAAAAAAAANAAAAAAAAAD "
," M.........N.........J "
," M.EAD.EAD.N.EAD.EAD.J "
," MOM J.M J.N.M J.M JOJ "
," M.IBH.IBH.L.IBH.IBH.J "
," M...................J "
," M.FCG.K.FCACG.K.FCG.J "
," M.....N...N...N.....J "
," IBBBB.MCG.L.FCJ.BBBBH "
,"     J.N.......N.M     "
," BBBBH.L.E---D.L.IBBBB "
," /.......M   J.......\ "
," AAAAD.K.I---H.K.EAAAA "
,"     J.N.... ..N.M     "
," BBBBH.L.FCACG.L.IBBBB "
," M.........N.........J "
," MOFCD.FCG.L.FCG.ECGOJ "
," M...N...........N...J "
," AAD.L.FCCCCCCCG.L.EAA "
,"   J...............M   "
,"    AAAAAAAAAAAAAAA    "



( Chomp.f - maze )
decimal

\ copy maze definition to run-time maze
: maze-copy ( a1 a2 -- )
    maze-h 0 do
        2dup 24 cmove
        dup udgize
        swap 24 + swap 24 +
    loop
    2drop ;

\ Stage 4: mazes on Screen, editable with EDIT without recompiling.
\ Screens 740-779 are reserved for chomp-chomp levels (40 Screen = 20
\ mazes of 2 Screen/4 BLOCK each); confirmed free/overwritable by the
\ author 2026-08-23 (740-776 were empty, 777-779 held obsolete unrelated
\ experiments).  Maze #0 (level MOD n-mazes = 0) stays the compiled
\ maze-base above -- kept as a permanent fallback so the ZAP standalone
\ .bin does not depend on !Blocks-64.bin.  Disk maze n (n>=1, 1-based)
\ lives on Screen MAZE-SCR0+2*(n-1) and +2*(n-1)+1.  Line 0 of EACH of
\ the two Screens is a title comment (so INDEX shows it instead of raw
\ maze data), not maze data: maze rows 0..14 live at Screen-A lines
\ 1..15 (15 rows) and rows 15..20 at Screen-B lines 1..6, i.e. absolute
\ lines 17..22 (6 rows) -- see maze-line below, which is the only place
\ that shift is encoded (util/chomp-maze.py mirrors it by hand).
\ Columns 0..20 of a maze-row line are the maze-w(21) maze characters
\ (same alphabet as maze-base); columns 21..63 and absolute lines 23..31
\ are free/reserved and never read by the loader below.
\
\ Maze 1 is the compiled maze converted as-is (it is what proved the
\ loader); mazes 2 and 3 are new layouts.  Every maze has to leave the
\ sprite spawn cells alone -- see check-spawn in MAZE-CHECK -- but the
\ number of dots is free: total is primed from maze-dots at run time.
\ util/chomp-maze.py renders a layout as pixels and runs the same
\ structural checks headlessly, which is how these two were drawn.
740 constant MAZE-SCR0
   4 value   n-mazes     \ 0 = compiled maze-base; 1..3 = Screen 740..745
   variable  level        \ 0-based; reset in game, advanced in phase-complete

\ first BLOCK (of 4) holding disk maze n (n>=1, 1-based)
: maze-blk0 ( n -- blk )
    1- 4 * MAZE-SCR0 2* + ;

\ write the 24-byte maze-run row shape from src (maze-w=21 raw chars)
\ to dest, WITHOUT converting to UDG -- shared by the game loader below
\ (which UDGizes right after) and by MAZE-CHECK (which wants the
\ original characters).  A maze-base row is NOT [count=21][21 chars]:
\ ," strips the source's leading alignment space (WORD skips leading
\ blanks) but keeps the trailing one, so the compiled count is 22 (21
\ real chars + 1 trailing space), followed by a stray 0x00 that ,"'s
\ own "0 c," tacks on after every string.  Reproduce that exact shape
\ here so a disk-loaded row is byte-for-byte identical to a compiled
\ one after UDGize (confirmed via maze-base/maze-run DUMP, 2026-08-23).
: raw-row! ( src dest -- )
    >r
    r@ 1+ maze-w cmove
    bl r@ maze-w 1+ + c!
     0 r@ maze-w 2 + + c!
    maze-w 1+ r> c! ;

\ address of the 64 raw bytes of row r (0..20) of disk maze n.  r maps to
\ absolute Screen-pair line r+1 (r<15, Screen A) or r+2 (r>=15, Screen B)
\ to leave line 0 of each Screen free for the title comment above.
: maze-line ( n r -- a )
    swap maze-blk0
    swap
    dup 15 < if 1+ else 2 + then
    8 /mod
    rot +
    block
    swap 64 * + ;

\ load row r (0..20) of disk maze n into maze-run and UDGize it,
\ mirroring what maze-copy does per row for the compiled path
: load-maze-row ( n r -- )
    dup >r
    maze-line
    r> 24 * maze-run +
    2dup raw-row!
    nip udgize ;

: load-maze ( n -- )
    maze-h 0 do
        dup i load-maze-row
    loop drop ;

\ prepare running image of maze: level 0 keeps the original compiled
\ path unchanged; any other level loads the matching disk maze
: set-maze-run
    level @ n-mazes mod
    ?dup 0= if
        maze-base maze-run maze-copy
    else
        load-maze
    then ;


set-maze-run  \ ...and do it now


\ determine address of maze-cell x y
: maze^ ( x y -- a )
    maze-run + swap 1-
    24 * + ;

\ fetch character at maze-cell x y
: maze@ ( x y -- c )
    maze^ c@ ;

\ store character at maze-cell x y
: maze! ( c x y -- )
    maze^ c! ;
\


\ print maze
: maze. ( -- )
    0 0 .at
    22 1 do
        025 23 i - 16 +
        beep-pitch bleep-calc
    loop
    maze-run
    22 1 do
        cr space sync-vid
        dup count gtype 24 +
        >R bleep R>
    loop
    drop
;


.( array )


\ Array is an area 6 x 16 bytes
\ Stride went from 8 to 16 to make room for the AI attributes (accum,
\ speed, rev?).  Four places encode the stride and must agree: this
\ ALLOT, sprite#, name-of and all-ghost.
create Array   6 16 * allot

\ current object pointer
0 variable Sprite^            Sprite^   !

\ current object number
0 value    Sprite-no


\ choose sprite number n setting
\  n to sprite-no
\  a to sprite^
: sprite# ( n -- )
  dup 4 lshift array +
  sprite^ ! to sprite-no ;
\

\ fetch sprite address, i.e. sprite pointer
: sprite@ ( -- a )
  sprite^ @ ;
\

\ set value v on attribute i for all ghosts
: all-ghost  ( v i -- )
    64 Array  +     \ limit is 64 = 4 * 16
    swap Array  +   \ index starts with first attribute
    do
        dup i c!    \ store value
    16 +loop
    drop ;          \ drop value



\ creates an index of Ghost
\ this allows defining a "name" instead of an "attribute-index"
\ used in the form
\   n index-of cccc
: index-of ( n -- )
  <builds c, does> c@ + ;


\ creates a ghost pointer
\ this allows defining a "name" instead of an "row-index"
\   n index-of cccc
: name-of  ( n -- creates )
  <builds c, does> c@ dup
  4 lshift Array + sprite^ !
  to sprite-no ;


.( objects )

\ array index by name
0  name-of  Inky
1  name-of  Pinky
2  name-of  Blinky
3  name-of  Ted
\

0  index-of  face
1  index-of  color
2  index-of  x-pos
3  index-of  y-pos
4  index-of  dir
5  index-of  x-pre
6  index-of  y-pre
7  index-of  maze

\ AI attributes, added when the stride grew from 8 to 16
 8 index-of  accum    \ fractional speed accumulator, 0..255
 9 index-of  speed    \ increment per tick: 192 = 75%, 128 = 50%
10 index-of  rev?     \ pending forced reversal, consumed at next cell



\ shorthand for  x-pos,y-pos & fetch
: xy-pos@  ( -- x y )
    sprite@
    dup    x-pos c@
    swap   y-pos c@ ;

\ shorthand for  x-pre,y-pre & fetch
: xy-pre@  ( -- x y )
    sprite@
    dup    x-pre c@
    swap   y-pre c@ ;

\ shorthand for  x-pre,y-pre & store
: xy-pre! ( x y -- )
    >R sprite@ x-pre c!
    R> sprite@ y-pre c! ;
\


.( scatter/chase )

\ Periodically the ghosts stop chasing and head for their own corner.
\ That rhythm is what makes the arcade game playable rather than
\ merciless: it hands the player regular windows to breathe.  Durations
\ are in game ticks (~10Hz), from the arcade's 7s / 20s / 5s.
\ Defined here, ahead of the AI proper, because init-all and
\ pacman-eat-pill already need reset-phases and force-reverse.
create phase-tab
  70 ,  200 ,
  70 ,  200 ,
  50 ,  200 ,
  50 ,    0 ,           \ 0 = chase for the rest of the level
8 constant phase-max

variable phase-i
variable phase-t
variable scatter?       \ non-zero while in scatter mode

: load-phase ( -- )
  phase-i @ phase-max < if
     phase-i @ dup + phase-tab + @ phase-t !
     phase-i @ 1 and 0=
  else
     0 phase-t !  0
  then
  scatter? ! ;

: reset-phases ( -- )
  0 phase-i !  load-phase ;

\ every ghost must turn round at its next cell
: force-reverse ( -- )
  1  0 rev?  all-ghost ;

\ Advance the phase timer.  It is suspended while the ghosts are
\ frightened and resumes into the same phase afterwards.
: tick-phase ( -- )
  hunt @ 1 = if
     phase-t @ if
        -1 phase-t +!
        phase-t @ 0= if
           1 phase-i +!
           load-phase
           force-reverse
        then
     then
  then ;


.( ghosts )

\ setup standard ghost colors
\ Aligned with the arcade personalities: the colour now tells you which
\ targeting rule a ghost follows.  This also frees blue (1) for the
\ frightened state, which used to be white.
: Ghost-color ( -- )
 Inky   5 sprite@ color c!  \ Cyan    - crossed vector, doubles Blinky's
 Pinky  3 sprite@ color c!  \ Magenta - ambusher, aims 4 cells ahead
 Blinky 2 sprite@ color c!  \ Red     - direct chaser
 Ted    6 sprite@ color c!  \ Yellow  - Clyde's role (nearest to orange)
;


ghost-color \ and doit now

\ Color cycles: anelli di colore con rate (tick per colore) e lista colori
: COLORS: ( rate count -- )
    <builds  c, c,                 \ pfa: [count][rate][c1..cN]
    does>  ( pfa -- c )
        dup 1+ c@                  \ rate
        ticks @ swap /             \ indice grezzo
        over c@ mod                \ modulo count
        + 2+ c@ ;

\ anello di colore per fantasmi spaventati: blu/bianco, 1 tick ciascuno
1 2 COLORS: SCARED-FLASH
  1 c,  7 c,

\ anello di colore per la frutta: rosso/giallo/magenta ogni 4 tick
4 3 COLORS: FRUIT-CYCLE
  2 c,  6 c,  3 c,

\ anello di colore per le pillole di potere: verde (come il resto del
\ labirinto) / bianco, ogni 3 tick -- il BRIGHT globale (game imposta
\ 1 .bright una volta sola) si applica gia' a tutto lo schermo, quindi
\ il bianco esce gia' come bianco brillante senza bisogno di toccare
\ l'attributo BRIGHT qui.
3 2 COLORS: PILL-FLASH
  4 c,  7 c,

\ counting value at which scared ghosts start flashing; frightened mode
\ ends at 60, so the default reproduces the old cascade's last 4 ticks
variable flash-at
56 flash-at !

\ color for frightened ghosts: solid blue most of time, flash at the end
: scared-color ( -- c )
  counting @ flash-at @ < if
    1
  else
    SCARED-FLASH
  then ;

\ colour a sprite draws with: cherry pulses, ghosts turn scared, else
\ each entity's own colour field.  sprite-no 4 < selects ghosts only
\ (0-3): without it a scared Pac-Man (sprite-no 4) would flash too.
: sprite-color ( -- c )
  sprite-no 5 = if
    FRUIT-CYCLE
  else
    sprite-no 4 < hunt @ -1 = and if
      scared-color
    else
      sprite@ color c@
    then
  then ;

\ Initialize all ghosts appearance
: Ghost-init  ( -- )
    12 0  x-pos  all-ghost
    11 0  y-pos  all-ghost
    55 0  dir    all-ghost
    bl 0  maze   all-ghost
    Inky   10 sprite@ y-pos c!
    Inky   xy-pos@ xy-pre!
    Pinky  12 sprite@ y-pos c!
    Pinky  xy-pos@ xy-pre!
    Ted    11 sprite@ x-pos c!
    Ted    xy-pos@ xy-pre!
    Blinky xy-pos@ xy-pre!
    [char] T udg+
    0 face all-ghost
    000 0 accum all-ghost
    192 0 speed all-ghost    \ 75% of Pac-Man
    000 0 rev?  all-ghost
;


\ Setup pacman appearance

.( pac )

4 name-of Pacman

\ setup standard pacman
: pacman-init
    Pacman [char] R UDG+
       sprite@ face  c!
    14 sprite@ x-pos c!
    12 sprite@ y-pos c!
    14 sprite@ x-pre c!
    12 sprite@ y-pre c!
     6 sprite@ color c!
    56 sprite@ dir   c!
    bl sprite@ maze  c!
;

ghost-init
pacman-init



.( cherry )


5 name-of Cherry

\ one fruit per maze level, cycling with n-mazes so it always matches
\ the maze in play: cherry, orange, banana, apple, then round again.
\ Score grows with the level, arcade-style.
create fruit-glyph
  [char] U c,  [char] X c,  [char] Y c,  [char] Z c,
create fruit-score
  10 c,  20 c,  30 c,  40 c,

: fruit-idx ( -- n ) level @ n-mazes mod ;
: fruit-glyph@ ( -- c ) fruit-idx fruit-glyph + c@ UDG+ ;
: fruit-score@ ( -- n ) fruit-idx fruit-score + c@ ;

: cherry-init
  Cherry fruit-glyph@
     sprite@ face  c!
  14 sprite@ x-pos c!
  12 sprite@ y-pos c!
  14 sprite@ x-pre c!
  12 sprite@ y-pre c!
   2 sprite@ color c!
  00 sprite@ dir   c!
  bl sprite@ maze  c!
;

cherry-init 


.( move )

\ draw current sprite, well they aren't ZX Spectrum Next's Sprite, just UDG
\ usage:
\   Blinky  sprite-put
: sprite-put ( -- )
    sprite@ face  c@
    sprite-color  16
    xy-pos@ swap      22  \ prepare .at
    sprite@ maze  c@
    xy-pre@ swap      22  \ prepare .at
    4 16
    sync-emit             \ send all 12 chr
;


( init-all )
\ draw every mob at their start position
: init-all
    ghost-init
    pacman-init
    cherry-init
    99 counting !
    ghost-color 1 hunt !
    reset-phases
    key-right LASTK c!
;


( ?pac-trail )
\ given a character c that is ahead of pacman
\ verify if is a good trail
: ?pac-trail  ( c -- )
    case
        bl       of 1 endof
        [udg]  V of 1 endof
        fruit-glyph@ of 1 endof
        [udg]  O of 1 endof
        [char] / of 1 endof
        [char] \ of 1 endof
        0 swap
    endcase ;


( ?ghost-all )
\ given a character c that is ahead of ghost
\ verify if is a good trail
: ?ghost-trail  ( c -- )
    case
        bl       of 1 endof
        [udg]  V of 1 endof
        fruit-glyph@ of 1 endof
        [udg]  O of 1 endof
        [char] - of 1 endof
        0 swap
    endcase ;


( go-right )
: go-right
  Pacman
  xy-pos@      1+      maze@
  dup [char] \ = if
   1 sprite@ y-pos c!
  then
  ?pac-trail if
   [char] R UDG+
   sprite@ face  c!
   1  sprite@ y-pos c+!
   key-right sprite@ dir c!   \ Pinky/Inky aim ahead of this
  then ;


( go-left )
: go-left
  Pacman
  xy-pos@      1-      maze@
  dup [char] / = if
   21 sprite@ y-pos c!
  then
  ?pac-trail if
   [char] P UDG+
    sprite@ face  c!
   -1 sprite@ y-pos c+!
   key-left sprite@ dir c!
  then ;


( go-up )
: go-up
  Pacman
  xy-pos@ swap 1- swap maze@
  ?pac-trail if
   [char] Q UDG+
   sprite@ face  c!
   -1 sprite@ x-pos c+!
   key-up sprite@ dir c!
  then ;


( go-down )
: go-down
  Pacman
  xy-pos@ swap 1+ swap maze@
  ?pac-trail if
   [char] S UDG+
   sprite@ face  c!
   1  sprite@ x-pos c+!
   key-down sprite@ dir c!
  then ;


( pacman-move )
: pacman-move ( c -- )
 case
 key-right of go-right endof key+right of go-right endof
 key-left  of go-left  endof key+left  of go-left  endof
 key-up    of go-up    endof key+up    of go-up    endof
 key-down  of go-down  endof key+down  of go-down  endof
 endcase
 \ Kempston joystick interface 
 31 p@ case
 1         of go-right endof
 2         of go-left  endof
 4         of go-down  endof
 8         of go-up    endof
 endcase
;


( pacman-eat-pill ) 
: pacman-eat-pill ( c -- ) 
  [udg] O = if 
   -1 hunt ! 
   10 score d+! 
   10 total d+! 
   [ 50 25 bip ] 2lit bleep 
   [ 50 39 bip ] 2lit bleep 
   0 counting !
   128 0 speed all-ghost    \ frightened ghosts drop to 50%
   force-reverse            \ and turn round on the spot
  then ;
\


( pacman-walk )
: pacman-walk ( c -- )
  >r r@ [udg]  O =
     r@ [udg]  V = or
     r> fruit-glyph@ = or
  0= if
   pacman
   xy-pos@ xy-pre@ d=
   0= if
\   [ 12 -14 bip ] 2lit
\   bleep
   then
  then
;


( pacman-eat-cherry )
: pacman-eat-cherry ( c -- )
  fruit-glyph@ = if
   fruit-score@ score d+!
   fruit-score@ total d+!
   [ 50 29 bip ] 2lit bleep
   [ 50 36 bip ] 2lit bleep
  then ;


( ghost AI - geometry )

\ The arcade rules are written for x=column, y=row.  This game is the
\ other way round: x-pos is the ROW and y-pos is the COLUMN.  Everything
\ below is already translated to (r,c) = (x-pos,y-pos).  Get that
\ backwards and Pinky's bug and the tie-break come out mirrored, with no
\ visible error to tell you.

\ reverse of a direction: key-left+key-right = key-up+key-down = 109
: opposite ( d1 -- d2 )
  109 swap - ;

\ the cell reached from (r,c) by one step in direction d
: step-cell ( r c d -- r2 c2 )
  case
    key-up    of swap 1- swap endof
    key-down  of swap 1+ swap endof
    key-left  of 1-           endof
    key-right of 1+           endof
  endcase ;

\ squared euclidean distance between two cells.  Squaring is enough:
\ sqrt is monotonic so the ordering is identical, and we skip the root.
\ Worst case here stays well inside a 16-bit cell.
: dist2 ( r1 c1 r2 c2 -- n )
  rot - dup * >r
  - dup * r> + ;


( ghost AI - targets )

variable tgt-r
variable tgt-c
variable own-r          \ the deciding ghost's own cell, for Ted
variable own-c

\ Scatter corners, one per ghost, deliberately outside the maze so they
\ can never be reached: the ghost just orbits its corner until the mode
\ changes.  Indexed by ghost number.
create scatter-tab
  22 c, 23 c,           \ 0 Inky   bottom-right
   0 c,  1 c,           \ 1 Pinky  top-left
   0 c, 23 c,           \ 2 Blinky top-right
  22 c,  1 c,           \ 3 Ted    bottom-left

: scatter-cell ( n -- r c )
  dup + scatter-tab +
  dup c@ swap 1+ c@ ;

\ Offset of n cells in direction d, reproducing the arcade's 8080
\ overflow bug: when Pac-Man faces UP the offset also picks up a LEFT
\ component of the same size.  Pinky's ambushes and the classic
\ "head-fake" escape both depend on it, so it is kept on purpose.
: dir-delta ( n d -- dr dc )
  case
    key-up    of dup negate swap negate endof   \ ( -n -n ) : the bug
    key-down  of 0                      endof   \ ( n  0 )
    key-left  of 0 swap negate          endof   \ ( 0 -n )
    key-right of 0 swap                 endof   \ ( 0  n )
    >r drop 0 0 r>
  endcase ;

\ the cell n steps ahead of Pac-Man
: ahead ( n -- r c )
  pacman sprite@ dir c@ dir-delta
  pacman xy-pos@
  >r rot + r> rot + ;

\ Blinky, "Shadow": straight at Pac-Man's own cell.
: blinky-target ( -- )
  pacman xy-pos@ tgt-c ! tgt-r ! ;

\ Pinky, "Speedy": four cells ahead of Pac-Man.
: pinky-target ( -- )
  4 ahead tgt-c ! tgt-r ! ;

\ Inky, "Bashful": take the cell two ahead of Pac-Man, draw the vector
\ from Blinky to it, and double it.  Inky hangs back while Blinky is far
\ away and closes in as Blinky closes in -- he is the only one who
\ depends on another ghost, so Blinky is moved first each tick.
: inky-target ( -- )
  2 ahead                       \ or oc
  blinky xy-pos@                \ or oc br bc
  rot dup + swap - tgt-c !      \ 2*oc - bc
  swap dup + swap - tgt-r ! ;   \ 2*or - br

\ Ted, in Clyde's "Pokey" role: charges while more than 8 cells away,
\ peels off to his own corner once he gets closer.  Hence the loop:
\ charge, touch the 8-cell ring, drift off, come back.
: ted-target ( -- )
  xy-pos@ own-c ! own-r !
  pacman xy-pos@
  2dup own-r @ own-c @ dist2
  64 < if
     2drop 3 scatter-cell
  then
  tgt-c ! tgt-r ! ;


( ghost AI - choosing a direction )

variable best-d
variable best-n
variable no-dir         \ the direction this ghost may not take
variable found

\ Consider one direction.  It survives only if it is not the forbidden
\ reversal, is not a wall, and lands strictly closer to the target than
\ anything tried so far.  Because the caller tries up, left, down, right
\ in that order and the test is a strict <, ties break the arcade way --
\ up > left > down > right -- for free.
: try-dir ( r c d -- r c )
  dup no-dir @ = if
     drop
  else
     >r 2dup r@ step-cell
     2dup maze@ ?ghost-trail if
        2dup tgt-r @ tgt-c @ dist2
        dup best-n @ < if
           best-n !  r@ best-d !
        else
           drop
        then
     then
     2drop r> drop
  then ;

\ Greedy one-cell lookahead: there is no pathfinding anywhere in this
\ file.  A ghost's whole personality is in WHERE its target sits, never
\ in how it walks there.
: choose-dir ( -- d )
  32767 best-n !
  sprite@ dir c@ dup best-d !
  opposite no-dir !
  xy-pos@
  key-up    try-dir
  key-left  try-dir
  key-down  try-dir
  key-right try-dir
  2drop
  best-n @ 32767 = if
     no-dir @ best-d !    \ dead end: turning back is the only way out
  then
  best-d @ ;

\ clockwise probe order, used only when frightened
create cw-tab
  key-up c, key-right c, key-down c, key-left c,

: legal-dir? ( r c d -- f )
  dup no-dir @ = if
     drop 2drop 0
  else
     step-cell maze@ ?ghost-trail
  then ;

\ Frightened ghosts use no target at all: they pick a pseudo-random
\ direction and, if it is blocked, step clockwise to the next one.
: scared-dir ( -- d )
  sprite@ dir c@ dup best-d !
  opposite no-dir !
  0 found !
  4 choose
  4 0 do
     found @ 0= if
        dup 3 and cw-tab + c@
        dup >r
        xy-pos@ rot legal-dir? if
           r@ best-d !  1 found !
        then
        r> drop
     then
     1+
  loop
  drop
  best-d @ ;


( ghost movement )

\ consume a pending forced reversal, set when the mode changed
: apply-reverse ( -- )
  sprite@ rev? c@ if
     sprite@ dir c@ opposite sprite@ dir c!
     0 sprite@ rev? c!
  then ;

\ Fractional speed, so ghosts can be slower than Pac-Man: pure add and
\ compare, no multiply.  192/256 = 75% normally, 128/256 = 50% when
\ frightened.  This replaces the FRAMES gate that never worked.
: ghost-step? ( -- f )
  sprite@ accum c@  sprite@ speed c@  +
  dup 255 > if
     256 -  sprite@ accum c!  1
  else
     sprite@ accum c!  0
  then ;

\ pick a direction, then step if the cell ahead is walkable
: ghost-move ( -- )
  hunt @ -1 = if scared-dir else choose-dir then
  dup sprite@ dir c!
  xy-pos@ rot step-cell
  2dup maze@ ?ghost-trail if
     sprite@ y-pos c!
     sprite@ x-pos c!
  else
     2drop
  then ;

\ Work out where ghost n wants to go, then leave ghost n selected: the
\ target words select Pacman and Blinky as they work, so restoring the
\ selection is not optional.
: ghost-target ( n -- )
  dup >r
  scatter? @ if
     scatter-cell tgt-c ! tgt-r !
  else
     dup sprite#
     case
       0 of inky-target   endof
       1 of pinky-target  endof
       2 of blinky-target endof
       3 of ted-target    endof
     endcase
  then
  r> sprite# ;



\
: pacman-eat-dot ( c -- )
  [udg] V = if
   1  score d+!
\  [ 12 -12 bip ] 2lit
\  bleep
  then ;


.( display )

: init-display
 LAYER11 30 emitc 8 emitc
 0 .paper 0 .border 4 .ink
 cls maze.
 0 20 .at ." high "
 high-score 2@
 <# # # # # # # #> type
 5 0 do
  i  sprite#
  sprite-put
 loop
;


.( Interlude course )

: inter-hunt
  0 27 do
   10 i .at sync-vid
   1 16 bl emit emitc emitc  \ scared ghost: blue, not the old white
   [udg] T emitc sync-vid
   bl bl emitc emitc
   6 16 emitc emitc
   [udg] P emitc
   bl emit sync-vid
   bleep
   ?terminal if quit then
  -1 +loop ;


: inter-flee
  28 1 do
   10 i .at sync-vid
   3 16 bl emit emitc emitc
   [udg] T emitc sync-vid
   bl bl emitc emitc
   6 16 emitc emitc
   [udg] R emitc
   sync-vid
   bleep
   ?terminal if quit then
  1 +loop ;



: inter-sound
  27 0 do
   012 i bip swap
  01 +loop
  1 28 do
   012 i bip swap
  -1 +loop ;


: interlude
  inter-sound cls
  7 .ink
  10 30 .at
  [udg]  O  emitc
  inter-flee
  inter-hunt ;




: catch? ( -- f )
  pacman xy-pos@
  inky   xy-pos@ d=
  pacman xy-pos@
  pinky  xy-pos@ d=
  pacman xy-pos@
  blinky xy-pos@ d=
  pacman xy-pos@
  ted    xy-pos@ d=
  or or or ;



: ghost-eaten ( n -- )
  sprite#
  12 sprite@ x-pos c!
  12 sprite@ y-pos c!
  bl sprite@ maze  c!
  10 score d+!
  10 total d+!
  [  5 20 bip ] 2lit bleep
  [  5 10 bip ] 2lit bleep
  [ 10 10 bip ] 2lit bleep
;



: ghost-catch
  -1 lives +!
  lives @ 0= if
   high-score 2@ score 2@
   dnegate d+ nip 0< if   \ d+'s sign lives in the high cell, which is on
                          \ top; nip discards the low cell under it so 0<
                          \ tests the right one and nothing leaks
     score 2@ high-score 2!
   then
   0. score 2!
   0. total 2!
   maze-dots @ total D+!
  then
  init-all
  interlude
  init-display ;



: catch!
  hunt @ 1 = if
   ghost-catch
  else
   4 0 do
    i sprite# xy-pos@
    pacman    xy-pos@ d= if
     i ghost-eaten
    then
   loop
  then ;



: count-down
  hunt @ -1 = if
   1  counting +!
   60 counting @ < if
     ghost-color 1 hunt ! 192 0 speed all-ghost
   then
  then
; 



\ true while the cherry is still on the maze, waiting to be eaten
: cherry-visible? ( -- f )
  cherry xy-pos@ maze@ fruit-glyph@ = ;

\ once visible, redraw every tick so FRUIT-CYCLE actually pulses;
\ otherwise roll for a new cherry to appear
: put-cherry
  cherry-visible? if
   cherry sprite-put
  else
   100 choose 0= if
    cherry sprite-put
    fruit-glyph@ xy-pos@ maze!
   then
  then ;
\

\ Power pills are few and fixed once a maze loads, so their positions are
\ scanned once (find-pills, called after every set-maze-run) instead of
\ every heart-beat: flash-pills then just checks those 4 cached cells,
\ same as put-cherry treats the one cherry position.
4 constant pill-n
create pill-x  pill-n allot
create pill-y  pill-n allot

\ scan the maze once and cache every power pill's (x,y), counting the
\ plain dots on the way; a maze with fewer than pill-n pills leaves the
\ remaining slots at 0 (never matches a real row, so flash-pills'
\ maze@ check on them just misses harmlessly)
variable pill-found
: find-pills ( -- )
  pill-n 0 do 0 i pill-x + c!  0 i pill-y + c! loop
  0 pill-found !
  0 maze-dots !
  22 1 do
    22 1 do
      j i maze@
      dup [udg] V = if 1 maze-dots +! then
      [udg] O = if
        pill-found @ pill-n < if
          j pill-found @ pill-x + c!
          i pill-found @ pill-y + c!
          1 pill-found +!
        then
      then
    loop
  loop ;

\ redraw every power pill still uneaten with the current PILL-FLASH
\ colour, then restore the maze's standard ink so nothing else (e.g.
\ the dashboard's plain-text " score " label) inherits the flash colour
: flash-pills ( -- )
  PILL-FLASH .ink
  pill-n 0 do
    i pill-x + c@ i pill-y + c@   \ x y
    2dup maze@ [udg] O = if
      2dup .at [udg] O emitc
    then
    2drop
  loop
  4 .ink ;

\ ===========================================================================
\ MAZE-CHECK -- interpreter-only validator for a maze (compiled or on disk).
\ Not called by the game.  Loads the RAW characters (no UDGize) of maze n
\ into a scratch buffer separate from maze-run (so a live game is never
\ disturbed), then runs a handful of structural checks, reporting every
\ problem found instead of stopping at the first one.
\
\ Usage:  0 MAZE-CHECK   \ checks the compiled maze-base
\         1 MAZE-CHECK   \ checks disk maze #1 (Screen 740/741)
\ ===========================================================================

create maze-check-buf  24 21 * allot

\ address of raw character at (0-based row 0..20, column 1..maze-w) in
\ maze-check-buf -- same column convention as maze^/maze@ above
: check^ ( r c -- a )
    swap 24 * maze-check-buf + + ;

\ A-N are the fourteen wall strokes, W the fifteenth (the one-cell
\ island); V is the dot's UDG slot, not a wall, so the range stops at N
\ and W is tested apart
: wall-char? ( c -- f )
    upper dup [char] W =
    swap [char] A [char] N between or ;

\ same per-row copy maze-copy does, but WITHOUT the UDGize step
: raw-copy-base ( a1 a2 -- )
    maze-h 0 do
        2dup 24 cmove
        swap 24 + swap 24 +
    loop
    2drop ;

: maze-check-load ( n -- )
    ?dup 0= if
        maze-base maze-check-buf raw-copy-base
    else
        maze-h 0 do
            dup i maze-line
            maze-check-buf i 24 * +
            raw-row!
        loop drop
    then ;

variable check-errors

\ ---- individual checks -----------------------------------------------

: check-nul ( -- )
    maze-h 0 do
        maze-w 0 do
            j i 1+ check^ c@ 0= if
                1 check-errors +!
                cr ." NUL byte at row " j 1+ . ." col " i 1+ .
            then
        loop
    loop ;

variable door-count

: check-door ( -- )
    0 door-count !
    maze-h 0 do
        maze-w 0 do
            j i 1+ check^ c@ [char] - = if
                1 door-count +!
            then
        loop
    loop
    door-count @ 0= if
        1 check-errors +!
        cr ." no ghost-house door ('-') found"
    then ;

variable slash-count
variable slash-row
variable bslash-count
variable bslash-row

: check-tunnel ( -- )
    0 slash-count !   0 bslash-count !
    -1 slash-row !    -1 bslash-row !
    maze-h 0 do
        maze-w 0 do
            j i 1+ check^ c@
            dup [char] / = if
                1 slash-count +!
                j slash-row !
            then
            92 = if                      \ 92 = '\' -- avoid [char] \, which
                1 bslash-count +!         \ would hand a bare backslash token
                j bslash-row !            \ to the parser right after [char]
            then
        loop
    loop
    slash-count @ bslash-count @ <> if
        1 check-errors +!
        cr ." tunnel mismatch: " slash-count @ . ." '/' vs " bslash-count @ . ." '\'"
    then
    slash-count @ 0> if
        slash-row @ bslash-row @ <> if
            1 check-errors +!
            cr ." tunnel '/' and '\' not on the same row"
        then
    then ;

variable pill-count-check
variable dot-count-check

\ pill-n power pills exactly (find-pills caches that many and no more),
\ and at least one dot -- a maze with no dots can never be completed.
\ The dot count itself is free: total is primed from it at run time.
: check-pills ( -- )
    0 pill-count-check !
    0 dot-count-check !
    maze-h 0 do
        maze-w 0 do
            j i 1+ check^ c@
            dup [char] . = if 1 dot-count-check +! then
            [char] O = if
                1 pill-count-check +!
            then
        loop
    loop
    pill-count-check @ pill-n <> if
        1 check-errors +!
        cr ." pill count mismatch: found " pill-count-check @ . ." expected " pill-n .
    then
    dot-count-check @ 0= if
        1 check-errors +!
        cr ." no dots: the phase could never be completed"
    then ;

\ Where Pac-Man, the four ghosts and the cherry appear is hard-coded in
\ pacman-init / ghost-init / ghost-eaten / cherry-init, not read from
\ the maze, and each of them stores a blank as the cell it covers -- so
\ a maze that puts anything else there loses that character the moment
\ the sprite steps off it.  Ted starts on the ghost-house door, which
\ is the one cell that must NOT be blank.
\ r and c are check^'s own coordinates (row 0-based, column 1..maze-w),
\ and so is what gets reported -- same convention as every check above
: check-cell ( r c c1 -- )
    >r 2dup check^ c@ r> <> if
        1 check-errors +!
        cr ." spawn cell at row " swap 1+ . ." col " .
        ." holds the wrong character"
    else
        2drop
    then ;

: check-spawn ( -- )
    13 12 bl check-cell            \ Pac-Man and the cherry
    11 10 bl check-cell            \ Inky
    11 11 bl check-cell            \ Blinky, and where an eaten ghost returns
    11 12 bl check-cell            \ Pinky
    10 11 [char] - check-cell ;    \ Ted, on the door

\ ---- connectivity (flood-fill from Pac-Man's start cell) --------------

512 constant ff-max
create ff-stack  ff-max 2 * allot
variable ff-sp
variable ff-count

: ff-addr ( -- a )  ff-sp @ 2* ff-stack + ;

: ff-push ( r c -- )
    ff-addr 1+ c!
    ff-addr c!
    1 ff-sp +! ;

: ff-pop ( -- r c )
    -1 ff-sp +!
    ff-addr c@
    ff-addr 1+ c@ ;

variable ff-ok

: ff-in-bounds? ( r c -- f )
    -1 ff-ok !
    dup 1 < if 0 ff-ok ! then
    dup maze-w > if 0 ff-ok ! then
    drop                              ( r )
    dup 0 < if 0 ff-ok ! then
    maze-h 1- > if 0 ff-ok ! then
    ff-ok @ ;

\ open = in bounds, not a wall letter, and not already visited (the
\ flood-fill marks a visited cell by overwriting it with byte 1, which
\ is not a legal maze character so it can never be confused with one)
: ff-open? ( r c -- f )
    2dup ff-in-bounds?
    if
        check^ c@
        dup wall-char?
        swap 1 = or 0=
    else
        2drop 0
    then ;

\ if (r,c) is open and unvisited: mark it visited and queue it
: ff-try ( r c -- )
    2dup ff-open? if
        2dup check^ 1 swap c!
        1 ff-count +!
        ff-push
    else
        2drop
    then ;

: ff-visit ( r c -- )
    2dup swap 1- swap ff-try     \ up:    (r-1, c)
    2dup swap 1+ swap ff-try     \ down:  (r+1, c)
    2dup 1- ff-try                \ left:  (r, c-1)
    2dup 1+ ff-try                \ right: (r, c+1)
    2drop ;

: flood-fill ( start-r start-c -- n )
    0 ff-count !
    0 ff-sp !
    ff-try
    begin
        ff-sp @ 0>
    while
        ff-pop ff-visit
    repeat
    ff-count @ ;

\ A row's leading/trailing run of spaces is not corridor: the maze
\ shape is not a rectangle (e.g. the ghost-house alcove rows), and those
\ columns are genuinely outside the walkable area, never reached by any
\ path -- comparing a raw non-wall cell count against the flood-fill
\ would flag maze-base itself as "broken".  Instead, check that every
\ cell that actually MATTERS for play -- a dot, a pill, a door, a tunnel
\ mouth -- was reached: those characters never appear in the outside-
\ shape filler, so this has no false positives on the compiled maze.
: feature-char? ( c -- f )
    dup [char] . =
    over [char] O = or
    over [char] - = or
    over [char] / = or
    swap 92 = or ;                \ 92 = '\'

\ Pac-Man's start cell is hard-coded here the same way pacman-init hard-
\ codes it (14 x-pos, 12 y-pos): row is 0-based for check^, so 14-1.
\ flood-fill overwrites every reached cell with byte 1, so a feature
\ character still showing its original glyph afterwards was never
\ reached.
: check-connectivity ( -- )
    13 12 flood-fill drop
    maze-h 0 do
        maze-w 0 do
            j i 1+ check^ c@ feature-char? if
                1 check-errors +!
                cr ." unreachable feature at row " j 1+ . ." col " i 1+ .
            then
        loop
    loop ;

\ maze-run's shape is not a rectangle (e.g. the tapered top/bottom rows
\ and the ghost-house alcove), so "row 0/20 are all walls" is false even
\ for maze-base itself: it has blank filler cells there too.  The
\ property that actually matters is that NONE of those filler cells (or
\ any cell on the outer edge of the maze-h x maze-w grid) is reachable -- maze^
\ has no bounds check, so a reachable edge cell would let a future move
\ compute a row/column outside the array.  Must run right after
\ check-connectivity, which is what leaves the byte-1 reachability
\ markers this reads.
: check-perimeter ( -- )
    maze-w 0 do
        0 i 1+ check^ c@ 1 = if
            1 check-errors +!
            cr ." reachable cell on top border, col " i 1+ .
        then
        maze-h 1- i 1+ check^ c@ 1 = if
            1 check-errors +!
            cr ." reachable cell on bottom border, col " i 1+ .
        then
    loop
    \ the tunnel row is a deliberate exception: its '/' and '\' mouths
    \ are meant to reach column 1 / maze-w (that is how Pac-Man wraps
    \ around), so skip left/right on whichever row check-tunnel found
    \ them on -- everywhere else the edge must stay unreached.
    maze-h 0 do
        i slash-row @ <> if
            i 1 check^ c@ 1 = if
                1 check-errors +!
                cr ." reachable cell on left border, row " i 1+ .
            then
        then
        i bslash-row @ <> if
            i maze-w check^ c@ 1 = if
                1 check-errors +!
                cr ." reachable cell on right border, row " i 1+ .
            then
        then
    loop ;

\ ---- driver -------------------------------------------------------------

: MAZE-CHECK ( n -- )
    0 check-errors !
    maze-check-load
    check-nul
    check-door
    check-tunnel
    check-pills
    check-spawn
    check-connectivity
    check-perimeter
    check-errors @ 0= if
        cr ." MAZE-CHECK: OK, " dot-count-check @ . ." dots"
    else
        cr ." MAZE-CHECK: " check-errors @ . ." problem(s) found"
    then ;


: key-decode ( c1 -- c2 )
  case
  key+up of key-up endof
  key+down of key-down endof
  key+left of key-left endof
  key+right of key-right endof
  dup
  endcase ;




: move-pacman
  pacman xy-pos@ xy-pre!
  LASTK key-decode c@
\ sprite dir c@
  pacman-move sprite-put
  xy-pos@ maze@
  bl xy-pos@ maze!
  catch? if catch! then
  dup pacman-eat-dot
  dup pacman-eat-pill
  dup pacman-eat-cherry
      pacman-walk
;



\ Blinky is moved before Inky, because Inky's target is built from
\ Blinky's current cell.  The order of this table is not cosmetic.
create ghost-order  2 c, 1 c, 0 c, 3 c,

: move-four-ghosts
  4 0 do
    i ghost-order + c@              \ n
    dup sprite# xy-pos@ xy-pre!
    apply-reverse
    ghost-step? if
       dup ghost-target
       ghost-move
    then
    sprite-put
    xy-pos@ maze@
    sprite@ maze c!
    catch? if catch! then
    drop
  loop
;



: dashboard
  0  1 .at
  6 16 emitc emitc \ yellow
  [udg] P emitc
  7 16 emitc emitc \ white
  bl emitc lives ?
  0  6 .at ." score "
  score 2@
  <# # # # # # # #> type
;



needs .s
: debug
  2 24 .at 6 16 emitc emitc
  pacman xy-pos@ swap . .
  3 24 .at LASTK c@ .
\ 22 1 .at hex sprite 8 +
\ sprite@ (dmp) decimal
  5 24 .at total 2@ D.
  7 24 .at counting @ .
  9 24 .at
  sprite@ maze c@ emitc
  0 0 .at .s
  11 24 .at hunt @ .
\ 22 22 .at ." KEY" key drop
; 



\ put-cherry/flash-pills draw first so Pac-Man and the ghosts, drawn
\ after, always win the cell visually: both redraw their glyph every
\ tick straight onto the maze data's say-so (still O / still the fruit
\ glyph), with no idea a sprite is currently sitting on that same cell,
\ so whichever draws last wins the pixel.  A ghost sitting on the power
\ pill used to lose to the very next flash-pills call.
: heart-beat
  pace
  put-cherry
  flash-pills
  move-pacman
  move-four-ghosts
  count-down
  tick-phase
  dashboard
\ debug
;

\ debug
: T heart-beat ;
: C catch? . ;
: M init-display ;



\ every dot of the maze about to be played raises the bar score has to
\ reach, so the count has to be taken AFTER find-pills has scanned the
\ new maze -- not before set-maze-run, where the old fixed 180 sat
: phase-complete
  score 2@ total 2@ d= if
   ghost-color 1 hunt !
   1 level +!    \ before init-all: cherry-init reads FRUIT-GLYPH@ off
   init-all       \ the level about to be played, not the old one
   set-maze-run
   find-pills
   maze-dots @ total D+!
   interlude
   init-display
   key-right LASTK c!
  then ;



: run-game
  begin
   lives @
  while
   heart-beat
   phase-complete
   ?terminal if quit then
  repeat
;



: play-level
  UDG_1 $5C7B ! \ UDG
  LAYER11 
  [ 2 ] LITERAL SPEED! 
  30 emitc 8 emitc
  [ 3 ] LITERAL lives !
  0 .paper 0 .border 4 .ink
  1 .bright \ .perm
  interlude
  0.   total 2!
  0.   score 2!
  decimal
  init-all
  set-maze-run
  find-pills
  maze-dots @ total D+!
  init-display
  run-game
  22 0 .at
  LAYER12 3 SPEED!
;

: game 0 level ! play-level ;


\ same as GAME, but starting at the given level instead of always 0 --
\ lets a disk maze be played straight from the prompt for testing,
\ without first clearing the levels before it.  ( n -- )
: test-level  level ! play-level ;

\ BASE !


CR CR CR
needs TRUV needs INVV
TRUV  .( Use: )
INVV  .(  GAME )  CR
TRUV  .( Arrorw keys to move. ) CR
      .( Cursor Joystick should work. ) CR
INVV  .(  BREAK )
TRUV  .( stops. ) CR .( Give. ) CR
INVV  .(  LAYER12 )
TRUV  .( to go at 64 columns and ) CR
INVV  .(  3 SPEED! )
TRUV  .( to go at 28 MHz. ) CR


