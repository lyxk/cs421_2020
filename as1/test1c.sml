val prog = SEQ(SEQ(ASSIGN("a", CONST 8), PRINT [VAR "a"]), PRINT []);
maxargs(prog);

val prog = SEQ(PRINT [VAR "a"], PRINT []);
maxargs(prog);

val prog = SEQ(ASSIGN("a", CONST 6), PRINT [VAR "b"]);
interp(prog);