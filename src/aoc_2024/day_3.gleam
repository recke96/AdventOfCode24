import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/yielder

pub fn parse(input: String) -> List(Instruction) {
  instruction_regex()
  |> regexp.scan(input)
  |> list.filter_map(to_instruction)
}

pub fn pt_1(input: List(Instruction)) {
  let s =
    yielder.from_list(input)
    |> yielder.filter(fn(i) {
      case i {
        Mul(_, _) -> True
        _ -> False
      }
    })
    |> yielder.fold(Enabled(0), apply_instruction)

  s.sum
}

pub fn pt_2(input: List(Instruction)) {
  let s = list.fold(input, Enabled(0), apply_instruction)
  s.sum
}

fn instruction_regex() -> regexp.Regexp {
  let assert Ok(regexp) =
    regexp.compile(
      "(mul)\\((\\d{1,3}),(\\d{1,3})\\)|(do)\\(\\)|(don't)\\(\\)",
      regexp.Options(False, True),
    )
  regexp
}

pub type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

fn to_instruction(match: regexp.Match) -> Result(Instruction, Nil) {
  let non_empty_matches =
    match.submatches
    |> list.filter_map(option.to_result(_, Nil))

  case non_empty_matches {
    ["mul", a, b] -> new_mul(a, b)
    ["do"] -> Ok(Do)
    ["don't"] -> Ok(Dont)
    _ -> Error(Nil)
  }
}

type State {
  Enabled(sum: Int)
  Disabled(sum: Int)
}

fn apply_instruction(state: State, instruction: Instruction) -> State {
  case state, instruction {
    Enabled(acc), Mul(x, y) -> Enabled(acc + { x * y })
    Enabled(acc), Dont -> Disabled(acc)
    Disabled(acc), Do -> Enabled(acc)
    _, _ -> state
  }
}

fn new_mul(a: String, b: String) -> Result(Instruction, Nil) {
  use x <- result.try(int.parse(a))
  use y <- result.try(int.parse(b))

  Ok(Mul(x, y))
}
