(* liveness.sml *)

signature LIVENESS =
sig

  datatype igraph = 
      IGRAPH of {graph : Graph.graph,
                 tnode : Graph.node Temp.Table.table,
                 gtemp : Temp.temp Graph.Table.table,
                 moves : (Graph.node * Graph.node) list}

  val interferenceGraph : 
      Flow.flowgraph -> igraph * (Flow.Graph.node -> Temp.temp list)

  val show : igraph -> unit

end (* signature LIVENESS *)

structure Liveness : LIVENESS = 
struct

  datatype igraph = 
      IGRAPH of {graph : Graph.graph,
                 tnode : Graph.node Temp.Table.table,
                 gtemp : Temp.temp Graph.Table.table,
                 moves : (Graph.node * Graph.node) list}

  (* To construct the interference graph, it is convenient to
     construct a liveness map at each node in the FlowGraph first.
     For each node in the flowgraph, i.e., for each assembly 
     instruction, we want to easily look up the set S of live 
     temporaries. 
   *)

  type liveSet = unit Temp.Table.table * Temp.temp list
  type livenessMap = liveSet Flow.Graph.Table.table

  fun show(IGRAPH {graph, tnode, gtemp, moves}) =
  let
    fun printSuccNode(node) = print(" " ^ Int.toString(valOf( Graph.Table.look(gtemp, node) ) ) )
    fun printSucc(node) = List.app printSuccNode (Graph.succ(node) )
    fun printNode(node) = ( 
      print("Node " ^ Int.toString(valOf( Graph.Table.look(gtemp, node) ) ) );
      printSucc(node);
      print("\n")
    )
  in
    List.app printNode (Graph.nodes(graph) )
  end

  (* Create an empty set which contains an empty table and an empty list used for iteration *)
  fun newSet() = (Temp.Table.empty, nil)

  (* Union two live sets *)
  fun union( (t1, l1), (_, nil) ) = (t1, l1)
    | union( (t1, l1), (t2, temp::temps) ) = (
      (* If temp is not found in the first table, enter it to the first table and append it to the first list *) 
      case Temp.Table.look(t1, temp) of NONE => union( (Temp.Table.enter(t1, temp, ()), temp::l1), (t2, temps) )
         | _ => union( (t1, l1), (t2, temps) )
    )

  (* Compute set 1 minus set 2 *)
  (* Base case, empty set minus any set still equals an empty set *)
  fun diffSet( (t1, nil), _) = newSet()
    | diffSet( (t1, temp::temps), (t2, l2) ) = 
    let
      (* Compute diffrence for rest of the set *)
      val (diffT, diffL) = diffSet( (t1, temps), (t2, l2) )
    in
      (* If temp is not found in table 2 and is present in table 1, add it to diff table *)
      case Temp.Table.look(t2, temp) of NONE => (Temp.Table.enter(diffT, temp, ()), temp::diffL)
        (* Otherwise, no change is made *) 
         | _ => (diffT, diffL) 
    end
    
  (* Test set equality by first calculating set difference then testing whether difference is empty *)
  fun eqSet(s1, s2) = 
  let val diff12 = diffSet(s1, s2)
    val diff21 = diffSet(s2, s1)
  in
    case (diff12, diff21) of  ( (_, nil), (_, nil) ) => true
       | _ => false
  end

  (* Test an whether an array of sets are all equal *)
  fun eqSets(s1, s2) = 
  let
    fun helper(i) = 
      if i = Array.length(s1) 
      then true
      else if eqSet(Array.sub(s1, i), Array.sub(s2, i) )
      then helper(i + 1)
      else false
  in
    helper(0)
  end

  (* Add a new temp to live set *)
  fun insert(temp, (t, l) ) = (Temp.Table.enter(t, temp, ()), temp::l)

  (* Extend a live set by adding multiple temporaries *)
  fun extend(temps, liveSet) = List.foldr insert liveSet temps 

  (* Create a live set from a list of temporaries *)
  fun temps2Set(temps) = extend(temps, newSet() )

  (* Find the index of a node in the list *)
  fun index(target, nodes) = 
  let
    fun index'(i, nil) = (print("Error: Node not found!!!"); NONE)
      | index'(i, n::ns) = if n = target then SOME(i) else index'(i + 1, ns)
  in
    index'(0, nodes)
  end
    
  (* Extract the temporaries from a live set *)
  fun getTemps( (t, l) ) = l

  structure Temp : TEMP = Temp
  (* Iterate over all nodes and put their live-out temps in a table *)
  fun array2Table(arr, nodes) = 
  let
    val numOfNodes = List.length(nodes)
    fun helper(node, t) = 
    let
      val i = Graph.getInt(node)
    in
      Graph.Table.enter(t, node, Array.sub(arr, i) )
    end
  in
    List.foldr helper Graph.Table.empty nodes
  end

  (* Takes in a flow graph and return a hash table which stores live temporaries for each instruction node *)
  fun buildLivenessMap(Flow.FGRAPH{control, def, use, ismove}) = 
  let
    (* Get all the nodes in the graph *)
    val nodes = Graph.nodes(control)
    val numOfNodes = List.length(nodes)

    (* Create use[i] and def[i] for each node in the graph *)
    val useSet = Array.array(numOfNodes, newSet() )
    val defSet = Array.array(numOfNodes, newSet() )

    (* Create in[i], in'[i], out[i], out'[i] for each node in the graph *)
    val inSet = Array.array(numOfNodes, newSet() )
    val outSet = Array.array(numOfNodes, newSet() )
    val inSet' = Array.array(numOfNodes, newSet() )
    val outSet' = Array.array(numOfNodes, newSet() )

    (* initUse looks up temps used by node i and add them to use[i] *)
    fun initUse(node) = 
    let
      val i = Graph.getInt(node)
      (* Use i as array index *)
      val old = Array.sub(useSet, i)
      val useTemps = valOf(Graph.Table.look(use, node) )
      val new = extend(useTemps, old)
    in
      Array.update(useSet, i, new)
    end

    (* initDef looks up temps defined by node i and add them to use[i] *)
    fun initDef(node) =
    let
      val i = Graph.getInt(node)
      (* Use i as array index *)
      val old = Array.sub(defSet, i)
      val defTemps = valOf(Graph.Table.look(def, node) )
      val new = extend(defTemps, old)
    in
      Array.update(defSet, i, new)
    end

    (* in[n] <- use[n] U (out[n] - def[n]) *)
    fun updateIn(node) = 
    let
      val i = Graph.getInt(node)
      val use = Array.sub(useSet, i)
      val def = Array.sub(defSet, i)
      val out = Array.sub(outSet, i)
      val new = union(use, diffSet(out, def) )
    in
      Array.update(inSet', i, new)
    end
      
    (* out[n] <- U_{s \in succ[n]} in[s] *)
    fun updateOut(node) = 
    let
      val i = Graph.getInt(node)
      val succs = List.map Flow.Graph.getInt (Flow.Graph.succ(node) )
      fun helper(succ, out) = 
      let
        val inSucc = Array.sub(inSet, succ)
      in
        union(inSucc, out)
      end
      val new = List.foldr helper (newSet() ) succs
    in
      Array.update(outSet', i, new)
    end

    fun update node = ( updateIn(node); updateOut(node) )

    fun iteration() = ( 
      (* Update in[i] and out[i] for each node *)
      List.app update nodes;
      if (eqSets(inSet, inSet') andalso eqSets(outSet, outSet') ) 
      then ()
      (* If fixation point isn't reached, update inSet and outSet and continue iteration *)
      else (Array.copy{src=inSet', dst=inSet, di=0}; Array.copy{src=outSet', dst=outSet, di=0}; iteration() )
    )
      
  in
    (* Initialize use[i] and def[i] for each node in the graph *)
    List.app initUse nodes;
    List.app initDef nodes;
    iteration();
    array2Table(outSet, nodes)
  end
    
  (* after constructing the livenessMap, it is quite easy to
     construct the interference graph, just scan each node in
     the Flow Graph, add interference edges properly ... 
   *)
   
  (* Merge two lists and remove redundant elements *)
  fun mergeLists(l1, nil) = l1
    | mergeLists(nil, l2) = l2
    | mergeLists(n::ns, l2) = 
    if (List.exists (fn x => x = n) l2)
    then mergeLists(ns, l2)
    else mergeLists(ns, n::l2)

  (* Get all temporaries of the graph *)
  fun getAllTemps(nil, _, _) = nil
    | getAllTemps(n::ns, def, use) = 
    let
      val defTemps = valOf(Graph.Table.look(def, n) )
      val useTemps = valOf(Graph.Table.look(use, n) )
      val allTemps = mergeLists(defTemps, useTemps)
      val restTemps = getAllTemps(ns, def, use)
    in
      mergeLists(allTemps, restTemps)
    end

  (* Initialize the graph given information about all the temps *)
  fun initIgraph(nodes, def, use) = 
  let
    val g = IGRAPH {
      graph = Graph.newGraph(),
      tnode = Temp.Table.empty,
      gtemp = Graph.Table.empty,
      moves = nil
    }
    val temps = getAllTemps(nodes, def, use)
    fun helper(temp, IGRAPH{graph, tnode, gtemp, moves}) =
    let
      val toAdd = Graph.newNode(graph)
    in
      IGRAPH {
        graph = graph, 
        tnode = Temp.Table.enter(tnode, temp, toAdd), 
        gtemp = Graph.Table.enter(gtemp, toAdd, temp),
        moves = moves
      }
    end
  in
    List.foldr helper g temps
  end

  fun buildIgraph(liveMap, Flow.FGRAPH{control, def, use, ismove}) = 
  let
    val nodes = Flow.Graph.nodes(control)
    val IGRAPH{graph, tnode, gtemp, moves} = initIgraph(nodes, def, use)
    
    (* Function returned by buildIgraph, look up all live temporaries at an instruction node *)
    fun lookLiveness(node) = ( 
      case Graph.Table.look(liveMap, node) of NONE => ErrorMsg.impossible("Instrcuction node not found!")
         | SOME(t, l) => l
    )

    (* Add interference edges for an instruction node *)
    fun helperForNode(node) = 
    let
      (* def[i] *)
      val defs = valOf(Flow.Graph.Table.look(def, node) )
      (* out[i] *)
      val (outSet, outList) = valOf(Flow.Graph.Table.look(liveMap, node) )

      (* Add interference edges for a temporary defined in the instruction node *)
      fun helperForDef(def) = 
      let
        (* Determine whether to add an interference edge for a live-out temporary *)
        fun helperForOut(out) = 
          if def = out
          then ()
          else (
            Graph.mk_edge{from=valOf(Temp.Table.look(tnode, def) ), to=valOf(Temp.Table.look(tnode, out) )};
            Graph.mk_edge{to=valOf(Temp.Table.look(tnode, def) ), from=valOf(Temp.Table.look(tnode, out) )} 
          )
      in
        (* Apply helperForOuut to all live-out temporaries *)
        List.app helperForOut outList
      end

    in
      (* Apply helperForDef to all temporaries defined in the instruction node *)
      List.app helperForDef defs
    end
  in
    (* Apply helperForNode to all nodes in the Igraph *)
    List.app helperForNode nodes;
    (IGRAPH{graph=graph, tnode=tnode, gtemp=gtemp, moves=moves}, lookLiveness)
  end

  fun interferenceGraph(flowgraph) = 
  let
    val liveMap = buildLivenessMap(flowgraph)
    val (iGraph, lookLiveness) = buildIgraph(liveMap, flowgraph)
  in
    (iGraph, lookLiveness)
  end


end (* structure Liveness *)

     

               
