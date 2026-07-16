\
\ help.f
\

.( HELP )

BASE @ DECIMAL

NEEDS VIEW-FILE-PAD

\ help files are searched in HELP sub-directory.
  HERE ," help" CONSTANT HELP-DIR

\ help

\ Used in the form
\    HELP cccc
\ It searches for a file cccc.txt in ./HELP subdirectory 
\ that provides some help-manual-file of some cccc definition
\ and send it to output

: HELP  ( -- cccc )
    68 ALLOT HERE                   \ a1            -- string start (= PAD at exit)
    HELP-DIR COUNT DUP ALLOT >R     \ a1 a2         -- room for "help"
    OVER R> CMOVE                   \ a1            -- copy "help" to HERE
    BL WORD DUP MAP-FN              \ a1 a3         -- parse cccc, map illegal chr
    DUP C@ 1+ ALLOT                 \ a1 a3         -- append cccc
    [ CHAR . CHAR t 8 LSHIFT + ] LITERAL ,
    [ CHAR x CHAR t 8 LSHIFT + ] LITERAL ,
    0 C,                            \ a1 a3         -- append ".txt" and 0x00
    [CHAR] / SWAP C!                \ a1            -- put / over count byte
    HERE - 68 - ALLOT               \               -- release scratch, HERE restored
    VIEW-FILE-PAD
;

BASE !

