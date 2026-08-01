\
\ DIR-WILDCARD-MANUAL.f
\
.( DIR-WILDCARD-MANUAL )
\
\ Manual/visual test script for DIR and WILDCARD (lib/dir.f, inc/wildcard.f,
\ core words F_OPENDIR/F_READDIR). NOT a {...}T automated suite: DIR prints
\ a human-readable directory listing whose exact content (file names, sizes,
\ dates) depends on what is really on the SD card being tested -- the CSpect
\ image and a real ZX Spectrum Next SD card will differ. What must NOT differ
\ is the FILTERING BEHAVIOUR: which steps show everything, which show a
\ subset, which show nothing, which report an error -- and none of them may
\ hang or crash.
\
\ How to use: run this file once on CSpect and once on real hardware
\ (INCLUDE test/dir-wildcard-manual.f), read the ">>> expect" line printed
\ before each listing, press a key to move to the next step, and compare
\ the two transcripts against each other.
\
\ Prerequisites: this repo mirrored under the current drive (inc/, lib/
\ exist as real folders next to where vForth was launched -- true for both
\ the CSpect SD image and a nextsync-mirrored real-hardware SD card).
\
NEEDS DIR
NEEDS WAIT-KEY

: PAUSE-STEP  ( -- )
    CR ." --- press any key to continue ---" WAIT-KEY
;

BASE @ DECIMAL

CR ." ============================================================" CR
." STEP 1 -- baseline: full listing, default wildcard (*.*)"        CR
." Folder: inc   (all entries are .f files)"                        CR
." >>> expect every entry in the folder"                             CR
CR
DIR inc
CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 2 -- real filter: mixed-extension folder, .BAS only"        CR
." Folder: .  (repo root: .bin/.bas/.md/.txt/.tap files + subdirs)"  CR
." >>> expect ONLY the .bas files (compare count against Step 1's"   CR
." >>> full listing of a DIFFERENT folder -- this is the step that"  CR
." >>> actually proves OS-side filtering, since inc/ above is all"   CR
." >>> .f anyway)"                                                   CR
." (if '.' is not accepted as 'current directory' on your setup,"    CR
." substitute the real folder name vForth was launched from)"        CR
WILDCARD *.BAS
CR
DIR .
CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 3 -- sticky pattern: same WILDCARD, different folder"       CR
." Folder: dot   (dot-command binaries)"                             CR
." >>> WILDCARD is NOT reset between DIR calls (by design, see"      CR
." >>> inc/wildcard.f) -- this call did NOT repeat WILDCARD *.BAS,"   CR
." >>> yet the filter still applies here"                             CR
CR
DIR dot
CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 4 -- pattern matching nothing: empty-set path"               CR
." Folder: inc  (all .f -- no .zzz files can exist)"                 CR
." >>> expect the #43 'File not found' message, NOT a hang or a"      CR
." >>> crash (this exercises the empty-set fix in DIR-SHELL-SORT)"   CR
WILDCARD *.ZZZ
CR
DIR inc
CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 5 -- reset to match-all (bare WILDCARD)"                     CR
." Folder: inc"                                                      CR
." >>> expect the SAME full listing as Step 1 again"                 CR
WILDCARD
CR
DIR inc
CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 6 -- single-character wildcard (?)"                          CR
." Folder: .  (repo root)"                                            CR
." >>> WILDCARD ?.??? matches only 1-character base names -- expect" CR
." >>> a much shorter list than Step 2's *.BAS (likely empty; if so"  CR
." >>> that is correct too, see Step 4)"                              CR
WILDCARD ?.???
CR
DIR .
CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 7 -- drive-letter switch (DIR-DRIVE)"                        CR
." Default is CHAR C. Switching to CHAR D and listing 'inc' again"   CR
." on that drive."                                                    CR
." >>> if D: does not exist, or has no matching 'inc' folder on"      CR
." >>> your setup, expect a graceful error message -- NOT a hang"     CR
." >>> or a crash. If D: DOES mirror this SD layout, expect the"      CR
." >>> same kind of listing as Step 1."                               CR
WILDCARD
CHAR D DIR-DRIVE !
CR
DIR inc
CR
." >>> restoring default drive (CHAR C)"                             CR
CHAR C DIR-DRIVE !
PAUSE-STEP

CR ." ============================================================" CR
." STEP 8 -- nonexistent drive letter: graceful failure"             CR
." >>> expect an error message (NOT a hang/crash), then the drive"    CR
." >>> is restored to C: right after"                                 CR
CHAR Z DIR-DRIVE !
CR
DIR inc
CR
CHAR C DIR-DRIVE !
." >>> drive restored to C:"                                          CR
PAUSE-STEP

CR ." ============================================================" CR
." STEP 9 -- nonexistent path on a valid drive"                       CR
." >>> expect an error message (NOT a hang/crash)"                    CR
WILDCARD
CR
DIR this-path-does-not-exist
CR
PAUSE-STEP

CR ." ============================================================" CR
." Sequence complete."                                                CR
." Compare this transcript against the run on the OTHER platform"    CR
." (CSpect vs real hardware): the filtering behaviour of each step"  CR
." (all / subset / none+error / drive error / path error) must"       CR
." match; only the actual file names, sizes and dates are expected"  CR
." to differ."                                                        CR
CR

BASE !

