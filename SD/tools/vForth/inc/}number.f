\
\ }number.f
\

\ Standard >NUMBER
\ Converts digits from the string a,u accumulating the digits in the number d
\ Conversion stops when any character that is not a legal digit is encountered
\ returning the result d2 and the string parameters a2 n2 for the remaining
\ characters in the string

: >number  ( d a u -- d2 a2 u2 )
    >r              \ d a           R: u 
    Begin
        dup >r      \ d a           R: u a
        c@          \ d c 
        base @      \ d c b 
        digit       \ d n 1 | d 0 
    While
        swap        \ dL n dH 
        base @      \ dL n dH b 
        um*         \ dL n d 
        drop rot    \ n dH dL 
        base @      \ n dH dL b 
        um*         \ n dH d 
        d+          \ d 
        dpl @ 1+    \ d m 
        If
            1 dpl +!
        Then
        r> 1+       \ d a           R: u
        r> 1- >r    \ d a           R: u+1
    Repeat
    r>              \ d a 
    r>              \ d a u    
    ;

