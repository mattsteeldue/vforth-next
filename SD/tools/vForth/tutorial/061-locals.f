\
\ 061-locals.f
\ Named local variables: how to stop juggling the stack in words that
\ take three or four arguments, and what you give up in exchange.
\
\ A word that takes one or two arguments reads well in plain stack style.
\ At three or four, the ROT / OVER / -ROT / 2SWAP traffic starts to hide
\ what the word actually computes, and a single misplaced SWAP produces a
\ wrong answer with no error message. Locals let you name the arguments
\ once and then refer to them by name.
\
\ vForth-specific notes:
\   - This is NOT the Forth-2012 locals wordset, and does not try to be.
\     The standard {: a b :} form declares locals INSIDE the definition;
\     here the declaration goes on the line BEFORE it. The reason is in
\     section 4: creating a word while another one is being compiled
\     would splice bytes into the middle of the code being generated.
\   - A local is one permanent cell, not a stack frame. Re-entrancy is
\     obtained by saving the cell on entry and restoring it on exit, so
\     recursion works but stays shallow; see section 6.
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
\ 2. Declaring a scope
\ =========================================================================
\
\ The declaration goes on the line BEFORE the colon definition, in
\ interpretation state, and has this shape:
\
\       n LOCALS-FOR <definition-name>  <local1> <local2> ... <localn>
\
\ n is the number of locals. The name that follows is the name of the
\ definition that comes next -- LOCALS-FOR is a decorator for it.
\ Everything must fit on ONE source line.
\
\ Inside the definition, LOCALS (no arguments) makes the names visible
\ and compiles the code that pops the arguments into them. In practice
\ it is the first word of the definition, because it consumes the
\ caller's arguments.

3 LOCALS-FOR MULADD  A B C
: MULADD  ( a b c -- n )
    LOCALS
    A B *  B C *  +  C A *  +
;

\   2 3 4 MULADD .          => 26      \ 6 + 12 + 8

\ Note what did NOT have to be written: no >R, no ROT, no 2DUP. Each
\ argument is simply named where it is used, as many times as needed.

\ =========================================================================
\ 3. Reading and writing a local
\ =========================================================================
\
\ A local behaves like VALUE: the bare name pushes its value, and TO
\ stores into it. This works because a local IS a CONSTANT underneath,
\ so the core TO needs no modification at all.

2 LOCALS-FOR CLAMP-ADD  LO HI
: CLAMP-ADD  ( lo hi -- n )
    LOCALS
    LO HI +              ( sum )
    DUP 100 > IF         \ cap the running total at 100
        DROP 100
    THEN
;

\   30 40 CLAMP-ADD .       => 70
\   80 90 CLAMP-ADD .       => 100

\ TO in action: the local is updated in place during the computation.

3 LOCALS-FOR ACCUM  V1 V2 V3
: ACCUM  ( v1 v2 v3 -- n )
    LOCALS
    V1 V2 + TO V1        \ V1 := V1 + V2
    V1 V3 + TO V1        \ V1 := V1 + V3
    V1
;

\   1 2 3 ACCUM .           => 6

\ =========================================================================
\ 4. Why it takes TWO words instead of one
\ =========================================================================
\
\ The split is not a matter of taste, it is forced by the core.
\
\ (a) A local is a real dictionary word, and creating a word writes into
\     the dictionary at HERE. While a colon definition is being
\     compiled, HERE IS the code being generated -- so a local created
\     mid-definition would drop bytes into the middle of the thread, and
\     the interpreter would later run straight into them. Hence the
\     locals are created BEFORE the definition opens.
\
\ (b) But  :  begins with  CURRENT @ CONTEXT !  -- it resets the search
\     vocabulary. So whatever LOCALS-FOR does to make the names findable
\     is undone the instant  :  runs. Something has to put it back from
\     INSIDE the definition, and that something is LOCALS.
\
\ A useful consequence: if you forget LOCALS, the local names simply do
\ not resolve and compilation stops with an error. The mistake is loud,
\ not silent.

\ =========================================================================
\ 5. Scoping: the names do not leak
\ =========================================================================
\
\ The locals live in their own vocabulary, which is emptied by every
\ LOCALS-FOR. Once another scope is declared, the previous names are
\ gone from the search order:
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
\ 6. Re-entrancy: how one cell serves several activations
\ =========================================================================
\
\ Each local is ONE permanent cell, allocated when the scope is
\ declared -- there is no stack frame. Two live activations of the same
\ word would therefore trample on each other, were it not for what
\ LOCALS compiles around the body:
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

1 LOCALS-FOR FACT  N
: FACT  ( n -- n! )
    LOCALS
    N 1 > IF  N 1- RECURSE  N *  ELSE  1  THEN
;

\   5 FACT .                => 120

\ Look at where N appears: AFTER the recursive call. That is the whole
\ test -- it reads correctly only because the inner FACT gave N back on
\ its way out.
\
\ Ordinary nesting works for the same reason, and needs nothing special.

1 LOCALS-FOR SQUARE-IT  S
: SQUARE-IT  ( n -- n2 )   LOCALS  S S * ;

2 LOCALS-FOR HYPOT2  H1 H2
: HYPOT2  ( a b -- a2+b2 )
    LOCALS
    H1 SQUARE-IT  H2 SQUARE-IT  +
;

\   3 4 HYPOT2 .            => 25

\ The restoring is done WITHOUT redefining EXIT, ; or : . LOCALS pushes
\ on the return stack, on top of the caller's address, the address of a
\ short chain of restore steps. The EXIT that ends the definition finds
\ that address instead of the caller's, lands in the chain, and the
\ chain's own EXIT is what finally returns. Any EXIT works this way,
\ including an early one in the middle of the body:

1 LOCALS-FOR SAFE-DIV  D
: SAFE-DIV  ( n d -- q )
    LOCALS
    D 0= IF  DROP 0 EXIT  THEN      \ this EXIT unwinds too
    D /
;

\   100 4 SAFE-DIV .        => 25
\   100 0 SAFE-DIV .        => 0

\ THE PRICE: the return stack. Every activation spends 4 bytes, plus 4
\ for each local, on a return stack that is only 160 bytes and shares
\ them with the input line buffer. A word with 1 local recurses about 15
\ levels deep; with 4 locals, about 6. Going past that overwrites the
\ input buffer and corrupts the system with no error message, so keep
\ recursion visibly bounded -- and remember that ABORT (and THROW) jump
\ straight out without running the restore chain, which is harmless only
\ because every entry re-binds all the locals before the body starts.

\ =========================================================================
\ 7. The guards
\ =========================================================================
\
\ Three mistakes are caught and reported rather than silently miscompiled:
\
\   LOCALS: bad count           n is 0, or larger than 8 (the maximum).
\
\   LOCALS: no scope declared   LOCALS used without a LOCALS-FOR, or a
\                               second time on the same declaration.
\                               Without this, two definitions would
\                               quietly share the same cells.
\
\   LOCALS: scope not adjacent  something else was defined between the
\                               LOCALS-FOR and its definition, so the
\                               pairing is no longer certain.

\ =========================================================================
\ 8. Rules of thumb
\ =========================================================================
\
\   - Use locals when a word takes three or more arguments, or when an
\     argument is needed more than twice. Below that, plain stack code
\     is shorter and faster.
\   - Keep LOCALS as the first word of the definition.
\   - Remember the cost: every scope permanently spends one cell per
\     local plus a name in the heap, and none of it is reclaimed. They
\     are meant for a handful of definitions, not for every word.
\   - Recursion is allowed, but count the levels: 4+4n bytes each on a
\     160-byte return stack (section 6).

\ NEEDS TESTING
\ T{  2 3 4 MULADD-STACK   ->  10   }T
\ T{  2 3 4 MULADD         ->  26   }T
\ T{  30 40 CLAMP-ADD      ->  70   }T
\ T{  80 90 CLAMP-ADD      ->  100  }T
\ T{  1 2 3 ACCUM          ->  6    }T
\ T{  3 4 HYPOT2           ->  25   }T
\ T{  5 FACT               ->  120  }T
\ T{  100 4 SAFE-DIV       ->  25   }T
\ T{  100 0 SAFE-DIV       ->  0    }T
