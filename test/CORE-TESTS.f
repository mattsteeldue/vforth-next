\
\ CORE-TESTS.f
\


MARKER TESTING-TASK

BASE @

NEEDS TESTING
NEEDS S"
NEEDS FIND

HEX \ all test needs base 16.

CR

\ F.3.1 Basic Assumption
\
\ A method for testing KEY, QUIT, ABORT, ABORT", ENVIRONMENT?, etc 
\ has yet to be proposed.
\
INCLUDE  test/basic-assumptions.f

\ F.3.2 Booleans

INCLUDE  test/invert.f
INCLUDE  test/and.f
INCLUDE  test/or.f
INCLUDE  test/xor.f

\ F.3.3 Shifts

INCLUDE  test/2&.f      \ 2*
INCLUDE  test/2%.f      \ 2/
INCLUDE  test/lshift.f
INCLUDE  test/rshift.f

\ F.3.4 Numeric Notation

\ INCLUDE  test/numeric-notation.f

\ F.3.5 Comparison

INCLUDE  test/0=.f  
INCLUDE  test/=.f
INCLUDE  test/0{.f      \ 0<
INCLUDE  test/{.f       \ <
INCLUDE  test/}.f       \ >
INCLUDE  test/u{.f      \ U<
INCLUDE  test/min.f
INCLUDE  test/max.f

INCLUDE  test/not.f     \ NOT 

\ F.3.6 Stack Operators

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

\ F.3.7 Return Stack Operators

INCLUDE  test/}r.f

\ F.3.8 Addition and Subtraction

INCLUDE  test/+.f
INCLUDE  test/-.f
INCLUDE  test/1+.f
INCLUDE  test/1-.f
INCLUDE  test/abs.f
INCLUDE  test/negate.f

\ F.3.9 Multiplication

INCLUDE  test/&.f       \ *
INCLUDE  test/s}d.f     \ S>D
INCLUDE  test/m&.f      \ M*
INCLUDE  test/um&.f     \ UM*

\ Division

INCLUDE  test/um%mod.f  \ UM/MOD
INCLUDE  test/fm%mod.f  \ FM/MOD
INCLUDE  test/sm%rem.f  \ SM/REM

INCLUDE  test/&%mod.f   \ */MOD
INCLUDE  test/%mod.f    \ /MOD
INCLUDE  test/%.f       \ /
INCLUDE  test/mod.f     \ MOD
INCLUDE  test/&%.f      \ */

\ Memory

INCLUDE  test/,.f
INCLUDE  test/+!.f
INCLUDE  test/cells.f
INCLUDE  test/c,.f
INCLUDE  test/chars.f
INCLUDE  test/align.f
INCLUDE  test/allot.f

\ Characters

INCLUDE  test/bl.f
INCLUDE  test/char.f
INCLUDE  test/[char].f
INCLUDE  test/[.f
INCLUDE  test/s~.f      \ S" 
\ using heap corrupts ram paging ?

\ Dictionary

INCLUDE  test/'.f
INCLUDE  test/['].f
INCLUDE  test/find.f            
INCLUDE  test/literal.f
INCLUDE  test/count.f  
INCLUDE  test/postpone.f
INCLUDE  test/state.f

\ Flow Control

INCLUDE  test/if.f
INCLUDE  test/while.f   
INCLUDE  test/until.f
INCLUDE  test/recurse.f  

\ Counted Loops

INCLUDE  test/loop.f
INCLUDE  test/+loop.f 
INCLUDE  test/j.f     
INCLUDE  test/leave.f    
INCLUDE  test/unloop.f        


BASE !
