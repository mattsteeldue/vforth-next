\
\ HEAP-STRING-TESTS.f
\
\ Tests for the strings the Heap memory facility lays down: H", +" and
\ +C. A HEAP block is: forward pointer, data, a zero cell and a back
\ pointer, HP just after it. After each word the string must still be
\ a counted z-string, the block the last one on Heap, and the back
\ pointer and the forward pointer must still agree with HP.
\ One group puts HP near the end of a page, to check that H" returns
\ the ha of the next page when HEAP skips to it.
\ An empty text, S" " H" " +" ", is an empty string: they parse with
\ PARSE, which does not skip a leading " as WORD does.
\ The errors (#-18, #14, #12) are not tested here, as ERROR ends in QUIT.
\ Every word used by the tests is defined before the first string is
\ allocated: a new definition puts its name on Heap, and the string
\ would no longer be the last block.
\

MARKER TESTING-TASK

WARNING @
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !

    NEEDS H"        NEEDS +"        NEEDS +C        NEEDS COMPARE

 \ Save base value
BASE    @ DECIMAL

\ zero cell right after the text
: Z?     ( ha -- f )  FAR DUP C@ + 1+ @ 0= ;
\ HP is just after the block of ha
: LAST?  ( ha -- f )  DUP FAR C@ + 5 + HP@ = ;
\ the back pointer gives the start of the block, which points to HP
: LINKS? ( -- f )     HP@ FAR CELL- @ FAR @ HP@ = ;
\ copy the string to PAD, out of reach of the next FAR
: >PAD   ( ha -- a n )  FAR COUNT DUP >R PAD SWAP CMOVE PAD R> ;
\ length of the string
: LEN    ( ha -- n )  FAR C@ ;
\ append n times the character x
: X+C    ( ha n -- ha )  0 DO [CHAR] x +C LOOP ;

: E1  ( -- a n )  S" HELLO" ;
: E2  ( -- a n )  S" HELLO, WORLD" ;
: E3  ( -- a n )  S" HELLO, WORLD!?" ;
: E4  ( -- a n )  S" NEXT" ;
: E5  ( -- a n )  S" NEXT PAGE" ;
: E0  ( -- a n )  S" " ;

VARIABLE HA1
VARIABLE HA2

CR

TESTING \ H" lays down a counted z-string

H" HELLO" HA1 !

T{ HA1 @ Z? -> <TRUE> }T
T{ HA1 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T
T{ HA1 @ >PAD E1 COMPARE -> 0 }T

TESTING \ +" extends it in place

T{ HA1 @ +" , WORLD" -> HA1 @ }T
T{ HA1 @ Z? -> <TRUE> }T
T{ HA1 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T
T{ HA1 @ >PAD E2 COMPARE -> 0 }T

TESTING \ +C extends it in place

T{ HA1 @ CHAR ! +C CHAR ? +C -> HA1 @ }T
T{ HA1 @ Z? -> <TRUE> }T
T{ HA1 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T
T{ HA1 @ >PAD E3 COMPARE -> 0 }T

TESTING \ up to 255 characters

H" x" HA1 !

T{ HA1 @ 254 X+C -> HA1 @ }T
T{ HA1 @ LEN -> 255 }T
T{ HA1 @ Z? -> <TRUE> }T
T{ HA1 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T

TESTING \ the empty text

T{ E0 NIP -> 0 }T
T{ H" " LEN 7 -> 0 7 }T

H" " HA1 !

T{ HA1 @ Z? -> <TRUE> }T
T{ HA1 @ LAST? -> <TRUE> }T
T{ HA1 @ +" " LEN 7 -> 0 7 }T
T{ HA1 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T

TESTING \ H" when HEAP skips to the next page

\ HP goes forward to offset $1EFC of its page, so that the next block
\ does not fit below PAGE-WATERMARK
HP@ $1FFF AND $1EFC MAX  HP@ $E000 AND OR  HP !

H" NEXT" HA2 !

T{ HA2 @ $1FFF AND -> 4 }T
T{ HA2 @ Z? -> <TRUE> }T
T{ HA2 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T
T{ HA2 @ >PAD E4 COMPARE -> 0 }T

TESTING \ and +" right after it

T{ HA2 @ +"  PAGE" -> HA2 @ }T
T{ HA2 @ Z? -> <TRUE> }T
T{ HA2 @ LAST? -> <TRUE> }T
T{ LINKS? -> <TRUE> }T
T{ HA2 @ >PAD E5 COMPARE -> 0 }T

\ Restore base
BASE !

