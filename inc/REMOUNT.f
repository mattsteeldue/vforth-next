\
\ remount.f
\
\ v-Forth 1.8 - NextZXOS version - build 2025-01-01
\ MIT License (c) 1990-2025 Matteo Vitturi 
\
\ REMOUNT via IDE_MOUNT    $01d2
\ This definitions uses M_P3DOS primitive.
\ M_P3DOS expects hl, de, bc, a, and address of service routine
\         returns hl, de, bc, a, and status 0=ok 1=ko
\
: REMOUNT  ( -- )
  BLK-FH @ F_CLOSE DROP         \ close BLOCKs file and ignore any error
  0 0 0 0 [ HEX ] 01D2 M_P3DOS  \ invoke IDE_MOUNT NextZXOS service
  >R 2DROP 2DROP R>             \ keep only returned status 0=ok 1=ko
  CR
  IF                            \ there is a problem, maybe an open file
    ." Can't unmount, there's something still open." CR
    ." Use F_CLOSE manually, then retry." CR
  ELSE
    ." Remove/insert SD and press Y "
    BEGIN
        CURS KEY UPPER          \ wait for Y
        [CHAR] Y =
    UNTIL
    0 0 0 1 [ HEX ] 01D2 M_P3DOS \ invoke IDE_MOUNT NextZXOS service
    DROP 2DROP 2DROP            \ ingnore everything.
  THEN                          \ if it works, then you can...
  BLK-INIT [ DECIMAL ]          \ reopen BLOCKs f!ile using BLK-FNAME.
;

