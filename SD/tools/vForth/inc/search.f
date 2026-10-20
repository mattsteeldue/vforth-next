\
\ search.f
\
.( SEARCH )
\
\ Search the string a1 n1 for the string a2 n2. If it is found, f is
\ true and a3 n3 is the rest of a1 n1 starting at the first match;
\ if not, f is false and a3 n3 is a1 n1 itself.
\ An empty a2 n2 is found at once. Like COMPARE it relies on the core
\ word (COMPARE): at start-up case is ignored, CASEON makes it count.
\ Forth-2012 String word set (17.6.1.2191).
\
NEEDS /STRING

: SEARCH  ( a1 n1 a2 n2 -- a3 n3 f )
    2OVER 2SWAP                         \ a1 n1  a n  a2 n2
    BEGIN
        2OVER NIP OVER U< 0=            \ room left for a2 n2 ?
        IF                              \ a n a2 n2 -- a n a2 n2 b
            2OVER DROP >R 2DUP R> -ROT (COMPARE)
        ELSE  0  THEN
    WHILE                               \ room left, no match here
        2SWAP 1 /STRING 2SWAP
    REPEAT
    NIP OVER SWAP U< 0=                 \ a1 n1  a n  f
    IF  2SWAP 2DROP -1  ELSE  2DROP 0  THEN
;

