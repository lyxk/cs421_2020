signature ENV =
sig
  type access
  type level
  type label
  type ty

  datatype enventry 
    = VARentry of {access: access, ty: ty}
    | FUNentry of {level: level, label: label, formals: ty list, result: ty}

  type tenv = ty Symbol.table
  type env = enventry Symbol.table

  val base_tenv : tenv
  val base_env : env
end

functor EnvGen(Translate : TRANSLATE) : ENV =
struct

  structure S = Symbol
  structure T = Types

  type access = Translate.access
  type level = Translate.level
  type label = Temp.label
  type ty = T.ty

  datatype enventry 
    = VARentry of {access: access, ty: ty}
    | FUNentry of {level: level, label: label, formals: ty list, result: ty}

  type tenv = ty Symbol.table

  type env = enventry Symbol.table

  (* here you need to add all primtive types into the base_tenv *)
  val base_tenv = let val t = S.empty
      val t = S.enter(t, S.symbol("int"), T.INT)
      val t = S.enter(t, S.symbol("string"), T.STRING)
    in t end
 
  (* here you need to add all primitive library functions into the base_env *)
  val base_env = let val t = S.empty
      val t = S.enter(t, S.symbol("print"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "print",
        formals=[T.STRING],
        result=T.UNIT}))
      val t = S.enter(t, S.symbol("flush"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "flush",
        formals=[],
        result=T.UNIT}))
      val t = S.enter(t, S.symbol("getchar"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "getch",
        formals=[],
        result=T.STRING}))
      val t = S.enter(t, S.symbol("ord"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "ord",
        formals=[T.STRING],
        result=T.INT}))
      val t = S.enter(t, S.symbol("chr"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "chr",
        formals=[T.INT],
        result=T.STRING}))
      val t = S.enter(t, S.symbol("size"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "size",
        formals=[T.STRING],
        result=T.INT}))
      val t = S.enter(t, S.symbol("substring"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "substring",
        formals=[T.STRING, T.INT, T.INT],
        result=T.STRING}))
      val t = S.enter(t, S.symbol("concat"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "concat",
        formals=[T.STRING, T.STRING],
        result=T.STRING}))
      val t = S.enter(t, S.symbol("not"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "not",
        formals=[T.INT],
        result=T.INT}))
      val t = S.enter(t, S.symbol("exit"), FUNentry({
        level=Translate.outermost,
        label=Temp.namedlabel "exit",
        formals=[T.INT],
        result=T.UNIT}))
    in t end

end
  
