//  ______________________________________________________________________ 
//
//  L1.asm
// 
//  Level-1 definitions and derivate
//  ______________________________________________________________________ 

//  ______________________________________________________________________ 
//
// :            -- cccc     ( compile time )
//              i*x -- j*x  ( run time )
// Colon Definition
                Colon_Def COLON, ":", is_normal      // has forward-ref 

                dw      QEXEC                   // ?exec      
                dw      STORE_CSP               // !csp
                dw      CURRENT, FETCH          // current @
                dw      CONTEXT, STORE          // context !
                dw      CREATE                  // create  ( forward )
                dw      SMUDGE                  // dmudge
                dw      SQUARED_CLOSE           // ]
                dw      C_SEMICOLON_CODE        // ;code ( change the 3-bytes CFA of defining word to call Enter_Ptr )
                                                // ... immediate
Enter_Ptr:      
                // via call coded in CFA
                ex      de, hl //** 
                // *** ldhlrp
                dec     hl                  // push on Return-Stack current Instruction-Pointer
                ld      (hl), b
                dec     hl
                ld      (hl), c
                // *** ldrphl
                ex      de, hl //** 


                pop     bc                  // points to PFA of "this" word
                next

//  ______________________________________________________________________ 
//
// ;            --
// Semicolon. End of Colon-Definition. Stack must be balanced.
                Colon_Def SEMICOLON, ";", is_immediate   // has forward-ref 
                
                dw      QCSP                    // ?csp
                dw      COMPILE, EXIT           // [compile] ;s
                dw      SMUDGE                  // smudge
                dw      SQUARED_OPEN            // [
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// noop         --

                New_Def NOOP, "NOOP", is_code, is_normal
                next

//  ______________________________________________________________________ 
//
// constant     n -- cccc     ( compile time )
//              -- n          ( run time )
// Constant definition.
                Colon_Def CONSTANT, "CONSTANT", is_normal   // has forward-ref 
                dw      CREATE                  // create
                dw      COMMA                   // ,    ( at PFA then, store the value )
                dw      C_SEMICOLON_CODE        // ;code (  changes the 3-bytes CFA to call Constant_Ptr )
Constant_Ptr:


                pop     hl

                ld      a, (hl)
                inc     hl
                ld      h, (hl)
                ld      l, a
                push    hl
                next

//  ______________________________________________________________________ 
//
// variable     n -- cccc     ( compile time )
//              -- a          ( run time )
// Variable definition, n is the initial value. 
                Colon_Def VARIABLE, "VARIABLE", is_normal   // has forward-ref 

                dw      ZERO
                dw      CONSTANT                // constant
                dw      C_SEMICOLON_CODE        // ;code ( changes the 3-bytes CFA to call Variable_Ptr )
Variable_Ptr:




                next

//  ______________________________________________________________________ 
//
// user         b -- cccc     ( compile time )
//              -- a          ( run time )
// User variable definition
                Colon_Def USER, "USER", is_normal

                dw      CREATE                  // create 
                dw      CCOMMA                  // c,          
                dw      C_SEMICOLON_CODE        // ;code () changes the 3-bytes CFA to call User_Ptr )


User_Ptr:
                // via call coded in CFA
                pop     hl

                ld      a, (hl)
                ld      hl, (USER_Pointer)
                add     hl, a
                push    hl
                next
                
//  ______________________________________________________________________ 
//
                Constant_Def ZERO       ,   "0"     ,   0
                Constant_Def ONE        ,   "1"     ,   1
                Constant_Def TWO        ,   "2"     ,   2
                Constant_Def THREE      ,   "3"     ,   3
                Constant_Def NEG_ONE    ,   "-1"    ,  -1
                Constant_Def BL         ,   "BL"    , $20
                Constant_Def CL         ,   "C/L"   ,  64
                Constant_Def BBUF       ,   "B/BUF" , 512
                Constant_Def BSCR       ,   "B/SCR" ,   2
                Constant_Def LSCR       ,   "L/SCR" ,  16

//  ______________________________________________________________________ 
//
// +origin         --
//              Colon_Def PLUS_ORIGIN, "+ORIGIN", is_normal
//              dw      LIT, Cold_origin        // [ hex 6366 ] literal
//              dw      PLUS                    // +
//              dw      EXIT                    // ;
                New_Def  PLUS_ORIGIN, "+ORIGIN", is_code, is_normal
                exx
                pop     hl
                ld      de, Cold_origin
                add     hl, de
                push    hl
                exx
                next


//  ______________________________________________________________________ 
//
                Constant_Def CNEXT      ,   "(NEXT)", Next_Ptr

//  ______________________________________________________________________ 
//

                User_Def S0         , "S0"        , 06 // starting value of Stack-Pointer
                User_Def R0         , "R0"        , 08 // starting value of Return-Pointer
                User_Def TIB        , "TIB"       , 10 // input terminal buffer address
                User_Def WIDTH      , "WIDTH"     , 12 // maximum number of characters for a word name
                User_Def WARNING    , "WARNING"   , 14 // error reporting method: 0 base, 1 verbose
                User_Def FENCE      , "FENCE"     , 16 // minimum address where FORGET can work
                User_Def DP         , "DP"        , 18 // Dictionary Pointer 
                User_Def VOC_LINK   , "VOC-LINK"  , 20 // pointer to the latest vocabulary
                User_Def FIRST      , "FIRST"     , 22 // address of first buffer
                User_Def LIMIT      , "LIMIT"     , 24 // address of last buffer
                User_Def HP         , "HP"        , 26 // heap-pointer address
                User_Def NMODE      , "NMODE"     , 28 // number mode: 0 integer, 1 floating point 
                User_Def BLK        , "BLK"       , 30 // block number to be interpreted. 0 for terminal
                User_Def TO_IN      , ">IN"       , 32 // incremented when consuming input buffer
                User_Def OUT        , "OUT"       , 34 // incremented when sending to output
                User_Def SCR        , "SCR"       , 36 // latest screen retreieved by LIST
                User_Def OFFSET     , "OFFSET"    , 38 // 
                User_Def CONTEXT    , "CONTEXT"   , 40 // pointer to the vocabulary where search begins
                User_Def CURRENT    , "CURRENT"   , 42 // pointer to the vocabulary where search continues
                User_Def STATE      , "STATE"     , 44 // compilation status. 0 interpreting.
                User_Def BASE       , "BASE"      , 46 // 
                User_Def DPL        , "DPL"       , 48 // number of digits after decimal point in conversion
                User_Def FLD        , "FLD"       , 50 // output field width
                User_Def CSP        , "CSP"       , 52 // used to temporary store Stack-Pointer value
                User_Def RSHARP     , "R#"        , 54 // location of editing cursor
                User_Def HLD        , "HLD"       , 56 // last character during a number conversion output
                User_Def USE        , "USE"       , 58 // address of last used block
                User_Def PREV       , "PREV"      , 60 // address of previous used block
                User_Def LP         , "LP"        , 62 // line printer (not used)
                User_Def PLACE      , "PLACE"     , 64 // number of digits after decimal point in output
                User_Def SOURCE_ID  , "SOURCE-ID" , 66 // data-stream number in INCLUDE and LOAD-
                User_Def SPAN       , "SPAN"      , 68 // number of character of last EXPECT
                User_Def HANDLER    , "HANDLER"   , 70 // Used by THROW-CATCH
                User_Def EXP        , "EXP"       , 72 // keeps the exponent in number conversion

//  ______________________________________________________________________ 
//
// here         -- a
                Colon_Def HERE, "HERE", is_normal
                dw      DP, FETCH               // dp @
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// allot        n --
                Colon_Def ALLOT, "ALLOT", is_normal
                dw      DP,  PLUSSTORE          // dp +!
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// comma        n --
                Colon_Def COMMA, ",", is_normal
                dw      HERE, STORE             // here !
                dw      TWO, ALLOT              // 2 allot
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ccomma       c --
                Colon_Def CCOMMA, "C,", is_normal
                dw      HERE, CSTORE            // here c!
                dw      ONE, ALLOT              // 1 allot
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// hpcomma      n --
//              Colon_Def HCOMMA, "HP,", is_normal
//              dw      HP_FETCH, FAR, STORE    // HP@ FAR !
//              dw      TWO, HP, PLUSSTORE      // 2 HP +!
//              dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// s>d          n -- d
// converts a single precision integer in a double precision
                New_Def S_TO_D, "S>D", is_code, is_normal
                pop     hl
                ld      a, h
                push    hl
                rla
                sbc     hl, hl
                push    hl
                next

//  ______________________________________________________________________ 
//
// -            n1 n2 -- n3
// subtraction
                New_Def SUBTRACT, "-", is_code, is_normal
                exx
                pop     de
                pop     hl
                and     a
                sbc     hl, de
                push    hl
                exx
                next


//  ______________________________________________________________________ 
//
// =            n1 n2 -- n3
// equals
                Colon_Def EQUALS, "=", is_normal
                dw      SUBTRACT, ZEQUAL        // - 0=
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// u<           u1 u2 -- u3
// unsigned less-than
                New_Def ULESS, "U<", is_code, is_normal
                exx
                pop     de
                pop     hl
                and     a
                sbc     hl, de
                sbc     hl, hl
                push    hl
                exx
                next

//  ______________________________________________________________________ 
//
// <           n1 n2 -- n3
// less-than
                New_Def LESS, "<", is_code, is_normal
                exx
                pop     de
                pop     hl
                ld      a, h
                xor     $80
                ld      h, a
                ld      a, d
                xor     $80
                ld      d, a
//              and     a
                sbc     hl, de
                sbc     hl, hl
                push    hl
                exx
                next

//  ______________________________________________________________________ 
//
// >            n1 n2 -- n3
// greater than
                Colon_Def GREATER, ">", is_normal
                dw      SWAP, LESS              // swap <
                dw      EXIT                    // ;
//  ______________________________________________________________________ 
//
// min          n1 n2 -- n3
// minimum between n1 and n2
                Colon_Def MIN, "MIN" , is_normal
                dw      TWO_DUP                 // 2dup
                dw      GREATER                 // >
                dw      ZBRANCH
                dw      Min_Skip - $   // if
                dw          SWAP                //      swap
Min_Skip:                                       // endif
                dw      DROP                    // drop
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// max          n1 n2 -- n3
// maximum between n1 and n2
                Colon_Def MAX, "MAX", is_normal
                dw      TWO_DUP                 // 2dup
                dw      LESS                    // <
                dw      ZBRANCH
                dw      Max_Skip - $   // if
                dw          SWAP                //      swap
Max_Skip:                                       // endif
                dw      DROP                    // drop
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?dup         n -- 0 | n n
// duplicate if not zero
                New_Def QDUP, "?DUP", is_code, is_normal
QDup_Ptr:
                pop     hl
                ld      a, h
                or      l
                jr      z, QDup_Skip
                    push    hl
QDup_Skip:                    
                psh1

//  ______________________________________________________________________ 
//
// -dup         n -- 0 | n n
// duplicate if not zero
                New_Def LDUP, "-DUP", is_code, is_normal
                jp      QDup_Ptr

//  ______________________________________________________________________ 
//
// emit         c --
                Colon_Def EMIT, "EMIT", is_normal
                dw      C_EMIT                      // (?emit)
                dw      QDUP                        // ?dup
                                                    // if                   
                dw      ZBRANCH
                dw      Emit_Skip - $
                dw          EMITC                   //      emitc
                dw          ONE                     //      1       
                dw          OUT, PLUSSTORE        //      out +! 
Emit_Skip:                                          // endif
                dw      EXIT                        // ;

//  ______________________________________________________________________ 
//
// space        --
                Colon_Def SPACE, "SPACE", is_normal
                dw      BL, EMIT                // bl emit
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// traverse     a n -- a
// A dictionary entry is structured as follows
// NFA: +0   one byte of word-length (n<32) | some flags (immediate, smudge) | $80
//      +1   word name, last character is toggled with $80
// LFA: +1+n link to NFA ofprevious  dictionary entry.
// CFA: +3+n routine address. Colon definitions here have a CALL aa
// PFA: +6+n "is_code", definitions have no PFA. // +5
//
                Colon_Def TRAVERSE, "TRAVERSE", is_normal
                dw      SWAP                    // swap
Traverse_Begin:                                 // begin
                dw          OVER, PLUS          //      over +
                dw          LIT, 127            //      127
                dw          OVER, CFETCH        //      over @
                dw          LESS                //      <    
                                                // until
                dw      ZBRANCH
                dw      Traverse_Begin - $
                dw      NIP                     //  nip
                dw      EXIT                    //  ;  

//  ______________________________________________________________________ 
//
// mmu7@        -- n
// query current page in MMU7 8K-RAM : 0 and 223

                New_Def MMU7_FETCH, "MMU7@", is_code, is_normal
                exx
                call    MMU7_read
                exx
                ld      l, a
                ld      h, 0
                push    hl
                next

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
                New_Def TO_FAR, ">FAR", is_code, is_normal
                pop     hl
                call    TO_FAR_rout
                push    hl
                ld      l, a
                ld      h, 0
                push    hl
                next
                   
//  ______________________________________________________________________ 
// 
// <far         a n  -- ha
// given an address E000-FFFF and a page number n (64-71 or 40h-47h)
// reverse of >FAR: encodes a FAR address compressing
// to bits 765 of H, lower bits of HL address offset from E000h
                New_Def FROM_FAR, "<FAR", is_code, is_normal
                pop     hl                  // page number in e
                ld      a, l
                and     07
                rrca
                rrca
                rrca
                ex      af, af
                pop     hl                  // address in hl
                ld      a, h
                and     $1F
                ld      h, a
                ex      af, af
                or      h
                ld      h, a
                psh1

//  ______________________________________________________________________ 
//
// ?IN_MMU7        a -- f
// query current page in MMU7 8K-RAM : 0 and 223
                Colon_Def QMMU7, "?IN_MMU7", is_normal
                dw      DUP
                dw      LIT, $E000
                dw      ULESS
                dw      NOT_OP
                dw      EXIT

//  ______________________________________________________________________ 
//
// far          hp -- ha
// query current page in MMU7 8K-RAM : 0 and 223
                Colon_Def FAR, "FAR", is_normal
                dw      TO_FAR
                dw      MMU7_STORE
                dw      EXIT

//  ______________________________________________________________________ 
//
// ?HEAP_PTR       n -- n f
// query current page in MMU7 8K-RAM : 0 and 223
                Colon_Def QHEAPP, "?HEAP_PTR", is_normal
                dw      DUP
                dw      ZBRANCH
                dw      QHeap_Skip - $
                dw          LIT, $6000
                dw          ULESS
QHeap_Skip:                                          // endif
                dw      EXIT                        // ;

//  ______________________________________________________________________ 
//
// ?>heap       n1 -- n2
// query current page in MMU7 8K-RAM : 0 and 223
                Colon_Def QTOHEAP, "?>HEAP", is_normal
                dw      DUP
                dw      QHEAPP
                dw      ZBRANCH
                dw      Q2Heap_Skip - $
                dw          FAR
Q2Heap_Skip:                                          // endif
                dw      EXIT                        // ;

//  ______________________________________________________________________ 
//
// hp_fetch     -- a
                Colon_Def HP_FETCH, "HP@", is_normal
                dw      HP, FETCH               // hp @
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// page-watermark   -- n
// number of buffers available. must be the difference between LIMIT and FIRST divided by 516
                Constant_Def PAGE_WATERMARK,   "PAGE-WATERMARK", $1F80  

//  ______________________________________________________________________ 
//
// skip-hp-page ha -- a
                Colon_Def SKIP_HP_PAGE, "SKIP-HP-PAGE", is_normal
                dw      HP_FETCH                // hp@
                dw      LIT, $1FFF, AND_OP      // 1FFF and
                dw      PLUS
                dw      PAGE_WATERMARK
                dw      GREATER
                dw      ZBRANCH
                dw      Skip_Skip - $   // if
                dw      HP_FETCH
                dw      LIT, $1FFF, OR_OP
                dw      ONE_PLUS, TWO_PLUS
                dw      HP, STORE
Skip_Skip:                
                dw      EXIT                    // ;
//  ______________________________________________________________________ 
//
// latest       -- nfa
                Colon_Def LATEST, "LATEST", is_normal
                dw      CURRENT                 // current
                dw      FETCH, FETCH            // @ @
                dw      FAR // Q TO HEAP
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// >body        cfa -- pfa
                Colon_Def TO_BODY, ">BODY", is_normal
                dw      THREE, PLUS             // cell+ --> 3 +
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// <name        cfa -- nfa
                Colon_Def TO_NAME, "<NAME", is_normal
                dw      CELL_MINUS              // cell-
                dw      DUP, FETCH
                dw      QHEAPP
                dw      ZBRANCH
                dw      ToName_Skip - $
                dw          FETCH, FAR
                dw          CELL_MINUS
ToName_Skip:                                    // endif

                dw      ONE_SUBTRACT            // 1-
                dw      NEG_ONE                 // -1
                dw      TRAVERSE                // traverse
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// cfa          pfa -- cfa
                Colon_Def CFA, "CFA", is_normal
                dw      THREE, SUBTRACT         // 3 -
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// nfa          pfa -- nfa
                Colon_Def NFA, "NFA", is_normal
                dw      CFA                     // cfa
                dw      TO_NAME                 // traverse
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// lfa          pfa -- lfa
                Colon_Def LFA, "LFA", is_normal
                dw      NFA                     // nfa
                dw      ONE                     // 1
                dw      TRAVERSE                // traverse
                dw      ONE_PLUS                // 1+
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// pfa          nfa -- pfa
                Colon_Def PFA, "PFA", is_normal
                dw      QTOHEAP
                dw      ONE                     // 1
                dw      TRAVERSE                // traverse
                dw      ONE_PLUS                // 1+
                dw      CELL_PLUS               // cell+
                dw      QMMU7
                dw      ZBRANCH
                dw      PFA_Skip - $
                dw          MMU7_FETCH
                dw          ONE, SUBTRACT
                dw          ZBRANCH
                dw          PFA_Skip - $
                dw              FETCH
PFA_Skip:                                    // endif
                dw      TO_BODY                 // >body
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// !csp         --
// store in user variable CSP current value of SP. Used at compile-time for syntax checkng
                Colon_Def STORE_CSP, "!CSP", is_normal
                dw      SPFETCH                 // sp@
                dw      CSP, STORE              // csp !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?error       f n --
// rase error n if flag f it true
                Colon_Def QERROR, "?ERROR", is_normal
                dw      SWAP                    // swap
                                                // if
                dw      ZBRANCH
                dw      QError_Else - $
                dw          ERROR               //      error  ( is a forward-ref )
                                                // else
                dw      BRANCH
                dw      QError_Endif - $
QError_Else:
                dw          DROP                //      drop
QError_Endif:                                   // endif
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?comp       --
// raise msg #17 if not compiling
                Colon_Def QCOMP, "?COMP", is_normal
                dw      STATE, FETCH            // state @
                dw      ZEQUAL                  // 0=
                dw      LIT, 17                 // 17  ( can't be executed )
                dw      QERROR                  // ?error
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?exec       --
// raise msg #18 if compiling
                Colon_Def QEXEC, "?EXEC", is_normal
                dw      STATE, FETCH            // state @
                dw      LIT, 18                 // 18  ( can't be compiled )
                dw      QERROR                  // ?error
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?pairs       n1 n2 --
// raise msg #19 if n1 != n2. Compiler pushes some placeholder to stack for syntax checking
                Colon_Def QPAIRS, "?PAIRS", is_normal
                dw      SUBTRACT                // -
                dw      LIT, 19                 // 18  ( syntax error )
                dw      QERROR                  // ?error
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?csp       --
// raise msg #20 if surrent SP in not what previously saved in CSP. 
// Compiler relies on that for  syntax checking of structures
                Colon_Def QCSP, "?CSP", is_normal
                dw      SPFETCH                 // sp@
                dw      CSP, FETCH              // csp @
                dw      SUBTRACT                // -
                dw      LIT, 20                 // 20  ( bad definition end )
                dw      QERROR                  // ?error
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?loading      --
// raise msg #22 if not loading
                Colon_Def QLOADING, "?LOADING", is_normal
                dw      BLK, FETCH              // blk @
                dw      ZEQUAL                  // 0=
                dw      LIT, 22                 // 22  ( aren't loading now )
                dw      QERROR                  // ?error
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// compile      --
// compiles the following word
                Colon_Def COMPILE, "COMPILE", is_normal
                dw      QCOMP                   // ?comp
                dw      R_TO                    // r>
                dw      DUP, CELL_PLUS          // dup, cell+
                dw      TO_R                    // >r
                dw      FETCH, COMMA            // @ ,
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// compile,     --
// compiles the following word
                Colon_Def COMPILE_XT, "COMPILE,", is_normal
                dw      QCOMP                   // ?comp
                dw      COMMA                   // ,
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// [            --
// stop compilation
                Colon_Def SQUARED_OPEN, "[", is_immediate
                dw      ZERO                    // 0
                dw      STATE, STORE            // state !
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// ]            --
// start compilation
                Colon_Def SQUARED_CLOSE, "]", is_normal
                dw      LIT, $C0                // 192
                dw      STATE, STORE            // state !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// smudge       --
// toggle smudge bit of latest definition
                Colon_Def SMUDGE, "SMUDGE", is_normal
                dw      LATEST                  // latest
                dw      LIT, SMUDGE_BIT         // 32
                dw      TOGGLE                  // toggle
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// immediate    --
// make immediate the latest definition
                Colon_Def IMMEDIATE, "IMMEDIATE", is_normal
                dw      LATEST                  // latest
                dw      LIT, $40                // 64
                dw      TOGGLE                  // toggle
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// hex          --
// change numeration base
                Colon_Def HEX, "HEX", is_normal
                dw      LIT, 16                 // 16
                dw      BASE, STORE             // base !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// decimal      --
// change numeration base
                Colon_Def DECIMAL, "DECIMAL", is_normal
                dw      LIT, 10                 // 10
                dw      BASE, STORE             // base !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// (;code)       --
// patch to CFA to call/jump to the "following code"
                Colon_Def C_SEMICOLON_CODE, "(;CODE)", is_normal
                dw      R_TO                    // r>       ( Return Stack has IP to caller's next cell )
                dw      LATEST                  // latest   ( Word being defined in this moment )
                dw      PFA, CFA                // pfa cfa  ( cfa of latest word )
                
                dw      LIT, $CD                // $CD      ( At Latest CFA put "call" op-code )
                dw      OVER, CSTORE            // over c!  ( why can't use comma? because CFA was already ALLOTted by create? )
                dw      ONE_PLUS                // 1+       ( At Latest CFA+1 put address for call. )
                
                dw      STORE                   // ! 
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ;code        --
                Colon_Def SEMICOLON_CODE, ";CODE", is_immediate
                dw      QCSP                    // ?csp
                dw      COMPILE                 // compile
                dw      C_SEMICOLON_CODE        // (;code)
                dw      SQUARED_OPEN            // [
                dw      NOOP                    // noop () can be patched later to ASSEMBLER... )
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// <builds      --
                Colon_Def CBUILDS, "<BUILDS", is_normal
                dw      ZERO                    // 0
                dw      CONSTANT                // constant
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// recurse      --
//              Colon_Def RECURSE, "RECURSE", is_immediate
//              dw      QCOMP                   // ?comp
//              dw      LATEST                  // latest
//              dw      PFA, CFA                // pfa cfa
//              dw      COMMA                   // ,
//              dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// does>     --
                Colon_Def DOES_TO, "DOES>", is_normal   
                dw      R_TO                    // r>
                dw      LATEST                  // latest
                dw      PFA                     // pfa 
                dw      STORE                   // !
                dw      C_SEMICOLON_CODE        // ;code
Does_Ptr:
                // via call coded in CFA
                ex      de, hl //** 
                // *** ldhlrp
                dec     hl                  // push on Return-Stack current Instruction-Pointer
                ld      (hl), b
                dec     hl
                ld      (hl), c
                // *** ldrphl
                ex      de, hl //** 
                pop     hl                  // CFA has a call to this, so PFA -> IP

                ld      c, (hl)
                inc     hl                  
                ld      b, (hl)
                inc     hl                  

                psh1
                // SMUDGE !

//  ______________________________________________________________________ 
//
// count        a -- a2 n
// expects a counted string at address a, returns string address and counter
                New_Def COUNT, "COUNT", is_code, is_normal
                exx
                pop     hl
                ld      e, (hl)
                ld      d, 0
                inc     hl
Count_Here:
                push    hl
                push    de
                exx
                next
//                pop     hl
//                ld      a, (hl)
//                inc     hl
//                push    hl  
//                ld      h, 0
//                ld      l, a
//                push    hl
//                next                

//  ______________________________________________________________________ 
//
// bounds       a n -- a+n n
// given an address and a length ( a n ) calculate the bound addresses
// suitable for DO-LOOP
                New_Def BOUNDS, "BOUNDS", is_code, is_normal
                exx
                pop     hl
                pop     de
                add     hl, de
                jr      Count_Here
                // push    hl  
                // push    de 
                // exx
                // next                

//  ______________________________________________________________________ 
//
// leave        --
// Compile (leave) to leave current LOOP and jump just after it
                Colon_Def LEAVE, "LEAVE", is_immediate
                dw      COMPILE, C_LEAVE       // compile (leave)     \ unloop and branch
                dw      HERE, TO_R, ZERO, COMMA // here >r 0 ,
                dw      ZERO, ZERO
                dw      SPFETCH, DUP
                dw      CELL_PLUS, CELL_PLUS
                dw      TUCK
                dw      CSP, FETCH
                dw      SWAP, SUBTRACT
                dw      CMOVE
                dw      CSP, FETCH, CELL_MINUS
                dw      R_TO, OVER, STORE
                dw      CELL_MINUS, ZERO
                dw      SWAP, STORE
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// type         a n --
// Sends to current output channel n characters starting at address a.
                Colon_Def TYPE, "TYPE", is_normal
                dw      BOUNDS                  // bounds
                dw      C_Q_DO                  // ?do
                dw      Type_Skip - $
Type_Loop:                
                dw          I, CFETCH           //      i c@
                dw          EMIT                //      emit
                dw      C_LOOP                  // loop 
                dw      Type_Loop - $
Type_Skip:                
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// -trailing    a n1 -- a n2
// Assumes that an n1 bytes-long string is stored at address a 
// and the string contains a space delimited word,
// Finds n2 as the position of the first character after the word.
                Colon_Def LTRAILING, "-TRAILING", is_normal
                dw      DUP, ZERO               // dup 0
                                                // do
                dw      C_Q_DO
                dw      LTrailing_Leave - $
LTrailing_Loop:
                dw          TWO_DUP, PLUS       //      2dup +
                dw          ONE_SUBTRACT        //      1-
                dw          CFETCH              //      c@
                dw          BL, SUBTRACT        //      bl -
                                                //      if
                dw          ZBRANCH
                dw          LTrailing_Else - $
                dw              C_LEAVE         //          leave
                dw              LTrailing_Leave - $
                dw          BRANCH              //      else
                dw          LTrailing_Endif - $
LTrailing_Else:         
                dw              ONE_SUBTRACT    //          1- 
LTrailing_Endif:                                //      endif    
                                                // loop 
                dw      C_LOOP              
                dw      LTrailing_Loop - $
LTrailing_Leave:
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// accept       a n1 -- n2
// Accepts at most n1 characters from terminal and stores them at address a 
// CR stops input. A 'nul' is added as trailer.
// n2 is the string length. n2 is kept in span user variable also.
                Colon_Def ACCEPT, "ACCEPT", is_normal
                dw      OVER, PLUS, OVER        //                      ( a  n1+a  a )
                dw      ZERO, DASH_ROT          //                      ( a  0     a+n1  a )
                                                // do                   
                dw      C_Q_DO
                dw      Accept_Leave - $
Accept_Loop:                                                            
                dw          CUR
                dw          DROP, KEY           //      drop key        ( a  c )
                dw          DUP                 //      dup             ( a  c  c )
                dw          LIT, $0E            //      0E
                dw          PLUS_ORIGIN         //      +origin      
                dw          FETCH               //      @               ( a  c  c  del )
                dw          EQUALS              //      =               ( a  c  c==del )
                                                //      if
                dw          ZBRANCH
                dw          Accept_Else_0 - $
                dw              DROP            //          drop        ( a  )
                dw              DUP, I, EQUALS  //          dup i =     ( a  a==i )
                dw              ONE, AND_OP     //          1 and
                dw              DUP             //          dup         ( a  a==i  a==i )
                dw              R_TO            //          r> 2 - + r>
                dw              TWO_MINUS, PLUS //      ( decrement index by 1 or 2 )
                dw              TO_R            //      
                                                //          if
                dw              ZBRANCH
                dw              Accept_Else_1 - $
                dw                  LIT, 7      //              7       ( a  7 )
                                                //          else
                dw              BRANCH
                dw              Accept_Endif_1 - $
Accept_Else_1:                
                dw                  LIT, 8      //              8       ( a  8 )
Accept_Endif_1:                                 //          endif         
                dw          BRANCH
                dw          Accept_Endif_0 - $                
Accept_Else_0:                                  //      else
                dw              DUP             //          dup         ( a  c  c )
                dw              LIT, 13         //          13    
                dw              EQUALS          //          =           ( a  c  c==CR )
                                                //          if
                dw              ZBRANCH
                dw              Accept_Else_2 - $
                dw                  DROP, BL    //              drop bl ( a  bl )
                dw                  ZERO        //              0       ( a  c  0 )
                                                //          else
                dw              BRANCH
                dw              Accept_Endif_2 - $
Accept_Else_2:
                dw                  DUP         //              dup     ( a  c  c )
                                                //          endif
Accept_Endif_2:
                dw              I, CSTORE       //          i           ( a  c )
                dw              DUP, BL, LESS   //          dup bl <    ( a  c  c<BL )
                                                //          if
                dw              ZBRANCH
                dw              Accept_Endif_3 - $ 
                dw                  R_TO        //              r> 
                dw                  ONE_SUBTRACT//              1-
                dw                  TO_R        //              >r
                                                //          endif
Accept_Endif_3:
Accept_Endif_0:                                 //      endif
                dw          EMIT                //      emit

                dw          ZERO, I, ONE_PLUS   //      0 i 1+ !
                dw          STORE               //          ( zero pad )
                dw          I                   //      i
                dw          I, CFETCH, ZEQUAL   //      i 0= if
                dw          ZBRANCH             //
                dw              Accept_Endif_4 - $ 
                dw                  C_LEAVE     //              leave       
                dw                  Accept_Leave - $
Accept_Endif_4:                                 //      endif
                                                // loop
                dw      C_LOOP
                dw      Accept_Loop - $
Accept_Leave:                
                dw      SWAP, SUBTRACT          // swap -
                dw      ONE_PLUS                // 1+
                dw      DUP, SPAN, STORE        // dup span !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// expect      a n -- 
// Accepts at most n1 characters from terminal and stores them at address a 
// CR stops input. A 'nul' is added as trailer.
// n2 is the string length. n2 is kept in span user variable also.
//              Colon_Def EXPECT, "EXPECT", is_normal
//              dw      ACCEPT, DROP            // accept drop
//              dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// query        -- 
// Accept at most 80 character from console. CR stops. 
// Text is stored in TIB. Variable IN is zeroed.
                Colon_Def QUERY, "QUERY", is_normal
                dw      TIB, FETCH              // tib @
                dw      LIT, 80                 // 80
                dw      ACCEPT, DROP            // accept drop
                dw      ZERO, TO_IN, STORE      // 0 >in !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// fill        a n c --
// If n > 0, fills n locations starting from address a with the value c.
                New_Def FILL, "FILL", is_code, is_normal
                exx
                pop     de                  // de has character
                pop     bc                  // bc has counter
                pop     hl                  // hl has address, save Instruction Pointer
Fill_Loop:                 
                    ld      a, b                
                    or      c
                jr      z, Fill_While_End
                    ld      (hl), e
                    dec     bc
                    inc     hl
                jr      Fill_Loop
Fill_While_End:   
                exx
                next

//  ______________________________________________________________________ 
//
// erase        a n --
// If n > 0, fills n locations starting from address a with 'nul' characters.
                Colon_Def ERASE, "ERASE", is_normal
                dw      ZERO, FILL              // 0 fill
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// blank        a n --
// If n > 0, fills n locations starting from address a with 'nul' characters.
                Colon_Def BLANK, "BLANK", is_normal
                dw      BL, FILL                // bl fill
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// hold         c --
// Used between <# and #> to insert a character c in numeric formatting.
                Colon_Def HOLD, "HOLD", is_normal
                dw      NEG_ONE                 // -1
                dw      HLD, PLUSSTORE          // hld +!
                dw      HLD, FETCH, CSTORE      // hld @ c!
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// pad         -- a
// leaves the buffer text address. This is at a fixed distance over HERE.
                Colon_Def PAD, "PAD", is_normal
                dw      HERE                    // here
                dw      LIT, 68                 // 68
                dw      PLUS                    // +
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// word         c -- a
// reads characters from input streams until it encouners a c delimiter.
// Stores that packet so it starts from HERE
// WORD leaves a counter as first byte and ends the packet with two spaces.
// Other occurrences of c are ignored.
// If BLK is zero, text is taken from terminal buffer TIB.
// Otherwise text is taken from the disk-block given by BLK.
// "in" variable is incremented of the number of character read.
// The number of characters read is given by ENCLOSE.
                Colon_Def WORD, "WORD", is_normal
                dw      BLK, FETCH              // blk @
                                                // if
                dw      ZBRANCH
                dw      Word_Else - $
                dw          BLK, FETCH          //      blk @
                dw          BLOCK               //      block ( forward )
                                                // else
                dw      BRANCH
                dw      Word_Endif - $
Word_Else: 
                dw         TIB, FETCH           //      tib @
Word_Endif:                                     // endif
                dw      TO_IN, FETCH, PLUS      // >in @ +
                dw      SWAP, ENCLOSE           // swap enclose
                dw      HERE, LIT, 34, BLANK    // here 34 blank 
                dw      TO_IN, PLUSSTORE        // >in @ +    
                dw      OVER, SUBTRACT, TO_R    // over - >r    
                dw      R_OP, HERE, CSTORE      // r here c!
                dw      PLUS                    // +
                dw      HERE, ONE_PLUS, R_TO    // here 1+ r>
                dw      CMOVE                   // cmove
                dw      HERE                    // here
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// (.")         --
// Direct procedure compiled by ." and  .(  It executes TYPE.
                Colon_Def C_DOT_QUOTE, '(.")', is_normal
                dw      R_OP, COUNT             // r count
                dw      DUP, ONE_PLUS           // dup 1+
                dw      R_TO, PLUS, TO_R        // r> + >r  ( advance IP )
                dw      TYPE                    // type
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// char         -- c
// get first character from next input word
                Colon_Def CHAR,  "CHAR", is_normal
                dw      BL, WORD                // bl word
                dw      ONE_PLUS, CFETCH        // 1+ c@
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ,"           -- 
// compiles a string terminated by " as a counted string from next input stream
                Colon_Def COMMA_QUOTE,  ',"', is_normal
                dw      LIT, DQUOTE_CHAR        // [char] "
                dw      WORD                    // word
                dw      CFETCH, ONE_PLUS        // c@ 1+
                dw      ALLOT                   // allot
                dw      ZERO, CCOMMA            // 0 c,  ( nul-terminated string - useful anyway )
                dw      EXIT

//  ______________________________________________________________________ 
//
// .c           c --
// intermediate general purpose string builder, used by ." and .(
                Colon_Def DOT_C,  ".C", is_immediate
                dw      STATE, FETCH            // state @
                                                // if
                dw      ZBRANCH
                dw      Dot_C_Else - $
                dw          COMPILE, C_DOT_QUOTE //     compile (.")
                dw          WORD, CFETCH        //      word c@
                dw          ONE_PLUS, ALLOT     //      1+ allot
                                                // else
                dw      BRANCH
                dw      Dot_C_Endif - $
Dot_C_Else:              
                dw          WORD, COUNT, TYPE   //      word count type
Dot_C_Endif:                                    // endif
                dw      EXIT                    ;

//  ______________________________________________________________________ 
//
// ."           c --
                Colon_Def DOT_QUOTE,  '."', is_immediate
                dw      LIT, DQUOTE_CHAR        // [char] "  
                dw      DOT_C                   // [compile] .c
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// .(           c --
                Colon_Def DOT_BRACKET,  ".(", is_immediate
                dw      LIT, ")"                // [char] ) 
                dw      DOT_C                   // [compile] .c     
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// (sgn)        a -- a f
// determines if char in addr a is a sign (+ or -), and in that case increments
// a flag. Returns f as the sign, true for negative, false for positive.
// called by NUMBER and (EXP)
                Colon_Def CSGN,  "(SGN)", is_normal
                dw      DUP, ONE_PLUS, CFETCH   // dup 1+ c@
                dw      DUP, LIT, "-", EQUALS   // dup [char] - =
                                                // if
                dw      ZBRANCH
                dw      CSgn_Else_0 - $   
                dw          DROP                //      drop
                dw          ONE_PLUS            //      1+
                dw          ONE, DPL, PLUSSTORE //      1 dpl +!
                dw          ONE                 //      1
                                                // else
                dw      BRANCH
                dw      CSgn_Endif_0 - $ 
CSgn_Else_0:          
                dw          LIT, "+", EQUALS    //      [char] + =
                                                //      if
                dw          ZBRANCH
                dw          CSgn_Endif_1 - $
                dw              ONE_PLUS        //          1+
                dw              ONE, DPL        //          1 dpl
                dw              PLUSSTORE       //          +!
CSgn_Endif_1                                    //      endif
                dw          ZERO                //      0    
CSgn_Endif_0:                                   // endif
                dw      EXIT

//  ______________________________________________________________________ 
//
// (number)     d a -- d1 a1
// using the current BASE parse characters stored in address a 
// accumulating a double precision integer d
// the process stops at the first not-convertible character
// A double-number is kept in CPU registers as HLDE.
// On the stack a double number is treated as two single numbers
// where HL is on the top of the stack and DE is the second from top,
// so in the stack memory it appears as LHED.
// Instead, in 2VARIABLE a double number is stored as EDLH.
                Colon_Def CNUMBER,  "(NUMBER)", is_normal
                                                // begin
CNumber_Begin:                
                dw          ONE_PLUS            //      1+
                dw          DUP, TO_R           //      dup >r
                dw          CFETCH              //      @
                dw          BASE, FETCH         //      base @
                dw          DIGIT               //      digit
                                                // while
                dw      ZBRANCH
                dw      CNumber_While_end - $
                dw          SWAP                //      swap
                dw          BASE, FETCH         //      base @
                dw          UM_MUL              //      um*
                dw          DROP, ROT           //      drop rot
                dw          BASE, FETCH         //      base @
                dw          UM_MUL              //      um*
                dw          DPLUS               //      d+
                dw          DPL, FETCH          //      dpl @
                dw          ONE_PLUS            //      1+
                                                //      if
                dw          ZBRANCH
                dw          CNumber_Endif - $
                dw              ONE, DPL        //          1 dpl
                dw              PLUSSTORE       //          +!
CNumber_Endif:                                  //      endif
                dw             R_TO             //      r>  ( balance rp )
                dw      BRANCH
                dw      CNumber_Begin - $
CNumber_While_end:                              // repeat          
                dw      R_TO                    // r>  ( balance rp on exit while-repeat )
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// (prefix)
                Colon_Def CPREFIX,  "(PREFIX)", is_normal
                dw      DUP, ONE_PLUS, CFETCH   // dup 1+ c@
                dw      DUP, TO_R               // dup >r
                dw      LIT, "$", EQUALS        // [char] $ =
                                                // if
                dw      ZBRANCH
                dw      CPrefix_Endif_0 - $   
                dw          ONE_PLUS            //      1+
                dw          LIT, 16 
                dw          BASE, STORE         //      16 base !
CPrefix_Endif_0:                                // endif
                dw      R_TO                    // r>
                dw      LIT, "%", EQUALS        // [char] $ =
                                                // if
                dw      ZBRANCH
                dw      CPrefix_Endif_1 - $   
                dw          ONE_PLUS            //      1+
                dw          TWO                 
                dw          BASE, STORE         //      2 base !
CPrefix_Endif_1:                                // endif
                dw      EXIT

//  ______________________________________________________________________ 

                New_Def PDOM,   "PDOM", Create_Ptr, is_normal  
                db ',/-:'

                New_Def PCDM,   "PCDM", Create_Ptr, is_normal  
                db '....' 

//  ______________________________________________________________________ 
//
// number       a -- d
                Colon_Def NUMBER,  "NUMBER", is_normal
                dw      ZERO, ZERO              // 0 0
                dw      ROT                     // rot
                dw      CSGN, TO_R              // (sgn) >r
                dw      BASE, FETCH, TO_R       // base @ >r  // ***
                dw      CPREFIX                 // (prefix)   // ***
                dw      NEG_ONE, DPL, STORE     // -1 dpl !
                dw      CNUMBER                 // (number)
Number_Begin:                                   // begin
                dw        DUP, CFETCH             // dup c@
                dw        TO_R                    // >r
                dw        PCDM, PDOM, LIT, 4      // pcdm pdom 4
                dw        R_TO                    // r>
                dw        C_MAP                   // (map)
                dw        ZERO, SWAP              // 0 swap
                dw        LIT, ".", EQUALS        // [char] . =  ( decimal point )
                                                  
                dw        ZBRANCH                 // if  
                dw        Number_Endif_1 - $
                dw          ZERO, DPL, STORE        //      0 dpl !
                dw          ONE_PLUS                //      1+
Number_Endif_1:                                   // endif   

                dw      ZBRANCH                // while
                dw      Number_While_end - $
                dw        CNUMBER                 // (number)
                dw      BRANCH                 
                dw      Number_Begin - $        
Number_While_end:                               // repeat          

                dw      CFETCH, BL              // c@ bl
                dw      SUBTRACT, ZERO, QERROR  // - 0 ?error
                dw      R_TO, BASE, STORE       // r> base !  // ***
                dw      R_TO                    // r>
                                                // if
                dw      ZBRANCH
                dw      Number_Endif_2 - $
                dw          DMINUS              //      dminus
Number_Endif_2:                                 // endif
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// twofind      a -- d
                Colon_Def TWOFIND,  "2FIND", is_normal
                dw      TO_R, R_OP              // >r r@
                dw      CONTEXT, FETCH, FETCH   // context @ @
                dw      C_FIND                  // (find)
                dw      QDUP                    // ?dup
                dw      ZEQUAL                  // 0=
                                                // if
                dw      ZBRANCH
                dw      LFind_Endif - $
                dw          R_OP                //      r@
                // dw          LATEST               //      latest
                dw          CURRENT, FETCH, FETCH   // context @ @
                dw          C_FIND              //      (find)

                    dw      QDUP                    // ?dup
                    dw      ZEQUAL                  // 0=
                                                    // if
                    dw      ZBRANCH
                    dw      LFind_Endif2 - $
                    dw          R_OP                //      r@
                    dw          LIT, FORTH, TO_BODY
                    dw          CELL_PLUS, CELL_PLUS
                    dw          FETCH
                    dw          C_FIND              //      (find)
LFind_Endif2:                                    // endif


LFind_Endif:                                    // endif
                dw      R_TO, DROP              // r> drop
                dw      EXIT                    // ;    

//  ______________________________________________________________________ 
//
// -find        a -- d
                Colon_Def LFIND,  "-FIND", is_normal
                dw      BL, WORD                // bl word
                dw      TWOFIND                 // 2find
                dw      EXIT                    // ;    

//  ______________________________________________________________________ 
//
// (abort)      --
                Colon_Def CABORT,  "(ABORT)", is_normal
                dw      ABORT                   // abort
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// error        n --
// raise an error 
// if WARNING is 0, prints "MSG#n".
// if WARNING is 1, prints line n of screen 4.
// if WARNING is -1 does (ABORT) that normally does ABORT
// value can be negative or beyond block 4.
                Colon_Def ERROR,  "ERROR", is_normal
                dw      WARNING, FETCH, ZLESS   // warning @ 0<
                                                // if
                dw      ZBRANCH
                dw      Error_Endif_1 - $
                dw          CABORT              //      (abort)
Error_Endif_1:                                  // endif
                dw      HERE, COUNT, TYPE       // here count type
                dw      C_DOT_QUOTE             // .( ? )
                db      2, "? " 
                dw      MESSAGE                 // message  ( forward )
                dw      S0, FETCH, SPSTORE      // s0 @ sp!
                dw      BLK, FETCH, QDUP        // blk @ ?dup
                                                // if
                dw      ZBRANCH
                dw      Error_Endif_2 - $
                dw          TO_IN, FETCH, SWAP  //      >in @ swap
Error_Endif_2:                                  // endif   
                dw      QUIT                    // quit ( forward )
                dw      EXIT                    // ; 
//  ______________________________________________________________________ 
//
// id.          nfa --
                Colon_Def ID_DOT,  "ID.", is_normal
                dw      QTOHEAP 
                dw      DUP, ONE, TRAVERSE      // dup 1 traverse
                dw      ONE_PLUS                // 1+
                dw      OVER, SUBTRACT          // over -
                dw      DUP, TO_R               // >r
                dw      PAD, SWAP               // pad swap
                dw      CMOVE                   // cmove
                dw      PAD, ONE_PLUS           // pad 1+
                dw      R_TO, ONE_SUBTRACT      // R> 1-
                dw      TYPE, SPACE             // type
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// code         -- cccc
                Colon_Def CODE,  "CODE", is_normal
                dw      LFIND                   // -find
                                                // if
                dw      ZBRANCH
                dw      Code_Endif - $
                dw          DROP                //      drop
                dw          TO_NAME, ID_DOT     //      >name id.
                dw          LIT, 4, MESSAGE     //      4 message
                dw          SPACE               //      space
Code_Endif:                                     // endif                
                dw      HERE                    // here
                                                // ( ---- here begins NFA ---- )
                dw      DUP, CFETCH             // dup c@
                dw      WIDTH, FETCH, MIN       // width @ min  ( max 31 character length )
                dw      ONE_PLUS                // 1+
                dw      DUP, ALLOT              // dup allot
                dw      CELL_PLUS, CELL_PLUS    // cell+ cell+
                dw      TO_R                    // >r
                dw      DUP                     // dup  
                dw      LIT
                dw      SMUDGE_BIT | END_BIT    // 160
                dw      TOGGLE                  // toggle
                dw      HERE, ONE_SUBTRACT      // here 1- ( last character )
                dw      LIT, END_BIT, TOGGLE    // 128 toggle
                                                // ( ---- here is LFA ---- )
                dw      CURRENT, FETCH, FETCH   // current @ @ , \ latest ,
                dw      COMMA
                dw      DUP, CELL_PLUS, COMMA   // dup cell+ ,
                dw      HP_FETCH                // hp@ 
                dw      CURRENT, FETCH, STORE   // current @ ! ( save this word as the latest )
                dw      HP_FETCH, FAR           // hp@ far R@ cmove
                dw      R_OP, CMOVE          
                dw      R_OP, MINUS, ALLOT      // r@ negate allot 
                dw      R_TO, HP, PLUSSTORE     // r> hp +!
                dw      HP_FETCH, CELL_MINUS    // hp@ cell- ,
                dw      COMMA
                dw      ZERO, SKIP_HP_PAGE
                                                // ( ---- here is LFA ---- )
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// create       -- cccc     ( compile time )
//              -- a        ( run time )
                Colon_Def CREATE,  "CREATE", is_normal
                dw      CODE, SMUDGE            // code smudge    
                dw      LIT, $CD, CCOMMA        // 00CD c,
                dw      LIT, Variable_Ptr, COMMA// Variable_Ptr ,
                dw      C_SEMICOLON_CODE
                // this routine is called from the call coded in CFA
Create_Ptr:



                next

//  ______________________________________________________________________ 
//
// [compile]    -- cccc     ( compile time )
                Colon_Def COMPILE_IMMEDIATE,  "[COMPILE]", is_immediate
                dw      LFIND                   // -find      (  cfa  b  f  )
                dw      ZEQUAL                  // 0=         (  cfa  b  )
                dw      ZERO, QERROR            // 0 ?error
                dw      DROP                    // drop       (  cfa  )
                dw      COMMA                   // ,
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// literal      n --      ( compile time )
                Colon_Def LITERAL,  "LITERAL", is_immediate
                dw      STATE, FETCH            // state @      
                                                // if
                dw      ZBRANCH
                dw      Literal_Endif - $
                dw          COMPILE, LIT        //      compile lit
                dw          COMMA               //      ,
Literal_Endif:                                  // endif
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// dliteral     n --      ( compile time )
                Colon_Def DLITERAL,  "DLITERAL", is_immediate
                dw      STATE, FETCH            // state @      
                                                // if
                dw      ZBRANCH
                dw      DLiteral_Endif - $
                dw          SWAP                //      swap
                dw          LITERAL,  LITERAL   //      [compile] literal [compile] literal
DLiteral_Endif:                                 // endif
                dw      EXIT                    // ; immediate

//  ______________________________________________________________________ 
//
// [char]       n --      ( compile time )
// inside colon definition, gets first character from next input word 
// and compiles it as literal.
                Colon_Def COMPILE_CHAR,  "[CHAR]", is_immediate
                dw      CHAR, LITERAL           // char [compile] literal
                dw      EXIT                    // ; immediate  

//  ______________________________________________________________________ 
//
// 0x00         n --      ( compile time )
                Colon_Def NUL_WORD,  $00, is_immediate
                dw      BLK, FETCH, ONE         // blk @ 1 
                dw      GREATER                 // > if
                                                // if
                dw      ZBRANCH
                dw      Nul_Else_1 - $
                dw          ONE, BLK, PLUSSTORE //      1 blk +!
                dw          ZERO, TO_IN, STORE  //      0 >in !
                dw          BLK, FETCH          //      blk @
                dw          BSCR                //      b/scr
                dw          ONE_SUBTRACT        //      1 - 
                dw          AND_OP              //      and  ( this is tricky )
                dw          ZEQUAL              //      0=
                                                //      if
                dw          ZBRANCH
                dw          Nul_Endif_2 - $
                dw              QEXEC           //          ?exec
                dw              R_TO, DROP      //          r> drop
Nul_Endif_2:                                    //      endif
                dw      BRANCH
                dw      Nul_Endif_1 - $
Nul_Else_1:                                     // else              
                dw          R_TO, DROP          //      r> drop
Nul_Endif_1:                                    // endif
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// ?stack       --
// Raise error #1 if stack is empty and you pop it
// Raise error #7 if stack is full.
// This means SP must always stay between HERE and FFFF 
// For 128K BANK paging purpose SP must be <= BFE0 and 50 words room
// for Next 8K MMU paging this is $DOE8
                Colon_Def QSTACK, "?STACK", is_normal
                dw      SPFETCH                 // sp@
                dw      S0, FETCH               // s0 @
                dw      SWAP, ULESS             // swap u< 
                dw      ONE, QERROR             // 1 ?error
                dw      HERE                    // here
                dw      S0, FETCH, LESS         // s0 @ <
                                                // if
                dw      ZBRANCH 
                dw      QStack_Endif - $ 
                dw          SPFETCH             //      sp@
                dw          HERE, LIT, 128      //      here 128
                dw          PLUS, ULESS         //      plus u<
                dw          LIT, 7, QERROR      //      7 Cerror
QStack_Endif:                                   // endif
                dw      EXIT                    // ;


