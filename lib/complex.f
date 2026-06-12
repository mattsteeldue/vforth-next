\
\ complex.f
\ ______________________________________________________________________ 
\
\ v-Forth 1.8 - NextZXOS version - build 2026-04-19
\ MIT License (c) 1990-2026 Matteo Vitturi     
\ ______________________________________________________________________ 
\
\ Complex numbers arithmetics as pairs on stack: ( module angle )
\ Angle is on top of stack, Module is the second element from top.  
\ This lib relies on Fixed-point 8.8 arithmetic library for vForth (16-bit cells)
\ Signed Q8.8 format: 8 integer bits, 8 fractional bits (range -128.0 to +127.996)

MARKER COMPLEX

NEEDS FIXED88


\ --- COMPLEX NUMBER CREATION ---

: C-ZERO   ( -- mag ang )
  \ Complex zero: magnitude=0, angle=0
  0 0 ;

: C-ONE   ( -- mag ang )
  \ Complex one: magnitude=1, angle=0
  FP-1.0 0 ;

: C-I   ( -- mag ang )
  \ Complex i: magnitude=1, angle=Pi/2
  FP-1.0  FP-PI/2 ;
    
\ --- COMPLEX ARITHMETIC (POLAR ADVANTAGES) ---

: C*   ( mag1 ang1 mag2 ang2 -- mag3 ang3 )
  \ Multiplication: (r1,ß1) * (r2,ß2) = (r1*r2, ß1+ß2)
  ROT FP+           \ Add angles: ß1 + ß2
  NORMALIZE-ANGLE   \ Keep in [0,2Pi)
  -ROT FP*          \ Multiply magnitudes: r1 * r2
  SWAP ;

: C/   ( mag1 ang1 mag2 ang2 -- mag3 ang3 )
  \ Division: (r1,ß1) / (r2,ß2) = (r1/r2, ß1-ß2)
  NEGATE ROT FP+    \ Subtract angles:  -ß2 + ß1 
  NORMALIZE-ANGLE
  -ROT FP/          \ Divide magnitudes: r1 / r2
  SWAP ;

: C-CONJ   ( mag ang -- mag -ang )
  \ Complex conjugate: (r,ß) --> (r,-ß)
  NEGATE NORMALIZE-ANGLE ;

: C-NEGATE   ( mag ang -- mag ang+Pi )
  \ Negation: (r,ß) --> (r,ß+Pi)
  FP-PI FP+ NORMALIZE-ANGLE ;    

: C-INV   ( mag ang -- mag ang )
  \ Reciprocal: 1/(r,ß) = (1/r,-ß)
  NEGATE NORMALIZE-ANGLE
  SWAP FP-1.0 SWAP FP/ SWAP ;

\ --- POWER OPERATIONS (VERY EFFICIENT IN POLAR) ---

: C-SQUARE   ( mag ang -- mag² ang*2 )
  \ Square: (r,ß)² = (r²,2ß)
  2* NORMALIZE-ANGLE
  SWAP FP-SQUARE SWAP ;

: C-CUBE   ( mag ang -- mag³ ang*3 )
  \ Cube: (r,ß)³ = (r³,3ß)
  3 * NORMALIZE-ANGLE
  SWAP DUP FP* FP* SWAP ;

: C-POW-N   ( mag ang n -- mag^n ang*n )
  \ Integer power: (r,ß)^n = (r^n,nß)
  TUCK                    \ r n ß n
  FP* NORMALIZE-ANGLE     \ Multiply angle by n
  -ROT FP-1.0 SWAP        \ ß*n r 1.0 n 
  0 ?DO                   \ ß*n r 1.0
    OVER FP*              
  LOOP                    \ ß*n r r^n  
  NIP SWAP ;

: C-SQRT   ( mag ang -- sqrt-mag ang/2 )
  \ Square root: sqrt(r,ß) = (sqrt r,ß/2)
  2/ 
  SWAP FP-SQRT SWAP ;

: C-ROOT-N   ( mag ang n -- root-mag ang/n )
  \ Nth root: sqrt(r,ß) = (ªsqrt r,ß/n)
  >R 
  R@ /              \ Divide angle by n
  SWAP 
  \ For magnitude: approximate with repeated square roots
  R> 0 SWAP
  1 DO FP-SQRT LOOP
  SWAP ;

\ --- MAGNITUDE AND PHASE EXTRACTION ---

: C-MAG   ( mag ang -- mag )
  \ Extract magnitude
  DROP ;

: C-ANG   ( mag ang -- ang )
  \ Extract angle
  NIP ;

: C-ABS   ( mag ang -- |mag| )
  \ Absolute value (same as magnitude for polar)
  DROP ABS ;
  
\ --- POLAR TO CARTESIAN CONVERSION ---

: C>XY   ( mag ang-rad -- x y )
  \ Convert polar to cartesian: x = r*cos(ß), y = r*sin(ß)
  2DUP              \ r ß r ß
  FCOS              \ r ß r cosß
  FP*               \ r ß rcosß
  -ROT              \ rcosß r ß 
  FSIN              \ rcosß r sinß 
  FP*               \ rcosß rsinß 
; 

\ --- CARTESIAN TO POLAR CONVERSION ---

: XY>C   ( x y -- mag ang )
  \ Convert cartesian to polar: magnitude = sqrt(x²+y²)
  2DUP VEC2-LEN     \ x y mag
  -ROT              \ mag x y 
  ATAN2 ;


\ --- ADDITION ---

: C+ ( m1 a1 m2 a2 -- m3 a3 )
    \ Convert both to cartesian
    C>XY                \ m1 a1  -> x1 y1
    >R >R               \ m1 a1     R: y1 x1
    C>XY                \ m2 a2  -> x2 y2
    R> +                \ x2 x1     -> x3
    R> +                \ x3 y3
    XY>C                \ mag3 ang3
;
