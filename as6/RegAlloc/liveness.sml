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
   
  (*
   * Do we really need an outstream here?
   *
   *
   *  val show : outstream * igraph -> unit
   *)
   
  val show : igraph -> unit

  val showLiveset : Flow.flowgraph * (Assem.instr * Flow.Graph.node) list  * Assem.instr list-> unit

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

  
  fun show(IGRAPH{graph, tnode, gtemp, moves}) =
    (app (fn tempNode =>
            (print("Node "^Int.toString(valOf (Graph.Table.look(gtemp, tempNode)))^" conflicts with: ");
            app (fn conflictingTempNode =>
                    print(Int.toString(valOf (Graph.Table.look(gtemp, conflictingTempNode)))^" ")
              ) (Graph.succ(tempNode));
             print("\n"))
      ) (Graph.nodes(graph)))

  (* New liveset *)
  fun newLS() = (Temp.Table.empty, [])
 
  (* Union of two live sets *)
  fun unionLS((t1, l1), (t2, [])) = (t1, l1)
    | unionLS((t1, l1), (t2, temp::rest)) =
      case Temp.Table.look(t1, temp) of 
           NONE => 
             unionLS((Temp.Table.enter(t1, temp, ()), temp::l1), (t2, rest))
         | _ =>
             unionLS((t1, l1), (t2, rest))
      

  (* Set diff of two livesets *)
  fun diffLS((t1, []), (t2, l2)) = newLS()
    | diffLS((t1, temp::rest), (t2, l2)) =
      let
        val (tr, lr) = diffLS((t1, rest), (t2, l2))
      in
        case Temp.Table.look(t2, temp) of NONE => 
              (Temp.Table.enter(tr, temp, ()), temp::lr)
           | _ => (tr, lr)
      end
 
  (* Are the two livesets equal? *)
  fun equalLS(ls1, ls2) =
    let
      val a = diffLS(ls1, ls2)
      val b = diffLS(ls2, ls2)
    in
      case (a, b) of ((_, []), (_, [])) => true
         | _ => false
    end

  (* List of temps --> LiveSet *)
  fun tempListToLS [] = newLS()
    | tempListToLS (temp::rest) = 
      let
        val (tr, lr) = tempListToLS(rest)
      in
        (Temp.Table.enter(tr, temp, ()), temp::lr)
      end

  (* Add to liveset *)
  fun addLS((t, l), temp) = (Temp.Table.enter(t, temp, ()), temp::l)
  
  (* Add many temps to liveset *)
  fun addManyLS(ls, temps) =
    case temps of [] => ls
       | temp::rest => addManyLS(addLS(ls, temp), rest)

  (* Find the index of a node in a list *)
  fun getNodeIdx(node, nodes) = 
    let
      fun r(n, ns, i) = 
        case ns of [] => (print("Couldn't find a node!!! Error!!\n"); i)
           | nx::rest => (if Flow.Graph.eq(n, nx) then i else r(n, rest, i + 1))
    in
      r(node, nodes, 0)
    end

  (* Extract the temp list from a liveset *)
  fun lsToTempList((t, l)) = l

  (* Used at the end of main of alg *)
  fun arraySetToLiveSetTable(lsArray, nodes) =
    let 
      val len = length(nodes)
      fun r(a, n, i) = 
        if(i = len)
        then
          Flow.Graph.Table.empty
        else
          Flow.Graph.Table.enter(
            r(a, n, i + 1),
            List.nth(n, i),
            Array.sub(a, i)) (* Here's the bug! *)
    in
      r(lsArray, nodes, 0)
    end

  fun debugArr(arr) =
    let
      val len = Array.length(arr)
      fun r (i) =
        if (i = len)
        then print("Done!\n")
        else (
          let
            val temps = lsToTempList(Array.sub(arr, i))
          in
            print("\t");
            (app(fn t => print(Int.toString(t)^" ")) temps);
            print("\n");
            r(i + 1)
          end
        )
    in
      print("Array: ");
      r(0)
    end


  (* This function does the heavy lifting of our program
   * 
   * It uses four arrays: inSet, outSet, inSet', and outSet', and mimics the functionality
   * of the algorithm described on page 214 of the Appel book. For "sets" I use
   * IntBinarySet rather than igraph, since it already has union, set diff,
   * etc.
   *
   * At the very end, I convert the array "out" to a map from nodes to 
   * liveSets.
   *
   * *)
  fun buildLivenessMap(Flow.FGRAPH{control, def, use, ismove}) = 
    let
      val nodes = Flow.Graph.nodes(control)
      
      val inSet   = Array.array(length(nodes), newLS())
      val outSet  = Array.array(length(nodes), newLS())
      val inSet'  = Array.array(length(nodes), newLS())
      val outSet' = Array.array(length(nodes), newLS())

      (* Are the two arrays of sets equal? Must be of equal length! *)
      fun setsMatch(a, a') =
        let
          fun r(a, a', i) =
            if(i = Array.length(a))
            then true
            else
              (if equalLS(Array.sub(a, i), Array.sub(a', i)) 
               then r(a, a', i + 1)
               else false)
        in
          r(a, a', 0)
        end

      val continue = ref true (* Hacky way to do do-while loop! *)
      val iteration = ref 0
    in
      (* Main processing loop of the alg. on page 214! *)
      while(!continue)
      do (
        continue := false;
        iteration := !iteration + 1;

        Array.copy{di=0, src=inSet, dst=inSet'};
        Array.copy{di=0, src=outSet, dst=outSet'};

        (* in[n] <- use[n] U (out[n] - def[n]) *)
        (Array.modifyi(
          fn (i, s) =>
            let
              (* Will throw an error if can't find it! *)
              val use_n = addManyLS(newLS(), valOf (Graph.Table.look(use, List.nth(nodes, i))))
              val def_n = addManyLS(newLS(), valOf (Graph.Table.look(def, List.nth(nodes, i))))
              val toRet = unionLS(use_n, diffLS(Array.sub(outSet, i), def_n))
            in
              toRet
            end
            ) inSet);
       
        (* out[n] <- U over s in succ[n] of in[s] *)
        (Array.modifyi(
          fn (i, s) =>
            let
              val succ = Flow.Graph.succ(List.nth(nodes, i))
              val toRet = ref (newLS())
            in
              (app(
                fn (node_x) =>
                  toRet := unionLS(!toRet, Array.sub(inSet, getNodeIdx(node_x, nodes)))
              ) succ);
              !toRet
            end
            ) outSet);

            continue := not(setsMatch(inSet, inSet') andalso setsMatch(outSet, outSet')) 
      );
      
      (*
      print("Printing liveness map:\n");
      debugArr(outSet);
      *)

      (* Return out set *)
      arraySetToLiveSetTable(outSet, nodes)
    end

  fun mergeLists([], b) = b
    | mergeLists(a, []) = a
    | mergeLists(t::rest, b) =
      if(List.exists(fn x => (x = t)) b)
      then(mergeLists(rest, b))
      else(mergeLists(rest, t::b))

  fun getAllTemps([], _, _) = []
    | getAllTemps(node::rest, def, use) = 
    let
      val defTemps = valOf(Graph.Table.look(def, node))
      val useTemps = valOf(Graph.Table.look(use, node))

      val restTemps = getAllTemps(rest, def, use)

      val nodesTemps = mergeLists(defTemps, useTemps)
    in
      mergeLists(nodesTemps, restTemps)
    end


  fun makeSkeletonIgraph(nodes, def, use) =
    let
      val g = Graph.newGraph()
      val temps = getAllTemps(nodes, def, use)

      fun r [] = IGRAPH{graph=g, 
                        tnode=Temp.Table.empty, 
                        gtemp=Graph.Table.empty, 
                        moves=[]}
        | r (temp::rest) =
          let
            val IGRAPH{graph, tnode, gtemp, moves} = r(rest)
            val toAdd = Graph.newNode(g)
          in
            IGRAPH{graph = g,
                   tnode = Temp.Table.enter(tnode, temp, toAdd),
                   gtemp = Graph.Table.enter(gtemp, toAdd, temp),
                   moves = []}
          end

    in
      r(temps)
    end

  fun buildIgraph(livMap, Flow.FGRAPH{control, def, use, ismove}) =
    let
      val instructionNodes = Flow.Graph.nodes(control)

      (* TODO build skeleton graph here *)

      val IGRAPH{graph, tnode, gtemp, moves} = makeSkeletonIgraph(instructionNodes, def, use)
      
      fun addInstructionsNodes(instNode) =
        let
          (* List of temps defined by this inst *)
          val defs = valOf(Flow.Graph.Table.look(def, instNode)) 
          
          
          (* List of temps live at this inst *)
          val (liveSetTable, liveSetList) = valOf(Flow.Graph.Table.look(livMap, instNode))
        
        in
          (* Iterate all over all pairs in cartesian product of defs and liveSetList *)
          (app (
            fn (definition) =>
              (app (
                fn (liveTemp) =>
                  (* Add edge definition ----> liveTemp *)
                  if (not(definition = liveTemp))
                  then 
                    (Graph.mk_edge{from=valOf(Temp.Table.look(tnode, definition)),
                                to=valOf(Temp.Table.look(tnode, liveTemp))};
                    Graph.mk_edge{to=valOf(Temp.Table.look(tnode, definition)),
                                from=valOf(Temp.Table.look(tnode, liveTemp))})
                  else ()

              ) liveSetList)
          ) defs)
        end
    in
      (app addInstructionsNodes instructionNodes);
      (IGRAPH{graph=graph, tnode=tnode, gtemp=gtemp, moves=moves},
          fn (instructionNode) => 
            (case Graph.Table.look(livMap, instructionNode) of 
                 NONE => ErrorMsg.impossible("instruction node doesn't exist")
               | SOME(t, l) => l))
    end
    
    (*(IGRAPH{graph=Flow.Graph.newGraph(),
           tnode=Temp.Table.empty,
           gtemp=Graph.Table.empty,
           moves=[]}, (fn n => []))
           *)

  fun interferenceGraph(flowgraph) =
  let
    val livMap = buildLivenessMap(flowgraph)
    val (igr, nodeToTempMapping) = buildIgraph(livMap, flowgraph)
  in
    (*show(igr);*)
    (igr, nodeToTempMapping)
  end
  
  fun showLiveset(flowgraph, assemToNodeMapping, instrs) =
    let
      val livMap = buildLivenessMap(flowgraph)
      fun getNode(inst, []) = ErrorMsg.impossible("Couldn't find instruction")
        | getNode(inst, (i, n)::rest) = if(inst = i) then n else getNode(inst, rest)

      fun printLiveset((tab, [])) = ()
        | printLiveset((tab, t::rest)) = (print(Int.toString(t)^" "); printLiveset(tab, rest))
    in
      app(
        fn inst =>
          let
            val livset = valOf(Flow.Graph.Table.look(livMap, getNode(inst, assemToNodeMapping)))
          in
            (case inst of Assem.OPER{assem, dst, src, jump} => print(assem)
               | Assem.MOVE{assem, dst, src} => print(assem)
               | Assem.LABEL{assem, lab} => print(assem));
            print("\t\t\thas liveset: ");
            printLiveset(livset);
            print("\n")
          end
      ) instrs 
    end

  (* after constructing the livenessMap, it is quite easy to
     construct the interference graph, just scan each node in
     the Flow Graph, add interference edges properly ... 
   *)

end (* structure Liveness *)


