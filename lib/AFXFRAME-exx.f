\
\ AFXFRAME.f
\
.( AFXFRAME )

NEEDS AY
NEEDS BINARY            \ accept number in base 2
NEEDS ASSEMBLER

BASE @

MARKER TASK

DECIMAL
        \ (E)=noise, (D)=mixer 
VARIABLE AFX-MIXER

CREATE   AFX-CH-DESC 12 ALLOT
         AFX-CH-DESC 12 ERASE

\ +0 current pointer  (channel is frEe if high byte #00
\ +2 effect time
\ 
\ Every frame is encoded with a flags-byte and a number of data bytes 
\ depending from value change flags (from 0 to 3)
\   bit0..3  Volume
\   bit4     Disable T
\   bit5     Change Tone
\   bit6     Change Noise
\   bit7     Disable N
\ 
code AFXFRAME ( -- )

    \ save Forth registers 
    push    ix|
    push    bc|
    push    de|

    \ prepare woring registes           \ a  b c  d e  h l  | b'c' d'e' h'l'  a'
    ldx     ix|  AFX-CH-DESC NN,                            
    ldx     bc|  AY-register-port  NN,  \ .. FFFD .... .... | .... .... ....  ..
    ldx     de|  0303 NN,               \ .. FFFD 0n03 .... | .... .... ....  ..
    ldhl()  AFX-MIXER AA,               \ .. FFFD 0n03 mmmm | .... .... ....  .. 
    exx                                 \ .. .... .... .... | FFFD 0n03 mmmm  ..
    ldx     bc|  AY-data-port  NN,      \ .. BFFD .... .... | FFFD 0n03 mmmm  ..

\ afxFrame0:                            
  HERE                                  \                       0
    ldn     a'|  DECIMAL 11 N,          \ 0B BFFD .... .... | FFFD 0n03 mmmm  ..
    ld      h'|  (ix+  1  )|            \ 0B BFFD .... aa.. | FFFD 0n03 mmmm  ..
    
    \ skip if h <= 0B
    cpa      h|    
    jrf    nc'|  HOLDPLACE              \ afxFrame7             0 7
    ld      l'|  (ix+  0  )|            \ 0B BFFD .... aaaa | FFFD 0n03 mmmm  ..
    ld      e'|  (hl)|                  \ 0B BFFD ..xv aaaa | FFFD 0n03 mmmm  ..
    incx    hl|                         \ 0B BFFD ..xv aaaa | FFFD 0n03 mmmm  ..
    
    \ compute channel A,B,C: 11-b is 8,9 or 10
    exx                                 \ 0B FFFD 0n03 mmmm | BFFD ..xv aaaa  ..
    suba     b|                         \ 08 FFFD 0n03 mmmm | BFFD ..xv aaaa  ..
    
    \ send volume to chip register
    \ select chip register 8,9 or 10
    \ volume is between 0 and 15
    out(c)  a'|                         \ a  b c  d e  h l  | b'c' d'e' h'l'  a'
    exx                                 \ 0v BFFD ..xv aaaa | FFFD 0n03 mmmm  ..
    ld      a'|     e|                  \ xv BFFD ..xv aaaa | FFFD 0n03 mmmm  ..
    andn         hex  00F  N,           \ 0v BFFD ..xv aaaa | FFFD 0n03 mmmm  ..
    out(c)  a'|                     
    
    \ decide if tone changes        
    bit      5|     e|                  
    jrf     z'|  HOLDPLACE              \ afxFrame1             0 7 1
    
    \ select tone register: 0-1, 2-3, 4-5
    exx                                 \ 0v FFFD 0n03 mmmm | BFFD ..xv aaaa  ..
    ldn     a'|  3  N,                  \ 03 FFFD 0n03 mmmm | BFFD ..xv aaaa  ..
    suba     d|                         \ 0y FFFD 0n03 mmmm | BFFD ..xv aaaa  ..
    \  a : 0 or 2 or 4 chip register
    adda     a|                         

    \ emit tone value low-byte          \ a  b c  d e  h l  | b'c' d'e' h'l'  a'
    out(c)  a'|                         \ 0y FFFD 0n03 mmmm | BFFD ..xv aaaa  ..
    exx                                 \ 0y BFFD ..xv aaaa | FFFD 0n03 mmmm  ..
    ld      d'|  (hl)|                  \ 0y BFFD ttxv aaaa | FFFD 0n03 mmmm  ..
    incx    hl|                         \ 0y BFFD ttxv aaaa | FFFD 0n03 mmmm  ..
    exx                                 \ 0y FFFD 0n03 mmmm | BFFD ttxv aaaa  ..
    out(c)  d'|                         \ 0y FFFD 0n03 mmmm | BFFD ttxv aaaa  ..
    
    \ tone chip register 1, 3, 5
    inc     a'|                         \ 0n FFFD 0n03 mmmm | BFFD ttxv aaaa  ..
    out(c)  a'|                         
    exx                                 \ 0y BFFD ttxv aaaa | FFFD 0n03 mmmm  ..
    ld      d'|  (hl)|                  \ 0y BFFD 0txv aaaa | FFFD 0n03 mmmm  ..
    incx    hl|                         \ 0y BFFD 0txv aaaa | FFFD 0n03 mmmm  ..
    out(c)  d'|                         \ emit high byte tone value
\
\ afxFrame1:
    HERE DISP,                          \ resolve jr afxFrame1  0 7
    \
    \ decide noise change               \ a  b c  d e  h l  | b'c' d'e' h'l'  a'
    bit      6|     e|
    jrf     z'|  HOLDPLACE              \ afxFrame3             0 7 3
    \
    ld      a'|  (hl)|                  \ nn BFFD 0txv aaaa | FFFD 0n03 mmmm  ..
    subn         hex  020  N,           \ nn BFFD 0txv aaaa | FFFD 0n03 mmmm  ..
    jrf    cy'|  HOLDPLACE              \ afxFrame2             0 7 3 2

    ld      h'|  a|                     \ nn BFFD  0txv  nn..
    ldn     b'|  hex  0FF  N,           \ nn FFFD  0txv  nn..
    ld      c'|  b|                     \ nn FFFF  0txv  nn..
    jr           HOLDPLACE              \ afxFrame6             0 7 3 2 6
\
\ afxFrame2:
  SWAP  HERE DISP,                      \ resolve jr afxFrame2  0 7 3 6
    incx    hl|                         \ nn BFFD 0txv aaaa | FFFD 0n03 ....  ..
    ld()a   AFX-MIXER  AA,              \ put noise period in mixer
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
  SWAP  HERE DISP,                      \ resolve jr afxFrame6  0 7
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

    pop     de|
    pop     bc|
    pop     ix|
    jpix
C;

\ end of AFXFRAME

DECIMAL
FORTH DEFINITIONS
BASE !
