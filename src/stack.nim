type
  Stack*[T] = object
    vals: seq[T]
    top_idx: int

proc newStack*[T](init_size: int = 10): Stack[T] =
  result.vals = newSeq[T](init_size)
  result.top_idx = -1

proc push*[T](stack: var Stack[T], val: T) =
  stack.top_idx += 1
  if stack.top_idx > stack.vals.high:
    stack.vals.add(val)
  else:
    stack.vals[stack.top_idx] = val

proc top*[T](stack: Stack[T]): T =
  result = stack.vals[stack.top_idx]

proc pop*[T](stack: var Stack[T]): T =
  result = stack.vals[stack.top_idx]
  stack.top_idx -= 1

proc len*[T](stack: Stack[T]): int =
  return stack.top_idx + 1
