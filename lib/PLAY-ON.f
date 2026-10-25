\
\ PLAY-ON.f
\
\ PLAY in the background: the music strings of lib/PLAY.f played by the
\ frame interrupt while the program goes on.
\
\   a1 n1 ... ak nk k PLAY-ON   \ start, k strings as for PLAY
\   PLAYING?  ( -- f )          \ true until the music ends
\   PLAY-OFF                    \ stop it, chips quiet, IM 1 back
\   PLAY-ERROR  ( -- n )        \ the error that stopped it, 0 if none
\
\ The time is kept in frames, 50 or 60 a second (NextReg 5, bit 2), not
\ with MS: it does not depend on the CPU speed. Every frame 2T is added
\ to an accumulator and a unit (1/96 of a semibreve) goes by every 5f of
\ it, f = 50 or 60; what is left stays there, so there is no drift. A
\ note starts on a frame, up to one frame (20 ms at 50 Hz) late.
\
\ The strings are copied into PL-TEXT (1024 bytes) at the start: the
\ interrupt cannot see the heap, where S" leaves them, because it may
\ come while the MMU7 window maps another page.
\
\ Errors: the strings are checked as they are read, so only the first
\ notes are checked by PLAY-ON itself (the usual messages, see PLAY, plus
\ -18 when the strings do not fit PL-TEXT). An error found later in the
\ interrupt cannot be reported: the music halts, and PLAY-ERROR gives
\ its number. BREAK does not stop it: PLAY-OFF does.
\
\ The hook is the one ISR-XT cell of lib/INTERRUPTS.f. PLAY-ON keeps the
\ xt it finds there and calls it after its own step: so a player already
\ installed, such as AFXFRAME, goes on, and its effects come after the
\ music in the same frame. Install it before PLAY-ON, not while the
\ music plays, or PLAY-ON loses the hook. Known conflicts with AFXFRAME,
\ which rewrites registers 6 and 7 and the stereo bits of the three
\ chips at every frame: see planners/PLAY-PLAN.md, section 5.3.
\
\ NO-PLAY-ON stops the music and removes this module; NO-PLAY (of
\ lib/PLAY.f) removes both, but call PLAY-OFF before it. A program that
\ writes the AY itself while the music plays can be interrupted between
\ the register and the data of an AY!.
\
.( PLAY-ON )

NEEDS PLAY
NEEDS INTERRUPTS
NEEDS [']

BASE @

MARKER FORGET-PLAY-ON

DECIMAL

1024 CONSTANT PL-ROOM
CREATE PL-TEXT  PL-ROOM ALLOT   \ the strings, copied by PLAY-ON

VARIABLE PL-RATE                \ 5 times the frames in a second
VARIABLE PL-ACCUM               \ in 1/PL-RATE of a unit
VARIABLE PL-OLD-XT              \ what ISR-XT held before PLAY-ON

: PL-COPY  ( -- )               \ the strings into PL-TEXT
    PL-TEXT  PL-COUNT @ 0 DO
        I PL-CHANNEL
        PL-TEXT PL-ROOM +  OVER PL-LEN @ +  U< -18 PL-?ERROR
        PL-ADDR @ OVER PL-LEN @ CMOVE
        DUP PL-ADDR !  PL-LEN @ +
    LOOP
    DROP ;

: PL-OVER?  ( -- f )            \ nothing left to play
    PL-SHORTEST 0=  PL-HALT @ OR ;

: PL-DONE  ( -- )               \ in the interrupt: the music is over
    0 PL-BG !  PL-SILENCE  PL-OLD-XT @ ISR-XT ! ;

: PL-TICK  ( -- )               \ one frame
    PL-ACCUM @  PL-TEMPO @ 2* +  PL-RATE @ /MOD  SWAP PL-ACCUM !
    PL-COUNT @ 0 DO
        I PL-CHANNEL
        PL-ON @ IF  DUP NEGATE PL-LEFT +!  PL-STEP  THEN
    LOOP
    DROP
    PL-OVER? IF  PL-DONE  THEN ;

: PL-ISR  ( -- )                \ the word in ISR-XT while it plays
    PL-BG @ IF  PL-TICK  THEN
    PL-OLD-XT @ EXECUTE ;

: PLAYING?  ( -- f )  PL-BG @ ;

: PLAY-ERROR  ( -- n )  PL-ERR @ ;

: PLAY-OFF  ( -- )
    PL-BG @ IF
        ISR-DI  0 PL-BG !  PL-OLD-XT @ ISR-XT !  ISR-EI
        PL-SILENCE
    THEN
    ISR-XT @ ['] NOOP = IF  ISR-OFF  THEN ;

: PLAY-ON  ( a1 n1 ... ak nk k -- )
    PLAY-OFF  PL-INIT  PL-COPY
    5 REG@ 4 AND IF  300  ELSE  250  THEN  PL-RATE !  0 PL-ACCUM !
    PL-COUNT @ 0 DO  I PL-CHANNEL  PL-STEP  LOOP
    PL-OVER? IF
        PL-SILENCE
    ELSE
        ISR-XT @ PL-OLD-XT !  -1 PL-BG !
        ISR-DI  ['] PL-ISR ISR-XT !  ISR-ON
    THEN ;

' PLAY-OFF PL-STOP !            \ PLAY stops the background first

: NO-PLAY-ON  ( -- )
    PLAY-OFF  ['] NOOP PL-STOP !  FORGET-PLAY-ON ;

BASE !
