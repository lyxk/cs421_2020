(* regalloc.sml *)

signature REG_ALLOC =
sig
   structure R : REGISTER_STD
   
   type allocation = Register.register Temp.Table.table

   val color : {interference : Liveness.igraph,
                initial : allocation,
                registers : R.register list} -> allocation

end (* signature REG_ALLOC *)

functor RegAllocGen(Register : REGISTER_STD) : REG_ALLOC =
struct
    structure R : REGISTER_STD = Register
    structure G = Graph
    structure T = Temp

    type allocation = R.register Temp.Table.table
    

   (* The color function talkes an initial allocation table (which assigns
      temporary variables such as FP or SP into certain fixed registers)
      plus an interference graph and a list of registers, and returns
      a new allocation table (mapping from temps to registers).

      Notice, you don't need to implement spilling and coalescing. 
      Just do the "simplify" and then do the "select".
    *)


    fun color {interference, initial, registers} = (
        let 
            val Liveness.IGRAPH{graph, tnode, gtemp, moves} = interference
            val temps = G.nodes(graph)

            (*simplyfy function*)
            fun simplify (igraph, nil, stack, table) = (
                stack, table
            )
            | simplify (igraph, node::rest, stack, table) = (
                let 
                    val (stack, table) = simplify(igraph, rest, stack, table)
                    val neighbors = G.pred(node)
                in 
                    (* if the node has less than K neighbors and not been put on the stack *)
                    if (length(neighbors) < length(registers) andalso G.Table.look(table, node) = NONE) then (
                        app (fn n => G.rm_edge{from=node, to=n}) neighbors;
                        app (fn n => G.rm_edge{from=n, to=node}) neighbors;
                        ((node, neighbors)::stack, G.Table.enter(table, node, ()))
                    ) else (
                        stack, table
                    )
                end
            )
                  
            val (stack, table) = simplify(graph, G.nodes(graph), [], G.Table.empty)

            (* select function *)
            fun select (nil, allocation) = (
                allocation
            )
            | select ((node, neighbors)::rest, allocation) = (
                let
                    val temp = valOf(G.Table.look(gtemp, node))
                    val allTemps = map (fn n => valOf(G.Table.look(gtemp, n))) neighbors
                    fun findUsedColors(nil, colorList) = (
                        colorList
                    )
                    | findUsedColors((interferedTemp::rest), colorList) = (
                        valOf(T.Table.look(allocation, interferedTemp))::findUsedColors(rest, colorList)
                    )
                    val usedColor = findUsedColors(allTemps, [])
                    fun pickColor(color::rest) = (
                        if (List.exists (fn (currColor) => currColor = color) usedColor) then (
                            pickColor(rest)
                        ) else (
                            color
                        )
                    )

                    val color = pickColor(registers)
                in
                    case T.Table.look(allocation, temp) of 
                        NONE => (
                            select(rest, T.Table.enter(allocation, temp, color))
                        )
                        | _ => (
                            select(rest, allocation)
                        )
                end
            )
        in
            select(stack, initial)
        end
    )
end (* functor RegAllocGen *)
