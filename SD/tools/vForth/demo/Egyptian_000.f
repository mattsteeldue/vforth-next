\
\ Egyptian Code
\

: J ( -- n )
    RP@ [ 6 ] LITERAL + @ 
;

\ string of first number
variable str  5  allot

\ check no digit is repeated in first number
: str-check  ( -- f )
  0                           \  f
  5 0 do                      \  f
    5 i 1+ ?do                \  f
      str i + c@              \  f c
      str j + c@ = or         \  f
    loop
  loop
;

\ string of second number
variable mul  5  allot

\ check no digit is repeated in second number
: mul-check  ( -- f )
  0                           \  f
  5 0 do                      \  f
    5 i 1+ ?do                \  f
      mul i + c@              \  f c
      mul j + c@ = or         \  f
    loop
  loop
;

\ check no digit is repeated across the
\ two number
\ return non-zero (true-flaag) if repetion is detected
: cross-check  ( -- f )
  0                           \ ff
  5 0 do  \ first number
    5 0 do  \ second number
      str j + c@
      mul i + c@ = or
    loop
  loop
;

\ use standard number formatting to convert to string
\ a double precision integer and move the string away 
\ to the address passed
\
: represent     ( d a -- )
  decimal
  >R                     \ d
  <# # # # # # #>        \ a2 u
  R> swap                \ a2 a u
  cmove
;

( Egyptian code )
: egypt
  \ loop all integers between 12345 and 32456
  23987 12345 do
    \ convert double-integer to string at str address
    i 0 str represent
    \ check no digit is repeated str
    str-check not if
      \ check last digit of first number isn't 0 or 1
      str 4 + c@  
      dup  [char] 0 =
      swap [char] 1 =
      or not if
        \ multiply by 3 and convert to string at mul address 
        i 3 um*  mul represent
        \ check digit 3 in second position
        mul 1+ c@  [char] 3  = if
          \ check no digit is repeated in mul
          mul-check  0=  if
            \ cross-check between the two strings str and mul
            cross-check  0=  if
              \ print the found solution
              str 5 type space ." -> "
              mul 5 type cr
            then
          then
        then
      then
    then
  loop 
  ." No more solutions." cr
;
