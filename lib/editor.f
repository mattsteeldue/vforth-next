\
\ editor.f
\
.( EDITOR vocabulary ) 
\

NEEDS TEXT
NEEDS LINE
NEEDS -MOVE

VOCABULARY EDITOR IMMEDIATE

EDITOR DEFINITIONS

\
\ Quick reference of Line - EDITOR words
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\


: H ( n -- )        \ hold line n to PAD
    LINE 
    PAD 1+ 
    C/L 
    DUP PAD C! 
    CMOVE 
;

: E ( n -- )        \ blank line n of current screen
    LINE C/L BLANKS 
    UPDATE 
;

: S ( n -- )        \ shift lines >= n down by one
    DUP  L/SCR 1- 
    DO  
        I 1- LINE  
        I -MOVE  
    -1 +LOOP 
    E 
;

: RE ( n -- )       \ replace line n using PAD content
    PAD 1+ SWAP 
    -MOVE 
;

: INS ( n -- )      \ insert line n from PAD
    DUP S RE 
;

: D ( n -- )        \ remove line n from current screen
    DUP H 
    L/SCR 1- DUP ROT 
    ?DO 
        I 1+ LINE 
        I -MOVE 
    LOOP 
    E 
;

: P ( n -- )        \ put line n reading input until ~ which is an EOT
    [CHAR] ~ TEXT RE 
;

FORTH DEFINITIONS

: L ( -- )          \ list current screen
    SCR @ LIST 
;

: N ( -- )          \ list next screen
    1 SCR +! L 
;

: B ( -- )          \ list previous (back) screen
    -1 SCR +! L 
;

