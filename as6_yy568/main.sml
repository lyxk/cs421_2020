(* main.sml *)

signature MAIN = 
sig 
  val compile : string -> unit
end (* signature MAIN *)

structure Main : MAIN = 
struct
  structure Semant = SemantGen(Register)
  structure RegAlloc = RegAllocGen(Register)

  structure C = Codegen
  structure F = C.F
  structure S = Symbol

  fun emitproc out (F.DATA {lab, s}) = TextIO.output( out, C.string(lab, s) )

    | emitproc out (F.PROC {name, body, frame}) =
        let 
            (*val _ = print ("Emit " ^ S.name name ^ "\n")
            val _ = Printtree.printtree(out, body) *)
            (*
              datatype frag = PROC of {
                name : Temp.label, 
                body: Tree.stm, 
                frame: frame
              } 
              | DATA of { lab : Temp.label, s: string } 
            *)
            fun printHelper (out, nil) = ()
              | printHelper (out, t::ts) = (Printtree.printtree(out, t); printHelper(out, ts))
            val stms = Canon.linearize body
            val stms' = Canon.traceSchedule(Canon.basicBlocks stms)
            (*val _ = printHelper(out,stms');*)

            val instrs = List.concat(map C.codegen stms') 

            (* 
             * Once the RegAlloc module is ready, you can get 
             * (1) a new list of body instrs together with its live 
             *     temporaries: (Assem.instr * Temp.temp list) list
             *
             * (2) a register allocation table
             *
             * These information then can be fed into the C.procEntryExit
             * function to generate the proper function calling sequence,
             * procedure entry/exit sequences etc.
             *     
             *)

            
             val (flowgraph, nodelist) = MakeGraph.instrs2graph(instrs)
             val (igraph, tempConversionFunction) = Liveness.interferenceGraph(flowgraph)
            
             val alloc = RegAlloc.color {
               interference = igraph,
               initial = Register.initial,
               registers = Register.registers
             }
            
             val processedInstrs = C.procEntryExit {
               name = name,
               body = (map ( fn inst => (inst, nil) ) instrs),
               allocation = alloc,
               formals = [],
               frame = frame
             }

            val format0 = Assem.format (fn t => "t" ^ Temp.makestring t)

         in app (fn i => TextIO.output(out, format0 i)) processedInstrs
        end

  fun withOpenFile fname f = 
        let 
          val out = TextIO.openOut fname
        in 
          (f out before TextIO.closeOut out) handle e => (TextIO.closeOut out; raise e)
        end 

  fun compile filename = 
        let 
          val frags = Semant.transprog(Parse.parse filename)
        in
          withOpenFile (filename ^ ".s") (fn out => (app (emitproc out) frags))
        end

end (* structure Main *)


