\
\ SCREEN-FROM-FILE.f

needs LINE   needs J
: SCREEN-FROM-FILE  ( n -- cccc )
  open< >R  SCR !
  l/scr 0 do
    1 block c/l 1+  2dup blank
    J  f_getline drop
    1 block I LINE c/l cmove
    update
  loop
  R> f_close
;




