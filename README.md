Forth on Sinclair ZX Spectrum Next

vForth1.15

On April 27th 2020, I received my  ZX Spectrum Next  (Accelerated)  and immediately tried to port my Forth to the Next environment. 
The purpose was to make Screens / BLOCKs system available using ZxNextOS APIs. 
Having done it in the past for ZX Microdrive and MGT Disciple floppy diskette  I really thought it was worth give a try on ZxNextOs.
I'm putting here the version that are stable enough to be published.

Screens are stored in a file inside the SD card called "!Blocks.txt" 8 MBytes long and it can hold 16.383 Screens (while MGT version can hold 1.560 and Microdrive 254 only). Content of STRM variable determines which opened stream is in use: ZXNEXTOS needs a value 2 to indicate the first OPEN# channel.  

In this implementation a Screen is equivalent to a BLOCK that is 512 bytes, for legacy reasons.

I implemented an ASSEMBLER vocabulary with notation as explained in Wiki pages <https://github.com/mattsteeldue/forth-next/wiki>.  
This ASSEMBLER provides Z80N extension op-codes.
