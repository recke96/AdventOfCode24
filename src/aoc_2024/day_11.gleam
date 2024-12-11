import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}

pub type Stone {
  Stone(num: Int)
}

pub fn parse(input: String) -> List(Stone) {
  string.split(input, on: " ")
  |> list.filter_map(int.parse)
  |> list.map(Stone)
}

pub fn pt_1(input: List(Stone)) {
  yielder.iterate(yielder.from_list(input), fn(stones) {
    stones |> yielder.flat_map(apply_rule)
  })
  |> yielder.at(25)
  |> result.unwrap(yielder.empty())
  |> yielder.length()
}

pub fn pt_2(input: List(Stone)) {
  todo as "part 2 not implemented"
}

fn apply_rule(stone: Stone) -> Yielder(Stone) {
  list.fold_until(rules, Error([]), fn(_, rule) {
    case rule(stone) {
      Error(Nil) -> list.Continue(Error([]))
      Ok(stones) -> list.Stop(Ok(stones))
    }
  })
  |> result.unwrap_both()
  |> yielder.from_list()
}

const rules = [zero_rule, even_digits_rule, other_rule]

fn zero_rule(stone: Stone) -> Result(List(Stone), Nil) {
  use <- bool.guard(stone.num != 0, Error(Nil))

  Ok([Stone(1)])
}

fn even_digits_rule(stone: Stone) -> Result(List(Stone), Nil) {
  use digits <- result.try(int.digits(stone.num, 10))
  let num_digits = digits |> list.length()

  use <- bool.guard(num_digits % 2 != 0, Error(Nil))

  let #(left, right) = list.split(digits, num_digits / 2)
  use first <- result.try(int.undigits(left, 10))
  use second <- result.try(int.undigits(right, 10))

  Ok([Stone(first), Stone(second)])
}

fn other_rule(stone: Stone) -> Result(List(Stone), Nil) {
  Ok([Stone(stone.num * 2024)])
}
