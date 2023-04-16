//  ______________________________________________________________________ 
// 
//  system.asm
//  ______________________________________________________________________ 

// Registers:
//
//      BC: Instruction Pointer
//      DE: 
//      HL: W register
//      SP: Calc stack Pointer
//      IX: Inner-Interpreter Address

//  ______________________________________________________________________
//
// ZX-Spectrum standard system variables
SCR_CT          equ     $5C8C                   // SCR-CT system variable
LASTK           equ     $5C08                   // LASTK system variable
BORDCR          equ     $5C48                   // BORDCR system variable
FLAGS2          equ     $5C6A                   // for caps-lock

//  ______________________________________________________________________
//
// Flag constants 
TRUE_FLAG       equ     $FFFF
FALSE_FLAG      equ     $0000

//  ______________________________________________________________________
//
// Ascii char constants
NUL_CHAR        equ     $00
COMMA_CHAR      equ     $06
BACKSPACE_CHAR  equ     $08
CR_CHAR         equ     $0D
BLANK_CHAR      equ     $20  
QUOTE_CHAR      equ     "'"
DQUOTE_CHAR     equ     '"' 
UNDERSCORE_CHAR equ     $5F
SOLIDBLOCK_CHAR equ     $8F
HALFBLOCK_CHAR  equ     $8C
LC_A_CHAR       equ     $61                 // lower-case "a"
LC_Z_CHAR       equ     $7A                 // lower-case "z"


//  ______________________________________________________________________
//

                // emulate something like:  ld hl,rp
ldhlrp          macro
                ld      hl,(RP_Pointer)
                endm

                // emulate something like:  ld rp,hl
ldrphl          macro
                ld      (RP_Pointer),hl
                endm

//  ______________________________________________________________________
//
//  Inner interpreter next-address pointer. This is 2T-state faster than "jp address"
next            macro
                jp      (ix)
                endm

psh1            macro
                push    hl
                jp      (ix)
                endm

psh2            macro
                push    de
                push    hl
                jp      (ix)
                endm

//  ______________________________________________________________________
//
// Bit constants in length-byte

SMUDGE_BIT      equ     %00100000               // $20
IMMEDIATE_BIT   equ     %01000000               // $40
END_BIT         equ     %10000000               // $80


//  ______________________________________________________________________
//
//  To create Forth words using this (nice) Assembler, we have to use the two following
//  pointers 
temp_NFA        defl    0
last_NFA        defl    0
len_NFA         defl    0

Dict_Ptr        defl    0
Heap_Ptr        defl    $0002
Prev_Ptr        defl    0
mirror_Ptr      defl    0

is_code         equ     0                   // so the direct machine-code starts at CFA 
is_normal       equ     0                   // so the direct machine-code starts at CFA 
is_immediate    equ     IMMEDIATE_BIT       // $40 - the definition is IMMEDIATE.

//  ______________________________________________________________________
//
//  Create a new "low-level" definition
//  This macro is used in the form  Create FORTH_NAME,n,"forth_name" 
//  to create a new Forth Dictionary entry the same way Forth itself would do.
//  A word begins with a Length-Byte in range 1-31. Top 3 msb are used as flags 
//  see SMUDGE_BIT and IMMEDIATE_BIT constant above.
//  It is followed by the Name of the word, i.e. a string expressed in 7-bit Ascii.
//  The last character of the Name must have the msb set to signal the end of it (END_BIT)
//  This macro acts much like the standard Forth definition CREATE

New_Def         macro   label, namec, runcode, bits

Dict_Ptr        defl    $

//              ______________________________________________________________________
//              Heap part


                org     (Heap_Ptr & $1FFF) + $E000

temp_NFA        defl    $                   // save this NFA address to temp_NFA
Latest_Definition defl  Heap_Ptr

                // dummy db directives used to calculate length of namec
                db      namec
len_NFA         defl    $ - temp_NFA
                org     $ - len_NFA         // rewind to temp_NFA and re-do NFA part

                db      len_NFA | END_BIT | bits  // The start of NFA must have msb set to signal the beginning of the sounted string 
                db      namec               // name string in 7-bit ascii, but
                org     $-1                 // alter last byte of Name just above to set
                db      {b $} | END_BIT     // msb as name end 

                dw      Prev_Ptr            // Link to previous definition Name
Prev_Ptr        defl    Heap_Ptr
                
mirror_Ptr      defl    $ 

                dw      Dict_Ptr + 2        // xt
Heap_Ptr        defl    $ - $E000           // save current HP

Current_HP      defl  $ - $E000             // used to set HP once!

//              ______________________________________________________________________
//              Dictionary part

                org     Dict_Ptr

                dw      mirror_Ptr - $E000

label:          if runcode != 0 ; ok        // This is the start address of the direct jp(hl)
                call    runcode ; ok        // for primitive definitions  actual code


                endif           ; ok        // for other definitions it "points" the correct handler
                // Use of "; ok" to suppress "warning[fwdref]"
                                            
last_NFA        defl    temp_NFA            // keep track of NFA saved above
                endm

//  ______________________________________________________________________
//
// Create a "constant"
// The constant value is compiled in first PFA cell
Constant_Def    macro   label, namec, constant_value
                New_Def  label, namec, Constant_Ptr, is_normal
                dw      constant_value
                endm

//  ______________________________________________________________________
//
// Create a "variable"
// The when invoked, a variable returns a pointer, the address of first PFA cell
// this allow creation of "variables" which content is  of any length
Variable_Def    macro   label, namec, initial_value
                New_Def  label, namec, Variable_Ptr, is_normal
                dw      initial_value
                endm

//  ______________________________________________________________________
//
// Create a "user"
// It uses a single byte as offset to calculate the address of the variable
User_Def        macro   label, namec, offset_value
                New_Def  label, namec, User_Ptr, is_normal
                db      offset_value
                endm

//  ______________________________________________________________________
//
// Create a "colon-definition"
// The CFA contains a small routine i.e. "call Enter_Ptr". 
// The PFA, three bytes later, contains the actual Forth definition
Colon_Def       macro   label, namec, bits
                New_Def  label, namec, Enter_Ptr, bits ; ok
                endm

//  ______________________________________________________________________
//

S0_system:      equ     $D0E8               // Address of top of Calc Stack
TIB_system      equ     $D0E8               // TIB grows upwards, Return-Stack downward.
R0_system:      equ     $D188               // Address of top of Return Stack. This is S0 + $00A0
USER_system:    equ     $D188               // User variables zone.
FIRST_system:   equ     $D1E4               // Address of first BUFFER
LIMIT_system:   equ     $E000               // Address of first byte beyond last BUFFER

