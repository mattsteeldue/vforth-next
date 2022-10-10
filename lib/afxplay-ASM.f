\ 440 
\ .( AFX PLAYER - Music using AY )

 needs assembler
 needs binary

 DECIMAL

 variable afxBnkAdr  \ pointer indirizzo bank
 
 variable afxNseMix  \ valore noise-mixer
 
 
 variable afxChDesc  10 allot  \ 12 bytes table 3x4

          afxChDesc  12 ERASE

          4400 block afxBnkAdr !


\ BINARY 11111101 \ enable left+right audio, select AY1
\ HEX FFFD P!
\ BINARY 00010010 HEX 08 REG! \ Use ABC, enable internal spkr
\ BINARY 11100000 HEX 09 REG! \ Enable mono for AY1-3
 
: AYSETUP
    \ enable left-right audio, select AY1
    [ BINARY ] 10011111  [ HEX ] 0FFFD P!
    \ setup mapping of chip channels to stereo channels
    [ HEX    ] 8 REG@
    [ BINARY ] 00000010 OR  \ enable NextSound
    [ HEX    ] 8 REG!
    [ HEX    ] 9 REG@
    [ BINARY ] 00011111 AND \ disable Mono for A,B and C
    [ HEX    ] 9 REG!
;





\ Inizializzazione del descrittore dei canali                   
\ Disattiva tutti i canali, imposta le variabili.               
\ Input: indirizzo del bank con effetti                    

CODE AFXINIT ( a -- )
    exx
    pop     hl|
    incx    hl|
    ld()hl  afxBnkAdr     AA,   \ pointer indirizzo bank
    
    ldx     hl|  afxChDesc NN, \ contrassegna i 3 canali come vuoti
    ldx     de|  hex 00ff  NN,
    ldx     bc|  hex 03fd  NN,
HERE \ afxInit0
    ld      (hl)'| d|           \ zero
    incx    hl
    ld      (hl)'| d|           \ zero
    incx    hl
    ld      (hl)'| e|           \ FF
    incx    hl
    ld      (hl)'| e|
    incx    hl|
    djnz    BACK, \ afxInit0

    ldx     hl| hex ffbf NN,    \ inizializza 14 registri AY 
    ldn     e'| hex 15   N,
HERE \ afxInit1
    dec     e'|           \ 
    ld      b'| h|        \ BC <-- #fffd : Turbo Sound Next Control Register
    out(c)  e'|
    ld      b'| l|        \ BC <-- #bffd : Sound Chip Register Write 
    out(c)  d'|
    jr nz,  BACK, \ afxInit1

    ld()de  afxNseMix    AA,    \ mixer

    exx next \ ret
 
 
\
\ Riproduci il frame corrente.                                 ;
\ Non ci sono parametri.                                       ;
code AFXFRAME
 \ save Forth status
        push    ix|
        push    bc|
\
\ prepare registes: B contatore per 3 ; C porta bassa di #FFFD / BFFD
        ldx     bc|  HEX 03FD NN,
        ldx     ix|  AFX-CH-DESC NN,
\
\
 \ afxFrame0:                                            0
HERE    push    bc|

        ldn     a'|  DECIMAL 11 N,
        ld      h'|  (ix+  1  )|    
        cpa      h|                 \ confronta byte di indirizzo alto con 11
        jrf    nc'|  HOLDPLACE      \ afxFrame7          0 7

        ld      l'|  (ix+  0  )|    \ prende anche (ix+0)

        ld      e'|  (hl)|          \ prende il valore del byte di dati
        incx    hl|

        xora     a|                 \ calc channel AY3 AY2 AY1
        suba     b|

        ld      d'|  b|             \ salva in d il valore di b (3,2,1)

        ldn     b'|  hex  0FF  N,   \ bc : FFFD
        out(c)  a'|                 \ manda in output il valore del volume
        ldn     b'|  hex  0BF  N,   \ bc : BFFD
        ld      a'|  e|
        andn         hex  00F  N,
        out(c)  a'|                 \ send volume

        bit      5|     e|          \ il tono non cambia, passa oltre
        jrf     z'|  HOLDPLACE      \ afxFrame1          0 7 1

        ldn     a'|  3  N,          \ seleziona i registri dei toni:
        suba     d|                 \ 3-3=0, 3-2=1, 3-1=2
        adda     a|                 \ 0*2=0, 1*2=2, 2*2=4

        ldn     b'|  hex  0FF  N,   \ bc : FFFD
        out(c)  a'|                 \ emette il valori di tono sul reg. 0, 2, 4 
        ldn     b'|  hex  0BF  N,   \ bc : BFFD
        ld      d'|  (hl)|          \ channel tone low byte
        incx    hl|
        out(c)  d'|
        inc     a'|                 \ sul registro 1, 3, 5
        ldn     b'|  hex  0FF  N,   \ bc : FFFD
        out(c)  a'|
        ldn     b'|  hex  0BF  N,   \ bc : BFFD
        ld      d'|  (hl)|
        incx    hl|
        out(c)  d'|
\
        HERE DISP,          \ resolve jr afxFrame1       0 7
\ afxFrame1:
        bit      6|     e|          \ decide noise change
        jrf     z'|  HOLDPLACE      \ afxFrame3          0 7 3
\
        ld      a'|  (hl)|          \ legge il valore del rumore
        subn         hex  020  N,
        jrf    cy'|  HOLDPLACE      \ afxFrame2          0 7 3 2
        ld      h'|  a|
        ldn     b'|  hex  0FF  N,
        ld      c'|  b|             \ bc : FFFF, the longest time
        jr           HOLDPLACE      \ afxFrame6          0 7 3 2 6
\
  SWAP  HERE DISP,          \ resolve jr afxFrame2       0 7 3 6
\ afxFrame2:
        incx    hl|
        ld()a   afxNseMix  AA,       \ periodo del rumore sul noise-mixer
  SWAP  HERE DISP,          \ resolve jr afxFrame3       0 7 6
\ afxFrame3:
        pop     bc|                 \ ripristina il valore del ciclo in B
        push    bc|
        inc     b'|                 \ numero di turni per i flag T e N
\
        ldn     a'|  binary 01101111  N,   \ mask for T and N

\ afxFrame4:
  HERE  rrc      e|                                    \ 0 7 6 4
        rrca
        djnz    BACK,    \ afxFrame4                   \ 0 7 6

        ld      d'|  a|

        ldx     bc|  afxNseMix 1+  NN,
        lda(x)  bc|
        xora     e|
        anda     d|
        xora     e|
        ld(x)a  bc|

\ afxFrame5:
  HERE  ld      c'|  (ix+  2  )|    \ aumenta il timer di 1
        ld      b'|  (ix+  3  )|
        incx    bc|
   SWAP  HERE DISP,         \ resolve jr afxFrame6      0 7
\ afxFrame6:
        ld(ix+  2  )'|  c|
        ld(ix+  3  )'|  b|

        ld(ix+  0  )'|  l|           \ salva l'indirizzo modificato
        ld(ix+  1  )'|  h|
        HERE DISP,          \ resolve jr afxFrame7      0
\ afxFrame7:
        ldx     bc|  4  NN,
        addix   bc|

        pop     bc|
        djnz    BACK,       \ afxFrame0
 
        ldx     hl|   HEX  FFBF  NN,

        
        ldx()   de|   afxNseMix  AA,
        ldn     a'|   6   N,
        ld      b'|   h|        \ bc : FFFD
        out(c)  a'|
        ld      b'|   l|        \ bc : BFFD
        out(c)  e'|
        inc     a'|
        ld      b'|   h|        \ bc : FFFD
        out(c)  a'|
        ld      b'|   l|        \ bc : BFFD
        out(c)  a'|
 
        pop     bc|
        pop     ix|
        jpix
C;
\ end of AFXFRAME

 DECIMAL
 
\ determina l'indirizzo a dell'effetto n
CODE AFXADDR ( n -- a )
        pop     hl|
    	addhl   hl|
        ldx()   de|  afxBnkAdr @ AA,
    	addhl   de|
        ld      e'| (hl)|    	
        incx    hl|
        ld      d'| (hl)|    	
        addhl   de|
        push    hl|
        jpix
 
 
\ Lancio di un effetto su un canale libero. In assenza di      ;
\ i canali liberi sono selezionati per il suono più lungo.     ;

CODE AFXPLAY ( a -- )
        pop     hl|

        push    ix|
        push    bc|

        ldx     de| 0 NN,   \  in DE il tempo più lungo durante la ricerca
        
        ldx     hl| afxChDesc AA, \ descrittore 3 canali
        ldn     b'| 3 N,

\ afxPlay0
        incx    hl|
        incx    hl|
        ld      a'| (hl)|   \ confronta il tempo del canale con il più grande
        incx    hl|
        cpa     e|    
        jrf     cy'| HOLDPLACE \afxPlay1       ; salta se e > (hl)
        ld      c'| a|
        ld      a'| (hl)|      
        cpa     d|                \ salta se anche e > (hl)
        jrf     cy'| HOLDPLACE \ afxPlay1
        ld      e'| c|                \ ricorda il tempo più lungo in DE
        ld      d'! a|
        push    hl|                \ salva l'indirizzo del canale+3 in IX
        pop     ix|

        HERE DISP,
        HERE DISP,
\ afxPlay1
        inc     hl|
        djnz    BACK, \ afxPlay0

        pop     de|          \ riprendiamo l'indirizzo dell'effetto dallo stack
        ld(ix+  -3 )| e|            \ entra nel descrittore del canale
        ld(ix+  -2 )| d|     
        ld(ix+  -1 )| b|            \ azzerando il tempo del suono ( B è zero )
        ld(ix+  -0 )| b|

        pop     bc| 
        push    ix|
        next \ ret 
 
 
