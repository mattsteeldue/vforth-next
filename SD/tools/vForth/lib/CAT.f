\
\ cat.f
\
\ CAT directory

0 VARIABLE FH

\ emit a MSDOS format date
HEX
: .FAT-DATE ( n -- )
    <#  dup 1F and  0 # # 2D hold  2drop 5 rshift
        dup 0F and  0 # # 2D hold  2drop 4 rshift
        7BC + 0 # # # #  #> type space ;


\ emit a MSDOS format time
: .FAT-TIME ( n -- )
    <#  dup 1F 2* and  0 # # 3A hold  2drop 5 rshift
        dup 3F    and  0 # # 3A hold  2drop 6 rshift
        0 # #  #> type space ;

DECIMAL
: CAT ( -- cccc )
    bl word count over + 0 swap !
    f_opendir 43 ?error
    FH !
    DECIMAL
    begin
      PAD  0  1+
      FH @
      f_readdir  46 ?error
      ?TERMINAL NOT AND
      while
        PAD
        begin
          DUP C@ ?DUP while emit 1+  \ next address
        repeat 6 emit
        1+        DUP @ >R
        cell+     DUP @ >R
        cell+     2@ SWAP 08 d.r space space
        R> .fat-date space R> .fat-time CR
    repeat
    FH @
    F_CLOSE DROP
;
