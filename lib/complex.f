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
  \ Multiplication: (r1,b1) * (r2,b2) = (r1*r2, b1+b2)
  ROT FP+           \ Add angles: b1 + b2
  NORMALIZE-ANGLE   \ Keep in [0,2Pi)
  -ROT FP*          \ Multiply magnitudes: r1 * r2
  SWAP ;

: C/   ( mag1 ang1 mag2 ang2 -- mag3 ang3 )
  \ Division: (r1,b1) / (r2,b2) = (r1/r2, b1-b2)
  NEGATE ROT FP+    \ Subtract angles:  -b2 + b1 
  NORMALIZE-ANGLE
  -ROT FP/          \ Divide magnitudes: r1 / r2
  SWAP ;

: C-CONJ   ( mag ang -- mag -ang )
  \ Complex conjugate: (r,b) --> (r,-b)
  NEGATE NORMALIZE-ANGLE ;

: C-NEGATE   ( mag ang -- mag ang+Pi )
  \ Negation: (r,b) --> (r,b+Pi)
  FP-PI FP+ NORMALIZE-ANGLE ;    

: C-INV   ( mag ang -- mag ang )
  \ Reciprocal: 1/(r,b) = (1/r,-b)
  NEGATE NORMALIZE-ANGLE
  SWAP FP-1.0 SWAP FP/ SWAP ;

\ --- POWER OPERATIONS (VERY EFFICIENT IN POLAR) ---

: C-SQUARE   ( mag ang -- mag^2 ang*2 )
  \ Square: (r,b)^2 = (r^2,2b)
  2* NORMALIZE-ANGLE
  SWAP FP-SQUARE SWAP ;

: C-CUBE   ( mag ang -- mag^3 ang*3 )
  \ Cube: (r,b)^3 = (r^3,3b)
  3 * NORMALIZE-ANGLE
  SWAP DUP FP* FP* SWAP ;

: C-POW-N   ( mag ang n -- mag^n ang*n )
  \ Integer power: (r,b)^n = (r^n,nb)
  TUCK                    \ r n b n
  FP* NORMALIZE-ANGLE     \ Multiply angle by n
  -ROT FP-1.0 SWAP        \ b*n r 1.0 n 
  0 ?DO                   \ b*n r 1.0
    OVER FP*              
  LOOP                    \ b*n r r^n  
  NIP SWAP ;

: C-SQRT   ( mag ang -- sqrt-mag ang/2 )
  \ Square root: sqrt(r,b) = (sqrt r,b/2)
  2/ 
  SWAP FP-SQRT SWAP ;

: C-ROOT-N   ( mag ang n -- root-mag ang/n )
  \ Nth root: n-root(r,b) = (n-root r,b/n)
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
  \ Convert polar to cartesian: x = r*cos(b), y = r*sin(b)
  2DUP              \ r b r b
  FCOS              \ r b r cosb
  FP*               \ r b rcosb
  -ROT              \ rcosb r b 
  FSIN              \ rcosb r sinb 
  FP*               \ rcosb rsinb 
; 

\ --- CARTESIAN TO POLAR CONVERSION ---

: XY>C   ( x y -- mag ang )
  \ Convert cartesian to polar: magnitude = sqrt(x^2+y^2)
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
