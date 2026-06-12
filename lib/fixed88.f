\
\ fixed88.f
\ ______________________________________________________________________ 
\
\ v-Forth 1.8 - NextZXOS version - build 2026-04-19
\ MIT License (c) 1990-2026 Matteo Vitturi     
\ ______________________________________________________________________ 
\
\ Fixed-point 8.8 arithmetic library for vForth (16-bit cells)
\ Signed Q8.8 format: 8 integer bits, 8 fractional bits (range -128.0 to +127.996)

.( FIXED88 )

NEEDS FLIP
NEEDS SPLIT
NEEDS UD/
NEEDS DSQRT
NEEDS FP-INTERFACE

MARKER FIXED88 

.( .) \ show progress


DECIMAL

\ --- CONSTANTS ---

  256 CONSTANT FP-SCALE       \ 2^8 = scaling factor
  128 CONSTANT FP-HALF        \ 0.5 in fixed-point format
    8 CONSTANT BIT-SCALE
  255 CONSTANT B-MASK

  256 CONSTANT FP-1.0      \ 1.0
  128 CONSTANT FP-0.5      \ 0.5 
 1608 CONSTANT FP-2PI
  804 CONSTANT FP-PI       \ Pi ~ 3.14159 ~ 804/256
  402 CONSTANT FP-PI/2
  201 CONSTANT FP-PI/4 
  696 CONSTANT FP-E        \ e ~ 2.71828 ~ 696/256
46080 CONSTANT FP-180      \ 180.0


\ --- CONVERSIONS ---

: >FP   ( n -- fp )
  \ Convert integer to fixed-point Q8.8
  \ Optimized: shift byte instead of multiply by 256
  BIT-SCALE LSHIFT ;


: FP>INT   ( fp -- n )
  \ Convert fixed-point to integer (truncation)
  DUP BIT-SCALE RSHIFT
  SWAP +- ;  


: FP>ROUND   ( fp -- n )
  \ Convert fixed-point to integer (rounding)
  FP-HALF + FP>INT ;



\ --- COMPONENT EXTRACTION ---

: FP-FRAC   ( fp -- n )
  \ Extract fractional part (0-255)
  B-MASK AND ;


: FP-PARTS   ( fp -- int frac )
  \ Extract both parts using SPLIT
  SPLIT SWAP ;


\ --- BASE ARITHMETIC OPERATIONS ---

: FP+   ( fp1 fp2 -- fp3 )
  \ Fixed-point addition
  + ;


: FP-   ( fp1 fp2 -- fp3 )
  \ Fixed-point subtraction
  - ;


: FP*   ( fp1 fp2 -- fp3 )
  \ Fixed-point multiplication
  \ Result needs to be scaled down by 256
  FP-SCALE */ ;  


: FP/   ( fp1 fp2 -- fp3 )
  \ Fixed-point division
  \ Numerator needs to be scaled up by 256
  FP-SCALE SWAP */ ;  


\ --- FRACTION CONVERSION ---

: N/D>FP   ( numerator denominator -- fp )
  \ Convert fraction to fixed-point
  FP/
;

\ --- ANGLE NORMALIZATION ---

: NORMALIZE-ANGLE   ( angle -- normalized-angle )
  \ Normalize angle to [0, 2Pi) range
  FP-2PI /MOD DROP 
  DUP 0< IF FP-2PI FP+ THEN 
;  


\ --- COMBINED OPERATIONS ---

: FP-SQUARE   ( fp -- fp^2 )
  \ Square
  DUP FP* ;


: FP-AVERAGE   ( fp1 fp2 -- fp-avg )
  \ Arithmetic mean
  FP+ 2 / ;


: FP-LERP   ( fp1 fp2 t -- fp-result )
  \ Linear interpolation: fp1 + t*(fp2-fp1)
  \ where t is in fixed-point format [0..1]
  >R 2DUP FP- R> FP* -ROT DROP + ;


\ D<<8    ( ud -- ud*256 )
\ Shift left 8 bits (multiply by 256) for double unsigned.
\ Internal double representation in this Forth:
\   Input := "HLDE"   (HL on top of stack, DE below)
\   Output:= "LDE0"   (H is discarded, remaining LDE is shifted)
CODE D<<8 ( ud -- ud' ) 
    $D9 C,          \ EXX
    $E1 C,          \ POP     HL|     
    $D1 C,          \ POP     DE|     
    $65 C,          \ LD      H'|    L|    
    $6A C,          \ LD      L'|    D|    
    $53 C,          \ LD      D'|    E|    
    $1E C, $00 C,   \ LDN     E'|    HEX 00 N,  
    $D5 C,          \ PUSH DE
    $E5 C,          \ PUSH HL
    $D9 C,          \ EXX
    $DD C, $E9 C,   \ NEXT
    SMUDGE          \ C;


\ --- SQUARE ROOT (Approximated) ---

               
\ FP-SQRT   ( ufp -- sqrt-fp )
\ Fixed-point square root using Newton's method.
\ Returns 0 for negative or zero input.
\ Uses early exit via LEAVE when convergence is reached.
: FP-SQRT   ( uf -- sqrt_f )
    DUP 0> IF
        0 D<<8 DSQRT 
    ELSE
        DROP 0
    THEN ;


\ --- PRACTICAL APPLICATIONS ---

\ Calculate distance between two points (positive part only)
: FP-DIST   ( x1 y1 x2 y2 -- dist )
  \ dist = sqrt((x2-x1)^2 + (y2-y1)^2)
  ROT  FP- FP-SQUARE    \ (y2-y1)^2
  -ROT FP- FP-SQUARE    \ (x2-x1)^2
  FP+ FP-SQRT ;


\ Temperature conversion Celsius → Fahrenheit
: C>F   ( celsius-fp -- fahrenheit-fp )
  \ F = C * 9/5 + 32
  9 5 */ 32 >FP FP+ ;


\ Temperature conversion Fahrenheit → Celsius
: F>C   ( fahrenheit-fp -- celsius-fp )
  \ C = (F - 32) * 5/9
  32 >FP FP- 5 9 */ ;


\ Compound interest calculation
: FP-INTEREST   ( capital rate% years -- amount )
  \ M = C * (1 + r)^n (approximated for small n)
  >R >R           \ Save years and capital
  100 N/D>FP FP-1.0 FP+  \ (1 + r/100)
  R> FP*          \ capital * (1+r)
  R> 1- 0 DO 
    OVER FP* 
  LOOP
  NIP ;


\ --- 2D VECTOR OPERATIONS ---

\ Vector addition
: VEC2-ADD   ( x1 y1 x2 y2 -- x3 y3 )
  ROT FP+ -ROT FP+ SWAP ;


\ Dot product
: VEC2-DOT   ( x1 y1 x2 y2 -- dot-product )
  ROT FP* -ROT FP* FP+ ;


\ Vector length
: VEC2-LEN   ( x y -- length )
  FP-SQUARE SWAP FP-SQUARE FP+ FP-SQRT ;


\ Vector normalization
: VEC2-NORMALIZE   ( x y -- x-norm y-norm )
  2DUP VEC2-LEN      \ x y len
  DUP 0= IF 
    DROP 2DROP 0 0   \ Null vector
  ELSE
    >R 2DUP R> 
    DUP >R FP/ -ROT R> FP/ SWAP
  THEN ;


\ --- I/O --- 

\ Print Q8.8 fixed point with 2 decimal places 
: FP.   ( fp -- )
    DUP 0< IF 
        [CHAR] - EMIT 
        NEGATE 
    THEN    
    \ simple rounding, only if fractional part is non-zero
    DUP SPLIT DROP IF 1+ THEN     
    \ Integer part and dot
    SPLIT 0 .R [CHAR] . EMIT
    \ Fractional (2 decimal places)
    100 * SPLIT NIP   \ 100 means 2 decimal digits
    0 <# # # #> TYPE
    SPACE
;


CREATE FP-SCALE-TABLE
DECIMAL        
\ Each entry: ( divisor-hi divisor-lo )
\ Index by (DPL-1)*2*CELLS
    0 , 10    ,    \ one digit after decimal point
    0 , 100   ,    \ two digits after decimal point
    0 , 1000  ,    \ three digits
    0 , 10000 ,    \ four digits
   10 , 10000 ,    \ five digits
  100 , 10000 ,    \ six digits
 1000 , 10000 ,    \ seven digits

\ convert a double integer into a fixed 8.8, useful for literal input. 
\ It uses DPL as the number of digits after the decimal point, 
\ d must have less than 8 precision digits to be meaninful for f8.8 fixed points
: D>FP ( d -- f8.8 )
    \ save high part as sign and use absolute value of d
    DUP >R DABS   
    D<<8 
    \ if there is any digit after decimal point
    DPL @ ?DUP IF
        \ get corresponding TWO scale-divisors addresses
        1- CELLS 2* 
        FP-SCALE-TABLE +
        DUP @ >R 
        \ get first divisor
        CELL+ @ DUP >R
        \ first add half divisor for rounding.
        2/ 0 D+
        \ apply first divisor
        R> UD/
        \ apply second divisor if non zero.
        \ we don't care any other rounding at this point
        R> ?DUP IF
            UD/
        THEN
    THEN
    DROP
    \ apply sign 
    R> +- ;

.( .)

\ move fp from Forth calculator stack to Spectrum's floating-point stack
\ by separating sign, integer and fractional part and adding them togheter
\ Be careful to balance push to and pop from Spectrum's floating-point stack
: FP>W ( fp -- )
    DUP >R              \ fp-sign
    ABS SPLIT           \ frac intg     
    0 >W                \ frac          F: intg
    FP-SCALE 0 ROT 0    \ 256. frac. 
    >W >W 5 FOP         \               F: intg frac/256
    #15 FOP             \               F: intg+frac/256
    R> 0<               \ fp-sign?
    IF #27 FOP THEN     \               F: �intg+frac/256
;
    
\ move fp from Spectrum's floating-point stack to Forth calculator stack
\ by reverting FP>W activity.
\ Be careful to balance push to and pop from Spectrum's floating-point stack
: W>FP ( -- fp )
    #49 FOP W> >R DROP  \               F:  fp      R: sign
    #42 FOP             \               F: |fp|
    #49 FOP #39 FOP     \               F:  fp  int(fp)
    #49 FOP W> D<<8     \ ud            F:  fp  int(fp)   
      3 FOP             \ ud            F:  fp-int(fp) 
    FP-SCALE 0 >W 4 FOP \ 
    #39 FOP W> D+       \ ud    
    R> +- DROP
;

            
\ Trigonometric functions 
\ Argument in radians (Q8.8), result in Q8.8 (-256..+256 represents -1.0..+1.0)

    
DECIMAL

\ Convert degrees to radians: rad = deg * Pi/180
: FP-DEG>RAD   ( degrees -- radians )
  355 20340 */ ;

\ Convert radians to degrees: deg = rad * 180/Pi
: FP-RAD>DEG   ( radians -- degrees )
  20340 355 */ ;

: *PI    ( fp -- pi*fp )
    355 113 */ ;

: /PI    ( f -- fp/pi )
    113 355 */ ;


\ build-part of the following  nFOPm  definition
\ it stores the xt of the following check-word and the op-code
: ',C,   ( b -- cccc )
    <BUILDS 
    '  ,  C,  
;


\ execute FOP stored at a+2 and bring to TOS the result.
: FOP1  ( a -- d )     
    CELL+ C@ FOP W>FP
;


\ execute check-word stored during "nFOPm" creation
: FCHECK ( a -- a )     
    >R R@  @  EXECUTE R> 
;


\ create a FP-word that takes one argument and returns one argument
: 1FOP1 ( n -- cccc xxxx )
    ',C, DOES>
    FCHECK              \ d 
    >R FP>W R>          \ a
    FOP1                \ d
;


: ?FTRG 
    DUP ABS FP-1.0 > 11 ?ERROR ; \ Invalid floating point.
    

31  1FOP1  FSIN        NOOP         ( rad -- fp   )  \ sine 
32  1FOP1  FCOS        NOOP         ( rad -- fp   )  \ cosine
33  1FOP1  FTAN        NOOP         ( rad -- fp   )  \ tangent
34  1FOP1  FASIN       ?FTRG        (  fp -- rad  )  \ arc-sine
35  1FOP1  FACOS       ?FTRG        (  fp -- rad  )  \ arc-cosine
36  1FOP1  FATAN       NOOP         (  fp -- rad  )  \ arc-tangent


