\ 17-03c.f -- the Forth side of a NextBASIC listing
\ BASIC: bas2f/txt/17-03.txt
\ guide: doc/basic-to-vforth/17-time-and-motion.md
\ written by util/guide-forth.py: edit the guide, not this file
\
\   10 GO TO 100
\   20 FOR i=1 TO 16: FOR c=1 TO 16: FOR n=1 TO 6
\   30 IF r$(i,c)=k$(n) THEN OUT 91,v(n)
\   40 NEXT n: NEXT c: NEXT i: RETURN
\   100 DIM r$(16,16): DIM v(6): LET k$="_hokst"
\   110 FOR i=1 TO 6: READ v(i): NEXT i
\   120 FOR i=1 TO 16: READ r$(i): NEXT i
\   130 OUT 12347,0: GO SUB 20
\   140 FOR j=1 TO 7: READ i: READ r$(i): NEXT j
\   150 OUT 12347,1: GO SUB 20
\   200 SPRITE PRINT 1
\   210 FOR %x=32 TO 288 STEP 2
\   220 SPRITE 0,%x,128,%x/8&1,1
\   230 PAUSE 2
\   240 NEXT %x
\   250 SPRITE 0,0,0,0,0
\   300 DATA 227,136,246,0,224,3
\   310 DATA "______hhhh______","_____hhhhhh_____"
\   320 DATA "_____hoooo______","_____ooook______"
\   330 DATA "_____ooooooo____","______oooo______"
\   340 DATA "_____sssssss____","____sssssssss___"
\   350 DATA "___ss_sssss_ss__","__o___sssss___o_"
\   360 DATA "______ttttt_____","_____ttt_ttt____"
\   370 DATA "_____ttt__ttt___","___ttt_____ttt__"
\   380 DATA "_kkk________kkk_","________________"
\   400 DATA 8,"_____sssssss____",9,"_____sssssss____"
\   410 DATA 10,"______sssss_____",12,"_______ttt______"
\   420 DATA 13,"_______ttt______",14,"_______ttt______"
\   430 DATA 15,"_______kkkkk____"

\ --- the translation

\ 17-time-and-motion.md:488
: HIT?  ( x1 y1 x2 y2 -- flag )
    ROT - ABS 16 < >R  - ABS 16 < R> AND ;
10 10 20 25 HIT? .              \ => -1
10 10 30 10 HIT? .              \ => 0
