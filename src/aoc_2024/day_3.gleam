import gleam/int
import gleam/option
import gleam/regexp
import gleam/result
import gleam/yielder

pub fn pt_1(input: String) {
  mul_regex()
  |> regexp.scan(input)
  |> yielder.from_list()
  |> yielder.filter_map(to_instruction)
  |> yielder.map(apply_instruction)
  |> yielder.fold(0, int.add)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

fn mul_regex() -> regexp.Regexp {
  let assert Ok(regexp) =
    regexp.compile(
      "mul\\((\\d{1,3}),(\\d{1,3})\\)",
      regexp.Options(False, True),
    )
  regexp
}

type Instruction {
  Mul(Int, Int)
}

fn to_instruction(match: regexp.Match) -> Result(Instruction, Nil) {
  case match.submatches {
    [a, b] -> new_mul(a, b)
    _ -> Error(Nil)
  }
}

fn apply_instruction(instruction: Instruction) -> Int {
  case instruction {
    Mul(x, y) -> x * y
  }
}

fn new_mul(
  a: option.Option(String),
  b: option.Option(String),
) -> Result(Instruction, Nil) {
  use x <- result.try(option.to_result(a, Nil) |> result.try(int.parse))
  use y <- result.try(option.to_result(b, Nil) |> result.try(int.parse))

  Ok(Mul(x, y))
}
