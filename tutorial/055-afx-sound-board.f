\
\ 055-afx-sound-board.f
\ Background AFX sound: fire-and-forget effects while the keyboard stays live.
\
\ Tutorial 050 introduced the .afx format and the AFXFRAME machine-code
\ player; tutorial 063 showed how LOAD2BLOCK packs one .afx file per block.
\ This tutorial puts the two together with a small sample of the effects
\ shipped in tutorial/afx/ and demonstrates the whole point of
\ interrupt-driven sound: once an effect is started it plays entirely in
\ the BACKGROUND.  The foreground program -- or you, at the ok prompt --
\ keeps running, and the keyboard stays fully interactive while up to six
\ voices decay on the AY chips.
\
\ Reference: sec.7.4; see also tutorials 034, 049, 050, 063
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   055 TUTORIAL
\ To unload and reload interactively:
\   SFX-OFF NEWTASK 055 TUTORIAL     ( SFX-OFF first -- see section 7! )
\

MARKER NEWTASK

CR
.( --- Tutorial 055: AFX sound board loaded.  ) CR
.(     Type SFX-OFF NEWTASK to unload.        ) CR

NEEDS AY
NEEDS INTERRUPTS
NEEDS AFXFRAME
NEEDS LOAD2BLOCK
NEEDS PAD"
NEEDS .PAD
NEEDS [']

\ ===========================================================================
\ 1. Why background sound
\ ===========================================================================
\
\ Everything played so far was blocking: BEEP (tutorial 033) sits in a
\ timed loop until the note ends, and AFXPLAY (tutorial 050) loops until
\ the effect data runs out.  A game cannot afford that -- when the player
\ shoots, the game needs the "pew" to start NOW and the game loop to carry
\ on in the same instant.
\
\ The trick is the 50 Hz interrupt (tutorial 049).  AFXFRAME, installed as
\ the ISR word, advances every active voice by exactly one .afx frame per
\ video frame and feeds the AY registers.  "Playing a sound" then reduces
\ to storing a pointer into a descriptor table -- two machine instructions
\ worth of work -- and the interrupt does everything else, invisibly,
\ whatever the foreground is doing.

\ ===========================================================================
\ 2. The sample bank: six effects from tutorial/afx/
\ ===========================================================================
\
\ tutorial/afx/zxgames/ ships 94 classic ZX game effects (see also the
\ test/, zxmsxdemo/ and streetsofrage_2/ folders).  We pick six of the
\ longer ones -- different games, different characters -- and pack them
\ one per block, exactly as tutorial 063 taught.  Blocks 4402-4407 are
\ the conventional AFX sample area (tutorial/afx/zxgames.f uses
\ 4402-4495), so they are safe to overwrite.
\
\ Why six?  vForth keeps exactly six block BUFFERs in RAM, and the player
\ reads effect data straight out of them -- see the caveat in section 7.

4402 CONSTANT SFX-BANK      \ first block of the six-effect bank

PAD" tutorial/afx/zxgames/wizball_2.afx"       4402 LOAD2BLOCK  .PAD CR
PAD" tutorial/afx/zxgames/cybernoid_9.afx"     4403 LOAD2BLOCK  .PAD CR
PAD" tutorial/afx/zxgames/netherworld_9.afx"   4404 LOAD2BLOCK  .PAD CR
PAD" tutorial/afx/zxgames/arcanoid2_3.afx"     4405 LOAD2BLOCK  .PAD CR
PAD" tutorial/afx/zxgames/captainfizz_2.afx"   4406 LOAD2BLOCK  .PAD CR
PAD" tutorial/afx/zxgames/exolon_5.afx"        4407 LOAD2BLOCK  .PAD CR

\ ===========================================================================
\ 3. Voices: starting an effect is just a store
\ ===========================================================================
\
\ AFX-CH-DESC (from lib/AFXFRAME.f, tutorial 050) holds one 4-byte
\ descriptor per voice -- 9 voices in all, 3 channels on each of the
\ 3 AY chips; this tutorial uses the first six:
\
\   +0 (2 bytes) : current position in the .afx data
\                  (high byte $00 = voice free/stopped)
\   +2 (2 bytes) : frame timer
\
\ To start an effect: point the descriptor at the data and zero the
\ timer.  That is the entire cost of "playing a sound".

: SFX-START   ( blk voice -- )
    2* 2* >R              \ blk           R: descriptor offset
    BLOCK C/L +           \ a             payload starts after the label
    0 SWAP                \ 0 a           timer=0, position=a
    AFX-CH-DESC R> +      \ 0 a desc
    2! ;                  \               position at +0, timer at +2

: FIRE   ( n -- )         \ n = 0..5: start bank effect n on voice n
    DUP SFX-BANK +        \ n blk
    SWAP                  \ blk n
    SFX-START ;

\ ===========================================================================
\ 4. Switching the background player on and off
\ ===========================================================================
\
\ Inside a definition the xt must be compiled with ['] -- never ' (tick),
\ which in vForth parses at RUN time.  See tutorial 049, section 2.

: SFX-ON   ( -- )
    AYSETUP               \ silence + enable all three AY's (tut 034)
    ISR-OFF
    ['] AFXFRAME ISR-XT !
    ISR-ON ;

: SFX-OFF   ( -- )
    ISR-OFF
    ['] NOOP ISR-XT !
    3 AYSELECT SHH        \ hush every chip: a stopped ISR leaves the
    2 AYSELECT SHH        \ AY registers frozen mid-sound otherwise
    1 AYSELECT SHH ;

\ ===========================================================================
\ 5. Fire and forget at the ok prompt
\ ===========================================================================
\
\ Try this, one line at a time, and notice that the ok prompt comes back
\ IMMEDIATELY after each FIRE, while the sound is still going:
\
\   SFX-ON
\   0 FIRE                \ => ok  (the sweep keeps playing behind you)
\   1 2 + .               \ => 3   (computed while the sound decays)
\   1 FIRE 2 FIRE         \ two more voices join the first
\   SFX-OFF
\
\ Nothing waits.  FIRE only stores a pointer; the interrupt feeds the AY
\ one .afx frame every 1/50 s until the end marker ($D0,$20) frees the
\ voice.  Everything you type is serviced in the foreground as usual.

\ ===========================================================================
\ 6. The sound board: keyboard interaction while voices play
\ ===========================================================================
\
\ KEY blocks -- but it blocks in an EI/HALT loop, so the 50 Hz interrupt
\ keeps firing and playback never hiccups while vForth waits for your
\ keystroke.  Mash 1-6 quickly: up to six effects overlap, each on its
\ own voice.  Re-firing a key restarts that voice from the top.

: SOUND-BOARD   ( -- )
    SFX-ON
    CR ." SOUND BOARD -- keys 1-6 fire, any other key quits" CR
    BEGIN
        KEY [CHAR] 1 -        \ n          key '1'..'6' -> 0..5
        DUP 0< OVER 5 > OR 0= \ n f        inside the bank?
    WHILE                     \ n
        DUP [CHAR] 1 + EMIT SPACE
        FIRE
    REPEAT
    DROP
    SFX-OFF ;

\ Run it from the prompt:
\   SOUND-BOARD

\ ===========================================================================
\ 7. Caveats
\ ===========================================================================
\
\ (a) ALWAYS SFX-OFF before NEWTASK (or any FORGET).  The interrupt calls
\     the AFXFRAME machine code 50 times a second; forgetting it while
\     ISR-ON leaves ISR-XT pointing at recycled dictionary space and the
\     machine crashes at the very next frame.  No error is raised first.
\
\ (b) Six voices, six BUFFERs.  Each descriptor points INTO a block
\     buffer, and vForth has exactly six of them.  Touching other blocks
\     (LIST, LOAD, EDIT...) while voices play can recycle a buffer that
\     a voice is still reading -- the player then feeds garbage to the
\     AY.  Keep the bank within six blocks and avoid heavy block traffic
\     while sounds are running.
\
\ (c) Loading this tutorial overwrites blocks 4402-4407 (LOAD2BLOCK marks
\     them dirty; they reach !Blocks-64.bin when the buffers recycle).
\     That range is the same one tutorial/afx/zxgames.f fills, so nothing
\     of value is lost.

\ ===========================================================================
\ 8. Going further
\ ===========================================================================
\
\   INCLUDE tutorial/afx/zxgames.f   \ load all 94 effects (blocks 4402+)
\   INCLUDE tutorial/afx/aydemo.f    \ the author's six-voice jukebox
\
\ Tutorial 050 documents the .afx frame encoding and the AFXFRAME code;
\ tutorial 063 documents LOAD2BLOCK and blocks-as-assets.

\ ===========================================================================
\ 9. Tests (geometry only -- the sound itself needs ears)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  SFX-BANK             ->  4402  }T
\ T{  SFX-BANK 2 /         ->  2201  }T   \ first half of Screen 2201
\ T{  AFX-CH-DESC 0=       ->  0     }T
\ Listen-test: SOUND-BOARD, press 1..6, any other key quits silence.
