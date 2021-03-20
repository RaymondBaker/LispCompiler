# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
#
import sequtils
import strutils
import strformat
import deques
import os
import sets
import typetraits

type
  TokenType = enum
    IdentifierToken, NumberToken, EOFToken, OpenParen, CloseParen, Unknown
  TokenObject = object
    case kind: TokenType
    of IdentifierToken:
      name: string
    of NumberToken:
      value: float
    of OpenParen:
      discard
    of CloseParen:
      discard
    of Unknown:
      discard
    of EOFToken:
      discard

proc createMultiCharTok(tok_type: TokenType, txt: string): TokenObject=
  case tok_type:
  of IdentifierToken:
    TokenObject(kind: IdentifierToken, name: txt)
  of NumberToken:
    TokenObject(kind: NumberToken, value: txt.parseFloat)
  else:
    echo "Non multichar tok passed to createMultiCharTok"
    echo tok_type
    TokenObject(kind: Unknown)


proc tokenizeString(txt: string): seq[TokenObject]=
  result = @[]
  var current_text = ""
  var current_type = Unknown

  for char in txt:
    case char:
    of '(':
      if current_type != Unknown:
        result.add(createMultiCharTok(current_type, current_text))
      result.add(TokenObject(kind: OpenParen))
      current_type = Unknown
      current_text = ""
    of ')':
      if current_type != Unknown:
        result.add(createMultiCharTok(current_type, current_text))
      result.add(TokenObject(kind: CloseParen))
      current_type = Unknown
      current_text = ""
    of WhiteSpace:
      if current_type != Unknown:
        result.add(createMultiCharTok(current_type, current_text))
      current_type = Unknown
      current_text = ""
    of Digits:
      if current_type == Unknown:
        current_type = NumberToken
      current_text &= char
    of IdentStartChars, '+', '-', '/', '*':
      if current_type == Unknown:
        current_type = IdentifierToken
      current_text &= char
    else:
      echo "Bad Char: "
      echo "\t-> " & $char
      return



type
  ArgumentType = enum
    SexpType, IdentifierType, NumberType
  ArgumentObject = object
    case kind: ArgumentType
    of SexpType:
      expr: Sexp
    of IdentifierType:
      name: string
    of NumberType:
      value: float

  Sexp = ref object
    identifier: string
    arguments: seq[ArgumentObject]



# int returned is amount of tokens eatten
proc createSexp(token_arr: openArray[TokenObject], cur_loc: int = 0): (Sexp, int)=

  var new_sexp = Sexp(identifier: "", arguments: @[])

  if token_arr[0].kind != OpenParen:
    echo "ERROR:"
    echo "\tSexp didn't start with ("
    raise newException(IOError, "This is IO speaking, Er Yes you can!")

  if token_arr[1].kind != IdentifierToken:
    echo "ERROR:"
    echo "\tSexp didn't have identifier"
    raise newException(IOError, "This is IO speaking, Er Yes you can!")

  new_sexp.identifier = token_arr[cur_loc+1].name

  var i = cur_loc + 2
  while i <= token_arr.high():
    let tok = token_arr[i]

    case tok.kind:
    of OpenParen:
      let (child_sexp, new_i) = createSexp(token_arr, i)
      new_sexp.arguments &= ArgumentObject(kind: SexpType, expr: child_sexp)
      i = new_i
    of IdentifierToken:
      new_sexp.arguments &= ArgumentObject(kind: IdentifierType, name: tok.name)
    of NumberToken:
      new_sexp.arguments &= ArgumentObject(kind: NumberType, value: tok.value)
    of CloseParen:
      return (new_sexp, i)
    else:
      echo "ERROR"
      return (new_sexp, i)
    i += 1

type
  Stack[T] = object
    vals: seq[T]
    top_idx: int

proc newStack[T](init_size: int = 10): Stack[T] =
  result.vals = newSeq[T](init_size)
  result.top_idx = -1

proc push[T](stack: var Stack[T], val: T) =
  stack.top_idx += 1
  if stack.top_idx > stack.vals.high:
    stack.vals.add(val)
  else:
    stack.vals[stack.top_idx] = val

proc top[T](stack: Stack[T]): T =
  if stack.top_idx < 0:
    return nil
  result = stack.vals[stack.top_idx]

proc pop[T](stack: var Stack[T]): T =
  if stack.top_idx < 0:
    return nil
  result = stack.vals[stack.top_idx]
  stack.top_idx -= 1

proc len[T](stack: Stack[T]): int =
  return stack.top_idx + 1

type
  SexpResultType = enum
    Integer, String, Procedure, Register, None
  SexpResult = object
    case kind: SexpResultType
    of Register:
      reg: string
    of Integer:
      val: int
    of String:
      text: string
    of Procedure:
      #TODO Implement
      discard
    of None:
      discard


#TODO make this a param or an obj
let all_regs = toHashSet(["r8", "r9", "r10", "r11"])
var used_regs = initHashset[string]()
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

proc genNasm(sexp: Sexp, result_queue: var Deque[SexpResult]): seq[string] =
  # Get argument results
  # List of strings
  var sexp_arguments = newSeq[string]()
  for arg in sexp.arguments:
    case arg.kind:
      of SexpType:
        if result_queue.peekFirst.kind == Register:
          sexp_arguments.add($result_queue.popfirst().reg)
          #TODO add these all to a list and free them at the end of this funcition
      of NumberType:
        sexp_arguments.add($arg.value.int)
      else:
        discard


  var nasm = newSeq[string]()

  case sexp.identifier:
    of "print":
      nasm = @[
        "; Print ",
        "push rdi",
        "push rsi",
        "mov rdi, int_print_fmt"
      ]
      for arg in sexp_arguments:
        nasm &= [
          &"mov rsi, {arg}",
           "xor eax, eax",
           "call printf wrt ..plt",
        ]
        #TODO make this call not use globals
        freeGpReg(arg)
      nasm.add("pop rsi")
      nasm.add("pop rdi")
      result_queue.addLast(SexpResult(kind:None))
    of "+":
      let result_reg = claimGpReg()
      let operand_reg = getTempGpReg()
      nasm = @[
        "; add ",
        &"mov {result_reg}, {sexp_arguments[0]}"
      ]
      for arg in sexp_arguments[1..sexp_arguments.high]:
        nasm &= [
          &"mov {operand_reg}, {arg}",
          &"add {result_reg}, {operand_reg}",
        ]
      result_queue.addLast(SexpResult(kind:Register, reg:result_reg))
    else:
      return @[";Didn't compile"]
  return nasm


proc walkAst(root_node: Sexp): string =
  let setup_code = """
    global main
    extern puts
    extern printf

default rel
    section .data
int_print_fmt: db "%d", 10, 0 ; 10 is newline

    section .text
main:
"""
  var nasm = newSeq[string]()
  var sexp_stack = newStack[Sexp](12)
  var result_queue = initDeque[SexpResult](16)

  var procedure_ids = ["print"]

  sexp_stack.push(root_node)

  var descend = true
  while descend:
    let sexp = sexp_stack.top()
    descend = false
    for arg in sexp.arguments:
      case arg.kind:
        of SexpType:
          sexp_stack.push(arg.expr)
          descend = true
        else:
          discard

  while sexp_stack.len() > 0:
    let sexp = sexp_stack.pop()
    nasm &= genNasm(sexp, result_queue)


  return setup_code & nasm.join("\n") & "\nret"



when isMainModule:
  echo("Welcome to my shitty scheme impl")
  let code = "(print (+ 1 3 (+ 3 5 (+ 234 3))))"
  let tokens = tokenizeString(code)
  let (ast, _) = createSexp(tokens)

  let nasm = walkAst(ast)

  echo "---------------NASM OUTPUT------------- \n\n"
  echo nasm
  writeFile("asm/test.asm", nasm)
  echo "---------------EXECUTING-------------"
  echo code
  echo "---------------OUTPUT-------------"
  discard execShellCmd("./asm/build_nasm.sh asm/test.asm")
