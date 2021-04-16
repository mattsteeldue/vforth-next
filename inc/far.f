\
\ far.f
\
\ Convert an heap-pointer-address ha into a real address
\ between E000h and FFFh and fit the correct 8K page on MMU7
: FAR  ( ha -- a )
    >FAR MMU7! ;
