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
    67 ALLOT                        \               -- this will be PAD
    0 C, HERE DUP HELP-DIR COUNT    \ a1 a1 a2 n    -- room for lenght byte
    DUP ALLOT >R                    \ a1 a1 a2      -- room for "help"
    SWAP R> CMOVE                   \ a1            -- copy "help" to HERE
    BL WORD DUP C@ 1+ ALLOT         \ a1 a3         -- append cccc
    >R                              \ a1     R: a3  -- append ".txt" and 0x00
    [ CHAR . CHAR t 8 LSHIFT + ] LITERAL ,              
    [ CHAR x CHAR t 8 LSHIFT + ] LITERAL , 
    0 C,
    1- HERE OVER - OVER C!          \ a0            -- fix length byte
    DUP MAP-FN                      \ a0            -- replace illegal chr
    [CHAR] / R> C!                  \ a0     R:     -- put / after help
    HERE - 67 - ALLOT
    VIEW-FILE-PAD
;

BASE !

