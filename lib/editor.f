\
\ editor.f
\
.( EDITOR vocabulary ) 
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

: RE ( n -- )       \ replace line n using PAD content
    PAD 1+          \ n a
    SWAP            \ a n
    -MOVE 
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

: S ( n -- )        \ shift lines >= n down by one
    L/SCR 1-        \ n max
    BEGIN
        2DUP <      \ n max  n<max
    WHILE           \ n max
        DUP 1- H    
        DUP RE      
        1-          \ n max-i
    REPEAT
    DROP            \ n
    E 
;

: INS ( n -- )      \ insert line n from PAD
    DUP S RE 
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

