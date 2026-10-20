\
\ +~.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( +" )
\
\
NEEDS HP@
NEEDS FAR
\
\ accept a string and append it to the counted string at "ha", which
\ must be the last one created on Heap (it is extended in place).
\ return the same Heap-Pointer to the counted string on Heap
\ no page-boundary check yet, nor on the 255 characters limit.
\
\ a block created by HEAP is: forward pointer, data, a zero cell and
\ a back pointer; HP points just after it. So the new text goes right
\ after the old one, then the tail is laid down again at the new end.
\
: +" ( ha -- ha )
    [CHAR] " WORD COUNT >R      \ ha a1        R: n
    OVER FAR DUP C@ + 1+        \ ha a1 a2     end of the string so far
    R@ CMOVE                    \ ha           append the text
    R@ HP +!                    \ ha           HP moves n bytes ahead
    DUP FAR DUP C@ R> +         \ ha a len     new length
    SWAP C!                     \ ha
    HP@ FAR CELL- >R            \ ha           R: a3
    DUP CELL- R@ !              \ ha           back pointer
    0 R> CELL- !                \ ha           zero pad
    HP@ OVER FAR CELL- !        \ ha           forward pointer
;


