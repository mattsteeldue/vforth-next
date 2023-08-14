\
\ editor.f
\
.( EDITOR ) 
\

NEEDS TEXT      ( c -- )     \ accept following text to PAD
NEEDS LINE      ( n -- a )   \ address of current screen line n
NEEDS -MOVE     ( a n -- )   \ move from a to current screen line n

VOCABULARY EDITOR IMMEDIATE

EDITOR DEFINITIONS

\
\ Quick reference of Line - EDITOR words
\ [ TIB ]  <->  [ PAD ]  <->   [BLOCK]
\          TEXT        H  E  RE
\                      D  S  INS
\


: H ( n -- )        \ hold line n to PAD
    LINE            \ a
    PAD 1+ C/L CMOVE 
    C/L PAD C!
;

: E ( n -- )        \ blank line n of current screen
    LINE C/L BLANK 
    UPDATE 
;

: S ( n -- )        \ shift lines >= n down by one
    DUP 1 MAX L/SCR 1- 
    DO  
        I 1- LINE  
        I -MOVE  
    -1 +LOOP 
    E 
;

: RE ( n -- )       \ replace line n using PAD content
    PAD 1+          \ n a
    SWAP            \ a n
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

: NN ( -- )         \ index next 20 screens
    SCR @ 20 SCR +!
    SCR @ INDEX
;

: BB ( -- )         \ index PREVIOUS 20 screens
    SCR @ 40 - 
    DUP 1 < IF DROP 1 THEN
    SCR ! NN
;
