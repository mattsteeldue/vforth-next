This directory and subdir contain .zip file.
Version number is given between "underscore", Build number is the last number and is intended as a date in YYYYMMDD format.

HOW TO START
------------
1. Download the latest .zip file from Project Download directory <https://github.com/mattsteeldue/vforth-next/tree/master/download>
2. Copy from .zip file to Next's SD card the whole "forth" directory
3. Forth System is loaded and activated by the Basic program C:/forth/forth15_loader.bas

HOW TO CONTINUE
---------------
1. The loader CLEARs RAMTOP to 25343, says it is loading the CODE part, then allows 5 seconds to be stopped (if you need to).
2. Then it loads another Basic program that runs LINE 20 to perform a COLD start, but RUN performs a WARM start
3. Before entering Forth, it OPEN# some text file to be used from within Forth environment.
4. To quit to Basic, you can give BYE
5. To re-enter Forth with a WARM start, you have to give interactively RUN.
6. To re-enter Forth with a COLD start, you have to give interactively RUN 20 instead.
