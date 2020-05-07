signature SEMANT =
sig
  type ir_code
  val transprog : Absyn.exp -> {exp: ir_code, ty: Types.ty}
end

structure Semant : SEMANT = 
struct

  structure A = Absyn
  structure E = Env
  structure S = Symbol
  structure T = Types
  val error = ErrorMsg.error
  val Error = ErrorMsg.Error
  type ir_code = unit (* not used for the time being *)

  
  (*** FILL IN DETAILS OF YOUR TYPE CHECKER PLEASE !!! ***)

  (*************************************************************************
   *                       UTILITY FUNCTIONS                               *
   *************************************************************************)

  val loop_nest_queue: int list ref = ref nil
  val loop_nest = ref 0

  fun inc x = (x := !x + 1)

  fun dec x = (x := !x - 1)

  (* checkInt: { exp : ir_code, ty : T.ty } -> unit *)
  fun checkInt ({exp, ty}, pos) = case ty of T.INT => true | _ => ( error pos "integer required"; false )

  fun checkUnit ({exp, ty}, pos) = case ty of T.UNIT => true | _ => ( error pos "unit required"; false )

  fun decode sym = "'" ^ (S.name sym) ^ "'"

  fun compatible (tyleft, tyright) = (
    if tyleft = tyright then true
    else if tyleft = T.NIL then (
      case tyright 
        of T.RECORD (_, _) => true
          | _ => false
    ) else if tyright = T.NIL then (
      case tyleft 
        of T.RECORD (_, _) => true
          | _ => false
    ) else false
  )
          
  (* actual_ty : (E.tenv * T.ty) -> T.ty *)
  fun actual_ty (env, ty) = (
    case ty
      of T.NAME (sym, opTy) => (
        case !opTy
          of NONE => 
          (
            case Symbol.look (env, sym)
              of NONE => ty
               | SOME ty' => (
                 if ty' = ty 
                 then ty
                 else (
                   opTy := SOME ty';
                   actual_ty (env, ty')
                 )
              )
          )
           | SOME ty => actual_ty (env, ty)
     )
      | _ => ty
  )

 (**************************************************************************
  *                   TRANSLATING TYPE EXPRESSIONS                         *
  *                                                                        *
  *              transty : (E.tenv * A.ty) -> (T.ty * A.pos)               *
  *************************************************************************)
  fun transty ( tenv, A.ArrayTy (id, pos) ) = ( 
                                                case S.look(tenv, id) of
                                                  NONE => ( 
                                                    error pos ("Undefined type " ^ S.name id ^ ". Assuming type is INT.");
                                                    (T.INT, pos)
                                                  )
                                                | SOME ty => (T.ARRAY ( ty, ref () ), pos) 
                                             )
    | transty ( tenv, A.NameTy (id, pos) ) =  ( 
                                                case S.look(tenv, id) of
                                                  NONE => ( 
                                                    error pos ("Undefined type " ^ S.name id ^ ". Assuming type is INT."); 
                                                    (T.INT, pos)
                                                  )
                                                | SOME ty => (ty, pos)
                                             )
    | transty ( tenv, A.RecordTy (tyfields) ) = (
                                                  let 
                                                    (* transfield: tfield -> ( S.symbol * T.ty ) 
                                                       tfield = { name: S.symbol, typ: S.symbol, pos: A.pos } *)
                                                    fun transfield { name: S.symbol, typ: S.symbol, pos: A.pos } = 
                                                      ( 
                                                        case S.look(tenv, typ) of 
                                                          NONE => ( 
                                                            error pos ("Undefined type " ^ S.name typ ^ ". Assuming type is INT."); 
                                                            (name, T.INT) 
                                                          )
                                                        | SOME ty => (name, ty)
                                                      )
                                                    val translated_fields = List.map transfield tyfields
                                                  in
                                                    case tyfields of 
                                                      nil => (T.RECORD ( nil, ref () ), 0) 
                                                    | t::ts => ( T.RECORD ( translated_fields, ref () ), #pos(t) )
                                                  end
                                               )
    


 (**************************************************************************
  *                   TRANSLATING EXPRESSIONS                              *
  *                                                                        *
  *  transexp : (E.env * E.tenv) -> (A.exp -> {exp : ir_code, ty : T.ty})  *
  **************************************************************************)
  fun transexp (env, tenv) expr =
    let fun g (A.OpExp {left,oper=A.NeqOp,right,pos}) = 
          (
            let val {exp = _, ty = tyleft} = g left
                val {exp = _, ty = tyright} = g right
            in
              if compatible (tyleft, tyright)
              then {exp=(), ty=T.INT}
              else ( error pos "Type mismatch in inequality comparison \"<>\""; { exp = (), ty = T.INT } )
            end
          )

         | g (A.OpExp {left,oper=A.EqOp,right,pos}) =
         (
          let 
            val {exp = _, ty = tyleft} = g left
            val {exp = _, ty = tyright} = g right
          in 
            (
              if compatible (tyleft, tyright)
              then { exp = (), ty = T.INT }
              else ( error pos "Type mismatch in equality comparison \"=\""; { exp = (), ty = T.INT} )
            )
          end
         )

        | g (A.OpExp {left,oper=A.GtOp,right,pos}) =
         (
          let val {exp = _, ty = tyleft} = g left
            val {exp = _, ty = tyright} = g right
          in 
            if tyleft <> tyright
            then (error pos "Type mismatch in equality comparison \">\""; {exp=(), ty=T.INT})
            else if tyleft <> T.INT andalso tyleft <> T.STRING
            then (error pos "Illegal type for order comparison \">\"."; {exp=(), ty=T.INT})
            else {exp=(), ty=T.INT}
          end
         )

        | g (A.OpExp {left,oper=A.LtOp,right,pos}) =
         (
          let val {exp = _, ty = tyleft} = g left
            val {exp = _, ty = tyright} = g right
          in 
            if tyleft <> tyright
            then (error pos "Type mismatch in equality comparison \"<\""; {exp=(), ty=T.INT})
            else if tyleft <> T.INT andalso tyleft <> T.STRING
            then (error pos "Illegal type for order comparison \"<\"."; {exp=(), ty=T.INT})
            else {exp=(), ty=T.INT}
          end
         )

         | g (A.OpExp {left,oper=A.GeOp,right,pos}) =
         (
          let val {exp = _, ty = tyleft} = g left
            val {exp = _, ty = tyright} = g right
          in 
            if tyleft <> tyright
            then (error pos "Type mismatch in equality comparison \">=\""; {exp=(), ty=T.INT})
            else if tyleft <> T.INT andalso tyleft <> T.STRING
            then (error pos "Illegal type for order comparison \">=\"."; {exp=(), ty=T.INT})
            else {exp=(), ty=T.INT}
          end
         )

         | g (A.OpExp {left,oper=A.LeOp,right,pos}) =
         (
          let val {exp = _, ty = tyleft} = g left
            val {exp = _, ty = tyright} = g right
          in 
            if tyleft <> tyright
            then (error pos "Type mismatch in equality comparison \"<=\""; {exp=(), ty=T.INT})
            else if tyleft <> T.INT andalso tyleft <> T.STRING
            then (error pos "Illegal type for order comparison \"<=\"."; {exp=(), ty=T.INT})
            else {exp=(), ty=T.INT}
          end
         )

        | g (A.OpExp {left,oper=A.PlusOp,right,pos}) =
        (
            checkInt (g left, pos);
            checkInt (g right, pos);
            {exp=(), ty=T.INT}
        )

        | g (A.OpExp {left,oper=A.MinusOp,right,pos}) =
        (
            checkInt (g left, pos);
            checkInt (g right, pos);
            {exp=(), ty=T.INT}
        )
        
        | g (A.OpExp {left,oper=A.TimesOp,right,pos}) =
        (
            checkInt (g left, pos);
            checkInt (g right, pos);
            {exp=(), ty=T.INT}
        )

        | g (A.OpExp {left,oper=A.DivideOp,right,pos}) =
        (
            checkInt (g left, pos);
            checkInt (g right, pos);
            {exp=(), ty=T.INT}
        )

        | g (A.IntExp ival) = { exp = (), ty = T.INT }

        | g (A.StringExp sval) = { exp = (), ty = T.STRING }

        | g (A.NilExp) = { exp = (), ty = T.NIL }

        | g (A.VarExp var) = h var

        | g (A.AppExp { func, args, pos }) = 
        (
          let
            val count = ref ( length args + 1 )
            fun checkarg (formal, arg) = 
            (
              let 
                val { exp = _, ty = ty_of_arg } = g arg
                val formal = actual_ty (tenv, formal)
              in
                dec count;
                if Bool.not( compatible(formal, ty_of_arg) )
                then error pos ( "Type mismatch in parameter " ^ Int.toString (!count) )
                else ()
              end
            )
          in
            case S.look (env, func) of
              SOME ( E.FUNentry {level, label, formals, result} ) => (
                if length formals <> length args 
                then ( 
                  error pos ("Expecting " ^ Int.toString (length formals) ^ " parameters, " ^ Int.toString (length args) ^ " were given.");
                  { exp = (), ty = actual_ty (tenv, result) } 
                ) else ( 
                  List.map checkarg ( List.rev ( ListPair.zip (formals, args) ) ); 
                  { exp = (), ty = actual_ty (tenv, result) }
                )
              )
              | NONE => ( error pos "Undefined identifier in function call. Assuming function returns INT."; { exp = (), ty = T.INT } )
              | _ => ( error pos "Identifier is not bound to a function. Assuming function returns INT."; { exp = (), ty = T.INT } )
          end
        )

        | g (A.RecordExp { typ, fields, pos }) =
        (
          let
            fun checkField (field: (S.symbol * T.ty), argument: (S.symbol * A.exp * A.pos)) = (
              if (#1 field) <> (#1 argument)
              then (
                error (#3 argument) ( "Expected binding for field " ^ decode (#1 field) ^ ", found binding for " ^ decode (#1 argument) ^ "." );
                false
              )
              else (
                let 
                  val ty_of_field = actual_ty (tenv, #2 field)
                  val { exp = _, ty = ty_of_arg } = g (#2 argument)
                in
                  if compatible (ty_of_field, ty_of_arg)
                  then true
                  else ( 
                    error (#3 argument) ( "Type of field " ^ decode (#1 field) ^ " initializer does not agree with record declaration." );
                    false
                  ) 
                end
              )
            )
            (* rectys: ( S.symbol * T.ty) list, fields: (S.symbol * A.exp * A.pos) list *)
            fun checkFields (fields, arguments) = (
              if length fields <> length arguments
              then (
                error pos "Number of arguments doesn't match with the number of fields"; false
              ) else (
                let
                  val results = ListPair.map checkField (fields, arguments)
                in
                  List.foldr ( fn (x, y) => x andalso y ) true results
                end
              )
          )
          in
            case S.look (tenv, typ)
              of NONE => (error pos ("Unsupported record type " ^ S.name typ ^ ". Assuming type INT"); {exp=(), ty=T.INT})
               | SOME (ty_of_rec) => (
                  let
                    val ty_of_rec = actual_ty (tenv, ty_of_rec)
                  in
                    (
                      case ty_of_rec of
                        T.RECORD (ty_of_fields, _) =>
                        (
                          checkFields (ty_of_fields, fields);
                          { exp = (), ty = ty_of_rec }
                        )
                      | _ => (error pos ("Unsupported record type " ^ S.name typ ^ ". Assuming type INT"); {exp=(), ty=T.INT})
                    )
                  end
               )
                  
          end
        )

        | g ( A.SeqExp (nil) ) = {exp = (), ty = T.UNIT}

        | g ( A.SeqExp (e::nil) ) = g (#1 e)
        
        | g ( A.SeqExp (e::es) ) = ( g (#1 e); g (A.SeqExp es) )

        | g (A.AssignExp { var, exp, pos }) =
        (
          let 
            fun helper () = (
              let
                val {exp = _, ty = tyleft} = h var
                val {exp = _, ty = tyright} = g exp
              in
                (
                  if tyleft = tyright 
                  then { exp = (), ty = T.UNIT }
                  else ( error pos ("Type of rvalue in assignment expression does not match lvalue."); { exp = (), ty = T.UNIT } )
                )
              end
            )
          in
            (
              case var
                of A.SimpleVar (id, _) => (
                  let 
                    val SOME (E.VARentry ({access, ty, iscounter}) ) = S.look (env, id)
                  in
                    if iscounter
                    then ( error pos "Attempt to assign to a FOR loop induction variable."; {exp = (), ty = T.INT} )
                    else helper ()
                  end
                )
                | _ => helper ()
            )
          end
        )
        (* A.IfExp of {test: A.exp, then': A.exp, else': A.exp option, pos: A.pos} *)
        | g (A.IfExp {test = test_exp, then' = then_exp, else' = NONE, pos}) = 
        (
          checkInt (g test_exp, pos);
          checkUnit (g then_exp, pos);
          { exp = (), ty = T.UNIT }
        )
        | g (A.IfExp {test = test_exp, then' = then_exp, else' = SOME else_exp, pos}) = 
        (
          checkInt (g test_exp, pos);
          let
            val {exp = _, ty = ty_of_then} = g then_exp
            val {exp = _, ty = ty_of_else} = g else_exp
          in
            if compatible (ty_of_then, ty_of_else)
            then { exp = (), ty = ty_of_then }
            else (
              error pos "Type mismatch between THEN and ELSE clauses. Assuming expression is an INT.";
              { exp = (), ty = T.INT }
            )
          end
        )

        (* 
          A.WhileExp of {test: A.exp, body: A.exp, pos: A.pos}
          1. test must be an int expression
          2. body must produce no value
        *)
        | g (A.WhileExp { test, body, pos }) = 
        (
          loop_nest := !loop_nest + 1;
          (* print ( Int.toString ( !loopnest ) ^ "\n" ); *)
          checkInt ( g test, pos );
          checkUnit ( g body, pos );
          loop_nest := !loop_nest - 1;
          { exp = (), ty = T.UNIT }
        )

        (* 
          A.ForExp of {var: A.vardec, lo: A.exp, hi: A.exp, body: A.exp, pos: A.pos}
          A.vardec = { name: A.symbol, escape: bool ref }
        *)
        | g (A.ForExp{ var = { name, escape }, lo, hi, body, pos  } ) = 
        (
          let
            val upper_bound = S.symbol "TIGER_COMPILER_FOR_LOOP_UPPER_BOUND"
            val env' = S.enter ( 
              S.enter (env, name, E.VARentry { access = (), ty = T.INT, iscounter = true } ),
              upper_bound,
              E.VARentry { access = (), ty = T.INT, iscounter = false }
            )
            val exp = A.WhileExp {
              test = A.OpExp {
                left = A.VarExp ( A.SimpleVar ( name, pos ) ),
                right = A.VarExp ( A.SimpleVar ( upper_bound, pos ) ),
                oper = A.LeOp,
                pos = pos
              },
              body = body,
              pos = pos
            }
          in
            transexp (env', tenv) exp
          end
        )

        | g (A.BreakExp pos ) = 
        (
          if !loop_nest > 0
          then ( { exp = (), ty = T.UNIT } )
          else ( error pos "BREAK expression found outside of WHILE or FOR loop."; { exp = (), ty = T.UNIT } )
        )

        | g (A.LetExp { decs, body, pos }) = 
        (
          let 
            val (env', tenv') = transdecs (env, tenv, decs)
          in
            (* print ( "Inside LetExp of length " ^ ( Int.toString (length decs) ) ^ "\n"); *)
            transexp (env', tenv') body
          end
        )

        | g (A.ArrayExp { typ, size, init, pos }) = 
        (
          case S.look (tenv, typ)
            of SOME ( ty_of_arr ) => 
             (
              let 
                val ty_of_arr = actual_ty (tenv, ty_of_arr)
              in 
                (
                  case ty_of_arr
                    of T.ARRAY ( ty_of_element, _ ) => 
                    (
                        let 
                          val ty_of_element = actual_ty (tenv, ty_of_element)
                          val { exp = _, ty = ty_of_init } = g init
                        in
                          ( 
                            checkInt (g size, pos);
                            if compatible (ty_of_element, ty_of_init)
                            then { exp = (), ty = ty_of_arr }
                            else ( 
                              error pos "Type of array initializer does not agree with array declaration.";
                              { exp = (), ty = T.UNIT }
                            )
                          )
                        end
                    )
                    | _ => ( error pos ("undefined array type " ^ (S.name typ) ); { exp = (), ty = T.INT } )
                )
              end
             )
             | _ => ( error pos ("undefined array type " ^ (S.name typ) ); { exp = (), ty = T.INT } )
        )

        (* function dealing with "var", may be mutually recursive with g *)
        and h (A.SimpleVar (id,pos)) = 
        ( 
          case S.look(env, id) of
            SOME (E.VARentry { access = _, ty = ty, iscounter }) => { exp = (), ty = actual_ty (tenv, ty) }
          | _ => ( error pos ( "Variable (" ^ S.name id ^ ") is of an unknown type, or the variable has not been defined." ); { exp = (), ty = T.INT } ) 
        )

         (* FieldVar of var * symbol * pos *)
        |  h (A.FieldVar (v,id,pos)) = 
        (
            let 
              (* Apply function h recursively on v *)
              val {exp = _, ty = ty_of_var} = h v
              fun getFieldType (id: S.symbol, rectys: (S.symbol * T.ty) list) = 
              (
                case rectys of 
                  (* If the corresponding field is not found, print error and return Ty.INT *)
                  nil => ( error pos ("field " ^ S.name id ^ " can't be found"); {exp=(), ty=T.INT} )
                  (* If id matches with the field, return the type of the field*)
                | (sym, type_of_this_sym)::rest => 
                  (
                    if id = sym
                    then { exp = (), ty = actual_ty (tenv, type_of_this_sym) }
                    else getFieldType(id, rest)
                  ) 
              ) 
            in
              case ty_of_var of 
                T.RECORD ( rectys, _ ) => getFieldType (id, rectys)
              | _ => ( error pos ("field " ^ S.name id ^ " can't be found"); {exp=(), ty=T.INT} )
            end
        )

        |  h (A.SubscriptVar (v: A.var, exp: A.exp, pos: A.pos)) = 
        (
          let
            val {exp = _, ty = ty_of_var} = h v
            val {exp = _, ty = ty_of_sub} = g exp
          in
            (
              case ty_of_var 
               of T.ARRAY ( arr_ty, _ ) =>
                  (
                    let 
                      val arr_ty = actual_ty (tenv, arr_ty)
                    in 
                    ( 
                      if ty_of_sub = T.INT 
                      then { exp = (), ty = arr_ty } 
                      else ( error pos ("subscript is not an integer"); {exp=(), ty=T.INT} )
                    )
                    end
                  )
                | _ => ( error pos ("var is not an array"); {exp=(), ty=T.INT} )
            )
          end
        )
    in
      g expr
    end

 (**************************************************************************
  *                   TRANSLATING DECLARATIONS                             *
  *                                                                        *
  *  transdec : (E.env * E.tenv * A.dec) -> (E.env * E.tenv)               *
  **************************************************************************)

  (* A.FunctionDec of fundec list *)
  and transdec (env, tenv, A.FunctionDec(declist)) =
    let
      (* 
        formals = 
        {
          var: A.vardec, 
          typ: symbol, 
          pos: pos
        }
        vardec = { name: symbol, escape: bool ref }
        transparam: A.formals -> {name: S.symbol, ty: T.ty}
      *)
      fun transparam { var = { name, escape }, typ, pos } = 
      (
        case S.look (tenv, typ) of 
          NONE => (error pos ("Unsupported record type " ^ S.name typ ^ ". Assuming type INT"); { name = name, ty = T.INT })
        | SOME ty_of_var => { name = name, ty = ty_of_var }
      )

      (* ( {name: S.symbol, ty: T.ty} * E.env ) -> E.env *)
      fun enterparam ({ name, ty }, env) = 
      (
        S.enter ( env, name, E.VARentry { access = (), ty = ty, iscounter = false } )
      )

      (* 
        fundec = 
        {
          name: symbol, 
          params: formals list,
          result: (symbol * pos) option,
          body: exp, 
          pos: pos
        }
      *)
      fun transheader {name, params, result, body, pos} = 
      (
        let          
          (* ty_of_params: T.ty list *)
          val ty_of_params = List.map #ty (List.map transparam params)
        in
          (* 
            FUNentry of 
            {
              level: level (unit),
              label: label (unit), 
              formals: ty list, 
              result: ty
            }
          *)
          (
            case result of 
              NONE =>
              (
                E.FUNentry
                {
                  level = (), 
                  label = (), 
                  formals = ty_of_params,
                  result =  T.UNIT
                }
              )
            | SOME (sym_of_res, pos_of_res) => 
              (
                case S.look (tenv, sym_of_res) of
                  NONE =>
                  (
                    error pos ("Undefined return type " ^ S.name sym_of_res ^ ". Assuming function returns UNIT");
                    E.FUNentry
                    {
                      level = (),
                      label = (),
                      formals = ty_of_params,
                      result = T.UNIT
                    }
                  )
                | SOME ty_of_res =>
                  (
                    E.FUNentry
                    {
                      level = (),
                      label = (),
                      formals = ty_of_params,
                      result = ty_of_res
                    }
                  )
              )
          )
        end
      )

      (* Translate function into function headers *)
      fun enterheader (dec, env) = S.enter (env, #name dec, transheader dec)

      (* Put function headers into the env *)
      val env' = List.foldl enterheader env declist

      (* Check the type of the function body *)
      fun check_func_body {name, params, result, body, pos} = 
      (
        let
          val env'' =
          (
            let 
            (* ty_of_params: { name: S.symbol, ty: T.ty } list *)
              val ty_of_params = List.map transparam (params)
            in
              List.foldl enterparam env' ty_of_params
            end
          )
          
          val { exp = _, ty = ty_of_body } = transexp (env'', tenv) body

        in
          (
            case S.look (env', name) of
              SOME ( E.FUNentry ({level, label, formals, result}) ) => 
                (
                  if compatible(actual_ty (tenv, result), ty_of_body)
                  then true
                  else ( error pos ("Result type of function body does not match declared return type."); false )
                )
              | _ => ( error pos ("function header of " ^ S.name (name) ^ " not found"); false )
          )
        end
      )
      (* Check all functions and store results in checklist *)
      val checklist = (
        loop_nest_queue := (!loop_nest)::(!loop_nest_queue);
        loop_nest := 0; 
        List.map check_func_body declist
      )
      (* Check if all functions match with bodies *)
      val checkres = (
        loop_nest := hd (!loop_nest_queue);
        loop_nest_queue := tl (!loop_nest_queue);
        List.foldl (fn (x, y) => x andalso y) true checklist
      )
    in
      (env', tenv)
    end

    | transdec (env, tenv, A.VarDec( { var={name, escape}, typ=NONE, init, pos } ) ) = 
      (* name: S.symbol, init: A.exp, pos: A.pos *)
      (
        let
          val { exp = _, ty = ty_of_init } = transexp (env, tenv) init
        in
          if ty_of_init = T.NIL
          then ( error pos "Illegal assignment of NIL to declaration of a variable of an unknown type."; (env, tenv) )
          else ( S.enter(env, name, E.VARentry { access = (), ty = ty_of_init, iscounter = false }), tenv )
        end
      ) 
      
    | transdec (env, tenv, A.VarDec( { var={name, escape}, typ=SOME (typ_of_var, typ_pos), init, pos } ) ) =
      (
        let
          val { exp = _, ty = ty_of_init } = transexp (env, tenv) init
        in
          (
            case S.look (tenv, typ_of_var) of
              NONE => ( error pos ("Undefined type " ^ S.name typ_of_var); (env, tenv) )
            | SOME ty_of_var => 
              (
                let 
                  val ty_of_var = actual_ty (tenv, ty_of_var)
                in
                  if compatible (ty_of_var, ty_of_init)
                  then (S.enter(env, name, E.VARentry { access = (), ty = ty_of_var, iscounter = false }), tenv)
                  else (
                    error pos ( "Type mismatch in declaration of variable " ^ (S.name name) );
                    (env, tenv)
                  )
                end
              )
          )
        end
      )

    | transdec (env, tenv, A.TypeDec(declist)) =
    (* 
      TypeDec of { name: S.symbol, ty: A.ty, pos: A.pos} list
    *)
    if length declist = 0
    then (env, tenv)
    else (
      let
        val pos_of_first = #pos (hd declist)
        fun enterheader ({name, ty, pos}, env) = S.enter ( env, name, T.NAME (name, ref NONE) )
        fun entertype ({name, ty, pos}, env) = (
          let
            val (ty_of_ty, _) = transty (env, ty)
          in 
            (
              case S.look (env, name)
                of SOME (ty_of_name) => (
                  (* Recursive definition *)
                  if ty_of_name = actual_ty (env, ty_of_ty)
                  then ( 
                    error pos_of_first ("Primitive (non-array/record) cycle detected in recursive type definition; Type forced to INT. (" ^ (S.name name) ^ ").");
                    env
                  )
                  else S.enter ( env, name, T.NAME ( name, ref (SOME ty_of_ty) ) )
                )
                | _ => ( error pos ("Undefined type " ^ (S.name name) ^ "." ) ; env)
            ) 
          end
        )
        val tenv' = List.foldl enterheader tenv declist
        val tenv'' = List.foldl entertype tenv' declist
      in
        (env, tenv'')
      end
    )
    
  (*** transdecs : (E.env * E.tenv * A.dec list) -> (E.env * E.tenv) ***)
  and transdecs (env,tenv,nil) = (env, tenv)
    | transdecs (env,tenv,dec::decs) =
      let 
        val (env',tenv') = transdec (env,tenv,dec)
      in 
        transdecs (env',tenv',decs)
      end

  (*** transprog : A.exp -> {exp : ir_code, ty : T.ty} ***)
  fun transprog prog = transexp (E.base_env, E.base_tenv) prog

end  (* structure Semant *)
  

