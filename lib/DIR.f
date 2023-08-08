\
\ dir.f
\
.( DIR )

BASE @ DECIMAL

: DIR ( -- cccc )
     NOOP
;

NEEDS ?ESCAPE

\
\ emit a date given a MSDOS format date number
HEX
: .FAT-DATE ( n -- )
    ?dup if
        <#  dup 1F and  0 # # 2D hold  2drop \ day
            5 rshift
            dup 0F and  0 # # 2D hold  2drop \ month
            4 rshift
            7BC + 0 # # # #  \ year
         #> type
    else 
        0A spaces       
    then 
;

\
\ emit a time given a MSDOS format time number
HEX
: .FAT-TIME ( n -- )
    ?dup if
        <# \ dup 1F and 2* 0 # # 3A hold  2drop  \ seconds
            5 rshift  
            dup 3F and    0 # # 3A hold  2drop  \ minutes
            6 rshift
            0 # #  \ hours
         #> type
    else  
      \ 8 spaces     
        5 spaces     
    then 
;
\
\ emit filename
: .FILENAME ( a1 -- a2 )
    begin  
        DUP C@ ?DUP 
    while 
        emitc 1+ 
    repeat  
    dup pad - 30 >
    if
        CR
    then
    6 emit                        \ emit tab
;


DECIMAL
\
\ given a z-string address in PAD, emit the directory content
: DIR-PAD  ( --  )
    PAD
    CR
    BASE @ >R                           \ save current base
    f_opendir 43 ?error >R              \ keep filehandle in R@
    begin
        ?escape if
            1
        else
            HERE                        \ use HERE as temp area
            PAD                         \ wildcard ignored
            R@  f_readdir  46 ?error
        then
        ?TERMINAL NOT 
        AND
    while
        ?escape not if
            HERE      DUP C@ >R         \ keep attribute byte
            1+        .filename space
            1+        DUP @  >R         \ keep time
            cell+     DUP @             \ keep date
            DECIMAL                   
            .fat-date space space R>
            .fat-time space space R>
            16 AND if
                [char] d emit
            else
                cell+ DUP 2@ swap           \ keep size
                9 d.r 
            then 
            DROP
            CR
        then
    repeat
    R>  F_CLOSE DROP
    R>  BASE !
;

\
: DIR-CCCC ( -- cccc )
    PAD C/L BLANK
    67 ALLOT                        \               
    0 C, HERE                       \ a1            -- now HERE is PAD
    [ CHAR C ] LITERAL C,           \ a1            -- start with C:
    BL WORD DUP C@ 1+ ALLOT         \ a1 a3         -- append cccc
    >R                              \ a1     R: a3  
    0 C,                            \ a1            -- append 0x00
    1- HERE OVER - OVER C!          \ a0            -- fix length byte
    [CHAR] : R> C!                  \ a0     R:     -- put : after C
    HERE - 67 - ALLOT
     DIR-PAD
;

\ this allows FORGET DIR to remove this whole package

' DIR-CCCC ' DIR >BODY !

BASE !
