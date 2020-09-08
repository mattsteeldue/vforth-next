Forth on Sinclair ZX Spectrum Next

vForth1.5

On April 27th 2020, I received my  ZX Spectrum Next  (Accelerated)  and immediately tried to port my Forth to the Next environment. 
The purpose was to make Screens / BLOCKs system available using ZxNextOS APIs. 
Having done it in the past for ZX Microdrive and MGT Disciple floppy diskette  I really thought it was worth give a try on ZxNextOs.
I'm putting here the version that are stable enough to be published.

Screens are stored in a file inside the SD card called "!Blocks.txt" 16 MBytes long and it can hold 16.383 1KByte-Screens (while MGT version and Microdrive - 512 Byte Screens - can hold 1.560 and 254 respectively). Content of STRM variable determines which opened stream is in use: ZXNEXTOS needs a value 2 to indicate the first OPEN# channel. 

In the latest implementation a Screen is two BLOCKs that is 1024 bytes (at last).

I implemented an ASSEMBLER vocabulary with notation as explained in Wiki pages <https://github.com/mattsteeldue/forth-next/wiki>.  
This ASSEMBLER provides Z80N extension op-codes.

The Wiki in this repository is getting some shape, I suggesto to pay a visit.
