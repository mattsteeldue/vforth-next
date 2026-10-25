# Keyword index

[From NextBASIC to vForth](README.md)

Manual: Appendix B, "NextBASIC Keywords and Functions", pp. 291-295.

Every keyword and function of the manual's alphabetical list, with the
vForth word or idiom that takes its place and the chapter of this guide
that explains it. Commands and functions are in one list, in the
manual's order of letters; a keyword with several forms has one line
per form, as in the manual. A few keywords that the manual's list
leaves out, the operators and the parts of other statements (`AND`,
`MOD`, `ELSE`, ...), are added in their place, since they are looked up
just the same.

How to read the second column:

- the word or idiom, written as it is typed: values first, then the
  word (`v a C!` for `POKE a,v`);
- `NEEDS name` when the word is not in the core;
- "in the chapter" when the word is not a library word but is defined in
  the chapter named on the right, to be typed from there;
- `--` when vForth has no counterpart; the chapter says why.

| NextBASIC | vForth | See |
|---|---|---|
| `ABS x` | `x ABS` | [8](08-functions.md) |
| `ACS x` | `x FACOS`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `AND` | `AND`, bitwise and logical | [6](06-expressions.md), [12](12-conditions.md) |
| `ASN x` | `x FASIN`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `ATN x` | `x FATAN`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `ATTR (x,y)` | `r c ATTR`, in the chapter | [15](15-colours.md) |
| `BANK 1346 FORMAT`, `BANK 1346 USR` | -- | [23](23-the-memory.md) |
| `BANK m CLEAR` | `page FREE-PAGE`, in the chapter | [23](23-the-memory.md) |
| `BANK m COPY TO n` | `p1 p2 PAGE-COPY`, in the chapter | [23](23-the-memory.md) |
| `BANK m COPY o,l TO n,o2` | `MMU7!` and `CMOVE`, through a buffer | [23](23-the-memory.md) |
| `BANK m DPOKE o,v` | `MMU7!`, then `v $E000 o + !` | [23](23-the-memory.md) |
| `BANK m ERASE o,l,v` | `page v PAGE-FILL`, in the chapter | [23](23-the-memory.md) |
| `BANK m GOSUB n`, `GOTO`, `LIST`, `MERGE`, `LINE`, `PROC`, `RESTORE` | -- | [23](23-the-memory.md) |
| `BANK m LAYER ... TO ...` | -- | [17](17-time-and-motion.md), [23](23-the-memory.md) |
| `BANK m POKE o,v` | `v page o PAGE-C!`, in the chapter | [23](23-the-memory.md) |
| `BANK NEW v` | `NEW-PAGE`, in the chapter; 8K pages | [23](23-the-memory.md) |
| `BANK n DPEEK o` | `MMU7!`, then `$E000 o + @` | [23](23-the-memory.md) |
| `BANK n PEEK o` | `page o PAGE-C@`, in the chapter | [23](23-the-memory.md) |
| `BANK n PEEK$ (o,l)` | `MMU7!`, copy below `$E000`, put the page back | [23](23-the-memory.md) |
| `BANK n USR o` | `MMU7!`, then `CALL#` | [25](25-using-machine-code.md) |
| `BEEP x,y` | `ms p BEEP`, `NEEDS BLEEP`; milliseconds | [18](18-sound-and-music.md) |
| `BIN 1010` | `%1010` | [6](06-expressions.md), [13](13-the-character-set.md) |
| `BORDER m` | `m .BORDER`, `NEEDS .BORDER` | [15](15-colours.md) |
| `BRIGHT n` | `n .BRIGHT`, `NEEDS .BRIGHT` | [15](15-colours.md) |
| `CAT` | `DIR path`, `NEEDS DIR` | [19](19-nextzxos-and-alternatives.md) |
| `CAT #n` | `n SELECT DIR VIDEO` | [20](20-channels-streams-drivers-and-windows.md) |
| `CAT TAB`, `CAT ASN` | -- | [19](19-nextzxos-and-alternatives.md) |
| `CD path` | `CD path`, `NEEDS CD` | [19](19-nextzxos-and-alternatives.md) |
| `CHR$ n` | `n EMIT`, `n EMITC` | [13](13-the-character-set.md), [App. A](app-a-character-set-z80n-control-codes.md) |
| `CIRCLE x,y,z` | `row col r CIRCLE`, `NEEDS GRAPHICS` | [16](16-graphics.md) |
| `CLEAR` | -- | [23](23-the-memory.md) |
| `CLEAR n` | `CREATE name n ALLOT` | [23](23-the-memory.md), [25](25-using-machine-code.md) |
| `CLOSE #n` | `fh F_CLOSE` | [20](20-channels-streams-drivers-and-windows.md) |
| `CLS` | `CLS` | [14](14-more-about-print-and-input.md) |
| `CODE f` | `CHAR x`, `[CHAR] x`, `a C@` | [13](13-the-character-set.md) |
| `CONTINUE` | -- | [1](01-basic-programming-concepts.md), [App. B](app-b-reference.md) |
| `COPY` (the screen to the printer) | -- | [20](20-channels-streams-drivers-and-windows.md) |
| `COPY u TO SCREEN$` | `VIEW file`, `NEEDS VIEW` | [19](19-nextzxos-and-alternatives.md) |
| `COPY u1 TO u2` | -- (a loop of `F_READ` and `F_WRITE`) | [19](19-nextzxos-and-alternatives.md) |
| `COS x` | `x FCOS`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `DATA list` | `CREATE t  n1 , n2 , n3 ,` | [5](05-read-data-restore.md) |
| `DEF FN f(x)=e` | `: F  ( x -- y )  e ;` | [8](08-functions.md) |
| `DEFPROC name(a,b)` | `: name  ( a b -- )` | [4](04-procedures-and-subroutines.md) |
| `DIM #n TO v` | `buf fh F_FSTAT`, `NEEDS F_FSTAT` | [20](20-channels-streams-drivers-and-windows.md) |
| `DIM a(n)` | `CREATE A n CELLS ALLOT`, or `n ARRAY A` in the chapter | [11](11-arrays.md) |
| `DIM a(m,n)` | `m n MATRIX A`, in the chapter | [11](11-arrays.md) |
| `DIM a$(m,n)` | `m n SARRAY A$`, in the chapter | [11](11-arrays.md) |
| `DIM a$(n)` | `CREATE A$ n ALLOT` | [7](07-strings.md), [11](11-arrays.md) |
| `DPEEK a` | `a @` | [23](23-the-memory.md) |
| `DPOKE a,v` | `v a !` | [23](23-the-memory.md) |
| `DRAW x,y` | `row2 col2 row1 col1 DRAW-LINE`, `NEEDS GRAPHICS` | [16](16-graphics.md) |
| `DRAW x,y,z` | -- | [16](16-graphics.md) |
| `DRIVER` | -- | [20](20-channels-streams-drivers-and-windows.md) |
| `ELSE` | `ELSE` ... `THEN` | [2](02-decisions.md) |
| `ENDIF` | `THEN`, or `ENDIF` | [2](02-decisions.md) |
| `ENDPROC` | `;`, or `EXIT` in the middle | [4](04-procedures-and-subroutines.md) |
| `ENDPROC =r` | leave `r` on the stack | [4](04-procedures-and-subroutines.md) |
| `ERASE` (the program) | `FORGET word`, a `MARKER` | [1](01-basic-programming-concepts.md), [19](19-nextzxos-and-alternatives.md) |
| `ERASE m,n` (lines) | `FORGET word` | [19](19-nextzxos-and-alternatives.md) |
| `ERASE file` | `UNLINK file` | [19](19-nextzxos-and-alternatives.md) |
| `ERROR` | `n THROW`, `NEEDS THROW` | [1](01-basic-programming-concepts.md), [4](04-procedures-and-subroutines.md) |
| `ERROR TO e` | the number left by `CATCH` | [1](01-basic-programming-concepts.md) |
| `ERROR$` | `n MESSAGE` | [1](01-basic-programming-concepts.md), [App. B](app-b-reference.md) |
| `EXIT` (from a loop) | `LEAVE`; from two loops `UNLOOP UNLOOP EXIT` | [3](03-looping.md) |
| `EXP x` | `x FEXP`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `FLASH n` | `n .FLASH`, `NEEDS .FLASH` | [15](15-colours.md) |
| `FN f(x)` | `x F` | [8](08-functions.md) |
| `FOR v=a TO b` ... `NEXT v` | `b 1+ a DO` ... `LOOP` | [3](03-looping.md) |
| `FOR v=a TO b STEP s` | `b 1+ a DO` ... `s +LOOP` | [3](03-looping.md) |
| `GO SUB n` | the name of a word | [4](04-procedures-and-subroutines.md) |
| `GO TO n` | the name of another word | [1](01-basic-programming-concepts.md), [2](02-decisions.md) |
| `GO TO #n,m` | `d fh F_SEEK` | [20](20-channels-streams-drivers-and-windows.md) |
| `IF x THEN y` | `x IF y THEN` | [2](02-decisions.md) |
| `IF x THEN y: ELSE z` | `x IF y ELSE z THEN` | [2](02-decisions.md) |
| `IN n` | `n P@` | [22](22-in-out-and-the-next-registers.md) |
| `IN (s$,m$)` | `SEARCH`, `NEEDS SEARCH` | [8](08-functions.md) |
| `INK n` | `n .INK`, `NEEDS .INK` | [15](15-colours.md) |
| `INKEY$` | `KEY` (waits), `KEY-SCAN`, `NEEDS KEYBOARD` | [14](14-more-about-print-and-input.md) |
| `INPUT v` | `ACCEPT`, then `EVALUATE` or `>NUMBER` | [14](14-more-about-print-and-input.md) |
| `INPUT LINE a$` | `buf n ACCEPT` | [14](14-more-about-print-and-input.md) |
| `INPUT #n; LINE a$` | `GET-LINE`, in the chapter, on `F_READ` | [20](20-channels-streams-drivers-and-windows.md) |
| `INT x` | nothing, with integers; `FINT` with `FLOATING` | [8](08-functions.md), [9](09-mathematical-functions.md) |
| `INT (a/b)` | `a b /` | [8](08-functions.md) |
| `INT {x}` | explicit words: `S>D`, `F>D`, `D>F` | [6](06-expressions.md) |
| `INVERSE n` | `n .INVERSE`, `NEEDS .INVERSE` | [15](15-colours.md) |
| `LAYER m,n` | `LAYER0`, `LAYER10` ... `LAYER13`, `LAYER2`, `NEEDS` each | [15](15-colours.md), [16](16-graphics.md) |
| `LAYER AT x,y` | `x $16 REG!  y $17 REG!`, on Layer 2 | [17](17-time-and-motion.md) |
| `LAYER BANK n,m` | `n $12 REG!  m $13 REG!` | [17](17-time-and-motion.md), [23](23-the-memory.md) |
| `LAYER CLEAR` | -- | [16](16-graphics.md) |
| `LAYER DIM x1,y1,x2,y2` | `CLIP-L2`, in the chapter | [16](16-graphics.md) |
| `LAYER ERASE x,y,w,h,f` | `FILL-RECT`, in the chapter | [16](16-graphics.md) |
| `LAYER OVER n` | `n LAYER-OVER`, in the chapter | [15](15-colours.md) |
| `LAYER PALETTE n,i,v` | registers `$43`, `$40`, `$44` | [15](15-colours.md) |
| `LEN a$` | `A$ C@`; of a pair `a n`, the `n` | [7](07-strings.md), [8](08-functions.md) |
| `LET v=e` | `e v !`; for a `VALUE`, `e TO v` | [1](01-basic-programming-concepts.md) |
| `LET %v=e` | the same: integers are the normal case | [6](06-expressions.md) |
| `LINE` (renumbering) | -- | [1](01-basic-programming-concepts.md) |
| `LINE MERGE` | -- | [1](01-basic-programming-concepts.md) |
| `LIST` | -- (the source is a file: `VIEW file`, `n LIST`) | [1](01-basic-programming-concepts.md), [19](19-nextzxos-and-alternatives.md) |
| `LIST PROC name` | `SEE word`, `NEEDS SEE` | [19](19-nextzxos-and-alternatives.md) |
| `LLIST` | `3 SELECT n LIST VIDEO` | [20](20-channels-streams-drivers-and-windows.md) |
| `LN x` | `x FLN`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `LOAD f` (a program) | `INCLUDE file`, `NEEDS word` | [19](19-nextzxos-and-alternatives.md) |
| `LOAD f BANK`, `LAYER`, `SCREEN$` | `LOAD-BYTES`, with `MMU7!` page by page | [19](19-nextzxos-and-alternatives.md) |
| `LOAD f CODE a,n` | `PAD" f" a n LOAD-BYTES`, `NEEDS LOAD-BYTES` | [19](19-nextzxos-and-alternatives.md) |
| `LOAD f DATA a()` | `LOAD-BYTES` on the table | [19](19-nextzxos-and-alternatives.md) |
| `LOCAL v` | the stack, or `{ a b }`, `NEEDS LOCALS` | [4](04-procedures-and-subroutines.md) |
| `LPRINT` | `3 SELECT` ... `VIDEO` | [20](20-channels-streams-drivers-and-windows.md) |
| `MERGE f` | `NEEDS word`, `INCLUDE file` | [19](19-nextzxos-and-alternatives.md) |
| `MKDIR path` | `MAKEDIR path`, `NEEDS MAKEDIR` | [19](19-nextzxos-and-alternatives.md) |
| `MOD` | `MOD` | [6](06-expressions.md) |
| `MOVE f1,f2` | `src dest F_RENAME` | [19](19-nextzxos-and-alternatives.md) |
| `MOVE f TO attribute` | `F_CHMOD` | [19](19-nextzxos-and-alternatives.md) |
| `NEW` | `FORGET word`, a `MARKER`, `COLD` | [1](01-basic-programming-concepts.md) |
| `NEXT v` | `LOOP`, `+LOOP` | [3](03-looping.md) |
| `NEXT #n,v` | `GET-CHAR`, in the chapter, on `F_READ` | [20](20-channels-streams-drivers-and-windows.md) |
| `NOT` | `NOT`, `0=`; bitwise `INVERT` | [6](06-expressions.md), [12](12-conditions.md) |
| `ON n: s0: s1: s2` | `CASE` ... `OF` ... `ENDOF` ... `ENDCASE`, `NEEDS CASE` | [2](02-decisions.md) |
| `ON ERROR` | `['] word CATCH`, `NEEDS CATCH` | [1](01-basic-programming-concepts.md), [4](04-procedures-and-subroutines.md) |
| `OPEN #n,"i>f"` | `OPEN< f`, or `F_OPEN` | [20](20-channels-streams-drivers-and-windows.md) |
| `OPEN #n,"o>f"` | `OPEN> f`, `NEEDS OPEN>`, or `F_OPEN` | [20](20-channels-streams-drivers-and-windows.md) |
| `OPEN #n,"w>..."`, `"v>"`, `"m>"` | -- | [20](20-channels-streams-drivers-and-windows.md) |
| `OR` | `OR`, bitwise and logical | [6](06-expressions.md), [12](12-conditions.md) |
| `OUT m,n` | `n m P!` | [22](22-in-out-and-the-next-registers.md) |
| `OVER n` | `n .OVER`, `NEEDS .OVER` | [15](15-colours.md) |
| `PALETTE CLEAR` | -- | [15](15-colours.md) |
| `PALETTE DIM n` | register `$41` in place of `$44` | [15](15-colours.md) |
| `PALETTE FORMAT n` | `n $42 REG!`, bit 0 of `$43` | [15](15-colours.md) |
| `PALETTE OVER n` | `n $14 REG!` | [15](15-colours.md) |
| `PAPER n` | `n .PAPER`, `NEEDS .PAPER` | [15](15-colours.md) |
| `PAUSE n` | `1FRAME` repeated; `n PAUSE`, in the chapter | [17](17-time-and-motion.md) |
| `PAUSE 0` | `KEY DROP`, `WAIT-KEY` | [17](17-time-and-motion.md) |
| `PEEK a` | `a C@` | [23](23-the-memory.md), [24](24-the-system-variables.md) |
| `PEEK$ (a,n)` | `a n`, already a string | [23](23-the-memory.md) |
| `PI` | `PI`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `PLAY f1,...` | `a1 n1 ... k PLAY`, `NEEDS PLAY`; `PLAY" ..."` for one | [18](18-sound-and-music.md) |
| `PLOT x,y` | `175 y - x PLOT` on Layer 0, `y x PLOT` on the others | [16](16-graphics.md) |
| `POINT (x,y)` | `row col POINT`, `NEEDS GRAPHICS` | [16](16-graphics.md) |
| `POINT x,y TO v` | `row col POINT` | [16](16-graphics.md) |
| `POKE a,v` | `v a C!` | [23](23-the-memory.md), [24](24-the-system-variables.md) |
| `POKE a,list` | a table with `C,`, then `CMOVE` | [23](23-the-memory.md) |
| `PRINT e` | `e .` | [1](01-basic-programming-concepts.md), [14](14-more-about-print-and-input.md) |
| `PRINT "text"` | `." text"` | [1](01-basic-programming-concepts.md), [14](14-more-about-print-and-input.md) |
| `PRINT #n;...` | `n SELECT` ... `VIDEO` | [20](20-channels-streams-drivers-and-windows.md) |
| `PRINT AT r,c;` | `r c .AT`, `NEEDS .AT` | [14](14-more-about-print-and-input.md) |
| `PRINT TAB n;` | `n .TAB`, `NEEDS .TAB` | [14](14-more-about-print-and-input.md) |
| `PRINT POINT x,y` | -- | [14](14-more-about-print-and-input.md) |
| `PRIVATE v` | `VARIABLE v` before the word | [4](04-procedures-and-subroutines.md) |
| `PROC name(x,y)` | `x y name` | [4](04-procedures-and-subroutines.md) |
| `PROC name() TO v` | `name v !` | [4](04-procedures-and-subroutines.md) |
| `PWD` | `PWD`, `NEEDS PWD`; into a buffer `F_GETCWD` | [19](19-nextzxos-and-alternatives.md) |
| `RANDOMIZE n` | `n RANDOMIZE`, `NEEDS RANDOMIZE` | [10](10-random-numbers.md) |
| `READ v` | `t i CELLS + @` | [5](05-read-data-restore.md) |
| `REF a()` | pass the address | [4](04-procedures-and-subroutines.md) |
| `REG n` | `n REG@` | [22](22-in-out-and-the-next-registers.md) |
| `REG n,v` | `v n REG!` | [22](22-in-out-and-the-next-registers.md) |
| `REM text` | `\ text`, `( text )` | [1](01-basic-programming-concepts.md) |
| `REMOUNT` | `REMOUNT` | [19](19-nextzxos-and-alternatives.md) |
| `REPEAT` ... `REPEAT UNTIL x` | `BEGIN` ... `x UNTIL` | [3](03-looping.md) |
| `REPEAT: WHILE x` ... `REPEAT UNTIL 0` | `BEGIN x WHILE` ... `REPEAT` | [3](03-looping.md) |
| `RESTORE n` | an index variable, `k p !` | [5](05-read-data-restore.md) |
| `RETURN` | `;`, or `EXIT` in the middle | [4](04-procedures-and-subroutines.md) |
| `RETURN #n,v` | `fh F_FGETPOS` | [20](20-channels-streams-drivers-and-windows.md) |
| `RMDIR path` | `REMOVEDIR path`, `NEEDS REMOVEDIR` | [19](19-nextzxos-and-alternatives.md) |
| `RND` | `n RND`, `NEEDS RND`; no fraction; NextBASIC's own numbers: `n XRND`, `NEEDS XRND` | [10](10-random-numbers.md) |
| `RUN` | the name of the word | [1](01-basic-programming-concepts.md) |
| `RUN AT s` | `s SPEED!`, `NEEDS SPEED!` | [19](19-nextzxos-and-alternatives.md), [22](22-in-out-and-the-next-registers.md) |
| `SAVE f` (a program) | -- (the source is a file) | [19](19-nextzxos-and-alternatives.md) |
| `SAVE f CODE a,n` | `PAD" f" a n SAVE-BYTES`, `NEEDS SAVE-BYTES` | [19](19-nextzxos-and-alternatives.md) |
| `SAVE f LINE n` | `ZAP` | [19](19-nextzxos-and-alternatives.md), [25](25-using-machine-code.md) |
| `SAVE f BANK`, `LAYER`, `SCREEN$`, `DATA` | `SAVE-BYTES`, with `MMU7!` for pages | [19](19-nextzxos-and-alternatives.md) |
| `SCREEN$ (x,y)` | -- | [14](14-more-about-print-and-input.md) |
| `SGN x` | `x SGN`, in the chapter; `FSGN` with `FLOATING` | [8](08-functions.md), [9](09-mathematical-functions.md) |
| `SGN {i}` | `.` in place of `U.`: signed is the default | [6](06-expressions.md) |
| `SIN x` | `x FSIN`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `SPECTRUM` (48K mode) | -- | [19](19-nextzxos-and-alternatives.md) |
| `SPECTRUM INK`, `PAPER`, `CHR$` ... | `.INK`, `.PAPER`, `NARROWCHAR` in Screen 11 | [19](19-nextzxos-and-alternatives.md) |
| `SPRITE s,x,y,i,f` | the fields of `SPRITE`, then `s SPRITE-UPDATE`, `NEEDS SPRITE` | [17](17-time-and-motion.md) |
| `SPRITE BANK b` | `p SPRITE-INIT`, one per pattern | [17](17-time-and-motion.md) |
| `SPRITE BORDER n` | bit 1 of register `$15` | [17](17-time-and-motion.md) |
| `SPRITE CLEAR` | `s SPRITE-HIDE` for each sprite | [17](17-time-and-motion.md) |
| `SPRITE DIM x1,y1,x2,y2` | `CLIP-SPRITES`, in the chapter | [17](17-time-and-motion.md) |
| `SPRITE PALETTE n,i,v` | registers `$43`, `$40`, `$41` | [17](17-time-and-motion.md) |
| `SPRITE PRINT n` | `SPRITES-ON`, `SPRITES-OFF` | [17](17-time-and-motion.md) |
| `SQR x` | `x SQRT`, `NEEDS SQRT`; `FSQRT` with `FLOATING` | [8](08-functions.md), [9](09-mathematical-functions.md) |
| `STEP` | `+LOOP` | [3](03-looping.md) |
| `STOP` | `QUIT`, `ABORT` | [1](01-basic-programming-concepts.md) |
| `STR$ x` | `<# #S #>`; `STR$`, in the chapter | [8](08-functions.md) |
| `TAN x` | `x FTAN`, `NEEDS FLOATING` | [9](09-mathematical-functions.md) |
| `TILE`, `TILE BANK`, `TILE DIM` | -- (Layer 3: `NEEDS LAYER3`) | [16](16-graphics.md) |
| `TIME` | `RESET-TIMER`, `TIMER`, in the chapter | [17](17-time-and-motion.md) |
| `TIME$` | `IDE_RTC`, `.NOW`, `NEEDS` each | [17](17-time-and-motion.md) |
| `USR o` | `n o CALL#`, `NEEDS CALL#`; or a `CODE` word | [25](25-using-machine-code.md) |
| `USR "a"` | `CHAR A UDG@`, `NEEDS UDG+` | [13](13-the-character-set.md) |
| `USR$ o` | a `CODE` word that leaves `a n` | [25](25-using-machine-code.md) |
| `VAL f` | `EVALUATE`, `NEEDS EVALUATE`; `>NUMBER` | [8](08-functions.md) |
| `VAL$ f` | `EVALUATE` | [8](08-functions.md) |
| `VERIFY f` | -- | [19](19-nextzxos-and-alternatives.md) |
| `<<`, `>>` | `LSHIFT`, `RSHIFT` | [6](06-expressions.md), [22](22-in-out-and-the-next-registers.md) |

<!-- nav -->
---

Previous: [Appendix D - The Calculator](app-d-the-calculator.md) |
[Contents](README.md)
