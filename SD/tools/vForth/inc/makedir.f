\
\ makedir.f
\
.( MAKEDIR )
\
\ create a directory. Used in the form:
\
\   MAKEDIR  cccc
\
\ example  MAKEDIR C:/tools/vForth/newdir

NEEDS IDE_PATH

: MAKEDIR ( -- )
    (PARSE-PATH)  2 IDE_PATH   \ f  -- create directory
    #44 ?ERROR                 \    -- NextZXOS DOS call error
;
