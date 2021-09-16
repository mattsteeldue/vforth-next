\
\ chomp-chomp.f
\

.( Chomp-Chomp GAME ) 

MARKER CHOMP-CHOMP
FORTH DEFINITIONS 

CASEOFF                 \ ignore case for this source

FLUSH EMPTY-BUFFERS     \ just stay clean

NEEDS VALUE  
NEEDS TO  
NEEDS CASE
NEEDS LAYERS            \ Sinclair ZX Spectrum Next - Layer 1,1
NEEDS SPEED!            \ Sinclair ZX Spectrum Next - Run up to 28 MHz

NEEDS CHOOSE            \ Brodie's random numbers

\ decimal  50 load \ bleep

.( BLEEP ) CR
\
( n1 = {3.5M/Hz-241}/8 )
( n2 = 1000 * ms / Hz )
\
CODE  BLEEP  HEX
  E1 C,                 \ pop hl
  D1 C,                 \ pop de
  C5 C,                 \ push bc
  DD C, E5 C,           \ push ix
  CD C, 03B5 ,          \ call 03B5
  DD C, E1 C,           \ pop ix
  C1 C,                 \ pop bc
  DD C, E9 C, ( NEXT )  \ jp (ix)
SMUDGE DECIMAL


( BLEEP )
\ accept two integers
\ ms  : sound duration in millisecond
\ Hz  : sound frequency in hertz
\ Give back then suitable numbers for BLEEP routine
: BLEEP-CALC  ( ms Hz -- n1 n2 )
  >R R@ 1000 */
  3500.000 R> UM/MOD
  241 - 8 /
  SWAP DROP ;

: BEEP-PITCH  ( BEEP pitch -- freq )
  69 SWAP -
  12 /MOD 14080
  SWAP 0 ?DO 2/ LOOP
  SWAP 0 ?DO 269 286 */ LOOP
;


\ decimal  41 load \ attributes
\
.( Color and attributes  ) CR

NEEDS CALL#         

HEX

: PERM  0 1CAD CALL# DROP ;         \ make "permanent" the previous attribute
: BORDER. 2297 CALL# DROP ;         \ set border color

DECIMAL

: (COLOR)
  ROT AND SWAP EMITC EMITC
  PERM ;
: INK.     16 7 (COLOR) ;
: PAPER.   17 7 (COLOR) ;
: FLASH.   18 1 (COLOR) ;
: BRIGHT.  19 1 (COLOR) ;
: INVERSE. 20 1 (COLOR) ;
: OVER.    21 1 (COLOR) ;



( AT TAB                   )

: AT. ( row col -- )
  22 EMITC        SWAP
         EMITC EMITC ;

: TAB.
  23 EMITC EMITC 0 EMITC ;

: LVIDEO
  2 23659 C! 1 SELECT ;

: ATTR  ( x y --- b )
  SWAP 32 * + 22528 + C@ ;





( Chomp.f )
CODE sync-vid HEX
 76 C,              \ halt
 DD C, E9 C,        \ jp (ix)
 smudge
\

: c+! ( n a )
  tuck c@ + swap c! ;
\

: d+! ( n a )
  tuck 2@      \ a n d
  rot s>d d+  \ a d+n
  rot 2! ;
decimal




( Chomp.f )
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




( Chomp.f )
: six-emitc
  emitc emitc emitc
  emitc emitc emitc ;
\
: sync-emit
  sync-vid
  emitc emitc emitc emitc
  emitc emitc emitc emitc
  emitc emitc emitc emitc ;
\

( Chomp.f )

decimal 23560 constant LASTK    \ system variable : last key pressed
 0 variable total 0 ,
 0 variable score 0 ,
 0 variable high-score 0 ,
30 variable counting
 3 variable lives
 1 variable hunt



( Chomp.f )

: pill-on
  -1 hunt !
  10  total d+!
  0 counting ! ;

\
: bip ( n1 n2 -- n3 n4 )
  beep-pitch
  bleep-calc
  swap ;
\
: 2lit ( n1 n2 -- )
  [compile] literal
  [compile] literal
; immediate 


( Chomp.f )
  char 8  value    key-right
  char 5  value    key-left
  char 7  value    key-up
  char 6  value    key-down
       9  value    key+right
       8  value    key+left
      11  value    key+up
      10  value    key+down


.( Chomp.f - UDG )

decimal

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

: .UDG ( c -- )
 cr UDG@ dup 8 + swap do
  i c@ b.     cr
 loop ; 


( Chomp.f - UDG )

: UDGize ( a -- )
 count over + swap do
  i c@ upper [char] A [char] U
  between if
   i c@ upper UDG+ i c!
  endif
 loop ;
\

: Gtype ( a c -- )
 over + swap ?do
  i c@ emitc loop ;

: UDGs
  [char] V [char] A do
   i UDG+ emitc loop ;



( Chomp.f - UDG )

\ UDG - User Defined Graphic characters

create UDG_1
hex
FF00 , 0000 , 0000 , 0000 , \ A
0000 , 0000 , 0000 , 00FF , \ B
FF00 , 0000 , 0000 , 00FF , \ C
F800 , 0204 , 0202 , 0202 , \ D
1F00 , 4020 , 4040 , 4040 , \ E
3F00 , 8040 , 4080 , 003F , \ F
FC00 , 0102 , 0201 , 00FC , \ G
0202 , 0202 , 0402 , 00F8 , \ H
4040 , 4040 , 2040 , 001F , \ I
0202 , 0202 , 0202 , 0202 , \ J


( Chomp.f - UDG )
hex
1800 , 4224 , 4242 , 4242 , \ K
4242 , 4242 , 2442 , 0018 , \ L
4040 , 4040 , 4040 , 4040 , \ M
4242 , 4242 , 4242 , 4242 , \ N
0000 , 7C38 , 7C7C , 0038 , \ O
3E1C , 0F1F , 3E1F , 001C , \ P
2200 , 7F77 , 3E7F , 001C , \ Q
1C00 , 7C3E , 7C78 , 1C3E , \ R
3800 , FE7C , EEFE , 0044 , \ S
7E38 , DB5A , FFFF , 93FF , \ T
0602 , 140A , EE24 , 66EE , \ U
UDG_1 5C7B ! \ UDG


.( Chomp.f - maze )
decimal
21 constant maze-h
21 constant maze-w
create maze-run
24 21 * allot
create maze-base



( Chomp.f - maze )
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
,"     J.N.... ..N.N     "
," BBBBH.L.FCACG.L.IBBBB "
," M.........N.........J "
," MOFCD.FCG.L.FCG.ECGOJ "
," M...N...........N...J "
," AAD.L.FCCCCCCCG.L.EAA "
,"   J...............M   "
,"    AAAAAAAAAAAAAAA    "



( Chomp.f - maze )
decimal
: maze-copy ( a1 a2 -- )
 maze-h 0 do
  2dup 24 cmove
  dup udgize
  swap 24 + swap 24 +
 loop
 2drop ;
\
: set-maze-run
  maze-base
  maze-run
  maze-copy ;
set-maze-run



( Chomp.f - maze )
: maze^ ( x y -- a )
 maze-run + swap 1-
 24 * + ;
\
: maze@ ( x y -- c )
 maze^ c@ ;
\
: maze! ( c x y -- )
 maze^ c! ;
\



( Chomp.f - maze )
: maze.
 0 0 at.
 1 22 do
  025 i 16 +
  beep-pitch bleep-calc
 -1 +loop
 maze-run
 22 1 do
  cr space
  dup count gtype 24 +
 >R bleep R>
 loop
 drop
;



.( Chomp.f - Sprite )
create Array   6 08 * allot

0 variable Sprite^
0 value    Sprite-no

: sprite# ( n -- )
  dup 3 lshift array +
  sprite^ ! to sprite-no ;
\

: sprite@ ( -- a )
  sprite^ @ ;
\

: all-ghost  ( v i -- )
  32 Array  + swap Array  +
  do dup i c! 08 +loop
  drop ;



( Chomp.f - Sprite )

\ creates an index of Ghost
: index-of ( n -- )
  <builds c, does> c@ + ;

\ creates a ghost pointer
: name-of  ( n -- creates )
  <builds c, does> c@ dup
  3 lshift Array + sprite^ !
  to sprite-no ;



( Chomp.f - Sprite )

\ array index by name
0 name-of Inky
1 name-of Pinky
2 name-of Blinky
3 name-of Ted
\

0 index-of face
1 index-of color
2 index-of x-pos
3 index-of y-pos
4 index-of dir
5 index-of x-pre
6 index-of y-pre
7 index-of maze



( chomp.f - Sprite )
\ shorthand for x-pos,y-pos
: xy-pos@  ( -- x y )
  sprite@
  dup    x-pos c@
  swap   y-pos c@ ;

: xy-pre@  ( -- x y )
  sprite@
  dup    x-pre c@
  swap   y-pre c@ ;

: xy-pre! ( x y -- )
  >R sprite@ x-pre c!
  R> sprite@ y-pre c! ;
\


( Chomp.f - Sprite )

: Ghost-color ( -- )

 Inky   1 sprite@ color c!
 Pinky  3 sprite@ color c!
 Blinky 5 sprite@ color c!
 Ted    2 sprite@ color c!
;

: Ghost-white ( -- )
 7  0 color  all-ghost
;

ghost-color



( Chomp.f - Sprite )
: Ghost-init  ( -- )
 12 0 x-pos  all-ghost
 11 0 y-pos  all-ghost
 55 0 dir    all-ghost
 bl 0 maze   all-ghost
 Inky   10 sprite@ y-pos c!
 Inky   xy-pos@ xy-pre!
 Pinky  12 sprite@ y-pos c!
 Pinky  xy-pos@ xy-pre!
 Ted    11 sprite@ x-pos c!
 Ted    xy-pos@ xy-pre!
 Blinky xy-pos@ xy-pre!
 [char] T udg+
 0 face all-ghost
; 


( Chomp.f - Sprite )

4 name-of Pacman

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



( Chomp.f - Sprite )

5 name-of Cherry

: cherry-init
  Cherry [char] U UDG+
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




( Chomp.f - Sprite )

\ draw current sprite

: sprite-put ( -- )
  sprite@ face  c@
  sprite@ color c@   16
  xy-pos@ swap      22
  sprite@ maze  c@
  xy-pre@ swap      22
  4 16
  sync-emit
;

\ usage:
\ Blinky  sprite-put


( Chomp.f )
: init-all
  ghost-init
  pacman-init
  cherry-init
  00 counting !
  key-right LASTK c!
;

.( Chomp.f - trail )
: ?pac-trail  ( c -- )
 case
  bl       of 1 endof
  [char] . of 1 endof
  [udg]  U of 1 endof
  [udg]  O of 1 endof
  [char] / of 1 endof
  [char] \ of 1 endof
  0 swap
 endcase ;


( Chomp.f - trail )
: ?ghost-trail  ( c -- )
 case
  bl       of 1 endof
  [char] . of 1 endof
  [udg]  U of 1 endof
  [udg]  O of 1 endof
  [char] - of 1 endof
  0 swap
 endcase ;


( Chomp.f - trail )
: go-right
  Pacman
  xy-pos@      1+      maze@
  dup [char] \ = if
   1 sprite@ y-pos c!
  endif
  ?pac-trail if
   [char] R UDG+
   sprite@ face  c!
   1  sprite@ y-pos c+!
\ else 2 choose if key-up
\  else key-down then
\  sprite@ dir c!
  endif ;



( Chomp.f - trail )
: go-left
  Pacman
  xy-pos@      1-      maze@
  dup [char] / = if
   21 sprite@ y-pos c!
  endif
  ?pac-trail if
   [char] P UDG+
    sprite@ face  c!
   -1 sprite@ y-pos c+!
\ else 2 choose if key-up
\  else key-down then
\  sprite@ dir c!
  endif ;



( Chomp.f - trail )
: go-up
  Pacman
  xy-pos@ swap 1- swap maze@
  ?pac-trail if
   [char] Q UDG+
   sprite@ face  c!
   -1 sprite@ x-pos c+!
\ else 2 choose if
\  key-right else key-left then
\  sprite@ dir c!
  endif ;



( Chomp.f - trail )
: go-down
  Pacman
  xy-pos@ swap 1+ swap maze@
  ?pac-trail if
   [char] S UDG+
   sprite@ face  c!
   1  sprite@ x-pos c+!
\ else 2 choose if
\  key-left else key-right then
\  sprite@ dir c!
  endif ;


( Chomp.f - trail )
: pacman-move ( c -- )
 case
 key-right of go-right endof
 key-left  of go-left  endof
 key-up    of go-up    endof
 key-down  of go-down  endof
 endcase
 \ Kempston joystick interface 
 31 p@ case
 1         of go-right endof
 2         of go-left  endof
 4         of go-down  endof
 8         of go-up    endof
 endcase
;


( Chomp.f - trail )
: pacman-eat-pill ( c -- )
  [udg] O = if
   -1 hunt !
   10 score d+!
   10 total d+!
   [ 50 25 bip ] 2lit bleep
   [ 50 39 bip ] 2lit bleep
   0 counting !
   ghost-white
  endif ;
\


( Chomp.f - trail )
: pacman-walk ( c -- )
  >r r@ [udg]  O =
     r@ [char] . = or
     r> [udg]  U = or
  0= if
   pacman
   xy-pos@ xy-pre@ d=
   0= if
\   [ 12 -14 bip ] 2lit
\   bleep
   endif
  endif
;


( Chomp.f - trail )
: pacman-eat-cherry ( c -- )
  [udg] U = if
   10 score d+!
   10 total d+!
   [ 50 29 bip ] 2lit bleep
   [ 50 36 bip ] 2lit bleep
  endif ; 


( Chomp.f - ghost )
: ghost-right ( c -- )
  xy-pos@ 1+ maze@
  ?ghost-trail if
     1  sprite@ y-pos c+!
  else
   2 choose if
    key-down
   else
    key-up
   endif
   sprite@ dir c!
  endif
;


( Chomp.f - ghost )
: ghost-left  ( c -- )
  xy-pos@ 1- maze@
  ?ghost-trail if
    -1  sprite@ y-pos c+!
  else
   2 choose if
    key-up
   else
    key-down
   endif
   sprite@ dir c!
  endif
;


( Chomp.f - ghost )
: ghost-down  ( c -- )
  xy-pos@ swap 1+ swap maze@
  ?ghost-trail if
     1  sprite@ x-pos c+!
  else
   2 choose if
    key-right
   else
    key-left
   endif
   sprite@ dir c!
  endif
;


( Chomp.f - ghost )
: ghost-up    ( c -- )
  xy-pos@ swap 1- swap maze@
  ?ghost-trail if
    -1  sprite@ x-pos c+!
  else
   2 choose if
    key-left
   else
    key-right
   endif
   sprite@ dir c!
  endif
;


( Chomp.f - ghost )
: ghost-move ( c -- )
 case
  key-right of
   ghost-right endof
  key-left  of
   ghost-left  endof
  key-up    of
   ghost-up    endof
  key-down  of
   ghost-down  endof
 endcase ;
\


( Chomp.f - ghost )
: ghost-decision ( -- )
  xy-pos@ xy-pre@ d= if
   4 choose
   case
   0 of key-left  endof
   1 of key-down  endof
   2 of key-up    endof
   3 of key-right endof
   endcase
  endif
  sprite@ dir c!
;


( Chomp.f - trail )
\
: pacman-eat-dot ( c -- )
  [char] . = if
   1  score d+!
\  [ 12 -12 bip ] 2lit
\  bleep
  endif ;



( Chomp.f )
: init-display
 0 paper. 0 border. 4 ink.
 cls maze.
 0 20 at. ." high "
 high-score 2@
 <# # # # # # # #> type
 5 0 do
  i  sprite#
  sprite-put
 loop
;


( Chomp.f )
: inter-hunt
  0 27 do
   10 i at. sync-vid
   7 16 bl emit emitc emitc
   [udg] T emitc sync-vid
   bl bl emitc emitc
   6 16 emitc emitc
   [udg] P emitc
   bl emit sync-vid
   bleep
   ?terminal if quit then
  -1 +loop ;


( Chomp.f )
: inter-flee
  28 1 do
   10 i at. sync-vid
   3 16 bl emit emitc emitc
   [udg] T emitc sync-vid
   bl bl emitc emitc
   6 16 emitc emitc
   [udg] R emitc
   sync-vid
   bleep
   ?terminal if quit then
  1 +loop ;


( Chomp.f - Interlude )
: inter-sound
  27 0 do
   012 i bip swap
  01 +loop
  1 28 do
   012 i bip swap
  -1 +loop ;
\

: interlude
  inter-sound cls
  10 30 at.
  [udg]  O  emitc
  inter-flee
  inter-hunt ;



( Chomp.f )
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


( Chomp.f )
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


( Chomp.f )
: ghost-catch
  -1 lives +!
  lives @ 0= if
   high-score 2@ score 2@
   dnegate d+ 0< if
     score 2@ high-score 2!
   endif
   0. score 2!
   180. total 2!
  endif
  init-all
  interlude
  init-display ;


( Chomp.f )
: catch!
  hunt @ 1 = if
   ghost-catch
  else
   4 0 do
    i sprite# xy-pos@
    pacman    xy-pos@ d= if
     i ghost-eaten
    endif
   loop
  endif ;


( Chomp.f )
: count-down
  hunt @ -1 = if 1 counting +!
   56 counting @ < if
    ghost-color endif
   57 counting @ < if
    ghost-white endif
   58 counting @ < if
    ghost-color endif
   59 counting @ < if
    ghost-white endif
   60 counting @ < if
    ghost-color
    1 hunt ! endif
  endif
; 


( Chomp.f )
: put-cherry
  100 choose 0= if
   cherry sprite-put
   [udg] U xy-pos@ maze!
  endif ;
\

: key-decode ( c1 -- c2 )
  case
  key+up of key-up endof
  key+down of key-down endof
  key+left of key-left endof
  key+right of key-right endof
  dup
  endcase ;



( Chomp.f )
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


( Chomp.f )
: move-four-ghosts
  4 0 do
    i sprite# xy-pos@ xy-pre!
    23672 @ 1 and hunt @ - 1- if
  \   ghost-decision
      sprite@ dir c@
      ghost-move then
    sprite-put
    xy-pos@ maze@
    sprite@ maze c!
    catch? if catch! then
  loop
; 


( Chomp.f )
: dashboard
  0  1 at.
  6 16 emitc emitc \ yellow
  [udg] P emitc
  7 16 emitc emitc \ white
  bl emitc lives ?
  0  6 at. ." score "
  score 2@
  <# # # # # # # #> type
;


( Chomp.f )
needs .s
: debug
  2 24 at. 6 16 emitc emitc
  pacman xy-pos@ swap . .
  3 24 at. LASTK c@ .
\ 22 1 at. hex sprite 8 +
\ sprite@ (dmp) decimal
  5 24 at. total 2@ D.
  7 24 at. counting @ .
  9 24 at.
  sprite@ maze c@ emitc
  0 0 at. .s
  11 24 at. hunt @ .
\ 22 22 at. ." KEY" key drop
; 


( Chomp.f )
: heart-beat
  move-pacman
  move-four-ghosts
  put-cherry
  count-down
  dashboard
\ debug
;

\ debug
: T heart-beat ;
: C catch? . ;
: M init-display ;


( Chomp.f )
: phase-complete
  score 2@ total 2@ d= if
   180  total D+!
   init-all
   set-maze-run
   interlude
   init-display
   key-right LASTK c!
  endif ;


( Chomp.f )
: run-game
  begin
   lives @
  while
   heart-beat
   phase-complete
   ?terminal if quit then
  repeat
;


( Ghost.f )
: game
  LAYER11 1 SPEED! 30 emitc 8 emitc
  3 lives !
  0 paper. 0 border. 4 ink.
  1 bright. perm
  interlude
  180. total 2!
  0.   score 2!
  init-all
  set-maze-run
  init-display
  run-game
  22 0 at.
  LAYER12 3 SPEED!
; 


( Ghost.f )
CR CR
.( Use GAME to start game. ) CR
.( Arrorw keys to move. ) CR
.( Cursor Joystick should work. ) CR
.( BREAK stops: give LAYER12 to pass to 64 columns. ) CR

