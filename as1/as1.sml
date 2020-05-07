type id = string;

datatype binop = PLUS | MINUS | TIMES | DIV;

datatype stm = SEQ of stm * stm
	     | ASSIGN of id * exp
	     | PRINT of exp list
        and exp = VAR of id
	        | CONST of int
            | BINOP of exp * binop * exp
            | ESEQ of stm * exp;

val prog = 
SEQ(ASSIGN("a",BINOP(CONST 5, PLUS, CONST 3)),
 SEQ(ASSIGN("b",ESEQ(PRINT[VAR"a",BINOP(VAR"a",MINUS,CONST 1)],
	             BINOP(CONST 10, TIMES, VAR"a"))),
  PRINT[VAR "b"]));

exception EmptyList;

fun max(nil) = raise EmptyList | max([x]) = x | max(x::xs) = let val xs_max = max(xs) in if x > xs_max then x else xs_max end;

fun maxargs (PRINT(nil)) = 0
    | maxargs (PRINT(exp_list)) = max(length(exp_list)::max(map maxargs_exp exp_list)::nil)
    | maxargs (SEQ(s1, s2)) = max(maxargs(s1)::maxargs(s2)::nil)
    | maxargs (ASSIGN(_, e)) = maxargs_exp(e)
    and maxargs_exp (BINOP(e1, _, e2)) = max(maxargs_exp(e1)::maxargs_exp(e2)::nil)
    | maxargs_exp (ESEQ(s, e)) = max(maxargs(s)::maxargs_exp(e)::nil)
    | maxargs_exp (VAR(_)) = 0
    | maxargs_exp (CONST(_)) = 0;

exception KeyNotFound of string;

datatype entry = ENTRY of id * int;

fun lookup (n: id, nil) = raise KeyNotFound (n)
    | lookup (n: id, ENTRY(k, v)::es) = if n = k then v else lookup(n, es);

fun update (k: id, v: int, t: entry list) = ENTRY(k, v)::t;

(* interp_stm: (stmt * entry list) -> entry list *)
fun interp_stm (SEQ (s1, s2), t) = let val t1 = interp_stm (s1,  t) in interp_stm (s2, t1) end
    | interp_stm (ASSIGN (i, e), t) = let val ep = interp_exp (e, t) in update(i, #1(ep), #2(ep)) end
    | interp_stm (PRINT (nil), t) = (print ("\n"); t)
    | interp_stm (PRINT (e::es), t) = let val ep = interp_exp(e, t) in (print (Int.toString(#1(ep)) ^ " "); interp_stm (PRINT (es), #2(ep))) end
    (* interp_exp: (exp * entry list) -> (int * entry list) *)
    and interp_exp (VAR (i), t) = (lookup (i, t), t)
    | interp_exp (CONST (c), t) = (c, t)
    | interp_exp (BINOP (e1, PLUS, e2), t) = let val ep1 = interp_exp (e1, t) val ep2 = interp_exp (e2, #2(ep1)) in (#1(ep1) + #1(ep2), #2(ep2)) end
    | interp_exp (BINOP (e1, MINUS, e2), t) = let val ep1 = interp_exp (e1, t) val ep2 = interp_exp (e2, #2(ep1)) in (#1(ep1) - #1(ep2), #2(ep2)) end
    | interp_exp (BINOP (e1, TIMES, e2), t) = let val ep1 = interp_exp (e1, t) val ep2 = interp_exp (e2, #2(ep1)) in (#1(ep1) * #1(ep2), #2(ep2)) end
    | interp_exp (BINOP (e1, DIV, e2), t) = let val ep1 = interp_exp (e1, t) val ep2 = interp_exp (e2, #2(ep1)) in (#1(ep1) div #1(ep2), #2(ep2)) end
    | interp_exp (ESEQ (s, e), t) = let val t1 = interp_stm (s, t) in interp_exp (e, t1) end;

(* interp: stm -> unit *)
fun interp (s: stm) = (interp_stm (s, nil); ()) handle KeyNotFound (var_name) => print (var_name ^ " is not bound to any value. \n")