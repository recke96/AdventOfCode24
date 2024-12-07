import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Equation {
  Equation(test_value: Int, numbers: List(Int))
}

pub fn parse(input: String) -> List(Equation) {
  let assert Ok(equations) =
    string.split(input, "\n")
    |> list.try_map(parse_eq)

  equations
}

fn parse_eq(line: String) -> Result(Equation, Nil) {
  use #(test_value_str, numbers_str) <- result.try(string.split_once(line, ":"))

  use test_value <- result.try(int.parse(test_value_str))
  use numbers <- result.try(
    string.split(numbers_str, " ")
    |> list.filter(fn(str) { !string.is_empty(str) })
    |> list.try_map(int.parse),
  )

  Ok(Equation(test_value, numbers))
}

pub fn pt_1(input: List(Equation)) {
  // let err_case = Equation(292, [11, 6, 16, 20])
  // find_operators(err_case) |> string.inspect() |> io.println()

  list.filter(input, fn(eq) { find_operators(eq) |> result.is_ok() })
  |> list.fold(0, fn(sum, eq) { sum + eq.test_value })
}

pub fn pt_2(input: List(Equation)) {
  todo as "part 2 not implemented"
}

type Operator {
  Add
  Mul
}

fn apply_op(operator: Operator, a: Int, b: Int) -> Int {
  case operator {
    Add -> a + b
    Mul -> a * b
  }
}

fn find_operators(in: Equation) -> Result(List(Operator), Nil) {
  case in.numbers {
    [] -> Error(Nil)
    [single] ->
      case single == in.test_value {
        True -> Ok([])
        False -> Error(Nil)
      }
    [first, ..remaining] -> {
      use <- result.lazy_or(
        find_operators_loop(in.test_value, first, Add, remaining, []),
      )

      find_operators_loop(in.test_value, first, Mul, remaining, [])
    }
  }
}

fn find_operators_loop(
  target: Int,
  current_number: Int,
  current_operator: Operator,
  remaining: List(Int),
  operators: List(Operator),
) -> Result(List(Operator), Nil) {
  case remaining {
    [] if current_number == target -> Ok(list.reverse(operators))
    [] -> Error(Nil)
    [next, ..rest] -> {
      let acc = apply_op(current_operator, current_number, next)
      use <- result.lazy_or(
        find_operators_loop(target, acc, Add, rest, [
          current_operator,
          ..operators
        ]),
      )

      find_operators_loop(target, acc, Mul, rest, [
        current_operator,
        ..operators
      ])
    }
  }
}
