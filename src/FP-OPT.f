\ _________________
\
\ Floating point option
\ _________________

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
NEEDS [']

MARKER TASK

: FORGET-FP
    \ Patch INTERPRET 
    ['] NUMBER
    [ ' INTERPRET >BODY HEX 20 + ] LITERAL !
    TASK
;

DECIMAL 


\ 6E51h
\ FOP    ( n -- )
\ Floating-Point-Operation.
\ it calls the FP calculator which is a small Stack-Machine
CODE FOP 
    HEX
    E1 C,           \ POP     HL|     
    7D C,           \ LD      A'|    L|
    32 C, HERE 0 ,  \ LD()A   HERE 0 AA,
    C5 C,           \ PUSH    BC|
    EF C,           \ RST     28|
    HERE SWAP !     \         HERE SWAP !
    38 C,           \         HEX 38 C, \ this location is patched each time
    38 C,           \         HEX 38 C, \ end of calculation
    C1 C,           \ POP     BC|
    DD C, E9 C,     \ NEXT
    SMUDGE          \ C;


\ 6E11h
\ >W    ( d -- )
\ takes a double-number from stack and put to floating-pointer stack 
CODE >W
    HEX
    E1 C,           \ POP     HL|     
    D1 C,           \ POP     DE|     
    C5 C,           \ PUSH    BC|     
    CB C, 15 C,     \ RL       L|         \ To keep sign as the msb of H,   
    CB C, 14 C,     \ RL       H|         \ so you can check for sign in the
    CB C, 1D C,     \ RR       L|         \ integer-way. Sorry.
    06 C, FC C,     \ LDN     B'|    HEX 00 N,  
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
    C1 C,           \ POP     BC|
    DD C, E9 C,     \ NEXT
    SMUDGE          \ C;


\ 6E33h
\ W>    ( -- d )
\ takes a double-number from stack and put to floating-pointer stack 
CODE W>
    HEX
    C5 C,           \ PUSH    BC|     
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
    C1 C,           \ POP     BC|
    D5 C,           \ PSH2
    E5 C,
    DD C, E9 C, 
    SMUDGE          \ C;

DECIMAL


\ activate floating-point numbers
: FLOATING 1 NMODE ! ;

\ deactivate floating-point numbers
: INTEGER  0 NMODE ! ;


\ build-part of the following  nFOPm  definition
\ it stores the xt of the following check-word and the op-code
: ',C,   ( b -- cccc )  '  ,  C,  ;

\ execute check-word stored during nFOPm creation
: FCHECK ( a -- a )     >R R@ EXECUTE R> ;

\ execute FOP stored at a+2 and bring to TOS the result.
: 0FOP1  ( a -- d )     CELL+ C@ FOP W> ;

\ takes 2 top-most floating-point 
: 2>W    ( d d -- )     2SWAP >W >W ;


\ create a FP-word that takes one argument and returns one argument
: 1FOP1 ( n -- cccc xxxx )
    <BUILDS ',C, DOES>
    FCHECK 
    >R >W R> 0FOP1
;
    

\ create a FP-word that takes two arguments and returns one argument
: 2FOP1 ( n -- cccc xxxx )
    <BUILDS ',C, DOES>
    FCHECK 
    >R 2>W R> 0FOP1
;


\ create a FP-word that takes two arguments and returns two arguments
: 2FOP2 ( n -- cccc xxxx )
    <BUILDS ',C, DOES>
    FCHECK 
    >R 2>W R> 0FOP1 W> 2SWAP 
;


\ check for zero-division
: ?ZERO
    2DUP OR 0= 13 ?ERROR ;  \ Division by zero.


\ check for negative argument
: ?FNEG 
    DUP 0< 11 ?ERROR ;      \ Invalid floating point.


QUIT

    
\ Aritmethics

03  2FOP1   F-          NOOP        ( d d -- d   )  \ subtraction
04  2FOP1   F*          NOOP        ( d d -- d   )  \ product
05  2FOP1   F/          ?ZERO       ( d d -- d   )  \ division
15  2FOP1   F+          NOOP        ( d d -- d   )  \ sum
27  1FOP1   FNEGATE     NOOP        (   d -- d   )  \ negate
41  1FOP1   FSGN        NOOP        (   d -- d   )  \ sign
42  1FOP1   FABS        NOOP        (   d -- d   )  \ absolute value 
50  2FOP2   F/MOD       ?ZERO       ( d d -- d d )  \ remainder and quotient
06  2FOP1   F**         ?FNEG       ( d d -- d   )  \ power


: FMOD  F/MOD 2DROP ;


\ comparison
: F0<   NIP   0<  ;
: F0>   NIP   0>  ;
: F<    F-   F0<  ;
: F>    2SWAP F<  ;


\ Exponential / Log
37  1FOP1   FLN         NOOP        (   d -- d   )  \ natural log
38  1FOP1   FEXP        NOOP        (   d -- d   )  \ exponentation
39  1FOP1   FINT        NOOP        (   d -- d   )  \ truncation
40  1FOP1   FSQRT       ?FNEG       (   d -- d   )  \ square root


\ 58  1FOP1   FFIX        NOOP        (   d -- d   )  \ 


: ?FTRG 
    2DUP FABS 1 0 F> 11 ?ERROR ; \ Invalid floating point.


\ Trigonometrics

31  1FOP1  FSIN        NOOP         (   d -- d   )  \ sine 
32  1FOP1  FCOS        NOOP         (   d -- d   )  \ cosine
33  1FOP1  TAN         NOOP         (   d -- d   )  \ tangent
34  1FOP1  ARCSIN      ?FTRG        (   d -- d   )  \ arc-sine
35  1FOP1  ARCCOS      ?FTRG        (   d -- d   )  \ arc-cosine
36  1FOP1  ARCTAN      NOOP         (   d -- d   )  \ arc-tangent


\ Number Interpretation

\ 6FD9
\ (INTG)
\ convert the text in address a+1 int a floating-point number d.
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
            ENDIF
            2SWAP       ( d     b 0 ) 
        ENDIF
        
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
\ NUMBER
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
        ENDIF
        DUP C@ UPPER
        [CHAR] E =
        IF
            1 DPL +! 
            (EXP)
        ENDIF
        C@ BL - 0 ?ERROR
        R> IF 
            FNEGATE
        ENDIF
\       DPL @ 1+ IF 1 0 F/  THEN
    ELSE
        NUMBER   \ Previous version
    ENDIF
    ;


DECIMAL 


: D>F   ( d -- fp )
    DUP 0< >R DABS 0 SWAP 0
    0 [ HEX 4880 DECIMAL ] LITERAL \ 65536. 
    F* F+ 
    R> IF FNEGATE ENDIF 1 0 F/
;


: F>D   ( fp -- d )
    DUP 0< >R FABS 
    0 [ HEX 4880 DECIMAL ] LITERAL \ 65536. 
    F/MOD FINT SWAP 2SWAP FINT D+ 
    R> IF DNEGATE ENDIF 
;


: FLOAT  ( n -- fp )
    S>D D>F ;


: FIX    ( fp -- n )
    F>D DROP ;


: F.R    ( fp u -- ) 
    BASE @ >R DECIMAL
    >R 2DUP FABS 2DUP OR            \ non zero
    IF
        FLN 10 0 FLN F/ F>D         \ magnitude
    ENDIF
    TUCK 2DUP >R >R                 \ save sign and
    DABS
    <# #S SIGN 2DROP [CHAR] E HOLD  \ exponential part
    10 0  R>  R@   DABS F**         \ magnitude
    R> 0< 
    IF 
        F* 
    ELSE
        F/ 
    ENDIF 
    TUCK
    FABS 10 0  PLACE @ 0 F** F*
    \ [ 1 0 2 0 F/ ] DLITERAL F+    \ rounding
    F>D 
    PLACE @ ?DUP
    IF 
        0 DO # LOOP 
        [CHAR] . HOLD
    ENDIF
    #S SIGN #> 
    R> OVER - SPACES TYPE 
    R> BASE !
;


: F. 0 F.R SPACE ;

: PLACES  PLACE ! ;


: FP-INIT
    \ Patch INTERPRET 
    ['] NUMBER
    [ ' INTERPRET >BODY HEX 20 + ] LITERAL !
;


: PI
    [ 1 0 ARCTAN 4 0 F* ] DLITERAL
;


