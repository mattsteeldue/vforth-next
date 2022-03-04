\
\ test/parse-name.f
\

NEEDS TESTING

NEEDS PARSE-NAME
NEEDS S"

TESTING F.6.2.2020 - PARSE-NAME

T{ PARSE-NAME abcd S" abcd" S= -> <TRUE> }T
T{ PARSE-NAME   abcde   S" abcde" S= -> <TRUE> }T
\ test empty parse area
T{ PARSE-NAME 
   NIP -> 0 }T    \ empty line
T{ PARSE-NAME    
   NIP -> 0 }T    \ line with white space

T{ : parse-name-test ( "name1" "name2" -- n ) 
   PARSE-NAME PARSE-NAME S= ; -> }T

T{ parse-name-test abcd abcd -> <TRUE> }T
T{ parse-name-test  abcd   abcd   -> <TRUE> }T
T{ parse-name-test abcde abcdf -> <FALSE> }T
T{ parse-name-test abcdf abcde -> <FALSE> }T
T{ parse-name-test abcde abcde 
    -> <TRUE> }T
T{ parse-name-test abcde abcde  
    -> <TRUE> }T    \ line with white space
