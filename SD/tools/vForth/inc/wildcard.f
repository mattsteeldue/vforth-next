\
\ wildcard.f
\
.( WILDCARD )
\
\ Parses the next word in the input stream as a DOS-style wildcard pattern
\ (* / ?) and keeps it ready, null-terminated, as the "a2" argument of the
\ core word F_READDIR: NextZXOS itself filters entries, because F_OPENDIR
\ opens the directory with esx_mode_use_wildcards, so no Forth-side
\ WILDCARD? matching is needed on that path anymore.
\
\ Independent of DIR (lib/dir.f): DIR keeps parsing only the path that
\ follows it in the input stream, exactly as today. WILDCARD-SPEC defaults
\ to "*.*" (match all) until WILDCARD is called; call it separately, anywhere
\ earlier on the same input line, to change the pending pattern:
\
\     WILDCARD *.F  DIR MYDIR
\
\ STICKY BY DESIGN: the pattern is not scoped to that one DIR call -- it
\ stays in effect for every later DIR, on any line, until WILDCARD is
\ called again. Reset to match-all with a bare WILDCARD (no following
\ word):
\
\     WILDCARD

BASE @ DECIMAL

CREATE WILDCARD-ALL ," *.*"
CREATE WILDCARD-SPEC  32 ALLOT      \ null-terminated pattern buffer

: WILDCARD-DEFAULT ( -- )
    WILDCARD-ALL COUNT 1+
    WILDCARD-SPEC SWAP CMOVE
;

\ initialization for WILDCARD-SPEC
WILDCARD-SPEC 32 BLANK              
WILDCARD-DEFAULT

: WILDCARD  ( -- )
    WILDCARD-SPEC 32 BLANK       \      -- useful for .PAD
    BL WORD COUNT >R             \ a    R: n
    WILDCARD-SPEC R@ CMOVE       \  
    0 WILDCARD-SPEC R> + C!      \      -- terminate at WILDCARD-SPEC+n
    WILDCARD-SPEC C@ 0= IF
        WILDCARD-DEFAULT
    THEN
;


BASE !
