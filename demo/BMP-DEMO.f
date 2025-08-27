\ 
\ BMP-DEMO.f
\
\ 

NEEDS BMP-LOAD
NEEDS LAYER2
NEEDS LAYER12
NEEDS TO

23672 CONSTANT FRAMES

\ Set L2-RAM-PAGE constant to indicate Layer 2 RAM default 
: LOAD-TO-9
     9  TO L2-RAM-PAGE
;

\ Set L2-RAM-PAGE constant to indicate Layer 2 RAM Shadow
: LOAD-TO-C
    #12 TO L2-RAM-PAGE
;

\ Layer 2 RAM point PAGE #9
: SHOW-TO-9
     9  $12 REG!
;

\ Layer 2 RAM point PAGE #12
: SHOW-TO-C
    #12 $12 REG!
;



\ waits two seconds before changing image
: DELAY ( -- )
    0 FRAMES !
    FRAMES @ 100 + 
    BEGIN
        DUP FRAMES @ U< 
        ?TERMINAL OR \ IF QUIT THEN
    UNTIL      
    DROP
;


: BMP-DEMO
    LAYER12 1 #17 EMITC EMITC \ set black-on-white
    LAYER2 CLS
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/critters.bmp"  SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/diehard.bmp"   SHOW-TO-9  DELAY 
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/et.bmp"        SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/et2.bmp"       SHOW-TO-9  DELAY 
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/freddy.bmp"    SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/friday.bmp"    SHOW-TO-9  DELAY 
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/future.bmp"    SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/indian.bmp"    SHOW-TO-9  DELAY 
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/jaws.bmp"      SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/krull.bmp"     SHOW-TO-9  DELAY 
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/rocky.bmp"     SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/teenwolf.bmp"  SHOW-TO-9  DELAY 
    LOAD-TO-C  BMP-LOAD" /tools/vforth/demo/bmp/term.bmp"      SHOW-TO-C  DELAY 
    LOAD-TO-9  BMP-LOAD" /tools/vforth/demo/bmp/trouble.bmp"   SHOW-TO-9  DELAY 
    CLS LAYER12
;

BMP-DEMO

