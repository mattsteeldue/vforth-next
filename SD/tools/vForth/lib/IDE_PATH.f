\
\ ide_path.f
\
.( IDE_PATH )
\
\ Manage path
\
\ a : address of pathspec (terminated with $ff)
\ b : 0 change path
\     1 get path
\     2 make path
\     3 delete path

BASE @

: IDE_PATH ( a b -- f )      
    >R 0 0 R> 
    [ HEX ] 01B1 M_P3DOS [ DECIMAL ]
    >R 2DROP 2DROP R> 
;


\ accept text from current input and set a suitable string for IDE_PATH
: PATH>PAD ( -- )
    BL WORD COUNT >R PAD R@ 
    CMOVE 
    $FF PAD R> + C!
;


\ wrapper around IDE_PATH having b as operation selection
: PATH_OP ( b -- )
    PATH>PAD
    PAD SWAP IDE_PATH  
    [ DECIMAL ] 44 ?ERROR
;


\ set current path, used in the form
\   SETCD cccc
: SETCD ( -- ) 
    0 PATH_OP
;


\ get current path, uses PAD as result buffer
\ used in the form
\   GETCD .
: GETCD ( -- ) 
    1 PATH_OP
;


\ create path, used in the form
\   MAKEDIR cccc
: MAKEDIR ( -- ) 
    2 PATH_OP
;


\ remove path, used in the form
\   REMOVEDIR cccc
: REMOVEDIR ( -- ) 
    3 PATH_OP
;


BASE !
