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

   (* The color function talkes an initial allocation table (which assigns
      temporary variables such as FP or SP into certain fixed registers)
      plus an interference graph and a list of registers, and returns
      a new allocation table (mapping from temporaries to registers).

      Notice, you don't need to implement spilling and coalescing. 
      Just do the "simplify" and then do the "select".
    *)

   fun color {interference=Liveness.IGRAPH{graph, tnode, gtemp, moves},
              initial,
              registers} =
   let

     (* An imperative-style reference to the allocation we will return *)
     val allocation = ref initial

     (* A stack to hold nodes *)
     val stack = ref []

     fun isStackEmpty() = 
       (case !stack of [] => true
           | _ => false)

     fun push(n) =
       stack := n::(!stack)

     fun pop() = 
       (case !stack of [] => ErrorMsg.impossible("Can't pop empty stack")
           | a::rest => (stack := rest; a))

     fun assignColor(node, register) =
       (case Graph.Table.look(gtemp, node) of NONE => ErrorMsg.impossible("Missing node in gtemp")
           | SOME(temp) => (allocation := Temp.Table.enter(!allocation, temp, register))
       )
     
     fun populateStack() =
       stack := Graph.nodes(graph)

     fun getNodeColor(n) =
       (case Temp.Table.look(!allocation, n) of NONE => ErrorMsg.impossible("Node not colored!")
          | SOME(c) => c)

     fun printColor(n, isPrecolored) =
       if(isPrecolored)
       then
         (case Graph.Table.look(gtemp, n) of NONE => ErrorMsg.impossible("Missing node in gtemp")
             | SOME(temp) => print("Precolor of temp "^Int.toString(temp)^" is "^getNodeColor(temp)^"\n")
         )
       else
         (case Graph.Table.look(gtemp, n) of NONE => ErrorMsg.impossible("Missing node in gtemp")
             | SOME(temp) => print("Color of temp "^Int.toString(temp)^" is "^getNodeColor(temp)^"\n")
         )

     fun nodeToTemp(n) =
       case Graph.Table.look(gtemp, n) of NONE => ErrorMsg.impossible("Error converting node to temp")
          | SOME(temp) => temp
     
     fun isNodeColored(n) =
       (case Temp.Table.look(!allocation, nodeToTemp(n)) of NONE => false
          | _ => true)


     fun removeColorFromSet(color, set) =
       let
         (* Non-ref version for recursion *)
         fun getSetWithoutColor(c, []) = ErrorMsg.impossible("Color "^color^" not in set")
           | getSetWithoutColor(c, c2::rest) =
              if (c = c2) then rest
              else (c2::getSetWithoutColor(c, rest))
       in
         set := getSetWithoutColor(color, !set)
       end
     
     fun removeColorFromSetIfPossible(color, set) =
       let
         (* Non-ref version for recursion *)
         fun getSetWithoutColor(c, []) = []
           | getSetWithoutColor(c, c2::rest) =
              if (c = c2) then rest
              else (c2::getSetWithoutColor(c, rest))
       in
         set := getSetWithoutColor(color, !set)
       end

     fun setContainsColor(s, []) = false
       | setContainsColor(s, c::rest) =
            if(s = c) then true
            else setContainsColor(s, rest)

     fun assignColors() =
       (while(not(isStackEmpty())) do (
          let
            val n = pop()
            val ok = ref registers
          in
            if(isNodeColored(n))
            then () (* Precolored! *)
            else(
              (* For each w in adj[n]
               *    if isColored(w)
               *    then ok = ok - color(w)
               *)
              (app(
                fn w =>
                  (
                    if(isNodeColored(w))
                    then
                      removeColorFromSetIfPossible(getNodeColor(nodeToTemp(w)), ok)
                    else
                      ()
                  )
              ) (Graph.adj(n)));

              (* If no remaining colors, error! Else assign one *)
              if(!ok = [])
              then
                ErrorMsg.impossible("Not enough colors!")
              else
                assignColor(n, hd(!ok))
            )
          end
       ))
   in
     populateStack();
     assignColors();
     !allocation
   end

end (* functor RegAllocGen *)
