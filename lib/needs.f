
.( NEEDS included ) 
\ check for cccc exists in vocabulary
\ if it doesn't then  INCLUDE  inc/cccc.F

BASE @ DECIMAL

\ temp filename cccc.f as counted string zero-padded
CREATE   NEEDS-W     35 ALLOT   \ 32 + .F + 0x00 = len 35
NEEDS-W 35 ERASE
\ temp complete path+filename
CREATE   NEEDS-FN    40 ALLOT
NEEDS-FN 40 ERASE
\ constant path
CREATE   NEEDS-INC   ," inc/"
CREATE   NEEDS-LIB   ," lib/"


\ Concatenate path at a and filename and include it
\ No error is issued if filename doesn't exist.
DECIMAL
: NEEDS/  ( a -- )             \ a is address of Path passed
    COUNT TUCK                   \ n a n
    NEEDS-FN SWAP CMOVE          \ n       \ Path
    NEEDS-FN +                   \ a1+n    \ concat
    NEEDS-W 1+ SWAP 35 
    CMOVE                        \         \ Filename
    NEEDS-FN                     \ a3
    PAD 1 F_OPEN
    0=
    IF 
        F_INCLUDE
    ELSE 
    \   needs-w count type space
    \   [ 43 ] Literal message 
        DROP
    THEN
;

( map-into )
(   \ : ? / * | \ < > "    )
(   \ _ ^ % & $ _ { } ~   `)

\ create ndom hex    (   \ : ? / * | \ < > "   )
\     3A C,  3F C,  2F C,  2A C,  7C C,  5C C,  3C C,  3E C,  22 C,
CREATE NDOM HEX    (   : ? / * | \ < > "   )
    CHAR : C,  CHAR ? C,  CHAR / C,  CHAR * C, 
    CHAR | C,  CHAR \ C,  CHAR < C,  CHAR > C,  CHAR " C,
    00     C,

\ create ncdm hex    (   \ _ ^ % & $ _ { } ~   )
\     5F C,  5E C,  25 C,  26 C,  24 C,  5F C,  7B C,  7D C,  7E C,
CREATE NCDM HEX    (   _ ^ % & $ _ { } ~   )
    CHAR _ C,  CHAR ^ C,  CHAR % C,  CHAR & C,  
    CHAR $ C,  CHAR _ C,  CHAR { C,  CHAR } C,  CHAR ~ C,
    HEX 00     C,


\ Replace illegal character in filename 
DECIMAL
: MAP-FN ( a -- )
    COUNT BOUNDS
    DO
        NCDM NDOM [ 10 ] LITERAL I C@ (MAP) I C!
    LOOP
;


\ include  "path/cccc.f" if cccc is not defined
\ filename cccc.f is temporary stored at NEEDS-W
DECIMAL 
: NEEDS-F  ( a -- )
    -FIND IF
        DROP 2DROP
    ELSE
        NEEDS-W    [ 35 ] LITERAL  
        ERASE                           \ a
        HERE C@ 1+ HERE OVER            \ a n here n
        NEEDS-W    SWAP CMOVE           \ a n
        NEEDS-W    MAP-FN
        NEEDS-W    +                    \ a a1+n
        [ HEX 662E DECIMAL ] LITERAL    \ a a1+n ".F"
        SWAP !                          \ a
        NEEDS/
    THEN 
;


\ check for cccc exists in vocabulary
\ if it doesn't then  INCLUDE  inc/cccc.f searching in inc subdirectory
\ when file is not found, gives a 2nd chance with  lib/cccc.f
DECIMAL
: NEEDS
    >IN @ DUP
    NEEDS-INC NEEDS-F     \ search in "inc/"
    >IN !                 \ re-feed it
    NEEDS-LIB NEEDS-F     \ 2nd chance at "lib/"
    >IN !                 \ re-feed it
    -FIND IF
        2DROP
    ELSE 
        NEEDS-W COUNT TYPE SPACE
        [ 43 ] LITERAL MESSAGE 
    THEN 
;


BASE !

