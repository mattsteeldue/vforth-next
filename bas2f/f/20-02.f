\ 20-02.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/20-02.txt
\ guide: doc/basic-to-vforth/20-channels-streams-drivers-and-windows.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 OPEN #4,"notes.txt"
\   20 INPUT #4; LINE a$
\   30 RETURN #4 TO p
\   40 INPUT #4; LINE a$: INPUT #4; LINE a$
\   50 GO TO #4,p
\   60 INPUT #4; LINE a$: PRINT p;" ";a$
\   70 CLOSE #4

\ --- words defined earlier in the guide

\ 20-channels-streams-drivers-and-windows.md:26
NEEDS VALUE  NEEDS TO
0 VALUE FH
OPEN< help/rnd.txt TO FH
FH F_CLOSE .                    \ => 0
FH F_CLOSE .                    \ => -1

\ 20-channels-streams-drivers-and-windows.md:72
CREATE CH  0 C,
: GET-CHAR  ( -- c )                \ next byte of FH, -1 at the end
    CH 1 FH F_READ 46 ?ERROR
    IF  CH C@  ELSE  -1  THEN ;
OPEN< help/rnd.txt TO FH
GET-CHAR . GET-CHAR . GET-CHAR .    \ => 32 32 32
GET-CHAR . GET-CHAR EMIT            \ => 32 R

\ 20-channels-streams-drivers-and-windows.md:91
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

\ --- the translation

\ 20-channels-streams-drivers-and-windows.md:259
NEEDS 2VARIABLE
2VARIABLE SPOT
OPEN< help/rnd.txt TO FH
LINEBUF 80 GET-LINE 2DROP  LINEBUF 80 GET-LINE 2DROP
FH F_FGETPOS DROP SPOT 2!
SPOT 2@ D.                      \ => 18
LINEBUF 80 GET-LINE 2DROP  LINEBUF 80 GET-LINE 2DROP
SPOT 2@ FH F_SEEK .             \ => 0
LINEBUF 80 GET-LINE . .         \ => -1 38
LINEBUF 38 TYPE                 \ => Returns a pseudo-random number
FH F_CLOSE DROP
