signature MAIN =
sig
  val comp : string -> unit
 
  val testit : unit -> unit
end

(* print( case Symbol.look(Env.base_tenv, Symbol.symbol "int") of SOME(Types.INT) => "INT" | _ => "NONE" ); *)
structure Main : MAIN =
struct
  fun comp fname = (Semant.transprog (Parse.parse fname); ())

  val num_of_tests = 49;

  fun testit() = 
    let fun h(k) = 
          if (k <= num_of_tests) then
            (let val name = Format.format "test%d.tig" [Format.INT (k)] 
                 val dirname = "/c/cs421/as/testcases/"
              in print "\n";
                 print "------------------parsing ";
                 print name;
                 print "------------------------\n";
                 comp (dirname^name)
             end; h(k+1))
          else ()
     in h(1)
    end

end

