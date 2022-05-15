\
\ set-fence.f
\
\ Modify FENCE to prvent FORGET to clear below it.
\
\   ##  USE WITH CARE ##
\
\ We have to patch some specific cells to the value of HERE or LATEST
: SET-FENCE ( a -- ) [ HEX ]
  DUP              FENCE !
  DUP         1C +ORIGIN !   \ FENCE value in cold area
  DUP         1E +ORIGIN !   \ DP    value in cold area
  >BODY LFA @ 0C +ORIGIN !   \ LATEST value in origin area
  VOC-LINK  @ 20 +ORIGIN !   \ just to be sure
; DECIMAL

