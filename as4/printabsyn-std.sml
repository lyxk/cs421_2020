(*  PP - Pretty Printer for abstract syntax
    Use as follows:
      PP.pp e         where e : Absyn.exp
    Or use my test functions TS & TN to print the abstract syntax of the
    test cases.
 *)

signature PPSIG =
sig 
  val pp : Absyn.exp -> string
  val TS : string -> unit
  val TN : int -> unit
end (* signature PPSIG *)

structure PP : PPSIG = struct

local open Absyn
      fun decode s = "\"" ^ s ^ "\""   (* later decode \n et al *)
      fun N s = Symbol.name s
      fun LF r = ListFormat.fmt r
in
   fun pp e =
     case e 
      of VarExp v                    => ppv v
       | NilExp                      => "Nil"
       | IntExp i                    => Int.toString i
       | StringExp (s,_)             => decode s
       | AppExp{func,args,pos}       => LF{init= N func ^ "(",
                                           sep= ", ",final= ")",fmt= pp} args
       | OpExp{left,oper,right,pos}  => ("(" ^ pp left ^ ppo oper ^ 
                                         pp  right ^ ")")
       | RecordExp {typ,fields,pos}  => LF{init= N typ ^ "{",sep= ", ",
                                           final= "}",
                                           fmt= (fn (s,e,_)=> N s^"  = "^pp e)}
                                         fields
       | SeqExp (eps)                => LF{init="(",sep=";\n",final=")",
                                          fmt= pp o #1} eps
       | AssignExp{var,exp,pos}      => ppv var ^ " := "  ^ pp exp
       | IfExp {test,then',else'=NONE,pos} => "if " ^ pp test
                                              ^ "\nthen " ^ pp then'
       | IfExp {test,then',else'=SOME(e),pos} => "if " ^ pp test ^ "\nthen "
                                             ^ pp then' ^ "\nelse " ^ pp e
       | WhileExp{test,body,pos}     => "while " ^ pp test ^ " do\n"  ^ pp body
       | ForExp{var,lo,hi,body,pos}  => "for " ^ N (#name var)
                                        ^ " := " ^ pp lo ^ " to "
                                        ^ pp hi ^ " do\n" ^ pp body
       | BreakExp _                  => "break"
       | LetExp {decs,body,pos}      => "let\n" ^ ppds decs
                                        ^ "\nin " ^ pp body ^ " end"
       | ArrayExp{typ,size,init,pos} => N typ ^ "[" ^ pp size ^ "] of " 
                                        ^ pp init
   and ppv v =
     case v 
      of SimpleVar (s,p)     => N s
       | FieldVar (v,s,p)    => ppv v ^ "." ^ N s
       | SubscriptVar(v,e,p) => ppv v ^ "[" ^ pp e ^ "]"

   and ppfd {name,params,result,body,pos} = 
           "function " ^ N name ^ LF{init="(",sep=", ",
                                     final=")",fmt= ppfms} params
           ^ (case result of NONE        => ""
                           | SOME (ty,_) => "  : " ^ N ty)
           ^ " =\n" ^ pp body ^ "\n"

   and pptd {name,ty,pos} = "type " ^ N name ^ " = " ^ ppt ty ^ "\n"

   and ppd (FunctionDec fds) = "[[[ BEGIN fundecs\n" ^ 
                               (String.concat (map ppfd fds)) ^
                               "]]] END fundecs\n"
     | ppd (TypeDec tds)     = "[[[ BEGIN tydecs\n" ^ 
                               (String.concat (map pptd tds)) ^
                               "]]] END tydecs\n"
     | ppd (VarDec{var,typ,init,pos}) = 
           "var " ^ N (#name var) ^ (case typ 
                                      of NONE      => ""
                                       | SOME(n,_) => " : " ^ N n)
           ^ " := " ^ pp init ^ "\n"

   and ppds (d::ds) = ppd d ^ ppds ds
     | ppds []      = ""

   and ppt (NameTy(s,_))  = N s
     | ppt (RecordTy fields) = LF{init="{",sep=", ",final="}",fmt=ppf} fields
     | ppt (ArrayTy(s,_)) = "array of " ^ N s

   and ppo oper =
     case oper 
      of PlusOp  => "+"
       | MinusOp => "-"
       | TimesOp => "*"
       | DivideOp=> "/"
       | EqOp    => "="
       | NeqOp   => "<>"
       | LtOp    => "<"
       | LeOp    => "<="
       | GtOp    => ">"
       | GeOp    => ">="

   and ppf {name,typ,pos} = N name ^ " : " ^ N typ

   and ppfms {var,typ,pos} = N (#name var) ^ " : " ^ N typ

 end

fun TS(s) =
  ((print o pp o Parse.parse) s;
     (* ("/c/cs421/as/testcases/" ^ s ^ ".tig"); *)
   print "\n")

fun TN(n :int) = TS("test" ^ Int.toString n)

end  (* structure PP *)


