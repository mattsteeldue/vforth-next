\ 
\ remount.f
\
\ REMOUNT via IDE_MOUNT    $01d2 )

\ This definitions uses M_P3DOS primitive.
\ M_P3DOS expects hl, de, bc, a, and address of service routine
\         returns hl, de, bc, a, and status 0=ok 1=ko
\ 
\ Using REMOUNT staying in Forth, you need to use Basic's REMOUNT no more.
\
\ You can even change the BLOCKs file used by changing the content of
\ BLK-FNAME (counted-string-with zero-padding)
\
\ 
: REMOUNT  ( -- )
  BLK-FH @ F_CLOSE DROP         \ close BLOCKs file and ignore any error
  0 0 0 0 [ HEX ] 01D2 M_P3DOS  \ invoke IDE_MOUNT NextZXOS service  
  >R 2DROP 2DROP R>             \ keep only returned status 0=ok 1=ko
  IF                            \ there is a problem, maybe an open file
    ." Cannot unmount " 
  ELSE
    ." Remove/insert SD and press Y "
    BEGIN               
        KEY UPPER               \ wait for Y
        [CHAR] Y = 
    UNTIL
    0 0 0 1 [ HEX ] 01D2 M_P3DOS \ invoke IDE_MOUNT NextZXOS service  
    DROP 2DROP 2DROP            \ ingnore everything.
  THEN                          \ if it works, then you can...
  BLK-INIT [ DECIMAL ]          \ reopen BLOCKs file using BLK-FNAME.
;

