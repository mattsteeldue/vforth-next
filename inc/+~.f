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
NEEDS PARSE
\
\ accept a string and append it to the counted string at "ha", which
\ must be the last one created on Heap (it is extended in place).
\ return the same Heap-Pointer to the counted string on Heap
\
\ a block created by HEAP is: forward pointer, data, a zero cell and
\ a back pointer; HP points just after it. So the new text goes right
\ after the old one, then the tail is laid down again at the new end:
\ the string stays a counted z-string.
\ PARSE, not WORD: no leading " is skipped, so  +" "  appends nothing.
\ h0, the start of the block, is read from the back pointer and not
\ taken as ha-2: when HEAP had to skip to the next page, the forward
\ pointer is left at the old HP, in the previous page.
\
\ Errors:
\ #-18 Parsed string overflow.          more than 255 characters
\ #14  Patching the wrong definition.   ha is not the last heap block
\ #12  Heap full.                       the block would grow past offset
\                                       $1F58, BASIC's UDG area $FF58,
\                                       that PAGE-WATERMARK keeps clear
\
BASE @ DECIMAL
\
: +" ( ha -- ha )
    HP@ FAR CELL- @ SWAP        \ h0 ha        start of the block
    [CHAR] " PARSE >R           \ h0 ha a1     R: n
    OVER FAR C@                 \ h0 ha a1 len
    DUP R@ + 255 > -18 ?ERROR   \ h0 ha a1 len
    2 PICK + 5 + HP@ -          \ h0 ha a1 f   ha+len+5 is HP when last
    14 ?ERROR                   \ h0 ha a1
    HP@ $1FFF AND R@ + $1F58 >  \ h0 ha a1 f   new end, as page offset
    12 ?ERROR                   \ h0 ha a1
    OVER FAR DUP C@ + 1+        \ h0 ha a1 a2  end of the string so far
    R@ CMOVE                    \ h0 ha        append the text
    R@ HP +!                    \ h0 ha        HP moves n bytes ahead
    DUP FAR DUP C@ R> +         \ h0 ha a len  new length
    SWAP C!                     \ h0 ha
    OVER HP@ FAR CELL- !        \ h0 ha        back pointer
    0 HP@ FAR 4 - !             \ h0 ha        zero pad
    HP@ ROT FAR !               \ ha           forward pointer
;
\
BASE !
