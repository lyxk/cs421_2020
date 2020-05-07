val prog = ASSIGN("a1", CONST 500) ;
interp(prog);

val prog = SEQ(ASSIGN("a2", CONST 6),PRINT[VAR"a2"]);
interp(prog);

val prog = SEQ(SEQ(ASSIGN("a3", CONST 500),ASSIGN("b", BINOP(VAR"a3", MINUS, ESEQ(PRINT[VAR "a3"], CONST 100)))),
	       PRINT [ESEQ(PRINT[VAR"b"],VAR "a3"), 
		      BINOP(VAR "a3", TIMES, VAR "a3"), 
		      BINOP(ESEQ(ASSIGN("a3div2", BINOP(VAR"a3", DIV , CONST 2)), 
				 ESEQ(ASSIGN("a3div2plusa3", BINOP(ESEQ(ASSIGN("a3diva3",
									       BINOP(VAR"a3", DIV,VAR"a3")
									      ),
									ESEQ(PRINT[VAR"a3diva3"],VAR"a3div2")
								   ),
						   	           PLUS, 
							           VAR"a3")
					    ), 
				      VAR"a3div2plusa3"
				     )
			        ), 
			    MINUS, 
			    VAR"a3"
		           )
		     ]
	      ) ;
interp(prog);

val prog = SEQ(ASSIGN("a", BINOP(CONST 3, TIMES, CONST 2)),
                SEQ(ASSIGN("b", BINOP(VAR"a", DIV, CONST 3)),
                    PRINT[VAR"a", VAR "b", BINOP(ESEQ(ASSIGN("b", CONST 1000), VAR "a"), TIMES, VAR "b")]
                )
           );
interp(prog);


val prog = SEQ(ASSIGN("a",BINOP(CONST 5, PLUS, CONST 3)),
               SEQ(ASSIGN("b",ESEQ(PRINT[VAR"a",VAR"a",BINOP(ESEQ(PRINT[VAR"a",VAR"a",VAR"a",VAR"a"],VAR"a"),MINUS,CONST 1)],  
                                   BINOP(CONST 10, TIMES, VAR"a")
                                  )
                         ),
                   PRINT[VAR"b",VAR"b",VAR"b",VAR"b",VAR"b",VAR"a"]
                  )
              );
interp(prog);

val prog = SEQ(ASSIGN("a",BINOP(CONST 5, PLUS, CONST 3)),
               SEQ(ASSIGN("b",ESEQ(PRINT[VAR"a",BINOP(VAR"a",MINUS,CONST 1)],  
                                   BINOP(ESEQ(ASSIGN("c", CONST 999),CONST 10), TIMES, VAR"c")
                                  )
                         ),
                   PRINT[VAR"b"]
                  )
              );
interp(prog);

val prog = SEQ(ASSIGN("a",BINOP(CONST 5, PLUS, CONST 3)),
               SEQ(ASSIGN("b",ESEQ(PRINT[VAR"a",BINOP(VAR"a",MINUS,CONST 1)],  
                                   BINOP(CONST 10, TIMES, VAR"a")
                                  )
                         ),
                   PRINT[VAR"b"]
                  )
              );
interp(prog);
