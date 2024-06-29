\
\ inc/zap~.f
\

.( ZAP" ) 

\ produce a .nex file for standalone execution 

\ Usage:
\ ' cccc  ZAP" filename" 

\ Example:
\ INCLUDE DEMO/CHOMP-CHOMP.F
\ NEEDS ZAP 
\ ' GAME  ZAP" chomp-chomp.nex"  

NEEDS CHECKSUM
NEEDS OPEN">

BASE @

DECIMAL

\ ________________________________________________________________________

\ Header pointer
VARIABLE NEX-HEADER

\ calc address of offset u inside NEX-HEADER
\ enforce u to be between 0 and 511
: +HEADER ( u -- a )
    DUP 512 U< NOT 33 ?ERROR    \ #33 Programming error
    NEX-HEADER @ + 
;

\ 8k page size
  8 1024 * CONSTANT PAGE-SIZE

\ MMU7 address
  $E000    CONSTANT PAGE-ADDR

\ File-handle
VARIABLE FHANDLE

\ If f is true, raise error n, but first close FHANDLE
: ?ERROR-CLOSE ( f n -- )
    SWAP IF
        FHANDLE @ F_CLOSE DROP
        ERROR
    THEN
;

\ write 8k page b to FHANDLE
: FWRITE-PAGE ( b -- )
    MMU7!
    PAGE-ADDR PAGE-SIZE 
    FHANDLE @ 
    F_WRITE 47 ?ERROR-CLOSE
;

\ ordered list of BANK
\ 5,2,0,1,3,4,6,7,8,9,10,...,111
CREATE BANK-LIST 
HERE
     5 C,  2 C,  0 C,  1 C,  
\    3 C,  4 C,  6 C,  7 C,  
     8 C, 
    16 C, 
\   17 C, 18 C, 19 C,
HERE SWAP - CONSTANT BANK-NUM
    
\ ________________________________________________________________________
    
\ ZAP" 
\ Usage:
\ ' cccc ZAP" filename" 
\ Given a xt, create or overwrite "filename.nex"
: ZAP" ( xt -- CCCC )
    
    \ first save current COLD 
\   ['] COLD >BODY       @ >R
\   ['] COLD >BODY CELL+ @ >R

    \ put xt as first definition to execute at COLD start.
\   ['] COLD >BODY       !
\   ['] BYE
\   ['] COLD >BODY CELL+ !
    
    \ accept filename string and open for write (overwrite)
    OPEN">
    FHANDLE !
    
    \ write nex-header
    0 +HEADER 512               \ a u    
    FHANDLE @ F_WRITE           \ f
    47 ?ERROR-CLOSE
    
    \ save pages
    BANK-NUM 0 DO
        BANK-LIST I + C@ 
        DUP .
        2* DUP 1+ SWAP 
        FWRITE-PAGE 
        FWRITE-PAGE 
    LOOP
    
    \ restore COLD
\   R> ['] COLD >BODY CELL+ !
\   R> ['] COLD >BODY       !

    \ close down
    FHANDLE @ F_CLOSE 42 ?ERROR
;

\ ________________________________________________________________________


\ 512 bytes header (https://wiki.specnext.dev/NEX_file_format)
HERE 512 ALLOT  
NEX-HEADER !  
NEX-HEADER @ 512 ERASE 

\ "Next" string
\ string with NEX file version, currently "V1.0", "V1.1", or "V1.2"

CHAR   N   0 +HEADER C!
CHAR   e   1 +HEADER C!
CHAR   x   2 +HEADER C!
CHAR   t   3 +HEADER C!
CHAR   V   4 +HEADER C!
CHAR   1   5 +HEADER C!
CHAR   .   6 +HEADER C!
CHAR   2   7 +HEADER C!


\ RAM required: 0 = 768k, 1 = 1792k

  1  8  +HEADER  C!
 

\ Number of 16k Banks to Load: 0-112
\ (see also the byte array at offset 18, which must yield this count)
\ It's calculated later.

  5  9  +HEADER  C! 


\ Loading-screen blocks in file (bit-flags):
\ 128 = no palette block, 16 = Hi-Colour, 8 = Hi-Res, 4 = Lo-Res, 2 = ULA, 1 = Layer2
\ The loader does use common banks to load the graphics into, and show it from, 
\ i.e. bank5 for all ULA related modes and banks 9,10 and 11 for Layer2 graphics 
\ (loading these banks afterwards as regular bank will thus replace the shown data on screen).
\ Only Layer2, Tilemap and Lo-Res screens expect the palette block (unless +128 flag set). 
\ While one can include multiple screen data in single file (setting up all relevant bits), 
\ the recommended/expected usage is to have only one type of screen in NEX file.

  0 10  +HEADER  C! 
    

\ Border colour: 0-7  

  7 11  +HEADER  C!        
 
 
\ Stack Pointer
 
  8 +ORIGIN @ 12  +HEADER  ! 


\ Program counter (0 = don't run, just load)

 $7634        14  +HEADER  ! 
\ 4 +ORIGIN   14  +HEADER  ! 
\ 0           14  +HEADER  ! 


\ "Number of extra files"

  0 16  +HEADER  ! 
 
 
\ byte flag (0/1) of 16k banks included in the file - this array is in regular 
\ order 0..111, i.e. bank5 in file will set 1 to header byte at offset 18+5 = 23,
\ but the 16kiB of data for bank 5 are first in the file (order of bank data
\ in file is: 5,2,0,1,3,4,6,7,8,9,10,...,111) 

\ Nine pages +1 must be saved (128k Memory + bank $08)
  1  18       +HEADER C!        \ bank 5 = 8k pages $0A,0B (lower 16K RAM)
  1  18 1+    +HEADER C!        \ bank 2 = 8k pages $04,05 
  1  18 2+    +HEADER C!        \ bank 0 = 8k pages $00,01 
  1  18 3 +   +HEADER C!        \ bank 1 = 8k pages $02,03

\ 1  18 4 +   +HEADER C!        \ bank 3 = 8k pages $06,07
\ 1  18 5 +   +HEADER C!        \ bank 4 = 8k pages $08,09
\ 1  18 6 +   +HEADER C!        \ bank 6 = 8k pages $0C,0D
\ 1  18 7 +   +HEADER C!        \ bank 7 = 8k pages $0E,0F

  1  18 8 +   +HEADER C!        \ bank 8 = 8k pages $10,11

\ Heap
  1  18 16 +  +HEADER C!        \ bank 16 = 8k pages $20,21
\ 1  18 17 +  +HEADER C!        \ bank 17 = 8k pages $22,23
\ 1  18 18 +  +HEADER C!        \ bank 18 = 8k pages $24,25
\ 1  18 19 +  +HEADER C!        \ bank 19 = 8k pages $26,27

\ now compute: Number of 16k Banks to Load: 0-112
  18 +HEADER  112  CHECKSUM  9  +HEADER  C! 


\ Layer2 "loading bar" 0 = OFF, 1 = ON (works only in combination with Layer2 screen data)

  0 130  +HEADER  C! 


\ "Loading bar" colour (0..255) (for 640x256x4 mode the byte defines pixels pair)   

  0 131  +HEADER  C! 


\ Loading delay per bank (0..255 amount of frames), 0 = no delay

  0 132  +HEADER  C! 


\ Start delay (0..255 amount of frames), 0 = no delay

  0 133  +HEADER  C! 


\ Preserve current Next-Registers values (0 = reset machine state, 1 = preserve)

  0 134  +HEADER  C! 
  
  
\ Required core version, three bytes 0..15 "major", 0..15 "minor", 0..255 "subminor"
\  version numbers. (core version is checked only when reported machine-ID is 10 = "Next",
\ on other machine or emulator=8 the latest loaders will skip the check)

  3 135  +HEADER  C! 
  0 136  +HEADER  C! 
  0 137  +HEADER  C! 


\ Timex HiRes 512x192 mode colour, encoded as for port 255 = bits 5-3. 
\ I.e. values 0, 8, 16, .., 56 (0..7 * 8)
\ When screens 320x256x8 or 640x256x4 are used, this byte is re-used as palette 
\ offset for Layer 2 mode, values 0..15

  1 138  +HEADER  C!  


\ Entry bank = bank to be mapped into slot 3 (0xC000..0xFFFF address space), 
\ the "Program Counter" (header offset +14) and "File handle address" (header offset +140) 
\ are used by NEX loader after the mapping is set 
\ (The default ZX128 has bank 0 mapped after reset, which makes zero value nice default).

  0 139  +HEADER  C!   


\ File handle address: 0 = NEX file is closed by the loader, 1..0x3FFF values 
\ (1 recommended) = NEX loader keeps NEX file open and does pass the file handle in 
\ BC register, 0x4000..0xFFFF values (for 0xC000..0xFFFF see also "Entry bank") = NEX 
\ loader keeps NEX file open and the file handle is written into memory at the desired address.

  0 140  +HEADER  !  


BASE !
