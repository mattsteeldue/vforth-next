\
\ SCREEN-TO-FILE.f
\
needs LINE   needs J
: SCREEN-TO-FILE  ( n -- cccc )
  scr ! bl word count over + 0 over c! 1+
  [ 2 4 + ] literal f_open #47 ?error >R
  $0A    here  c!
  l/scr 0 do
    I line c/l -trailing  J f_write 2drop
    here 1  J f_write 2drop
  loop
  here 1 R@ f_write 2drop
  R> f_close
;


