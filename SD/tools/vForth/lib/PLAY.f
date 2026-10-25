\
\ PLAY.f
\
\ NextBASIC's PLAY on the AY chips of the Next: the music strings of the
\ manual (Chapter 18, pp. 147-153), up to nine channels.
\
\   a1 n1 ... ak nk k PLAY      \ k strings, 1 to 9, one per channel
\   PLAY" O4cegC"               \ one literal string, channel A of AY1
\
\ Strings 1-3 drive channels A, B, C of AY1, strings 4-6 those of AY2,
\ strings 7-9 those of AY3 (Turbosound is enabled when there are more
\ than three). An empty string leaves its channel silent. PLAY waits until
\ the music ends, as in BASIC; H in any string and the BREAK key stop it.
\ To play while the program goes on: NEEDS PLAY-ON (lib/PLAY-ON.f).
\
\ The language is NextBASIC's: notes c..b and C..B, # sharp, $ flat,
\ O0-O8 octave, 1-12 durations, _ tie, & rest, N separator, V0-V15
\ volume, U envelope on, W0-W7 envelope shape, X0-X65535 envelope
\ period, T60-T240 tempo (first string only), ( ) repeats, ! comments !,
\ H halt, M0-M63 mixer, L R S stereo. Y and Z (MIDI) are read and
\ ignored. Spaces are ignored.
\
\ Choices where the manual says nothing:
\ - O5 c is middle C (MIDI note 60); a note below the lowest period the
\   AY has (about 27 Hz, in O0 and O1) is played at that lowest period;
\ - on a channel whose noise is on (M), a note also sets the noise
\   period: the tone period, limited to 31;
\ - with U, every note restarts the envelope;
\ - a string that repeats from its start with no note or rest since the
\   last time (e.g. "V5))") ends there, instead of looping for ever.
\
\ The strings must stay readable while they play: in the dictionary, or
\ in the heap only if they lie in the same 8K page (an S" typed at the
\ prompt is decoded in the window at $E000 and the next one may map
\ another page).
\
\ Errors (no message reserved): #19 Syntax error, a character outside
\ the language or more than five ( open; -24 Invalid numeric argument, a
\ number out of its range; #15 [ BREAK ] was pressed. The chips are
\ silenced first.
\
.( PLAY )

NEEDS AY
NEEDS MS
NEEDS S"

BASE @

MARKER NO-PLAY

DECIMAL

\ ____________________________________________________________________
\
\ The nine channels. Each has a record of fields; a field word gives the
\ address of the field in the record of the current channel, PL-CH.

VARIABLE PL-CH             \ record of the current channel
VARIABLE PL-CH#            \ its number, 0 to 8

: PL-FIELD  ( n -- n+2 )  CREATE DUP , 2+  DOES> @ PL-CH @ + ;

0
PL-FIELD PL-ADDR           \ address of the string
PL-FIELD PL-LEN            \ its length
PL-FIELD PL-POS            \ offset of the next character
PL-FIELD PL-LEFT           \ units still to play of the current note
PL-FIELD PL-ON             \ true until the string is over
PL-FIELD PL-OCT            \ O, 0 to 8
PL-FIELD PL-DUR            \ length of a note, in units
PL-FIELD PL-TIE            \ units tied in front of the next note, by _
PL-FIELD PL-TRIP           \ notes still to play as triplets
PL-FIELD PL-SAVE           \ the length to go back to after the triplets
PL-FIELD PL-VOL            \ V, 0 to 15
PL-FIELD PL-ENV            \ true after U, false after V
PL-FIELD PL-SHAPE          \ W, as a shape of the AY envelope
PL-FIELD PL-ACC            \ 1 after #, -1 after $
PL-FIELD PL-DEPTH          \ number of ( still open
PL-FIELD PL-HEARD          \ a note or a rest since the start, or the last
                           \ repeat from the start
PL-FIELD PL-STACK          \ five pairs: offset after the (, repeated flag
18 +
CONSTANT PL-SIZE

CREATE PL-CHANNELS  9 PL-SIZE * ALLOT

: PL-CHANNEL  ( n -- )  DUP PL-CH# !  PL-SIZE * PL-CHANNELS + PL-CH ! ;

VARIABLE PL-COUNT       \ number of strings
VARIABLE PL-TEMPO       \ T, crotchets per minute
VARIABLE PL-HALT        \ true after H
VARIABLE PL-REM         \ remainder of the last division to milliseconds
VARIABLE PL-BG          \ true while lib/PLAY-ON.f plays in the background
VARIABLE PL-ERR         \ the error that stopped it, 0 if none
VARIABLE PL-STOP        \ xt run before PLAY: PLAY-OFF once PLAY-ON is loaded
' NOOP PL-STOP !
CREATE PL-STEREO 3 ALLOT    \ per chip: $60 both sides, $40 L, $20 R
CREATE PL-MIXER  3 ALLOT    \ per chip: the last M

\ ____________________________________________________________________
\
\ The chips. A chip is selected together with its stereo bits: port
\ $FFFD takes 1, left, right, 1 1 1 and the chip, 11 for AY1 to 01 for
\ AY3 (lib/AY.f).

: PL-CHIP   ( -- n )  PL-CH# @ 3 / ;       \ 0 to 2, AY1 to AY3
: PL-VOICE  ( -- n )  PL-CH# @ 3 MOD ;     \ 0 to 2, channel A to C
: PL-CHIPS  ( -- n )  PL-COUNT @ 2+ 3 / ;

: PL-PSG  ( chip -- )
    DUP PL-STEREO + C@  $9C OR  SWAP 3 SWAP - OR
    AY-register-port P! ;

: PL-PSG!  ( b reg -- )  PL-CHIP PL-PSG  AY! ;

: PL-SILENCE  ( -- )        \ all chips quiet, stereo and AY back
    PL-CHIPS 0 ?DO
        $60 I PL-STEREO + C!  I PL-PSG
        SHH  0 8 AY!  0 9 AY!  0 10 AY!
    LOOP
    AY @ ?DUP 0= IF  1  THEN  AYSELECT ;

\ In the background there is no one to tell: the error is kept in PL-ERR
\ and the music halts; the caller goes on, so it must not harm anything.

: PL-?ERROR  ( f n -- )
    PL-BG @ IF
        SWAP IF  PL-ERR !  -1 PL-HALT !  ELSE  DROP  THEN
    ELSE
        OVER IF  PL-SILENCE  THEN  ?ERROR
    THEN ;

: PL-BREAK  ( -- )  PL-BG @ 0= IF  ?TERMINAL 15 PL-?ERROR  THEN ;

\ ____________________________________________________________________
\
\ Reading a string.

: PL-MORE?  ( -- f )  PL-POS @ PL-LEN @ < ;
: PL-PEEK   ( -- c )  PL-ADDR @ PL-POS @ + C@ ;
: PL-CHAR   ( -- c )  PL-PEEK  1 PL-POS +! ;

: PL-DIGIT?  ( -- f )
    PL-MORE? IF  PL-PEEK [CHAR] 0 - 10 U<  ELSE  0  THEN ;

: PL-NUMBER  ( -- u )
    0  BEGIN  PL-DIGIT?  WHILE  10 *  PL-CHAR [CHAR] 0 - +  REPEAT ;

: PL-ARG  ( max -- u )  PL-NUMBER  TUCK U< -24 PL-?ERROR ;

\ ____________________________________________________________________
\
\ Pitch. A note is a semitone s, 60 for middle C; its period comes from
\ one octave of periods, 1750000 / (16 * f) for the MIDI notes 0 to 11,
\ shifted right once per octave, rounded.

CREATE PL-PERIODS
    13378 , 12627 , 11918 , 11249 , 10618 , 10022 ,
     9460 ,  8929 ,  8428 ,  7955 ,  7508 ,  7087 ,

: PL-PERIOD  ( s -- p )
    0 MAX  12 /MOD  SWAP CELLS PL-PERIODS + @  SWAP
    ?DUP IF  1 OVER 1- LSHIFT  ROT +  SWAP RSHIFT  THEN
    4095 MIN ;

: PL-VOLUME  ( v -- )  PL-VOICE 8 + PL-PSG! ;

: PL-NOISE?  ( -- f )  PL-CHIP PL-MIXER + C@  8 PL-VOICE LSHIFT AND ;

: PL-SOUND  ( s -- )
    PL-PERIOD  DUP  PL-CHIP PL-PSG  PL-VOICE 2* AY!!
    PL-NOISE? IF  31 MIN  6 PL-PSG!  ELSE  DROP  THEN
    PL-ENV @ IF  16 PL-VOLUME  PL-SHAPE @ 13 PL-PSG!
    ELSE  PL-VOL @ PL-VOLUME
    THEN ;

\ ____________________________________________________________________
\
\ Time. A unit is 1/96 of a semibreve, so that the triplets are whole
\ numbers too: a crotchet is 24 units, and at T beats per minute a unit
\ lasts 2500/T milliseconds.

CREATE PL-UNITS
    6 C,  9 C,  12 C,  18 C,  24 C,  36 C,  48 C,  72 C,  96 C,
    4 C,  8 C,  16 C,

: PL-LENGTH  ( -- u )       \ the length of the next note or rest
    PL-DUR @  PL-TIE @ +  0 PL-TIE !
    PL-TRIP @ IF
        -1 PL-TRIP +!
        PL-TRIP @ 0= IF  PL-SAVE @ PL-DUR !  THEN
    THEN ;

: PL-DURATION  ( -- )       \ 1 to 12, perhaps followed by _
    12 PL-ARG  DUP 0= -24 PL-?ERROR
    DUP 1- PL-UNITS + C@  SWAP 9 > IF
        PL-TRIP @ 0= IF  PL-DUR @ PL-SAVE !  THEN
        3 PL-TRIP !
    ELSE
        0 PL-TRIP !
    THEN
    PL-DUR !
    PL-MORE? IF  PL-PEEK [CHAR] _ = IF
        1 PL-POS +!  PL-DUR @ PL-TIE +!
    THEN  THEN ;

\ ____________________________________________________________________
\
\ Notes and rests.

CREATE PL-STEPS  9 C, 11 C, 0 C, 2 C, 4 C, 5 C, 7 C,   \ a b c d e f g

: PL-NOTE  ( c -- )
    DUP [CHAR] a < IF  [CHAR] A - 12  ELSE  [CHAR] a - 0  THEN
    SWAP PL-STEPS + C@ +
    PL-OCT @ 12 * +  PL-ACC @ +  0 PL-ACC !
    PL-SOUND  PL-LENGTH PL-LEFT +!  -1 PL-HEARD ! ;

: PL-REST  ( -- )
    0 PL-VOLUME  0 PL-ACC !  PL-LENGTH PL-LEFT +!  -1 PL-HEARD ! ;

\ PL-LEFT is added to, not set: in the background a frame may take a
\ note past its end, and the next note is that much shorter.

: PL-END  ( -- )  0 PL-ON !  0 PL-VOLUME ;

\ ____________________________________________________________________
\
\ Repeats. ( pushes the offset after it; the first ) jumps back there,
\ the second goes on. A ) with no ( open repeats from the start of the
\ string, once: so )) at the end repeats for ever, until H or BREAK.

: PL-ENTRY  ( -- a )  PL-DEPTH @ 2* CELLS PL-STACK + ;

: PL-OPEN  ( -- )
    PL-DEPTH @ 4 >  DUP 19 PL-?ERROR
    0= IF  PL-POS @ PL-ENTRY !  0 PL-ENTRY CELL+ !  1 PL-DEPTH +!  THEN ;

: PL-CLOSE  ( -- )
    PL-BREAK
    PL-DEPTH @ 0= IF
        PL-HEARD @ IF
            0 PL-HEARD !
            0 PL-ENTRY !  1 PL-ENTRY CELL+ !  1 PL-DEPTH +!  0 PL-POS !
        ELSE
            PL-END
        THEN
    ELSE
        -1 PL-DEPTH +!
        PL-ENTRY CELL+ @ 0= IF
            1 PL-ENTRY CELL+ !  PL-ENTRY @ PL-POS !  1 PL-DEPTH +!
        THEN
    THEN ;

\ ____________________________________________________________________
\
\ The other commands.

CREATE PL-SHAPES  0 C, 4 C, 11 C, 13 C, 8 C, 12 C, 14 C, 10 C,

: PL-SHARP    ( -- )   1 PL-ACC ! ;
: PL-FLAT     ( -- )  -1 PL-ACC ! ;
: PL-OCTAVE   ( -- )   8 PL-ARG PL-OCT ! ;
: PL-V        ( -- )  15 PL-ARG PL-VOL !  0 PL-ENV ! ;
: PL-U        ( -- )  -1 PL-ENV ! ;
: PL-W        ( -- )   7 PL-ARG PL-SHAPES + C@ PL-SHAPE ! ;
: PL-X        ( -- )  PL-NUMBER  PL-CHIP PL-PSG  11 AY!! ;
: PL-H        ( -- )  -1 PL-HALT ! ;
: PL-MIDI     ( -- )  PL-NUMBER DROP ;
: PL-L        ( -- )  $40 PL-CHIP PL-STEREO + C!  PL-CHIP PL-PSG ;
: PL-R        ( -- )  $20 PL-CHIP PL-STEREO + C!  PL-CHIP PL-PSG ;
: PL-S        ( -- )  $60 PL-CHIP PL-STEREO + C!  PL-CHIP PL-PSG ;

: PL-T  ( -- )              \ only the first string sets the tempo
    240 PL-ARG  PL-CH# @ IF  DROP EXIT  THEN
    DUP 60 < -24 PL-?ERROR  PL-TEMPO ! ;

: PL-M  ( -- )              \ in register 7 a 0 switches on
    63 PL-ARG  DUP PL-CHIP PL-MIXER + C!  63 XOR 7 PL-PSG! ;

: PL-COMMENT  ( -- )        \ up to the next ! or to the end
    BEGIN  PL-MORE? IF  PL-CHAR [CHAR] ! -  ELSE  0  THEN  0=  UNTIL ;

CREATE PL-COMMANDS
    BL     C, ' NOOP ,       CHAR # C, ' PL-SHARP ,
    CHAR $ C, ' PL-FLAT ,    CHAR & C, ' PL-REST ,
    CHAR ( C, ' PL-OPEN ,    CHAR ) C, ' PL-CLOSE ,
    CHAR ! C, ' PL-COMMENT , CHAR N C, ' NOOP ,
    CHAR O C, ' PL-OCTAVE ,  CHAR V C, ' PL-V ,
    CHAR U C, ' PL-U ,       CHAR W C, ' PL-W ,
    CHAR X C, ' PL-X ,       CHAR T C, ' PL-T ,
    CHAR H C, ' PL-H ,       CHAR M C, ' PL-M ,
    CHAR L C, ' PL-L ,       CHAR R C, ' PL-R ,
    CHAR S C, ' PL-S ,       CHAR Y C, ' PL-MIDI ,
    CHAR Z C, ' PL-MIDI ,    0 C,

: PL-COMMAND  ( c -- )
    DUP [CHAR] 0 - 10 U< IF  DROP  -1 PL-POS +!  PL-DURATION  EXIT  THEN
    DUP [CHAR] a - 7 U<  OVER [CHAR] A - 7 U<  OR IF  PL-NOTE  EXIT  THEN
    PL-COMMANDS
    BEGIN  DUP C@  WHILE
        2DUP C@ = IF  NIP 1+ @ EXECUTE  EXIT  THEN
        3 +
    REPEAT
    2DROP  -1 19 PL-?ERROR ;

\ ____________________________________________________________________
\
\ Playing.

: PL-STEP  ( -- )           \ read the string up to a note or a rest
    BEGIN  PL-LEFT @ 1 <  PL-ON @ AND  PL-HALT @ 0= AND  WHILE
        PL-MORE? IF  PL-CHAR PL-COMMAND  ELSE  PL-END  THEN
    REPEAT ;

: PL-SHORTEST  ( -- u )     \ the shortest note playing, 0 if none
    0  PL-COUNT @ 0 DO
        I PL-CHANNEL
        PL-ON @ IF  PL-LEFT @  OVER IF  MIN  ELSE  NIP  THEN  THEN
    LOOP ;

: PL-WAIT  ( u -- )         \ let u units go by
    PL-COUNT @ 0 DO
        I PL-CHANNEL  PL-ON @ IF  DUP NEGATE PL-LEFT +!  THEN
    LOOP
    2500 UM*  PL-REM @ 0 D+  PL-TEMPO @ UM/MOD  SWAP PL-REM !
    BEGIN  PL-BREAK  DUP 100 >  WHILE  100 MS  100 -  REPEAT
    MS ;

: PL-INIT  ( a1 n1 ... ak nk k -- )
    0 PL-BG !  0 PL-ERR !
    DUP 1- 9 U< 0= -24 PL-?ERROR
    DUP PL-COUNT !  120 PL-TEMPO !  0 PL-HALT !  0 PL-REM !
    3 > IF  ENABLE-TURBOSOUND  THEN
    0 PL-COUNT @ 1- DO
        I PL-CHANNEL  PL-CH @ PL-SIZE ERASE
        PL-LEN !  PL-ADDR !  PL-LEN @ 0= 0= PL-ON !
        5 PL-OCT !  24 PL-DUR !  15 PL-VOL !
    -1 +LOOP
    PL-CHIPS 0 DO
        $60 I PL-STEREO + C!  7 I PL-MIXER + C!  I PL-PSG
        $38 7 AY!  0 8 AY!  0 9 AY!  0 10 AY!  -1 11 AY!!
    LOOP ;

: PLAY  ( a1 n1 ... ak nk k -- )
    PL-STOP @ EXECUTE  PL-INIT
    BEGIN
        PL-COUNT @ 0 DO  I PL-CHANNEL  PL-STEP  LOOP
        PL-SHORTEST  PL-HALT @ IF  DROP 0  THEN
        ?DUP
    WHILE
        PL-WAIT
    REPEAT
    PL-SILENCE ;

: PLAY"  ( -- )             \ PLAY" string" plays one literal string
    [COMPILE] S"
    STATE @ IF  1 [COMPILE] LITERAL  COMPILE PLAY
    ELSE  1 PLAY
    THEN
; IMMEDIATE

BASE !
