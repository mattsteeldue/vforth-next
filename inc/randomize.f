\
\ randomize.f  
\
.( RANDOMIZE )
\
BASE @
\
DECIMAL
\
: RANDOMIZE ( u -- )
    23670           \ a         \ address of "SEED" system variable 
    !               
;

BASE !
\
