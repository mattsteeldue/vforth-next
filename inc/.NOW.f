    \
\ . now.f
\
.( .NOW )
\
\ real-time-clock module not present
\
NEEDS .FAT-TIME
NEEDS .FAT-DATE
NEEDS IDE_RTC

: .NOW ( -- )
    BASE @
    IDE_RTC
    .FAT-DATE SPACE .FAT-TIME
    DROP  
    BASE !
;

