\
\ 022-introspection.f
\ Dictionary introspection: WORDS, SEE, WHERE, '.
\
\ vForth exposes the dictionary at runtime.  You can list all words,
\ disassemble any word, and inspect name/link/code fields directly.
\
\ Core words (no NEEDS):
\   '     ( -- xt )      look up the follwing word; return its xt 
\   <NAME (  xt -- nfa )  xt to Name Field Address (NFA) on Heap
\   >BODY (  xt -- pfa )  xt to Parameter Field Address (PFA)
\   CFA   ( pfa -- xt  )  pfa to xt (or Code Field Address)
\   LFA   ( pfa -- lfa ) pfa to Link Field Address (LFA)
\   NFA   ( pfa -- nfa ) pfa to Name Field Address (NFA)
\   PFA   ( nfa -- pfa ) nfa to Parameter Field Address (PFA)
\   ID.   ( nfa -- )     print the name at NFA
\
\ Words requiring NEEDS:
\   WORDS   ( -- )       list all words in CONTEXT vocabulary
\   SEE     ( -- cccc )  disassemble a word
\   WHERE   ( n n -- )   show the source line after a LOAD error
\
\ Starting FORTH (Brodie): Ch.9  |  vForth screens 868-877 (incl. SEE)
\ Reference: sec.2.12.4, 3.6.1, 4.6
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   022 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 022 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 022: dictionary loaded. ) CR
.(     Type NEWTASK to unload.   ) CR

NEEDS SEE


\ ===========================================================================
\ 1.  '  (tick)  --  get the xt (or CFA) of a word
\ ===========================================================================
\
\ ' name ( -- xt )
\   Returns the xt (Code Field Address) of name.  
\   When compiled, it delays it operation at run-time when it expects a name
\   from the current input source.
\   Unlike ['] which is immediate and works inside definitions and compiles 
\   a literal of such execution token.
\
\   ' DUP HEX .         => (prints xt of DUP)
\   ' DUP EXECUTE       => same as DUP ALONE (duplicates TOS)
\
\ Inside a definition, use ['] (NEEDS [']) to compile the xt as a literal:
\   : GET-DUP-XT  ( -- xt )  ['] DUP ;

.( ' DUP CFA: ) ' DUP U. CR
.( ' +   CFA: ) ' +   U. CR


\ ===========================================================================
\ 2. NFA, LFA, ID.  --  walking the dictionary
\ ===========================================================================
\
\ Each dictionary entry has some fields relative to its xt:
\   <NAME ( cfa -- nfa )  Name Field Address: length+flags byte then name
\   >BODY ( cfa -- pfa )  Parameter Field Address: its definition
\   LFA ( pfa -- lfa )  Link Field Address: points to the previous name entry
\   ID. ( nfa -- )      print the name stored at nfa
\ 
\   n.b. vForth namespace is kept in heap.
\
\ Walk two entries back from DUP:
\
\   ' DUP  <NAME ID. CR             \ => DUP
\   ' DUP  >BODY LFA  @             \ heap-address of previous entry
\   ' DUP  >BODY LFA @ FAR ID. CR   \ => SWAP (the name of previous entry)

.( DUP name: ) ' DUP <NAME ID. CR


\ ===========================================================================
\ 3. WORDS  --  list all words in the current vocabulary
\ ===========================================================================
\
\ WORDS ( -- )
\   Lists every word in the CONTEXT vocabulary (FORTH by default),
\   wrapping at the screen width.  Press BREAK to stop early.
\
\   WORDS              \ list all words
\   DEMO-VOC WORDS     \ list words of a specific vocabulary
\
CR
.( Try: WORDS ) CR


\ ===========================================================================
\ 4. SEE  --  disassemble a word
\ ===========================================================================
\
\ SEE name ( -- )
\   Disassembles the word named by the next token.  For high-level
\   words it shows the compiled word addresses; for CODE words it
\   shows the hex bytes of the machine code.
\
\   SEE DUP         \ show DUP's code
\   SEE =           \ show ='s code, i.e. the sequence  - 0= EXIT
\   SEE [CHAR]      \ show [CHAR]'s code. [CHAR] is an immediate word.
\
.( Try: SEE SWAP ) CR


\ ===========================================================================
\ 5. Inspecting a word manually
\ ===========================================================================
\
\ Example: print name and link of the word before DUP in the dictionary.

: .WORD-INFO  ( cfa -- )
    DUP  <NAME ID.  SPACE
    >BODY LFA  @ DUP IF  FAR ID.  ELSE  DROP ." (end)"  THEN  CR ;

.( DUP info: ) ' DUP .WORD-INFO


\ ===========================================================================
\ 6. WHERE  --  locate an error in a LOAD
\ ===========================================================================
\
\ WHERE is used after a compilation error during LOAD or INCLUDE.
\ It displays the screen and line number where the error occurred.
\ In case of error LOAD leaves on top of stack the content of >BLK and >IN
\ so that you can give WHERE and see the offending line and position.
\
\   WHERE

.( The following definition has an error. ) CR
.( Type:  WHERE  when you receive "Syntax error" ) CR

: WRONG  BEGIN WHILE LOOP  ;

\ ===========================================================================
\ 7. Simple tests (requires NEEDS TESTING)
\ ===========================================================================
\
\ NEEDS TESTING
\ T{  ' DUP  NFA  C@  $3F AND  -> 3  }T   \ "DUP" is 3 chars
\ T{  ' +    NFA  C@  $3F AND  -> 1  }T   \ "+" is 1 char
