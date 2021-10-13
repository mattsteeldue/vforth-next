//  ______________________________________________________________________ 
//
//  next-opt.asm
// 
//  ZX Spectrum Next - peculiar definitions
//  ______________________________________________________________________ 

//  ______________________________________________________________________ 
//
// reg@         n -- b
// read Next REGister n giving byte b

                Colon_Def REG_FETCH, "REG@", is_normal
                dw      LIT, $243B          
                dw      PSTORE
                dw      LIT, $253B          
                dw      PFETCH
                dw      EXIT

//  ______________________________________________________________________ 
//
// reg!         b n --
// write value b to Next REGister n 

                Colon_Def REG_STORE, "REG!", is_normal
                dw      LIT, $243B          
                dw      PSTORE
                dw      LIT, $253B          
                dw      PSTORE
                dw      EXIT

//  ______________________________________________________________________ 
//
// mmu7@        -- n
// query current page in MMU7 8K-RAM : 0 and 223

                Colon_Def MMU7_FETCH, "MMU7@", is_normal
                dw      LIT, 87, REG_FETCH
                dw      EXIT

//  ______________________________________________________________________ 
//
// mmu7!        n -- 
// set MMU7 8K-RAM page to n given between 0 and 223
// optimized version that uses NEXTREG n,A Z80n op-code.

                New_Def MMU7_STORE, "MMU7!", is_code, is_normal
                pop     hl
                ld      a, l
                nextreg 87, a

                next

//  ______________________________________________________________________ 
//
// >far         ha -- a n
// decode bits 765 of H as one of the 8K-page between 64 and 71 (40h-47h)
// take lower bits of H and L as an offset from E000h
// then return address  a  between E000h-FFFFh 
// and page number n  between 64-71 (40h-47h)
// For example, in hex: 
//   0000 >FAR  gives  40.E000
//   1FFF >FAR  gives  40.FFFF
//   2000 >FAR  gives  41.E000
//   3FFF >FAR  gives  41.FFFF
//   EFFF >FAR  gives  47.EFFF
//   FFFF >FAR  gives  47.FFFF
//                New_Def TO_FAR, ">FAR", is_code, is_normal
//                pop     de
//                ld      a, d
//                and     $E0
//                rlca
//                rlca
//                rlca
//                add     $40
//                ld      l, a
//                ld      h, 0
//                ld      a, d
//                or      $E0
//                ld      d, a
//                push    hl
//                push    de
//                next

//  ______________________________________________________________________ 
//
// <far         a n  -- ha
// given an address E000-FFFF and a page number n (64-71 or 40h-47h)
// reverse of >FAR: encodes a FAR address compressing
// to bits 765 of H, lower bits of HL address offset from E000h
//                New_Def FROM_FAR, "<FAR", is_code, is_normal
//                pop     de                  // page number in e
//                pop     hl                  // address in hl
//                ld      a, e
//                sub     $40                 // reduced to 0-7
//                rrca
//                rrca
//                rrca
//                ld      d, a                // save to d bits 765 
//                ld      a, h                // drops
//                and     $1F
//                or      d
//                ld      h, a
//
//                psh1

//  ______________________________________________________________________ 
//
// m_p3dos      n1 n2 n3 n4 a -- n5 n6 n7 n8  f 
// NextZXOS call wrapper.
//  n1 = hl register parameter value
//  n2 = de register parameter value 
//  n3 = bc register parameter value
//  n4 =  a register parameter value
//   a = routine address in ROM 3
// ----
//  n5 = hl returned value
//  n6 = de returned value 
//  n7 = bc returned value
//  n8 =  a returned value
//   f
                New_Def M_P3DOS, "M_P3DOS", is_code, is_normal
                pop     de                  // dos call entry address in de
                pop     hl                  // a register
                ld      a, l
                exx
                pop     bc
                pop     de
                pop     hl
                exx

                push    bc
                push    ix

                ld      (SP_Saved), sp
                ld      sp, Cold_origin - 5
                ld      c, 7                // use 7 RAM Bank

                rst     08
                db      $94

                ld      sp, (SP_Saved)
                push    ix
                pop     hl
                ld      (IX_Echo), hl
//              nop
                pop     ix
                ex      (sp), hl            // hl argument and retrieve bc
                push    de
                push    bc
                ld      c, l
                ld      b, h

                ld      h, 0
                ld      l, a
                push    hl
                sbc     hl, hl              // -1 for OK ; 0 for KO but now...
                inc     hl                  //  0 for OK ; 1 for ko
                
                psh1

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


 