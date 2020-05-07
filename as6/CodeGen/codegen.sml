(* codegen.sml *)

signature CODEGEN =
sig
  structure F : FRAME
  structure R : REGISTER

  (* translate each canonical tree into a list of assembly instructions *)
  val codegen : Tree.stm -> Assem.instr list 

  (* converting a string fragment into the actual assembly code *)
  val string : Temp.label * string -> string
  
  val munchStm : Tree.stm -> unit
  val munchExp : Tree.exp -> Assem.temp

  (* procEntryExit sequence + function calling sequence tune-up 
   * + mapping pseudo-registers to memory load/store instructions 
   * and actual registers.
   * This is a post-pass, to be done after register allocation.
   *)
  val procEntryExit : {
    name : Temp.label, 
    body : (Assem.instr * Temp.temp list) list,
    allocation : R.register Temp.Table.table,
    formals : Temp.temp list,
    frame : Frame.frame
  } -> Assem.instr list

end (* signature CODEGEN *)

structure Codegen : CODEGEN =
struct

 structure T = Tree
 structure A = Assem
 structure Er = ErrorMsg
 structure F = Frame
 structure R = Register
 structure S = Symbol

 val ilist = ref (nil: A.instr list)
 fun emit x = ( ilist := x :: (!ilist) )
 fun result gen = let val t = Temp.newtemp() in (gen t; t) end

 fun int_to_string i = if i < 0 then "-" ^ Int.toString (~i) else Int.toString i

 fun reop_to_string T.EQ = "je"
   | reop_to_string T.NE = "jne"
   | reop_to_string T.LT = "jl"
   | reop_to_string T.GT = "jg"
   | reop_to_string T.LE = "jle"
   | reop_to_string T.GE = "jge"
   | reop_to_string T.ULT = "jl"
   | reop_to_string T.UGT = "jg"
   | reop_to_string T.ULE = "jle"
   | reop_to_string T.UGE = "jge"
   | reop_to_string _ = (ErrorMsg.impossible "Unrecognized reop. Assume jmp."; "jmp") 

 fun op_to_string T.PLUS = "addl"
   | op_to_string T.MINUS = "subl"
   | op_to_string T.MUL = "imull"
   | op_to_string T.DIV = "idivl"
   | op_to_string T.AND = "andl"
   | op_to_string T.OR = "orl"
   | op_to_string T.XOR = "xorl"
   | op_to_string _ = (ErrorMsg.impossible "Unrecognized op. Assume addl"; "addl")
  
 fun comment s = ("\t\t\t\t# " ^ s ^ "\n")

 fun munchStm ( T.MOVE (T.MEM (T.BINOP (T.PLUS, e1, T.CONST i), _), e2) ) = 
    (
      case e2 of T.CONST c => emit (A.OPER {assem = "\tmovl\t$" ^ (int_to_string c) ^ ", " ^ int_to_string(i) ^ "(`s0)\n", src = [munchExp e1], dst = nil, jump = NONE})
               | _ => emit (A.OPER {assem = "\tmovl\t`s0, " ^ int_to_string(i) ^ "(`s1)\n", src = [munchExp e2, munchExp e1], dst = nil, jump = NONE})
    )

   | munchStm ( T.MOVE (T.MEM (T.BINOP (T.PLUS, T.CONST i, e1), _), e2) ) = 
   (
     case e2 of T.CONST c => emit (A.OPER {assem = "\tmovl\t" ^ "$" ^ (int_to_string c) ^ ", " ^ int_to_string(i) ^ "(`s0)\n", src = [munchExp e1], dst = nil, jump = NONE})
               | _ => emit (A.OPER {assem = "\tmovl\t`s0, " ^ int_to_string(i) ^ "(`s1)\n", src = [munchExp e2, munchExp e1], dst = nil, jump = NONE})
   )

   | munchStm ( T.MOVE ( T.TEMP t, call as T.CALL (T.NAME lab, args) ) ) = 
   emit (A.MOVE {assem = "\tmovl\t`s0, `d0\n", src = munchExp call, dst = t}) 

   | munchStm ( T.MOVE ( T.MEM (e1, _),  me2 as T.MEM (e2, _) ) ) = 
   emit (A.OPER {assem = "\tmovl\t`s0, (`s1)\n", src = [munchExp me2, munchExp e1], dst = nil, jump = NONE})

   | munchStm ( T.MOVE (T.MEM (e1, _), e2) ) = 
   (
     case e2 of T.CONST c => emit (A.OPER {assem = "\tmovl\t$" ^ (int_to_string c) ^ ", (`s0)\n", src = [munchExp e1], dst = nil, jump = NONE})
              | _ => emit (A.OPER {assem = "\tmovl\t`s0, (`s1)\n", src = [munchExp e2, munchExp e1], dst = nil, jump = NONE})
   )

   | munchStm ( T.MOVE (T.TEMP t, e2) ) =
   (
     case e2 of T.CONST c => emit (A.OPER {assem = "\tmovl\t$" ^ (int_to_string c) ^ ", `d0\n", src = nil, dst = [t], jump = NONE})
              | _ => emit (A.OPER {assem = "\tmovl\t`s0, `d0\n", src = [munchExp e2], dst = [t], jump = NONE})
   )

   | munchStm ( T.JUMP (T.NAME lab, labs) ) =
   emit (A.OPER {assem = "\tjmp\t`j0\n", src = nil, dst = nil, jump = SOME labs})

   | munchStm ( T.CJUMP (T.TEST (relop, e1, e2), lab_true, lab_false) ) = 
   ( 
     emit (A.OPER {assem = "\tcmpl\t`s0, `s1\n", src = [munchExp e2, munchExp e1], dst = nil, jump = NONE});
     emit (A.OPER {assem = "\t" ^ (reop_to_string relop) ^ "\t`j0" ^ "\n", src = nil, dst = nil, jump = SOME [lab_true, lab_false]})
   )

   | munchStm ( T.EXP (e) ) = ( munchExp e; () )

   | munchStm ( T.LABEL (lab) ) =
   emit (A.LABEL {assem = S.name lab ^ ":\n", lab = lab})

   | munchStm _ = (ErrorMsg.impossible "MunchStm unmatched"; ())

 and munchExp ( T.MEM (T.BINOP (T.PLUS, e1, T.CONST c), _) ) = 
   result ( fn r => emit (A.MOVE {assem = "\tmovl\t" ^ int_to_string(c) ^ "(`s0), `d0\n", src = munchExp e1, dst = r}) )

   | munchExp ( T.MEM (T.BINOP (T.PLUS, T.CONST c, e1), _) ) = 
   result ( fn r => emit (A.MOVE {assem = "\tmovl\t" ^ int_to_string(c) ^ "(`s0), `d0\n", src = munchExp e1, dst = r}) )

   | munchExp ( T.MEM (T.CONST c, _) ) = 
   result ( fn r => emit (A.OPER {assem = "\tmovl\t($" ^ int_to_string(c) ^ "), `d0\n", src = nil, dst = [r], jump = NONE}) )

   | munchExp ( T.CALL ( T.NAME lab, args ) ) = (
     let
       val name = S.name lab 
     in
       ( munchArgs (0, args);
         result (fn r => (
           emit (A.OPER {assem = "\tcall\t" ^ name ^ "\n", src = nil, dst = [R.RV], jump = NONE});
           emit (A.MOVE {assem = "\tmovl\t`s0, `d0\n", src = R.RV, dst = r}) ) 
         ) 
       )
     end
   )

   | munchExp ( T.BINOP (T.DIV, e1, e2) ) = 
   ( 
     emit (A.OPER {assem = "\tmovl\t$0, %edx\n", src = nil, dst = [R.EDX], jump = NONE});
     (
       case e1 of T.CONST c => emit (A.OPER {assem = "\tmovl\t$" ^ int_to_string(c) ^ ", %eax\n", src = nil, dst = [R.RV], jump = NONE})
                | _ => emit (A.MOVE {assem = "\tmovl\t`s0, %eax\n", src = munchExp e1, dst = R.RV})
     );
     emit (A.OPER {assem = "\tidivl\t`s0\n", src = [munchExp e2, R.RV], dst = [R.EDX, R.RV], jump = NONE});
     R.RV
   )

   | munchExp ( T.BINOP (oper, e1, e2) ) =
   result (fn r => 
     ( 
       (
         case e1 of T.CONST c => emit (A.OPER {assem = "\tmovl\t$" ^ int_to_string(c) ^ ", `d0\n", src = nil, dst = [r], jump = NONE})
                  | _ => emit (A.MOVE {assem = "\tmovl\t`s0, `d0\n", src = munchExp e1, dst = r})
       );
       (
         case e2 of T.CONST c => emit (A.OPER {assem = "\t" ^ (op_to_string oper) ^ "\t$" ^ int_to_string(c) ^ ", `d0\n", src = [r], dst = [r], jump = NONE})
                  | _ => emit (A.OPER {assem = "\t" ^ (op_to_string oper) ^ "\t`s0, `d0\n", src = [munchExp e2, r], dst = [r], jump = NONE})
       )
     )
   )

   | munchExp ( T.MEM (e1, _) ) =
   result ( fn r => 
     (
       case e1 of T.CONST c => emit (A.OPER {assem = "\tmovl\t($" ^ int_to_string(c) ^ "), `d0\n",  src = nil, dst = [r], jump = NONE})
                | _ => emit (A.MOVE {assem = "\tmovl\t(`s0), `d0\n", src = munchExp e1, dst = r})
      
     )
   )

   | munchExp (T.CONST c) = 
   result ( fn r => emit (A.OPER {assem = "\tmovl\t$" ^ int_to_string(c) ^ ", `d0\n", src = nil, dst = [r], jump = NONE}) )
   
   | munchExp (T.NAME lab) =
   result ( fn r => emit (A.OPER {assem = "\tleal\t" ^ (S.name lab) ^ ", `d0\n", src = nil, dst = [r], jump = NONE}) )

   | munchExp (T.TEMP t) = t

   | munchExp _ = (ErrorMsg.impossible "MunchExp unmatched"; R.ERROR)
 
 and munchArgs (_, nil) = ()
   | munchArgs (index, e::es) =
   (
     (
       case e of T.CONST c => emit (A.OPER {assem = "\tmovl\t$" ^ int_to_string(c) ^ ", " ^ int_to_string (index * 4) ^ "(`s0)\n", src = [R.SP], dst = nil, jump = NONE})
               | _ => emit (A.OPER {assem = "\tmovl\t`s0, " ^ int_to_string (index * 4) ^ "(`s1)\n", src = [munchExp e, R.SP], dst = nil, jump = NONE})
     );
     munchArgs (index + 1, es) 
   )

 fun codegen tree = (
   munchStm(tree);
   let 
     val instructions = List.rev (!ilist)
   in
     ilist := nil;
     instructions
   end
 )

fun printable_for_string(nil): string =  ""
 | printable_for_string(character::rest) = Char.toString(character) ^ printable_for_string(rest)
 
fun string(lab: Temp.label, s: string): string =
   Symbol.name(lab) ^ ": "^ comment("string literal")
   ^ "\t.long " ^ int_to_string ( String.size(s) ) ^ comment("length of string")
   ^ "\t.string \"" ^ printable_for_string ( String.explode(s) ) ^ "\"" ^ comment("content of string")

 fun prologue (name: Temp.label, {formals: int, offlst: F.offset list, locals: int ref, maxargs: int ref}) : A.instr list = 
   let
     val proc_name = S.name name
     val frame_size = F.wordSize * ( R.NPSEUDOREGS + !locals + List.length(R.calleesaves) + !maxargs ) 
     val pseudo_instrs_link = A.OPER {assem = ".globl\t" ^ proc_name ^ comment("Linkable"), src = nil, dst = nil, jump = NONE}
     val pseudo_instrs_id = A.OPER {assem = ".type\t" ^ proc_name ^ ", @function\n", src = nil, dst = nil, jump = NONE}
     val proc_label = A.LABEL {assem = proc_name ^ ":\n", lab = name}
     val view_shift_save_fp = A.OPER {assem = "\tpushl\t`s0\n", src = [R.FP], dst = nil, jump = NONE}
     val view_shift_change_fp = A.MOVE {assem = "\tmovl\t`s0, `d0\n", src = R.SP, dst = R.FP}
     val view_shift_change_sp = A.OPER {assem = "\tsubl\t$" ^ int_to_string(frame_size) ^ ", `d0\n", src = [R.SP], dst = [R.SP], jump = NONE}
     fun save_regs(nil, _) = nil
       | save_regs(r::rs, index) = A.OPER {assem = "\tmovl\t" ^ r ^ ", " ^ int_to_string( ~F.wordSize * (R.NPSEUDOREGS + !locals + index + 1) ) ^ "(`s0)\n", src = [R.FP], dst = nil, jump = NONE} :: save_regs(rs, index + 1)
   in
     [pseudo_instrs_link, pseudo_instrs_id, proc_label, view_shift_save_fp, view_shift_change_fp, view_shift_change_sp] @ save_regs(R.calleesaves, 0)
   end
 
fun epilogue (name: Temp.label, {formals: int, offlst: F.offset list, locals: int ref, maxargs: int ref}) = 
  let
    fun restore_regs(nil, _) = nil
      | restore_regs(r::rs, index) = A.OPER{assem = "\tmovl\t" ^ int_to_string( ~F.wordSize * (R.NPSEUDOREGS + !locals + index + 1) ) ^ "(`s0), " ^ r ^ "\n", src = [R.FP], dst = nil, jump = NONE} :: restore_regs(rs, index + 1)
    val view_shift_change_sp = A.MOVE {assem = "\tmovl\t`s0, `d0\n", src = R.FP, dst = R.SP}
    val view_shift_change_fp = A.OPER {assem = "\tpopl\t`d0\n", src = nil, dst = [R.FP], jump = NONE}
    val return_instr = A.OPER {assem = "\tret\n", src = nil, dst = nil, jump = NONE}
  in
    restore_regs(R.calleesaves, 0) @ [view_shift_change_sp, view_shift_change_fp, return_instr]
  end

  (* The following is an example implementation of mapping pseudo-registers 
  to memory load/store instructions and actual registers.  It is done
  in a single pass.  It assumes that pseudo-register names start with
  the letter "f".  It uses the actual registers ECX and EDX as temporaries
  when a pseudo-register is an operand of an instruction.

  There is a special case that this function does NOT handle, but you MUST!
  The DIV instruction has special requirements.  Its dividend must be in EAX, 
  its divisor in a general-purpose register.  It returns both the quotient,
  in EAX, and the remainder, in EDX regardless where the original divisor was! 
  So be careful that a divide instruction does not trash something useful
  in EDX, and that you retrieve the correct resulut from the divide instruction. *)


  (* regname -- produce an assembly language name for the given machine
   * register or psuedo-register.
   * psuedo-registers are mapped to an expression for psuedo-register's
   * location in stack frame.
   *)
  (* regname : R.register -> string *)
  fun regname reg =
    if (String.isPrefix "f" reg) then (
      (* it's a psuedo-register *)
      let
          val (SOME prNum) = Int.fromString (String.extract(reg,1,NONE));
          val offset = (prNum + 1) * F.wordSize
      in
          "-" ^ Int.toString(offset) ^ "(%ebp)"
      end
    ) else reg


 (* genSpills -- do our "poor man's spilling".  Maps all pseudo-register
  * references to actual registers, by inserting instructions to load/store
  * the pseudo-register to/from a real register
  *)
 fun genSpills (insns, saytemp) =
     let
	  (* doload() -- given name of a source register src, and a true
	   * machine register mreg, will return a load instruction (if needed)
	   * and a machine register.
	   *)
	  (* loadit: Temp.temp * Temp.temp -> string * Temp.temp *)
	  fun loadit (src, mreg) =
	    let 
		    val srcnm = (saytemp src)
	    in
		    if (String.isPrefix "f" srcnm) then
		      (* it's a fake register: *)
		      let
			      (* val _ = print ("loadit(): mapping pseudo-register `" ^ srcnm ^ "'* to machine reg. `" ^ (saytemp mreg) ^"'\n"); *)
			      val loadInsn = "\tmovl\t" ^ (regname srcnm) ^ ", " ^ (saytemp mreg) ^ " # load pseudo-register\n"
		      in
			      (loadInsn, mreg)
		      end
		    else
		      (* no mapping needed *)
		      ("", src)
	    end
	  (* mapsrcs : produce a sequence of instructions to load
	   * pseudo-registers into real registers, and produce a list
	   * of sources which reflects the real registers.
	   *)
	  (* mapsrcs : Temp.temp list * Temp.temp list -> string * Temp.temp list *)
	  fun mapsrcs ([], _) = ("",[])
      | mapsrcs (_, []) = ("", [])
	    | mapsrcs (src::srcs, mreg::mregs) =
          let
              val (loadInsn, src') = loadit(src,mreg)
              val (loadRest, srcs') = mapsrcs(srcs,mregs)
          in
              (loadInsn ^ loadRest, src'::srcs')
          end
	  (* findit -- like List.find, but returns SOME i, where i is index
	   * of element, if found
	   *)
    fun findit f l =
	    let
        fun dosrch([], f, _) = NONE
          | dosrch(el::els, f, idx) = if f(el) then SOME idx else dosrch(els, f, idx+1)
	    in
		    dosrch(l,f,0)
	    end

	  (* mapdsts -- after we have mapped sources to real machine
	   * registers, iterate through dsts.
	   * If dst is a pseudo-register then
	   *    if dst was also a src,
	   *         replace dst with machine register to which src is already
	   *         mapped
	   *    else
	   *         map dst to its own machine register (just use %ecx)
	   *    generate a store insn for dst to save result
	   *)
          (* mapdsts : Temp.temp list * Temp.temp list * Temp.temp list ->
	   *           string * Temp.temp list
	   *)
          (* N.B.!  This only works for dst of length 0 or 1 !! *)
          (* pre: length(dsts) <= 1 *)
	  fun mapdsts ([],_,_) = ("",[])
	    | mapdsts (dst::dsts, srcs, newsrcs) =
	      let
		      val found = findit (fn e => e = dst) srcs
		      val dstnm = (saytemp dst)
	      in
		      if (isSome(found)) then
		      (* this dst is also a source *)
		        let
			        val idx = valOf(found)
			        val src = List.nth (srcs,idx)
			        val mreg = List.nth (newsrcs,idx)
		        in
			        if (src <> mreg) 
              then ("\tmovl\t`d0, " ^ (regname dstnm) ^ " # save pseudo-register\n", mreg::dsts)
			        else (* no mapping *) ("", dst::dsts)
		        end
		      else
		      (* this dst isn't a source, but it might be a pseudo-register *)
            if (String.isPrefix "f" dstnm) then
              (* it's a fake register: *)
              (* we can safely just replace this destination with
                * %ecx, and then write out %ecx to the pseudo-register
                * location.  Even if %ecx was used to hold a different
                * source pseudo-register, we won't end up clobbering
                * it until after the source has been used...
                *)
              ("\tmovl\t`d0, " ^ (regname dstnm) ^ " # save pseudo-register\n", R.ECX::dsts)
             else
              (* no mapping *)
              ("", dst::dsts)
	      end

	  fun mapInstr(A.OPER{assem=insn, dst=dsts, src=srcs, jump=jmp}) = 
	      let
		      val (loadinsns, newsrcs) = mapsrcs(srcs, [R.ECX, R.EDX]);
          val (storeinsns, newdsts) = mapdsts(dsts, srcs, newsrcs); 
	      in
		      A.OPER{assem=loadinsns ^ insn ^ storeinsns, dst=newdsts, src=newsrcs, jump=jmp}
	      end
        
      | mapInstr(A.MOVE{assem, dst, src}) =  
        let
          val (load_instrs, newsrcs) = mapsrcs([src], [R.ECX, R.EDX])
          val (store_instrs, newdsts) = mapdsts([dst], [src], newsrcs)
        in
          A.OPER {assem = load_instrs ^ assem ^ store_instrs, dst = newdsts, src = newsrcs, jump = NONE}
        end
        
	    | mapInstr(instr as A.LABEL _) = instr

     in
         map mapInstr insns
     end


  fun replacePseudoRegs (instrs: Assem.instr list, reg_table: R.register Temp.Table.table): A.instr list = 
    let
      fun tmp_to_reg(tmp: Temp.temp): R.register = (
        case Temp.Table.look (reg_table, tmp)
          of SOME reg => reg
           | NONE => (ErrorMsg.error 0 ("Temp unregistered: " ^ Temp.makestring tmp); Temp.makestring tmp)
      )
      (* Replace all pseudoregs with memory loads/stores using %ecx or %edx *)
      val no_pseudoregs = genSpills(instrs, tmp_to_reg)
      val reg_format = A.format (tmp_to_reg)
      fun replace_regs(instr: A.instr): A.instr = A.OPER {assem = (reg_format instr), src = nil, dst = nil, jump = NONE}
    in
      map replace_regs no_pseudoregs
    end

  (* procEntryExit sequence + function calling sequence tune-up 
   * + mapping pseudo-registers to memory load/store instructions 
   * and actual registers.
   * This is a post-pass, to be done after register allocation.
   *)
   fun procEntryExit {
      name : Temp.label, 
      body : (Assem.instr * Temp.temp list) list,
      allocation : R.register Temp.Table.table,
      formals : Temp.temp list,
      frame : Frame.frame
    } = (
      let
        fun alloc(instrs: A.instr list): A.instr list = replacePseudoRegs(instrs, allocation)
        val pre = alloc( prologue(name, frame) )
        val new_body = alloc (map (fn (i, t) => i) body)
        val post = alloc( epilogue(name, frame) )
      in
        pre @ new_body @ post
      end
    )
end (* structure Codegen *)
