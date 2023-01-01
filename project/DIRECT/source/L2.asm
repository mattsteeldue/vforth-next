//  ______________________________________________________________________ 
//
//  L2.asm
// 
//  Level-2 
//  the Forth interpreter, vocabulary, cold/warm start and quit from Forth. 
//  ______________________________________________________________________ 


//  ______________________________________________________________________ 
//
// interpret    --
// This is the text interpreter.
// It executes or compiles, depending on STATE, the text coming from
// current input stream.
// If the word search fails after parsing CONTEXT and CURRENT vocabulary,
// the word is interpreted as numeric and converted, using current BASE,
// leaving on top of stack a single or double precision number, depending 
// on the presence of a decimal point.
// If the number conversion fails, the terminal is notified with ? followed
// by the offending word.
                Colon_Def INTERPRET, "INTERPRET", is_normal
                        
Interpret_Begin:                                        // begin                            
                dw          LFIND                       //      -find
                                                        //      if
                dw          ZBRANCH
                dw          Interpret_Else_1 - $
                dw              STATE, FETCH, LESS      //          state @ <
                                                        //          if   
                dw              ZBRANCH
                dw              Interpret_Else_2 - $
                dw                  COMPILE_XT          //              compile,
                                                        //          else       
                dw              BRANCH
                dw              Interpret_Endif_2 - $
Interpret_Else_2:  
                dw                  EXECUTE, NOOP       //              execute nooop
Interpret_Endif_2:                                      //          endif                
                                                        //      else
                dw          BRANCH
                dw          Interpret_Endif_1 - $
Interpret_Else_1:
                dw              HERE, NUMBER            //          here number
                dw              DPL, FETCH, ONE_PLUS    //          dpl @ 1+
                                                        //          if
                dw              ZBRANCH
                dw              Interpret_Else_3 - $
//              dw                  NMODE, FETCH        //              nmode @
//                                                      //              if
//              dw                  ZBRANCH
//              dw                  Interpret_Endif_4 - $
//              dw                      ONE, ZERO       //                  1 0
//              dw                      TWO_DROP        //                  2drop    
//Interpret_Endif_4:                                      //              endif
                dw                  DLITERAL            //              [compile] dliteral
                                                        //          else
                dw              BRANCH
                dw              Interpret_Endif_3 - $
Interpret_Else_3:
                dw                  DROP                //              drop
                dw                  LITERAL             //              [compile]  literal
Interpret_Endif_3:                                      //          endif                
Interpret_Endif_1:                                      //      endif    
                dw          QSTACK                      //      ?stack
//              dw          QTERMINAL                   //      ?terminal
//                                                      //      if
//              dw          ZBRANCH
//              dw          Interpret_Endif_5 - $
//              dw              CABORT                  //          (abort)
//Interpret_Endif_5:                                      //      endif
                dw      BRANCH
                dw      Interpret_Begin - $     
                dw      EXIT                            // ;

//  ______________________________________________________________________ 
//
// vocabulary   -- cccc     ( compile time )
// Defining word used in the form   VOCABULARY cccc
// creates the word  cccc  that gives the name to the vocabulary.
// Giving  cccc  makes the vocabulary CONTEXT so its words are executed first
// Giving  cccc DEFINITIONS makes  the vocabulary  CURRENT 
// so new definitions can be inserted in that vocabulary.
                Colon_Def VOCABULARY, "VOCABULARY", is_normal
                
                dw      CBUILDS

                dw      LIT, $A081, COMMA       // $81A0 ,
                dw      CURRENT, FETCH          // current @    
                dw      CELL_MINUS, COMMA       // cell- ,
                dw      HERE                    // here 
                dw      VOC_LINK, FETCH, COMMA  // voc-link @ ,
                dw      VOC_LINK, STORE         // voc-link !

                dw      DOES_TO                 // does>
Vocabulary_Does:
                dw      CELL_PLUS               // cell+
                dw      CONTEXT, STORE          // context !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// forth        --
// Name of the first vocabulary. 
// It makes FORTH the CONTEXT vocabulary. 
// Until new user vocabulary are defined, new colon-definitions becomes
// part of FORTH. It is immediate, so it will executed during the creation
// of a colon definition to be able to select the vocabulary.

                New_Def FORTH, "FORTH", Does_Ptr, is_immediate
                dw      Vocabulary_Does
                db      $81, $A0
Forth_Latest_Ptr:                
                dw      Latest_Definition // Fence_Word // Latest_Definition // Here_Dictionary
Voclink_Ptr:                
                dw      0
// Any new vocabulary is structured as follow:
// PFA+0 points to DOES> part of VOCABULARY to perform CELL+ CONTEXT !
// PFA+2 is 81,A0 i.e. a null-word used as LATEST in the new vocabulary
// PFA+4 always contains the LATEST word of this VOCABULARY.
//       at creations it points to the null-word of its parent vocabulary
//       that is normally FORTH, For example ASSEMBLER points FORTH's null-word
// PFA+6 is the pointer that builds up the vocabulary linked list.
//       FORTH has 0 here to signal the end of the list and user's variable
//       VOC-LINK points to PFA+6 of the newest vocabulary created.
//       While FORTH is the only vocabulary, VOC-LINK points to FORTH's PFA+6
//       When ASSEMBLER is created, its PFA+6 points to FORTH's PFA+6, and so on

//  ______________________________________________________________________ 
//
// definitions  --
// Used in the form  cccc DEFINITIONS
// set the CURRENT vocabulary at CONTEXT to insert new definitions in 
// vocabulary cccc.
                Colon_Def DEFINITIONS, "DEFINITIONS", is_normal
                dw      CONTEXT, FETCH          // context @
                dw      CURRENT, STORE          // current !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// (            -- cccc )
// the following text is interpreted as a comment until a closing ) 
                Colon_Def COMMENT_BRAKET, "(", is_immediate 
                dw      LIT, ")"                // [char] )
                dw      WORD, DROP              // word drop
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// quit         --
// \ Erase the return-stack, stop any compilation and give controlo to the console. No message is issued.
                Colon_Def QUIT, "QUIT", is_normal

                dw      SOURCE_ID, FETCH        // source-id @
                dw      F_CLOSE, DROP           // f_close drop
                dw      ZERO, SOURCE_ID, STORE  // 0 source-id !
                dw      ZERO, BLK, STORE        // 0 blk !
                dw      SQUARED_OPEN            // [compile] [
                                                // begin
Quit_Begin:                                                
                dw      R0, FETCH, RPSTORE      //      r0 @ rp!
                dw      CR                      //      cr
                dw      QUERY                   //      query
Next_Breakpoint_1:
                dw      INTERPRET               //      interpret                                                
                dw      STATE, FETCH, ZEQUAL    //      state @ 0=
                                                //      if
                dw      ZBRANCH
                dw      Quit_Endif - $
                dw          C_DOT_QUOTE 
                db          2, "ok"             //          .( ok)
Quit_Endif:                                     //      else
                                                // again
                dw      BRANCH
                dw      Quit_Begin - $
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// abort        --
                Colon_Def ABORT, "ABORT", is_normal
                dw      S0, FETCH, SPSTORE      // s0 @ sp!
                dw      DECIMAL                 // decimal
                dw      FORTH                   // [compile] forth
                dw      DEFINITIONS             // definitions
Autoexec_Ptr:                
                dw      AUTOEXEC                // autoexec, patched to noop
                dw      QUIT                    // quit
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// warm         --
                Colon_Def WARM, "WARM", is_normal
                dw      BLK_INIT                // blk-init
                dw      SPLASH                  // splash
                dw      LIT, 7, EMIT            // 7 emit
                dw      ABORT                   // abort
                dw      EXIT                    // exit

//  ______________________________________________________________________ 
//
// cold         --
                Colon_Def COLD, "COLD", is_normal
                dw      LIT, S0_origin          // [ hex $12 +origin ] Literal 
                dw      LIT, USER_Pointer       // [ hex $3E +origin ] literal
                dw      FETCH                   // @
                dw      LIT, 6, PLUS            // 6 +
                dw      LIT, 20                 // 20
                dw      CMOVE
                dw      LIT, Latest_origin      // [ hex 0C +origin ] literal 
                dw      FETCH                   // @
                dw      LIT, Forth_Latest_Ptr   // [ ' forth >body 4 + ] Literal
                dw      STORE                   // ! 
                dw      ZERO, NMODE, STORE      // 0 nmode !
                dw      FIRST, FETCH, DUP       // first @ dup
                dw      USE, STORE              // use !
                dw      PREV, STORE             // prev !
                dw      LIT, 4, PLACE, STORE    // 4 place !
//              dw      LIT, 8
//              dw      LIT, FLAGS2, CSTORE     // 8 5C6A c!
                dw      TWO, HP, STORE          // 2 hp !
Warm_Start:     dw      WARM
Cold_Start:     dw      COLD      
                dw      EXIT        

//  ______________________________________________________________________ 
WarmRoutine:
ColdRoutine:
                ld      ix, Next_Ptr
                exx
                push    hl
                exx

                ld      (SP_Basic), sp
                ld      sp, (S0_origin)
//              nop
                ld      hl, (R0_origin)
//              nop
                ldrphl
                ld      bc, Warm_Start
                jr      c, Warm_Skip
                inc     bc
                inc     bc
Warm_Skip:  
                next                

//  ______________________________________________________________________ 
//
// basic        --
                New_Def BASIC, "BASIC", is_code, is_normal
                pop     bc
                ld      hl, 0
                add     hl, sp
                ld      sp, (SP_Basic)
//              nop
                ld      (SP_Basic),hl
                exx
                pop     hl
                exx
                ret     // to Basic

//  ______________________________________________________________________ 
//
// +-           n1 n2 -- n3
// leaves n1 with the sign of n2 as n3.
                Colon_Def PLUS_MINUS, "+-", is_normal
                dw      ZLESS                   // 0<
                                                // if
                dw      ZBRANCH
                dw      Plus_Minus_Endif - $
                dw          MINUS               //      minus
Plus_Minus_Endif:                               // endif 
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// d+-          d1 n -- d2
// leaves d1 with the sign of n as d2.
                Colon_Def DPLUS_MINUS, "D+-", is_normal
                dw      ZLESS                   // 0<
                                                // if
                dw      ZBRANCH
                dw      DPlus_Minus_Endif - $
                dw          DMINUS              //      dminus
DPlus_Minus_Endif:                              // endif 
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// abs          n1 -- n2
                Colon_Def ABS_OP, "ABS", is_normal
                dw      DUP                     // dup
                dw      PLUS_MINUS              // +-
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// dabs         d1 -- d2
                Colon_Def DABS, "DABS", is_normal
                dw      DUP                     // dup
                dw      DPLUS_MINUS             // d+-
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// m*           n1 n2 -- d
// multiply two integer giving a double
                Colon_Def MMUL, "M*", is_normal
                dw      TWO_DUP, XOR_OP, TO_R   // 2dup xor >r
                dw      ABS_OP, SWAP            // abs swap
                dw      ABS_OP, UM_MUL          // abs um*
                dw      R_TO, DPLUS_MINUS       // r> d+-
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// sm/rem       d n -- q r
// Symmetric division: divides a double into n giving quotient q and remainder r 
// the remainder has the sign of d.
                Colon_Def SMDIVM, "SM/REM", is_normal
                dw      OVER, TO_R, TO_R        // over >r >r
                dw      DABS, R_OP, ABS_OP      // dabs r abs 
                dw      UMDIVMOD                // um/mod
                dw      R_TO                    // r>
                dw      R_OP, XOR_OP            // r xor 
                dw      PLUS_MINUS, SWAP        // +- swap
                dw      R_TO                    // r>
                dw      PLUS_MINUS, SWAP        // +- swap
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// fm/mod       d n -- q r
// Floored division: divides a double into n giving quotient q and remainder r 
// the remainder has the sign of d.
                Colon_Def FMDIVM, "FM/MOD", is_normal
                dw      DUP, TO_R               // dup >r
                dw      SMDIVM
                dw      OVER, DUP
                dw      ZEQUAL, ZEQUAL
                dw      SWAP, ZLESS
                dw      R_OP, ZLESS
                dw      XOR_OP, AND_OP
                dw      ZBRANCH
                dw      Fm_Mod_Else - $
                dw          ONE_SUBTRACT
                dw          SWAP, R_TO
                dw          PLUS, SWAP
                dw      BRANCH
                dw      Fm_Mod_Endif - $
Fm_Mod_Else:
                dw          R_TO, DROP
Fm_Mod_Endif:
                dw      EXIT
//              dw      TWO_DUP                 // 2dup
//              dw      XOR_OP, TO_R, TO_R      // xor >r >r
//              dw      DABS, R_OP, ABS_OP      // dabs r abs 
//              dw      UMDIVMOD                // um/mod
//              dw      SWAP                    // swap
//              dw      II, ZLESS               // i'
//              dw      ONE, AND_OP, PLUS       // 0< 1 and +
//              dw      R_TO                    // r>
//              dw      PLUS_MINUS, SWAP        // +- swap
//              dw      R_OP                    // r@
//              dw      ZLESS                   // i'
//              dw      ONE, AND_OP, PLUS       // 0< 1 and +
//              dw      R_TO                    // r>
//              dw      PLUS_MINUS              // +- swap
//              dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// m/mod        d n -- q r
// multiply two integer giving a double
                Colon_Def MDIVM, "M/MOD", is_normal
                dw      SMDIVM
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// m/           d n -- q
// multiply two integer giving a double
                Colon_Def MDIV, "M/", is_normal
                dw      MDIVM, NIP
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// *            n1 n2 -- n3
// multiply two integer
                Colon_Def MUL, "*", is_normal
                dw      MMUL, DROP              // m* drop
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// /mod         n1 n2 -- n3 n4
// leaves quotient n4 and remainder n3 of the integer division n1 / n2. 
// The remainder has the sign of n1
                Colon_Def DIVMOD, "/MOD", is_normal
                dw      TO_R, S_TO_D, R_TO      // >r s->d r>
                dw      MDIVM                   // m/mod
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// /            n1 n2 -- n3
// division
                Colon_Def DIV, "/", is_normal
                dw      DIVMOD, NIP             // /mod nip
                dw      EXIT                    // ;
   
//  ______________________________________________________________________ 
//
// mod          n1 n2 -- n3
                Colon_Def MOD, "MOD", is_normal
                dw      DIVMOD, DROP            // /mod drop
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// */mod        n1 n2 n3 -- n4 n5
// leaves the quotient n5 and the remainder n4 of the operation
// (n1 * n2) / n3. The intermediate passage through a double number
// avoids loss of precision
                Colon_Def MUL_DIV_MOD, "*/MOD", is_normal
                dw      TO_R, MMUL              // >r  m*
                dw      R_TO, MDIVM             // r>  m/mod
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// */          n1 n2 n3 -- n4
// (n1 * n2) / n3. The intermediate passage through a double number avoids loss of precision
                Colon_Def MUL_DIV, "*/", is_normal
                dw     MUL_DIV_MOD              // */mod 
                dw     NIP                      // nip
                dw     EXIT                     // ;


//  ______________________________________________________________________ 
//
// m/mod        ud1 u2 -- u3 ud4
// mixed operation: it leaves the remainder u3 and the quotient ud4 of ud1 / u1.
// All terms are unsigned.
//              Colon_Def MDIV_MOD, "M/MOD", is_normal
//              dw      TO_R                    // >r           ( ud1 )
//              dw      ZERO, R_OP, UMDIVMOD    // 0 r um/mod   ( l rem1 h/r )            
//              dw      R_TO, SWAP, TO_R        // r> swap >r   ( l rem )
//              dw      UMDIVMOD                // um/mod       ( rem2 l/r )
//              dw      R_TO                    // r>           ( rem2 l/r h/r )
//              dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// (line)       n1 n2 -- a b
// sends the line n1 of block n2 to the disk buffer.
// it returns the address a and ca counter b = C/L meaning a whole line.
                Colon_Def CLINE, "(LINE)", is_normal
                dw      TO_R                    // >r
                dw      NOOP                    // noop
                dw      CL                      // c/l
                dw      BBUF, MUL_DIV_MOD       // */mod
                dw      R_TO                    // r>
                dw      BSCR, MUL, PLUS         // b/scr * +
                dw      BLOCK                   // block   ( forward )
                dw      PLUS                    // +
                dw      NOOP                    // noop
                dw      CL                      // c/l
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// .line        n1 n2 --
// Sends to output line  n1  of screen n2.
                Colon_Def DOT_LINE, ".LINE", is_normal
                dw      CLINE, LTRAILING, TYPE  // (line) -trailing type 
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// message       n1 n2 --
// prints error message to current channel.
// if WARNING is 0, prints "MSG#n".
// if WARNING is 1, prints line n of screen 4.
// if WARNING is -1, see ERROR
// value can be negative or beyond block 4.
                Colon_Def MESSAGE, "MESSAGE", is_normal
                dw      WARNING, FETCH          // warning @
                                                // if
                dw      ZBRANCH
                dw      Message_Else - $
                dw          LIT, 4              //      4
                dw          OFFSET, FETCH       //      offset @
                dw          BSCR, DIV, SUBTRACT //      b/scr / -
                dw          DOT_LINE            //      .line
                dw          SPACE               //      space
                                                // else

                dw      BRANCH
                dw      Message_ENdif - $
Message_Else:
                dw          C_DOT_QUOTE         //      .( msg#)    
                db          4, "msg#"                
                dw          DOT                 //      .  ( forward )
Message_ENdif:                                  // endif                
                dw      EXIT                    // ;


//  ______________________________________________________________________ 
//
// device
                Variable_Def DEVICE,   "DEVICE",   2

//  ______________________________________________________________________ 
