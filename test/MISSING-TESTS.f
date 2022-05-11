\
\ MISSING-TESTS.f
\

\ definitions that has no tester
\
MARKER TESTING-TASK

WARNING @ 
0 WARNING ! \ reduce messaging #4

    NEEDS TESTING

WARNING !
    
 \ Save base value
BASE    @ HEX \ all test needs base 16.

CR

TESTING \ Missing

\   INCLUDE  test/DIGIT.f
\   INCLUDE  test/CASEON.f
\   INCLUDE  test/CASEOFF.f
\   INCLUDE  test/ENCLOSE.f
\   INCLUDE  test/(MAP).f
\   INCLUDE  test/(COMPARE).f
\   INCLUDE  test/KEY.f
\   INCLUDE  test/?TERMINAL.f
\   INCLUDE  test/INKEY.f
\   INCLUDE  test/SELECT.f
\   INCLUDE  test/F_SEEK.f
\   INCLUDE  test/F_CLOSE.f
\   INCLUDE  test/F_SYNC.f
\   INCLUDE  test/F_FGETPOS.f
\   INCLUDE  test/F_READ.f
\   INCLUDE  test/F_WRITE.f
\   INCLUDE  test/F_OPEN.f
\   INCLUDE  test/F_OPENDIR.f
\   INCLUDE  test/F_READDIR.f
\   INCLUDE  test/CMOVE.f
\   INCLUDE  test/CMOVE>.f
\   INCLUDE  test/SP@.f
\   INCLUDE  test/SP!.f
\   INCLUDE  test/RP@.f
\   INCLUDE  test/RP!.f
\   INCLUDE  test/P@.f
\   INCLUDE  test/P!.f
\   INCLUDE  test/b%buf.f
\   INCLUDE  test/b%scr.f
\   INCLUDE  test/l%scr.f
\   INCLUDE  test/+origin.f
\   INCLUDE  test/latest.f
\   INCLUDE  test/NFA.f
\   INCLUDE  test/LFA.f
\   INCLUDE  test/CFA.f
\   INCLUDE  test/PFA.f
\   INCLUDE  test/<NAME.f
\   INCLUDE  test/!CSP.f
\   INCLUDE  test/?error.f
\   INCLUDE  test/?comp.f
\   INCLUDE  test/?exec.f
\   INCLUDE  test/?pairs.f
\   INCLUDE  test/?csp.f
\   INCLUDE  test/?loading.f
\   INCLUDE  test/smudge.f
\   INCLUDE  test/;code.f
\   INCLUDE  test/bounds.f
\   INCLUDE  test/type.f
\   INCLUDE  test/-trailing.f
\   INCLUDE  test/query.f
\   INCLUDE  test/fill.f
\   INCLUDE  test/blanks.f
\   INCLUDE  test/pad.f
\   INCLUDE  test/,".f
\   INCLUDE  test/.(.f
\   INCLUDE  test/number.f
\   INCLUDE  test/[compile].f
\   INCLUDE  test/nullword.f ?
\   INCLUDE  test/?stack.f
\   INCLUDE  test/interpret.f
\   INCLUDE  test/vocabulary.f
\   INCLUDE  test/forth.f
\   INCLUDE  test/definitions.f
\   INCLUDE  test/(.f
\   INCLUDE  test/quit.f
\   INCLUDE  test/abort.f
\   INCLUDE  test/abort".f
\   INCLUDE  test/warm.f
\   INCLUDE  test/cold.f
\   INCLUDE  test/+-.f
\   INCLUDE  test/D+-.f
\   INCLUDE  test/dabs.f
\   INCLUDE  test/(line).f
\   INCLUDE  test/.line.f
\   INCLUDE  test/message.f
\   INCLUDE  test/reg@.f
\   INCLUDE  test/reg!.f
\   INCLUDE  test/mmu7@.f
\   INCLUDE  test/mmu7!.f
\   INCLUDE  test/M_P3DOS.f
\   INCLUDE  test/update.f
\   INCLUDE  test/buffer.f
\   INCLUDE  test/block.f
\ ...


\ Restore base and warning values
BASE !
