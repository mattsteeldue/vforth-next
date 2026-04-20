\
\ .date-time.f
\
.( .DATE-TIME )
\
\ real-time-clock module not present
\
NEEDS .FAT-TIME
NEEDS .FAT-DATE
NEEDS IDE_RTC

: .DATE-TIME ( -- )      
    IDE_RTC
    .FAT-DATE
    .FAT-TIME
;

