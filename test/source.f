\
\ test/source.f
\

NEEDS TESTING

NEEDS S"
NEEDS SOURCE
NEEDS EVALUATE
NEEDS COMPARE

TESTING F.6.1.2216  -  SOURCE

\ v-Forth has a system dependency on S" in that the address obtained by S"
\ is available while the page MMU7 hasn't changed.
\ There is no way to prevent the EVALUATEd string to change MMU7, so then
\ the string itself must be copied into a non-volatile area before INTERPRET
\ begin interpretation.

: GS0 S" SOURCE" 2DUP EVALUATE ;
T{ GS0 rot min tuck COMPARE -> 0 }T

\ : GS1 S" SOURCE" 2DUP EVALUATE >R SWAP >R = R> R> = ;
\ T{ GS1 -> <TRUE> <TRUE> }T
\ : GS4 SOURCE >IN ! DROP ;
\ T{ GS4 123 456 
\    -> }T
