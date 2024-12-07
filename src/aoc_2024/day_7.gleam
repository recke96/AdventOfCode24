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

  list.filter(input, fn(eq) { find_operators(eq, [Add, Mul]) |> result.is_ok() })
  |> list.fold(0, fn(sum, eq) { sum + eq.test_value })
}

pub fn pt_2(input: List(Equation)) {
  list.filter(input, fn(eq) {
    find_operators(eq, [Add, Mul, Concat]) |> result.is_ok()
  })
  |> list.fold(0, fn(sum, eq) { sum + eq.test_value })
}

type Operator {
  Add
  Mul
  Concat
}

fn apply_op(operator: Operator, a: Int, b: Int) -> Int {
  case operator {
    Add -> a + b
    Mul -> a * b
    Concat -> {
      let assert Ok(digits_a) = int.digits(a, 10)
      let assert Ok(digits_b) = int.digits(b, 10)

      let assert Ok(concat) =
        list.append(digits_a, digits_b) |> int.undigits(10)
      concat
    }
  }
}

fn find_operators(
  in: Equation,
  available_ops: List(Operator),
) -> Result(List(Operator), Nil) {
  case in.numbers {
    [] -> Error(Nil)
    [single] ->
      case single == in.test_value {
        True -> Ok([])
        False -> Error(Nil)
      }
    [first, ..remaining] -> {
      map_to_success(available_ops, find_operators_loop(
        in.test_value,
        first,
        _,
        remaining,
        [],
        available_ops,
      ))
    }
  }
}

fn find_operators_loop(
  target: Int,
  current_number: Int,
  current_operator: Operator,
  remaining: List(Int),
  operators: List(Operator),
  available_ops: List(Operator),
) -> Result(List(Operator), Nil) {
  case remaining {
    [] if current_number == target -> Ok(list.reverse(operators))
    [] -> Error(Nil)
    [next, ..rest] -> {
      let acc = apply_op(current_operator, current_number, next)
      map_to_success(available_ops, find_operators_loop(
        target,
        acc,
        _,
        rest,
        [current_operator, ..operators],
        available_ops,
      ))
    }
  }
}

fn map_to_success(list: List(a), fun: fn(a) -> Result(b, c)) -> Result(b, Nil) {
  list.fold_until(list, Error(Nil), fn(_, e) {
    case fun(e) {
      Ok(r) -> list.Stop(Ok(r))
      Error(_) -> list.Continue(Error(Nil))
    }
  })
}
