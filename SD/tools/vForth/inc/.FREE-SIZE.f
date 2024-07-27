\
\ .FREE-SIZE.f
\
\ display free space available on default drive expressed in G, M or K 
\ depending on which is better fit, with one decimal precision digit.

BASE @

.( .)  \ show progression

NEEDS F_GETFREE \

.( .)  \ show progression

DECIMAL 

\ Given a double-precision integer representing free space / 512 bytes
\ emit the best fit for scale unit G, M or K
\ It returns a character G, M or K for later processing
: D.GMK ( d -- c )
  ?dup if             \ high part is non-zero, result is greater than 32M
    dup 29 > if       \ high part > 29, result is at least 1.0 G 
      nip 3 /         \ this approximates: 512*d / 1G (scaled x 10)
      0   [char] G    \ use G unit
    else              \ high part <= 29, result is less than 1.0 G 
      200 um/mod nip  \ this approximates: 512*d / 1M (scaled x 10)
      0   [char] M    \ use M unit
    then              \
  else                \ high part is zero, result is less than 32M
    5 um* over        \ this approximates: d / 2  (scaled x 10)
    9996 swap u<      \ compare against 999.6 (scaled x 10)
    if                \ to see if it stays below 1.0 M
      1024 um/mod nip \ then compute 512*d / 1M (scaled x 10) 
      0   [char] M    \ use M unit
    else              \ 
      [char] K        \ use K unit
    then              \ 
  then >R             \
  <# # [char] . hold #s #> 
  type R>             \ emit quantity
;

.( .)  \ show progression

\ display free space on default drive with one place after the decimal-point
\ expressed in G, M or K depending on which is better fit.
: .FREE-SIZE ( -- ) \
  [CHAR] * F_GETFREE 
  IF                    \ zero means error
    2DROP               \ so discard result
  ELSE                  \ d is the number of 512-bytes-blocks free on drive
    D.GMK 
    SPACE 
    EMIT                \ emit unit
  THEN 
; 
\
\ wipe progression-bar 
8 DUP DUP EMITC EMITC EMITC \ hide progression
\
BASE ! \
