//  ______________________________________________________________________ 
//
// blk-fh
                Variable_Def BLK_FH,   "BLK-FH",   1

                New_Def BLK_FNAME,   "BLK-FNAME", Create_Ptr, is_normal  
                db      14, "!Blocks-64.bin", 0
                ds      24

//  ______________________________________________________________________ 
//
// blk-seek     n -- 
// seek block n  within blocks!.bin  file
                Colon_Def BLK_SEEK, "BLK-SEEK", is_normal
                dw  BBUF, MMUL
                dw  BLK_FH, FETCH
                dw  F_SEEK
                dw  LIT, $2D, QERROR
                dw  EXIT

//  ______________________________________________________________________ 
//
// blk-read     n -- 
// seek block n  within blocks!.bin  file
                Colon_Def BLK_READ, "BLK-READ", is_normal
                dw  BLK_SEEK
                dw  BBUF
                dw  BLK_FH, FETCH
                dw  F_READ
                dw  LIT, $2E, QERROR
                dw  DROP
                dw  EXIT

//  ______________________________________________________________________ 
//
// blk-write     n -- 
// seek block n  within blocks!.bin  file
                Colon_Def BLK_WRITE, "BLK-WRITE", is_normal
                dw  BLK_SEEK
                dw  BBUF
                dw  BLK_FH, FETCH
                dw  F_WRITE
                dw  LIT, $2F, QERROR
                dw  DROP
                dw  EXIT

//  ______________________________________________________________________ 
//
// blk-init     n -- 
// seek block n  within blocks!.bin  file
                Colon_Def BLK_INIT, "BLK-INIT", is_normal
                dw  BLK_FH, FETCH, F_CLOSE, DROP
                dw  BLK_FNAME, ONE_PLUS
                dw  HERE, THREE, F_OPEN         // open for update (read+write)
                dw  LIT, $2C, QERROR
                dw  BLK_FH, STORE
                dw  EXIT

//  ______________________________________________________________________ 
//
// #sec
// number of 512 Byte "sector" available on thie sysstem.
// it addd up to 16 MByte of data that can be used as source or pool for almost anything.

                Constant_Def NSEC , "#SEC", 32767

//  ______________________________________________________________________ 

