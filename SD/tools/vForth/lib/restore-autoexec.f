\
\ restore-autoexec.f
\
\    ##  USE WITH CARE  ##


\ First check if there is a NOOP in the nth position of ABORT
' ABORT >BODY 13 CELLS + @
' NOOP - 14 ?ERROR

\ Then restore AUTOEXEC in-place
' AUTOEXEC
' ABORT >BODY 13 CELLS + !


