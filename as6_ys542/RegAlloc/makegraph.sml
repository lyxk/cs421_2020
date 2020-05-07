(* makegraph.sml *)

signature MAKEGRAPH = 
sig
 val instrs2graphRecursive : Assem.instr list
    -> Flow.flowgraph * Flow.Graph.node list * (Assem.instr * Flow.Graph.node) list
 
  val instrs2graph : Assem.instr list
    -> Flow.flowgraph * Flow.Graph.node list
end

structure MakeGraph : MAKEGRAPH =
struct

(* The "instrs2graph" function takes a list of assembly instructions,
   and constructs its flowgraph and also returns the list of nodes in 
   the flowgraph. The instructions exactly correspond to the nodes in 
   the graph. If instruction m can be followed by instruction n (either
   by a jump or by falling through), there should be an edge from m to n
   in the graph.

   The flowgraph also maintains several attributes for each node in the 
   graph, i.e., the "def" set, the "use" set, and the "ismove" flag

 *)
  
  fun getAsm (Assem.OPER{assem, dst, src, jump}) = assem
    | getAsm (Assem.LABEL{assem, lab}) = assem
    | getAsm (Assem.MOVE{assem, dst, src}) = assem

  fun doesEdgeExist(from, to) = 
  let
    fun doesListContainNode([], node) = false
      | doesListContainNode(n::rest, node) = 
      if (Flow.Graph.eq(n, node))
      then true
      else doesListContainNode(rest, node)
  in
    doesListContainNode(Flow.Graph.succ(from), to)
  end
  

  fun instrs2graphRecursive [] =
    (* First, the base case! *)
    (Flow.FGRAPH({ 
      control=Flow.Graph.newGraph(),
      def=Flow.Graph.Table.empty,
      use=Flow.Graph.Table.empty,
      ismove=Graph.Table.empty
    }), [], [])

    (* Now for the recursive case! *)
    | instrs2graphRecursive(instr::rest) =
    let
      (* Helper functions *)

      (* When we hit a JUMP inst, look FORWARD to find the label we jump to *)
      fun insertForwardJumpEdge(graph, toAdd, labs, mappings) = 
        let
          val labToMatch = hd labs
        in
          case mappings of [] => ()
             | (Assem.LABEL{assem, lab}, node)::rest =>
                 (if (lab = labToMatch)
                  then ((if (not(doesEdgeExist(toAdd, node))) then Flow.Graph.mk_edge{from=toAdd, to=node} else ());
                        ()) 
                  else (insertForwardJumpEdge(graph, toAdd, labs, rest)))
             | mapping::rest => insertForwardJumpEdge(graph, toAdd, labs, rest)
        end

      (* When we hit a LABEL inst, look FORWARD to find any JUMPS that jump to this label *)
      fun insertBackwardJumpEdges(graph, toAdd, labToMatch, mappings) =
        case mappings of [] => ()
           | (Assem.OPER{assem, dst, src, jump=SOME([lab])}, node)::rest =>
               (if (lab = labToMatch)
                then ((if(not(doesEdgeExist(node, toAdd))) then Flow.Graph.mk_edge{from=node, to=toAdd} else ()); 
                     insertBackwardJumpEdges(graph, toAdd, labToMatch, rest)) 
                else (insertBackwardJumpEdges(graph, toAdd, labToMatch, rest)))
           | mapping::rest => insertBackwardJumpEdges(graph, toAdd, labToMatch, rest)
      
      (* These functions add the appropriate metadata to tables if necessary *) 
      fun enterDsts(node, def, dst) = Graph.Table.enter(def, node, dst)
      fun enterSrcs(node, use, src) = Graph.Table.enter(use, node, src)
      fun enterIsMove(node, ismove, assem) = if(String.isSubstring "movl" assem)
                                             then (Graph.Table.enter(ismove, node, true))
                                             else (Graph.Table.enter(ismove, node, false))

      (* Make the rest of the graph *)
      val (Flow.FGRAPH{control, def, use, ismove}, nodes, mappings) = instrs2graphRecursive(rest)

      (* Make the new node to add and hook it up *)
      val toAdd = Flow.Graph.newNode(control)
      val newMappings = (instr, toAdd)::mappings
      val _ =
        case nodes of [] => ()
           | _ => (Flow.Graph.mk_edge{from=toAdd, to=hd(nodes)})
    in
      (* Jump case *)
      case instr of Assem.OPER{assem, dst, src, jump=SOME(lab)} =>
        (* Traverse forward to find where to jump to *)
        (insertForwardJumpEdge(control, toAdd, lab, mappings); 
             (Flow.FGRAPH{
                control=control,
                def=enterDsts(toAdd, def, dst),
                use=enterSrcs(toAdd, use, src),
                ismove=enterIsMove(toAdd, ismove, assem)},
              toAdd::nodes,
              newMappings))

        (* No jump case (easy *)
         | Assem.OPER{assem, dst, src, jump=NONE} =>
             (Flow.FGRAPH{
                control=control,
                def=enterDsts(toAdd, def, dst),
                use=enterSrcs(toAdd, use, src),
                ismove=enterIsMove(toAdd, ismove, assem)},
             toAdd::nodes,
             newMappings)

        (* Same as no jump case *)
         | Assem.MOVE{assem, dst, src} => 
             (Flow.FGRAPH{
                control=control,
                def=enterDsts(toAdd, def, [dst]),
                use=enterSrcs(toAdd, use, [src]),
                ismove=enterIsMove(toAdd, ismove, assem)},
             toAdd::nodes,
             newMappings)

        (* Label case *)
         | Assem.LABEL{assem, lab} =>
             (* Traverse forward to find places that could jump here *)
             (insertBackwardJumpEdges(control, toAdd, lab, mappings);
             (Flow.FGRAPH{
                control=control,
                def=enterDsts(toAdd, def, []),
                use=enterSrcs(toAdd, use, []),
                ismove=enterIsMove(toAdd, ismove, assem)},
              toAdd::nodes,
              newMappings))
    end

  fun debugFlowGraph(flowgraph, nodes, mappings) = 
  let
    fun findMatchingInst(node, []) = "\tUNKNOWN INST\n"
      | findMatchingInst(node, (headInstr, headNode)::r) =
        if (Flow.Graph.eq(node, headNode))
        then (getAsm(headInstr))
        else (findMatchingInst(node, r))
  in
    app (fn (instr, node) => 
      let
        val successors = Flow.Graph.succ(node)
        val successorInsts = map(fn n => findMatchingInst(n, mappings)) successors
      in
        print(getAsm(instr));
        (app(fn asm => print("\t\t ---> "^asm)) successorInsts)
      end
    ) mappings
  end


  (* Just starts the recursive process *)
  fun instrs2graph(instrs) =
  let
    val (flowgraph, nodes, mappings) = instrs2graphRecursive(instrs)
    (*val _ = debugFlowGraph(flowgraph, nodes, mappings)*)
  in
    (flowgraph, nodes)
  end
end
