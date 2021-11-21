\ z80n-asm.f
\ 
\ CR
.( Zilog Z80 ) CR
.( also Z80N Next extensions are available ) CR
\ 
\ This is a tentative Z80 adaptation of Albert van der Horst's work available 
\ at  <https://github.com/albertvanderhorst/ciasdis>
\ In particular I carefully studied the two Forth sources  as80.frt   
\ and   asgen.frt  to get some clue to port his work to be effective within 
\ a "vintage" Sinclair ZX Spectrum system with a ZX-Microdrive.
\ As far I can see, I used an older version than these above.
\ You can recognize  asgen.frt   in screens between 100 and 119
\ and   as80.frt   in screens from 120.
\
\ The TASK involved here is the modification of an 8080 assembler to become 
\ a Z80 assembler and since my first purpose was to build an "assembler" 
\ I deliberately ignored the "dis-assembler" part.
\ And with the aim of reducing the overall size I also omit wide part of it.
\
\ Here follows the edited dump of Microdrive blocks 100-170 where i stored 
\ the source of Z80 ASSEMBLER VOCABULARY.
\
\ First, I had to introduce some new "xFAMILY," creative words 
\    CBFAMILY,  for CB prefixed  opcodes (shift, rotation and bit manipulation)
\    EDFAMILY,  for ED prefixed  
\    DDFAMILY,  for IX index register specialized opcodes
\    FDFAMILY,  for IY index register specialized opcodes
\ Second, I modified the COMMAER names to became   
\    N,         for immediate single byte value
\    NN,        for immediate word value
\    AA,        for memory address value
\    P,         for port addres value (16 bits)
\    D,         for displacement in relative jump JR.
\
\ Next, I renamed some single byte op-code to port 8080 notation to a proper 
\ "near-Z80" notation.
\ To avoid some Forth-Assembler name clash I had to use some peculiar notation 
\ for some op-codes,  
\ for example   EXAFAF      EX(SP)HL     EXDEHL  
\ instead of    EX AF, AF'  EX (SP),HL   EX DE,HL
\
\ Also, I had to explicitly say A for all arithmetic/logic opcodes, 
\ e.g.  ADDA... instead of ADD A, and so on. This was not strictly necessary
\ but in the beginning I preferred to avoid any word duplication.
\ IX and IY index-register caused the most trouble because they add both a
\ prefix and a displacement (but not in all cases), and because they can be
\ used in conjunction with CB prefix. In this case I use some custom
\ late-compilation word to fix everything but relaxing some of the syntax
\ check that the Albert's core provided.
\ 
\ Z80N extensions are all ED-prefixed, so I followed the same path
\ introducing some new COMMAER to enforce a better syntax check.
\    REG,       used by NEXTREG and NEXTREGA 
\    LH,        used by PUSHN that strangely needs hi-lo bytes swapped

NEEDS RENAME        \ this is just a patch to be removed in the future
NEEDS CODE          \ this is just a patch to be removed in the future 
NEEDS INVERT        \   : INVERT -1 XOR ;
NEEDS FLIP

FORTH DEFINITIONS 

MARKER FORGET-ASSEMBLER
VOCABULARY TOOLS-ASM IMMEDIATE
VOCABULARY FORTH-ASM

: ASSEMBLER FORTH-ASM 1 MMU7! ; IMMEDIATE

DECIMAL

\ Screen# 101 
ASSEMBLER TOOLS-ASM DEFINITIONS
  DP @ LP ! HEX E080 DP !
  
\  : INVERT -1 XOR ;
: @+ >R R@ CELL+ R> @ ;
: !+ >R R@ ! R> CELL+ ;
: @- 0 CELL+ - >R R@ @ R> ;
1 VARIABLE TABL1 1 ,
: ROTLEFT  TABL1 + @
  UM* \ U*
  OR ;
\
CHAR - CONSTANT &-
CHAR ~ CONSTANT &~

\ Screen# 102 

\ ## : %           COMPILE ' <NAME ;
\ ## : %           POSTPONE ' <NAME ;
\ ## : %ID.        ID. ;
: %>BODY      PFA CELL+ ;
\ ## : %BODY>      0 CELL+ - NFA ;
: %>CODE      PFA CFA CELL+  2 CFA NEGATE + ( direct/indirect patch ) ;
\ ## : IGNORE?     1+ C@ &~ = ;
: (>NEXT%)    PFA LFA @ ;
\ ## : VOCEND?     @ FFFF AND A081 = ;
\ ## : >NEXT%      BEGIN (>NEXT%)  DUP 1+ C@ &- - UNTIL ;

\ Screen# 103 
( Z80 Utility - Sys depend )
: STARTVOC '  ASSEMBLER  >BODY  CELL+ @ ;
: IS-A        <BUILDS  0 ,  DOES>  @ SWAP %>CODE @ = ;
: REMEMBER    HERE LATEST  (>NEXT%) %>BODY ! ;  IMMEDIATE
: CONTAINED-IN OVER AND = ;

\ Screen# 104 
\ 0 VARIABLE TABLE FF ,
\ FFFF , FFFFFF , FFFFFFFF ,
\ : FIRSTBYTES CELLS TABLE
\   + @ AND ;
0 VARIABLE    TALLY-BI
0 VARIABLE    TALLY-BY
0 VARIABLE    TALLY-BA
0 VARIABLE    ISS
0 VARIABLE    ISL
0 VARIABLE    PREVIOUS
: !TALLY      0 TALLY-BY !  0 TALLY-BI ! 0 TALLY-BA !  0 PREVIOUS ! ;

\ Screen# 105 
( Z80 System independ. )
: AT-REST?    TALLY-BI @ 0= TALLY-BY @ 0= AND ;
: BADPAIRS?   DUP 2 * AND AAAAAAAA AND ;
: BAD?        TALLY-BA @ BADPAIRS? ;
\ ## : COMPATIBLE? TALLY-BA @ OR BADPAIRS? 0= ;
DECIMAL

\ Screen# 106 
( Z80 Generate errors )
: CHECK26     AT-REST? 0= 26 ?ERROR ;
: CHECK27     BAD? 27 ?ERROR ;
: CHECK31     2DUP SWAP  CONTAINED-IN 0= 31 ?ERROR ;
: CHECK33     2DUP SWAP INVERT  CONTAINED-IN 0= 33 ?ERROR ;
: CHECK28     2DUP AND 28 ?ERROR ;
: CHECK29     2DUP OR -1 -  29 ?ERROR ;
: CHECK30     DUP PREVIOUS @ <  30 ?ERROR DUP PREVIOUS ! ;
HEX

\ Screen# 107 
( Assembler Z80 )
: OR!         >R R@ @ CHECK28 OR R> ! ;
: OR!U        >R R@ @ OR R> ! ;
: AND!        >R INVERT R@ @  CHECK29 AND R> ! ;

\ Screen# 108 
( Assembler Z80 )
\ ## : >DATA       %>BODY ;
\ ## : >BI         %>BODY CELL+ ;
\ ## : >BY         %>BODY 2 CELLS + ;
\ ## : >BA         %>BODY 3 CELLS + ;
\ ## : >CNT        %>BODY 4 CELLS + ;
\ ## : >DIS        %>BODY 5 CELLS ;
: CORRECT,-   ISL @ 1 CELLS - ALLOT ;
: !POSTIT     HERE ISS ! 0 PREVIOUS ! ;
: TALLY:,     @+ TALLY-BI !  @+ TALLY-BY ! @+ TALLY-BA !  @ ISL ! ;

\ Screen# 109 
( Assembler Z80 )
: POSTIT      CHECK26 !POSTIT  HERE ISS ! @+ , TALLY:,  CORRECT,- ;
IS-A IS-CBPI : CBPI CHECK33
    <BUILDS , , , , 1 , DOES>
    REMEMBER CB C, POSTIT ;
IS-A IS-EDPI : EDPI CHECK33
    <BUILDS , , , , 1 , DOES>
    REMEMBER ED C, POSTIT ;
IS-A IS-DDPI : DDPI CHECK33
    <BUILDS , , , , 1 , DOES>
    REMEMBER DD C, POSTIT ;
IS-A IS-FDPI : FDPI CHECK33
    <BUILDS , , , , 1 , DOES>
    REMEMBER FD C, POSTIT ; 

\ Screen# 110 
( Assembler Z80 )
IS-A IS-1PI : 1PI CHECK33
    <BUILDS , , , , 1 , DOES>
    REMEMBER POSTIT ;
IS-A IS-2PI : 2PI CHECK33
    <BUILDS , , , , 2 , DOES>
    REMEMBER POSTIT ;
IS-A IS-3PI : 3PI CHECK33
    <BUILDS , , , , 3 , DOES>
    REMEMBER POSTIT ;
: IS-PI >R R@ IS-1PI
    R@ IS-2PI  R@ IS-3PI OR OR
    R@ IS-CBPI R@ IS-EDPI OR OR
    R@ IS-DDPI R@ IS-FDPI OR OR
    R> DROP ;

\ Screen# 111 
( Assembler Z80 )
: TALLY:|
    @+ TALLY-BI AND!
    @+ TALLY-BY OR!
    @  TALLY-BA OR!U ;
: FIXUP> @+ ISS @ OR!  TALLY:| CHECK27 ;
IS-A IS-XFI : XFI CHECK31
    <BUILDS , , , , DOES>
    REMEMBER FIXUP> ;
: CORRECT-R 0 CELL+ ISL @  - ROTLEFT ;

\ Screen# 112 
( Assembler Z80 )
: TALLY:|R @+ CORRECT-R TALLY-BI AND! @+ TALLY-BY OR! @ TALLY-BA OR!U ;
: FIXUP< @+ CORRECT-R ISS @ OR! TALLY:|R CHECK27 ;
IS-A IS-XFIR : XFIR CHECK31
    <BUILDS , , , , DOES>
    REMEMBER FIXUP< ;
: TALLY:,, CELL+ @+ CHECK30 TALLY-BY AND! @ TALLY-BA OR!U ;
: COMMA @+ >R TALLY:,,  CHECK27 R> EXECUTE ;

\ Screen# 113 
( Assembler Z80 )
IS-A IS-COMMA : COMMAER
    <BUILDS , 0 , , , , , DOES>
    REMEMBER COMMA ;
0 VARIABLE PRO-TALLY  2 CELLS ALLOT
: T! PRO-TALLY !+ !+ !+ DROP ;
: T@ PRO-TALLY 3 CELLS +   @- @- @- DROP ;

\ Screen# 114 
( Assembler Z80 )
: 1FAMILY, 0 DO DUP >R T@   R> 1PI OVER + LOOP   DROP DROP ;
: 2FAMILY, 0 DO DUP >R T@   R> 2PI OVER + LOOP   DROP DROP ;
: 3FAMILY, 0 DO DUP >R T@   R> 3PI OVER + LOOP   DROP DROP ;
: XFAMILY| 0 DO DUP >R T@   R> XFI OVER + LOOP   DROP DROP ;
: XFAMILY|R 0 DO DUP >R T@  R> XFIR OVER + LOOP  DROP DROP ; 

\ Screen# 115 
( Assembler Z80 )
: CBFAMILY, 0 DO DUP >R T@   R> CBPI OVER + LOOP  DROP DROP ;
: EDFAMILY, 0 DO DUP >R T@   R> EDPI OVER + LOOP  DROP DROP ;

\ Screen# 116 
( Assembler Z80 )
: DDFAMILY, 0 DO DUP >R T@   R> DDPI OVER + LOOP  DROP DROP ;
: FDFAMILY, 0 DO DUP >R T@   R> FDPI OVER + LOOP  DROP DROP ;

\ Screen# 120 
.( Z80 definitions. ) CR

ASSEMBLER DEFINITIONS HEX
TOOLS-ASM

0 1 0 800       ' C,   COMMAER N,
0 0 CELL+ 0 200 '  ,   COMMAER NN,
0 0 CELL+ 0 400 '  ,   COMMAER AA,
0 1 0 100       ' C,   COMMAER P,
0 1 0 1000      ' C,   COMMAER D,




\ Screen# 121 
( Z80 ) HEX
00 00 00 T!
08 07 8 1FAMILY,    RLCA RRCA RLA  RRA  DAA  CPL  SCF  CCF
08 00 2 1FAMILY,    NOP  EXAFAF
08 E3 4 1FAMILY,    EX(SP)HL  EXDEHL  DI  EI
00 00 238 T!
08 00 8 XFAMILY|    00| 08| 10| 18|   20| 28| 30| 38|
00 00 238 C7 1PI    RST

\ RST 38|  DAA


\ Screen# 122 
( Z80 ) HEX
00 00 07 T!
01 00 8 XFAMILY|    B|  C|    D|  E|  H|  L| (HL)|  A|
08 80 8 1FAMILY,    ADDA ADCA SUBA SBCA ANDA XORA ORA  CPA
00 00 00 76 1PI     HALT

\ ADDA B|
\ HALT





\ Screen# 123 
( Z80 ) HEX
00 00 30 T!
10 00 4 XFAMILY|    BC| DE| HL| SP|
01 02 2 1FAMILY,    LD(X)A INCX
01 09 3 1FAMILY,    ADDHL  LDA(X)  DECX
00 0200 30 01 1PI   LDX
00 00 30 30 XFI     AF|
00 00 30 T!
04 C1 2 1FAMILY,    POP PUSH

\ LD(X)A BC|
\ LDX BC| nn NN,

\ Screen# 124 
( Z80 immediate data )
HEX
00 0100 00 T!
08 D3 2 1FAMILY,    OUTA  INA
00 0800 00 T!
08 C6 8 1FAMILY,    ADDN ADCN SUBN SBCN  ANDN XORN ORN  CPN
00 00 00 T!
10 C9 4 1FAMILY,    RET EXX JPHL LDSPHL

\ OUTA n P,   INA n P,
\ ADDN n N,


\ Screen# 125 
( Z80 address )
00 0400 00 T!
08 22 4 1FAMILY,    LD()HL LDHL() LD()A LDA()
0A C3 2 1FAMILY,    JP CALL
00 00 38 T!
08 00 8 XFAMILY|    B'| C'| D'| E'|  H'| L'| (HL)'| A'|
01 04 2 1FAMILY,    INC DEC
00 00 3F 40 1PI     LD
00 0800 38 06 1PI   LDN

\ LD B'| C| LD()A nn AA,

\ Screen# 126 
( Z80 ) HEX
00 00 138 T!
08 00 8 XFAMILY|    NZ|  Z|  NC|  CY|  PO| PE|   P|   M|
00 00 138 C0 1PI    RETF
00 0400 138 T!
02 C2 2 1FAMILY,    JPF CALLF

\ JPF Z| aa AA,
\ CALLF PO| aa AA,
\ RETF NC|
\ and CY| instead of C|



\ Screen# 127 
( Z80 relative jump )
HEX
00 1000 00 T!
08 10 2 1FAMILY,    DJNZ JR
00 00 218 T!
08 00 4 XFAMILY|    NZ'| Z'| NC'| CY'|
00 1000 218 20 1PI  JRF

\ JRF Z'| d D,
\ JR d D,
\ DJNZ d D,




\ Screen# 128 
( ED prefix )
00 00 30 T!
08 42 2 EDFAMILY,   SBCHL  ADCHL
00 0400 30 T!
08 43 2 EDFAMILY,   LD()X  LDX()
00 00 38 T!
01 40 2 EDFAMILY,   IN(C)  OUT(C)
 
\ SBCHL BC| ADCHL SP|
\ LDX() BC| nn AA,
\ LD()X SP| nn AA,
\ IN(C) L'|
\ OUT(C) H'|

\ Screen# 129 
( ED )
00 00 00 T!
01 44 4 EDFAMILY,   NEG RETN IM0 LDIA
02 4D 2 EDFAMILY,   RETI LDRA
01 56 2 EDFAMILY,   IM1 LDAI
01 5E 2 EDFAMILY,   IM2 LDAR
08 67 2 EDFAMILY,   RRD RLD





\ Screen# 130 
( ED )
00 00 00 T!
01 A0 4 EDFAMILY,   LDI  CPI  INI  OUTI
01 A8 4 EDFAMILY,   LDD  CPD  IND  OUTD
01 B0 4 EDFAMILY,   LDIR CPIR INIR OTIR
01 B8 4 EDFAMILY,   LDDR CPDR INDR OTDR







\ Screen# 131 
( CB )
00 00 07 T!
08 00 8 CBFAMILY,   RLC  RRC  RL  RR  SLA  SRA  SLL SRL
00 00 43F T!
40 40 3 CBFAMILY,   BIT  RES  SET
00 00 438 T!
08 00 8 XFAMILY|    0| 1| 2| 3| 4| 5| 6| 7|

\ RLC B|
\ BIT 3| B|
\ RES 3| B|
\ SET 3| B|

\ Screen# 132 
( IX IY )
HEX
00 00 00 T!
02 E3 1 DDFAMILY,   EX(SP)IX
02 E3 1 FDFAMILY,   EX(SP)IY
\
10 E9 2 DDFAMILY,   JPIX  LDSPIX
10 E9 2 FDFAMILY,   JPIY  LDSPIY
\

\


\ Screen# 133 
( IX IY )
HEX
00 00 30 T!
00 09 1 DDFAMILY,   ADDIX
00 09 1 FDFAMILY,   ADDIY
\
00 0400 00 T!
08 22 2 DDFAMILY,   LD()IX LDIX()
08 22 2 FDFAMILY,   LD()IY  LDIY()

\ ADDIX IX|  ADDIX SP|
\ LD()IY aa AA,
\ LDIY() aa AA,


\ Screen# 134 
( IX IY )
: I)          
  HERE 1 - C@
  HERE 2 - C@ 
  CB - IF
    -1 ALLOT SWAP C, C,
  ELSE
    -2 ALLOT SWAP C, CB C, C,
  ENDIF 
;
TOOLS-ASM

00 00 07 T!
00 06 1 XFAMILY|    (I

: (IX+      (I  DD I) ;
: (IY+      (I  FD I) ;
TOOLS-ASM

\ LD B'| (IY+ d )|
\ ADCA   (IY+ d )|
\ SRA    (IY+ d )|


\ Screen# 135 
( IX IY )
HEX
: )|
  HERE 1 - C@
  HERE 2 - C@
  CB = IF 
    SWAP 
  ENDIF
  HERE 1 - C! C, 
;
\
: IXY| ( n -- )
  DUP HERE 2 - 
  C@ - IF
    HERE 1- C@ -1 ALLOT SWAP C, C,
  ENDIF 
;
TOOLS-ASM


\ Screen# 136 
( IX IY )
HEX
\ INC DEC  (IX'+ d )'|
\ LDN  (IX'+ d )'|  n N,

00 00 38 T!
00 30 1 XFAMILY|    (I'

: (IX'+ (I' DD I) ;
: (IY'+ (I' FD I) ;
TOOLS-ASM

\
\ LD(IX+ d )'|  r|

00 00 07 T!
00 70 1 DDFAMILY, LD(IX+
00 70 1 FDFAMILY, LD(IY+

: )'| ' EXECUTE )| ;
TOOLS-ASM


\ Screen# 137 
( IX IY )
\ LDIXL A|

00 00 07 T!
08 60 2   DDFAMILY, LDIXH LDIXL
08 60 2   FDFAMILY, LDIYH LDIYL


\ Screen# 138 
( IX IY )
HEX
: IX|   HL|  DD  IXY| ;
: IY|   HL|  FD  IXY| ;
: IXL|   L|  DD  IXY| ;
: IXH|   H|  DD  IXY| ;
: IYL|   L|  FD  IXY| ;
: IYH|   H|  FD  IXY| ;
TOOLS-ASM

\ LDX IY| nn NN,
\ PUSH POP IX|

\ FORTH DEFINITIONS DECIMAL



\ Screen# 140 
.( Z80 near structure )   CR

ASSEMBLER DEFINITIONS HEX

\

: NEXT                     JPIX ;
: PSH1           PUSH HL|  JPIX ;
: PSH2 PUSH DE|  PUSH HL|  JPIX ;
\
: HOLDPLACE HERE 0 D, ;
: DISP,     OVER -  1 - SWAP C! ;
: BACK,     HOLDPLACE SWAP DISP, ;
\
: | ;

\ Screen# 141 
.( Z80 Near struct. )
: THEN, HERE DISP, ;
: ELSE, JR HOLDPLACE  SWAP THEN, ;

\ Screen# 160 
.( Z80N Next extension )

ASSEMBLER DEFINITIONS HEX

\ swaps hi-lo bytes
\ : <, 100 /MOD C, C, ;
: <, FLIP , ;

TOOLS-ASM

0 1 0 4000 ' <, COMMAER     LH,
\
00 0900 00 91 EDPI          NEXTREG
\  NEXTREG reg P, n N,
00 0100 00 92 EDPI          NEXTREGA
\  NEXTREGA reg P,
00 4000 00 8A EDPI          PUSHN
\   PUSHN nn LH,
00 0800 00 27 EDPI          TESTN
\  TESTN n N,


\ Screen# 161
( Z80N Next extension )

00 00 00 T!
01 23 2 EDFAMILY,           SWAPNIB MIRRORA
08 A4 4 EDFAMILY,           LDIX LDDX LDIRX LDDRX
12 A5 2 EDFAMILY,           LDWS LDPIRX
08 90 2 EDFAMILY,           OUTINB JP(C)
01 93 3 EDFAMILY,           PIXELDN PIXELAD SETAE




\ Screen# 162
( Z80N Next extension )
01 28 5 EDFAMILY,           BSLADE,B BSRADE,B BSRLDE,B BSRFDE,B BRLCDE,B          
01 30 4 EDFAMILY,           MUL  ADDHL,A ADDDE,A ADDBC,A
00 0200 00 T!
01 34 3 EDFAMILY,           ADDHL, ADDDE, ADDBC,
\ ADDBC, nn NN,
\

FORTH DEFINITIONS DECIMAL

DP @ LP @ DP !  LP !


\ Screen# 117 
.( Assembler Z80 )

FORTH DEFINITIONS RENAME CODE MCOD

: CODE ?EXEC 
    MCOD   
    [COMPILE] ASSEMBLER   
    TOOLS-ASM
    !TALLY !CSP 
    ; IMMEDIATE
: C; \ Ends a CODE definition
    CURRENT @ CONTEXT !  ?EXEC 
    TOOLS-ASM CHECK26 CHECK27  
    SMUDGE ; IMMEDIATE

' ASSEMBLER ' ;CODE >BODY 4 CELLS + ! ( patch to ;CODE )

FORTH DEFINITIONS DECIMAL
