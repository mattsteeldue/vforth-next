\
\ .fat-date.f
\
.( .FAT-DATE )
\
\ emit a date given a MSDOS format date-number: 16 bits are used this way
\ day :  bits 0-4, values between 1 and 31.
\ month: bits 5-8, values between 1 and 12.
\ year:  bits 9-15, must add 1980.
: .FAT-DATE ( n -- )
    <#  DUP $1F AND 1 MAX 0 # # [CHAR] - HOLD  2DROP \ day
        #5 RSHIFT
        DUP $0F AND 1 MAX #12 MIN 0 # # [CHAR] - HOLD  2DROP \ month
        #4 RSHIFT
        #1980 + 0 # # # #  \ year
     #> TYPE
;
