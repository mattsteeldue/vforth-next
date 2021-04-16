\ z80n-asm.f
\ 
CR
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

NEEDS RENAME
NEEDS CODE

DECIMAL 100 LOAD

