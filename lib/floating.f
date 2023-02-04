\
\ floating.f
\
\ _________________
\
\ Floating point option
\ _________________

.( Floating point option )

\ To remove this library and restore "everything" to integer you have to
\ give NO-FLOATING

\ ______________________________________________________________________

\ A floating point number is stored in stack in 4 bytes (HLDE) 
\ instead of the usual 5 bytes, so there is a little precision loss
\ Maybe in the future we'll be able to extend and fix this fact.
\
\ Sign is the msb of H, so you can check for sign in the integer-way.
\ Exponent +128 is stored in the following 8 bits of HL
\ Mantissa is stored in L and 16 bits of DE. B is defaulted.
\ 
\ A floating point number is stored in Spectrum's calculator stack as 5 bytes.
\ Exponent in A, sign in msb of E, mantissa in the rest of E and DCB.
\  H   <->  A    # 0   -> a
\  LDE <->  EDC  # 0DE -> eCD
\  x   <->  B    # x 

\ NEEDS ASSEMBLER
NEEDS 2ROT
NEEDS 2OVER
NEEDS 2CONSTANT
NEEDS [']

MARKER FP-MARKER

BASE @

DECIMAL 

\ the following three words are coded in assembler but without using ASSEMBLER
\ by directly compiling the Hexadecimal values of these routines.

\ FOP    ( n -- )
\ Floating-Point-Operation.
\ it calls the FP calculator which is a small Stack-Machine
CODE FOP 
    HEX
    E1 C,           \ POP     HL|     
    3A C, HERE 0 ,  \ LDA()   HERE 0 AA,   
    F5 C,           \ PUSH    AF|
    C5 C,           \ PUSH    BC|
    D5 C,           \ PUSH    DE|
    7D C,           \ LD      A'|    L|
    32 C, HERE 0 ,  \ LD()A   HERE 0 AA,   
    EF C,           \ RST     28|
    HERE SWAP !     \         HERE SWAP !  *THIS BYTE IS FIXED*
    HERE SWAP !     \         HERE SWAP !  
\   HERE
    38 C,           \         HEX 38 C, \ this location is patched each time
    38 C,           \         HEX 38 C, \ end of calculation
    D1 C,           \ POP     DE|
    C1 C,           \ POP     BC|
    F1 C,           \ POP     AF
\   32 C, HERE 0 ,  \ LD()A   HERE 0 AA,   
    DD C, E9 C,     \ NEXT
    SMUDGE          \ C;


\ 6E11h
\ >W    ( d -- )
\ pop number from calculator stack and push it to floating-pointer stack 
CODE >W
    HEX
    D9 C,           \ EXX
    E1 C,           \ POP     HL|     
    D1 C,           \ POP     DE|     
    CB C, 15 C,     \ RL       L|         \ To keep sign as the msb of H,   
    CB C, 14 C,     \ RL       H|         \ so you can check for sign in the
    CB C, 1D C,     \ RR       L|         \ integer-way. Sorry.
    06 C, A2 C,     \ LDN     B'|    HEX 00 N,  
    4B C,           \ LD      C'|    E|    
    5D C,           \ LD      E'|    L|    
    7C C,           \ LD      A'|    H|    
    A7 C,           \ ANDA     A|
    20 C, 03 C,     \ JRF    NZ'|   HOLDPLACE
    62 C,           \     LD      H'|    D|  \ swap C and D 
    51 C,           \     LD      D'|    C|
    4C C,           \     LD      C'|    H|
                    \ HERE DISP, \ THEN,       
    CD C, 2AB6 ,    \ CALL    HEX 2AB6 AA,
    D9 C,           \ EXX
    DD C, E9 C,     \ NEXT
    SMUDGE          \ C;


\ 6E33h
\ W>    ( -- d )
\ pop a number from floating-pointer stack and push it to top of calculator stack 
CODE W>
    HEX
    D9 C,           \ EXX
    CD C, 2BF1 ,    \ CALL    HEX 2BF1 AA,
    A7 C,           \ ANDA     A|
    20 C, 03 C,     \ JRF    NZ'|   HOLDPLACE
    62 C,           \     LD      H'|    D|  \ swap C and D 
    51 C,           \     LD      D'|    C|
    4C C,           \     LD      C'|    H|
                    \ HERE DISP, \ THEN,       
    67 C,           \ LD      H'|    A|
    6B C,           \ LD      L'|    E|
    59 C,           \ LD      E'|    C|   \ B is lost precision
    CB C, 15 C,     \ RL       L|         \ To keep sign as the msb of H,
    CB C, 1C C,     \ RR       H|         \ so you can check for sign in the 
    CB C, 1D C,     \ RR       L|         \ integer-way. Sorry.
    D5 C,           \ PUSH DE
    E5 C,           \ PUSH HL
    D9 C,           \ EXX
    DD C, E9 C, 
    SMUDGE          \ C;

DECIMAL


\ activate floating-point numbers
\ : FLOATING 1 NMODE ! ;  ( moved to ./lib )


\ deactivate floating-point numbers
: INTEGER  0 NMODE ! ;


\ build-part of the following  nFOPm  definition
\ it stores the xt of the following check-word and the op-code
: ',C,   ( b -- cccc )
    <BUILDS 
    '  ,  C,  
;


\ execute check-word stored during "nFOPm" creation
: FCHECK ( a -- a )     
    >R R@  @  EXECUTE R> 
;


\ execute FOP stored at a+2 and bring to TOS the result.
: FOP1  ( a -- d )     
    CELL+ C@ FOP W> 
;


\ create a FP-word that takes one argument and returns one argument
: 1FOP1 ( n -- cccc xxxx )
    ',C, DOES>
    FCHECK              \ d 
    >R >W R>            \ a
    FOP1                \ d
;
    

\ create a FP-word that takes two arguments and returns one argument
: 2FOP1 ( n -- cccc xxxx )
    ',C, DOES>
    FCHECK              \ d 
    >R 2SWAP >W >W R> 
    FOP1                \ d
;


\ create a FP-word that takes two arguments and returns two arguments
: 2FOP2 ( n -- cccc xxxx )
    ',C, DOES>
    FCHECK              \ d 
    >R 2SWAP >W >W R> 
    FOP1                \ d
    W> 2SWAP            \ d d
;


\ check for zero-division
: ?ZERO ( d -- d )
    2DUP OR 0= 13 ?ERROR    \ Division by zero.
;


\ check for negative argument
: ?FNEG ( d -- d ) 
    DUP 0< 11 ?ERROR        \ Invalid floating point.
;


\ check for positive argument
: ?FPOS ( d -- d )
    ?FNEG ?ZERO        \ Invalid floating point.
;


\ check for positive argument
: ?FPOW (   d1      d2   --   d1      d2   )
        ( n3  n2  n1  n0 -- n3  n2  n1  n0 )
    2 PICK 0<          \  n3  n2  n1  n0  f 
    OVER 0< AND        \  n3  n2  n1  n0  f 
    11 ?ERROR 
;      

    
\ Aritmethics
\
\ Op-Code   Name        Check       Stack figure     \ meaning
\ -------   ---------   ---------   ---------------  ---------
\
03  2FOP1   F-          NOOP      ( d1 d0 -- d2    ) \ subtraction
04  2FOP1   F*          NOOP      ( d1 d0 -- d2    ) \ product
05  2FOP1   F/          ?ZERO     ( d1 d0 -- d2    ) \ division
15  2FOP1   F+          NOOP      ( d1 d0 -- d2    ) \ sum
27  1FOP1   FNEGATE     NOOP      (    d0 -- d2    ) \ negate
41  1FOP1   FSGN        NOOP      (    d0 -- d2    ) \ sign
42  1FOP1   FABS        NOOP      (    d0 -- d2    ) \ absolute value 
50  2FOP2   F/MOD       ?ZERO     ( d1 d0 -- d2 d3 ) \ remainder and quotient
06  2FOP1   F**         ?FPOW     ( d1 d0 -- d2    ) \ power


: FMOD  ( d1 -- d2 )
    F/MOD       \ remainder and quotient
    2DROP       \ remainder
;


\ comparison
: F0<   NIP    0<  ;
: F0>   NIP    0>  ;
: F<    F-    F0<  ;
: F>    2SWAP  F<  ;


\ Exponential / Log
37  1FOP1   FLN         ?FPOS       (   d -- d   )  \ natural log
38  1FOP1   FEXP        NOOP        (   d -- d   )  \ exponentation
39  1FOP1   FINT        NOOP        (   d -- d   )  \ truncation
40  1FOP1   FSQRT       ?FNEG       (   d -- d   )  \ square root


\ 58  1FOP1   FFIX        NOOP        (   d -- d   )  \ 


: ?FTRG 
    2DUP FABS 1 0 F> 11 ?ERROR ; \ Invalid floating point.


\ Trigonometrics

31  1FOP1  FSIN        NOOP         (   d -- d   )  \ sine 
32  1FOP1  FCOS        NOOP         (   d -- d   )  \ cosine
33  1FOP1  FTAN        NOOP         (   d -- d   )  \ tangent
34  1FOP1  FASIN       ?FTRG        (   d -- d   )  \ arc-sine
35  1FOP1  FACOS       ?FTRG        (   d -- d   )  \ arc-cosine
36  1FOP1  FATAN       NOOP         (   d -- d   )  \ arc-tangent


\ Compound

: F*/   ( d1 d2 d3 -- d4 )
    ?ZERO   
    >R >R       \ d1 d2     R: d3
    >W >W       \                   F: d2 d1
    04 FOP      \ F*                F: d0
    R> R>       \ d3        R:
    >W 
    05 FOP      \ F/                F: d0 d3
    W>          \ d4
;
    

: PI
  [
    1 0 >W 36 FOP  \ atan
    4 0 >W 04 FOP  \ *4 
    W>  
  ] 
  DLITERAL
;


: DEG>RAD
    PI 180 0 F*/ 
;


: RAD>DEG
    180 0 PI F*/
;


\ Number Interpretation

\ 6FD9
\ (INTG)
\ convert the text in address a+1 into a floating-point number d.
: (INTG)  ( d a -- d1 a1 )
    BEGIN
        1+          ( d a ) 
        DUP >R      ( d a ) 
        C@          ( d c )
        BASE @      ( d c b )
        DIGIT       ( d n 1 | d 0 )
    WHILE
        0 2SWAP     ( dn d )  
        BASE @ 0    ( dn d db )
        F*          ( dn d )
        F+          ( d )
        R>
    REPEAT
    R>
    ;


\ 700Dh
\ (FRAC)
\ convert the text in address a+1 in a floating-point number d. 
: (FRAC)  ( d a -- d1 a1 )
    1 0             ( d a 1 0 )
    ROT             ( d fp a )
    BEGIN
        1+          ( d fp a )
        DUP >R      ( d fp a )
        C@          ( d fp c )
        BASE @      ( d fp c b )
        DIGIT       ( d fp n 1 | d fp 0 )
    WHILE
        0 2SWAP     ( d n 0 fp )
        BASE @  0   ( d n 0 fp b 0 )
        F/          ( d n 0 fp )
        2DUP 2ROT   ( d fp fp n 0 )
        F*          ( d fp fp2 ) 
        2ROT        ( fp fp2 d )
        F+          ( fp d )
        2SWAP       ( d fp )
        1 DPL +!
        R>          ( d fp a )
    REPEAT
    2DROP           ( d ) 
    R>              ( d a )
    ;


\ 7059h
\ (EXP)
\ convert the text in address a+1 in a floating-point number d. 
: (EXP)  ( d a -- d1 a1 )
    0 0                 ( d  a  0 0 )
    ROT                 ( d  0 0  a )
    (SGN)               ( d  0 0  a f )
    >R                  ( d  0 0  a )
    (NUMBER)            ( d  n 0  a )
    R>                  ( d  n 0  a f )
    SWAP                ( d  n 0  f a )
    >R >R               ( d  n 0 ) ( a f ) 
    DROP                ( d  n )
    EXP !               ( d  )
    BASE @ 0            ( d  b 0 )
    BEGIN
        EXP @ 0         ( d  b 0  n 0  )
        2 UM/MOD        ( d  b 0  q m )
        EXP !           ( d  b 0  q )
        
        IF
            2SWAP       ( b 0   d )
            2OVER       ( b 0   d   b 0 )
            R@          ( b 0   d   b 0   f)
            IF
                F/      ( b 0   d/b )
            ELSE
                F*      ( b 0   d*b )
            THEN
            2SWAP       ( d     b 0 ) 
        THEN
        
        2DUP            ( d     b 0   b 0 )
        F*              ( d     b^2 0 ) 
        EXP @ 0=        
    UNTIL
    2DROP               ( d ) 
    R>                  ( d f )
    DROP                ( d )
    R>                  ( d a )
    ;


\ 70C1h
\ FNUMBER
: FNUMBER  ( a -- d )
    NMODE @ 
    IF
        0 0 
        ROT
        (SGN) >R
        -1 DPL !
    
        (INTG) 
        DUP C@ [CHAR] . =
        IF
            0 DPL ! 
            (FRAC)
        THEN
        DUP C@ UPPER
        [CHAR] E =
        IF
            1 DPL +! 
            (EXP)
        THEN
        C@ BL - 0 ?ERROR
        R> IF 
            FNEGATE
        THEN
\       DPL @ 1+ IF 1 0 F/  THEN
    ELSE
        NUMBER   \ Previous version
    THEN
    ;


DECIMAL 


: D>F   ( d -- fp )
    DUP 0< >R DABS 0 SWAP 0
    0 [ HEX 4880 DECIMAL ] LITERAL \ 65536. 
    F* F+ 
    R> IF FNEGATE THEN 1 0 F/
;


: F>D   ( fp -- d )
    DUP 0< >R FABS 
    0 [ HEX 4880 DECIMAL ] LITERAL \ 65536. 
    F/MOD FINT SWAP 2SWAP FINT D+ 
    R> IF DNEGATE THEN 
;


DECIMAL


: FLOAT  ( n -- fp )
    S>D D>F ;


: FIX    ( fp -- a n )
    F>D DROP ;


: 1/2
  [
    1 0 2 0 F/
  ] 
  DLITERAL
;


: F>PAD    ( fp -- u ) 
    BASE @ >R DECIMAL
    2DUP FABS 2DUP OR            \ non zero
    IF
        FLN 10 0 FLN F/ F>D         \ magnitude
    THEN
    TUCK 2DUP >R >R                 \ save sign and
    DABS
    <# #S ROT SIGN 2DROP [CHAR] e HOLD  \ exponential part lower case "e"
    10 0  R>  R@   DABS F**         \ magnitude
    R> 0< 
    IF 
        F* 
    ELSE
        F/ 
    THEN 
    TUCK
    FABS 10 0  PLACE @ 0 F** F*
    1/2 F+    \ rounding
    F>D 
    PLACE @ ?DUP
    IF 
        0 DO # LOOP 
        [CHAR] . HOLD
    THEN
    #S ROT SIGN #> 
    R> BASE !
;


: F.R    ( fp u -- ) 
    >R 
    F>PAD
    R> 
    OVER - SPACES TYPE 
;


: F. 0 F.R SPACE ;


: PLACES  PLACE ! ;


: FCONSTANT 2CONSTANT ; 


: NO-FLOATING
    \ Verify 17th word inside INTERPRET is really FNUMBER
    [ ' INTERPRET >BODY DECIMAL 32 + ] LITERAL
    DUP @
    ['] FNUMBER
    - 14 ?ERROR
    \
    \ Patch INTERPRET 
    ['] NUMBER
    [ ' INTERPRET >BODY HEX 20 + ] LITERAL !
    INTEGER
    FP-MARKER
;


MARKER FORGET-ME

: FP-INIT
    \ Verify 17th word inside INTERPRET is really NUMBER
    [ ' INTERPRET >BODY DECIMAL 32 + ] LITERAL
    DUP @
    ['] NUMBER
    - 14 ?ERROR
    \    
    \ Patch INTERPRET 
    ['] FNUMBER
    SWAP !
    FORGET-ME
;

FP-INIT

BASE !

CR
.( Use FLOATING to enable FP numbers ) CR
.(     INTEGER  to disable ) CR
.( Use n PLACES to set decimal places ) CR

\
.( FLOATING )
\
\ activate floating-point numbers
: COLD NO-FLOATING COLD ;
: FLOATING 1 NMODE ! ;

