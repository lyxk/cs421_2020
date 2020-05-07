(* register.sml *)

signature REGISTER =
sig 
  include REGISTER_STD

  val EIP : Temp.temp
  val EBX : Temp.temp
  val ECX : Temp.temp
  val EDX : Temp.temp
  val ERROR : Temp.temp

 (* we maintain a separate list here of true callersaves, so that
  * CodeGen will not emit code to "save" the pseudo-registers, since
  * they already live on the stack.
  *)
  val truecallersaves : register list (* CodeGen use only! *)

  (* number of pseudo-registers: *)
  val NPSEUDOREGS : int  (* CodeGen use only! *)

  val initial : register Temp.Table.table
  val registers : register list

end (* signature REGISTER *)


structure Register : REGISTER = 
struct
  
  type register = string

  val RV = Temp.newtemp()
  val FP = Temp.newtemp()
  val SP = Temp.newtemp()
  val EIP = Temp.newtemp()
  val EBX = Temp.newtemp()
  val ECX = Temp.newtemp()
  val EDX = Temp.newtemp()
  val ESI = Temp.newtemp()
  val EDI = Temp.newtemp()
  val ERROR = Temp.newtemp()

  (* of course, none of the following should be empty list *)

  val NPSEUDOREGS = 40 
  val localsBaseOffset : int = ~4 * (NPSEUDOREGS + 1)
  val paramBaseOffset : int = 8 (* before return address *)

  val specialregs : (Temp.temp * register) list = [
    (RV, "%eax"), 
    (FP, "%ebp"), 
    (SP, "%esp"), 
    (EIP, "%eip"), 
    (EBX, "%ebx"), 
    (ECX, "%ecx"), 
    (EDX, "%edx")
  ]
  val argregs : (Temp.temp * register) list = nil
  val calleesaves : register list = ["%esi", "%edi", "%ebx"] 
  val truecallersaves : register list = ["%eax", "%ecx", "%edx"]
  val callersaves : register list = List.tabulate (NPSEUDOREGS, fn x => "f" ^ Int.toString x)
  val registers : register list = calleesaves @ callersaves

  val initial : register Temp.Table.table =
    let
      fun tabulate (nil) = Temp.Table.empty
        | tabulate ( (tmp, reg)::rest ) = Temp.Table.enter (tabulate rest, tmp, reg)
    in
      tabulate specialregs
    end

  (* ... other stuff ... *)


end (* structure Register *)

