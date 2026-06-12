\
\ 050-afxframe.f
\ AY music playback with AFXFRAME and the interrupt handler.
\
\ lib/AFXFRAME.f provides a machine-code routine AFXFRAME that
\ updates all three AY-3-8910 chips once per video frame.  It is
\ designed to be called from within a Forth ISR (interrupt service
\ routine) at 50 Hz.  lib/afxplay.f provides a Forth-language
\ version of the same algorithm plus AFXPLAY, which plays a single
\ .afx effect channel from a block file while blocked in a loop.
\ Together these libraries enable per-frame AY music synchronised
\ to the display refresh.
\
\ Reference: sec.7.4
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   050 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 050 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 050: AFX frame player loaded. ) CR
.(     Type NEWTASK to unload.            ) CR

NEEDS INTERRUPTS

\ ===========================================================================
\ 1. The .afx format
\ ===========================================================================
\
\ An .afx file is a compact per-frame encoding of AY register changes.
\ Each frame is represented by a flags byte followed by optional data:
\
\   bits 3-0 : volume  (0-15)
\   bit  4   : disable tone  flag
\   bit  5   : change tone   flag  (followed by 2 bytes: tone period)
\   bit  6   : change noise  flag  (followed by 1 byte:  noise period)
\   bit  7   : disable noise flag
\
\ The end of an effect is marked by the two-byte sequence $D0, $20.
\
\ When bit 5 is set, two bytes of tone period follow.
\ When bit 6 is set, one byte of noise period follows.
\ When both are set, tone bytes come first, then noise byte.
\ When neither is set, the next flags byte follows immediately.

\ ===========================================================================
\ 2. AFX-CH-DESC -- channel descriptor table
\ ===========================================================================
\
\ AFXFRAME uses a 48-byte table AFX-CH-DESC (6 channels: 3 chips x
\ 2 words each):
\
\   +0 (2 bytes) : current address in effect data
\                  high byte = $00 means channel is free/stopped
\   +2 (2 bytes) : effect timer
\   +4           : next channel descriptor (repeats for 6 channels)
\
\ To start playing an effect on channel n (1-based):
\   addr   AFX-CH-DESC n 1- 4 * + !   \ set data address
\   The high byte must be non-zero for the channel to be active.
\
\ AFX-MIXER is a 6-byte array holding the mixer state for each AY.

\ ===========================================================================
\ 3. AFXFRAME (machine-code version, lib/AFXFRAME.f)
\ ===========================================================================
\
\ NEEDS AFXFRAME  or  INCLUDE lib/AFXFRAME.f
\
\   AFXFRAME ( -- )   update all 3 AY chips from AFX-CH-DESC
\
\ AFXFRAME is implemented entirely in Z80 machine code for speed.
\ It processes all 3 AY chips (each with 3 channels) in one call,
\ taking the channel pointers from AFX-CH-DESC.
\ It is designed to be called from within an ISR at 50 Hz.
\
\ The AFXFRAME machine code is assembled inline at load time using
\ vForth's CODE words and raw C, directives.

\ ===========================================================================
\ 4. AFXFRAME (Forth version, lib/afxplay.f)
\ ===========================================================================
\
\ lib/afxplay.f provides the same algorithm in Forth:
\
\   AFXFRAME ( a n -- a )   update one channel
\     a : current data pointer
\     n : channel number 1=A 2=B 3=C
\     returns the new (advanced) data pointer
\
\   AFXWORKER ( -- )   process channel 1 from afxChDesc
\
\   AFXPLAY ( -- )   play the effect stored in block 4400 in a loop
\                    until data ends or BREAK is pressed

\ ===========================================================================
\ 5. Setting up ISR-based playback with AFXFRAME (machine code)
\ ===========================================================================
\
\ To use AFXFRAME as an ISR for continuous background music:
\
\   1. Load the .afx data into memory and populate AFX-CH-DESC
\   2. ISR-OFF
\   3. ' AFXFRAME  ISR-XT !
\   4. ISR-ON
\
\ The AFXFRAME word will be called at every vertical blank (50 Hz),
\ advancing the effect data pointers and writing to the AY chips.

\ ===========================================================================
\ 6. Demo: play an effect from memory using afxplay.f
\ ===========================================================================
\
\ The Forth AFXPLAY (from lib/afxplay.f) reads effect data from
\ Forth block 4400 and plays it on channel B (2), calling ISR-SYNC
\ for frame synchronisation.
\
\ To use:
\   NEEDS INTERRUPTS
\   \ Load effect data into block 4400:
\   4400 BLOCK  <address-of-afx-data>  512 CMOVE  UPDATE
\   AYSETUP
\   AFXPLAY

\ ===========================================================================
\ 7. Demo: manual frame player using AFXFRAME (Forth version)
\ ===========================================================================

\ This demo uses the Forth AFXFRAME from afxplay.f to play a simple
\ hand-coded sequence from an array in memory.

\ A minimal 3-frame .afx sequence:
\  Frame 0: volume=12, change tone  ($20+$0C = $2C), tone=500 ($F4,$01)
\  Frame 1: volume=8,  no change    ($08)
\  Frame 2: volume=4,  no change    ($04)
\  End: $D0, $20

CREATE AFX-DATA
    HEX
    2C C,  F4 C,  01 C,   \ frame 0: volume 12, tone 500
    08 C,                  \ frame 1: volume 8
    04 C,                  \ frame 2: volume 4
    D0 C,  20 C,           \ end marker
    DECIMAL

\ ===========================================================================
\ 8. Demo: ISR-based AFXFRAME player setup
\ ===========================================================================
\
\ NEEDS AFXFRAME (from lib/AFXFRAME.f) for the machine-code version.
\
\ The following definitions show how to load and start background
\ music using ISR-based AFXFRAME.

\ Load the AFXFRAME machine-code word.
NEEDS AFXFRAME

: AFX-START  ( a -- )
    \ Install effect at address a into channel 1 of AFX-CH-DESC
    AFX-CH-DESC !         \ set data pointer for channel 1
    AYSETUP               \ silence and enable all chips
    ISR-OFF
    ' AFXFRAME ISR-XT !   \ install AFXFRAME as ISR
    ISR-ON
    ." AFX player running. BREAK to stop." CR
;

: AFX-STOP  ( -- )
    ISR-OFF
    ' NOOP ISR-XT !
    AYSETUP               \ silence all chips
;

\ ===========================================================================
\ 9. Notes on AY chip selection in AFXFRAME
\ ===========================================================================
\
\ The machine-code AFXFRAME iterates over 3 AY chips.
\ For each chip it:
\   1. Selects the chip via the AY-register-port ($FFFD) using the
\      chip-select pattern with bits 7-6=1
\   2. Processes each of the 3 channels (A, B, C) using the inner
\      Z80 assembly loop
\   3. Outputs the mixer byte (register 7) for each chip
\
\ The Forth afxplay.f version processes only one channel at a time
\ and is slower, but easier to understand and modify.
\
\ Turbosound must be enabled (see tutorial 034, ENABLE-TURBOSOUND)
\ for chips AY2 and AY3 to respond.  AYSETUP calls ENABLE-TURBOSOUND
\ and ENABLE-MONO for all three chips.

\ ===========================================================================
\ 10. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  AFX-CH-DESC 0=  ->  0   }T   \ AFX-CH-DESC is not null
\ T{  AFX-DATA C@  ->  44   }T     \ $2C = 44 decimal
