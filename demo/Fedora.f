\
\ Patrick Kaell's Fedora
\
needs J
needs GRAPHICS
needs SQRT

marker task

\ array indexed by integer "deg" between 0 and 90
\ with the value of sin(deg) scaled /10000 for 
\ maximum precision with 16 bits integers.
CREATE sin-table
    00000 , 00175 , 00349 , 00523 , 00698 , 00872 , 01045 ,
    01219 , 01392 , 01564 , 01736 , 01908 , 02079 , 02250 ,
    02419 , 02588 , 02756 , 02924 , 03090 , 03256 , 03420 ,
    03584 , 03746 , 03907 , 04067 , 04226 , 04384 , 04540 ,
    04695 , 04848 , 05000 , 05150 , 05299 , 05446 , 05592 ,
    05736 , 05878 , 06018 , 06157 , 06293 , 06428 , 06561 ,
    06691 , 06820 , 06947 , 07071 , 07193 , 07314 , 07431 ,
    07547 , 07660 , 07771 , 07880 , 07986 , 08090 , 08192 ,
    08290 , 08387 , 08480 , 08572 , 08660 , 08746 , 08829 ,
    08910 , 08988 , 09063 , 09135 , 09205 , 09272 , 09336 ,
    09397 , 09455 , 09511 , 09563 , 09613 , 09659 , 09703 ,
    09744 , 09781 , 09816 , 09848 , 09877 , 09903 , 09925 ,
    09945 , 09962 , 09976 , 09986 , 09994 , 09998 , 10000 ,


: SIN ( n1 -- n2 )
    180 /mod >R dup >R abs              \ |q|         R: r q
    dup 90 >                            \ |q|  f        
    if 180 swap - then                  \ |q|  or  pi-|q|
    2* sin-table + @                    \ |sin|   
    R> +-                               \ |sin| with sign of q
    R> 1 and if negate then             \ sin   with quadrant
;

20736 CONSTANT 20736
27192 CONSTANT 27192
10000 CONSTANT 10000
16384 CONSTANT 16384
   56 CONSTANT    56
    5 CONSTANT     5
   -2 CONSTANT    -2

CREATE RR 642 ALLOT

0 VALUE ZS 
0 VALUE XL 
0 VALUE XT 
0 VALUE YY 
0 VALUE X1 
0 VALUE Y1 

160 VALUE DX 
140 VALUE DY

: FEDORA ( -- ) 

    642 0 DO
        1000 RR I + !
    2 +LOOP
  
    -64 64  DO
        I DUP * 81 16 */ TO ZS 
        20736 ZS - SQRT TO XL 
        XL 1+ XL NEGATE DO
            I DUP * ZS + SQRT 27192 16384 */ TO XT
            XT SIN XT 3 * SIN 2 5 */ + 56 10000 */ TO YY
            DX   I   +  J +  TO X1 
            DY  YY   -  J +  TO Y1 
            X1 0 < NOT  IF
                RR X1 2* + @ Y1  >  IF
                    Y1 RR X1 2* + ! 
                    Y1  2/ 
                    X1   
                    PLOT
                THEN
            THEN
        LOOP
        ?terminal if leave then
    -2 +LOOP
;
