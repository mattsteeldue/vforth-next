-----------------------------
Source-File naming convention
-----------------------------

Some vForth definitions aren't available until you give 

    NEEDS ``name`` 
    
and vForth interpreter tries to create ``name`` using a corresponding source
file, usually some ``name``.f file.
    
Using FAT, some 9 characters cannot be used as part of filename, i.e. they are 
illegal, namely:

    : ? / * | \ < > "   
   
For this reason, before trying to load ``name``.f source file, NEEDS acts a 
simple character mapping of ``name``.

    :           ->      %
    ?           ->      ^
    /           ->      %
    *           ->      &
    |           ->      $
    \           ->      _
    <           ->      {
    >           ->      }
    "           ->      ~
    
Here is a list of words which source filename went through this mapping:

    :NONAME     ->      %noname.f
    EXEC:       ->      exec%.f
    ?VOCAB      ->      ^vocab.f   
    M*/.f       ->      M&%.f    
    D<          ->      d{.f
    DUP>R       ->      dup}.f
    <>          ->      {}.f
    S"          ->      s~.f
    
    
    