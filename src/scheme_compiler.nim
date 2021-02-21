# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
#
import sequtils
import strutils

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

when isMainModule:
  echo("Welcome to my shitty scheme impl")
  let tokens = tokenizeString("(def x (+ 1 3))")
  echo tokens
  let (ast, _) = createSexp(tokens)


  let id = ast.identifier
  let args = ast.arguments
  echo id
  echo args
  let sub_sexp = args[1].expr
  echo sub_sexp.identifier
  echo sub_sexp.arguments
