\
\ (to).f
\
." (TO) "
\
\ Primitive definition used by  TO  and  +TO
\ It shouldn't be used directly.
\ At compile-time it compiles a literal pointer to cccc's PFA
\ followed by the xt passed so that later...
\ at run-time the literal is used by the xt word to alter cccc in some way
\ cccc was created via VALUE.
\ In interactive mode, passed xt is simply executed acting on cccc's PFA.
\
: (TO) ( xt -- cccc ) \ at compile-time
       ( xt --      ) \ when interactive
    ' >BODY 
    STATE @
    IF
        COMPILE LIT 
        COMPILE,    \ compile  body address
        COMPILE,    \ compiles xt ! or +!
    ELSE
        SWAP EXECUTE 
    ENDIF
;


