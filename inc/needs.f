( NEEDS )
\ check for cccc exists in vocabulary
\ if it doesn't then  INCLUDE  inc/cccc.F
DECIMAL
\ temp filename cccc.f as counted string zero-padded
CREATE   NEEDS-W     35 ALLOT   \ 32 + .F + 0x00 = len 35
\ temp complete path+filename
CREATE   NEEDS-FN    40 ALLOT
\ constant path
create   needs-inc   ," inc/"
create   needs-lib   ," lib/"

\ Concatenate path at a and filename and include it
\ No error is issued if filename doesn't exist.
: NEEDS/  ( a -- )             \ a is address of Path passed
  COUNT TUCK                   \ n a n
  NEEDS-FN SWAP CMOVE          \ n       \ Path
  NEEDS-FN +                   \ a1+n    \ concat
  NEEDS-W 1+ SWAP 35 CMOVE     \         \ Filename
  NEEDS-FN                     \ a3
  PAD 1 F_OPEN
  IF 43 MESSAGE
  ELSE F_INCLUDE
  ENDIF
;

\ include  "path/cccc.f" if cccc is not defined
\ filename cccc.f is temporary stored at NEEDS-W
: NEEDS-PATH  ( a -- )
  -FIND 0= IF
    NEEDS-W    35 ERASE           \ a
    HERE C@ 1+ HERE OVER          \ a n here n
    NEEDS-W    SWAP CMOVE         \ a n
    NEEDS-W    +                  \ a a1+n
    [ HEX 662E DECIMAL ] LITERAL  \ a a1+n ".F"
    SWAP !                        \ a
    NEEDS/
  ENDIF ;

\ check for cccc exists in vocabulary
\ if it doesn't then  INCLUDE  inc/cccc.F
\ search in inc subdirectory
: NEEDS
  NEEDS-INC NEEDS-PATH     \ search in "inc/"
\ NEEDS-W C@ MINUS >IN +!  \ re-feed cccc
\ NEEDS-LIB NEEDS-PATH     \ 2nd chance at "lib/"
;
