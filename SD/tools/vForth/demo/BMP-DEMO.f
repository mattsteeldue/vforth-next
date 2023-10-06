\ 
\ BMP-DEMO.f
\
\ 

NEEDS BMP-LOAD
NEEDS LAYER2
NEEDS LAYER12


23672 CONSTANT FRAMES

: DELAY ( -- )
    0 FRAMES !
    FRAMES @ 100 + 
    BEGIN
        DUP FRAMES @ U< 
        ?TERMINAL OR
    UNTIL      
    DROP
;

: BMP-DEMO
    LAYER2
    BMP-LOAD" /demos/bmp256converts/bitmaps/critters.bmp"  DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/diehard.bmp"   DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/et.bmp"        DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/et2.bmp"       DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/freddy.bmp"    DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/friday.bmp"    DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/future.bmp"    DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/indian.bmp"    DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/jaws.bmp"      DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/krull.bmp"     DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/rocky.bmp"     DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/teenwolf.bmp"  DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/term.bmp"      DELAY
    BMP-LOAD" /demos/bmp256converts/bitmaps/trouble.bmp"   DELAY
    LAYER12
;

BMP-DEMO

