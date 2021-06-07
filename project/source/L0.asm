//  ______________________________________________________________________ 
//
//  L0.asm
// 
//  Origin-Area and Level-0 definitions
//  ______________________________________________________________________ 


Cold_origin:
                and     a
                jp      ColdRoutine
Warm_origin:
                scf
                jp      WarmRoutine

// +008
SP_Basic:       dw      $D0E6               // These are bits with some "standard" meaning... 0101

// +00A                
                dw      $0E00               

// +00C
Latest_origin:  dw      Latest_Definition   // Latest word (used in Cold_Start) 

// +00E
DEL_Char_Ptr:   dw      $000C               // This is the characther used as "Back-Space"  

// +010
CPU_Id          dw      $B250               // Z80 expressed in base 36

// +012                
S0_origin:      dw      S0_system
R0_origin:      dw      R0_system   
TIB_origin:     dw      TIB_system
WIDTH_origin:   dw      31
WARNING_origin: dw      1
FENCE_origin:   dw      Fence_Word
DP_origin       dw      Fence_Word
VOCLINK_origin: dw      Voclink_Ptr
                dw      FIRST_system
                dw      LIMIT_system

// +026
Block_Face:     db      SOLIDBLOCK_CHAR     // Caps-Lock   Cursor face
Half_Face:      db      HALFBLOCK_CHAR      // Caps-unlock Cursor face
Underscore_Face:db      UNDERSCORE_CHAR     // Underscore  Cursor face
                db      0

// +02A
IX_Echo:        dw      $0000               // Echo IX after NextOS call

// +02C
SP_Saved:       dw      $0000               // Saved SP dufing NextOS call

// +02E
USER_Pointer:   dw      USER_system

// +030
RP_Pointer:     dw      $d188 // R0_system

// +32
// SP_Basic        dw      0


//  ______________________________________________________________________ 

// from this point we can use LDHLRP and LDRPHL Assembler macros
// instead of their equivalent long sequences.

//  ______________________________________________________________________ 

// address for "next" - inner interpreter
// This address must always be pointed by IX
// "next" macro simply does a  jp(ix)  instruction

// Psh2_Ptr:       push    de
// Psh1_Ptr:       push    hl

Next_Ptr:       // This address must always be kept in IX: "next" relies on that

                if ( 1 == DEBUGGING )
                ld      hl, Next_Breakpoint_1
                and     a
                sbc     hl, bc
                jr      nz, Next_Continue
                nop // This is where you have to put a real breakpoint to intercept BC values...
                endif

Next_Continue:
                ld      a, (bc)
                inc     bc                  
                ld      l, a
                ld      a, (bc)
                inc     bc      
                ld      h, a                // hl contains a CFA (xt) of word being executed

// Execute xt i.e. CFA held in HL
Exec_Ptr:
                ld      e, (hl)                
                inc     hl
                ld      d, (hl)
                ex      de, hl
                jp      (hl)                // and jump to it    
                                            // there you'll find the real code or a CALL to a ;code part
                                  
//  ______________________________________________________________________ 
//
// lit          -- x
// puts on top of stack the value of the following word.
// it is compiled in colon definition before a literal number

                New_Def  LIT, "LIT", is_code, is_normal

                ld      a, (bc)      
                inc     bc
                ld      l, a
                ld      a, (bc)      
                inc     bc
                ld      h, a               
                psh1

//  ______________________________________________________________________ 
//
// execute      i*x xt -- j*x
// execution token. usually xt is given by CFA

                New_Def  EXECUTE, "EXECUTE", is_code, is_normal
                pop     hl
                jr      Exec_Ptr
                

//  ______________________________________________________________________ 
//
// branch       -- 
// unconditional branch in colon definition using the following cell as an offset from current IP value
// compiled by ELSE, AGAIN and some other immediate words

                New_Def BRANCH, "BRANCH", is_code, is_normal
Branch_Ptr:                
                ld      h, b
                ld      l, c
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                dec     hl                  // offset is calculated from current IP
                add     hl, de
                ld      c, l
                ld      b, h
                next


//  ______________________________________________________________________ 
//
// 0branch      f -- 
// conditional branch if the top-of-stack is ZERO or FALSE.
// compiled by IF, UNTIL and some other immediate words

                New_Def ZBRANCH, "0BRANCH", is_code, is_normal
ZBranch_Ptr:                
                pop     hl
                ld      a, l
                or      h
                jp      z, Branch_Ptr      
                inc     bc                  // if not branch, skip offset cell.
                inc     bc
                next

//  ______________________________________________________________________ 
//
// (loop)       --
// compiled by +LOOP. it uses the top two values of return-stack to
// keep track of index and limit
                New_Def C_LOOP, "(LOOP)", is_code, is_normal


                ld      de, 1               // bc contains increment of 1








Loop_Ptr:
                ldhlrp                      // ld hl,rp macro 30h +Origin
                ld      a, (hl)             // hl points to loop-index, add increment de to it.
                add     e
                ld      (hl), a
                ld      e, a
                inc     hl
                ld      a, (hl)
                adc     d
                ld      (hl),a
                inc     hl                  // hl now points to loop-limit
                bit     7, d                // keep increment-sign just before overwriting d
                ld      d, a
                jr      nz, Loop_NegativeIncrement

                    ld      a, e                
                    sub     (hl)
                    ld      a, d
                    inc     hl
                    sbc     (hl)
                jr      Loop_Endif              // else
Loop_NegativeIncrement:
                    ld      a, (hl)             
                    sub     e
                    inc     hl
                    ld      a, (hl)
                    sbc     d
Loop_Endif:

                jp      m, Branch_Ptr       // perform branch consuming following cell

                inc     hl                  
                ldrphl                      // ld rp,hl macro 30h +Origin
                
                inc     bc                  // skip branch-style offset
                inc     bc
                next

//  ______________________________________________________________________ 
//
// (+loop)       n --
// same as (LOOP) but index is incremented by n (instead of just 1)
// compiled by +LOOP. 
                New_Def C_PLOOP, "(+LOOP)", is_code, is_normal
                pop     de
                jp      Loop_Ptr

//  ______________________________________________________________________ 
//
// (?do)        lim ind -- 
// compiled by ?DO to make a loop checking for lim == ind first
// at run-time (?DO) must be followed by a BRANCH offset
// used to skip the loop if lim == ind
                New_Def C_Q_DO, "(?DO)", is_code, is_normal
                pop     de                  // de has the index
                pop     hl                  // hl has the limit
                push    hl
                push    de
                and     a                   // reset carry flag
                sbc     hl, de              // compute limit - index
                jr      nz, Do_Ptr          // if zero then don't even begin loop
                    pop     de                 
                    pop     hl

                    jp      Branch_Ptr          // perform branch consuming following cell 
Do_Ptr: 
                ldhlrp                      // prepare RP
                dec     hl
                dec     hl
                dec     hl
                dec     hl
                ldrphl                                            

                // store index as top RP
                pop     de                  
                ld      (hl), e
                inc     hl
                ld      (hl), d
                inc     hl
                // stores lim as second from top RP
                pop     de
                ld      (hl), e
                inc     hl
                ld      (hl), d

                // skip branch-style offseet
                inc     bc       
                inc     bc
                next

//  ______________________________________________________________________ 
//
// (do)        lim ind -- 
// compiled by DO to make a loop checking for lim == ind first
// this is a simpler version of (?DO)
                New_Def C_DO, "(DO)", is_code, is_normal
                dec     bc                  // prepare IP beforehand 
                dec     bc                  // to balance the two final inc bc in (?do)
                jp      Do_Ptr

//  ______________________________________________________________________ 
//
// i            -- n
// used between DO and LOOP or between DO e +LOOP to copy on top of stack
// the current value of the index-loop
                New_Def I, "I", is_code, is_normal
I_Ptr:                

                ldhlrp
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                push    de
                next

//  ______________________________________________________________________ 
//
// digit        c n -- u 1  |  0
// convert a character c using base n
// returns a unsigned number and a true flag 
// or just a false flag if the conversion fails
                New_Def DIGIT, "DIGIT", is_code, is_normal
                pop     hl                  // l has the base
                pop     de                  // e has the digit
                ld      a, e
                cp      $60                 // check if lowercase
                jr      c, Digit_Uppercase
                    sub     $20                 // quick'n'dirty uppercase
Digit_Uppercase:
                sub     $30
                jr      c, Digit_Fail       // fail when character < "0"
                    cp      $0A
                    jr      c, Digit_Decimal    // perhaps is not decimal
                        sub     7                   // try hex and subtract 7
                        cp      $0A                 
                        jr      c,  Digit_Fail      // it is not hex !

Digit_Decimal:  
                // compare digit 
                cp      l                   // compare with base

                jr      nc, Digit_Fail      // fail when greater than base
                    ld      e, a                // digit is returned as second from TOS
                    ld      hl, 1

                    psh2
Digit_Fail:     
                ld      hl, 0
                psh1                

//  ______________________________________________________________________ 
//
//  parametric uppercase routine
//  depending on the following op-code the routine can be by-passed
//  changing the behaviour of some callers.
//  If it is "ret" then the system is Case-Sensitive
//  If it is "Nop" then the system is Case-Insensitive
//  Only A register is touched.
Case_Sensitive: nop                         // Default is case-insensitive. 
Case_Upper:     
                cp      LC_A_CHAR           // lower-case "a"
                ret     c                   // no change if A < "a"    
                cp      LC_Z_CHAR + 1       // lower-case "z" + 1
                ret     nc                  // no change if A > "z"
                sub     $20                 // Make uppercase if A in ["a".."z"]
                ret                     

//  ______________________________________________________________________ 
//
//  caseon      -- 
// set system case-sensitivity on
// it patches a RET/NOP at the beginning of the uppercase-routine
                New_Def CASEON, "CASEON", is_code, is_normal
                ld      a, $C9              // "ret"
                ld      (Case_Sensitive), a
                next

//  ______________________________________________________________________ 
//
//  caseoff     --
// set system case-sensitivity on
// it patches a RET/NOP at the beginning of the uppercase-routine
                New_Def CASEOFF, "CASEOFF", is_code, is_normal
                ld      a, $00              // "nop"
                ld      (Case_Sensitive), a
                next

//  ______________________________________________________________________ 
//
//  upper       c1 -- c1 | c2 
// character on top of stack is forced to Uppercase.
                New_Def UPPER, "UPPER", is_code, is_normal
                pop     hl
                ld      a, l
                call    Case_Upper
                ld      l, a
                
                psh1

//  ______________________________________________________________________ 
//
// (find)       addr voc -- addr 0 | cfa b 1 
// vocabulary search, 
// - voc is starting word's NFA
// - addr is the string to be searched for
// On success, it returns the CFA of found word, the first NFA byte
// (which contains length and some flags) and a true flag.
// On fail, a false flag  (no more: leaves addr unchanged)
                New_Def C_FIND, "(FIND)", is_code, is_normal
                                                // de has dictionary pointer
                    pop     de
Find_VocabularyLoop:
                    pop     hl                  // string pointer to search for
                    push    hl                  // keep it on stack too for the end.
                    ld      a, (de)             // save NFA length byte
                    ex      af,af'              // for later use (!)
                    ld      a, (de)             // reload NFA length byte
                    xor     (hl)                // check if same length
                    and     $3F                 // by resetting 3 high bits (flags)
                    // word an text haven't the same length, skip to next vocabulary entry
                    jr      nz, Find_DifferentLenght 

Find_ThisWord:  // begin loop
                        inc     hl
                        inc     de
                        ld      a, (de)
                        // case insensitive option - begin
                        push    bc
                        and     $80                 // split A in msb and the rest
                        ld      b, a
                        ld      a, (de)
                        and     $7F                 // ... the rest (lower 7 bits)
                        call    Case_Sensitive      // uppercase routine
                        ld      c, a
                        ld      a, (hl)
                        call    Case_Sensitive      // uppercase routine
                        xor     c
                        xor     b
                        pop     bc
                        // case insensitive option - end
                        add     a                   // ignore msb during compare
                        jr      nz, Find_DidntMatch  // jump if doesn't match (*)

                    // loop back until last byte msb is found set 
                    // that bit marks the ending char of this word
                    jr      nc, Find_ThisWord

                    // match found !
                        ld      hl, 3               // 3 bytes for CFA offset to skip LFA
                        add     hl, de
                        ex      (sp), hl            // CFA on stack and drop addr
                        ex      af, af'             // retrieve NFA byte (!)
                        ld      e, a
                        ld      d, 0


                        ld      hl, 1
                        psh2

Find_DidntMatch: // didn't match (*)
                    jr      c,  Find_WordEnd   // jump if not end of word (**)

Find_DifferentLenght:
                // consume chars until the end of the word
                // that is last byte msb is found set 
                    inc     de
                    ld      a, (de)
                    add     a, a
                jr      nc, Find_DifferentLenght

Find_WordEnd:   // word-end  found (**)
                // take LFA and use it
                inc     de
                ex      de, hl
                ld      e, (hl)
                inc     hl
                ld      d, (hl)
                ld      a, d
                or      e

            // loop until end of vocabulary 
            jr      nz, Find_VocabularyLoop        

            pop     hl              // with this, it leaves addr unchanged
            ld      hl, FALSE_FLAG

            psh1

//  ______________________________________________________________________ 
//
// enclose      a c -- a  n1 n2 n3 
// starting from a, using delimiter c, determines the offsets:
//   n1   the first character non-delimiter
//   n2   the first delimiter after the text 
//   n3   the first character non enclosed.
// This procedure does not go beyond a 'nul' ASCII (0x00) that represents
// an uncoditional delimiter. 
// Examples:
//   i:	c  c  x  x  x  c  x	 -- 2  5  6
//  ii:	c  c  x  x  x  'nul' -- 2  5  5
// iii:	c  c  'nul'          -- 2  3  2
                New_Def ENCLOSE, "ENCLOSE", is_code, is_normal
                pop     de                  //  e has the character
                pop     hl                  // hl has the string address
                push    hl
                ld      a, e
                ld      de, -1              // let's start from -1
                dec     hl
Enclose_NonDelimiter:
                // find first non delimiter
                    inc     hl
                    inc     de
                    cp      (hl)
                jr      z, Enclose_NonDelimiter
                push    de

                push    bc                  // save Instruction Pointer

                ld      c, a                // save char
                ld      a, (hl)
                and     a                   // stop if 0x00
                jr      nz, Enclose_NextChar

                /// case iii. no more character in string
                    pop     bc                  // restore Instruction Pointer
                    inc     de 
                    push    de
                    dec     de
                    push    de
                    next
Enclose_NextChar:
                    ld      a, c
                    inc     hl
                    inc     de
                    cp      (hl)
                    jr      nz, Enclose_NonSeparator

                        // case i. first non enclosed                
                        pop     bc                  // restore Instruction Pointer
                        push    de
                        inc     de
                        push    de
                        next
Enclose_NonSeparator: 
                    ld      a, (hl)               
                    and     a
                jr      nz, Enclose_NextChar
                
                // case ii. separator & terminator
                pop     bc                  // restore Instruction Pointer
                push    de
                push    de
                next

//  ______________________________________________________________________ 
//
// (map)        a2 a1 n c1 -- c2
// translate character c using mapping string a2 and a2
// c2 = c2 if it is not translated. n is the length of bot a1 and a2.
                New_Def C_MAP, "(MAP)", is_code, is_normal
                exx
                pop     hl
                ld      a, l
                pop     bc
                pop     hl
                ld      d, b
                ld      e, c
                cpir 
                pop     hl
                jr      nz, C_Map_Then:
                    add     hl, de
                    dec     hl
                    sbc     hl, bc
                    ld      a, (hl)
C_Map_Then:
                ld      l, a
                ld      h, 0
                push    hl
                exx
                next

//  ______________________________________________________________________ 
//
// (compare)    a1 a2 n -- b 
// this word performs a lexicographic compare of n bytes of text at address a1 
// with n bytes of text at address a2. It returns numeric a value: 
//  0 : if strings are equal
// +1 : if string at a1 greater than string at a2 
// -1 : if string at a1 less than string at a2 
// strings can be 256 bytes in length at most.
                New_Def C_COMPARE, "(COMPARE)", is_code, is_normal
                pop     hl                  // Number of bytes
                ld      a, l
                pop     hl                  // hl points string a2
                pop     de                  // hl points string a1
                push    bc                  // Instruction pointer on stack
                ld      b, a
C_Compare_Loop:
                    ld      a, (hl)
                    call    Case_Sensitive
                    ld      c, a
                    ld      a, (de)
                    call    Case_Sensitive
                    cp      c
                    inc     de
                    inc     hl
                    jr      z, C_Compare_Equal
                        jr      c, C_Compare_NotLessThan  // If LessThan
                            ld      hl, 1               // a1 gt a2
                        jr      C_Compare_Then      // Else
C_Compare_NotLessThan:                
                            ld      hl, -1              // a1 lt a2
C_Compare_Then:                                 // Endif
                        pop     bc              // restore Instruction Pointer

                        psh1
                
C_Compare_Equal:
                djnz    C_Compare_Loop
                ld      hl, 0               // a1 eq a2
                pop     bc                  // restore Instruction Pointer

                psh1

//  ______________________________________________________________________ 
//
// emitc        c -- 
// low level emit, calls ROM routine at #10 to send a character to 
// the the current channel (see SELECT to change stream-channel)
                New_Def EMITC, "EMITC", is_code, is_normal
                pop     hl
                ld      a, l
Emitc_Ptr:      
                push    bc
                push    ix
                rst     $10
                pop     ix
                pop     bc
                ld      a, 255            // max possible
                ld      (SCR_CT), a

                next

Emitc_Vec:    
                dw      C_Emit_Printable  // comma
                dw      C_Emit_Bel        // bel
                dw      C_Emit_Printable  // bs
                dw      C_Emit_Tab        // tab
                dw      C_Emit_Printable  // cr
                dw      C_Emit_NL         // lf (unix newline)    
                dw      C_Emit_Printable  // blank
                dw      C_Emit_Printable  // blank

Emit_Selector_Start:
                db      $06                 // comma
                db      $07                 // bel
                db      $08                 // bs
                db      $09                 // tab
                db      $0D                 // cr
                db      $0A                 // lf (unix newline)    
                db      $20
Emit_Selector_End:  
                db      $20

//  ______________________________________________________________________ 
//
// (?emit)      c1 -- c2 | c1
// decode a character to be sent via EMIT
// search first the Emit_Selector table, if found jump to the corresponding routine in Emit_Vector
// the routine should resolve anything and convert the character anyway.
                New_Def C_EMIT, "(?EMIT)", is_code, is_normal
                pop     de
                ld      a, e                //  de has c1
                and     $7F                 // 7-bit ascii only
                push    bc                  // save Instruction Pointer
                ld      bc, Emit_Selector_End - Emit_Selector_Start + 1
                ld      hl, Emit_Selector_End
                cpdr                        // search for c1 in Emit_Selector table, backward
                jr      nz, C_Emit_Not_Found  
                    // Found then decode it
                    ld      hl, Emitc_Vec
                    add     hl, bc
                    add     hl, bc
                    ld      e, (hl)
                    inc     hl
                    ld      d, (hl)
                    ex      de, hl
                    pop     bc                  // restore Instruction Pointer
                    jp      (hl)                // one of the following labels
C_Emit_Not_Found:
                pop     bc                  // restore Instruction Pointer
                cp      BLANK_CHAR          // cp $20 non-printable check
                jr      nc, C_Emit_Printable
                    ld      a, NUL_CHAR         // NUL is never "printed"
C_Emit_Printable:
                ld      l, a
                ld      h, 0
                
                psh1                

C_Emit_Bel:   
                push    bc                  // save Instruction Pointer
                ld      de, $0100
                ld      hl, $0200
                push    ix                  // save Next Pointer
                call    $03B6               // bleep Standard-ROM routine
                pop     ix                  // restore Next Pointer
                pop     bc                  // restore Instruction Pointer
                ld      hl, NUL_CHAR
                
                psh1

C_Emit_Tab:     ld      hl, COMMA_CHAR

                psh1

C_Emit_NL       ld      hl, CR_CHAR           // 0x0A --> 0x0D  à la Spectrum

                psh1

//  ______________________________________________________________________ 

Key_Table:
                db      $E2                 //  0: STOP  --> SYMBOL+A : ~
                db      $C3                 //  1: NOT   --> SYMBOL+S : |
                db      $CD                 //  2: STEP  --> SYMBOl+D : //
                db      $CC                 //  3: TO    --> SYMBOL+F : {
                db      $CB                 //  4: THEN  --> SYMBOL+G : }
                db      $C6                 //  5: AND   --> SYMBOL+Y : [
                db      $C5                 //  6: OR    --> SYMBOL+U : ]
                db      $AC                 //  7: AT    --> SYMBOL+I : (C) copyright symbol
                db      $C7                 //  8: <=
                db      $C8                 //  9: >=
                db      $C9                 // 10: <>    --> SYMBOL+W is the same as CAPS (toggle) SHIFT+2 
Key_MapTo:
                db      $06                 // 10: SYMBOL+W is the same as CAPS (toggle) SHIFT+2 
                db      $20                 //  9: not used
                db      $20                 //  8: not used
                db      $7F                 //  7: SYMBOL+I : (C) copyright symbol
                db      $5D                 //  6: SYMBOL+U : ]
                db      $5B                 //  5: SYMBOL+Y : [
                db      $7D                 //  4: SYMBOL+G : }
                db      $7B                 //  3: SYMBOL+F : {
                db      $5C                 //  2: SYMBOl+D : //
                db      $7C                 //  1: SYMBOL+S : |
                db      $7E                 //  0: SYMBOL+A : ~

//  ______________________________________________________________________ 
//
// key          -- c
// wait for a keypress
// This definition need Standard ROM Interrupt to be served

                New_Def KEY, "KEY", is_code, is_normal

                push    bc                  // save Instruction Pointer
                push    ix  

                ld      (SP_Saved), sp      // be sure to not to be paged out.
                ld      sp, Cold_origin - 2 // maybe $4000 in the future...
                res     5, (iy + 1)         // FLAGS (5C3A+1)

Key_Wait:       
                    halt
                    ld      a, 2                // selec channel #2 (Upper Video)
                    call    $1601               // SELECT Standard-ROM Routine
    
                    // software-flash: flips face every 320 ms
                    ld      a, $10              // Timing based
                    and     (iy + $3E)          // FRAMES (5C3A+3E)
    
                    ld      a, (Block_Face)     // see origin.asm
                    jr      nz, Key_Cursor
                        ld      a, (Half_Face)      // see origin.asm
                        bit     3, (iy + $30)       // FLAGS2 (5C3A+$30) that is CAPS-LOCK
                        jr      z, Key_Cursor
                            ld      a, (Underscore_Face) // see origin
Key_Cursor:     
                    rst     $10
                    ld      a, BACKSPACE_CHAR    // backspace            
                    rst     $10

                    bit     5, (iy + 1)         // FLAGS (5C3A+1)
                jr      z, Key_Wait
    
                halt    // this is to sync flashing cursor.

                ld      a, BLANK_CHAR       // space to blank cursor
                rst     $10
                ld      a, BACKSPACE_CHAR   // backspace
                rst     $10
                ld      a, (LASTK)          // get typed character (5C08)
                
                // decode character from above table
                ld      hl, Key_Table
                ld      bc, $000B
                cpir
                jr      nz, Key_DontMap
                    ld      hl, Key_MapTo
                    add     hl, bc
                    ld      a, (hl)
Key_DontMap:    cp      $06                 // CAPS-LOCK management                
                jr      nz, Key_NoCapsLock
                    ld      hl, $5C6A           // FLAGS2
                    ld      a, (hl)
                    xor     $08
                    ld      (hl), a
                    ld      a, NUL_CHAR
Key_NoCapsLock: ld      l, a
                ld      h, 0                // Prepare TOS 

                ld      a, ($5C48)          // BORDCR system variable
                rra
                rra
                rra
                or      $18                 // quick'n'dirty click
                out     ($fe), a
                ld      b, 0
                djnz    $                   // wait loop
                xor     $18
                out     ($fe), a
                
                ld      sp, (SP_Saved)

                pop     ix  
                pop     bc                  // Restore Instruction Pointer

                psh1

//  ______________________________________________________________________ 
//
// ?terminal    -- FALSE | TRUE
// test for BREAK keypress
                New_Def QTERMINAL, "?TERMINAL", is_code, is_normal
                ld      hl, 0
                ld      (SP_Saved), sp
                ld      sp, Cold_origin - 2
                call    $1F54
                ld      sp, (SP_Saved)

                jr      c, QTerminal_NoBreak
                    inc     l                  // quick TRUE_FLAG
QTerminal_NoBreak:  

                psh1     


//  ______________________________________________________________________ 
//
// ZX Spectrum Next - Low Level disk primitives.
// this include is "here" for backward compatibility

                include "next-opt0.asm"


//  ______________________________________________________________________ 
//
// cr           --
// send a CR via EMITC
                New_Def CR, "CR", is_code, is_normal

                ld      a, CR_CHAR
                jp      Emitc_Ptr

//  ______________________________________________________________________ 
//
// cmove    a1 a2 u --
// If u > 0, moves memory content starting at address a1 for n bytes long
// storing then starting at address addr2. 
// The content of a1 is moved first. See CMOVE> also.
                New_Def CMOVE, "CMOVE", is_code, is_normal
                ld      h, b
                ld      l, c

                pop     bc                  // bc has counter
                pop     de                  // de now has dest
                ex      (sp), hl            // hl has source, save Instruction Pointer
                ld      a, b                
                or      c
                jr      z, Cmove_NoMove
                    ldir
Cmove_NoMove:   
                pop     bc                  // Restore Instruction Pointer

                next

//  ______________________________________________________________________ 
//
// cmove>    a1 a2 u --
// If u > 0, moves memory content starting at address a1 for n bytes long
// storing then starting at address addr2. 
// The content of a1 is moved last. See cmove.
                New_Def CMOVE_TO, "CMOVE>", is_code, is_normal
                ld      h, b
                ld      l, c

                pop     bc                  // bc has counter
                pop     de                  // de has dest
                ex      (sp), hl            // hl has source, save Instruction Pointer
                ld      a, b                
                or      c
                jr      z, CmoveV_NoMove
                    ex      de, hl              // compute address to 
                    add     hl, bc              // operate backward
                    dec     hl
                    ex      de, hl
                    add     hl, bc
                    dec     hl               
                    lddr                        // backward
CmoveV_NoMove:   
                pop     bc                  // Restore Instruction Pointer

                next

//  ______________________________________________________________________ 
//
// um*      u1 u2 -- ud
// Unsigned multiplication
// A double-integer is kept in CPU registers as DEHL then pushed on stack.
// On the stack a double number is treated as two single numbers
// where DE is on the top of the stack and HL is the second from top,
// Instead, in 2VARIABLE a double number is stored as EDLH.
// this definition could use "MUL" Z80N new op-code.
                New_Def UM_MUL, "UM*", is_code, is_normal
                pop     de                    // de has u2 operand
                pop     hl                    // hl has u1 operand
                push    bc                    // Save Instruction Pointer
                ld      b, l
                ld      c, e
                ld      e, l
                ld      l, d
                push    hl
                ld      l, c
                mul
                ex      de, hl
                mul
                xor     a
                add     hl, de
                adc     a
                ld      e, c
                ld      d, b
                mul
                ld      b, a
                ld      c, h
                ld      a, d
                add     l
                ld      h, a
                ld      l, e
                pop     de
                mul
                ex      de, hl
                adc     hl, bc
                pop     bc
                push    de
                push    hl
                next

//  ______________________________________________________________________ 
//
// um/mod      ud u1 -- q r
// divides ud into u1 giving quotient q and remainder r
// algorithm takes 16 bit at a time starting from msb
// DE grows from lsb upward with quotient result
// HL keeps the remainder at each stage of division
// each loop 'lowers' the next binary digit to form the current dividend
                New_Def UMDIVMOD, "UM/MOD", is_code, is_normal
                ld      h, b
                ld      l, c                    // Save Instruction Pointer

                pop     bc                      // divisor

                pop     de                      // < high part
                ex      (sp), hl                // < low part and > save bc
                ex      de, hl                  // 
                ld      a, l                    // check without changing arguments
                sub     c                       // if divisor is greater than high part
                ld      a, h                    // so quotient will be in range
                sbc     a, b
                jr      nc, Um_DivMod_OutOfRange
                    ld      a, 16
Um_DivMod_Loop: 
                        and     a
                        rl      e
                        rl      d
                        rl      l
                        rl      h
                        jr      nc, Um_DivMod_Carry
                            and     a
                            sbc     hl, bc
                        jr      Um_DivMod_Endif    // else
Um_DivMod_Carry:
                            and     a
                            sbc     hl, bc
                            jr      nc, Um_DivMod_Endif
                                add     hl, bc
                                dec     de
Um_DivMod_Endif:                                   // endif 
                        inc     de
                        dec     a
                    jr      nz, Um_DivMod_Loop
                    ex      de, hl
Um_DivMod_Bailout:
                    pop     bc                  // restore Instruction Pointer
                    push    de                  // de := remanider
                    push    hl                  // hl := quotient
                    next

Um_DivMod_OutOfRange:
                ld      hl, -1
                ld      d, h
                ld      e, l
                jr      Um_DivMod_Bailout

//  ______________________________________________________________________ 
//
// and          n1 n2 -- n3
// bit logical AND. Returns n3 as n1 & n2
                New_Def AND_OP, "AND", is_code, is_normal
                pop     de
                pop     hl
                ld      a, e
                and     l
                ld      l, a
                ld      a, d
                and     h
                ld      h, a

                psh1

//  ______________________________________________________________________ 
//
// or           n1 n2 -- n3
// bit logical OR. Returns n3 as n1 | n2
                New_Def OR_OP, "OR", is_code, is_normal
                pop     de
                pop     hl
                ld      a, e
                or      l
                ld      l, a
                ld      a, d
                or      h
                ld      h, a

                psh1

//  ______________________________________________________________________ 
//
// xor          n1 n2 -- n3
// bit logical OR. Returns n3 as n1 ^ n2
                New_Def XOR_OP, "XOR", is_code, is_normal
                pop     de
                pop     hl
                ld      a, e
                xor     l
                ld      l, a
                ld      a, d
                xor     h
                ld      h, a

                psh1

//  ______________________________________________________________________ 
//
// sp@      -- a
// returns on top of stack the value of SP before execution
                New_Def SPFETCH, "SP@", is_code, is_normal

                ld      hl, 0
                add     hl, sp

                psh1

//  ______________________________________________________________________ 
//
// sp!      a --
// restore SP to the initial value passed
// normally it is S0, i.e. the word at offset 6 and 7 of user variabiles area.
                New_Def SPSTORE, "SP!", is_code, is_normal
                pop     hl
                ld      sp, hl

                next

//  ______________________________________________________________________ 
//
// rp@      -- a
// returns on top of stack the value of Return-Pointer
                New_Def RPFETCH, "RP@", is_code, is_normal

                ldhlrp

                psh1

//  ______________________________________________________________________ 
//
// rp!      a --
// restore RP to the initial value passed
// normally it is R0 @, i.e. the word at offset 8 of user variabiles area.
                New_Def RPSTORE, "RP!", is_code, is_normal
                pop     hl
                ldrphl

                next

//  ______________________________________________________________________ 
//
// ;s      --
// exits back to the caller word
                New_Def EXIT, ";S", is_code, is_normal
                ldhlrp                      // Get Return Stack Pointer
                ld      c, (hl)             // pop Instruction Pointer
                inc     hl                  // from Return Stack
                ld      b, (hl)
                inc     hl
                ldrphl                      // Set Return Stack Pointer
                next

//  ______________________________________________________________________ 
//
// leave        -- 
// set the limit-of-loop equal to the current index
// this forces to leave from loop at the end of the current iteration
                New_Def LEAVE, "LEAVE", is_code, is_normal

                ldhlrp
                ld      e, (hl)             
                inc     hl
                ld      d, (hl)
                inc     hl
                ld      (hl), e
                inc     hl
                ld      (hl), d

                next

//  ______________________________________________________________________ 
//
// >r      n --
// pop from calculator-stack and push into return-stack
                New_Def TO_R, ">R", is_code, is_normal
                pop     de
                ldhlrp
                dec     hl
                ld      (hl), d             // store current TOS
                dec     hl                  // to Return Stack
                ld      (hl), e
                ldrphl

                next

//  ______________________________________________________________________ 
//
// r>      -- n
// pop from return-stack and push into calculator-stack
                New_Def R_TO, "R>", is_code, is_normal

                ldhlrp
                ld      e, (hl)             // retrieve from Return Stack
                inc     hl
                ld      d, (hl)
                inc     hl
                ldrphl
                push    de
                next

//  ______________________________________________________________________ 
//
// r            -- n
// return on top of stack the value of top of return-stack
// Since this is the same as I, we alter R's CFA to jump there
                New_Def R_OP, "R@", I_Ptr, is_normal

//  ______________________________________________________________________ 
//
// r            -- n
// return on top of stack the value of top of return-stack
// Since this is the same as I, we alter R's CFA to jump there
                New_Def R_OLD, "R", I_Ptr, is_normal

//  ______________________________________________________________________ 
//
// 0=           n -- f
// true (non zero) if n is zero, false (0) elsewere
                New_Def ZEQUAL, "0=", is_code, is_normal
                pop     hl
                ld      a, l
                or      h
                ld      hl, FALSE_FLAG
                jr      nz, ZEqual_Skip
                    inc     l
ZEqual_Skip:    
                psh1

//  ______________________________________________________________________ 
//
// 0<           n -- f
// true (non zero) if n is less than zero, false (0) elsewere
                New_Def ZLESS, "0<", is_code, is_normal
                pop     hl
                add     hl, hl
                ld      hl, 0
                jr      nc, ZLess_Skip
                    inc     l
ZLess_Skip:     
                psh1

//  ______________________________________________________________________ 
//
// 0>           n -- f
// true (non zero) if n is less than zero, false (0) elsewere
                New_Def ZGREATER, "0>", is_code, is_normal
                pop     hl
                ld      a, l
                or      h
                add     hl, hl
                ld      hl, FALSE_FLAG
                jr      c, ZGreater_Skip
                    and     a
                    jr      z, ZGreater_Skip
                        inc     l
ZGreater_Skip:  
                psh1

//  ______________________________________________________________________ 
//
// +            n1 n2 -- n3
// returns the unsigned sum of two top values
                New_Def PLUS, "+", is_code, is_normal
                pop     hl
                pop     de
                add     hl, de

                psh1


//  ______________________________________________________________________ 
//
// d+           d1 d2 -- d3
// returns the unsigned sum of two top double-numbers
//      d2  d1
//      h l h l
// SP   LHEDLHED
// SP  +01234567
                New_Def DPLUS, "D+", is_code, is_normal

                ld      hl, 7
                add     hl, sp
                ld      d, (hl)
                ld      (hl), b             // Save IP
                dec     hl
                ld      e, (hl)
                ld      (hl), c             // de := d1.L    
                pop     bc                  // bc := d2.H
                pop     hl                  // hl := d2.L
                add     hl, de              // hl := d2.L + d1.L
                ex      de, hl              // de := lower
                pop     hl                  // d1.H
                adc     hl, bc              // d1.H + d2.H
                pop     bc                  // Restore IP


                psh2

//  ______________________________________________________________________ 
//
// 1+           n1 -- n2
// increment by 1 top of stack
                New_Def ONE_PLUS, "1+", is_code, is_normal
                pop     hl
                inc     hl

                psh1

//  ______________________________________________________________________ 
//
// 1-           n1 -- n2
// decrement by 1 top of stack
                New_Def ONE_SUBTRACT, "1-", is_code, is_normal
                pop     hl
                dec     hl

                psh1

//  ______________________________________________________________________ 
//
// 2+           n1 -- n2
// increment by 2 top of stack
                New_Def TWO_PLUS, "2+", is_code, is_normal
Two_Plus:                
                pop     hl
                inc     hl
                inc     hl

                psh1

//  ______________________________________________________________________ 
//
// cell+        a1 -- a2
// increment by 2 top of stack
                New_Def CELL_PLUS, "CELL+", Two_Plus, is_normal

//  ______________________________________________________________________ 
//
// align        a1 -- a2
// align memory : not used
//              New_Def ALIGN_ADDR, "ALIGN", is_code, is_normal
//            next

//  ______________________________________________________________________ 
//
// cell-        a1 -- a2
// decrement by 2 top of stack
                New_Def CELL_MINUS, "CELL-", is_code, is_normal
                pop     hl
                dec     hl
                dec     hl

                psh1

//  ______________________________________________________________________ 
//
// negate        n1 -- n2
// change the sign of number
                New_Def MINUS, "NEGATE", is_code, is_normal
                ld      hl, 0               // subtract from 0
                pop     de
                or      a
                sbc     hl, de

                psh1

//  ______________________________________________________________________ 
//
// dminus       d1 -- d2
// change the sign of a double number
                New_Def DMINUS, "DNEGATE", is_code, is_normal
                pop     hl                  // d1.H
                pop     de                  // d1.L
                push    bc                  // Save Instruction Pointer
                ld      b, h
                ld      c, l                // bc := d1.L
                xor     a
                ld      h, a                
                ld      l, a
                sbc     hl, de              // subtact from zero
                pop     de                  // Retrieve Instruction Pointer
                push    hl                  // > d2-L
                ld      h, a
                ld      l, a
                sbc     hl, bc              // subtract from zero with carry
                                            // > d2-H
                ld      b, d
                ld      c, e                                            
                psh1

//  ______________________________________________________________________ 
//
// over         n1 n2 -- n1 n2 n1
// copy the second value of stack and put it on top.
                New_Def OVER, "OVER", is_code, is_normal
                pop     de                  //   n2  
                pop     hl                  // < n1 
                push    hl                  // > n1
                push    de                  // > n2
                push    hl                  // > n1
                next

//  ______________________________________________________________________ 
//
// drop         n1 -- 
// drops the top of stack
                New_Def DROP, "DROP", is_code, is_normal
                pop     hl                  // < n1 and discard previous TOS
                next

//  ______________________________________________________________________ 
//
// nip          n1 n2 -- n2
// drops the second elemento on the stack
                New_Def NIP, "NIP", is_code, is_normal

                pop     hl                  // < n1 discarded
                ex      (sp), hl
                next

//  ______________________________________________________________________ 
//
// tuck         n1 n2 -- n2 n1 n2
// copy the top element after the second.
                New_Def TUCK, "TUCK", is_code, is_normal
                pop     hl
                pop     de                  // < n1
                push    hl                  // > n2  and TOS
                push    de                  // > n1
                push    hl
                next

//  ______________________________________________________________________ 
//
// swap         n1 n2 -- n2 n1
// swaps the two values on top of stack
                New_Def SWAP, "SWAP", is_code, is_normal
                pop     hl                  // < n1
                ex      (sp),hl             // > n2
                push    hl                  // copy n1 to TOS
                next

//  ______________________________________________________________________ 
//
// dup         n -- n n
// duplicates the top value of stack
                New_Def DUP, "DUP", is_code, is_normal
                pop     hl
                push    hl                  // > n duplicate TOS
                push    hl
                next

//  ______________________________________________________________________ 
//
// rot         n1 n2 n3 -- n2 n3 n1
// Rotates the 3 top values of stack by picking the 3rd in access-order
// and putting it on top. The other two are shifted down one place.
                New_Def ROT, "ROT", is_code, is_normal
                pop     de                  // < n2
                pop     hl                  // < n1
                ex      (sp),hl             // > n2
                push    de                  // > n3
                push    hl                  // copy n1 to TOS
                next

//  ______________________________________________________________________ 
//
// pick        n1 -- nx
// picks the nth element from TOS
                New_Def PICK, "PICK", is_code, is_normal      
                pop     hl                  // take TOS as index
                add     hl, hl              // as cells
                add     hl, sp              // from Stack Pointer
                ld      a, (hl)             // replace TOS
                inc     hl
                ld      h, (hl)
                ld      l, a

                psh1


//  ______________________________________________________________________ 
//
// 2over        d1 d2 -- d1 d2 d1
//              n1 n2 n3 n4 -- n1 n2 n3 n4 n1 n2
// copy the second double of stack and put on top.
                New_Def TWO_OVER, "2OVER", is_code, is_normal

                ld      hl, 7
                add     hl, sp
                ld      d, (hl)
                dec     hl
                ld      e, (hl)             // d1-L
                push    de
                dec     hl
                ld      d, (hl)
                dec     hl
                ld      e, (hl)             // d1-H
                push    de
                next

//  ______________________________________________________________________ 
//
// 2drop        d -- 
//              n1 n2 --
// drops the top double from stack
                New_Def TWO_DROP, "2DROP", is_code, is_normal
                pop     hl
                pop     hl
                next

//  ______________________________________________________________________ 
//
// 2nip         d1 d2 -- d2
//              n1 n2 n3 n4 -- n3 n4
// drops the second double on the stack
//              New_Def TWO_NIP, 4, "2nip"
//              ...

//  ______________________________________________________________________ 
//
// 2tuck         d1 d2 -- d2 d1 d2
// copy the top element after the second.
//              New_Def TWO_TUCK, 5, "2tuck"
//              ...

//  ______________________________________________________________________ 
//
// 2swap         d1 d2 -- d2 d1
//               n1 n2 n3 n4 -- n3 n4 n1 n2
// swaps the two doubles on top of stack
                New_Def TWO_SWAP, "2SWAP", is_code, is_normal
                pop     af                  //   d2-H  
                pop     hl                  // < d2-L
                pop     de                  // < d1-H
                ex      (sp), hl            // < d1-L > d2-L    
                push    af                  // > d2-H
                push    hl                  // > d1-L
                push    de

                next

//  ______________________________________________________________________ 
//
// 2dup         d -- d d
//              n1 n2 -- n1 n2 n1 n2
// duplicates the top double of stack
                New_Def TWO_DUP, "2DUP", is_code, is_normal
                pop     hl                  // < d-H    
                pop     de                  // < d-L
                push    de                  // < d-L
                push    hl                  // > d-H
                push    de                  // > d-L
                push    hl                  // > d-H
                next

//  ______________________________________________________________________ 
//
// 2rot         d1 d2 d3 -- d2 d3 d1
//              n1 n2 n3 n4 n5 n6 -- n3 n4 n5 n6 n1 n2
// Rotates the 3 top doubles of stack by picking the 3rd in access-order
// and putting it on top. The other two are shifted down one place.
//              New_Def TWO?ROT, 4, "2rot"
//              ...
                New_Def TWO_ROT, "2ROT", is_code, is_normal

//      d3  |d2  |d1  |
//      h l |h l |h l |
// SP   LHED|LHED|LHED|
// SP  +0123|4567|89ab|
                ld      hl, $000B
                add     hl, sp
                ld      d, (hl)
                dec     hl
                ld      e, (hl)
                dec     hl
                push    de
                ld      d, (hl)
                dec     hl
                ld      e, (hl)
                dec     hl
                push    de

//      d1  |d3  |d2  |d1  |
//      h l |h l |h l |h l |
// SP   LHED|LHED|LHED|LHED|
// SP       +0123|4567|89ab|

                ld      d, h
                ld      e, l
                inc     de
                inc     de
                inc     de
                inc     de
                push    bc
                ld      bc, $000C
                lddr
                pop     bc
                pop     de
                pop     de

                next


//  ______________________________________________________________________ 
//
// +!           n a --
// Sums to the content of address a the number n.
// It is the same of  a @ n + a !
                New_Def PLUSSTORE, "+!", is_code, is_normal
                pop     hl                  // hl is the address
                pop     de                  // de is the number
                ld      a, (hl)             
                add     e
                ld      (hl), a
                inc     hl
                ld      a, (hl)
                adc     d
                ld      (hl), a

                next

//  ______________________________________________________________________ 
//
// toggle       a n --
// Complements (xor) the byte at addrress  a  with the model n.
                New_Def TOGGLE, "TOGGLE", is_code, is_normal
                pop     de
                pop     hl
                ld      a, (hl)
                xor     e
                ld      (hl), a

                next

//  ______________________________________________________________________ 
//
// @            a -- n
// fetch 16 bit number n from address a. Z80 keeps high byte is in high memory
                New_Def FETCH, "@", is_code, is_normal
                pop     hl
                ld      e, (hl)             // low-byte
                inc     hl
                ld      d, (hl)             // high-byte
                push    de
                next

//  ______________________________________________________________________ 
//
// !            n a --
// store 16 bit number n from address a. Z80 keeps high byte is in high memory
                New_Def STORE, "!", is_code, is_normal
                pop     hl                  // address
                pop     de                  // < n
                ld      (hl), e             // low-byte
                inc     hl
                ld      (hl), d             // high-byte

                next

//  ______________________________________________________________________ 
//
// c@           a -- c
// fetch a character n from address a
                New_Def CFETCH, "C@", is_code, is_normal
                pop     hl
                ld      l, (hl)             // low-byte
                ld      h, 0

                psh1

//  ______________________________________________________________________ 
//
// c!           c a --
// fetch 16 bit number n from address a. Z80 keeps high byte is in high memory
                New_Def CSTORE, "C!", is_code, is_normal
                pop     hl                  // < address
                pop     de
                ld      (hl), e             // low-byte

                next

//  ______________________________________________________________________ 
//
// 2@           a -- d
// fetch a 32 bits number d from address a and leaves it on top of the 
// stack as two single numbers, high part as top of the stack.
// A double number is normally kept in CPU registers as HLDE.
// On stack a double number is treated as two single numbers
// where BC is on the top of the stack and HL is the second from top,
// so the sign of the number can be checked on top of stack
// and in the stack memory it appears as LHED.
// Instead, a 32 bits number d is kept in memory as EDLH
// with the lowest significant word in the lower location
// and the highest significant word in the higher location.
// fetch 32 bit number n from address a. 
                New_Def TWO_FETCH, "2@", is_code, is_normal
                pop     hl                  // address
                ld      e, (hl)             // low-byte
                inc     hl
                ld      d, (hl)             // high-byte

                inc     hl
                ld      a, (hl)             // low-byte
                inc     hl
                ld      h, (hl)             // high-byte
                ld      l, a
                psh2

//  ______________________________________________________________________ 
//
// 2!           d a --
// stores a 32 bits number d from address a and leaves it on top of the 
// stack as two single numbers, high part as top of the stack.
// A double number is normally kept in CPU registers as HLDE.
// On stack a double number is treated as two single numbers
// where BC is on the top of the stack and HL is the second from top,
// so the sign of the number can be checked on top of stack
// and in the stack memory it appears as LHED.
// Instead, a 32 bits number d is kept in memory as EDLH
// with the lowest significant word in the lower location
// and the highest significant word in the higher location.
// fetch 32 bit number n from address a. 
                New_Def TWO_STORE, "2!", is_code, is_normal
                ld      h, b
                ld      l, c
                pop     de                  // de has address
                pop     bc                  // < high-part
                ex      (sp), hl            // < low-part > Instruction Pointer
                ex      de, hl
                ld      (hl), e
                inc     hl
                ld      (hl), d
                inc     hl
                ld      (hl), c
                inc     hl
                ld      (hl), b
                pop     bc                  // Restore Instruction Pointer

                next

//  ______________________________________________________________________ 
//
// p@           a -- c
// Read one byte from port a and leave the result on top of stack
                New_Def PFETCH, "P@", is_code, is_normal
                ld      d, b
                ld      e, c

                pop     bc
                ld      h, 0
                in      l, (c)
                ld      b, d
                ld      c, e
                psh1

//  ______________________________________________________________________ 
//
// p!           c a --
// Send one byte (top of stack) to port a
                New_Def PSTORE, "P!", is_code, is_normal
                ld      d, b
                ld      e, c

                pop     bc
                pop     hl                  // < c
                out     (c), l              // low-byte
                ld      b, d
                ld      c, e

                next


//  ______________________________________________________________________ 
//
// 2*           n1 -- n2
// doubles the number at top of stack 
                New_Def TWO_MUL, "2*", is_code, is_normal
Two_Mul_Ptr:                
                pop     hl
                add     hl, hl

                psh1

//  ______________________________________________________________________ 
//
// 2/           n1 -- n2
// halves the top of stack, sign is unchanged 
                New_Def TWO_DIV, "2/", is_code, is_normal
                pop     hl
                sra     h
                rr      l

                psh1

//  ______________________________________________________________________ 
//
// lshift       n1 u -- n2
// bit left shift of u bits
                New_Def LSHIFT, "LSHIFT", is_code, is_normal
                pop     de

                pop     hl
                ld      a, e
                or      a
                jr      z, Lshift_Zero
Lshift_Loop:    
                        add     hl, hl
                        dec     a
                    jr      nz, Lshift_Loop
Lshift_Zero:    


                psh1

//  ______________________________________________________________________ 
//
// rshift       n1 u -- n2
// bit right shift of u bits 
                New_Def RSHIFT, "RSHIFT", is_code, is_normal
                pop     de

                pop     hl
                ld      a, e
                or      a
                jr      z, Rshift_Zero
Rshift_Loop:    
                        srl     h
                        rr      l
                        dec     a
                    jr      nz, Rshift_Loop
Rshift_Zero:


                psh1

//  ______________________________________________________________________ 
//
// cells        n1 -- n2
// decrement by 2 top of stack
                New_Def CELLS, "CELLS", Two_Mul_Ptr, is_normal


//  ______________________________________________________________________ 

