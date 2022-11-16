\
\ }sgn.f
\

\ Standard >NUMBER
\ determines if char in addr a is a sign (+ or -), and in that case increments
\ a flag. Returns f as the sign, true for negative, false for positive.
\ called by NUMBER and >EXP
: >sgn  ( d a u -- d2 a2 u2 f )
    >r                      \ d a           R: u 
    dup c@                  \ d a c
    dup                     \ d a c c
    [ CHAR - ] Literal      \ d a c c -
    =                       \ d a c c=-
    If                      \ d a c
        drop                \ d a
        1+                  \ d a+1
        1 dpl +!            \ d a+1
        1                   \ d aè1 tf
    Else                    \ d a c
        [ CHAR + ] Literal  \ d a c +
        =                   \ d a c=+
        If                  \ d a 
            1+              \ d a+1
            1 dpl +!        \ d a+1
        Then                
        0                   \ d a+1 ff
    Then
    r>                      \ d a f u    
    swap
    ;

