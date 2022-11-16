\
\ help.f
\
NEEDS INVV 
NEEDS TRUV
NEEDS S"

.( HELP )

\ given an open fh, print it
: TYPE-FILE ( fh -- )
    >R
    BEGIN
        PAD C/L R@  F_GETLINE
        PAD OVER TYPE CR
        0=
    UNTIL
    R> F_CLOSE DROP
;

\ help files are searched in HELP sub-directory.
  HERE ," help" CONSTANT HDIR


\ create ndom hex    (   \ : ? / * | \ < > "   )
\     3A C,  3F C,  2F C,  2A C,  7C C,  5C C,  3C C,  3E C,  22 C,
create hdom hex    (   : ? / * | \ < > "   )
    char : c,  char ? c,  char / c,  char * c, 
    char | c,  char \ c,  char < c,  char > c,  char " c,
    00     c,

\ create ncdm hex    (   \ _ ^ % & $ _ { } ~   )
\     5F C,  5E C,  25 C,  26 C,  24 C,  5F C,  7B C,  7D C,  7E C,
create hcdm hex    (   _ ^ % & $ _ { } ~  † )
    char _ c,  char ^ c,  char % c,  char & c,  
    char $ c,  char _ c,  char { c,  char } c,  char ~ c,
    86     c,


decimal
: help-ch ( a -- )
    count bounds
    Do
        hcdm hdom 10 i c@ (map) i c!
    Loop
;


\ help
\ Used in the form
\    HELP cccc
\ in ./HELP subdirectory searches for a file cccc.txt
\ that is some help-manual-file of some cccc definition
\ and send it to output
: HELP  ( -- cccc )
    0 C, HERE DUP HDIR COUNT         \ a  a  a2 n
    >R SWAP R@ CMOVE R> ALLOT        \ a  
    BL WORD DUP C@ 1+ ALLOT >R       \ a  a3
    [ CHAR . CHAR t 8 LSHIFT + ] LITERAL ,
    [ CHAR x CHAR t 8 LSHIFT + ] LITERAL , 0 C,
    1- HERE OVER - OVER C!           \ a
\   DUP NEEDS-CH                     \ a
    DUP MAP-FN                       \ a
    [CHAR] / R> C!                   \ a
    DUP COUNT TYPE CR
\   DUP 10 DUMP
    DUP 1+ PAD 1 F_OPEN
    IF
        DROP ." No help file "
    ELSE
        CR TYPE-FILE
    THEN
    HERE - ALLOT
;


