\
\ .fat-time.f
\
\
\ emit a time given a MSDOS format time-number
\ seconds : bits 0-4, values between 0 and 58, even values only
\ minutes : bits 5-10, values between 0 and 59.
\ hours   : bits 11-15, values between 0 and 23
: .FAT-TIME ( n -- )
    <# \ DUP $1F AND 2* 59 MIN 0 # # [CHAR] : HOLD  2DROP  \ seconds
        #5 RSHIFT  
        DUP $3F AND #59 MIN 0 # # [CHAR] : HOLD  2DROP  \ minutes
        #6 RSHIFT
        0 # #  \ hours
     #> TYPE
;
