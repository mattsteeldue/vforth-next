2025-09-14

On real-hardware Sinclair ZX Spectrum Next
------------------------------------------

1. Install, just copy SD/tools/vForth content into SD  at C:/tools/vForth
   or extract the very same content from the latest zipped file
   vforth-next/download/vForth_18e_yyyymmdd.zip 

2. Run, from File-Browser execute the Basic program C:/tools/vForth/Forth18_loader.bas



On #CSpect emulator
-------------------

The operations of points 1. and 2. has to be performed within an SD image like   tbblue.mmc  
To operato on a SD image, you can use HDFM-GOOEY available here: http://zxbasic.uk/nextbuild/hdfmgooey/
Remember: to copy a file to SD while you're running vForth environment, you have to temporarily suspend any activity on the SD card.
In vForth, this can be done via   REMOUNT   available after you give NEEDS REMOUNT .


Debian / Ubuntu / Linux-Lite
----------------------------

Install the latest  "Mono"  cross platform open source .NET framework

  $ sudo apt install mono-complete

start CSpect

  $ mono CSpect.exe -sound -tv -w3  -zxnext -nextrom  -mmc=./tbblue.mmc



Window / MacOS / ..
-------------------

THere is a very nice quickstart guide by Marco's retrobits
https://retrobits.altervista.org/blog/dogday-cspect-quickstart/



