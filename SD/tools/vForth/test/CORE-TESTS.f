\
\ CORE-TESTS.f
\

MARKER TESTING-TASK

WARNING @ 
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !
    
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
    

\ Save base value
BASE    @ HEX \ all test needs base 16.

CR

TESTING \ F.3.1 Basic Assumption
\
\ A method for testing KEY, QUIT, ABORT, ABORT", ENVIRONMENT?, etc 
\ has yet to be proposed.
\
    INCLUDE  test/basic-assumptions.f

TESTING \ F.3.2 Booleans

    INCLUDE  test/invert.f
    INCLUDE  test/and.f
    INCLUDE  test/or.f
    INCLUDE  test/xor.f

TESTING \ F.3.3 Shifts

    INCLUDE  test/2&.f      \ 2*
    INCLUDE  test/2%.f      \ 2/
    INCLUDE  test/lshift.f
    INCLUDE  test/rshift.f

TESTING \ F.3.4 Numeric Notation

\     INCLUDE  test/numeric-notation.f

TESTING \ F.3.5 Comparison

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

    INCLUDE  test/drop.f
    INCLUDE  test/dup.f
    INCLUDE  test/over.f
    INCLUDE  test/rot.f
    INCLUDE  test/swap.f

    INCLUDE  test/nip.f
    INCLUDE  test/tuck.f
    INCLUDE  test/pick.f
    INCLUDE  test/-rot.f    \ -ROT

    INCLUDE  test/2drop.f
    INCLUDE  test/2dup.f
    INCLUDE  test/2over.f
    INCLUDE  test/2swap.f

    INCLUDE  test/2rot.f

    INCLUDE  test/^dup.f
    INCLUDE  test/-dup.f    \ -DUP
    INCLUDE  test/depth.f

TESTING \ F.3.7 Return Stack Operators

    INCLUDE  test/}r.f

TESTING \ F.3.8 Addition and Subtraction

    INCLUDE  test/+.f
    INCLUDE  test/-.f
    INCLUDE  test/1+.f
    INCLUDE  test/1-.f
    INCLUDE  test/abs.f
    INCLUDE  test/negate.f

TESTING \ F.3.9 Multiplication

    INCLUDE  test/s}d.f     \ S>D
    INCLUDE  test/&.f       \ *
    INCLUDE  test/m&.f      \ M*
    INCLUDE  test/um&.f     \ UM*
    

TESTING \ F.3.10 Division

    INCLUDE  test/um%mod.f  \ UM/MOD
    INCLUDE  test/fm%mod.f  \ FM/MOD
    INCLUDE  test/sm%rem.f  \ SM/REM

    INCLUDE  test/&%mod.f   \ */MOD
    INCLUDE  test/%mod.f    \ /MOD
    INCLUDE  test/%.f       \ /
    INCLUDE  test/mod.f     \ MOD
    INCLUDE  test/&%.f      \ */
    INCLUDE  test/m&%.f     \ M*/

TESTING \ F.3.11 Memory

    INCLUDE  test/,.f
    INCLUDE  test/+!.f
    INCLUDE  test/cells.f
    INCLUDE  test/c,.f
    INCLUDE  test/chars.f
    INCLUDE  test/align.f
    INCLUDE  test/allot.f

TESTING \ F.3.12 Characters

    INCLUDE  test/bl.f
    INCLUDE  test/char.f
    INCLUDE  test/[char].f
    INCLUDE  test/[.f
    INCLUDE  test/s~.f      \ S" 

TESTING \ F.3.13 Dictionary

    INCLUDE  test/'.f
    INCLUDE  test/['].f
    INCLUDE  test/find.f            
    INCLUDE  test/literal.f
    INCLUDE  test/count.f  
    INCLUDE  test/postpone.f
    INCLUDE  test/state.f

TESTING \ F.3.14 Flow Control

    INCLUDE  test/if.f
    INCLUDE  test/while.f   
    INCLUDE  test/until.f
    INCLUDE  test/recurse.f  

TESTING \ F.3.15 Counted Loops

    INCLUDE  test/loop.f
    INCLUDE  test/+loop.f 
    INCLUDE  test/j.f     
    INCLUDE  test/leave.f    
    INCLUDE  test/unloop.f 
    
    INCLUDE  test/^do.f     \ ?DO


TESTING \ F.3.16 Defining Words

    INCLUDE  test/constant.f
    INCLUDE  test/variable.f
    INCLUDE  test/}body.f       
    INCLUDE  test/does}.f

TESTING \ F.3.17 Evaluate

    INCLUDE  test/evaluate.f        \ has a bug
    
( end of test session )
BASE !
EXIT

TESTING \ F.3.18 Parser Input Source Control

    INCLUDE  test/source.f
\   INCLUDE  test/}in.f             \ has bug
        INCLUDE  test/word.f        \ has bug

TESTING \ F.3.19 Number Patterns

    INCLUDE  test/hold.f            \ has bug
    INCLUDE  test/sign.f            \ has bug
    INCLUDE  test/#.f
    INCLUDE  test/#s.f              \ has bug
    INCLUDE  test/}number.f
    INCLUDE  test/base.f

TESTING \ F.3.20 Memory movement

    INCLUDE  test/fill.f            \ has bug
    INCLUDE  test/move.f            \ has bug

TESTING \ F.3.21 Output

    INCLUDE  test/emit.f

TESTING \ F.3.22 Input

    INCLUDE  test/accept.f

TESTING \ F.3.23 Dictionary Search Rules 

    INCLUDE  test/_.f               \ has bug

( end of test session )
BASE !
EXIT

TESTING \ other

    NEEDS BUFFER:
    NEEDS C"
    NEEDS COMPILE,
    NEEDS ACTION-OF
    NEEDS DEFER
    NEEDS DEFER!
    NEEDS DEFER@
    NEEDS IS
    NEEDS CASE
    NEEDS FALSE

    INCLUDE  test/(.f           ( filler )
    INCLUDE  test/_noname.f
    INCLUDE  test/buffer_.f
    INCLUDE  test/c~.f
    INCLUDE  test/case.f
    INCLUDE  test/compile,.f
    INCLUDE  test/action-of.f
    INCLUDE  test/defer.f
    INCLUDE  test/defer!.f
    INCLUDE  test/defer@.f
    INCLUDE  test/is.f
    INCLUDE  test/false.f   
    INCLUDE  test/holds.f
    INCLUDE  test/parse-name.f
    INCLUDE  test/save-input.f
    

