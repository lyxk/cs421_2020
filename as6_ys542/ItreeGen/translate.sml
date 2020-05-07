(* translate.sml *)

signature TRANSLATE = 
sig 
  type level
  type access
  type frag
  type gexp

  val outermost : level
  val newLevel : {parent: level, formals: 'a list} -> level
  val allocInFrame : level -> access
  val getResult : unit -> frag list
  (*val allocInRegister : unit -> access*)

  (* helper functions used by Semant *)
  val nthParam : level * int -> access
  val addFrag : frag -> unit
  val newLabel : unit -> Temp.label
  val mainLabel : unit -> Temp.label
  (* translation functions, returning gexp *)
  val nilExp : gexp
  val intExp : int -> gexp
  val stringExp : string -> gexp
  val opArithm : gexp * gexp * Absyn.oper -> gexp
  val compNonStr : gexp * gexp * Absyn.oper -> gexp
  val compStr : gexp * gexp * Absyn.oper -> gexp
  val simpleVar : access * level -> gexp
  val fieldVar : gexp * int -> gexp
  val subscriptVar : gexp * gexp -> gexp
  val assignExp : gexp * gexp -> gexp
  val ifThen : gexp * gexp -> gexp
  val ifThenElse : gexp * gexp * gexp -> gexp
  val seqExp : gexp list -> gexp
  val arrayExp : gexp * gexp -> gexp
  val recordExp : gexp list -> gexp
  val whileExp : gexp * gexp -> gexp
  val forExp : access * gexp * gexp * gexp -> gexp
  val breakExp : Temp.label -> gexp
  val appExp : gexp list * Temp.label * level * level -> gexp
  val letExp : gexp list * gexp -> gexp
  val funDec : {level : level, label : Temp.label, body : gexp} -> unit

  val defaultEx : gexp
  val defaultNx : gexp
  val defaultCx : gexp

end (* signature TRANSLATE *)


functor TranslateGen(Register : REGISTER_STD) : TRANSLATE = 
struct

  structure T = Tree
  structure F = Frame

  datatype level = LEVEL of {frame : F.frame,              
                             sl_offset : int,
                             parent : level} * unit ref
                 | TOP

  type gexp = T.exp

  type access = level * int  (* might needs to be changed later *)
  type frag = F.frag

  val outermost = TOP
  val fragmentlist = ref [F.DATA {lab=Temp.namedlabel "array_error", s="Error: array index out of range\n"},
                          F.DATA {lab=Temp.namedlabel "record_error", s="Error: nil record cannot be dereferenced\n"}]
  fun getResult () = let val r = !fragmentlist
    in (fragmentlist := [F.DATA {lab=Temp.namedlabel "array_error", s="Error: array index out of range\n"},
                          F.DATA {lab=Temp.namedlabel "record_error", s="Error: nil record cannot be dereferenced\n"}];
        rev r)
    end (* flush the fragment list *)


  (*****************************************************************
   *                  HELPERS USED BY SEMANT                       *
   *****************************************************************)
  (* dummy default values used for semantic error recovery, etc. *)
  val defaultEx = T.CONST 0
  val defaultNx = T.CONST 0
  val defaultCx = T.CONST 0

  (* create a new level for a function *)
  (* returns a level object *)
  fun newLevel {parent=p, formals=f} =
      let
        val len = length(f)
        val (frame, offlst) = F.newFrame (len, Register.paramBaseOffset)
        val sl_offset = hd offlst
      in LEVEL ({frame=frame, sl_offset=sl_offset, parent=p}, ref ()) end

  (* allocate space in the frame of the current function *)
  (* return an access to the level and offset *)
  fun allocInFrame (lev as LEVEL({frame, sl_offset, parent}, _)) =
     let val offset = F.allocInFrame (frame, Register.localsBaseOffset) in (lev, offset) end
    | allocInFrame _ = ErrorMsg.impossible "unexpected argument for allocInFrame"

  (* given LEVEL, return access to the n-th argument (starting from 0) of the function *)
  (* access = level * int/offset *)
  fun nthParam (lev as LEVEL({frame=f, sl_offset=_, parent=_}, _), n) = (lev, F.nthParam (n, Register.paramBaseOffset))
    | nthParam _ = ErrorMsg.impossible "unexpected argument for nthParam"

  (* generate a dummy label that serves as the default invalid break label *)
  fun newLabel() = Temp.newlabel()
  (* generate a specially reserved label for the main program *)
  fun mainLabel() = Temp.namedlabel "tigermain"

  (* given FRAG, add it to the global list of fragments *)
  fun addFrag f = (fragmentlist := f::(!fragmentlist))


  (*****************************************************************
   *               TRANSLATE INTERNAL UTILITIES                    *
   *****************************************************************)
  (* convert a flat list of stms into a tree of SEQ of stms *)
  fun seq [] = ErrorMsg.impossible "SEQ of stms cannot be empty"
    | seq [a] = a
    | seq (a::r) = T.SEQ(a, seq r)


  (*****************************************************************
   *                      ACTUAL TRANSLATORS                       *
   *****************************************************************)
  val nilExp = T.CONST 0 (* a pointer to 0x0, dereferencing with MEM causes error *)
  fun intExp i = T.CONST i
  fun stringExp str =
    let val lab = Temp.newlabel()
    in (fragmentlist := (F.DATA {lab=lab, s=str})::(!fragmentlist); T.NAME lab)
    end
  (* translate an arithmetic expression *)
  fun opArithm (expl : gexp, expr : gexp, oper : Absyn.oper) = 
    let
      val el = expl
      val er = expr
    in case oper
      of Absyn.PlusOp => T.BINOP(T.PLUS, el, er)
      | Absyn.MinusOp => T.BINOP(T.MINUS, el, er)
      | Absyn.TimesOp => T.BINOP(T.MUL, el, er)
      | Absyn.DivideOp => T.BINOP(T.DIV, el, er)
      | _ => ErrorMsg.impossible "unexpected operator for opArithm"
    end
  (* compare non-strings *)
  fun compNonStr (expl : gexp, expr : gexp, oper : Absyn.oper) =
    let
      val el = expl
      val er = expr
      val t = Temp.newlabel() and f = Temp.newlabel()
      val r = Temp.newtemp()
      val testop = case oper
        of Absyn.NeqOp => T.NE
        | Absyn.EqOp => T.EQ
        | Absyn.LtOp => T.LT
        | Absyn.LeOp => T.LE
        | Absyn.GtOp => T.GT
        | Absyn.GeOp => T.GE
        | _ => ErrorMsg.impossible "unexpected operator for compNonStr"
    in T.ESEQ(seq[T.MOVE(T.TEMP r, T.CONST 0),
                        T.CJUMP(T.TEST(testop, el, er), t, f),
                        T.LABEL t, T.MOVE(T.TEMP r, T.CONST 1),
                        T.LABEL f], T.TEMP r)
    end
  (* compare strings using runtime function *)
  fun compStr (expl : gexp, expr : gexp, oper : Absyn.oper) =
    let
      val el = expl
      val er = expr
    in case oper
      of Absyn.EqOp => F.externalCall("stringEqual", [el, er])
      | Absyn.NeqOp => F.externalCall("not", [F.externalCall("stringEqual", [el, er])])
      | Absyn.LtOp => F.externalCall("stringLessThan", [el, er])
      | Absyn.LeOp => T.BINOP(T.OR, F.externalCall("stringLessThan", [el, er]), F.externalCall("stringEqual", [el, er]))
      | Absyn.GtOp => F.externalCall("not", [T.BINOP(T.OR, F.externalCall("stringLessThan", [el, er]), F.externalCall("stringEqual", [el, er]))])
      | Absyn.GeOp => F.externalCall("not", [F.externalCall("stringLessThan", [el, er])])
      | _ => ErrorMsg.impossible "unexpected operator for compStr"
    end
  (* translate a simple var, acc = declared level + offset; lev = current level *)
  fun simpleVar (acc : access, lev : level) = 
    let
      val (dec_lev, dec_off) = acc
      fun follow_slink(current : level, target : level, cumulate : T.exp) : T.exp = 
        let
          val LEVEL({frame=_, sl_offset=slink, parent=parent}, rc) = current
          val LEVEL({frame=_, sl_offset=_, parent=_}, rt) = target
        in if rc = rt
          then T.MEM(T.BINOP(T.PLUS, T.CONST dec_off, cumulate), F.wordSize)
          else follow_slink(parent, target, T.MEM(T.BINOP(T.PLUS, T.CONST slink, cumulate), F.wordSize))
        end
    in follow_slink(lev, dec_lev, T.TEMP Register.FP)
    end
  (* translate record.field, e is IR code for record, n is the index of the field *)
  fun fieldVar (e : gexp, n : int) =
    let
      val base = Temp.newtemp()
      val error = Temp.newlabel() and proceed = Temp.newlabel()
    in T.ESEQ(seq[T.MOVE(T.TEMP base, e),
                  T.CJUMP(T.TEST(T.NE, T.CONST 0, T.TEMP base), proceed, error),
                  T.LABEL error,
                    T.EXP(F.externalCall("print", [T.NAME (Temp.namedlabel "record_error")])), T.EXP(F.externalCall("exit", [T.CONST 1])),
                  T.LABEL proceed],
      T.MEM(T.BINOP(T.PLUS, T.TEMP base, T.BINOP(T.MUL, T.CONST n, T.CONST F.wordSize)), F.wordSize))
    end
  (* translate a[i], e is IR code for a, e' is IR code for i *)
  fun subscriptVar (e : gexp, e' : gexp) =
    let
      val base = Temp.newtemp()
      val index = Temp.newtemp()
      val upper_limit = Temp.newtemp()
      val error = Temp.newlabel() and proceed = Temp.newlabel() and passed = Temp.newlabel()
    in T.ESEQ(seq[T.MOVE(T.TEMP base, e),
                  T.MOVE(T.TEMP index, e'),
                  T.MOVE(T.TEMP upper_limit, T.MEM(T.TEMP base, F.wordSize)),
                  T.CJUMP(T.TEST(T.LT, T.TEMP index, T.TEMP upper_limit), proceed, error),
                  T.LABEL error,
                    T.EXP(F.externalCall("print", [T.NAME (Temp.namedlabel "array_error")])), T.EXP(F.externalCall("exit", [T.CONST 1])),
                  T.LABEL proceed,
                    T.CJUMP(T.TEST(T.GE, T.TEMP index, T.CONST 0), passed, error),
                  T.LABEL passed],
      T.MEM(T.BINOP(T.PLUS, T.TEMP base, T.BINOP(T.MUL, T.BINOP(T.PLUS, T.CONST 1, T.TEMP index), T.CONST F.wordSize)), F.wordSize))
    end
  (* translating assignment expressions; lexp = l-value; rexp = r-value *)
  fun assignExp(lexp : gexp, rexp : gexp) =
    let
      val laddr = lexp
      val rval = rexp
    in T.ESEQ(T.MOVE(laddr, rval), T.CONST 0)
    end
  (* translate if e1 then e2 *)
  fun ifThen (e1 : gexp, e2 : gexp) =
    let
      val test = e1
      val then' = e2
      val t = Temp.newlabel() and f = Temp.newlabel()
    in T.ESEQ(seq[T.CJUMP(T.TEST(T.NE, T.CONST 0, test), t, f),
                  T.LABEL t, T.EXP(then'), T.LABEL f],
              T.CONST 0)
    end
  (* translate if e1 then e2 else e3 *)
  fun ifThenElse (e1 : gexp, e2 : gexp, e3 : gexp) =
    let
      val test = e1
      val then' = e2
      val else' = e3
      val t = Temp.newlabel() and f = Temp.newlabel() and done = Temp.newlabel()
      val r = Temp.newtemp()
    in T.ESEQ(seq[T.CJUMP(T.TEST(T.NE, T.CONST 0, test), t, f),
                  T.LABEL t, T.MOVE(T.TEMP r, then'), T.JUMP (T.NAME done, [done]),
                  T.LABEL f, T.MOVE(T.TEMP r, else'), T.LABEL done],
              T.TEMP r)
    end
  (* translate a sequence of gexp's *)
  fun seqExp (gexpl : gexp list) = 
    let fun toStm (e : gexp) : T.stm = T.EXP e
    in case rev(gexpl) (* reverse so that last element appears first *)
      of nil => defaultNx
      | ge::nil => ge
      | ge::rest => T.ESEQ(seq(rev (map toStm rest)), ge)
    end
  (* translate array creation; esize = length of array; einit = initialization value *)
  (* the length of the array is stored in the first entry, causing an extra length of 1 *)
  fun arrayExp (esize : gexp, einit : gexp) =
    let
      val r = Temp.newtemp()
      val size = Temp.newtemp()
    in T.ESEQ(seq[T.MOVE(T.TEMP size, esize),
                  T.MOVE(T.TEMP r, F.externalCall("initArray", [T.BINOP(T.PLUS, T.CONST 1, T.TEMP size), einit])),
                  T.MOVE(T.MEM(T.TEMP r, F.wordSize), T.TEMP size)],
              T.TEMP r)
    end
  (* translate record creation; fexps = REVERSED list of gexp for each field *)
  fun recordExp (fexps : gexp list) =
    let
      val r = Temp.newtemp()
      val len = length(fexps)
      fun cons_fields_tree (nil, existing) = existing
        | cons_fields_tree (f::rest, existing) = cons_fields_tree(rest,
            T.SEQ(T.MOVE(T.MEM(T.BINOP(T.PLUS, T.TEMP r, T.CONST (F.wordSize * length(rest))), F.wordSize), f), existing))
    in if len = 0 then T.ESEQ(T.MOVE(T.TEMP r, F.externalCall("allocRecord", [T.CONST 0])), T.TEMP r)
        else let
          val fields_tree = cons_fields_tree(tl fexps,
              T.MOVE(T.MEM(T.BINOP(T.PLUS, T.TEMP r, T.CONST(F.wordSize * length(tl fexps))), F.wordSize), hd fexps))
          val complete_tree = T.SEQ(T.MOVE(T.TEMP r, F.externalCall("allocRecord", [T.CONST (len * F.wordSize)])), fields_tree)
        in T.ESEQ(complete_tree, T.TEMP r)
        end
    end
  (* translate while loop; etest = test expression; ebody = body expression *)
  fun whileExp (etest : gexp, ebody : gexp) = 
    let
      val test = Temp.newlabel()
      val done = Temp.newlabel()
      val body = Temp.newlabel()
      val testfun = etest
      val bodyexp = ebody
    in
      T.ESEQ(seq[T.LABEL test,
                T.CJUMP(T.TEST(T.EQ, T.CONST 0, testfun), done, body),
              T.LABEL body,
                T.EXP bodyexp, T.JUMP (T.NAME test, [test]),
              T.LABEL done], T.CONST 0)
    end
  (* translate for loop; counter = access for loop var; elo = low; ehi = high; ebody = body *)
  fun forExp (counter : access, elo : gexp, ehi : gexp, ebody : gexp) =
    let
      val lo = elo
      val hi = ehi
      val bodyexp = ebody
      val (lev, off) = counter
      val test = Temp.newlabel()
      val done = Temp.newlabel()
      val body = Temp.newlabel()
      val increment = Temp.newlabel()
      val var = T.MEM(T.BINOP(T.PLUS, T.CONST off, T.TEMP Register.FP), F.wordSize)
    in
      T.ESEQ(seq[T.MOVE(var, lo),
            T.CJUMP(T.TEST(T.LE, lo, hi), body, done),
            T.LABEL body,
              T.EXP(bodyexp),
              T.CJUMP(T.TEST(T.LT, var, hi), increment, done),
            T.LABEL increment,
              T.MOVE(var, T.BINOP(T.PLUS, var, T.CONST 1)), T.JUMP(T.NAME body, [body]),
            T.LABEL done], T.CONST 0)
    end
  (* translate break: jump to the done label of the current nested loop *)
  fun breakExp (done_label : Temp.label) = T.ESEQ(T.JUMP(T.NAME done_label, [done_label]), T.CONST 0)
  (* translate function calls: eargs = gexp list of args; lab = label of this function;
   * lev = level of this function; call_lev = who calls this function *)
  (* note that this function needs to update the maxargs in the calling level *)
  fun appExp(eargs : gexp list, lab : Temp.label, lev : level, call_lev : level) =
    if lev = outermost
    then T.CALL(T.NAME lab, eargs)
    else let
      val LEVEL({frame=f, sl_offset=_, parent=_}, _) = call_lev
      val {formals=_, offlst=_, locals=_, maxargs=ma} = f
      fun compute_slink (caller : level, callee : level, fp : T.exp) : T.exp =
        let val LEVEL({frame=_, sl_offset=s, parent=p}, _) = callee
            val LEVEL({frame=_, sl_offset=sc, parent=pc}, _) = caller
        (* caller = callee means self-recursion; caller = callee_parent means callee is defined by caller *)
        in if compare_level (p, caller) then fp
            else compute_slink (pc, callee, T.MEM(T.BINOP(T.PLUS, T.CONST sc, fp), F.wordSize))
        end
      and compare_level (l1 : level, l2 : level) : bool =
        let val LEVEL({...}, r1) = l1
            val LEVEL({...}, r2) = l2
        in r1 = r2 end
    in
      (ma := Int.max(!ma, length(eargs) + 1); (* maxargs takes into account the static link !!! *)
        T.CALL(T.NAME lab, compute_slink(call_lev, lev, T.TEMP Register.FP)::eargs))
    end
  (* translate let expressions: declist = list of var initialization gexps; body = gexp of body expression *)
  fun letExp(declist : gexp list, body : gexp) = if length(declist) = 0 then body else
    let
      fun toStm (e : gexp) : Tree.stm =
        case e of T.ESEQ(a, T.CONST 0) => a | _ => ErrorMsg.impossible "unexpected gexp in declaration list"
      val decseq = seq (map toStm declist)
      val bodyexp = body
    in T.ESEQ(decseq, bodyexp)
    end
  (* convert function into a fragment and store it *)
  fun funDec {level=lev, label=lab, body=b} =
    let
      val LEVEL({frame=f, ...}, _) = lev
      val fragment = F.PROC {name=lab, body=T.MOVE(T.TEMP Register.RV, b), frame=f}
    in addFrag fragment
    end


end (* functor TranslateGen *)





     
