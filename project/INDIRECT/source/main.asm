//  ______________________________________________________________________ 
//
//  main.asm
//  ______________________________________________________________________ 
// 
//  v-Forth 1.5 NextZXOS version 
//  build 20220227
// 
//  Inirect-Thread version.
// 
//  NextZXOS version
//  ______________________________________________________________________
// 
//  This work is available as-is with no whatsoever warranty.
//  Copying, modifying and distributing this software is allowed 
//  provided that the copyright notice is kept.  
//  ______________________________________________________________________
// 
//  by Matteo Vitturi, 1990-2022
// 
//  https://sites.google.com/view/vforth/vforth15-next
//  https://www.oocities.org/matteo_vitturi/english/index.htm
//   
//  This is the complete compiler for v.Forth for SINCLAIR ZX Spectrum Next.
//  Each line of this source list mustn't exceed 80 bytes.
//  Z80N (ZX Spectrum Next) extension is available.
// 
//  This list has been tested using the following configuration:
//      - CSpect emulator V.2.12.30
//  ______________________________________________________________________
// 
//  Z80 Registers usage map
// 
//  AF 
//  BC - Instruction Pointer: should be preserved during ROM/OS calls
//  DE - Working
//  HL - Working 
// 
//  AF'- Sometime used for backup purpose
//  BC'- Not used
//  DE'- Not used
//  HL'- Not used: (saved at startup)
// 
//  SP - Calculator Stack Pointer
//  IX - Inner interpreter "next" address pointer. This way jp (ix) is 2T-state faster than JP next
//  IY - (ZX System: must be preserved to interact with standard ROM)
// 
//  ______________________________________________________________________
// 
//  _________________
// 
//  FORTH DEFINITIONS
//  _________________

                OPT     --zxnext    
//  ______________________________________________________________________
//
// this controls some debugging code in L0.asm
//  0 for final binary release.
//  1 for debugging with Visual Studio Code and DeZog
// -1 for for binary comparison with Forth generated code.
DEBUGGING       equ     -1
//
//  ______________________________________________________________________

                if ( -1 == DEBUGGING ) 
ORIGIN          equ     $62E6                   // for binary comparison
                endif
//  ______________________________________________________________________

                if (  0 == DEBUGGING ) 
ORIGIN          equ     $6366                   // binary
                endif
//  ______________________________________________________________________

                if (  1 == DEBUGGING ) 
ORIGIN          equ     $8080                   // for DeZog
                endif
//  ______________________________________________________________________

                DEVICE  ZXSPECTRUMNEXT

                ORG     ORIGIN

                if ( -1 == DEBUGGING ) 
                ds 128                            // for binary comparison
                endif

//  ______________________________________________________________________
// 
//  Naming convention for Label vs Forth correspondance
//  Forth words are named as they are named for real with some exception to avoid assembler syntax errors.
//    - Leading "0" is converted into "Z_"
//    - Leading "(" is converted into "C_", closing bracket is omitted
//    - Leading numbers are converted in letters: ONE_  TWO_ etc.
//    - Question mark "?" is converted into "Q" or omitted if needed / useful.
//    - Plus sign "+" is converted in _PLUS or ADD_ depending.
//    - Minus sign "-" in L (for Line), MINUS or SUBTRACT depending
//    - Greater-Than sign ">" in _GREATER or TO_ depending
//    - Equal sign "=" is converted in EQUAL
//    - Less-Than sign "<" in _LESS or FROM_ (or TO_ again) depending
//    - Asterisk sign "*" is converted in _MUL or STAR
//    - Slash "/" is converted in _DIV or omitted if it is clear what it means
//    - Exclamation mark "!" is converted in STORE
//    - At-Sign "@" is converted in FETCH
//    - Words that collide with Assembler are normally suffixed with "_OP"

                include "system.asm"
                include "L0.asm"
                include "L1.asm"
                include "L2.asm"
                include "next-opt1.asm"
                include "L3.asm"

// now we save the compiled file so we can either run it or debug it
                SAVENEX OPEN "output/main.nex", ORIGIN
                SAVENEX CORE 3, 0, 0                                // Next core 3.0.0 required as minimum
                SAVENEX CFG  0
                SAVENEX BANK 2, 0
                SAVENEX AUTO
                SAVENEX CLOSE 

//              PAGE 7 ;set 7 page to current slot
//              SAVEBIN "ram7.bin",$C000,$4000 ;- save 4000h begin from C000h of RAM to file
//              SAVEBIN "output/ram2.bin", $8000, 9800 ;- save 3000h begin from 8000h of RAM to file 
                
                SAVETAP "output/F15E.tap", CODE, "forth15e", ORIGIN, 10000

                SAVEBIN "output/forth15E.bin", ORIGIN, 10000

                END
