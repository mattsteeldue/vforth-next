\
\ cat.f
\
.( CAT directory )

0 VARIABLE FH
\
\ emit a date given a MSDOS format date number
HEX
: .FAT-DATE ( n -- )
  ?dup if
    <#  dup 1F and  0 # # 2D hold  2drop 5 rshift
        dup 0F and  0 # # 2D hold  2drop 4 rshift
        7BC + 0 # # # #  #> type
  else  0A spaces       endif ;
\
\ emit a time given a MSDOS format time number
: .FAT-TIME ( n -- )
  ?dup if
    <#  dup 1F 2* and  0 # # 3A hold  2drop 5 rshift
        dup 3F    and  0 # # 3A hold  2drop 6 rshift
        0 # #  #> type
  else   8 spaces     endif ;
\
DECIMAL
\
\ given a z-string address, emit the directory content
: CAT  ( a --  )
    f_opendir 43 ?error
    FH !
    DECIMAL                   \ save current base
    begin
      PAD                          \ use PAD as temp area
      0 1+                         \ use no wildcard
      FH @  f_readdir  46 ?error
      ?TERMINAL NOT AND
      while
        PAD DUP C@       >R        \ keep attribute byte
        1+ begin  DUP C@ ?DUP while emit 1+ repeat \ emit filename
        dup pad - 30 >
        if
          13 emit                    \ emit cr if name is too long
        endif
        6 emit                     \ emit tab
        1+        DUP @ >R         \ keep time
        cell+     DUP @            \ keep date
        .fat-date space R>
        .fat-time space R>
        16 AND if
          [char] d emit
        else
        cell+ 2@ swap              \ keep size
        9 d.r endif CR
    repeat
    DROP  \ working  PAD addres
    FH @  F_CLOSE DROP
    DECIMAL
;

\
: CAT"
    CR
    [char] "  word count over + 0 swap !      \ get a string
    cat
;
