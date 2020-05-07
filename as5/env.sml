signature ENV =
sig
  type access
  type level
  type label
  type ty

  datatype enventry 
    = VARentry of {access: access, ty: ty, iscounter: bool}
    | FUNentry of {level: level, label: label, formals: ty list, result: ty}

  type tenv = ty Symbol.table
  type env = enventry Symbol.table

  val base_tenv : tenv
  val base_env : env
end

structure Env : ENV =
struct

  structure S = Symbol
  structure T = Types

  type access = unit   (* not used for the time being *)
  type level = unit    (* not used for the time being *)
  type label = unit    (* not used for the time being *)
  type ty = T.ty

  datatype enventry 
    = VARentry of {access: access, ty: ty, iscounter: bool}
    | FUNentry of {level: level, label: label, formals: ty list, result: ty}

  type tenv = ty Symbol.table

  type env = enventry Symbol.table

  (* add all primtive types into the base_tenv *)
  val base_types = [ 
    (S.symbol "int", T.INT), 
    (S.symbol "string", T.STRING), 
    (S.symbol "unit", T.UNIT) 
  ]
  fun enterparam ( (symbol, ty), env ) = S.enter (env, symbol, ty)
  val base_tenv = List.foldl enterparam S.empty base_types
 
  (* add all primitive library functions into the base_env *)
  val base_funcs = [
    (S.symbol "print", FUNentry {level = (), label = (), formals = [T.STRING], result = T.UNIT}),
    (S.symbol "flush", FUNentry {level = (), label = (), formals = nil, result = T.UNIT}),
    (S.symbol "getchar", FUNentry {level = (), label = (), formals = nil, result = T.STRING}),
    (S.symbol "ord", FUNentry {level = (), label = (), formals = [T.STRING], result = T.INT}),
    (S.symbol "chr", FUNentry {level = (), label = (), formals = [T.INT], result = T.STRING}),
    (S.symbol "size", FUNentry {level = (), label = (), formals = [T.STRING] , result = T.INT}),
    (S.symbol "substring", FUNentry {level = (), label = (), formals = [T.STRING, T.INT, T.INT], result = T.STRING}),
    (S.symbol "concat", FUNentry {level = (), label = (), formals = [T.STRING, T.STRING], result = T.STRING}),
    (S.symbol "not", FUNentry {level = (), label = (), formals = [T.INT], result = T.INT}),
    (S.symbol "exit", FUNentry {level = (), label = (), formals = [T.INT], result = T.UNIT})
  ]
  fun enterfunc ( (symbol, entry), env ) = S.enter (env, symbol, entry)
  val base_env = List.foldl enterfunc S.empty base_funcs

end  (* structure Env *)
  
