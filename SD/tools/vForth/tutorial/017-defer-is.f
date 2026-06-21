\
\ 017-defer-is.f
\ Deferred words: DEFER, IS, ACTION-OF.
\
\ A deferred word is a named slot for an execution token.  When called,
\ it executes whatever xt has been stored in it via IS.  This provides
\ late binding: the behaviour of a word can be changed at runtime
\ without recompiling any definition that uses it.
\
\ All three require NEEDS.  Loading NEEDS DEFER also loads ['] (which
\ DEFER uses internally).  Loading NEEDS IS also loads DEFER! and ['].
\
\ Typical patterns:
\
\   DEFER HOOK          \ create the hook; initially executes NOOP
\   : action1  ." A" ;
\   : action2  ." B" ;
\   ' action1  IS HOOK  \ set at the prompt (interpreter mode)
\   HOOK                \ => A
\   ' action2  IS HOOK
\   HOOK                \ => B
\
\ Inside a definition, IS compiles a runtime store:
\   : select  ( n -- )
\       0= IF  ['] action1  ELSE  ['] action2  THEN  IS HOOK ;
\
\ Starting FORTH (Brodie): Ch.9  |  vForth screens 868-876
\ Reference: sec.2.12.9
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   017 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 017 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 017: DEFER and IS loaded. ) CR
.(     Type NEWTASK to unload.        ) CR

NEEDS DEFER
NEEDS IS
NEEDS ACTION-OF


\ ===========================================================================
\ 1. Creating and using a deferred word
\ ===========================================================================
\
\ DEFER name       creates name; initial behaviour is NOOP (do nothing)
\ xt IS name       store xt in name so calling name executes xt
\ ACTION-OF name   returns the xt currently stored in name

DEFER DISPLAY-ITEM          \ initially: NOOP

: SHOW-AS-NUMBER  ( n -- )  ." Number: " . CR ;
: SHOW-AS-CHAR    ( n -- )  ." Char:   " EMIT CR ;

." Initial DISPLAY-ITEM calls NOOP (does nothing): " CR
42 DISPLAY-ITEM

' SHOW-AS-NUMBER  IS  DISPLAY-ITEM
.( After IS SHOW-AS-NUMBER: ) CR
42 DISPLAY-ITEM             \ => Number: 42

' SHOW-AS-CHAR  IS  DISPLAY-ITEM
.( After IS SHOW-AS-CHAR: ) CR
65 DISPLAY-ITEM             \ => Char: A


\ ===========================================================================
\ 2. ACTION-OF -- inspecting a deferred word
\ ===========================================================================
\
\ ACTION-OF name ( -- xt )  returns the xt currently stored.
\ Useful for saving and restoring a hook around a temporary change.

: WITH-NUMBER-DISPLAY  ( -- )
    \ Temporarily switch DISPLAY-ITEM to number mode, then restore.
    ACTION-OF DISPLAY-ITEM >R  
    ['] SHOW-AS-NUMBER  IS  DISPLAY-ITEM
    42 DISPLAY-ITEM                   \ use temporarily
    R>  IS  DISPLAY-ITEM ;            \ restore

.( Calling WITH-NUMBER-DISPLAY: ) CR
WITH-NUMBER-DISPLAY
.( DISPLAY-ITEM restored to char mode: ) CR
66 DISPLAY-ITEM             \ => Char: B


\ ===========================================================================
\ 3. IS inside a colon-definition
\ ===========================================================================
\
\ When IS appears inside : ... ; it compiles a runtime store rather
\ than executing immediately.  Use ['] to compile an xt as a literal.
\
\   : USE-NUMBERS  ( -- )  ['] SHOW-AS-NUMBER  IS DISPLAY-ITEM ;
\   : USE-CHARS    ( -- )  ['] SHOW-AS-CHAR    IS DISPLAY-ITEM ;

: USE-NUMBERS  ( -- )  ['] SHOW-AS-NUMBER  IS DISPLAY-ITEM ;
: USE-CHARS    ( -- )  ['] SHOW-AS-CHAR    IS DISPLAY-ITEM ;
CR
.( Try: USE-NUMBERS  65 DISPLAY-ITEM ) CR
.( Try: USE-CHARS    65 DISPLAY-ITEM ) CR


\ ===========================================================================
\ 4. Forward reference with DEFER
\ ===========================================================================
\
\ DEFER also solves the mutual-recursion problem: two words that each
\ call the other cannot both be defined before the other exists.
\ DEFER creates a placeholder before the actual definition exists.

DEFER ODD?             \ forward reference

: EVEN?  ( n -- f )
    DUP 0= IF DROP -1 EXIT THEN
    1- ODD? ;

: .ODD?  ( n -- f )   \ actual definition fills in the deferred slot
    DUP 0= IF DROP 0 EXIT THEN
    1- EVEN? ;

' .ODD?  IS ODD?       \ complete the forward reference

.( Try: 4 EVEN?  .  ) CR    \ => -1  (true)
.( Try: 7 EVEN?  .  ) CR    \ => 0   (false)


\ ===========================================================================
\ 5. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  ' SHOW-AS-NUMBER  IS DISPLAY-ITEM
\     ACTION-OF DISPLAY-ITEM  ' SHOW-AS-NUMBER  =  -> -1  }T
\ T{  4 EVEN?   -> -1  }T
\ T{  7 EVEN?   -> 0   }T
\ T{  0 .ODD?   -> 0   }T
\ T{  1 .ODD?   -> -1  }T
