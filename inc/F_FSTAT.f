\
\ f_fstat.f
\

BASE @

\ Given open filehandle, get file information/status
\ return 0 on success, True flag on error
\ The following details are returned in the 11-byte buffer:
\ +0(1) '*'
\ +1(1) $81
\ +2(1) file attributes (MS-DOS format)
\ +3(2) timestamp (MS-DOS format)
\ +5(2) datestamp (MS-DOS format)
\ +7(4) file size in bytes
( F_FSTAT  via RST 08 hook code test )
CODE F_FSTAT ( a fh -- f ) 

    HEX 
    E1 C,               \  pop   hl|
    7D C,               \  ld    a'|   l|
    E1 C,               \  pop   hl|
    
    DD C, E5 C,         \  push  ix|
    D5 C,               \  push  de|
    C5 C,               \  push  bc|

    \ for dot-command compatibility  
    E5 C,               \  push  hl| 
    DD C, E1 C,         \  pop   ix|
    
    F3 C,               \  di    
    CF C, A1 C,         \  rst   08|   $A1  c,
    FB C,               \  ei

    C1 C,               \  pop   bc| 
    D1 C,               \  pop   de| 
    DD C, E1 C,         \  pop   ix|

    ED C, 62 C,         \  sbchl hl|
    E5 C,               \  push  hl|
    DD C, E9 C,         \  jpix

    FORTH
    SMUDGE

BASE !
