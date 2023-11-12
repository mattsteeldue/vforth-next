//  ______________________________________________________________________ 
//
//  next-opt.asm
// 
//  ZX Spectrum Next - peculiar definitions
//  ______________________________________________________________________ 

//  ______________________________________________________________________ 
//
// f_seek       d u -- f
// Seek to position d in file-handle u.
// Return a false-flag 0 on success, True flag on error
                New_Def F_SEEK, "F_SEEK", is_code, is_normal
                 exx
                 pop     hl                  // file-handle
                 ld      a, l
                 pop     bc                  // bc has high-word of d
                 pop     de
                exx
                push    ix       
                push    de
                push    bc                  // save Instruction Pointer           
                 exx 
                 ld      ix, 0
                 di
                 rst     $08     
                 db      $9F
F_Seek_Exit:                
                ei
                pop     bc                  // restore Instruction Pointer
                pop     de
                pop     ix
                sbc     hl, hl              // to get 0 or -1
                psh1

//  ______________________________________________________________________ 
//
// f_close      u -- f
// Close file-handle u.
// Return 0 on success, True flag on error

                New_Def F_CLOSE, "F_CLOSE", is_code, is_normal
                
                pop     hl
                ld      a, l                // file-handle
                push    ix
                push    de
                push    bc                  // Save Instruction pointer
                di
                rst     $08     
                db      $9B
                jr      F_Seek_Exit
//              ei
//              pop     de                
//              pop     bc
//              pop     ix
//              sbc     hl, hl
//              psh1

//  ______________________________________________________________________ 
//
// f_sync      u -- f
// Close file-handle u.
// Return 0 on success, True flag on error

                New_Def F_SYNC, "F_SYNC", is_code, is_normal
                pop     hl
                ld      a, l                // file-handle
                push    ix
                push    de
                push    bc
                di
                rst     $08     
                db      $9C
                jr      F_Seek_Exit
//              ei
//              pop     de
//              pop     bc
//              pop     ix
//              sbc     hl, hl
//              psh1

//  ______________________________________________________________________ 
//
// f_fgetpos    u -- d f
// Seek to position d in file-handle u.
// Return a false-flag 0 on success, True flag on error
                New_Def F_FGETPOS, "F_FGETPOS", is_code, is_normal
                 pop     hl
                 ld      a, l                // file-handle
                 push    ix                  
                 push    de
                 push    bc
                 di
                 rst     $08   
                 db      $A0
                 ei
                exx
                pop     bc                  // IP
                pop     de                  // Return Stack Pointer
                pop     ix
                 exx
                 push    de
                 push    bc
                 sbc     hl, hl
                 push    hl
                exx
                next
 
//  ______________________________________________________________________ 
//
// f_read       a n u -- n f
// Read b bytes from file-handle u to address a
// Return the actual number n of bytes read 
// Return 0 on success, True flag on error
                New_Def F_READ, "F_READ", is_code, is_normal
                 exx
                 pop     hl
                 ld      a, l                // file-handle
                 pop     bc                  // bc has bytes to read
                 ex      (sp), ix            // ix has address
                exx
                push    de                  // Save Return Stack pointer
                push    bc                  // Save Instruction pointer 
                 exx
                 di
                 rst     $08     
                 db      $9D
F_Read_Exit:                
                ei
                exx
                pop     bc                  // Restore Instruction pointer 
                pop     de                  // Restore Return Stack pointer
                pop     ix                  // Restore ix
                 exx
                 push    de                  // bytes involved in i/o operation
                 sbc     hl, hl
                 push    hl
                exx
                next

//  ______________________________________________________________________ 
//
// f_write      a n u -- n f
// Write bytes currently stored at address a to file-handle u.
// Return the actual n bytes written and 0 on success, True flag on error.
                New_Def F_WRITE, "F_WRITE", is_code, is_normal
                 exx
                 pop     hl            
                 ld      a, l                // file-handle
                 pop     bc                  // bc has bytes to read
                 ex      (sp), ix            // ix has address
                exx
                push    de                  // Save Return Stack pointer
                push    bc                  // Save Instruction pointer 
                 exx
                 di
                 rst     $08     
                 db      $9E
                 jr F_Read_Exit
//                ei
//                exx
//                pop     de                  // Restore Return Stack pointer
//                pop     bc                  // Restore Instruction pointer 
//                pop     ix                  // Restore ix
//                 exx
//                 push    de                  // bytes involved in i/o operation
//                 sbc     hl, hl
//                 push    hl
//                exx
//                next

//  ______________________________________________________________________ 
//
// f_open       a1 a2 b -- u f
// open a file 
// a1 (filespec) is a null-terminated string, such as produced by ," definition
// a2 is address to an 8-byte header data used in some cases.
// b is access mode-byte, that is a combination of:
// any/all of:
//   esx_mode_read          $01 request read access
//   esx_mode_write         $02 request write access
//   esx_mode_use_header    $40 read/write +3DOS header
// plus one of:
//   esx_mode_open_exist    $00 only open existing file
//   esx_mode_open_creat    $08 open existing or create file
//   esx_mode_creat_noexist $04 create new file, error if exists
//   esx_mode_creat_trunc   $0c create new file, delete existing
// Return file-handle u and 0 on success, True flag on error
                New_Def F_OPEN, "F_OPEN", is_code, is_normal
                 exx 
                 pop     bc                  // file-mode
                 ld      b, c                // file-mode
                 pop     de                  // 8-bytes buffer if any
                 ex      (sp), ix            // filespec nul-terminated
                exx 
                push    de                  // Save Return Stack pointer
                push    bc                  // Save Instruction pointer 
                 exx 
                 ld      a, "*"
                 di
                 rst     $08     
                 db      $9A
F_Open_Exit:                
                 ei
                 ld      e, a                // return the handle-number
                 ld      d, 0
                jr F_Read_Exit

//   \ CREATE FILENAME ," test.txt"   \ new Counted String
//   \ FILENAME 1+ PAD 1 F_OPEN
//   \ DROP
//   \ F_CLOSE


//  ______________________________________________________________________ 
//
// f_opendir    a1 -- u f
// open a file 
                New_Def F_OPENDIR, "F_OPENDIR", is_code, is_normal
                ex      (sp), ix            // filespec nul-terminated
                push    de                  // Save Return Stack pointer
                push    bc                  // Save Instruction pointer
                ld      b, $10              // file-mode
                ld      a, "C"
                di
                rst     $08     
                db      $A3
                jr      F_Open_Exit


//  ______________________________________________________________________ 
//
// f_readdir    a1 a2 b -- u f
// open a file 
                New_Def F_READDIR, "F_READDIR", is_code, is_normal
                 exx
                 pop     hl
                 ld      a, l
                 pop     de
                 ex      (sp), ix            // filespec nul-terminated
                exx
                push    de                  // Save Return Stack pointer
                push    bc                  // Save Instruction pointer
                 exx
                 di
                 rst     $08     
                 db      $A4
                 jr      F_Open_Exit


