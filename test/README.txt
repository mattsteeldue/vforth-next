-----------------------------
Source-File naming convention
-----------------------------

This test suite is started by importing the main source file 

    INCLUDE TEST/CORE-TESTS.f
    
Using FAT, some 9 characters cannot be used as part of filename, i.e. they are 
illegal, namely:

    : ? / * | \ < > "   
   
For this reason, many source files had to be renamed using the following map:

    :           ->      %
    ?           ->      ^
    /           ->      %
    *           ->      &
    |           ->      $
    \           ->      _
    <           ->      {
    >           ->      }
    "           ->      ~
    
Here is an example list of words which source filename went through this 
mapping:

    :           ->      %.f
    /MOD        ->      %mod.f
    ?DUP        ->      ^dup.f    
    >R          ->      }r.f
    U<          ->      u{.f
    S"          ->      s~.f
