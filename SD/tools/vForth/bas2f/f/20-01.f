\ 20-01.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/20-01.txt
\ guide: doc/basic-to-vforth/20-channels-streams-drivers-and-windows.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 OPEN #4,"o>notes.txt"
\   20 FOR i=1 TO 3
\   30 PRINT #4;"Line ";i
\   40 NEXT i
\   50 CLOSE #4
\   60 OPEN #4,"notes.txt"
\   70 FOR i=1 TO 3
\   80 INPUT #4; LINE a$: PRINT a$
\   90 NEXT i
\   100 CLOSE #4

\ --- words defined earlier in the guide

\ 20-channels-streams-drivers-and-windows.md:26
NEEDS VALUE  NEEDS TO
0 VALUE FH
OPEN< help/rnd.txt TO FH
FH F_CLOSE .                    \ => 0
FH F_CLOSE .                    \ => -1

\ 20-channels-streams-drivers-and-windows.md:81
CREATE CH  0 C,
: GET-CHAR  ( -- c )                \ next byte of FH, -1 at the end
    CH 1 FH F_READ 46 ?ERROR
    IF  CH C@  ELSE  -1  THEN ;
OPEN< help/rnd.txt TO FH
GET-CHAR . GET-CHAR . GET-CHAR .    \ => 32 32 32
GET-CHAR . GET-CHAR EMIT            \ => 32 R

\ 20-channels-streams-drivers-and-windows.md:100
VARIABLE LASTC                      \ the byte read before
: NEXT-CHAR  ( -- c )               \ GET-CHAR, a LF after a CR skipped
    GET-CHAR  DUP 10 =  LASTC @ 13 = AND
    IF  DROP GET-CHAR  THEN  DUP LASTC ! ;
: EOL?  ( c -- f )   DUP 13 =  OVER 10 = OR  SWAP 0< OR ;
: GET-LINE  ( a max -- n f )        \ the next line of FH into a
    >R 0
    BEGIN  NEXT-CHAR  DUP EOL? 0=
    WHILE  OVER R@ <
        IF  >R 2DUP + R> SWAP C!  1+  ELSE  DROP  THEN
    REPEAT
    R> DROP  0< 0=  OVER 0= 0= OR  ROT DROP ;
CREATE LINEBUF 80 ALLOT
LINEBUF 80 GET-LINE . .         \ => -1 11
LINEBUF 11 TYPE                 \ => ND  u -- u2
LINEBUF 80 GET-LINE . .         \ => -1 0

\ 20-channels-streams-drivers-and-windows.md:124
: TYPE-LINES  ( -- )                \ print every line of FH
    BEGIN  LINEBUF 80 GET-LINE
    WHILE  LINEBUF SWAP TYPE CR
    REPEAT  DROP ;
FH F_CLOSE DROP
OPEN< help/rnd.txt TO FH
TYPE-LINES
\ output of the last line:
\     RND  u -- u2
\
\ Returns a pseudo-random number between
\ 0 and u-1, with the 48K BASIC formula
\ and its SEED system variable (23670).
\ NextBASIC RND now uses another formula:
\ same seed, other numbers.
\ See RANDOMIZE to set the seed.
\
\ Available after NEEDS RND

\ --- the translation

\ 20-channels-streams-drivers-and-windows.md:227
\ no-test in the guide: it waits for keys, never ends or
\ needs hardware the emulator lacks
NEEDS OPEN>  NEEDS S"
: PUT  ( a n -- )   FH F_WRITE 47 ?ERROR DROP ;
: NOTES  ( -- )
    4 1 DO
        S" Line " PUT
        I 0 <# #S #> PUT  13 CH C!  CH 1 PUT
    LOOP ;
OPEN> notes.txt TO FH  NOTES  FH F_CLOSE .
OPEN< notes.txt TO FH  TYPE-LINES  FH F_CLOSE .
\ output of the last line:
\ Line 1
\ Line 2
\ Line 3
\ 0
