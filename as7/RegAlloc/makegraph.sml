(* makegraph.sml *)

signature MAKEGRAPH = 
sig
 val instrs2graph : Assem.instr list -> Flow.flowgraph * Flow.Graph.node list
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
   graph, i.e., the "def" set, the "use" set, and the "ismove" flag *)

  fun enterSrcs(def, node, srcs) = Graph.Table.enter(def, node, srcs) 

  fun enterDsts(use, node, dsts) = Graph.Table.enter(use, node, dsts)

  fun enterIsmove(ismove, node, assem) = if String.isSubstring "movl" assem 
                                         then Graph.Table.enter(ismove, node, true) 
                                         else Graph.Table.enter(ismove, node, false)

  (* Examine whether there is an edge from 'from' to 'to' *)
  fun isConnected(from, to) = 
  let
    fun memberOf(node, ns) = List.exists ( fn n => Flow.Graph.eq(node, n) ) ns
  in
    memberOf( to, Flow.Graph.succ(from) )
  end

  fun jumpToLabelEdge(graph, toAdd, labs, instr2node) = 
  let
    (* After cononicalization, it's safe to assume labs only contain one lab *)
    val target = hd labs 
    (* For each (instr, node) pair in instr2node, test whether an edge from toAdd to node needs to be added *)
    fun insertEdge(instr, node) = (
      case instr of Assem.LABEL {assem, lab} =>
        ( 
          (* If lab is the same as target and nodes haven't been connected previously *)
          if lab = target andalso not (isConnected(toAdd, node) )
          (* Connect two nodes *)
          
          then ( Flow.Graph.mk_edge {from = toAdd, to = node} )
          else () 
        )
         | _ => ()
    )
  in
    (* Apply insertEdge to every pair in istr2node *)
    List.app insertEdge instr2node
  end
   
  fun labelToJumpEdge(graph, toAdd, lab, instr2node) = 
  let
    (* For each (instr, node) pair in instr2node, test whether an edge from node to toAdd needs to be added *)
    fun insertEdge(instr, node) = (
      case instr of Assem.OPER {assem, dst, src, jump = SOME([target])} =>
        ( 
          (* If lab is the same as target and nodes haven't been connected previously *)
          if lab = target andalso not (isConnected(toAdd, node) )
          (* Connect two nodes *)
          then ( Flow.Graph.mk_edge {from = node, to = toAdd} )
          else ()
        )
         | _ => ()
    )
  in
    (* Apply insertEdge to every pair in istr2node *)
    List.app insertEdge instr2node
  end

  fun helper(instr::instrs):(Flow.flowgraph * Graph.node list * (Assem.instr * Graph.node) list) = 
  let
    (* Build graph for rest of the instrs *)
    val (Flow.FGRAPH {control, def, use, ismove}, nodes, instr2node) = helper(instrs)
    (* Create a new node for current instr *)
    val toAdd = Flow.Graph.newNode(control)
  in
    (* Make falling through edge *)
    ( case nodes of nil => () | n::ns => ( Flow.Graph.mk_edge {from = toAdd, to = n} ) );
    ( case instr of Assem.MOVE {assem, dst, src} => ( 
             Flow.FGRAPH {
               control = control, 
               def = enterDsts(def, toAdd, [dst]),
               use = enterSrcs(use, toAdd, [src]),
               ismove = enterIsmove(ismove, toAdd, assem)
             },
             toAdd::nodes,
             (instr, toAdd)::instr2node
         )
         | Assem.OPER {assem, dst, src, jump = NONE} => (
             Flow.FGRAPH {
               control = control,
               def = enterDsts(def, toAdd, dst),
               use = enterSrcs(use, toAdd, src),
               ismove = enterIsmove(ismove, toAdd, assem)
             },
             toAdd::nodes,
             (instr, toAdd)::instr2node
         )
         (* Search backward for labels *)
         | Assem.OPER {assem, dst, src, jump = SOME (labs)} =>
             (  jumpToLabelEdge(control, toAdd, labs, instr2node);
              ( Flow.FGRAPH {
                  control = control,
                  def = enterDsts(def, toAdd, dst),
                  use = enterSrcs(use, toAdd, src),
                  ismove = enterIsmove(ismove, toAdd, assem)
                }, 
                toAdd::nodes,
                (instr, toAdd)::instr2node )
             )
         (* Search backward for jumps *)
         | Assem.LABEL {assem, lab} =>
             (  labelToJumpEdge(control, toAdd, lab, instr2node); 
              ( Flow.FGRAPH {
                  control = control,
                  def = enterDsts(def, toAdd, nil),
                  use = enterSrcs(use, toAdd, nil),
                  ismove = enterIsmove(ismove, toAdd, assem)
                },
                toAdd::nodes,
                (instr, toAdd)::instr2node )
             )
     )
  end
         | helper(nil) = (
             Flow.FGRAPH { 
               control=Flow.Graph.newGraph(),
               def=Flow.Graph.Table.empty,
               use=Flow.Graph.Table.empty,
               ismove=Graph.Table.empty
             },
             nil,
             nil
           )
    
  fun instrs2graph(instrs) =
  let
    val (flowgraph, nodes, mappings) = helper(instrs)
  in
    (flowgraph, nodes)
  end
    
end
