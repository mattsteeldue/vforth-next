\
\ AFXFRAME.F
\
.( AFXFRAME )

NEEDS BINARY            \ base 2
NEEDS SPLIT             \ split an integer into two bytes, low, high.
NEEDS AY
NEEDS ASSEMBLER

BASE @

MARKER TASK

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
  FORTH
\ afxFrame-sub:  
  HERE  \ call-hook for AFXFRAME
  TOOLS-ASM !TALLY !CSP
  ASSEMBLER 

\ afxFrame0:                            
  HERE                                  \                       0
        push    bc|                     \    03FD
        ldn     a'|  DECIMAL 11 N,      \ 0B 03FD      
        ld      h'|  (ix+  1  )|        \ 0B 03FD        addr
        
        \ skip if h <= 0B, that is addr is in rom
        cpa      h|    
        jrf    nc'|  HOLDPLACE          \ afxFrame7             0 7
        ld      l'|  (ix+  0  )|        \ 0B 03FD        addr
        ld      e'|  (hl)|              \ 0B 03FD  __xv  addr
        incx    hl|                     \ 0B 03FD  __xv  addr+1
        
        \ compute channel A,B,C: 11-b is 8,9 or 10
        suba     b|                     \ 0B 03FD  __xv  addr+1
        
        \ save b (3,2,1)                \ a  b c   d e   h l    LABEL
        ld      d'|     b|              \ 0B 03FD  03xv  addr+1
        
        \ send volume to chip register
        ldn     b'|  hex  0FF  N,       \ 0B FFFD  03xv  addr+1
        out(c)  a'|                     \ select chip register 8,9 or 10
        ldn     b'|  hex  0BF  N,       \ 0B BFFD  03xv  addr+1
        ld      a'|     e|              \ XV BFFD  03xv  addr+1
        andn         hex  00F  N,       \ 0V BFFD  03xv  addr+1
        out(c)  a'|                     \ volume is between 0 and 15
        
        \ decide if tone changes        \ a  b c   d e   h l    LABEL
        bit      5|     e|
        jrf     z'|  HOLDPLACE          \ afxFrame1             0 7 1
        
        \ select tone register: 0-1, 2-3, 4-5
        ldn     a'|  3  N,              \ 03 BFFD  03xv  addr+1
        suba     d|                     \ 00 BFFD  03xv  addr+1
        adda     a|                     \  a : 0 or 2 or 4 chip register

        \ emit tone value               \ a  b c   d e   h l    LABEL
        ldn     b'|  hex  0FF  N,       \ 00 FFFD  03xv  addr+1
        out(c)  a'|                     \ tone chip register 0, 2, 4
        ldn     b'|  hex  0BF  N,       \ 00 BFFD  03xv  addr+1
        ld      d'|  (hl)|              \ 00 BFFD  ttxv  addr+1
        incx    hl|                     \ 00 BFFD  ttxv  addr+2
        out(c)  d'|                     \ emit low-byte tone value
        
        ldn     b'|  hex  0FF  N,       \ 00 FFFD  ttxv  addr+2
        inc     a'|                     \ 01 FFFD  ttxv  addr+2
        out(c)  a'|                     \ tone chip register 1, 3, 5
        ldn     b'|  hex  0BF  N,       \ 01 BFFD  ttxv  addr+2
        ld      d'|  (hl)|              \ 01 BFFD  0txv  addr+2
        incx    hl|                     \ 01 BFFD  0txv  addr+3
        out(c)  d'|                     \ emit high byte tone value
\
\ afxFrame1:
        HERE DISP,                      \ resolve jr afxFrame1  0 7
        \
        \ decide noise change           \ a  b c   d e   h l    LABEL
        bit      6|     e|
        jrf     z'|  HOLDPLACE          \ afxFrame3             0 7 3
        \
        ld      a'|  (hl)|              \ nn BFFD  0txv  addr+3
        subn         hex  020  N,       \ nn BFFD  0txv  addr+3
        jrf    cy'|  HOLDPLACE          \ afxFrame2             0 7 3 2

        ld      h'|  a|                 \ nn BFFD  0txv  nn..
        ldn     b'|  hex  0FF  N,       \ nn FFFD  0txv  nn..
        ld      c'|  b|                 \ nn FFFF  0txv  nn..
        jr           HOLDPLACE          \ afxFrame6             0 7 3 2 6
\
\ afxFrame2:
  SWAP  HERE DISP,                      \ resolve jr afxFrame2  0 7 3 6
        incx    hl|                     \ nn BFFD  0txv  addr+4
        ld()a   AFX-MIXER  AA,          \ put noise period in mixer
\
\ afxFrame3:
  SWAP  HERE DISP,                      \ resolve jr afxFrame3  0 7 6
        pop     bc|                     \ nn 03FD  0txv  addr+4
        push    bc|
        inc     b'|                     \ nn 04FD  0txv  addr+4
\
        ldn     a'| binary 01101111 N,  \ mm 04FD  0txv  addr+4
\
\ afxFrame4:                            \ a  b c   d e   h l    LABEL
  HERE                                  \                       0 7 6 4 
        rrc      e|                     \ nNTt____ --> ____nNTt  
        rrca                            \ 01101111 --> 11110110
        djnz    BACK,                   \ afxFrame4             0 7 6
        
        ld      d'|  a|                 \ mf 04FD  mfmd  addr+4
        ldx     bc|  AFX-MIXER 1+  NN,  \ mf ....  mfmd  addr+4
        lda(x)  bc|                     \ current mixer status
        xora     e|                     \ set or reset 
        anda     d|                     \ bit "n" and "t"
        xora     e|                     \ only
        ld(x)a  bc|
\
\ afxFrame5:
        ld      c'|  (ix+  2  )|        \ increase timer
        ld      b'|  (ix+  3  )|
        incx    bc|
\
\ afxFrame6:
        HERE DISP,                      \ resolve jr afxFrame6  0 7
        ld(ix+  2  )'|  c|
        ld(ix+  3  )'|  b|
        ld(ix+  0  )'|  l|
        ld(ix+  1  )'|  h|
\
\ afxFrame7:
        HERE DISP,                      \ resolve jr afxFrame7  0
        ldx     bc|  HEX 4  NN,
        addix   bc|
        
        pop     bc|                     \ nN 03FD  ....  addr+4
        djnz    BACK,                   \ afxFrame0
        
        \ decides noise and output mixer
        ldx     hl|   HEX 0FFBF  NN,    \ nN 00FD  ....  FFBF

        ldx()   de|   AFX-MIXER  AA,    \ nN 00FD  ....  FFBF

        ldn     a'|   6   N,            \ 06 00FD  ....  FFBF
        ld      b'|   h|                \ 06 FFFD  ....  FFBF
        out(c)  a'|                     \ select noise period chip regisger
        ld      b'|   l|                \ 06 BFFD  ....  FFBF
        out(c)  e'|                     \ send noise period 
        inc     a'|                     \ 06 BFFD  ....  FFBF
        ld      b'|   h|                \ 06 FFFD  ....  FFBF
        out(c)  a'|                     \ select flags chip regisger
        ld      b'|   l|                \ 06 BFFD  ....  FFBF
        out(c)  d'|                     \ send flags 
        ret


code AFXFRAME ( -- )

        \ save Forth registers 
        push    ix|
        push    bc|
        push    de|
        
        \ prepare woring registes       \ a  b c   d e   h l    LABEL
        ldx     ix|  AFX-CH-DESC NN,
        ldx     de|  AFX-MIXER   NN,   
        ldx     bc|  0FFFD       NN,         
        ldx     hl|  003FC       NN,
\ afxFrameAY:
  HERE
        inc     l'|
        out(c)  l'|                     \ select AY1, AY2, AY3
        exx
        ldx     bc|  HEX 03FD  NN,      \    03FD
        call    SWAP AA,                \ use call-hook to afxFrame-sub
        exx
        dec     h'|
        jrf    nz'|    BACK,            \ resolve afxFrameAY

        pop     de|
        pop     bc|
        pop     ix|
        jpix
C;

\ end of AFXFRAME

DECIMAL
FORTH DEFINITIONS
BASE !
