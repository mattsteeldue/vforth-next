\
\ +c.f
\
\ this is part of the HEAP memory management libary. See also:
\ FAR HP@ POINTER HEAP H" S" +C +" HEAP-INIT HEAP-DONE
\ See "Heap memory facility" in PDF documentation for details
\
.( +C )
\
NEEDS FAR
NEEDS H"

\
\ consume c and append it to the counted string at "ha", which must be
\ the last one created on Heap (it is extended in place, as +" does:
\ see there for the block layout, the tail laid down again and the
\ errors #-18, #14 and #12).
\ returns the same Heap-Pointer to the counted string in Heap
\
BASE @ DECIMAL
\
: +C ( ha c -- ha )
    HP@ FAR CELL- @ ROT ROT     \ h0 ha c      start of the block
    OVER FAR C@                 \ h0 ha c len
    DUP 254 > -18 ?ERROR        \ h0 ha c len
    DUP 3 PICK + 5 + HP@ -      \ h0 ha c len f
    14 ?ERROR                   \ h0 ha c len
    HP@ $1FFF AND 1+ $1F58 >    \ h0 ha c len f
    12 ?ERROR                   \ h0 ha c len
    1+ 2 PICK FAR               \ h0 ha c n a  new length
    2DUP C!                     \ h0 ha c n a  fix length
    + C!                        \ h0 ha        store c
    1 HP +!                     \ h0 ha        HP moves 1 byte ahead
    OVER HP@ FAR CELL- !        \ h0 ha        back pointer
    0 HP@ FAR 4 - !             \ h0 ha        zero pad
    HP@ ROT FAR !               \ ha           forward pointer
;
\
BASE !
