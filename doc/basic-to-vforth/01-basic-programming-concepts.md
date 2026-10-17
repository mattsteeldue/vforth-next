# Chapter 1 - Basic Programming Concepts

[From NextBASIC to vForth](README.md)

Manual: Chapter 1, pp. 5-15.

## In short

Little of this chapter carries over word for word, because it describes how
a BASIC program is held and run, and Forth holds and runs a program in
another way. There are no line numbers, so there is no `GO TO`, no `LIST` of
"the program", no `RUN` and no `CONTINUE`. What replaces them is one idea:
you add new words to the language, each one built from the words that are
already there, and you run a word by typing its name. `LET`, `PRINT`,
`INPUT`, `REM`, `STOP` and the error-trapping commands all have a
counterpart; the rest of the chapter is a change of habits.

## What changes

**There is no program, there is a dictionary.** BASIC keeps one program in
memory, a list of numbered lines. Forth keeps a *dictionary* of words. What
you type is carried out at once, word by word, exactly like a BASIC direct
command. To keep something for later you do not put a number in front of it:
you give it a name, between `:` and `;`.

```forth
10 20 + .                       \ => 30
: GREET  ." Hello" ;
GREET                           \ => Hello
```

`GREET` is now a word like any other, and typing its name is the only `RUN`
there is. Every definition is a command of its own, so there is nothing like
"the first line of the program" either: you start wherever you like.

**The order of definition replaces the line numbers.** A word can only use
words that already exist, so a source file reads from the small words at the
top to the main one at the bottom. Nothing can be slipped "between line 10
and line 20", and nothing ever needs renumbering. The source itself lives in
a text file loaded with `INCLUDE`, or in the numbered Screens of the block
file (`n LOAD`), not in the memory of the machine: see Chapter 19.

**Blanks separate, and the colon is taken.** Words are separated by one or
more spaces; the end of a line counts as a space, and a definition may run
over as many lines as you like. BASIC's statement separator `:` has no
counterpart, and the word `:` means something else: it starts a definition.

**The operands come first.** `10 20 + .` is `PRINT 10+20`. Numbers go onto
a *stack*, and every word takes what it needs from the top of it and leaves
its result there. This is the subject of Chapter 6; until then read each
line from left to right and keep track of what is on the stack.

**A variable has to be declared, and its name is an address.** BASIC creates
a variable the first time `LET` mentions it. In Forth `VARIABLE` creates it,
set to zero, and from then on its name pushes the *address* where the value
is kept. `@` fetches the value from an address, `!` stores a value there.

```forth
VARIABLE A
10 A !
A @ .                           \ => 10
A ?                             \ => 10
5 A +!
A ?                             \ => 15
```

`A ?` is short for `A @ .`. Forgetting the `@` is the classic first
mistake: `A .` prints an address, not 15.

A `VALUE` behaves more like a BASIC variable: it is given its first value
when it is created, its name pushes the value, and `TO` changes it.

```forth
NEEDS VALUE
NEEDS TO
NEEDS +TO
15 VALUE B
B .                             \ => 15
20 TO B
5 +TO B
B .                             \ => 25
```

A number that never changes is a `CONSTANT` (`25 CONSTANT ROWS`).

**Left for the value, right for the name.** A line is always carried out
from left to right, one word at a time. But a word can take what it needs
from two sides. From the left, that is from the stack, come *values*: what
the words before it have left there. From the right, that is from the text
that follows, come *names* and texts: `VARIABLE A` and `: GREET` read the
word written after them, `." Hello"` reads up to the closing quote. A name
that does not exist yet cannot be put on the stack, so it has to come from
the text. Many words take from both sides at once: in `15 VALUE B`,
`20 TO B` and `25 CONSTANT ROWS` the value is on the left and the name on
the right.

So a Forth phrase is not always read in one direction by a human. `20 TO B`
reads as in English, "20 to B". But `25 CONSTANT ROWS` makes sense read from the
right, "ROWS is the constant 25", and so does `15 VALUE B`:

```forth
25 CONSTANT ROWS
ROWS .                          \ => 25
```

The best-known case is in [Chapter 4](04-procedures-and-subroutines.md):
`' PONG2 IS PONG` means "PONG is PONG2", which English writes the other way
round. When a line puzzles you, ask of each word which side it takes its
arguments from. Its stack comment shows what comes from the left, and its
`HELP` page says whether it reads a name from the right.

**Most values need no name at all.** A BASIC program names every
intermediate result. In Forth the result of one word is simply left on the
stack for the next one, and a word that needs a number takes it from there.
Variables are kept for what really is long-lived: a score, a mode, a
position. The side-by-side examples show both styles.

**A cell has no type.** NextBASIC has floating-point variables, integer
variables with a `%` and string variables with a `$`. A Forth variable is a
16-bit cell and nothing says what is in it: the word you apply decides. `.`
prints the cell as a signed number, `U.` as an unsigned one, `EMIT` as a
character. The integer, which in NextBASIC is the fast special case, is the
normal case here. Floating point is a library (Chapter 9) and a string is an
address and a length (Chapter 7).

**Defining a word again does not replace it.** Typing a line with a number
that is already in use replaces the old line. A second definition with the
same name is *added*: you get a warning, new code uses the new word, and the
words compiled before still use the old one.

```forth
: PRICE  100 ;
: BILL   PRICE 2 * . ;
: PRICE  150 ;                  \ => PRICE has already been defined.
BILL                            \ => 200
PRICE .                         \ => 150
```

To change `PRICE` for `BILL` as well, correct the source and load it again.

**`NEW` becomes `FORGET`, and nothing is cleared for you.** `FORGET name`
removes `name` and every word defined after it. `MARKER` plants a word whose
only job is to be the place to go back to:

```forth
MARKER SCRATCH
: TEMP  1 . ;
TEMP                            \ => 1
SCRATCH
TEMP                            \ => TEMP? is undefined.
```

`COLD` restarts vForth as it was when first loaded. Since there is no `RUN`
there is no clearing of variables either: the dictionary, the variables and
the stack all stay as they are from one command to the next.

**`PRINT` falls apart into small words.** `.` prints a number followed by one
space and removes it from the stack. `." text"` prints text, inside a
definition or typed at the prompt. `CR` starts a new line, and it is
never automatic: two consecutive outputs stay on the same line unless
you say otherwise. So the
`;` of `PRINT` is the normal behaviour, the apostrophe is `CR`, and the
comma is `n .TAB`, which moves to column `n` (there is no automatic half
screen). To print a number in a column of its own width use `.R`:
`n w .R` prints `n` right-aligned in `w` places, with no space after it.

```forth
." Hello"                       \ => Hello
: SHOW  ( -- )
    ." in" CR
    12 . ." inches" CR
    3 4 .R  5 . ;
SHOW
```

```text
in
12 inches
   35
```

**The report is the name of the word.** BASIC ends every command with a
report: a code, a text, a line and a statement. vForth answers `ok` when all
went well. When something goes wrong it prints the word it was dealing with,
a question mark and a message, and goes back to waiting for input:

```forth
FOO                             \ => FOO? is undefined.
5 0 DO I . LOOP                 \ => DO? Can't be executed.
```

There is no line and statement number to report. While a source is being
loaded, `WHERE` (`NEEDS WHERE`) shows the place where it stopped.

**`STOP` is `QUIT` or `ABORT`, and there is no way back in.** `QUIT` stops
whatever is running and returns to the prompt, leaving the stack alone.
`ABORT` does the same and empties the stack. Neither prints `ok`.

```forth
NEEDS DEPTH
1 2 3 QUIT
DEPTH .                         \ => 3
1 2 3 ABORT
DEPTH .                         \ => 0
```

A word that has stopped cannot be resumed: you call it again. And BREAK is
not checked for you: a word that may run for a long time has to test
`?TERMINAL` by itself, as shown in [Chapter 3](03-looping.md).

**Not every mistake is an error.** vForth checks much less than BASIC does
while a word is running. A division by zero, for one, gives no report at
all, only a meaningless result:

```forth
5 0 / .                         \ => -1
```

The checks you want are the ones you write, and `THROW` is how a word
reports what it found.

**Error trapping wraps one word.** `ON ERROR` switches a trap on for the
rest of the program. In Forth the trap belongs to a single call: `CATCH`
executes the word whose address it is given and returns 0 if that word ended
normally, or the number that was given to `THROW` somewhere inside it. The
number plays the part of BASIC's error code, and by convention it is
negative: -10 is "Division by zero".

```forth
NEEDS CATCH
NEEDS THROW
NEEDS [']
: SHARE  ( n -- )
    DUP 0= IF  -10 THROW  THEN
    100 SWAP / . ;
: TRY  ( n -- )
    ['] SHARE CATCH
    ?DUP IF  ." There was an error! " .  DROP  THEN ;
4 TRY                           \ => 25
0 TRY                           \ => There was an error! -10
```

After a `THROW` the stack is as deep as it was when `CATCH` was called, but
what is in those cells is not to be trusted: hence the `DROP` of the
argument `SHARE` never used. A `THROW` that nobody catches ends in the usual
report, and `n MESSAGE` prints the text of message `n`, like `ERROR$`:

```forth
0 SHARE                         \ => SHARE? Division by zero.
-10 MESSAGE                     \ => Division by zero.
```

**`ERROR` means something else.** In NextBASIC `ERROR` raises the last
report again. vForth has a word `ERROR` too, but it takes a message number
from the stack, prints that message and goes back to the prompt: it is how
the system itself reports, and what an uncaught `THROW` ends up in.

## Correspondence table

| NextBASIC | vForth | Note |
|---|---|---|
| a numbered program line | `: name` ... `;` | A definition is run by typing its name. |
| a direct command | anything typed outside `:` ... `;` | Loops and `IF` work only inside a definition. |
| `:` between statements | a space | The end of a line is a space too. |
| `RUN` | the name of the word | Nothing is cleared. |
| `RUN n`, `GO TO n` to start elsewhere | the name of another word | Every word is an entry point. |
| `LET v=e` | `e v !` | After `VARIABLE v`. |
| the same, for a `VALUE` | `e TO v` | `NEEDS VALUE`, `NEEDS TO`; created by `e VALUE v`. |
| `v` in an expression | `v @` | A `VALUE` or a `CONSTANT` needs no `@`. |
| `PRINT v` | `v @ .` or `v ?` | |
| `LET a,b=10,20` | `10 a !  20 b !` | One store for each variable. |
| `v += e` | `e v +!` | For a `VALUE`: `e +TO v` (`NEEDS +TO`). |
| `v -= e` | `e NEGATE v +!` | |
| `v *= e` and the others | `v @ e * v !` | Only addition has a word of its own. |
| `PRINT e` | `e .` | Prints one space after the number; no new line. |
| `PRINT "text"` | `." text"` | Inside a definition or at the prompt. |
| `PRINT` alone, `'` | `CR` | |
| `PRINT a;b` | `a . b .` | Staying on the line is the default. |
| `PRINT a,b` | `a . n .TAB b .` | `NEEDS .TAB`; `n` is the column. |
| `REM text`, `; text` | `\ text` | To the end of the line. |
| a remark inside a line | `( text )` | `(` is a word: it needs a space after it. |
| `INPUT v` | `ACCEPT`, then `NUMBER` | No single word: see `INPUT#` below. |
| `INPUT a$` | `PAD 20 ACCEPT` | The text is at `PAD`; the count returned is one too many. |
| `NEW` | `FORGET name`, a `MARKER`, `COLD` | |
| `LIST` | - | See "No equivalent". |
| `STOP` | `QUIT` or `ABORT` | `ABORT` empties the stack as well. |
| BREAK key | `?TERMINAL` | Not automatic: see [Chapter 3](03-looping.md). |
| `ON ERROR` statements | `['] name CATCH` | `NEEDS CATCH`, `NEEDS [']`. Traps one call. |
| `ERROR` (raise again) | `n THROW` | `NEEDS THROW`. `0 THROW` does nothing. |
| `ERROR TO e` | the number left by `CATCH` | 0 means no error. |
| `ERROR$` | `n MESSAGE` | |
| report `0 OK` | `ok` | |
| any other report | `word? message.` | No line, no statement. |
| `GO TO`, labels, `CONTINUE` | - | See "No equivalent". |

## Side by side

**Two numbers and their sum.**

```
10 LET apples=7
20 LET pears=5
30 PRINT apples+pears
```

The literal translation declares two variables:

```forth
VARIABLE APPLES
VARIABLE PEARS
7 APPLES !
5 PEARS !
APPLES @ PEARS @ + .            \ => 12
```

But nothing here needs to be remembered, so nothing needs a name. The Forth
way to add two numbers is to add them:

```forth
7 5 + .                         \ => 12
```

**A conversion.** Inches to millimetres, asked for again and again.

```
10 REM inches to millimetres
20 INPUT "Inches? ";i
30 PRINT i;" in = ";i*25.4;" mm"
40 GO TO 20
```

The calculation becomes a word of its own, which can be tried from the
keyboard before anything else exists. There are no fractions in a cell, so
"times 25.4" is written "times 254, divided by 10"; `*/` does both in one
step and keeps the intermediate product in 32 bits.

```forth
: >MM  ( inches -- mm )  254 10 */ ;
12 >MM .                        \ => 304
```

For many uses that is the whole program: the prompt is already a loop that
asks for input, and `12 >MM .` is shorter than answering a question. A
version that asks, like the BASIC one, needs a word to read a number, which
vForth does not supply ready-made:

<!-- no-test -->
```forth
: INPUT#  ( -- n )
    PAD 1+ 20 ACCEPT  1- PAD C!
    BL PAD COUNT + C!
    PAD NUMBER DROP ;
: CONVERT  ( -- )
    BEGIN
        CR ." Inches? " INPUT#
    ?DUP WHILE
        DUP . ." in = " >MM . ." mm"
    REPEAT ;
```

`ACCEPT` reads a line into the buffer `PAD` and `NUMBER` converts it; the
details are in Chapter 14. The `GO TO 20` has become a `BEGIN ... WHILE ...
REPEAT`, and the loop has something BASIC's had not: a way out. Entering 0
ends `CONVERT`, where the BASIC program can only be stopped with BREAK.

**A running total.**

```
10 LET total=0
20 INPUT item
30 total+=item
40 PRINT total
50 GO TO 20
```

Here a variable earns its place, since the total has to outlive each
command. The input loop is, again, the prompt itself:

```forth
VARIABLE TOTAL
: ADD  ( n -- )  TOTAL +!  TOTAL ? ;
5 ADD                           \ => 5
7 ADD                           \ => 12
0 TOTAL !
```

**Asking for a name.**

```
10 INPUT "Your name? ";n$
20 PRINT "Welcome, ";n$;"!"
```

<!-- no-test -->
```forth
: WELCOME  ( -- )
    ." Your name? "  PAD 20 ACCEPT 1-
    CR ." Welcome, "  PAD SWAP TYPE  ." !" ;
```

There is no string variable: the text sits in the buffer at `PAD`, and
`ACCEPT` leaves its length (plus one, hence the `1-`) on the stack. `TYPE`
prints the text given an address and a length. Chapter 7 is about what to do
when the text has to be kept.

**Trapping an error.**

```
10 ON ERROR PRINT "Cannot share among ";n: ON ERROR: STOP
20 INPUT n
30 PRINT 100/n
```

The Forth version is the pair `SHARE` and `TRY` shown under "What changes".
Note where the test is: in BASIC the division itself raises the report and
`ON ERROR` waits for it; in Forth `SHARE` has to look at its argument and
`THROW`, because the division would not complain.

## No equivalent

- **`GO TO` and labels.** There is nowhere to jump to. A backward jump is a
  loop ([Chapter 3](03-looping.md)), a forward jump is an `IF` (Chapter 2),
  and a jump to "that part of the program" is the name of a word.
- **`CONTINUE`.** A word stopped by `QUIT`, `ABORT` or an error is not
  suspended, it is over. What survives is what it left in variables and, after
  `QUIT`, on the stack.
- **`LIST`.** The source is not in memory, so it cannot be listed from
  there: read the file (`NEEDS VIEW`) or the Screen (`n LIST`). `WORDS`
  shows the names in the dictionary, and `SEE name` (`NEEDS SEE`) decompiles
  one word, without its comments. Beware of the name: Forth's `LIST` lists a
  Screen of the block file.
- **Editing a line, deleting a line, Renumber.** These belong to the editor
  that holds the source: a text editor on a PC, or `EDIT` and `LED` on the
  machine (Chapter 19).
- **Multiple assignment** (`a,b,c=0`), and the accumulating operators other
  than `+=`. Each store is written out.
- **A variable created by its first use.** An unknown name is an error:
  `VARIABLE` comes first.
- **An `INPUT` that refuses bad input.** `ACCEPT` takes any text. A word
  like `INPUT#` stops with an error on something that is not a number;
  checking politely is up to the program.
- **`ERROR TO` with line, statement and bank.** `CATCH` returns the code
  and nothing else.

## Further reading

- Tutorial `001` -- the stack, arithmetic and `.`: the first thing to read.
- Tutorial `005` -- `:` and `;`, `CONSTANT`, `VARIABLE`, `VALUE`, `FORGET`.
- Tutorial `003` -- output: `.`, `."`, `EMIT`, `CR`, `.R`, number bases.
- Tutorial `008` -- `@`, `!`, `+!` and what an address is.
- Tutorial `016` -- `KEY` and `ACCEPT`; builds a word that asks for a number.
- Tutorial `022` -- `WORDS`, `SEE`, `WHERE`: looking inside the dictionary.
- Tutorial `026` -- `CATCH`, `THROW`, `ABORT`.
- Tutorial `062` -- the numbered error messages and where their text lives.
- `HELP :`, `HELP VARIABLE`, `HELP VALUE`, `HELP TO`, `HELP ?`,
  `HELP FORGET`, `HELP MARKER`, `HELP QUIT`, `HELP ABORT`, `HELP ACCEPT`,
  `HELP CATCH`, `HELP THROW`, `HELP MESSAGE`.
- vForth manual, sections 2.12.4 "Output", 2.12.6 "Memory" and 2.12.9
  "Definition related".

<!-- nav -->
---

[Contents](README.md) |
Next: [Chapter 2 - Decisions](02-decisions.md)
