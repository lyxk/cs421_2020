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

   type allocation = R.register Temp.Table.table

   (* The color function takes an initial allocation table (which assigns
      temporary variables such as FP or SP into certain fixed registers)
      plus an interference graph and a list of registers, and returns
      a new allocation table (mapping from temporaries to registers).

      Notice, you don't need to implement spilling and coalescing. 
      Just do the "simplify" and then do the "select".
    *)

   fun removeFromList(i, j::rest) = if i = j then rest else j::removeFromList(i, rest)
     | removeFromList(_, nil) = nil

   fun color {
     interference=Liveness.IGRAPH{graph, tnode, gtemp, moves},
     initial,
     registers
   } =
   let
     (* Get all the nodes from the interference graph *)
     val nodes = Graph.nodes(graph)

     (* Record whether a node has been visited *)
     val visited: (unit Graph.Table.table) = Graph.Table.empty

     (* Convert from node to temp *)
     fun nodeToTemp(n) = case Graph.Table.look(gtemp, n) of NONE => ErrorMsg.impossible("Error converting node to temp")
                            | SOME(t) => t


     (* A recursive helper *)
     fun recursiveColor(nil, visited, alloc) = alloc 
       | recursiveColor(n::ns, visited, alloc) = 
       (* If n has been visited, return immediately *)
       case Graph.Table.look(visited, n) of SOME(_) => alloc
          | NONE => (
               let
                 (* Get corresponding temporary for the current node *)
                 val ntemp = nodeToTemp(n)
                 (* Mark n as visited *)
                 val newVisited = Graph.Table.enter(visited, n, ())
                 (* Color rest of the graph *)
                 val newAlloc = recursiveColor(ns, newVisited, alloc)
               in
                 (
                   (* If the node is precolored, return alloc *)
                   case Temp.Table.look(alloc, ntemp) of SOME(_) => newAlloc
                      | NONE => 
                       (
                        let
                          (* Find all adjacent nodes and their colors *)
                          val neighbours = Graph.adj(n)

                          (* Add color of a node to a list *)
                          fun addColor(n, l) = 
                          let
                            (* Get corresponding temporary for the current node *)
                            val ntemp = nodeToTemp(n)
                          in
                            case Temp.Table.look(newAlloc, ntemp) of NONE => l
                               | SOME(c) => c::l
                          end

                          (* Find colors of adjacent nodes *)
                          val adjColors = List.foldr addColor nil neighbours

                          (* Choose the first color that's not used by adjacent nodes *)
                          fun findColor(adjColors, nil) = ErrorMsg.impossible("Not enough registers")
                            | findColor(adjColors, r::rs) =
                            if (List.exists (fn x => x = r) adjColors)
                            then findColor(adjColors, rs)
                            else r

                          val chosen = findColor(adjColors, registers)
                        in
                          Temp.Table.enter(newAlloc, ntemp, chosen)
                        end
                      )
                 ) 
               end
          )
   in
     recursiveColor(nodes, visited, initial)
   end
    


end (* functor RegAllocGen *)
