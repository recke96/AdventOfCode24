import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  string.split(input, on: "\n")
  |> yielder.from_list
  |> yielder.map(string.split(_, on: " "))
  |> yielder.map(list.filter(_, not_empty))
  |> yielder.filter_map(as_pair)
  |> yielder.filter_map(parse_pair)
  |> yielder.to_list()
  |> list.unzip()
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let sorted_1 = list.sort(input.0, by: int.compare) |> yielder.from_list
  let sorted_2 = list.sort(input.1, by: int.compare) |> yielder.from_list

  yielder.map2(sorted_1, sorted_2, int.subtract)
  |> yielder.map(int.absolute_value)
  |> yielder.fold(0, int.add)
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let freqs = list.fold(input.1, dict.new(), accumulate_frequencies)

  yielder.from_list(input.0)
  |> yielder.map(similarity_score(_, freqs))
  |> yielder.fold(0, int.add)
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
  use a <- result.try(int.parse(p.0))
  use b <- result.try(int.parse(p.1))

  Ok(#(a, b))
}

fn similarity_score(value: Int, frequencies: dict.Dict(Int, Int)) -> Int {
  dict.get(frequencies, value)
  |> result.map(int.multiply(_, value))
  |> result.unwrap(0)
}
