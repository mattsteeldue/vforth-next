\
\ removedir.f
\
.( REMOVEDIR )
\
\ remove a directory. Used in the form:
\
\   REMOVEDIR  cccc
\
\ example  REMOVEDIR C:/tools/vForth/olddir

NEEDS IDE_PATH

: REMOVEDIR ( -- )
    (PARSE-PATH)  3 IDE_PATH   \ f  -- remove directory
    #44 ?ERROR                 \    -- NextZXOS DOS call error
;
