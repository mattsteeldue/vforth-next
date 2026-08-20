\
\ 061-locals.f
\ Named local variables: the { ... } bracket form for naming a word's
\ arguments in place, what it costs, and the older two-part form it
\ replaces.
\
\ A word that takes one or two arguments reads well in plain stack style.
\ At three or four, the ROT / OVER / -ROT / 2SWAP traffic starts to hide
\ what the word actually computes, and a single misplaced SWAP produces a
\ wrong answer with no error message. Locals let you name the arguments
\ once and then refer to them by name.
\
\ vForth-specific notes:
\   - This is NOT the Forth-2012 locals wordset, and does not try to be:
\     a local here is a permanent cell, not a frame slot, and re-entrancy
\     is obtained by saving/restoring that cell (section 7), not by a
\     stack frame. { ... } now LOOKS similar to the standard's { : a b :}
\     shape -- declared inside the definition -- but section 5 explains
\     why that took a second design: creating a word while another one
\     is being compiled would normally splice bytes into the middle of
\     the code being generated, which is why an older two-part form
\     (section 11) had to declare locals BEFORE the definition opened.
\   - A local is one permanent cell, not a stack frame. Re-entrancy is
\     obtained by saving the cell on entry and restoring it on exit, so
\     recursion works but stays shallow; see section 7.
\   - Nothing in the core is modified or redefined by this library, so
\     loading it cannot disturb code that was already compiled.
\
\ Starting FORTH (Brodie): no Brodie counterpart (locals postdate the
\ book; this is a vForth extension built as a library).
\ Reference: sec.2 (core words). LOCALS is a lib/ module and is not yet
\ described in the manual; the design notes are in prompts/LOCALS-PLAN.md.
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   061 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 061 TUTORIAL
\

MARKER NEWTASK

CR
.( --- Tutorial 061: locals loaded.      ) CR
.(     Type NEWTASK to unload.           ) CR

NEEDS LOCALS
NEEDS RECURSE

\ =========================================================================
\ 1. The problem locals solve
\ =========================================================================
\
\ Consider a word that returns  a*b + c  from three arguments.
\ In plain stack style the arguments have to be shuffled into place:

: MULADD-STACK  ( a b c -- n )
    >R              ( a b )       \ park c on the return stack
    *               ( a*b )
    R> +            ( a*b+c )
;

\   2 3 4 MULADD-STACK .    => 10

\ That one is still readable. Now the same computation, but returning
\ a*b + b*c + c*a -- each argument is needed more than once, and the
\ stack version becomes a puzzle. With names it stays literal.

\ =========================================================================
\ 2. Declaring locals in place: { ... }
\ =========================================================================
\
\ { is IMMEDIATE and must be the very first word of the definition. It
\ parses names up to a closing } -- all on the SAME source line -- and
\ compiles the code that pops the caller's arguments into them, in the
\ order they were pushed:

: MULADD  ( a b c -- n )
    { A B C }
    A B *  B C *  +  C A *  +
;

\   2 3 4 MULADD .          => 26      \ 6 + 12 + 8

\ Note what did NOT have to be written: no >R, no ROT, no 2DUP. Each
\ argument is simply named where it is used, as many times as needed --
\ and the declaration sits right where the reader needs it, at the top
\ of the definition, instead of on a separate line above it.

\ =========================================================================
\ 3. Reading and writing a local
\ =========================================================================
\
\ A local behaves like VALUE: the bare name pushes its value, and TO
\ stores into it. This works because a local IS a CONSTANT underneath,
\ so the core TO needs no modification at all.

: CLAMP-ADD  ( lo hi -- n )
    { LO HI }
    LO HI +              ( sum )
    DUP 100 > IF         \ cap the running total at 100
        DROP 100
    THEN
;

\   30 40 CLAMP-ADD .       => 70
\   80 90 CLAMP-ADD .       => 100

\ TO in action: the local is updated in place during the computation.

: ACCUM  ( v1 v2 v3 -- n )
    { V1 V2 V3 }
    V1 V2 + TO V1        \ V1 := V1 + V2
    V1 V3 + TO V1        \ V1 := V1 + V3
    V1
;

\   1 2 3 ACCUM .           => 6

\ =========================================================================
\ 4. Output locals: an optional -- for return values
\ =========================================================================
\
\ A -- inside the braces marks off a second group: OUTPUT locals. They
\ are not bound from the stack -- each starts at 0 on every entry -- and
\ the body never pushes them either: every exit path (the closing ; and
\ any early EXIT) pushes their current value automatically, in the order
\ declared, before restoring the caller's own locals underneath them.

: SUM-TO  ( n -- sum )
    { N -- ACC }
    N 0> IF  N 0 DO  ACC I 1+ + TO ACC  LOOP  THEN
;

\   5 SUM-TO .              => 15     \ 1+2+3+4+5
\   0 SUM-TO .              => 0      \ ACC never touched: stays at 0

\ With more than one output, declaration order still matters: the FIRST
\ name declared after -- ends up deepest on the stack, the last one on
\ top -- same rule as any other multi-value return.

: SPLIT-DIGIT  ( n -- lo hi )
    { N -- LO HI }
    N 10 MOD TO LO   N 10 / TO HI
;

\   47 SPLIT-DIGIT .S       => 7 4    \ LO=7 deepest, HI=4 (declared 2nd) on top

\ =========================================================================
\ 5. How in-place declaration works: jumping over the splice
\ =========================================================================
\
\ A local is a real dictionary word, and CREATE writes at HERE -- but
\ while a colon definition is being compiled, HERE IS the thread being
\ generated, so a word created mid-definition would drop bytes into the
\ middle of it. { does not dodge this by closing the definition early --
\ it jumps over the problem instead, and never lets go of FOO's own : :
\
\   1. { compiles an unconditional BRANCH with its offset left blank, to
\      be patched later -- the same forward-reference trick IF uses.
\      FOO's own : stays open throughout.
\   2. Right after that BRANCH, each local name declared between { and }
\      gets CREATEd -- splicing real dictionary headers into the middle
\      of FOO's own thread, on purpose.
\   3. { then lays down this scope's own restore chain, and patches the
\      BRANCH's offset to land exactly here: past the local headers and
\      past the chain, on the code that binds them to the caller's
\      arguments.
\   4. Your own closing ; still belongs to FOO, completely unchanged: it
\      compiles the final EXIT and reveals FOO in the dictionary.
\
\ So  : FOO { X } ... ;  compiles ONE dictionary entry, ONE thread: a
\ BRANCH, X's own header, the restore chain, the code that binds X, your
\ code, EXIT. At run time the BRANCH simply jumps over the header and the
\ chain -- inert data no instruction ever falls into -- landing on the
\ binding code. Since there is only ever one word, RECURSE compiles a
\ call straight back into FOO: no second, nameless body to re-enter
\ through.
\
\ One practical side effect: SEE understands this splice and decodes a
\ word with locals cleanly -- try SEE FACT once section 7 has defined it.

\ =========================================================================
\ 6. Scoping: the names do not leak
\ =========================================================================
\
\ The locals live in their own vocabulary, emptied by every { (or
\ LOCALS-FOR, section 11). Once another scope is declared, the previous
\ names are gone from the search order:
\
\   FORTH  A .              => A? is undefined.
\
\ So two definitions can both call their arguments A and B without
\ interfering, and neither of them shadows anything at the prompt.
\
\ One wrinkle worth knowing: between the closing  ;  and the next  : ,
\ the search order still points at the locals vocabulary. Typing FORTH
\ restores it. (This also matters for FORGET, which insists that CONTEXT
\ and CURRENT agree and otherwise reports error 23.)

\ =========================================================================
\ 7. Re-entrancy: how one cell serves several activations
\ =========================================================================
\
\ Each local is ONE permanent cell, allocated when it is declared --
\ there is no stack frame. Two live activations of the same word would
\ therefore trample on each other, were it not for what { compiles
\ around the body:
\
\   on entry   the previous contents of each cell go on the return
\              stack, then the arguments are stored into the cells;
\   on exit    the saved contents are put back.
\
\ The technique has a name, shallow binding, and it is the same one Lisp
\ uses for special variables. The effect is what matters here: while the
\ inner activation runs, the cells hold ITS values; when it returns, the
\ outer activation finds its own values exactly where it left them. So a
\ word with locals may call itself.

: FACT  ( n -- n! )
    { N }
    N 1 > IF  N 1- RECURSE  N *  ELSE  1  THEN
;

\   5 FACT .                => 120

\ Look at where N appears: AFTER the recursive call. That is the whole
\ test -- it reads correctly only because the inner FACT gave N back on
\ its way out.
\
\ Ordinary nesting works for the same reason, and needs nothing special.

: SQUARE-IT  ( n -- n2 )   { S }   S S * ;

: HYPOT2  ( a b -- a2+b2 )
    { H1 H2 }
    H1 SQUARE-IT  H2 SQUARE-IT  +
;

\   3 4 HYPOT2 .            => 25

\ The restoring is done WITHOUT redefining EXIT, ; or : . { pushes, on
\ the return stack above the caller's address, the address of a short
\ chain of restore steps built for this scope. The EXIT that ends FOO
\ finds that address instead of the caller's, lands in the chain, and
\ the chain's own EXIT is what finally returns.

\ =========================================================================
\ 8. An early EXIT unwinds too
\ =========================================================================
\
\ Any EXIT works this way, including an early one in the middle of the
\ body:

: SAFE-DIV  ( n d -- q )
    { D }
    D 0= IF  DROP 0 EXIT  THEN      \ this EXIT unwinds too
    D /
;

\   100 4 SAFE-DIV .        => 25
\   100 0 SAFE-DIV .        => 0

\ =========================================================================
\ 9. The cost: return-stack budget
\ =========================================================================
\
\ Every activation spends one return-stack cell for the restore chain's
\ address, plus two per local (its old value and its cell address) --
\ 4+4n bytes, the SAME at every recursion level. That flat cost is a
\ direct result of section 5: RECURSE re-enters through FOO itself, not
\ through a second nameless body, so there is no extra per-level entry
\ charge to pay. The return stack is only 160 bytes, shared with the
\ input line buffer, so recursion still has to stay bounded -- overflow
\ overwrites the input buffer and corrupts the system with no error
\ message. If the exact depth matters to you, measure it: a RECURSE-
\ until-it-breaks word on the emulator is a cheap way to find your own
\ limit for a given local count. And remember that ABORT (and THROW)
\ jump straight out without running the restore chain, which is harmless
\ only because every entry re-binds all the locals before the body
\ starts.

\ =========================================================================
\ 10. The guards
\ =========================================================================
\
\ Four mistakes are caught and reported rather than silently miscompiled:
\
\   LOCALS: bad count           the count is 0, or more than 8 (input and
\                               output combined -- the maximum).
\
\   LOCALS: no scope declared   LOCALS (older form) used without a
\                               LOCALS-FOR, or a second time on the same
\                               declaration.
\
\   LOCALS: scope not adjacent  something else was defined between the
\                               older form's LOCALS-FOR and its
\                               definition, so the pairing is no longer
\                               certain.
\
\   LOCALS: misplaced { or }    } with no matching {, a { never closed
\                               on its own line, or a second -- in the
\                               same { ... } group.

\ =========================================================================
\ 11. See also: the older two-part form, LOCALS-FOR + LOCALS
\ =========================================================================
\
\ { ... } is built on top of an older mechanism that is still supported.
\ The declaration goes on the line BEFORE the colon definition, in
\ interpretation state:
\
\       n LOCALS-FOR <definition-name>  <local1> <local2> ... <localn>
\
\ n is the count; the name that follows is the name of the definition
\ that comes right after -- everything on ONE source line. Inside that
\ definition, LOCALS (no arguments, first word of the body) makes the
\ names visible and compiles the binding code. There is no -- in this
\ form: every declared local comes off the stack.

3 LOCALS-FOR MULADD2  X Y Z
: MULADD2  ( a b c -- n )
    LOCALS
    X Y *  Y Z *  +  Z X *  +
;

\   2 3 4 MULADD2 .         => 26

\ { exists precisely to remove this form's two sharp edges: the count
\ must match exactly (LOCALS-FOR N ... vs the definition's own argument
\ count), and nothing else may be defined between LOCALS-FOR and the
\ definition it names, or the adjacency guard rejects it. Prefer { ... }
\ for new code; LOCALS-FOR/LOCALS remains here for old sources and for
\ the rare case where the declaration genuinely needs to sit apart from
\ the definition.

\ =========================================================================
\ 12. Rules of thumb
\ =========================================================================
\
\   - Use locals when a word takes three or more arguments, or when an
\     argument is needed more than twice. Below that, plain stack code
\     is shorter and faster.
\   - Keep { ... } as the first thing in the definition.
\   - Remember the cost: every local permanently spends dictionary space
\     for TWO headers (its own reader, plus a second one SEE uses to
\     print its name), none of it reclaimed. They are meant for a
\     handful of definitions, not for every word.
\   - Recursion is allowed, but count the levels: the return-stack
\     budget in section 9 is tight.
\   - Reach for -- output locals when a word has more than one thing to
\     hand back and TO-driven bookkeeping reads clearer than juggling
\     the return stack by hand.

\ NEEDS TESTING
\ T{  2 3 4 MULADD-STACK   ->  10   }T
\ T{  2 3 4 MULADD         ->  26   }T
\ T{  30 40 CLAMP-ADD      ->  70   }T
\ T{  80 90 CLAMP-ADD      ->  100  }T
\ T{  1 2 3 ACCUM          ->  6    }T
\ T{  5 SUM-TO             ->  15   }T
\ T{  0 SUM-TO             ->  0    }T
\ T{  47 SPLIT-DIGIT       ->  7 4  }T
\ T{  3 4 HYPOT2           ->  25   }T
\ T{  5 FACT               ->  120  }T
\ T{  100 4 SAFE-DIV       ->  25   }T
\ T{  100 0 SAFE-DIV       ->  0    }T
\ T{  2 3 4 MULADD2        ->  26   }T
