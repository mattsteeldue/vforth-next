\
\ Egyptian.f

\ Egyptian Code Puzzle
\ Based on Michael Adler's puzzle https://groups.io/g/forth-sinclair/message/123

\ use base 10
decimal 

\ first number, six bytes to handle carry on fifth
variable top-row  6  allot

\ second number
variable bottom-row  6  allot

\ table to keep ten counter, one for each digit (0-9)
variable digit-table 10 allot

\ mark digit n "used" by incrementing the counter in above digit-table
\ ( n must be between 0 and 9)
: use-digit ( n -- )
    >R
    R@ digit-table + c@
    1+
    R> digit-table + c!
;   

\ return true flag if each digit is used no more than once.
: ?used-once ( -- f )
    0 \ flag
    10 0 do
        i digit-table + c@
        1 > or
    loop 
    0=   
;

\ use standard number formatting to convert to five bytes
\ a double precision integer and move these five bytes 
\ to the address passed
: represent     ( d a -- )
    1+ >R                  \ d
    decimal
    <# # # # # # #>        \ a2 u
    R@ swap                \ a2 a u
    cmove
    \ correct ascii to binary in place
    R@ 5 + R> do
        i c@ [char] 0 - i c!
    loop
;

\ display number whose digits are at address a
: display-number ( a -- )
    1+
    dup 5 + swap    \ a+5  a 
    do
        i c@ 1 .R
    loop
;

\ a is address of lowest significant byte
\ checks if it's greater than 9 so it
\ propagate the carry to the higer byte
\ repeating the carry process up to fifth byte.
: handle-carry ( a -- )
    begin             
        dup c@ 9 > 
    while
        dup c@ 10 - over c! 
        1-  \ point to previous byte
        dup c@ 1+   over c! 
    repeat
;

\ add 3 to number at address
: add-3-to ( a -- )
    5 +           
    dup c@ 3 + over c! 
    handle-carry
    drop
;

\ add 3 to number at address
: add-1-to ( a -- )
    5 +           
    dup c@ 1+ over c! 
    handle-carry
    drop
;

\ verify first number is legal
: scan-first-number
    6 1 do
        i top-row + c@ use-digit
    loop
;

\ verify second number is legal
: scan-second-number
    6 1 do
        i bottom-row + c@ use-digit
    loop
;

\ verify two numbers stored at "top-row" and "bottom-row" 
\ is a solution.
: ?egyptian-code ( -- f )
    0       \ initial false flag
    \ reset digit counting
    digit-table 10 erase    
    \ verify first number is legal
    scan-first-number 
    ?used-once 
    if
        \ verify second number has "3" in proper position
        2 bottom-row + c@
        3 = 
        if
            \ verify second number is legal
            scan-second-number
            ?used-once 
            if
                1-      \ change to true flag
            then
        then
    then
;


\ main
: egypt
    \
    29877   \ finish 
    12345   \ start
    \
    \ initialize two numbers 12345 and 3*12345
    dup   s>d top-row    represent
    dup 3 um* bottom-row represent
    \ 
    do
        ?egyptian-code 
        if
            \ emit result
            top-row    display-number space
            bottom-row display-number cr
        then            
        \ compute next 
        top-row    add-1-to
        bottom-row add-3-to
    loop
    ." No more solutions." cr
;

