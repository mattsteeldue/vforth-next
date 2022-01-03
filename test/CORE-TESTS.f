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

INCLUDE  test/basic-assumptions.f

\ Booleans

INCLUDE  test/invert.f
INCLUDE  test/and.f
INCLUDE  test/or.f
INCLUDE  test/xor.f

\ Shifts

INCLUDE  test/2&.f      \ 2*
INCLUDE  test/2%.f      \ 2/
INCLUDE  test/lshift.f
INCLUDE  test/rshift.f

\ Numeric Notation
\ INCLUDE  test/numeric-notation.f

\ Comparison

INCLUDE  test/0=.f  
INCLUDE  test/=.f
INCLUDE  test/0{.f   \ 0<
INCLUDE  test/{.f    \ <
INCLUDE  test/}.f    \ >
INCLUDE  test/u{.f   \ U<
INCLUDE  test/min.f
INCLUDE  test/max.f

INCLUDE  test/not.f  \ NOT

\ Stack Operators

INCLUDE  test/drop.f
INCLUDE  test/dup.f
INCLUDE  test/over.f
INCLUDE  test/rot.f
INCLUDE  test/swap.f

INCLUDE  test/nip.f
INCLUDE  test/tuck.f
INCLUDE  test/pick.f
INCLUDE  test/-rot.f \ -ROT

INCLUDE  test/2drop.f
INCLUDE  test/2dup.f
INCLUDE  test/2over.f
INCLUDE  test/2swap.f

INCLUDE  test/2rot.f

INCLUDE  test/^dup.f
INCLUDE  test/-dup.f \ -DUP
INCLUDE  test/depth.f

\ Return Stack Operators

INCLUDE  test/}r.f

\ Addition and Subtraction

INCLUDE  test/+.f
INCLUDE  test/-.f
INCLUDE  test/1+.f
INCLUDE  test/1-.f
INCLUDE  test/abs.f

\ Multiplication

INCLUDE  test/&.f
INCLUDE  test/s}d.f
INCLUDE  test/m&.f
INCLUDE  test/um&.f

\ Division

INCLUDE  test/um%mod.f
INCLUDE  test/fm%mod.f
INCLUDE  test/sm%rem.f

INCLUDE  test/&%mod.f
INCLUDE  test/%mod.f
INCLUDE  test/%.f
INCLUDE  test/mod.f
INCLUDE  test/&%.f

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
INCLUDE  test/s~.f              \ using heap corrupts ram paging ?

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
