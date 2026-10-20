\
\ 068-random-numbers.f
\ Random numbers: the two generators vForth offers, how to seed them,
\ how to turn their output into a range, and three things every game
\ needs -- a random pick from a table, a shuffled deck and a chance in
\ percent.  The demo throws a die a few hundred times and draws the
\ tally as a bar chart, to show what "uniform" looks like.
\
\ vForth-specific notes:
\   - Both generators keep their state in the BASIC system variable SEED
\     (23670), so RANDOMIZE serves both and a seed set in NextBASIC
\     before entering vForth is the one Forth starts from.
\   - RND is BASIC's own generator, word for word; RANDOM and CHOOSE are
\     the Starting FORTH pair.  None of them is in the core: each one is
\     a NEEDS away (inc/RND.f, inc/random.f, inc/choose.f).
\   - There is no fraction between 0 and 1: ask for the integer you want.
\
\ Coming from BASIC: Ch.10  |  doc/basic-to-vforth/
\ Starting FORTH (Brodie): Ch.10 (CHOOSE)  |  vForth screens 880, 888
\ Reference: sec.2.12.5
\
\ Load from a clean session:
\   NEEDS TUTORIAL
\   068 TUTORIAL
\ To unload and reload interactively:
\   NEWTASK 068 TUTORIAL
\
\ Run it with:  DEMO
\

MARKER NEWTASK

CR
.( --- Tutorial 068: random numbers loaded. ) CR
.(     Type NEWTASK to unload.              ) CR

NEEDS RND
NEEDS RANDOMIZE
NEEDS CHOOSE

\ =========================================================================
\ 1. Two generators, one seed
\ =========================================================================
\
\ A pseudo-random generator is a function applied over and over to a
\ number, the SEED: each call replaces the seed with the next value of
\ the sequence and derives its result from it.  vForth keeps the seed
\ where BASIC keeps it, in the system variable SEED at address 23670.
\
\   n RND     ( n -- 0..n-1 )   BASIC's generator, the one behind
\                               RND and %RND: seed -> 75*(seed+1) MOD
\                               65537, minus 1.  inc/RND.f
\   RANDOM    ( -- u )          Brodie's generator: seed -> 31421*seed
\                               + 6927 MOD 65536.  inc/random.f
\   n CHOOSE  ( n -- 0..n-1 )   RANDOM scaled to a range.  inc/choose.f
\   n RANDOMIZE  ( n -- )       stores n into SEED.  inc/randomize.f
\
\ Both sequences run through all 65536 values before repeating.  Pick
\ one generator per program: the two share the seed, so mixing them
\ makes each one jump around inside the other's sequence.
\
\ The seed can be read and written like any variable:

23670 CONSTANT SEED

\   SEED @ U.       => the current seed, whatever it happens to be

\ =========================================================================
\ 2. Repeatable sequences: RANDOMIZE
\ =========================================================================
\
\ The same seed always gives the same sequence.  That is what you want
\ while testing -- a bug that shows up once shows up every time:
\
\   1 RANDOMIZE  100 RND . 100 RND . 100 RND .     => 0 17 87
\   1 RANDOMIZE  100 RND . 100 RND . 100 RND .     => 0 17 87
\
\ In the finished program you want a different game each time.  BASIC's
\ RANDOMIZE with no argument takes the seed from FRAMES (23672), the
\ counter the 50 Hz interrupt bumps; in vForth you do it by hand, and
\ best after a key press, because the moment a person presses a key is
\ the one truly unknown quantity in the machine.

: SEED-FROM-FRAMES  ( -- )
    23672 @ RANDOMIZE ;

: START  ( -- )
    CR ." Press a key to start..."
    KEY DROP  SEED-FROM-FRAMES  CR ;

\ CAVEAT: RANDOMIZE always takes its argument from the stack.  Typing a
\ bare RANDOMIZE, as you would in BASIC, stores whatever number happens
\ to be on top of the stack.  On an empty stack it is worse: it stores
\ the cell that lies just below the stack, and only then complains
\ "Stack is empty".  That cell does not change from one run to the next,
\ so the "random" game now plays the same every time, and the error
\ message is easy to miss.

\ =========================================================================
\ 3. A range: from lo to hi
\ =========================================================================
\
\ n RND gives one of n values, 0 to n-1.  Every other range is a shift
\ of that one: a die is 6 RND 1+, a number from 10 to 20 is one of the
\ 11 values counted from 10.

: DICE  ( -- 1..6 )  6 RND 1+ ;

: RND-IN  ( lo hi -- lo..hi )
    OVER - 1+       ( lo count )
    RND + ;

\   1 RANDOMIZE  DICE . DICE . DICE .               => 1 2 6
\   1 RANDOMIZE  10 20 RND-IN . 10 20 RND-IN .      => 10 11

\ =========================================================================
\ 4. Why UM* NIP, and not MOD
\ =========================================================================
\
\ The obvious way to bring a 16-bit random number into a range is MOD:
\ RANDOM 6 MOD.  It is the wrong one for RANDOM, twice over.
\
\ First, in a generator of the form seed*a+c MOD 65536 the low bits are
\ much less random than the high ones: bit 0 simply alternates.  Look
\ at it alone, the remainder of a division by 2:

: COIN-LOW  ( -- 0|1 )  RANDOM 1 AND ;
: .COINS-LOW  ( -- )  10 0 DO  COIN-LOW .  LOOP ;

\   1 RANDOMIZE  .COINS-LOW                   => 0 1 0 1 0 1 0 1 0 1
\
\ Second, MOD is signed, and RANDOM is not: half of its values are above
\ 32767, which MOD reads as negative numbers, and their remainders are
\ negative too.

: COIN-MOD  ( -- -1|0|1 )  RANDOM 2 MOD ;
: .COINS-MOD  ( -- )  10 0 DO  COIN-MOD .  LOOP ;

\   1 RANDOMIZE  .COINS-MOD                   => 0 -1 0 -1 0 1 0 -1 0 1
\
\ A "coin" that alternates heads and tails is not a coin, and one with
\ three faces even less.  CHOOSE and
\ RND do something else: they treat the random number as a fraction of
\ 65536 and multiply it by the range, keeping the high cell of the
\ 32-bit product.  That uses the HIGH bits, the good ones:
\
\   u n UM* NIP     ( u n -- u*n/65536 )
\
\ which is exactly the body of CHOOSE.

: COIN  ( -- 0|1 )  2 CHOOSE ;

: .COINS  ( -- )  10 0 DO  COIN .  LOOP ;

\   1 RANDOMIZE  .COINS                       => 1 1 1 1 1 0 1 1 1 0
\
\ (DO ... LOOP works only inside a definition, hence the two little
\ words: typed at the prompt, DO answers "Can't be executed".)
\
\ RND uses the same scaling on top of BASIC's generator (whose low bits
\ are fine, as it happens, but the scaling costs nothing).  Rule: to get
\ a range, never apply MOD to RANDOM; use CHOOSE, or RND.

\ =========================================================================
\ 5. A random pick from a table
\ =========================================================================
\
\ BASIC programs pick a random element with a DATA list and a loop of
\ READs, or with a string and a slice.  In Forth the table is just
\ memory, and the random number is the index.  Here the table is a
\ counted string compiled with ,"  -- its first byte is the length:

CREATE WINDS  ," NESW"

: WIND  ( -- c )
    WINDS COUNT     ( addr len )
    RND + C@ ;

: .WINDS  ( -- )  8 0 DO  WIND EMIT  LOOP ;

\   1 RANDOMIZE  .WINDS                       => NNWSSEEE
\
\ The length is read from the table itself, so adding a fifth letter to
\ the string needs no other change.

\ =========================================================================
\ 6. Shuffling: the deck of cards
\ =========================================================================
\
\ Drawing at random from a table may give the same element twice.  When
\ every element must come out exactly once, in random order -- cards,
\ questions in a quiz, the levels of a game -- shuffle the table instead.
\ The Fisher-Yates shuffle walks the table from the last element down to
\ the second, and swaps each one with a random element at or below it.

10 CONSTANT #CARDS
CREATE DECK  #CARDS ALLOT

: CARD  ( i -- addr )  DECK + ;

: NEW-DECK  ( -- )                      \ cards 1 to 10, in order
    #CARDS 0 DO  I 1+  I CARD C!  LOOP ;

: SWAP-CARDS  ( i j -- )
    CARD SWAP CARD  ( aj ai )
    2DUP C@ SWAP C@ ( aj ai ci cj )
    ROT C!          ( aj ci )
    SWAP C! ;

: SHUFFLE  ( -- )
    1 #CARDS 1- DO              \ i from 9 down to 1
        I  I 1+ RND             ( i j )   \ j from 0 to i
        SWAP-CARDS
    -1 +LOOP ;

: .DECK  ( -- )
    #CARDS 0 DO  I CARD C@ .  LOOP ;

\   NEW-DECK .DECK                            => 1 2 3 4 5 6 7 8 9 10
\   1 RANDOMIZE  NEW-DECK SHUFFLE .DECK       => 6 3 10 8 9 4 5 7 2 1
\
\ CAVEAT: the bound of RND is I 1+, not #CARDS.  Swapping each card with
\ ANY card of the deck looks just as random but is not: some orders come
\ out more often than others.  With I 1+ every one of the 10! orders is
\ equally likely.

\ =========================================================================
\ 7. A chance in percent
\ =========================================================================
\
\ "One time in three the monster attacks": a probability is a range too.
\ 100 RND is 0 to 99; it is below 30 thirty times out of a hundred.

: CHANCE?  ( percent -- f )
    100 RND > ;

: .CHANCES  ( percent -- )
    10 0 DO  DUP CHANCE? 1 AND .  LOOP  DROP ;

\   1 RANDOMIZE  30 .CHANCES                  => 1 1 0 0 0 0 0 1 0 1

\ =========================================================================
\ 8. Demo: is the die fair?
\ =========================================================================
\
\ Throw the die 300 times, count each face, draw one bar per face.  A
\ fair die gives about 50 per face; the bars are never all the same
\ length, and they should not be: that is what chance looks like.

CREATE TALLY  6 CELLS ALLOT

: FACE  ( n -- addr )  1- CELLS TALLY + ;   \ face 1..6 -> its counter

: THROWS  ( n -- )
    TALLY 6 CELLS ERASE
    0 ?DO  1 DICE FACE +!  LOOP ;

: BAR  ( n -- )
    0 ?DO  [CHAR] * EMIT  LOOP ;

: .TALLY  ( -- )
    7 1 DO
        CR I .  I FACE @ DUP 3 .R SPACE BAR
    LOOP CR ;

: DEMO  ( -- )
    START
    300 THROWS .TALLY ;

\   1 RANDOMIZE  300 THROWS .TALLY      prints six bars, the first
\                                        starting "1  45 ******..."

\ =========================================================================
\ 9. Simple tests (requires NEEDS TESTING)
\ =========================================================================
\
\ NEEDS TESTING  DECIMAL          \ lib/testing.f leaves BASE in HEX
\ T{  1 RANDOMIZE  100 RND  100 RND  ->  0 17  }T
\ T{  1 RANDOMIZE  10 20 RND-IN  ->  10  }T
\ T{  1 RANDOMIZE  COIN-LOW COIN-LOW COIN-LOW  ->  0 1 0  }T
\ T{  1 RANDOMIZE  COIN-MOD COIN-MOD  ->  0 -1  }T
\ T{  NEW-DECK  0 CARD C@  9 CARD C@  ->  1 10  }T
\ T{  0 CHANCE?  ->  0  }T
\ T{  100 CHANCE?  ->  -1  }T
