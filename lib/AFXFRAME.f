\
\ AFXFRAME.F
\
.( AFXFRAME )

NEEDS BINARY            \ base 2
NEEDS SPLIT             \ split an integer into two bytes, low, high.
\ NEEDS AY
\ NEEDS ASSEMBLER

BASE @

\ MARKER TASK

DECIMAL

CREATE   AFX-CH-DESC 48 ALLOT
         AFX-CH-DESC 48 ERASE

        \ (E)=noise, (D)=mixer 
CREATE   AFX-MIXER   06 ALLOT
         AFX-MIXER   06 ERASE


\ +0 current pointer  (channel is frEe if high byte #00
\ +2 effect time
\ 
\ Every frame is encoded with a flags-byte and a number of data bytes 
\ depending from value change flags (from 0 to 3)
\  bit0..3  Volume
\  bit4     Disable T
\  bit5     Change Tone
\  bit6     Change Noise
\  bit7     Disable N
\ 
\ FORTH
\ HERE  \ call-hook
\ TOOLS-ASM !TALLY !CSP
\ ASSEMBLER 
HEX
\ ix register must be prepared
\ afxFrame:                            
  HERE                                                \                       0
                    \ prepare woring registes         \ a  b c   d e   h l    LABEL
  
                    \ afxFrame0:                            
                    \ HERE                            \                       0
  C5 C,             \ push    bc|                     \    03FD
  3E C, 0B C,       \ ldn     a'|  DECIMAL 11 N,      \ 0B 03FD      
  DD C, 66 C, 01 C, \ ld      h'|  (ix+  1  )|        \ 0B 03FD        addr
                      
                    \ skip if h <= 0B, that is addr is in rom
  BC C,             \ cpa      h|    
  30 C, 68 C,       \ jrf    nc'|  HOLDPLACE          \ afxFrame7             0 7
  DD C, 6E C, 00 C, \ ld      l'|  (ix+  0  )|        \ 0B 03FD        addr
  5E C,             \ ld      e'|  (hl)|              \ 0B 03FD  __xv  addr
  23 C,             \ incx    hl|                     \ 0B 03FD  __xv  addr+1
                      
                    \ compute channel A,B,C: 11-b is 8,9 or 10
  90 C,             \ suba     b|                     \ 0B 03FD  __xv  addr+1
                      
                    \ save b (3,2,1)                  \ a  b c   d e   h l    LABEL
  50 C,             \ ld      d'|     b|              \ 0B 03FD  03xv  addr+1
                      
                    \ send volume to chip register
  06 C, FF C,       \ ldn     b'|  hex  0FF  N,       \ 0B FFFD  03xv  addr+1
  ED C, 79 C,       \ out(c)  a'|                     \ select chip register 8,9 or 10
  06 C, BF C,       \ ldn     b'|  hex  0BF  N,       \ 0B BFFD  03xv  addr+1
  7B C,             \ ld      a'|     e|              \ XV BFFD  03xv  addr+1
  E6 C, 0F C,       \ andn         hex  00F  N,       \ 0V BFFD  03xv  addr+1
  ED C, 79 C,       \ out(c)  a'|                     \ volume is between 0 and 15
                      
                    \ decide if tone changes          \ a  b c   d e   h l    LABEL
  CB C, 6B C,       \ bit      5|     e|
  28 C, 19 C,       \ jrf     z'|  HOLDPLACE          \ afxFrame1             0 7 1
                      
                      \ select tone register: 0-1, 2-3, 4-5
  3E C, 03 C,       \ ldn     a'|  3  N,              \ 03 BFFD  03xv  addr+1
  92 C,             \ suba     d|                     \ 00 BFFD  03xv  addr+1
  87 C,             \ adda     a|                     \  a : 0 or 2 or 4 chip register
              
                      \ emit tone value               \ a  b c   d e   h l    LABEL
  06 C, FF C,       \ ldn     b'|  hex  0FF  N,       \ 00 FFFD  03xv  addr+1
  ED C, 79 C,       \ out(c)  a'|                     \ tone chip register 0, 2, 4
  06 C, BF C,       \ ldn     b'|  hex  0BF  N,       \ 00 BFFD  03xv  addr+1
  56 C,             \ ld      d'|  (hl)|              \ 00 BFFD  ttxv  addr+1
  23 C,             \ incx    hl|                     \ 00 BFFD  ttxv  addr+2
  ED C, 51 C,       \ out(c)  d'|                     \ emit low-byte tone value
                      
  06 C, FF C,       \ ldn     b'|  hex  0FF  N,       \ 00 FFFD  ttxv  addr+2
  3C C,             \ inc     a'|                     \ 01 FFFD  ttxv  addr+2
  ED C, 79 C,       \ out(c)  a'|                     \ tone chip register 1, 3, 5
  06 C, BF C,       \ ldn     b'|  hex  0BF  N,       \ 01 BFFD  ttxv  addr+2
  56 C,             \ ld      d'|  (hl)|              \ 01 BFFD  0txv  addr+2
  23 C,             \ incx    hl|                     \ 01 BFFD  0txv  addr+3
  ED C, 51 C,       \ out(c)  d'|                     \ emit high byte tone value
                    \
                    \ afxFrame1:
                    \       HERE DISP,                \ resolve jr afxFrame1  0 7
                      \
                      \ decide noise change           \ a  b c   d e   h l    LABEL
  CB C, 73 C,       \ bit      6|     e|
  28 C, 0F C,       \ jrf     z'|  HOLDPLACE          \ afxFrame3             0 7 3
                    \ \
  7E C,             \ ld      a'|  (hl)|              \ nn BFFD  0txv  addr+3
  D6 C, 20 C,       \ subn         hex  020  N,       \ nn BFFD  0txv  addr+3
  38 C, 06 C,       \ jrf    cy'|  HOLDPLACE          \ afxFrame2             0 7 3 2
              
  67 C,             \ ld      h'|  a|                 \ nn BFFD  0txv  nn..
  06 C, FF C,       \ ldn     b'|  hex  0FF  N,       \ nn FFFD  0txv  nn..
  48 C,             \ ld      c'|  b|                 \ nn FFFF  0txv  nn..
  18 C, 1E C,       \ jr           HOLDPLACE          \ afxFrame6             0 7 3 2 6
                    \
                    \ afxFrame2:
                    \ SWAP  HERE DISP,                \ resolve jr afxFrame2  0 7 3 6
  23 C,             \ incx    hl|                     \ nn BFFD  0txv  addr+4
  32 C, AFX-MIXER , \ ld()a   AFX-MIXER  AA,          \ put noise period in mixer
                    \
                    \ afxFrame3:
                    \ SWAP  HERE DISP,                \ resolve jr afxFrame3  0 7 6
  C1 C,             \ pop     bc|                     \ nn 03FD  0txv  addr+4
  C5 C,             \ push    bc|
  04 C,             \ inc     b'|                     \ nn 04FD  0txv  addr+4
                    \
  3E C, 6F C,       \ ldn     a'| binary 01101111 N,  \ mm 04FD  0txv  addr+4
                    \
                    \ afxFrame4:                      \ a  b c   d e   h l    LABEL
                    \ HERE                            \                       0 7 6 4 
  CB C, 0B C,       \ rrc      e|                     \ nNTt____ --> ____nNTt  
  0F C,             \ rrca                            \ 01101111 --> 11110110
  10 C, FB C,       \ djnz    BACK,                   \ afxFrame4             0 7 6
                      
  57 C,             \ ld      d'|  a|                 \ mf 04FD  mfmd  addr+4
  01 C,             \ ldx     bc|  AFX-MIXER 1+  NN,  \ mf ....  mfmd  addr+4  
     AFX-MIXER 1+ ,    
  0A C,             \ lda(x)  bc|                     \ current mixer status
  AB C,             \ xora     e|                     \ set or reset 
  A2 C,             \ anda     d|                     \ bit "n" and "t"
  AB C,             \ xora     e|                     \ only
  02 C,             \ ld(x)a  bc|
                    \
                    \ afxFrame5:
  DD C, 4E C, 02 C, \ ld      c'|  (ix+  2  )|        \ increase timer
  DD C, 46 C, 03 C, \ ld      b'|  (ix+  3  )|
  03 C,             \ incx    bc|
                    \
                    \ afxFrame6:
                    \       HERE DISP,                \ resolve jr afxFrame6  0 7
  DD C, 71 C, 02 C, \ ld(ix+  2  )'|  c|
  DD C, 70 C, 03 C, \ ld(ix+  3  )'|  b|
  DD C, 75 C, 00 C, \ ld(ix+  0  )'|  l|
  DD C, 74 C, 01 C, \ ld(ix+  1  )'|  h|
                    \
                    \ afxFrame7:
                    \       HERE DISP,                \ resolve jr afxFrame7  0
  01 C, 0004 ,      \ ldx     bc|  HEX 4  NN,
  DD C, 09 C,       \ addix   bc|
                      
  C1 C,             \ pop     bc|                     \ nN 03FD  ....  addr+4
  10 C, 87 C,       \ djnz    BACK,                   \ afxFrame0
                      
                      \ decides noise and output mixer
  21 C, FFBF ,      \ ldx     hl|   HEX 0FFBF  NN,    \ nN 00FD  ....  FFBF
              
  ED C, 5B C,       \ ldx()   de|   AFX-MIXER  AA,    \ nN 00FD  ....  FFBF
     AFX-MIXER ,             
  3E C, 06 C,       \ ldn     a'|   6   N,            \ 06 00FD  ....  FFBF
  44 C,             \ ld      b'|   h|                \ 06 FFFD  ....  FFBF
  ED C, 79 C,       \ out(c)  a'|                     \ select noise period chip regisger
  45 C,             \ ld      b'|   l|                \ 06 BFFD  ....  FFBF
  ED C, 59 C,       \ out(c)  e'|                     \ send noise period 
  3C C,             \ inc     a'|                     \ 06 BFFD  ....  FFBF
  44 C,             \ ld      b'|   h|                \ 06 FFFD  ....  FFBF
  ED C, 79 C,       \ out(c)  a'|                     \ select flags chip regisger
  45 C,             \ ld      b'|   l|                \ 06 BFFD  ....  FFBF
  ED C, 51 C,       \ out(c)  d'|                     \ send flags 
  C9 C,             \ ret
  
  \
  \ AFXFRAME 
  \ this definition is suitable to be called within an ISR
  \
  CODE AFXFRAME ( -- )
          
  HEX
                    \ save Forth registers 
  DD C, E5 C,       \ push    ix|
  C5 C,             \ push    bc|
  D5 C,             \ push    de|
  
  DD C, 21 C,       \ ldx     ix|  AFX-CH-DESC NN,
      AFX-CH-DESC ,
  11 C, AFX-MIXER , \ ldx     de| AFX-MIXER NN,   
  01 C, HEX 0FFFD , \ ldx     bc| 0FFFD NN,  
  21 C, HEX 003FC , \ ldx     bc| 003FC NN,

\ afxFrameAY:  
  2C C,             \ inc     l'|
  ED C, 69 C,       \ out(c)  l'|
  D9 C,             \ exx
  01 C, HEX 003FD , \ ldx     bc|  HEX 03FD  NN, 
  CD C, ,           \ call    SWAP AA,  
  D9 C,             \ exx
  25 C,             \ dec     h'|
  20 C, F2 C,       \ jrf    nz'|    BACK,            \ resolve afxFrameAY

  D1 C,             \ pop     de|
  C1 C,             \ pop     bc|
  DD C, E1 C,       \ pop     ix|
  DD C, E9 C,       \ jpix

SMUDGE \ C;

\ end of AFXFRAME

DECIMAL
FORTH DEFINITIONS

BASE !
