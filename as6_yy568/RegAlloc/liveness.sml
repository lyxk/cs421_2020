(* liveness.sml *)

signature LIVENESS =
sig

    datatype igraph = 
        IGRAPH of {graph : Graph.graph,
              tnode : Graph.node Temp.Table.table,
              gtemp : Temp.temp Graph.Table.table,
              moves : (Graph.node * Graph.node) list}

    val interferenceGraph : Flow.flowgraph -> igraph * (Flow.Graph.node -> Temp.temp list)

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
 
    (* Union of two livesets *)
    fun union((liveset_table1, []), (liveset_table2, liveset_list2)) = (
        (liveset_table2, liveset_list2)
    )
    | union((liveset_table1, temp::rest), (liveset_table2, liveset_list2)) = (
        case Temp.Table.look(liveset_table2, temp) of 
            NONE => (
                union((liveset_table1, rest), (Temp.Table.enter(liveset_table2, temp, ()), temp::liveset_list2))
            )
            | _ => (
                union((liveset_table1, rest), (liveset_table2, liveset_list2))
            )    
    )
        
    (* Diff of two livesets *)
    fun diff((liveset_table1, []), (liveset_table2, liveset_list2)) = (
        (Temp.Table.empty, [])
    )
    | diff((liveset_table1, temp::rest), (liveset_table2, liveset_list2)) = (
        let
              val (tr, lr) = diff((liveset_table1, rest), (liveset_table2, liveset_list2))
        in
              case Temp.Table.look(liveset_table2, temp) of 
                  NONE => (
                      Temp.Table.enter(tr, temp, ()), temp::lr
                  )
                  | _ => (
                      tr, lr
                  )
        end
    )
    
    (* build liveness map *)
    fun buildLivMap(Flow.FGRAPH{control, def, use, ismove}) = (
        let
            fun arrayEqual(array1, array2) = (
                let
                    fun equal(ls1, ls2) = (
                        let
                            val a = diff(ls1, ls2)
                            val b = diff(ls2, ls2)
                        in
                            case (a, b) of ((_, []), (_, [])) => (
                                  true
                            )
                            | _ => (
                                false
                            )
                        end
                    )
                    fun check(array1, array2, i) = (
                        if(i = Array.length(array1)) then (
                            true
                        ) else if not(equal(Array.sub(array1, i), Array.sub(array2, i))) then (
                            false
                        ) else (
                            check(array1, array2, i + 1)
                        )
                    )
                in
                    check(array1, array2, 0)
                end
            )
            fun index(node, []) = (
                print("Node not found\n");
                0
            )
            | index(node, nx::rest) = (
                if (Flow.Graph.eq(node, nx)) then (
                    0
                ) else (
                    index(node, rest) + 1
                )
            )
            fun insertTemps((liveset_table, liveset_list), temps) = (
                case temps of [] => (
                    (liveset_table, liveset_list)
                )
                | temp::rest => (
                    foldl (fn (temp, (lt, ll)) => (Temp.Table.enter(lt, temp, ()), temp::ll)) (liveset_table, liveset_list) temps
                )
            )
            fun array2Table(array, nodes) = (
                let 
                    fun convert(a, n, i) = (
                        if (i = length(nodes)) then (
                            Flow.Graph.Table.empty
                        ) else (
                            Flow.Graph.Table.enter(
                                convert(a, n, i + 1),
                                List.nth(n, i),
                                Array.sub(a, i)
                            )
                        )
                    )
                in
                    convert(array, nodes, 0)
                end
            )
            val nodes = Flow.Graph.nodes(control)
            val inSet   = Array.array(length(nodes), (Temp.Table.empty, []))
            val outSet  = Array.array(length(nodes), (Temp.Table.empty, []))
            val inSet'  = Array.array(length(nodes), (Temp.Table.empty, []))
            val outSet' = Array.array(length(nodes), (Temp.Table.empty, []))
            val continue = ref true   
        in
            while(!continue) do (

                Array.copy{di=0, src=inSet, dst=inSet'};
                Array.copy{di=0, src=outSet, dst=outSet'};

                (Array.modifyi 
                    (fn (i, s) =>
                        let
                            val use_n = insertTemps((Temp.Table.empty, []), valOf (Graph.Table.look(use, List.nth(nodes, i))))
                            val def_n = insertTemps((Temp.Table.empty, []), valOf (Graph.Table.look(def, List.nth(nodes, i))))
                            val newin = union(use_n, diff(Array.sub(outSet, i), def_n))
                        in
                            newin
                        end
                    ) 
                    inSet
                );
       
                (Array.modifyi
                    (fn (i, s) =>
                        let
                            val succ = Flow.Graph.succ(List.nth(nodes, i))
                            val newout = ref ((Temp.Table.empty, []))
                        in
                            (map
                                (fn (curr) =>
                                    newout := union(!newout, Array.sub(inSet, index(curr, nodes)))
                                ) 
                                succ
                            );
                            !newout
                        end
                    ) 
                    outSet
                );

                continue := not(arrayEqual(inSet, inSet') andalso arrayEqual(outSet, outSet')) 
            );

            array2Table(outSet, nodes)
        end
    )

    (* after constructing the livenessMap, it is quite easy to
     construct the interference graph, just scan each node in
     the Flow Graph, add interference edges properly ... 
    *)

    
      (* initialize a interference graph *)
      fun initIgraph(nodes, def, use) = (
          let
              fun extractTemps([], _, _) = []
              | extractTemps(node::rest, def, use) = (
                  let
                      fun getDefs(def, node) = (
                          valOf(Graph.Table.look(def, node))
                      )
                      fun getUses(use, node) = (
                          valOf(Graph.Table.look(use, node))
                      )
                      fun merge([], l2) = (
                          l2
                      )
                      | merge(l1, []) = (
                          l1
                      )
                      | merge(t::rest, b) = (
                          if(List.exists(fn x => (x = t)) b) then (
                              merge(rest, b)
                          ) else (
                              merge(rest, t::b)
                          )
                      )
                  in
                      merge(merge(getDefs(def, node), getUses(use, node)), extractTemps(rest, def, use))
                  end
              )
              val ng = Graph.newGraph()
              val temps = extractTemps(nodes, def, use)

              fun insertTemps2Graph [] = (
                  IGRAPH{graph=ng, 
                          tnode=Temp.Table.empty, 
                          gtemp=Graph.Table.empty, 
                          moves=[]}
              )
              | insertTemps2Graph (temp::rest) = (
                  let
                      val IGRAPH{graph, tnode, gtemp, moves} = insertTemps2Graph(rest)
                      val node = Graph.newNode(ng)
                  in
                      IGRAPH{graph = ng,
                              tnode = Temp.Table.enter(tnode, temp, node),
                              gtemp = Graph.Table.enter(gtemp, node, temp),
                              moves = []}
                  end
              )
          in
              insertTemps2Graph(temps)
          end
      )

      (* build interference graph*)
      fun buildIgraph(livMap, Flow.FGRAPH{control, def, use, ismove}) = (
          let
              val nodes = Flow.Graph.nodes(control)
              val IGRAPH{graph, tnode, gtemp, moves} = initIgraph(nodes, def, use)
      
              fun insertInstructions(node) = (
                  let
                      val defs = valOf(Flow.Graph.Table.look(def, node)) 
                      val (_, liveSetList) = valOf(Flow.Graph.Table.look(livMap, node))
                  in
                      (* nested for loop *)
                      (map 
                          (fn (liveSet) =>
                              (map
                                  (fn (def) =>
                                      if (not(def = liveSet)) then (
                                          Graph.mk_edge{from=valOf(Temp.Table.look(tnode, def)),
                                                        to=valOf(Temp.Table.look(tnode, liveSet))};
                                          Graph.mk_edge{to=valOf(Temp.Table.look(tnode, def)),
                                                        from=valOf(Temp.Table.look(tnode, liveSet))}
                                      ) else (
                                      )
                                  ) 
                                  defs
                              )
                          ) 
                          liveSetList
                      )
                  end
              )
          in
              (map insertInstructions nodes);
              (IGRAPH{graph=graph, 
                      tnode=tnode, 
                      gtemp=gtemp, 
                      moves=moves},
              fn (node) => (
                  (case Graph.Table.look(livMap, node) of 
                      NONE => (
                          []
                      )
                      | SOME(liveSet_table, liveSet_list) => (
                          liveSet_list
                      )
                  )
              )
              )
          end
    )

    (* build interference graph from flow graph *)
    fun interferenceGraph(flowgraph) = (
        buildIgraph(buildLivMap(flowgraph), flowgraph)
    )
  
end (* structure Liveness *)