signature SEMANT =
sig
  type ir_code
  type frag
  val transprog : Absyn.exp -> frag list
end

functor SemantGen(Register : REGISTER_STD) : SEMANT = 
struct

  structure Translate = TranslateGen(Register)
  structure Env = EnvGen(Translate)

  structure A = Absyn
  structure E = Env
  structure S = Symbol
  structure T = Types
  val error = ErrorMsg.error
  val impossible = ErrorMsg.impossible
  type ir_code = Translate.gexp
  type frag = Translate.frag

  (* used for loop counter assignment testing and break testing *)
  datatype envtest = WHILE | FOR | LET | FUNCTION

  (*************************************************************************
   *                       UTILITY FUNCTIONS                               *
   *************************************************************************)

  (* check that an expression is INT, and print error otherwise *)
  fun checkInt ({exp, ty}, pos) = case ty
    of T.INT => ()
     | _ => error pos "integer operand required"

  (* given a ty, recursively strip away the NAME's *)
  fun actual_ty ty = case ty
    of T.NAME(_, ref(SOME(t))) => actual_ty t
     | _ => ty

  (* variant of actual_ty to check for cyclic dependencies *)
  fun actual_ty_safe (t as T.NAME(symbol, ref(SOME(t'))), pos) =
      let
        fun iter (t as T.NAME(symbol, ref(SOME(t'))), previous, pos) =
          if nocycle (symbol, previous, pos)
          then iter (t', symbol::previous, pos)
          else (error pos ("cyclic primitive type dependency for '" ^ (S.name symbol) ^ "', assuming INT"); T.INT)
          | iter (t as _, _, _) = t
        and nocycle (symbol, nil, pos) = true
          | nocycle (symbol, first::rest, pos) =
            if (S.name symbol) = (S.name first)
            then false
            else nocycle (symbol, rest, pos)
      in
        iter (t, nil, pos)
      end
    | actual_ty_safe (t as _, pos) = t

  (* given a list of symbol * ty pairs, search for the type of a given id *)
  fun search_field ([], id, pos, n, e) =
        (error pos ((S.name id) ^ " is not a record field"); {exp=Translate.defaultEx, ty=T.INT})
     | search_field ((s,t)::tail, id, pos, n, e) = 
        if s = id then {exp=Translate.fieldVar(e, n), ty=actual_ty(t)} else search_field (tail, id, pos, n+1, e)


 (**************************************************************************
  *                   TRANSLATING TYPE EXPRESSIONS                         *
  *                                                                        *
  *              transty : (E.tenv * A.ty) -> T.ty                         *
  *************************************************************************)

  fun transty (tenv, A.ArrayTy(id, pos)) = 
        let
          val typ = S.look(tenv, id)
        in case typ
          of SOME(t) => T.ARRAY(t, ref ())
          | NONE => (error pos ("undeclared type " ^ (S.name id)); T.ARRAY(T.INT, ref ()))
        end
    | transty (tenv, A.NameTy(id, pos)) =
        let
          val typ = S.look(tenv, id)
        in case typ
          of SOME(t) => t
          | NONE => (error pos ("undeclared type " ^ (S.name id)); T.INT)
        end
    | transty (tenv, A.RecordTy(tfields)) = 
        let fun cumulate(tenv, [], existing) = existing
              | cumulate(tenv, tfield::tfields, existing) =
                let
                  val {name, typ, pos} = tfield
                  val ty = S.look(tenv, typ)
                in if duplicated(name, existing) then (error pos ("duplicated field name '" ^ (S.name name) ^ "' in record type"); [])
                    else case ty
                        of SOME(t) => cumulate(tenv, tfields, (name, t)::existing)
                        | NONE => (error pos ("undeclared type " ^ (S.name typ)); [])
                end
            (* helper function to check for duplicated fields *)
            and duplicated(symbol, []) = false
              | duplicated(symbol, first::rest) = if (S.name symbol) = (S.name(#1(first))) then true else duplicated(symbol, rest)
            val fields = cumulate(tenv, rev(tfields), [])
        in T.RECORD(fields, ref ())
        end


 (**************************************************************************
  *                   TRANSLATING EXPRESSIONS                              *
  *                                                                        *
  *  transexp : (env * tenv * expr * stack * level * label) -> {exp, ty}   *
  **************************************************************************)
  fun transexp (env, tenv, expr, envstack, level, done_label) =
    (* envstack is used to check for loop counter assignment and 'break' violations *)
    (* level is used to keep track of local var accesses and function activations *)
    let fun g (A.OpExp {left, oper=A.NeqOp, right, pos}) = f_eq(left, right, pos, A.NeqOp)
          | g (A.OpExp {left, oper=A.EqOp, right, pos}) = f_eq(left, right, pos, A.EqOp)
          | g (A.OpExp {left, oper=A.LtOp, right, pos}) = f_lg(left, right, pos, A.LtOp)
          | g (A.OpExp {left, oper=A.LeOp, right, pos}) = f_lg(left, right, pos, A.LeOp)
          | g (A.OpExp {left, oper=A.GtOp, right, pos}) = f_lg(left, right, pos, A.GtOp)
          | g (A.OpExp {left, oper=A.GeOp, right, pos}) = f_lg(left, right, pos, A.GeOp)
          | g (A.OpExp {left, oper=A.PlusOp, right, pos}) = f_arithm(left, right, pos, A.PlusOp)
          | g (A.OpExp {left, oper=A.MinusOp, right, pos}) = f_arithm(left, right, pos, A.MinusOp)
          | g (A.OpExp {left, oper=A.TimesOp, right, pos}) = f_arithm(left, right, pos, A.TimesOp)
          | g (A.OpExp {left, oper=A.DivideOp, right, pos}) = f_arithm(left, right, pos, A.DivideOp)

          | g (A.VarExp v) = h v (* l-value expression *)

          | g (A.NilExp) = {exp=Translate.nilExp, ty=T.NIL} (* nil *)

          | g (A.IntExp i) = {exp=Translate.intExp(i), ty=T.INT} (* integer literal *)

          | g (A.StringExp (str, pos)) = {exp=Translate.stringExp(str), ty=T.STRING} (* string literal *)

          (* f(arg1, arg2, ...) function call *)
          (* NEED: f is defined; args, formals number match; args, formals type match *)
          (* RETURN: the output type of the function; UNIT if failure *)
          | g (A.AppExp {func, args, pos}) = (case S.look(env, func)
              (* function name is defined, proceed *)
              of SOME(E.FUNentry{level=level_f, label, formals, result}) =>
                  (* function to check arg types, one by one *)
                  (* return gexp of all args, or an arbitrarily shorter list if there is an error *)
                  let 
                    fun check_arg_types ([], [], n, existing) = existing
                      | check_arg_types (arg1::args, formal1::formals, n, existing) =
                        (* targ1 = evaluated type of argument; formal1 = defined type of argument (cannot be UNIT/NIL) *)
                        let val {exp=earg1, ty=targ1} = g arg1 in case targ1
                          of T.RECORD(_, uref) => (case formal1
                                  of T.RECORD(_, unique) =>
                                    if uref = unique then check_arg_types(args, formals, n+1, earg1::existing)
                                    else (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil))
                                  | _ => (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil)))
                          | T.NIL => (case formal1
                                  of T.RECORD(_, _) => check_arg_types(args, formals, n+1, earg1::existing)
                                  | _ => (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil)))
                          | T.INT => (case formal1
                                  of T.INT => check_arg_types(args, formals, n+1, earg1::existing)
                                  | _ => (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil)))
                          | T.STRING => (case formal1
                                  of T.STRING => check_arg_types(args, formals, n+1, earg1::existing)
                                  | _ => (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil)))
                          | T.ARRAY(_, uref) => (case formal1
                                  of T.ARRAY(_, unique) =>
                                    if uref = unique then check_arg_types(args, formals, n+1, earg1::existing)
                                    else (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil))
                                  | _ => (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil)))
                          | T.UNIT => (error pos ("argument " ^ (Int.toString n) ^ " type incompatible with function definition");
                                          check_arg_types(args, formals, n+1, nil))
                          | _ => impossible "unexpected type returned by g"
                        end
                      | check_arg_types (arg1::args, [], n, _) = impossible "number of args doesn't match formals"
                      | check_arg_types ([], formal1::formals, n, _) = impossible "number of args doesn't match formals"
                  (* first check number of arguments, then check argument type matching *)
                  in if length(args) <> length(formals)
                     then (error pos ("number of arguments does not match function definition"); {exp=Translate.defaultEx, ty=result})
                     else let val eargs = check_arg_types(args, formals, 1, nil)
                          in if length(eargs) = length(formals)
                              then {exp=Translate.appExp(eargs, label, level_f, level), ty=result}
                              else {exp=Translate.defaultEx, ty=result}
                          end
                  end
              (* name is not a function, throw error *)
              | SOME(_) => (error pos ((S.name func) ^ " is not a function, assuming output UNIT"); {exp=Translate.defaultNx, ty=T.UNIT})
              (* function name is undefined, throw error *)
              | NONE => (error pos ("undeclared function " ^ (S.name func) ^ ", assuming output UNIT"); {exp=Translate.defaultNx, ty=T.UNIT}))

          (* type_id{f1=exp1, f2=exp2, ...} create new record of type_id *)
          (* NEED: type_id is defined RECORD; fields match definition *)
          (* RETURN: RECORD type matching type_id's type exactly; dummy RECORD if failure *)
          | g (A.RecordExp {fields, typ, pos}) = (case S.look(tenv, typ)
              (* type_id is undefined, throw error *)
              of NONE => (error pos ("undeclared record type " ^ (S.name typ)); {exp=Translate.defaultEx, ty=T.RECORD ([], ref ())})
              (* type_id is RECORD, proceed *)
              | SOME(T.RECORD(defs, unique)) =>
                let 
                  fun check_fields (nil, nil, n, existing) = existing
                    | check_fields ((sf, exp, _)::fields, (sd, ty)::defs, n, existing) =
                      if (S.name sf) <> (S.name sd)
                      then (error pos ("field name '" ^ (S.name sf) ^ "' does not match definition '" ^ (S.name sd) ^ "'");
                            check_fields (fields, defs, n+1, nil); [])
                      else let val {exp=ef, ty=texp} = g exp in case texp (* texp = evaluated type of the exp; ty = expected type of the field (cannot be NIL or UNIT) *)
                        of T.RECORD(_, fu) => (case actual_ty(ty) (* expected type of the field *)
                            of T.RECORD(_, du) =>
                              if fu = du then check_fields (fields, defs, n+1, (sf, texp, ef)::existing)
                              else (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); [])
                            | _ => (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); []))
                        | T.NIL => (case actual_ty(ty)
                            of T.RECORD(_, _) => check_fields (fields, defs, n+1, (sf, texp, ef)::existing)
                            | _ => (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); []))
                        | T.INT => (case actual_ty(ty)
                            of T.INT => check_fields (fields, defs, n+1, (sf, texp, ef)::existing)
                            | _ => (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); []))
                        | T.STRING => (case actual_ty(ty)
                            of T.STRING => check_fields (fields, defs, n+1, (sf, texp, ef)::existing)
                            | _ => (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); []))
                        | T.ARRAY(_, fu) => (case actual_ty(ty)
                            of T.ARRAY(_, du) =>
                              if fu = du then check_fields (fields, defs, n+1, (sf, texp, ef)::existing)
                              else (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); [])
                            | _ => (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); []))
                        | T.UNIT => (error pos ("field " ^ (Int.toString n) ^ " incompatible with record type definition");
                                    check_fields (fields, defs, n+1, nil); [])
                        | _ => impossible "unexpected type returned by g"
                      end
                    | check_fields (field::fields, [], _, _) = impossible "number of fields doesn't match defs"
                    | check_fields ([], def::defs, _, _) = impossible "number of fields doesn't match defs"
                in if length(fields) <> length(defs)
                    then (error pos ("number of record fields does not match definition"); {exp=Translate.defaultEx, ty=T.RECORD ([], ref ())})
                    else
                      let
                        fun extract_fexp (elem : (S.symbol * T.ty * ir_code)) = #3 elem
                        fun extract_symbol_ty (elem : (S.symbol * T.ty * ir_code)) = (#1 elem, #2 elem)
                        val results = check_fields (fields, defs, 1, nil) (* check_fields spits out things in REVERSE !! *)
                        val fexps = map extract_fexp results
                        val results = map extract_symbol_ty results
                      in if length(results) <> length(defs) then {exp=Translate.defaultEx, ty=T.RECORD ([], ref ())}
                          else {exp=Translate.recordExp(fexps), ty=T.RECORD (rev(results), unique)}
                      end
                end
              (* type_id is defined but not a RECORD, throw error *)
              | SOME(_) => (error pos ((S.name typ) ^ " is not a record type"); {exp=Translate.defaultEx, ty=T.RECORD ([], ref ())}))
                   
          (* (exp1; exp2; ...) sequence of expressions *)
          (* RETURN: UNIT if empty, or the type of last exp if non-empty *)
          | g (A.SeqExp expseq) = 
            let
              fun extract_gexp (r : {exp : ir_code, ty : T.ty}) = #exp r
              val etseq = map g (map #1 expseq) (* remove the pos values, then type-check every exp in the sequence *)
              val result = case etseq of nil => T.UNIT | _ => #ty(List.last etseq)
            in {exp=Translate.seqExp(map extract_gexp etseq), ty=result}
            end

          (* l-value := exp assigning new value to an l-value location *)
          (* NEED: l-value exp types match *)
          (* RETURN: UNIT *)
          | g (A.AssignExp {var, exp, pos}) = let
                val {exp=lexp, ty=vtype} = h var (* evaluated type of l-value *)
                val {exp=rexp, ty=etype} = g exp (* evaluated type of r-value *)
                val vid = case var (* used to check for loop counter assignment violation *)
                  of A.SimpleVar(id, _) => SOME id
                  | _ => NONE
                fun check_loop_counter(NONE, _) = true
                  | check_loop_counter(SOME(v), []) = true
                  | check_loop_counter(SOME(v), ((WHILE, _)::envstack)) = check_loop_counter(SOME(v), envstack)
                  | check_loop_counter(SOME(v), ((FOR, s)::envstack)) = if (S.name v) = s then false else check_loop_counter(SOME(v), envstack)
                  | check_loop_counter(SOME(v), ((LET, s)::envstack)) = if (S.name v) = s then true else check_loop_counter(SOME(v), envstack)
                  | check_loop_counter(SOME(v), ((FUNCTION, s)::envstack)) = if (S.name v) = s then true else check_loop_counter(SOME(v), envstack)
              in case vtype
                  (* make sure that A := B, B's type satisfies A's type *)
                  of T.RECORD(_, vu) => (case etype
                      of T.RECORD(_, eu) => if vu = eu then {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                                            else (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT})
                      | T.NIL => {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                      | _ => (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT}))
                  | T.NIL => (case etype
                      of T.NIL => {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                      | T.RECORD(_, _) => {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                      | _ => (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT}))
                  (* check whether this ASSIGN overwrites loop counter variable *)
                  | T.INT => (if check_loop_counter(vid, envstack) then case etype
                        of T.INT => {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                        | _ => (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT})
                      else (error pos "assignment to loop counter is not allowed"; {exp=Translate.defaultNx, ty=T.UNIT}))
                  | T.STRING => (case etype
                      of T.STRING => {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                      | _ => (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT}))
                  | T.ARRAY(_, vu) => (case etype
                      of T.ARRAY(_, eu) => if vu = eu then {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                                            else (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT})
                      | _ => (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT}))
                  | T.UNIT => (case etype
                      of T.UNIT => {exp=Translate.assignExp(lexp, rexp), ty=T.UNIT}
                      | _ => (error pos "assignment types do not match"; {exp=Translate.defaultNx, ty=T.UNIT}))
                  | _ => impossible "unexpected type returned by h"
              end

          (* if exp1 then exp2 [else exp3] *)
          (* NEED: exp1 of type INT; if else not present, then exp2 must be UNIT; otherwise exp2 matches exp3 *)
          (* RETURN: if else not present, UNIT; otherwise, the type of exp2, exp3; UNIT if failure *)
          | g (A.IfExp {test, then', else', pos}) = let 
              val {exp=e1, ty=ttest} = g test
              val {exp=e2, ty=tthen'} = g then'
            in case ttest
              (* check if test expr is valid integer expression *)
              of T.INT => (case else'
                  (* no else, so then must be valueless *)
                  of NONE => (case tthen'
                      of T.UNIT => {exp=Translate.ifThen(e1, e2), ty=T.UNIT}
                      | _ => (error pos ("then expr in if-then statement must produce no value"); {exp=Translate.defaultCx, ty=T.UNIT}))
                  (* else present, check that then-else must match *)
                  | SOME(exp) => let val {exp=e3, ty=telse'} = g exp in case telse'
                      of T.RECORD(_, uref) => (case tthen'
                          of T.RECORD(_, unique) => if uref = unique
                                                    then {exp=Translate.ifThenElse(e1, e2, e3), ty=telse'}
                                                    else (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT})
                          | T.NIL => {exp=Translate.ifThenElse(e1, e2, e3), ty=telse'}
                          | _ => (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT}))
                      | T.NIL => (case tthen'
                          of T.NIL => (error pos ("'nil' type cannot be inferred"); {exp=Translate.defaultCx, ty=T.UNIT})
                          | T.RECORD(_, _) => {exp=Translate.ifThenElse(e1, e2, e3), ty=telse'}
                          | _ => (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT}))
                      | T.INT => (case tthen'
                          of T.INT => {exp=Translate.ifThenElse(e1, e2, e3), ty=T.INT}
                          | _ => (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT}))
                      | T.STRING => (case tthen'
                          of T.STRING => {exp=Translate.ifThenElse(e1, e2, e3), ty=T.STRING}
                          | _ => (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT}))
                      | T.ARRAY(_, uref) => (case tthen'
                          of T.ARRAY(_, unique) => if uref = unique
                                                   then {exp=Translate.ifThenElse(e1, e2, e3), ty=telse'}
                                                   else (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT})
                          | _ => (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT}))
                      | T.UNIT => (case tthen'
                          of T.UNIT => {exp=Translate.ifThenElse(e1, e2, e3), ty=T.UNIT}
                          | _ => (error pos ("then, else types do not match"); {exp=Translate.defaultCx, ty=T.UNIT}))
                      | _ => impossible "unexpected type returned by g"
                    end)
              (* test expr is invalid, report error *)
              | _ => (error pos ("invalid if condition"); {exp=Translate.defaultCx, ty=T.UNIT})
            end

          (* while exp1 do exp2 *)
          (* NEED: exp1 of type INT; exp2 of type UNIT *)
          (* RETURN: UNIT *)
          | g (A.WhileExp {test, body, pos}) = 
            let
              val {exp=etest, ty=ttest} = g test
            in case ttest
              (* check that while loop guard is valid integer expression *)
              of T.INT => let val {exp=ebody, ty=tbody} = transexp (env, tenv, body, (WHILE, "")::envstack, level, Translate.newLabel()) in case tbody
                  (* body exp should be valueless *)
                  of T.UNIT => {exp=Translate.whileExp(etest, ebody), ty=T.UNIT}
                  | _ => (error pos ("while loop body must produce no value"); {exp=Translate.defaultNx, ty=T.UNIT})
                end
              (* invalid guard condition *)
              | _ => (error pos ("invalid while loop condition"); {exp=Translate.defaultNx, ty=T.UNIT})
            end

          (* for id := exp1 to exp2 do exp3 *)
          (* NEED: exp1, exp2 of type INT; exp3 of type UNIT; exp3 checked with new ENV! *)
          (* RETURN: UNIT *)
          | g (A.ForExp {var, lo, hi, body, pos}) =
            let
              val {name, escape} = var
              val {exp=elo, ty=t1} = g lo
              val {exp=ehi, ty=t2} = g hi
              val new_access = Translate.allocInFrame(level)
              val env' = S.enter(env, name, E.VARentry({access=new_access, ty=T.INT}))
              val {exp=ebody, ty=t3} = transexp (env', tenv, body, (FOR, S.name(name))::envstack, level, Translate.newLabel())
            in case (t1, t2)
                of (T.INT, T.INT) => (case t3
                    of T.UNIT => {exp=Translate.forExp(new_access, elo, ehi, ebody), ty=T.UNIT}
                    | _ => (error pos "for loop body must produce no value"; {exp=Translate.defaultNx, ty=T.UNIT}))
                | _ => (error pos "loop variable must be an integer"; {exp=Translate.defaultNx, ty=T.UNIT})
            end

          (* break *)
          (* NEED: takes place inside for or while loop *)
          (* RETURN: UNIT *)
          | g (A.BreakExp pos) =
            let fun check_break [] = false
                  | check_break ((FOR, _)::envstack) = true
                  | check_break ((WHILE, _)::envstack) = true
                  | check_break ((FUNCTION, _)::envstack) = false
                  | check_break ((LET, _)::envstack) = check_break envstack
            in if check_break envstack then {exp=Translate.breakExp done_label, ty=T.UNIT}
                else (error pos "'break' is not permitted outside of loops"; {exp=Translate.defaultCx, ty=T.UNIT})
            end

          (* let decs in expseq end *)
          (* NEED: add decs to ENV; every exp in body legal *)
          (* RETURN: type of last exp in expseq *)
          | g (A.LetExp {decs, body, pos}) = 
            let
              val (env', tenv', envstack', explist) = transdecs(env, tenv, decs, envstack, level, done_label, nil)
              val {exp=ebody, ty=tbody} = transexp (env', tenv', body, envstack', level, done_label)
            in {exp=Translate.letExp(explist, ebody), ty=tbody}
            end

          (* type_id[exp1] of exp2 *)
          (* NEED: type_id defined; type_id is ARRAY; exp1 is INT; exp2 matches type_id *)
          (* RETURN: ARRAY; if failure, return ARRAY of INT *)
          | g (A.ArrayExp {typ, size, init, pos}) = case S.look(tenv, typ)
              (* type_id is undefined, throw error *)
              of NONE => (error pos ("undeclared array type " ^ (S.name typ)); {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())})
              (* type_id is ARRAY, proceed *)
              | SOME(T.ARRAY(ty, unique)) => let val {exp=esize, ty=tsize} = g size in case tsize
                  (* exp1 is INT, proceed *)
                  (* check that exp2 and array typedef have the same type *)
                  (* tinit = evaluated type of init/exp2; ty = required type as per array typedef (cannot be UNIT, NIL) *)
                  of T.INT => let val {exp=einit, ty=tinit} = g init in case tinit
                      of T.RECORD(_, iu) => (case actual_ty(ty) (* required type as per array typedef *)
                          of T.RECORD(_, du) => if iu = du then {exp=Translate.arrayExp(esize, einit), ty=T.ARRAY(tinit, unique)}
                                                else (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())})
                          | _ => (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())}))
                      | T.NIL => (case actual_ty(ty)
                          of T.RECORD(_, _) => {exp=Translate.arrayExp(esize, einit), ty=T.ARRAY(tinit, unique)}
                          | _ => (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())}))
                      | T.INT => (case actual_ty(ty)
                          of T.INT => {exp=Translate.arrayExp(esize, einit), ty=T.ARRAY(tinit, unique)}
                          | _ => (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())}))
                      | T.STRING => (case actual_ty(ty)
                          of T.STRING => {exp=Translate.arrayExp(esize, einit), ty=T.ARRAY(tinit, unique)}
                          | _ => (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())}))
                      | T.ARRAY(_, iu) => (case actual_ty(ty)
                          of T.ARRAY(_, du) => if iu = du then {exp=Translate.arrayExp(esize, einit), ty=T.ARRAY(tinit, unique)}
                                                else (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())})
                          | _ => (error pos "initial value does not match array type definition"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())}))
                      | T.UNIT => (error pos "illegal initial value"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())})
                      | _ => impossible "unexpected type returned by g"
                    end
                  (* exp1 is not INT, throw error *)
                  | _ => (error pos "array size must be an integer"; {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())})
                end
              (* type_id is defined but not a ARRAY, throw error *)
              | SOME(_) => (error pos ((S.name typ) ^ " is not an array type"); {exp=Translate.defaultEx, ty=T.ARRAY(T.INT, ref ())})

        (* function dealing with "var", may be mutually recursive with g *)
        (* if anything fails, the type defaults to INT *)
        and h (A.SimpleVar (id, pos)) = (case S.look(env, id)
            of SOME(E.VARentry {access, ty}) => {exp=Translate.simpleVar(access, level), ty=actual_ty(ty)}
            | SOME(_) => (error pos ((S.name id) ^ " is a function"); {exp=Translate.defaultEx, ty=T.INT})
            | NONE => (error pos ("undeclared variable " ^ (S.name id)); {exp=Translate.defaultEx, ty=T.INT}))

	        | h (A.FieldVar (v, id, pos)) = (case v
            (* process directly if v is a simple variable (non-recursive) *)
            of A.SimpleVar(symbol, p) => (case S.look(env, symbol)
                of NONE => (error pos ("undeclared variable " ^ (S.name symbol)); {exp=Translate.defaultEx, ty=T.INT})
                | SOME(E.VARentry {access, ty}) => (case actual_ty(ty) (* check if v is a record variable *)
                    of T.RECORD(fields, _) => search_field (fields, id, pos, 0, Translate.simpleVar(access, level)) (* look for specific field *)
                    | _ => (error pos ("cannot use field accessor on non-record type"); {exp=Translate.defaultEx, ty=T.INT}))
                | SOME(_) => (error pos ((S.name symbol) ^ " is a function"); {exp=Translate.defaultEx, ty=T.INT}))
            (* process recursively first if v is a complicated variable *)
            | _ => let val {exp=e, ty=t} = h v in case t
                of T.RECORD(fields, _) => search_field (fields, id, pos, 0, e)
                | _ => (error pos ("cannot use field accessor on non-record type"); {exp=Translate.defaultEx, ty=T.INT})
              end)

	        | h (A.SubscriptVar (v, exp, pos)) = (case v
            (* process directly if v is a simple variable (non-recursive) *)
            of A.SimpleVar(symbol, p) => (case S.look(env, symbol)
                of NONE => (error pos ("undeclared variable " ^ (S.name symbol)); {exp=Translate.defaultEx, ty=T.INT})
                | SOME(E.VARentry {access, ty}) => (case actual_ty(ty) (* check if v is an array variable *)
                    of T.ARRAY(typ, _) => let val {exp=e', ty=t'} = g exp in
                        if t' = T.INT (* check if exp is an integer *)
                        then {exp=Translate.subscriptVar(Translate.simpleVar(access, level), e'), ty=typ}
                        else (error pos ("array subscript must be an integer"); {exp=Translate.defaultEx, ty=T.INT})
                      end
                    | _ => (error pos ("cannot use subscript on non-array type"); {exp=Translate.defaultEx, ty=T.INT}))
                | SOME(_) => (error pos ((S.name symbol) ^ " is a function"); {exp=Translate.defaultEx, ty=T.INT}))
            (* process recursively first if v is a complicated variable *)
             | _ => let val {exp=e, ty=t} = h v
              in case t
                of T.ARRAY(typ, _) => let val {exp=e', ty=t'} = g exp in
                      if t' = T.INT (* check if exp is an integer *)
                      then {exp=Translate.subscriptVar(e, e'), ty=typ}
                      else (error pos ("array subscript must be an integer"); {exp=Translate.defaultEx, ty=T.INT})
                    end
                | _ => (error pos ("cannot use subscript on non-array type"); {exp=Translate.defaultEx, ty=T.INT})
              end)

        (* function dealing with binary operations, so that code doesn't have to be duplicated *)
        (* f_eq deals with = and <> *)
        and f_eq (left, right, pos, oper) =
            let
              val {exp=expl, ty=tl} = g left
              val {exp=expr, ty=tr} = g right
            in case tl
              of T.RECORD(_, lu) => (case tr
                  of T.RECORD(_, ru) => if lu = ru then {exp=Translate.compNonStr(expl, expr, oper), ty=T.INT}
                                        else (error pos "cannot compare records of different types"; {exp=Translate.defaultCx, ty=T.INT})
                  | T.NIL => {exp=Translate.compNonStr(expl, expr, oper), ty=T.INT}
                  | _ => (error pos "comparison requires two operands with same type"; {exp=Translate.defaultCx, ty=T.INT}))
              | T.ARRAY(_, lu) => (case tr
                  of T.ARRAY(_, ru) => if lu = ru then {exp=Translate.compNonStr(expl, expr, oper), ty=T.INT}
                                        else (error pos "cannot compare arrays of different types"; {exp=Translate.defaultCx, ty=T.INT})
                  | _ => (error pos "comparison requires two operands with same type"; {exp=Translate.defaultCx, ty=T.INT}))
              | T.NIL => (case tr
                  of T.RECORD(_, _) => {exp=Translate.compNonStr(expl, expr, oper), ty=T.INT}
                  | T.NIL => (error pos "'nil' type cannot be inferred"; {exp=Translate.defaultCx, ty=T.INT})
                  | _ => (error pos "comparison requires two operands with same type"; {exp=Translate.defaultCx, ty=T.INT}))
              | T.INT => (case tr
                  of T.INT => {exp=Translate.compNonStr(expl, expr, oper), ty=T.INT}
                  | _ => (error pos "comparison requires two operands with same type"; {exp=Translate.defaultCx, ty=T.INT}))
              | T.STRING => (case tr
                  of T.STRING => {exp=Translate.compStr(expl, expr, oper), ty=T.INT}
                  | _ => (error pos "comparison requires two operands with same type"; {exp=Translate.defaultCx, ty=T.INT}))
              | _ => (error pos "illegal operand types for comparison"; {exp=Translate.defaultCx, ty=T.INT})
            end
        (* f_lg deals with <, <=, >, >= *)
        and f_lg (left, right, pos, oper) =
            let
              val {exp=expl, ty=tl} = g left
              val {exp=expr, ty=tr} = g right
            in if tl <> T.STRING andalso tl <> T.INT
                then (error pos "illegal operand types for comparison"; {exp=Translate.defaultCx, ty=T.INT})
                else if tl = tr
                    then case tl of T.STRING => {exp=Translate.compStr(expl, expr, oper), ty=T.INT}
                                  | _ => {exp=Translate.compNonStr(expl, expr, oper), ty=T.INT}
                    else (error pos "comparison requires two operands with same type"; {exp=Translate.defaultCx, ty=T.INT})
            end
        (* f_arithm deals with +, -, *, / *)
        and f_arithm (left, right, pos, oper) =
          let
            val {exp=expl, ty=tl} = g left
            val {exp=expr, ty=tr} = g right
          in
            (checkInt ({exp=expl, ty=tl}, pos);
              checkInt ({exp=expr, ty=tr}, pos);
              {exp=Translate.opArithm(expl, expr, oper), ty=T.INT})
          end

     in g expr
    end

 (**************************************************************************
  *                   TRANSLATING DECLARATIONS                             *
  *                                                                        *
  * transdec: (env * tenv * dec * envstack, level, label) -> (env * tenv)  *
  **************************************************************************)
  and transdec (env, tenv, A.VarDec {var, typ, init, pos}, envstack, level, done_label) = 
        let
          val {exp, ty} = transexp (env, tenv, init, envstack, level, done_label)
          val {name, escape} = var
          val acc = Translate.allocInFrame(level)
        in case typ
          (* no specified type, proceed directly *)
          of NONE => (case ty (* ty = actual evaluated type of init *)
            of T.NIL => ((error pos "'nil' type cannot be inferred");
                        (S.enter(env, name, E.VARentry {access=acc, ty=T.INT}), tenv, (LET, S.name(name))::envstack, nil))
            | _ => (S.enter(env, name, E.VARentry {access=acc, ty=ty}),
                    tenv, (LET, S.name(name))::envstack, [Translate.assignExp(Translate.simpleVar(acc, level), exp)]))
          (* found specified type, check if it is OK *)
          | SOME(symbol, _) =>
            let val required = S.look(tenv, symbol)
            in case required
              (* required type is unknown, throw error *)
              of NONE => (error pos ("undeclared type " ^ (S.name symbol));
                          (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil))
              (* found declaration of required type, check if it's compatible with initial value *)
              (* rt = expected return type; ty = actual evaluated type of init *)
              (* NOTE that rt cannot be UNIT or NAME or NIL *)
              | SOME(rt) => (case actual_ty(rt)
                of T.RECORD(_, uref) => (case ty
                    of T.RECORD(_, unique) => if uref = unique
                                              then (S.enter(env, name, E.VARentry {access=acc, ty=ty}),
                                                    tenv, (LET, S.name(name))::envstack, [Translate.assignExp(Translate.simpleVar(acc, level), exp)])
                                              else (error pos ("specified type is incompatible with initial value");
                                                    (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil))
                    | T.NIL => (S.enter(env, name, E.VARentry {access=acc, ty=actual_ty(rt)}),
                                tenv, (LET, S.name(name))::envstack, [Translate.assignExp(Translate.simpleVar(acc, level), exp)])
                    | _ => (error pos ("specified type is incompatible with initial value");
                            (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil)))
                | T.INT => (case ty
                    of T.INT => (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, [Translate.assignExp(Translate.simpleVar(acc, level), exp)])
                    | _ => (error pos ("specified type is incompatible with initial value");
                            (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil)))
                | T.STRING => (case ty
                    of T.STRING => (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, [Translate.assignExp(Translate.simpleVar(acc, level), exp)])
                    | _ => (error pos ("specified type is incompatible with initial value");
                            (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil)))
                | T.ARRAY(_, uref) => (case ty
                    of T.ARRAY(_, unique) => if uref = unique
                                              then (S.enter(env, name, E.VARentry {access=acc, ty=ty}),
                                                    tenv, (LET, S.name(name))::envstack, [Translate.assignExp(Translate.simpleVar(acc, level), exp)])
                                              else (error pos ("specified type is incompatible with initial value");
                                                    (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil))
                    | _ => (error pos ("specified type is incompatible with initial value");
                            (S.enter(env, name, E.VARentry {access=acc, ty=ty}), tenv, (LET, S.name(name))::envstack, nil)))
                | _ => impossible "unexpected type returned by actual_ty")
            end
        end

    (* process (possibly) mutually recursive type/function declarations in two passes *)
    | transdec (env, tenv, A.FunctionDec(fundecs), envstack, level, done_label) = 
      let
        (* detect and remove duplicates *)
        fun refine_fundecs (nil, previous) = previous
          | refine_fundecs (fundec::fundecs, previous) =
            let
              val {name, params, result, body, pos} = fundec
            in
              if nodup_fundecs (fundec, previous)
              then refine_fundecs (fundecs, fundec::previous)
              else (error pos ("duplicated function identifier '" ^ (S.name name) ^ "' in sequence of mutually recursive functions");
                    refine_fundecs (fundecs, previous))
            end
        and nodup_fundecs (fundec, first::rest) =
            let
              val {name, params, result, body, pos} = fundec
              val fname = name
              val {name, params, result, body, pos} = first
            in
              if (S.name fname) = (S.name name)
              then false
              else nodup_fundecs (fundec, rest)
            end
          | nodup_fundecs (fundec, nil) = true
        val fundecs' = rev(refine_fundecs(fundecs, nil))
        val (env', tenv') = transheader(env, tenv, A.FunctionDec(fundecs'), level, done_label)
        val (env'', tenv'') = transbody(env', tenv', A.FunctionDec(fundecs'), envstack, level, done_label)
      in
        (env'', tenv'', envstack, nil)
      end

    | transdec (env, tenv, A.TypeDec(typedecs), envstack, level, done_label) =
      let 
        (* detect and remove duplicates *)
        fun refine_typedecs (nil, previous) = previous
          | refine_typedecs (typedec::typedecs, previous) =
            let
              val {name, ty, pos} = typedec
            in
              if nodup_typedecs (typedec, previous)
              then refine_typedecs (typedecs, typedec::previous)
              else (error pos ("duplicated type identifier '" ^ (S.name name) ^ "' in sequence of mutually recursive types");
                    refine_typedecs (typedecs, previous))
            end
        and nodup_typedecs (typedec, first::rest) =
            let
              val {name, ty, pos} = typedec
              val fname = name
              val {name, ty, pos} = first
            in
              if (S.name fname) = (S.name name)
              then false
              else nodup_typedecs (typedec, rest)
            end
          | nodup_typedecs (typedec, nil) = true
        val typedecs' = rev(refine_typedecs(typedecs, nil))
        val (env', tenv') = transheader(env, tenv, A.TypeDec(typedecs'), level, done_label)
        val (env'', tenv'') = transbody(env', tenv', A.TypeDec(typedecs'), envstack, level, done_label)
      in
        (env'', tenv'', envstack, nil)
      end

  (* private helper function to process all the headers of mutually-recursive stuff in one pass *)
  (* takes in env, tenv, and either fundecs or typedecs *)
  (* returns new (env, tenv) in which only placeholders for the declarations are added *)
  and transheader (env, tenv, A.FunctionDec(fundec::fundecs), level, done_label) = 
      let
        fun extract_type(param) = 
          let
            val {var, typ, pos} = param
            val argtype = S.look(tenv, typ)
          in case argtype
            of NONE => (error pos ("undeclared type " ^ (S.name typ)); T.INT)
            | SOME(t) => t
          end
        val {name, params, result, body, pos} = fundec
        val tresult = case result
          of NONE => T.UNIT
          | SOME(symbol, _) => (case S.look(tenv, symbol)
            of NONE => (error pos ("undeclared type " ^ (S.name symbol)); T.UNIT)
            | SOME(t) => t)
        val formals = map extract_type params
        val env' = S.enter(env, name, E.FUNentry({level=Translate.newLevel {parent=level, formals=formals}, label=Translate.newLabel(), formals=formals, result=tresult}))
      in transheader (env', tenv, A.FunctionDec(fundecs), level, done_label)
      end

    | transheader (env, tenv, A.TypeDec(typedec::typedecs), level, done_label) = 
      let
        val {name, ty, pos} = typedec
        val tenv' = S.enter(tenv, name, T.NAME(name, ref NONE))
      in transheader (env, tenv', A.TypeDec(typedecs), level, done_label)
      end

    | transheader (env, tenv, A.FunctionDec([]), level, _) = (env, tenv)
    | transheader (env, tenv, A.TypeDec([]), level, _) = (env, tenv)
    | transheader (env, tenv, _, _, _) = impossible "unexpected declaration header"

  (* private helper function to process all the bodies of mutually-recursive stuff in a second pass *)
  (* the env, tenv arguments expect the T.NAME placeholders already present *)
  and transbody (env, tenv, A.FunctionDec(fundec::fundecs), envstack, level, done_label) =
      let
        (* helper function to add all parameter names into env *)
        fun add_param_names(env, [], n, stack, plev) = (env, (FUNCTION, "")::stack)
          | add_param_names(env, {var, typ, pos}::params, n, stack, plev) = 
            let
              val {name, escape} = var
              val argtype = case S.look(tenv, typ)
                of NONE => (error pos ("undeclared type " ^ (S.name typ)); T.INT)
                | SOME(t) => t
              val env' = S.enter(env, name, E.VARentry {access=Translate.nthParam(plev, n), ty=argtype})
            in add_param_names(env', params, n+1, (FUNCTION, S.name(name))::stack, plev)
            end
        val {name, params, result, body, pos} = fundec
        (* retrieve the new level and label for this function created in the transheader first pass *)
        val (plev, lab) = case S.look(env, name) of NONE => impossible "failed to retrieve FUNentry"
                    | SOME(E.FUNentry {level=lev, label=la, formals=_, result=_}) => (lev, la)
                    | _ => impossible "probable VARentry overwrite for FUNentry"
        (* add parameters to the environment table *)
        val (env', envstack') = add_param_names(env, params, 0, envstack, plev)
        (* type-check the body of the function *)
        val {exp, ty} = transexp (env', tenv, body, envstack', plev, done_label)
        val tresult = case result
          of NONE => T.UNIT
          | SOME(symbol, _) => (case S.look(tenv, symbol)
            of NONE => T.UNIT (* don't throw error here, because same error would have been thrown in first pass *)
            | SOME(t) => actual_ty(t))
      in ((case ty (* ty = actual return type of the body *)
          of T.RECORD(_, uref) => (case tresult (* tresult = expected return type as per function prototype *)
            of T.RECORD(_, unique) => if uref = unique then ()
                                      else (error pos "value of body expression does not match function definition")
            | _ => (error pos "type of body expression does not match function definition"))
          | T.INT => (case tresult
            of T.INT => ()
            | _ => (error pos "type of body expression does not match function definition"))
          | T.STRING => (case tresult
            of T.STRING => ()
            | _ => (error pos "type of body expression does not match function definition"))
          | T.ARRAY(_, uref) => (case tresult
            of T.ARRAY(_, unique) => if uref = unique then ()
                                      else (error pos "value of body expression does not match function definition")
            | _ => (error pos "type of body expression does not match function definition"))
          | T.NIL => (case tresult
            of T.RECORD(_, _) => ()
            | _ => (error pos "type of body expression does not match function definition"))
          | T.UNIT => (case tresult
            of T.UNIT => ()
            | _ => (error pos "type of body expression does not match function definition"))
          | _ => impossible "unexpected type returned by transexp");
        Translate.funDec {level=plev, label=lab, body=exp}; (* add function fragment PROC *)
        transbody (env, tenv, A.FunctionDec(fundecs), envstack, level, done_label))
      end

    | transbody (env, tenv, A.TypeDec(typedec::typedecs), envstack, level, done_label) =
      let
        val {name, ty, pos} = typedec
        val t = transty(tenv, ty)
        val SOME placeholder = S.look(tenv, name) (* placeholder is supposed to be the ref NONE thing *)
        fun getref (T.NAME(symbol, r)) = r
          | getref _ = impossible "unexpected format for placeholder"
      in
        let
          val r = getref(placeholder)
        in
          (r := SOME(t);
          transbody(env, S.enter(tenv, name, actual_ty_safe(placeholder, pos)), A.TypeDec(typedecs), envstack, level, done_label))
        end
      end

    | transbody (env, tenv, A.FunctionDec([]), _, _, _) = (env, tenv)
    | transbody (env, tenv, A.TypeDec([]), _, _, _) = (env, tenv)
    | transbody (env, tenv, _, _, _, _) = impossible "unexpected declaration body"

  (*** transdecs : (E.env * E.tenv * A.dec list * stack * level) -> (E.env * E.tenv * stack) ***)
  and transdecs (env,tenv,nil,envstack,level,done_label, existing : Translate.gexp list) = (env, tenv, envstack, existing)
    | transdecs (env,tenv,dec::decs,envstack,level,done_label, existing : Translate.gexp list) =
	let val (env',tenv',envstack',new_assign) = transdec (env,tenv,dec,envstack,level,done_label)
 	 in transdecs (env',tenv',decs,envstack',level,done_label,existing @ new_assign)
	end

  (*** transprog : A.exp -> {exp : ir_code, ty : T.ty} ***)
  fun transprog prog = 
    let
      val main_level = Translate.newLevel {parent=Translate.outermost, formals=nil}
      val default_done_label = Translate.newLabel()
      val {exp=e, ty=t} = transexp(E.base_env, E.base_tenv, prog, nil, main_level, default_done_label)
    in (Translate.funDec {level=main_level, label=Translate.mainLabel(), body=e}; Translate.getResult())
    end

end  (* structure Semant *)
  

