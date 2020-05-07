(* frame.sml *)

signature FRAME =
sig 
  type offset = int
  type frame

  val wordSize : int
  
  val newFrame : int * int -> frame * offset list
  val allocInFrame : frame * int -> offset
  val nthParam : int * int -> offset
  val externalCall : string * Tree.exp list -> Tree.exp

  datatype frag = PROC of {name : Temp.label, body: Tree.stm, frame: frame} 
                | DATA of {lab : Temp.label, s: string}

end (* signature FRAME *)


structure Frame : FRAME = 
struct
  type offset = int
  type frame = {formals : int,         (* number of formal parameters *)
                offlst : offset list,  (* offset list for formals *)
                locals : int ref,      (* # of local variables so far *)
                maxargs : int ref}     (* max outgoing args for the function *)

  datatype frag = PROC of {name : Temp.label, body: Tree.stm, frame: frame} 
                | DATA of {lab : Temp.label, s: string}

  val wordSize = 4

  (* static link at paramBaseOffset, n-th arg at pBO + n * wordSize *)
  (* returns a frame object, plus the list of offsets for arguments *)
  fun newFrame (nArgs, pbo) =
    let
      fun computeOfflst(0, prev) = prev
        | computeOfflst(r, prev) = computeOfflst(r-1, (wordSize + hd(prev))::prev)
      val offlst = rev(computeOfflst(nArgs, [pbo]))
    in ({formals=nArgs, offlst=offlst, locals=ref 0, maxargs=ref 0}, offlst)
    end

  (* n-th local var at (n-1) * wordSize + localsBaseOffset *)
  (* localsBaseOffset is assumed to be negative *)
  (* returns the offset for the newly allocated local variable *)
  fun allocInFrame (f : frame, lbo) =
    let val nl = #locals f
    in (nl := !nl + 1; ~(!nl - 1) * wordSize + lbo)
    end

  (* given n, compute the offset for the n-th argument (starting from 0) *)
  (* return the offset value for that argument *)
  fun nthParam (n, pbo) = pbo + (n+1) * wordSize

  fun externalCall(s, args) = Tree.CALL(Tree.NAME(Temp.namedlabel s), args)

end (* structure Frame *)

