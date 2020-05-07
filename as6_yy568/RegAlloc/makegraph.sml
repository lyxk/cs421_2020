(* makegraph.sml *)

signature MAKEGRAPH = 
    sig
    (* 
     * val instrs2graph : Assem.instr list -> Flow.flowgraph * Flow.Graph.node list
    *)
        val instrs2graph : Assem.instr list -> Flow.flowgraph * Flow.Graph.node list
        val instrs2graphHelper: Assem.instr list -> Flow.flowgraph * Flow.Graph.node list * (Assem.instr * Flow.Graph.node) list
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

        fun edgeExist(from, to) = (
            let
                fun checkNode([], node) = (
                    false
                )
                | checkNode(n::rest, node) = (
                    if (Flow.Graph.eq(n, node)) then (
                        true
                    ) else (
                        checkNode(rest, node)
                    )
                )
      
            in
                checkNode(Flow.Graph.succ(from), to)
            end
        )
        fun instrs2graphHelper [] =  (
            Flow.FGRAPH({
                control=Flow.Graph.newGraph(),
                def=Flow.Graph.Table.empty,
                use=Flow.Graph.Table.empty,
                ismove=Graph.Table.empty
            }), [], []
        )
        | instrs2graphHelper (instr::rest) = (
            let
                fun insertJumpEdge(graph, newNode, labels, mappings) = (
                    let
                        val labToMatch = hd labels
                    in
                        case mappings of [] => (
                        )
                        | (Assem.LABEL{assem, lab}, node)::rest => (
                            if (lab = labToMatch) then (
                                if (not(edgeExist(newNode, node))) then (
                                    Flow.Graph.mk_edge{from=newNode, to=node}
                                ) else (  
                                );
                                ()
                            ) else (
                                insertJumpEdge(graph, newNode, labels, rest)
                            )
                        )
                        | mapping::rest => (
                            insertJumpEdge(graph, newNode, labels, rest)
                        )
                    end
                )
                fun insertLabelEdge(graph, newNode, labels, mappings) = (
                    case mappings of [] => (
                    )
                    | (Assem.OPER{assem, dst, src, jump=SOME([lab])}, node)::rest => (
                        if (lab = labels) then (
                            if(not(edgeExist(node, newNode))) then (
                                Flow.Graph.mk_edge{from=node, to=newNode}
                            ) else (
                            ); 
                            insertLabelEdge(graph, newNode, labels, rest)
                        ) else (
                            insertLabelEdge(graph, newNode, labels, rest)
                        )
                    )
                    | mapping::rest => insertLabelEdge(graph, newNode, labels, rest)
                )
                fun insertDstNode(node, def, dst) = (
                    Graph.Table.enter(def, node, dst)
                )
                fun insertSrcNode(node, use, src) = (
                    Graph.Table.enter(use, node, src)
                )
                fun insertIsMove(node, ismove, assem) = (
                    if (String.isSubstring "movl" assem) then (
                        Graph.Table.enter(ismove, node, true)
                    ) else (
                        Graph.Table.enter(ismove, node, false)
                    )
                )

                val res = instrs2graphHelper(rest)
                val (Flow.FGRAPH{control, def, use, ismove}) = #1(res)
                val nodes = #2(res)
                val mappings = #3(res)
                val newNode = Flow.Graph.newNode(control)
                val newMappings = (instr, newNode)::mappings
                
            in
                case nodes of [] => (
                )
                | _ => (
                    Flow.Graph.mk_edge{from=newNode, to=hd(nodes)}
                );
                

                (* No Jump Operation *)
                case instr of Assem.OPER{assem, dst, src, jump=NONE} => (
                    (Flow.FGRAPH{
                        control=control,
                        def=insertDstNode(newNode, def, dst),
                        use=insertSrcNode(newNode, use, src),
                        ismove=insertIsMove(newNode, ismove, assem)},
                    newNode::nodes,
                    newMappings)
                )
                (* Jump operation *)
                | Assem.OPER{assem, dst, src, jump=SOME(lab)} => (
                    insertJumpEdge(control, newNode, lab, mappings); 
                    (Flow.FGRAPH{
                        control=control, 
                        def=insertDstNode(newNode, def, dst), 
                        use=insertSrcNode(newNode, use, src),
                        ismove=insertIsMove(newNode, ismove, assem)},
                    newNode::nodes,
                    newMappings)
                )
                (* Move instruction *)
                | Assem.MOVE{assem, dst, src} => (
                    Flow.FGRAPH{
                        control=control,
                        def=insertDstNode(newNode, def, [dst]),
                        use=insertSrcNode(newNode, use, [src]),
                        ismove=insertIsMove(newNode, ismove, assem)},
                    newNode::nodes,
                    newMappings
                )
                (* Label operation *)
                | Assem.LABEL{assem, lab} => (
                    insertLabelEdge(control, newNode, lab, mappings);
                    (Flow.FGRAPH{
                        control=control,
                        def=insertDstNode(newNode, def, []),
                        use=insertSrcNode(newNode, use, []),
                        ismove=insertIsMove(newNode, ismove, assem)},
                    newNode::nodes,
                    newMappings)
                )
            end
        )
    fun instrs2graph(instrs) = (
        let
            val (flowgraph, nodes, mappings) = instrs2graphHelper(instrs)
        in
            (flowgraph, nodes)
        end
    )
end