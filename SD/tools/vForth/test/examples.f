\
\ test/examples.f
\


NEEDS TESTING

TESTING Examples

T{  1 1   +     ->     2  }T  \ Ok
T{  1 2 3 SWAP  -> 1 3 2  }T  \ Ok

T{  1 2 3 SWAP  -> 1 2 3  }T  \ gives: Incorrect result
T{  1 2   SWAP  -> 1      }T  \ gives: Wrong number of results.

