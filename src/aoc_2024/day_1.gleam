import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  string.split(input, on: "\n")
  |> list.map(string.split(_, on: " "))
  |> list.map(list.filter(_, not_empty))
  |> list.filter_map(as_pair)
  |> list.filter_map(parse_pair)
  |> list.unzip()
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let #(l1, l2) = input

  let sorted_1 = list.sort(l1, by: int.compare)
  let sorted_2 = list.sort(l2, by: int.compare)

  list.map2(sorted_1, sorted_2, int.subtract)
  |> list.map(int.absolute_value)
  |> list.fold(0, int.add)
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let #(l1, l2) = input

  let freqs = list.fold(l2, dict.new(), accumulate_frequencies)

  list.map(l1, similarity_score(_, freqs))
  |> list.fold(0, int.add)
}

fn not_empty(value: String) -> Bool {
  !string.is_empty(value)
}

fn accumulate_frequencies(
  frequencies: dict.Dict(Int, Int),
  value: Int,
) -> dict.Dict(Int, Int) {
  dict.upsert(frequencies, value, increment)
}

fn increment(x: option.Option(Int)) -> Int {
  option.map(x, int.add(_, 1)) |> option.unwrap(1)
}

fn as_pair(elems: List(elem)) -> Result(#(elem, elem), Nil) {
  case elems {
    [a, b] -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

fn parse_pair(p: #(String, String)) -> Result(#(Int, Int), Nil) {
  let #(a_string, b_string) = p

  use a <- result.try(int.parse(a_string))
  use b <- result.try(int.parse(b_string))

  Ok(#(a, b))
}

fn similarity_score(value: Int, frequencies: dict.Dict(Int, Int)) -> Int {
  dict.get(frequencies, value)
  |> result.map(int.multiply(_, value))
  |> result.unwrap(0)
}
