//  ______________________________________________________________________ 
//
//  L3.asm
// 
//  Continuation of L2.asm
//  I/O Block definitions
//  ______________________________________________________________________ 


//  ______________________________________________________________________ 
//
// r/w          a n f --
// read/write block n depending on flag f, true-flag means read, false-flag means write.
                Colon_Def READ_WRITE, "R/W", is_normal
                dw      TO_R                    // >r    
                dw      ONE_SUBTRACT            // 1-
                dw      DUP, ZLESS              // dup 0<
                dw      OVER, NSEC              // over #sec
                dw      ONE_SUBTRACT, GREATER   // 1- >
                dw      OR_OP                   // or
                dw      LIT, 6, QERROR          // 6 ?error
                dw      R_TO                    // r>
                                                // if
                dw      ZBRANCH
                dw      Read_Write_Else - $           
                dw          BLK_READ            //      blk-read
                dw      BRANCH
                dw      Read_Write_Endif - $
Read_Write_Else:                                // else                                                     
                dw          BLK_WRITE           //      blk-write
Read_Write_Endif:                               // endif
                dw      EXIT                    // ;


//  ______________________________________________________________________ 
//
// +buf        a1 -- a2 f
// advences to next buffer, cyclically rotating along them
                Colon_Def PBUF, "+BUF", is_normal
                dw      LIT, 516, PLUS          // 516 +
                dw      DUP, LIMIT, FETCH       // dup limit @
                dw      EQUALS                  // =
                                                // if
                dw      ZBRANCH
                dw      PBuf_Endif - $
                dw          DROP                //      drop
                dw          FIRST, FETCH        //      first @    
PBuf_Endif:                                     // endif
                dw      DUP, PREV, FETCH        // dup prev @                    
                dw      SUBTRACT                // -
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// update       --
// mark the last used block to be written to disk
                Colon_Def UPDATE, "UPDATE", is_normal
                dw      PREV, FETCH, FETCH      // prev @ @
                dw      LIT, $8000, OR_OP       // $8000, or
                dw      PREV, FETCH, STORE      // prev @ !
                dw      EXIT                    // ;


//  ______________________________________________________________________ 
//
// empty-buffers --
                Colon_Def EMPTY_BUFFERS, "EMPTY-BUFFERS", is_normal
                dw      FIRST, FETCH            // first @
                dw      LIMIT, FETCH            // limit @
                dw      OVER, SUBTRACT, ERASE   // over - erase
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// buffer       n -- a
// read block n and gives the address to a buffer 
// any block previously inside the buffer, if modified, is rewritten to
// disk before reading the block n.

                Colon_Def BUFFER, "BUFFER", is_normal
                dw      USED, FETCH             // used @
                dw      DUP, TO_R               // dup >r
                                                // begin
Buffer_Begin:                                                
                dw          PBUF                //      +buf
                                                // until
                dw      ZBRANCH
                dw      Buffer_Begin - $
                dw      USED, STORE             // used !
                dw      R_OP, FETCH, ZLESS      // r @ 0<
                                                // if
                dw      ZBRANCH
                dw      Buffer_Endif - $
                dw          R_OP, CELL_PLUS     //      r cell+
                dw          R_OP, FETCH         //      r fetch
                dw          LIT, $7FFF          //      7FFF
                dw          AND_OP              //      and
                dw          ZERO, READ_WRITE    //      0 r/w
Buffer_Endif:                                   // endif
                dw      R_OP, STORE             // r !
                dw      R_OP, PREV, STORE       // r prev !
                dw      R_TO, CELL_PLUS         // r> cell+
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// block        n -- a
// Leaves the buffer address that contains the block n. 
// If the block is not already present, it will be loaded from disk
// The block previously inside the buffer, if modified, is rewritten to
// disk before reading the block n.
// See also BUFFER, R/W, UPDATE, FLUSH.

                Colon_Def BLOCK, "BLOCK", is_normal
            //  dw      OFFSET, FETCH           // offset @
            //  dw      PLUS
                dw      TO_R                    // + >r
                dw      PREV, FETCH             // prev @
                dw      DUP, FETCH              // dup @
                dw      R_OP, SUBTRACT          // r -
                dw      DUP, PLUS               // dup +  ( trick: check equality without most significant bit )
                                                // if
                dw        ZBRANCH
                dw        Block_Endif_1 - $
Block_Begin:                                    //      begin
                dw          PBUF, ZEQUAL        //          +buf 0
                                                //          if
                dw          ZBRANCH
                dw          Block_Endif_2 - $
                dw              DROP            //              drop
                dw              R_OP, BUFFER    //              r buffer
                dw              DUP             //              dup
                dw              R_OP, ONE       //              r 1
                dw              READ_WRITE      //              r/w
                dw              TWO_MINUS       //              2-
Block_Endif_2:                                  //          endif
                dw          DUP, FETCH, R_OP    //          dup @ r
                dw          SUBTRACT, DUP       //          - dup
                dw          PLUS, ZEQUAL        //          + 0=
                                                //      until
                dw        ZBRANCH
                dw        Block_Begin - $
                dw        DUP, PREV, STORE      //      dup prev !
Block_Endif_1:                                  // endif
                dw      R_TO, DROP, CELL_PLUS   // r> drop cell+
                dw      EXIT                    // ;
              
//  ______________________________________________________________________ 
//
// #buff        -- n
// number of buffers available. must be the difference between LIMIT and FIRST divided by 516
                Constant_Def NBUFF,   "#BUFF", BUFFERS

//  ______________________________________________________________________ 
//
// flush        --
                Colon_Def FLUSH, "FLUSH", is_normal
                dw      NBUFF, ONE_PLUS, ZERO   // #buff 1+ 0   
Flush_Do:                                       // do
                dw      C_DO
                dw      ZERO, BUFFER, DROP      //      0 buffer drop
                                                // loop
                dw      C_LOOP, Flush_Do - $
                dw      BLK_FH, FETCH           // blk-fh @     ( ZX-Next dependance )    
                dw      F_SYNC, DROP            // f_sync drop
                dw      EXIT                    // exit

//  ______________________________________________________________________ 
//
// f_getline    a m fh -- n
// Given an open filehandle read next line (terminated with $0D or $0A)
// Address a is left for subsequent processing
// and n as the actual number of byte read, that is the length of line 
                Colon_Def F_GETLINE, "F_GETLINE", is_normal
                dw      TO_R                    // >r               ( a  m  )     \  fh
                dw      TUCK                    // tuck             ( m a m )
                dw      R_OP, F_FGETPOS         // r f_fgetpos      ( m a m d f ) 
                dw      LIT, 35, QERROR         // 44 ?error        ( m a m d )     
                
                dw      TWO_SWAP, OVER          // 2swap over       ( m d a m )
                dw      ONE_PLUS, SWAP          // 1+ swap          ( m d a a+1 m )

                dw      R_OP, F_READ            // r f_read         ( m d a n f ) 
                dw      LIT, 35, QERROR         // 46 ?error        ( m d a n )  
                                                // if ( at least 1 chr was read )  \  fh
                dw      ZBRANCH
                dw      FGetline_Else - $
                dw          LIT, 10, ENCLOSE    //      10 enclose       ( m d a x b x )
                dw          DROP, NIP           //      drop nip         ( m d a b )
                dw          SWAP                //      drop swap        ( m d b a )
                dw          LIT, 13, ENCLOSE    //      13 enclose       ( m d b a x c x )
                dw          DROP, NIP           //      drop nip         ( m d b a c )
                dw          ROT, MIN            //      rot min          ( m d a n )
                dw          DUP, SPAN, STORE    //      dup span !       ( m d a n )
                dw          DUP, TO_R           //      dup >r           ( m d a n )      \ fh n
                dw          TWO_SWAP, R_TO      //      2swap r>         ( m a n d n )    \ fh
                dw          ZERO, DPLUS         //      0 d+             ( m a n d+n )
                dw          R_TO, F_SEEK        //      r> f_seek        ( m a n f )    
                dw          LIT, 36, QERROR     //      45 ?error        ( m a n )
                                                // else                
                dw      BRANCH
                dw      FGetline_Endif - $
FGetline_Else:
                dw          R_TO                //      r>              ( m d a fh ) 
                dw          TWO_SWAP, TWO_DROP  //      2swap 2drop     ( m a fh )
                dw          DROP, ZERO          //      drop, 0         ( m a 0 )
FGetline_Endif:                                 // endif
                dw      TO_R, DUP, DUP          // >r dup dup           ( m a a a )
                dw      ONE_PLUS, SWAP          // 1+ swap              ( m a a+1 a )
                dw      R_OP, CMOVE             // r cmove              ( m a )
                dw      TWO_DUP, PLUS           // 2dup +               ( m a m+a )
                dw      ZERO, SWAP              // 0 swap
                dw      CELL_MINUS,  STORE      // cell-  !             ( m a )
                dw      R_OP, PLUS, ONE_SUBTRACT// r + 1-               ( m a+n1 )
                dw      SWAP, R_OP, SUBTRACT    // swap r -             ( a+n+1 m-n )           
                dw      BLANK                   // blank 
                dw      R_TO                    // r>                   ( n )
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// f_include    fh --
// Given a filehandle includes the source from file
                Colon_Def F_INCLUDE, "F_INCLUDE", is_normal
                dw      BLK, FETCH, TO_R        // blk @ >r
                dw      TO_IN, FETCH, TO_R      // >in @ >r
                dw      SOURCE_ID, FETCH, TO_R  // source-id @ >r
                dw      R_OP                    // r
                dw      ZGREATER                // 0>  (filehandle)
                                                // if
                dw      ZBRANCH
                dw      FInclude_Else_1 - $
                dw          R_OP, F_FGETPOS     //      r f_getpos
                dw          LIT, 44, QERROR     //      44 ?error
                dw          TO_IN, FETCH        //      >in @ 2-
                dw          TWO_MINUS           
                dw          SPAN, FETCH         //      span @ -
                dw          SUBTRACT 
                dw          S_TO_D, DPLUS       //      s>d d+
                                                // else
                dw      BRANCH
                dw      FInclude_Endif_1 - $    
FInclude_Else_1:
                dw          ZERO, ZERO          //      0 0
                                                // endif
FInclude_Endif_1:                                                                                            
                dw      TO_R, TO_R              // >r >r
                dw      SOURCE_ID, STORE        // source-id !
FInclude_Begin:                                 // begin
                dw          ONE, BLOCK, BBUF    //      1 block b/buf
                dw          TWO_DUP, BLANK      //      2dup blank 
                dw          SWAP, ONE_PLUS      //      swap 1+
                dw          SWAP, CELL_MINUS    //      swap cell-
                dw          SOURCE_ID, FETCH    //      source-id @
                dw          F_GETLINE           //      f_getline
                                                // while
                dw      ZBRANCH
                dw      FInclude_Repeat - $  
                dw          ONE, BLK, STORE     //      1 blk !
                dw          ZERO, TO_IN, STORE  //      0 >in !    
                dw          INTERPRET           //      interpret
                dw      BRANCH
                dw      FInclude_Begin - $
FInclude_Repeat:                                // repeat
                //  close current file
                dw      SOURCE_ID, FETCH        // source-id @
                dw      F_CLOSE                 // f_close
                dw      LIT, 42, QERROR         // 42 ?error

                dw      R_TO, R_TO, R_TO        // r> r> r>
                dw      DUP, SOURCE_ID, STORE   // dup source-id !
                dw      ZGREATER                // 0>
                                                // if
                dw      ZBRANCH
                dw      FInclude_Else_2 - $
                dw          SOURCE_ID, FETCH    //      source-id @
                dw          F_SEEK              //      f_seek
                dw          LIT, 43, QERROR     //      43, ?error
                                                // else
                dw      BRANCH
                dw      FInclude_Endif_2 - $
FInclude_Else_2:
                dw          TWO_DROP            //      2drop
FInclude_Endif_2:                               // endif
                dw      R_TO, TO_IN, STORE      // r> >in !
                dw      R_TO, BLK, STORE        // r> blk !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// open<         -- fh
// Open the following filename and return it file-handle
// Used in the form OPEN CCCC
                Colon_Def OPEN_FH, "OPEN<", is_normal
                dw      BL
                dw      WORD, COUNT, OVER       // bl word count over
                dw      PLUS, ZERO, SWAP, STORE // + 0 swap !
                dw      PAD, ONE, F_OPEN        // pad 1 f_open
                dw      LIT, 43                 // 43
                dw      QERROR                  // ?error
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// use          -- cccc
// Include the following filename
//              Colon_Def USE, "USE", is_normal
//              dw      OPEN_FH                 // open<
//              dw      BLK_FH, FETCH           // blk-fh @
//              dw      F_CLOSE, DROP           // f_close drop
//              dw      BLK_FH, STORE           // blk-fh !
//              dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// include      -- cccc
// Include the following filename
                Colon_Def INCLUDE, "INCLUDE", is_normal
                dw      OPEN_FH                 // open<
                dw      F_INCLUDE               //  f_include
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// needs
// check for cccc exists in vocabulary
// if it doesn't then  INCLUDE  inc/cccc.F

// temp filename cccc.f as counted string zero-padded
                New_Def NEEDS_W,   "NEEDS-W", Create_Ptr, is_normal  
                ds      35                      // 32 + .f + 0x00 = len 35
// temp complete path+filename
                New_Def NEEDS_FN,  "NEEDS-FN", Create_Ptr, is_normal  
                ds      40
// constant path
                New_Def NEEDS_INC,  "NEEDS-INC", Create_Ptr, is_normal  
                db      4, "inc/", 0
                New_Def NEEDS_LIB,  "NEEDS-LIB", Create_Ptr, is_normal  
                db      4, "lib/", 0

// Concatenate path at a and filename and include it
// No error is issued if filename doesn't exist.
                Colon_Def NEEDS_SLASH, "NEEDS/", is_normal
                dw      COUNT, TUCK             // n a n
                dw      NEEDS_FN, SWAP, CMOVE   // n        \ Path
                dw      NEEDS_FN, PLUS          // a1+n     \ Concat
                dw      NEEDS_W, ONE_PLUS, SWAP 
                dw      LIT, 35
                dw      CMOVE
                dw      NEEDS_FN
                dw      PAD, ONE, F_OPEN
                dw      ZEQUAL
                dw      ZBRANCH
                dw      Needs_1 - $
                dw          F_INCLUDE
                dw      BRANCH
                dw      Needs_2 - $
Needs_1:
//              dw          NEEDS_W, COUNT, TYPE, SPACE
//              dw          LIT, 43, MESSAGE
                dw          DROP
Needs_2:
                dw      EXIT                    // ;

NDOM_PTR:
//              New_Def NDOM,   "NDOM", Create_Ptr, is_normal  
//              db $3A, $3F, $2F, $2A, $7C, $5C, $3C, $3E, $22
                db ':?/*|\<>"'
//              db 0

NCDM_PTR:
//              New_Def NCDM,   "NCDM", Create_Ptr, is_normal  
//              db $5F, $5E, $25, $26, $24, $5F, $7B, $7D, $7E
                db '_^%&$_{}~' 
//              db 0

// Replace illegal character in filename using the map here above
// at the moment we need only  "
                Colon_Def NEEDS_CHECK, "MAP-FN", is_normal
                dw      COUNT, BOUNDS
                dw      C_DO
Needs_3:
//              dw          NCDM, NDOM, LIT, 10
                dw          LIT, NCDM_PTR           //                
                dw          LIT, NDOM_PTR           //                
                dw          LIT, 9
                dw          I, CFETCH
                dw          C_MAP
                dw          I, CSTORE
Needs_4:
                dw      C_LOOP    
                dw      Needs_3 - $
                dw      EXIT


// include  "path/cccc.f" if cccc is not defined
// filename cccc.f is temporary stored at NEEDS-W
                Colon_Def NEEDS_PATH, "NEEDS-F", is_normal
                dw      LFIND
                dw      ZBRANCH
                dw      Needs_5 - $

                dw          DROP, TWO_DROP
                dw      BRANCH
                dw      Needs_6 - $
Needs_5:                
                dw          NEEDS_W
                dw          LIT, 35
                dw          ERASE                   // a
                dw          HERE, CFETCH, ONE_PLUS  // a n
                dw          HERE, OVER              // a n here n
                dw          NEEDS_W, SWAP, CMOVE    // a n
                dw          NEEDS_W, NEEDS_CHECK
                dw          NEEDS_W, PLUS           // a a1+1
                dw          LIT, $662E              // a a1+1 ".F"
                dw          SWAP, STORE             // a
                dw          NEEDS_SLASH         
Needs_6:
                dw      EXIT


// check for cccc exists in vocabulary
// if it doesn't then  INCLUDE  inc/cccc.F
// search in inc subdirectory
                Colon_Def NEEDS, "NEEDS", is_normal
                dw      TO_IN, FETCH
                dw      DUP
                dw      NEEDS_INC, NEEDS_PATH
                dw      TO_IN, STORE
                dw      NEEDS_LIB, NEEDS_PATH
                dw      TO_IN, STORE
                dw      LFIND
                dw      ZBRANCH
                dw      Needs_10 - $
                dw          TWO_DROP
                dw      BRANCH
                dw      Needs_11 - $
Needs_10:   
                dw      NEEDS_W, COUNT, TYPE, SPACE
                dw      LIT, 43, MESSAGE
Needs_11:                                
                dw      EXIT


//  ______________________________________________________________________ 
//
// load         n --
                Colon_Def LOAD, "LOAD", is_normal
                dw      BLK, FETCH, TO_R        // blk @ >r
                dw      TO_IN, FETCH, TO_R      // >in @ >r

                dw      ZERO, TO_IN, STORE      // 0 >in !
                dw      BSCR, MUL, BLK, STORE   // b/scr * blk !
                dw      INTERPRET               // interpret

                dw      R_TO, TO_IN, STORE      // r> >in !
                dw      R_TO, BLK, STORE        // r> blk !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// -->          --
                Colon_Def LOAD_NEXT, "-->", is_immediate
                dw      QLOADING                // ?loading
                dw      ZERO, TO_IN, STORE      // 0 >in !
                dw      BSCR                    // b/scr
                dw      BLK, FETCH              // blk @
                dw      OVER                    // over
                dw      MOD                     // mod
                dw      SUBTRACT                // -
                dw      BLK, PLUSSTORE          // +!
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// '            -- xt
                Colon_Def TICK, "'", is_normal
                dw      LFIND                   // -find
                dw      ZEQUAL                  // 0=
                dw      ZERO, QERROR            // 0 ?error
                dw      DROP                    // drop
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// forget       -- cccc
                Colon_Def FORGET, "FORGET", is_normal
                dw      CURRENT, FETCH          // current @
                dw      CONTEXT, FETCH          // context @
                dw      SUBTRACT, LIT, 23, QERROR // - 23 ?error
                dw      TICK, TO_BODY           // ' >body
                dw      DUP, FENCE, FETCH       // dup fence @ 
                dw      ULESS, LIT, 21, QERROR  // u< 21 ?error
                dw      DUP, NFA                // dup nfa 
                
            //  dw      DUP
            //  dw      LIT, $E000, LESS
            //  dw      MMU7_FETCH, ONE, EQUALS
            //  dw      OR_OP, NOT_OP
            //  dw      ZBRANCH
            //  dw      Forget_then - $

                dw      MMU7_FETCH, FROM_FAR
                dw      HP, STORE
                dw      DUP, CFA, CELL_MINUS
// Forget_then:    
                dw      DP, STORE               // dp !
                dw      LFA, FETCH              // lfa @
                dw      CONTEXT, FETCH, STORE   // context @ !
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// marker       -- cccc
                Colon_Def MARKER, "MARKER", is_immediate
                dw      CREATE

                dw      VOC_LINK, FETCH, COMMA
                dw      CURRENT, FETCH, COMMA
                dw      CONTEXT, FETCH, COMMA
                dw      CURRENT, FETCH, FETCH,  COMMA
                dw      LATEST, PFA, LFA, FETCH, COMMA
                
                dw      C_DOES

          //    nop
                call    Enter_Ptr                
                
                dw      DUP, FETCH, VOC_LINK, STORE, CELL_PLUS
                dw      DUP, FETCH, CURRENT, STORE, CELL_PLUS
                dw      DUP, FETCH, CONTEXT, STORE, CELL_PLUS
                dw      DUP, FETCH
            //  dw      DUP, QHEAPP
            //  dw      ZBRANCH
            //  dw      Marker_then - $
                dw          DUP, HP, STORE
                dw          PFA, CFA, CELL_MINUS
// Marker_then:
                dw      DP, STORE, CELL_PLUS
                dw      FETCH, CURRENT, FETCH, STORE
                dw      EXIT

//  ______________________________________________________________________ 
//
// spaces       n --
                Colon_Def SPACES, "SPACES", is_normal
                dw      ZERO, MAX
                dw      ZERO, C_Q_DO
                dw      Spaces_Leave - $
Spaces_Loop:                
                dw          SPACE
                dw      C_LOOP
                dw      Spaces_Loop - $
Spaces_Leave:                
                dw      EXIT                    // ;

//  ______________________________________________________________________ 
//
// <#           --
                Colon_Def BEGIN_DASH, "<#", is_normal
                dw      PAD, HLD, STORE
                dw      EXIT

//  ______________________________________________________________________ 
//
// #>           --
                Colon_Def DASH_END, "#>", is_normal
                dw      TWO_DROP
                dw      HLD, FETCH, PAD, OVER, SUBTRACT
                dw      EXIT

//  ______________________________________________________________________ 
//
// sign         n d -- d
                Colon_Def SIGN, "SIGN", is_normal
                dw      ZLESS
                dw      ZBRANCH
                dw      Sign_Endif - $
                dw          LIT, 45, HOLD
Sign_Endif:     
                dw      EXIT

//  ______________________________________________________________________ 
//
// #           d1 -- d2
                Colon_Def DASH, "#", is_normal
                dw      BASE, FETCH

                dw      TO_R                    // >r           ( ud1 )
                dw      ZERO, R_OP, UMDIVMOD    // 0 r um/mod   ( l rem1 h/r )            
                dw      R_TO, SWAP, TO_R        // r> swap >r   ( l rem )
                dw      UMDIVMOD                // um/mod       ( rem2 l/r )
                dw      R_TO                    // r>           ( rem2 l/r h/r )

                dw      ROT
                dw      LIT, 9, OVER, LESS
                dw      ZBRANCH
                dw      Dash_Endif - $
                dw          LIT, 7, PLUS
Dash_Endif:     

                dw      LIT, 48, PLUS, HOLD
                dw      EXIT

//  ______________________________________________________________________ 
//
// #s           d1 -- d2
                Colon_Def DASHES, "#S", is_normal
Dashes_Begin:                   
                dw      DASH, TWO_DUP
                dw          OR_OP, ZEQUAL
                dw      ZBRANCH
                dw      Dashes_Begin - $
                dw      EXIT

//  ______________________________________________________________________ 
//
// d.r          d n --
                Colon_Def D_DOT_R, "D.R", is_normal
                dw      TO_R
                dw      TUCK, DABS
                dw      BEGIN_DASH, DASHES, ROT, SIGN, DASH_END
                dw      R_TO
                dw      OVER, SUBTRACT, SPACES, TYPE
                dw      EXIT

//  ______________________________________________________________________ 
//
// .r           n1 n2 --
                Colon_Def DOT_R, ".R", is_normal
                dw      TO_R
                dw      S_TO_D, R_TO
                dw      D_DOT_R
                dw      EXIT

//  ______________________________________________________________________ 
//
// d.           d --
                Colon_Def D_DOT, "D.", is_normal
                dw      ZERO, D_DOT_R, SPACE
                dw      EXIT

//  ______________________________________________________________________ 
//
// .            n --
                Colon_Def DOT, ".", is_normal
                dw      S_TO_D, D_DOT
                dw      EXIT

//  ______________________________________________________________________ 
//
// ?            n --
                Colon_Def QUESTION, "?", is_normal
                dw      FETCH, DOT
                dw      EXIT

//  ______________________________________________________________________ 
//
// u.           u --
                Colon_Def U_DOT, "U.", is_normal
                dw      ZERO, D_DOT
                dw      EXIT

//  ______________________________________________________________________ 
//
// words        --
                Colon_Def WORDS, "WORDS", is_normal
                dw      LIT, 128, OUT, STORE
                dw      CONTEXT, FETCH, FETCH
Words_Begin:        
                dw          FAR // Q TO HEAP
                dw          DUP, CFETCH, LIT, $1F, AND_OP
                dw          OUT, FETCH, PLUS
                dw          CL, LESS, ZEQUAL
                dw          ZBRANCH
                dw          Words_Endif - $
                dw              CR, ZERO, OUT, STORE
Words_Endif:    
                dw          DUP, ID_DOT
                dw          ONE, TRAVERSE, ONE_PLUS, FETCH
                dw          DUP, ZEQUAL
                dw          QTERMINAL, OR_OP
                dw      ZBRANCH
                dw      Words_Begin - $
                dw      DROP
                dw      EXIT

//  ______________________________________________________________________ 
//
// list         n --
                Colon_Def LIST, "LIST", is_normal
                dw      DECIMAL, CR
                dw      DUP, SCR, STORE
                dw      C_DOT_QUOTE
                db      5, "Scr# "
                dw      DOT
                dw      LSCR, ZERO, C_DO
List_Loop:
                dw          CR
                dw          I, THREE
                dw          DOT_R, SPACE
                dw          I, SCR, FETCH, DOT_LINE
                dw          QTERMINAL
                dw          ZBRANCH
                dw          List_Endif - $
                dw              C_LEAVE
                dw              List_Leave - $
List_Endif:
                dw      C_LOOP
                dw      List_Loop - $     
List_Leave:
                dw      CR           
                dw      EXIT

//  ______________________________________________________________________ 
//
// index        n1 n2 --
                Colon_Def INDEX, "INDEX", is_normal
                dw      ONE_PLUS, SWAP, C_DO
Index_Loop:                
                dw          CR, I, THREE
                dw          DOT_R, SPACE
                dw          ZERO, I, DOT_LINE
                dw          QTERMINAL
                dw          ZBRANCH
                dw          Index_Endif - $
                dw              C_LEAVE
                dw              Index_Leave - $
Index_Endif:
                dw      C_LOOP
                dw      Index_Loop - $
Index_Leave:
                dw      CR
                dw      EXIT

//  ______________________________________________________________________ 
//
// cls          --
                Colon_Def CLS, "CLS", is_normal
                dw      CCLS
                dw      EXIT


//  ______________________________________________________________________ 
//
// splash       --
//              Colon_Def SPLASH, "SPLASH", is_normal
//              dw      CLS
//              dw      C_DOT_QUOTE
//              db      87
//              db      "v-Forth 1.8 NextZXOS version", 13    // 29
//              db      "Heap Vocabulary - build 20250719", 13  // 33
//              db      "1990-2025 Matteo Vitturi", 13        // 25
//              dw      EXIT

//  ______________________________________________________________________ 
//
// splash       --
                Colon_Def SPLASH, "SPLASH", is_normal
                dw      CLS
                dw      LIT, Splash_Ptr
                dw      FAR
                dw      COUNT, TYPE
                dw      EXIT

//  ______________________________________________________________________ 
//
// video        --
                Colon_Def VIDEO, "VIDEO", is_normal
                dw      TWO, DUP, DEVICE, STORE
                dw      SELECT
                dw      EXIT

//  ______________________________________________________________________ 
//
// autoexec     --
// this word is called the first time the Forth system boot to
// load Screen# 1. Once called it patches itself to prevent furhter runs.
                Colon_Def AUTOEXEC, "AUTOEXEC", is_normal
Autoexec_Self:                
                dw      LIT, NOOP
                dw      LIT, Autoexec_Ptr
                dw      STORE
                dw      LIT, Param_From_Basic
                dw      PAD, ONE
                dw      F_OPEN
                dw      DROP    
                dw      F_INCLUDE
                dw      EXIT


//              dw      LIT, 11
//              dw      LIT, NOOP
//              dw      LIT, Autoexec_Ptr
//              dw      STORE
//              dw      LOAD
//
//              dw      NEEDS_FN, ONE, F_OPEN
//              dw      LIT, 43, QERROR
//              dw      DUP, F_INCLUDE
//              dw      F_CLOSE, DROP

//              dw      QUIT
//              dw      EXIT
                

//  ______________________________________________________________________ 
//
// bye     --
//
                Colon_Def BYE, "BYE", is_normal
                dw      FLUSH
                dw      EMPTY_BUFFERS
                dw      BLK_FH, FETCH, F_CLOSE, DROP
                dw      ZERO, PLUS_ORIGIN
                dw      BASIC
                
//  ______________________________________________________________________ 
//
// invv     --
//
//              Colon_Def INVV, "INVV", is_normal
//              dw      LIT, 20, EMITC, ONE, EMITC
//              dw      EXIT

//  ______________________________________________________________________ 
//
// truv     --
//
//              Colon_Def TRUV, "TRUV", is_normal
//              dw      LIT, 20, EMITC, ZERO, EMITC
//              dw      EXIT

//  ______________________________________________________________________ 
//
// mark     --
//
//              Colon_Def MARK, "MARK", is_normal
//              dw      INVV, TYPE, TRUV
//              dw      EXIT

//  ______________________________________________________________________ 
//
// back     --
//
                Colon_Def BACK, "BACK", is_normal
                dw      HERE, SUBTRACT, COMMA
                dw      EXIT

//  ______________________________________________________________________ 
//
// if          ( -- a 2 ) \ compile-time 
// IF ... THEN 
// IF ... ELSE ... ENDIF 
                Colon_Def IF, "IF", is_immediate
                dw      COMPILE, ZBRANCH
                dw      HERE, ZERO, COMMA
                dw      TWO
                dw      EXIT

//  ______________________________________________________________________ 
//
// then        ( a 2 -- ) \ compile-time
//
                Colon_Def THEN, "THEN", is_immediate
                dw      QCOMP
                dw      TWO, QPAIRS
                dw      HERE, OVER, SUBTRACT, SWAP, STORE
                dw      EXIT

//  ______________________________________________________________________ 
//
// endif       ( a 2 -- ) \ compile-time
//
                Colon_Def ENDIF, "ENDIF", is_immediate
                dw      THEN
                dw      EXIT

//  ______________________________________________________________________ 
//
// else        ( a1 2 -- a2 2 ) \ compile-time 
//
                Colon_Def ELSE, "ELSE", is_immediate
                dw      QCOMP
                dw      TWO, QPAIRS
                dw      COMPILE, BRANCH
                dw      HERE, ZERO, COMMA
                dw      SWAP, TWO, THEN
                dw      TWO
                dw      EXIT

//  ______________________________________________________________________ 
//
// begin        ( -- a 1 ) \ compile-time
// BEGIN ... AGAIN
// BEGIN ... f UNTIL
// BEGIN ... f WHILE ... REPEAT
                Colon_Def BEGIN, "BEGIN", is_immediate
                dw      QCOMP
                dw      HERE
                dw      TWO
                dw      EXIT

//  ______________________________________________________________________ 
//
// again        ( a 1 -- ) \ compile-time
                Colon_Def AGAIN, "AGAIN", is_immediate
                dw      QCOMP
                dw      TWO, QPAIRS
                dw      COMPILE, BRANCH
                dw      BACK
                dw      EXIT

//  ______________________________________________________________________ 
//
// until        ( a 1 -- ) \ compile-time
                Colon_Def UNTIL, "UNTIL", is_immediate
                dw      QCOMP
                dw      TWO, QPAIRS
                dw      COMPILE, ZBRANCH
                dw      BACK
                dw      EXIT

//  ______________________________________________________________________ 
//
// end          ( a 1 -- ) \ compile-time
                Colon_Def END, "END", is_immediate
                dw      UNTIL
                dw      EXIT

//  ______________________________________________________________________ 
//
// while        ( a1 1 -- a1 1 a2 4 ) \ compile-time
                Colon_Def WHILE, "WHILE", is_immediate
                dw      IF
//              dw      TWO_PLUS // ( that is 4 )
                dw      TWO_SWAP
                dw      EXIT

//  ______________________________________________________________________ 
//
// repeat       ( a1 1 a2 4 -- ) \ compile-time
                Colon_Def REPEAT, "REPEAT", is_immediate
                dw      AGAIN
//              dw      TWO_MINUS
                dw      THEN
                dw      EXIT

//  ______________________________________________________________________ 
//
// ?do-
// special version of "BACK" used by ?DO and LOOP
                Colon_Def C_DO_BACK, "?DO-", is_normal
                dw      BACK
CDoBack_Begin:                
                dw      SPFETCH, CSP, FETCH, SUBTRACT
                dw      ZBRANCH
                dw      CDoBack_While - $
                dw          TWO_PLUS, THEN
                dw      BRANCH
                dw      CDoBack_Begin - $
CDoBack_While:  
                dw      QCSP, CSP, STORE
                dw      EXIT

//  ______________________________________________________________________ 
//
// do
// DO  ... LOOP
// DO  ... n +LOOP
// ?DO ... LOOP
// ?DO ... n +LOOP
                Colon_Def DO, "DO", is_immediate
                dw      COMPILE, C_DO
                dw      CSP, FETCH, STORE_CSP
                dw      HERE, THREE
                dw      EXIT

//  ______________________________________________________________________ 
//
// loop
                Colon_Def LOOP, "LOOP", is_immediate
                dw      THREE, QPAIRS
                dw      COMPILE, C_LOOP
                dw      C_DO_BACK
                dw      EXIT

//  ______________________________________________________________________ 
//
// +loop
                Colon_Def PLOOP, "+LOOP", is_immediate
                dw      THREE, QPAIRS
                dw      COMPILE, C_PLOOP
                dw      C_DO_BACK
                dw      EXIT

//  ______________________________________________________________________ 
//
// ?do
                Colon_Def QDO, "?DO", is_immediate
                dw      COMPILE, C_Q_DO
                dw      CSP, FETCH, STORE_CSP
                dw      HERE, ZERO, COMMA, ZERO
                dw      HERE, THREE
                dw      EXIT

//  ______________________________________________________________________ 
//
// \
                Colon_Def BACKSLASH, "\\", is_immediate  // this is a single back-slash
                dw      BLK, FETCH
                dw      ONE_SUBTRACT // BLOCK 1 is used as temp-line in INCLUDE file
                dw      ZBRANCH
                dw      Backslash_Else_1 - $

                dw          BLK, FETCH
                dw          ZBRANCH
                dw          Backslash_Else_2 - $

                dw              TO_IN, FETCH, CL, ONE_SUBTRACT, AND_OP, CL
                dw              SWAP, SUBTRACT, TO_IN, PLUSSTORE
                dw          BRANCH
                dw          Backslash_Endif_2 - $
Backslash_Else_2:
                dw              ZERO, TIB, FETCH, TO_IN, FETCH, PLUS, CSTORE
Backslash_Endif_2:
                dw      BRANCH
                dw      Backslash_Endif_1 - $
Backslash_Else_1:
                dw              BBUF, CELL_MINUS, TO_IN, STORE
Backslash_Endif_1:
                dw      EXIT

//  ______________________________________________________________________ 
//
// blk-fh
                Variable_Def BLK_FH,   "BLK-FH",   1

                New_Def BLK_FNAME,   "BLK-FNAME", Create_Ptr, is_normal  
Len_Filename:   db      14   // length of the following string, excluding 0x00 
Blk_filename:   db      "!Blocks-64.bin", 0
Param_From_Basic:  
                db      "lib/autoexec.f", 0

Fence_Word:
//  ______________________________________________________________________ 
//

Here_Dictionary db      0
