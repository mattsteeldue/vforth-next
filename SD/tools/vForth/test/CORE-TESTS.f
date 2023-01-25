\
\ CORE-TESTS.f
\

MARKER TESTING-TASK
    
    NEEDS :NONAME
    NEEDS 2OVER
    NEEDS 2ROT
    NEEDS 2SWAP
    NEEDS ALIGN
    NEEDS ALIGNED
    NEEDS CASE
    NEEDS CHAR+ 
    NEEDS CHARS
    NEEDS DEPTH
    NEEDS FIND
    NEEDS FM/MOD 
    NEEDS INVERT
    NEEDS J 
    NEEDS M*/ 
    NEEDS PICK 
    NEEDS POSTPONE
    NEEDS RECURSE
    NEEDS S"
    NEEDS SM/REM
    NEEDS UNLOOP
    NEEDS ['] 
    NEEDS EVALUATE
    NEEDS BINARY
    CHARS
    
WARNING @ 
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !


\ Save base value
BASE    @ HEX \ all test needs base 16.

CR

TESTING \ F.3.1 Basic Assumptions

\ These test assume a two's complement implementation where the range 
\ of signed numbers is -2^(n-1) ... 2^(n-1)-1 and the range of unsinged numbers
\ is 0 ... 2^n -1.
\ A method for testing KEY, QUIT, ABORT, ABORT", ENVIRONMENT?, etc 
\ has yet to be proposed.

    INCLUDE  test/basic-assumptions.f


TESTING \ F.3.2 Booleans

\ To test the booleans it is first neccessary to test F.6.1.0720 AND, and 
\ F.6.1.1720 INVERT. Before moving on to the test F.6.1.0950 CONSTANT. 
\ The latter defines two constants (0S and 1S) which will be used in the 
\ further test.
\ It is now possible to complete the testing of F.6.1.0720 AND, F.6.1.1980 OR, 
\ and F.6.1.2490 XOR.

    INCLUDE  test/invert.f
    INCLUDE  test/and.f
    INCLUDE  test/or.f
    INCLUDE  test/xor.f


TESTING \ F.3.3 Shifts

\ To test the shift operators it is necessary to calculate the most significant
\ bit of a cell:
\   1S 1 RSHIFT INVERT CONSTANT MSB
\ RSHIFT is tested later. MSB must have at least one bit set:
\   T{ MSB BITSSET? -> 0 0 }T
\ The test F.6.1.0320 2*, F.6.1.0330 2/, F.6.1.1805 LSHIFT, and 
\ F.6.1.2162 RSHIFT can now be performed.

    INCLUDE  test/2&.f      \ 2*
    INCLUDE  test/2%.f      \ 2/
    INCLUDE  test/lshift.f
    INCLUDE  test/rshift.f


TESTING \ F.3.4 Numeric Notation

\ implementation of NUMBER in v-Forth is very simple and it cannot handle 
\ prefix such as those used in the following tests.
\ The numeric representation can be tested with the following test cases

    INCLUDE  test/numeric-notation.f


TESTING \ F.3.5 Comparison

\ Before testing the comparison operators it is necessary to define a few 
\ constants to allow the testing of the upper and lower bounds.
\ See testing.f

    INCLUDE  test/0=.f  
    INCLUDE  test/=.f
    INCLUDE  test/0{.f      \ 0<
    INCLUDE  test/{.f       \ <
    INCLUDE  test/}.f       \ >
    INCLUDE  test/u{.f      \ U<
    INCLUDE  test/min.f
    INCLUDE  test/max.f

    INCLUDE  test/not.f     \ NOT 
    INCLUDE  test/{}.f      \ <>


TESTING \ F.3.6 Stack Operators

\ The stack operators can be tested without any prepatory work. The "normal" 
\ operators (F.6.1.1260 DROP, F.6.1.1290 DUP, F.6.1.1990 OVER, F.6.1.2160 ROT,
\ and F.6.1.2260 SWAP) should be tested first, followed by the two-cell 
\ variants (F.6.1.0370 2DROP, F.6.1.0380 2DUP, F.6.1.0400 2OVER and F.6.1.0430 
\ 2SWAP) with F.6.1.0630 ?DUP and F.6.1.1200 DEPTH being performed last.

    INCLUDE  test/drop.f
    INCLUDE  test/dup.f
    INCLUDE  test/over.f
    INCLUDE  test/rot.f
    INCLUDE  test/swap.f

    INCLUDE  test/2drop.f
    INCLUDE  test/2dup.f
    INCLUDE  test/2over.f
    INCLUDE  test/2swap.f

    INCLUDE  test/^dup.f
    INCLUDE  test/-dup.f    \ -DUP
    INCLUDE  test/depth.f

    \ custom
    INCLUDE  test/nip.f
    INCLUDE  test/tuck.f
    INCLUDE  test/pick.f
    INCLUDE  test/-rot.f    \ -ROT
    INCLUDE  test/2rot.f 


TESTING \ F.3.7 Return Stack Operators

\ The test F.6.1.0580 >R will test all three basic return stack operators 
\ (>R, R>, and R@).

    INCLUDE  test/}r.f


TESTING \ F.3.8 Addition and Subtraction

\ Basic addition and subtraction should be tested in the order: F.6.1.0120 +, 
\ F.6.1.0160 -, F.6.1.0290 1+, F.6.1.0300 1-, F.6.1.0690 ABS 
\ and F.6.1.1910 NEGATE.

    INCLUDE  test/+.f
    INCLUDE  test/-.f
    INCLUDE  test/1+.f
    INCLUDE  test/1-.f
    INCLUDE  test/abs.f
    INCLUDE  test/negate.f


TESTING \ F.3.9 Multiplication

\ The multiplication operators should be tested in the order: F.6.1.2170 S>D, 
\ F.6.1.0090 *, F.6.1.1810 M*, and F.6.1.2360 UM*.

    INCLUDE  test/s}d.f     \ S>D
    INCLUDE  test/&.f       \ *
    INCLUDE  test/m&.f      \ M*
    INCLUDE  test/um&.f     \ UM*
    

TESTING \ F.3.10 Division

\ Due to the complexity of the division operators they are tested separately 
\ from the multiplication operators. The basic division operators are tested 
\ first: F.6.1.1561 FM/MOD, F.6.1.2214 SM/REM, and F.6.1.2370 UM/MOD.
\ As the standard allows a system to provide either floored or symmetric 
\ division, the remaining operators have to be tested depending on the system 
\ behaviour. Two words are defined that provide a form of conditional 
\ compilation.
\   : IFFLOORED [ -3 2 / -2 = INVERT ] LITERAL IF POSTPONE \ THEN ;
\   : IFSYM      [ -3 2 / -1 = INVERT ] LITERAL IF POSTPONE \ THEN ;
\ IFSYM will ignore the rest of the line when it is performed on a system with 
\ floored division and perform the line on a system with symmetric division. 
\ IFFLOORED is the direct inverse, ignoring the rest of the line on systems 
\ with symmetric division and processing it on systems with floored division.
\ The remaining division operators are tested by defining a version of the 
\ operator using words which have already been tested (S>D, M*, FM/MOD and 
\ SM/REM). The test definition handles the special case of differing signes. 
\ As the test definitions use the words which have just been tested, the tests 
\ must be performed in the order: F.6.1.0240 /MOD, F.6.1.0230 /, 
\ F.6.1.1890 MOD, F.6.1.0100 */, and F.6.1.0110 */MOD.

    INCLUDE  test/um%mod.f  \ UM/MOD
    INCLUDE  test/fm%mod.f  \ FM/MOD
    INCLUDE  test/sm%rem.f  \ SM/REM

    INCLUDE  test/&%mod.f   \ */MOD
    INCLUDE  test/%mod.f    \ /MOD
    INCLUDE  test/%.f       \ /
    INCLUDE  test/mod.f     \ MOD
    INCLUDE  test/&%.f      \ */
    
    INCLUDE  test/m&%.f     \ M*/ ( F.8 The optional Double-Number word set )


TESTING \ F.3.11 Memory

\ As with the other sections, the tests for the memory access words build on 
\ previously tested words and thus require an order to the testing.
\ The first test (F.6.1.0150 , (comma)) tests HERE, the signle cell memory 
\ access words @, ! and CELL+ as well as the double cell access words 2@ and 2!.
\ The tests F.6.1.0130 +! and F.6.1.0890 CELLS should then be performed.
\ The test (F.6.1.0860 C,) also tests the single character memory words C@, C!,
\ and CHAR+, leaving the test F.6.1.0898 CHARS to be performed seperatly.
\ Finally, the memory access alignment test F.6.1.0705 ALIGN includes a test of
\ ALIGNED, leaving F.6.1.0710 ALLOT as the final test in this group.

    INCLUDE  test/,.f
    INCLUDE  test/+!.f
    INCLUDE  test/cells.f
    INCLUDE  test/c,.f
    INCLUDE  test/chars.f
    INCLUDE  test/align.f
    INCLUDE  test/allot.f


TESTING \ F.3.12 Characters

\ Basic character handling: F.6.1.0770 BL, F.6.1.0895 CHAR, F.6.1.2520 [CHAR], 
\ F.6.1.2500 [ which also tests ], and F.6.1.2165 S".

    INCLUDE  test/bl.f
    INCLUDE  test/char.f
    INCLUDE  test/[char].f
    INCLUDE  test/[.f
    INCLUDE  test/s~.f      \ S" 


TESTING \ F.3.13 Dictionary

\ The dictionary tests define a number of words as part of the test, these are
\ included in the approperate test: F.6.1.0070 ', F.6.1.2510 ['] both of which
\ also test EXECUTE, F.6.1.1550 FIND, F.6.1.1780 LITERAL, F.6.1.0980 COUNT, 
\ F.6.1.2033 POSTPONE, F.6.1.2250 STATE

    INCLUDE  test/'.f
    INCLUDE  test/['].f
    INCLUDE  test/find.f            
    INCLUDE  test/literal.f
    INCLUDE  test/count.f  
    INCLUDE  test/postpone.f
    INCLUDE  test/state.f

    INCLUDE  test/[compile].f  
\   INCLUDE  test/compile.f    *** TO TO ***


TESTING \ F.3.14 Flow Control

\ The flow control words have to be tested in matching groups. 
\ First test F.6.1.1700 IF, ELSE, THEN group. Followed by the BEGIN, 
\ F.6.1.2430 WHILE, REPEAT group, and the BEGIN, F.6.1.2390 UNTIL pairing. 
\ Finally the F.6.1.2120 RECURSE function should be tested.

    INCLUDE  test/if.f
    INCLUDE  test/while.f   
    INCLUDE  test/until.f
    INCLUDE  test/recurse.f  


TESTING \ F.3.15 Counted Loops

\ Counted loops have a set of special condition that require testing. 
\ As with the flow control words, these words have to be tested as a group. 
\ First the basic counted loop: DO; I; F.6.1.1800 LOOP, followed by loops with
\ a non regular increment: F.6.1.0140 +LOOP, loops within loops: F.6.1.1730 J,
\ and aborted loops: F.6.1.1760 LEAVE; F.6.1.2380 UNLOOP which includes a test
\ for EXIT.

    INCLUDE  test/loop.f  
    INCLUDE  test/+loop.f 
    INCLUDE  test/j.f     
    INCLUDE  test/leave.f    
    INCLUDE  test/unloop.f 

    \ custom    
    INCLUDE  test/^do.f     \ ?DO
    INCLUDE  test/i'.f   


TESTING \ F.3.16 Defining Words

\ Although most of the defining words have already been used within the test
\ suite, they still need to be tested fully. The tests include F.6.1.0450 :
\ which also tests ;, F.6.1.0950 CONSTANT, F.6.1.2410 VARIABLE, F.6.1.1250 DOES>
\ which includes tests CREATE, and F.6.1.0550 >BODY which also tests CREATE.

WARNING @ 0 WARNING ! \ reduce messaging #4
    INCLUDE  test/_.f 
WARNING !
    INCLUDE  test/constant.f
    INCLUDE  test/variable.f
    INCLUDE  test/}body.f   \ >BODY       
    INCLUDE  test/does}.f   \ DOES>


TESTING \ F.3.17 Evaluate

\ As with the defining words, F.6.1.1360 EVALUATE has already been used, but it
\ must still be tested fully.

    INCLUDE  test/evaluate.f       \ *** N.B. nested EVALUATE still has bug ***
    

TESTING \ F.3.18 Parser Input Source Control

\ Testing of the input source can be quite dificult. 
\ The tests require line breaks within the test: F.6.1.2216 SOURCE, 
\ F.6.1.0560 >IN, and F.6.1.2450 WORD.

   INCLUDE  test/source.f          
   INCLUDE  test/}in.f      \ >IN  \ *** N.B. nested EVALUATE still has bug ***
   INCLUDE  test/word.f            \ *** incorrect result on emtpy lines ***


TESTING \ F.3.19 Number Patterns

\ The number formatting words produce a string, a word that compares 
\ two strings is required. This test suite assumes that the optional 
\ String word set is unavailable. Thus a string comparison word is defined, 
\ using only trusted words:
\ : S= \ ( ADDR1 C1 ADDR2 C2 -- T/F ) Compare two strings.
\    >R SWAP R@ = IF            \ Make sure strings have same length
\      R> ?DUP IF               \ If non-empty strings
\        0 DO
\          OVER C@ OVER C@ - IF 2DROP <FALSE> UNLOOP EXIT THEN
\          SWAP CHAR+ SWAP CHAR+
\        LOOP
\      THEN
\      2DROP <TRUE>            \ If we get here, strings match
\    ELSE
\      R> DROP 2DROP <FALSE> \ Lengths mismatch
\    THEN ;
\ The number formatting words have to be tested as a group with F.6.1.1670 HOLD,
\ F.6.1.2210 SIGN, and F.6.1.0030 # all including tests for <# and #>.
\ Before the F.6.1.0050 #S test can be performed it is necessary to calculate
\ the number of bits required to store the largest double value.
\ 24 CONSTANT MAX-BASE                  \ BASE 2 ... 36
\ : COUNT-BITS
\    0 0 INVERT BEGIN DUP WHILE >R 1+ R> 2* REPEAT DROP ;
\ COUNT-BITS 2* CONSTANT #BITS-UD    \ NUMBER OF BITS IN UD
\ The F.6.1.0570 >NUMBER test can now be performed. Finally, the F.6.1.0750 BASE
\ test, which includes tests for HEX and DECIMAL, can be performed.

    INCLUDE  test/hold.f            
    INCLUDE  test/sign.f            
    INCLUDE  test/#.f
    INCLUDE  test/#S.f              
    INCLUDE  test/}number.f \ >NUMBER \ 
    INCLUDE  test/base.f


TESTING \ F.3.20 Memory movement

    INCLUDE  test/fill.f  
    INCLUDE  test/move.f  


TESTING \ F.3.21 Output

    INCLUDE  test/emit.f


TESTING \ F.3.22 Input

    INCLUDE  test/accept.f


TESTING \ F.3.23 Dictionary Search Rules 

    \ INCLUDE  test/_.f               \ already done


\ TESTING \ other

\   NEEDS BUFFER:
\   NEEDS C"
\   NEEDS COMPILE,
\   NEEDS ACTION-OF
\   NEEDS DEFER
\   NEEDS DEFER!
\   NEEDS DEFER@
\   NEEDS IS
\   NEEDS CASE
\   NEEDS FALSE
\
\   INCLUDE  test/(.f           ( filler )
\   INCLUDE  test/_noname.f
\   INCLUDE  test/buffer_.f
\   INCLUDE  test/c~.f
\   INCLUDE  test/case.f
\   INCLUDE  test/compile,.f
\   INCLUDE  test/action-of.f
\   INCLUDE  test/defer.f
\   INCLUDE  test/defer!.f
\   INCLUDE  test/defer@.f
\   INCLUDE  test/is.f
\   INCLUDE  test/false.f   
\   INCLUDE  test/holds.f
\   INCLUDE  test/parse-name.f
\   INCLUDE  test/save-input.f
    
( end of test session )
BASE !


