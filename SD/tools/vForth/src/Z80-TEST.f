\ Z80-TEST.f

: TASK ;

-5  VALUE   d 
 3  VALUE   n
 7  VALUE  nn
 8  VALUE  aa
44  VALUE   r 

ASSEMBLER 

:  r|  ASSEMBLER    E| ;
: r'|  ASSEMBLER   E'| ;
: rr|  ASSEMBLER   DE| ;
:  n|  ASSEMBLER    7| ;
:  f|  ASSEMBLER   PE| ;
: f'|  ASSEMBLER   Z'| ;
: aa|  ASSEMBLER   08| ;

\ FORTH ASSEMBLER

CODE Z80-TESTER
    \
    ADCA     (HL)|
    ADCA (IY+ d )|
    ADCN        n    N, 
    ADCA        r|
    ADCHL      rr|
    ADDA     (HL)|
    ADDA (IY+ n )|          
    ADDN        n    N,
    ADDA        r|
    ADDHL      rr|
    ADDHL,A                  \ Next extension
    ADDDE,A                  \ Next extension
    ADDBC,A                  \ Next extension
    ADDHL,     nn   NN,      \ Next extension
    ADDDE,     nn   NN,      \ Next extension
    ADDBC,     nn   NN,      \ Next extension
    ADDIY      rr|
    ANDA     (HL)|
    ANDA (IY+ n )|
    ANDN        n    N,
    ANDA        r|
    BIT         n|     (HL)|
    BIT         n| (IY+ d )|
    BIT         n|        r|
    BRLCDE,B                 \ Next extension
    BSLADE,B                 \ Next extension
    BSRADE,B                 \ Next extension
    BSRFDE,B                 \ Next extension
    BSRLDE,B                 \ Next extension
    CALLF       f|  aa   AA,
    CALL            aa   AA,
    CCF 
    CPA      (HL)|
    CPA  (IY+ n )|
    CPN         n    N,
    CPA         r|
    CPD
    CPDR
    CPI
    CPIR
    CPL
    DAA
    DEC     (HL)'|
    DEC (IY'+ d )|
    DECX       rr|
    DECX       IX|
    DECX       IY|
    DEC        r'|
    DI
    DJNZ        d    D,
    EI
    EX(SP)HL
    EX(SP)IY
    EXAFAF
    EXDEHL
    EXX
    HALT
    IM0   
    IM1   
    IM2
    IN(C)   (HL)'| 
    INA         n    P,
    IN(C)      r'|
    INC     (HL)'|
    INC (IY'+ d )|
    INCX       rr|
    INCX       IX|
    INCX       IY|
    INC        r'|
    IND
    INDR
    INI
    INIR
    JP(C)
    JPHL
    JPIX
    JPIY
    JPF         f|  aa   AA,
    JP              aa   AA,
    JRF        f'|   d    D,
    JR               d    D,
    LD(X)A     rr|
    LD      (HL)'|         r|
    LDN     (HL)'|    n    N,
    LDN (IY'+ d )|    n    N,
    LD(IY+    d )|         r|
    LD()A            aa   AA,
    LD()X      rr|   nn   AA,
    LD()IY           aa   AA,
    LD()HL           aa   AA,
    LDA(X)     rr|
    LDA()            aa   AA,
    LDAI     
    LDAR     
    LDX        rr|   nn   NN,
    LDX()      rr|   nn   AA,
    LDHL()           aa   AA,
    LDIA     
    LDX        IY|   nn   NN,
    LDRA     
    LDSPHL   
    LDSPIX    
    LDSPIY   
    LD         r'|      (HL)|
    LD         r'|  (IY+ d )|
    LD         r'|         r|
    LDN        r'|    n    N,
    LDD
    LDDR
    LDDRX
    LDDX
    LDI
    LDIR
    LDIRX
    LDIX
    LDPIRX
    LDWS
    MIRRORA
    MUL
    NEG
    NEXTREGA   r  P,
    NEXTREG    r  P,  n  N,  
    NOP
    ORA       (HL)|
    ORA   (IY+ d )|
    ORN          n    N,
    ORA          r|
    OTDR
    OTIR
    OUT(C)   (HL)'|
    OUT(C)      r'|
    OUTA         n    P, 
    OUTD
    OUTI
    OUTINB
    PIXELAD
    PIXELDN
    POP         AF|
    POP         rr|
    POP         IX|
    POP         IY|     
    PUSH        rr|
    PUSH        IX|
    PUSH        IY|    
    PUSHN       nn   LH,
    RES          n|     (HL)|
    RES          n| (IY+ d )|
    RES          n|        r|
\   RES          n|        r|  (IY+ d )|    
    RET       
    RETF         f|
    RETI
    RETN
    RL        (HL)|
    RL    (IY+ d )|
    RL           r|
\   RL           r| (IY+ d )|         
    RLA   
    RLC       (HL)|
    RLC   (IY+ d )|
    RLC          r|
\   RLC          r| (IY+ d )|         
    RLCA  
    RLD   
    RR        (HL)|
    RR    (IY+ d )|
    RR           r|
\   RR           r| (IY+ d )|         
    RRA   
    RRC       (HL)|
    RRC   (IY+ d )|
    RRC          r|
\   RRC          r| (IY+ d )|         
    RRCA  
    RRD   
    RST         aa|
    SBCA      (HL)|
    SBCA  (IY+ d )|
    SBCN         n   N,
    SBCA         r|
    SBCHL       rr|
    SCF   
    SET          n|     (HL)|
    SET          n| (IY+ d )|
    SET          n|        r|
\   SET          n|        r|  (IY+ d )|    
    SETAE 
    SLL       (HL)|
    SLL   (IY+ d )|
    SLL          r|
\   SLL          r| (IY+ d )|               
    SLA       (HL)|
    SLA   (IY+ d )|
    SLA          r|
\   SLA          r| (IY+ d )|
    SRA       (HL)|
    SRA   (IY+ d )|
    SRA          r|
\   SRA          r| (IY+ d )|            
    SRL       (HL)|
    SRL   (IY+ d )|
    SRL          r|
\   SRL          r| (IY+ d )|            
    SUBA      (HL)|
    SUBA  (IY+ d )|
    SUBN         n   N,
    SUBA         r|
    SWAPNIB
    TESTN        n   N,
    XORA      (HL)|
    XORA  (IY+ d )|
    XORN         n   N,
    XORA         r|
C;  

QUIT
