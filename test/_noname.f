\
\ test/_noname.f
\ 
\ since filename :NONAME.f is an illegal filename


NEEDS TESTING

NEEDS :NONAME

TESTING F.6.2.0455 - :NONAME

VARIABLE nn1
VARIABLE nn2
T{ :NONAME 1234 ; nn1 ! -> }T
T{ :NONAME 9876 ; nn2 ! -> }T
T{ nn1 @ EXECUTE -> 1234 }T
T{ nn2 @ EXECUTE -> 9876 }T

