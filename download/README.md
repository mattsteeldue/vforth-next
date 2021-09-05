This directory and subdir contain .zip file.
Version number is given between "underscore", Build number is the last number and is intended as a date in YYYYMMDD format.

HOW TO START
------------
1. Download the latest .zip file from Project Download directory https://github.com/mattsteeldue/vforth-next/tree/master/download
2. Copy from .zip file to Next's SD card the whole "forth" directory
3. Forth System is loaded and activated by the Basic program C:/tools/vforth/forth15_loader.bas

HOW TO CONTINUE
---------------
1. forth15_loader.bas  loads the CODE part, It CLEARs RAMTOP to 25087, so little Basic space is left.
2. It then loads another small Basic program that runs LINE 20 to perform a COLD start to Forth.
3. From Forth, BYE to quit to Basic.
5. From Basic, RUN to perform a WARM start to Forth.
6. From Basic, RUN 20 to perform a COLD starto to Forth.
