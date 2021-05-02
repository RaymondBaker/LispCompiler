




type
  TempVarType* = enum
    Register, Stack
  TempVar* = object
    type: TempVarType
    loc: string


#used_regs,all_regs : HashSet[string]
proc claimGpReg(): string =
  ## had to be mutable because only pop was able to get an elem
  var set_diff = (all_regs - used_regs)
  result = set_diff.pop
  used_regs.incl(result)

proc freeGpReg(register: string) =
  used_regs.excl(register)

proc getTempGpReg(): string =
  ## had to be mutable because only pop was able to get an elem
  var set_diff = (all_regs - used_regs)
  result = set_diff.pop

rdi, rsi, rdx, rcx, r8, and r9

type VarMan* = ref object
  all_regs, arg_regs, perm_regs, scratch_regs, used_regs: HashSet[String]
  stack_pos: int

proc get_temp_var*(var_man: VarMan): tuple[nasm: string[], var: TempVar] =
  var nasm = seq[String]

proc preserve_scratch(var_man: VarMan): tuple[before: string[], after: string[]] =


proc new_VarMan*(): VarMan =
  var var_man: VarMan
  var_man.all_regs = toHashSet(["rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15"])
  var_man.arg_regs = toHashSet(["rdi", "rsi", "rdx", "rcx", "r8", "r9"])
  var_man.scratch_regs = toHashSet(["r8", "r9", "r10", "r11"])
  var_man.perm_regs = toHashSet(["r12", "r13", "r14", "r15"])
  var_man.used_regs = initHashset[string]()
  return var_man




