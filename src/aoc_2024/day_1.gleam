import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  string.split(input, on: "\n")
  |> list.map(string.split(_, on: " "))
  |> list.map(list.filter(_, not_empty))
  |> list.filter_map(take_2)
  |> list.filter_map(parse_pair)
  |> list.unzip()
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let #(l1, l2) = input

  list.zip(list.sort(l1, by: int.compare), list.sort(l2, by: int.compare))
  |> list.fold(0, fn(dist, p) {
    dist + int.absolute_value(pair.first(p) - pair.second(p))
  })
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let freqs =
    pair.second(input)
    |> list.group(function.identity)
    |> dict.map_values(fn(_, v) { list.length(v) })

  pair.first(input)
  |> list.map(fn(v) {
    dict.get(freqs, v)
    |> result.unwrap(0)
    |> int.multiply(v)
  })
  |> list.fold(0, int.add)
}

fn not_empty(value: String) -> Bool {
  !string.is_empty(value)
}

fn take_2(ints: List(String)) -> Result(#(String, String), Nil) {
  case ints {
    [a, b] -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

fn parse_pair(p: #(String, String)) -> Result(#(Int, Int), Nil) {
  use a <- result.try(int.parse(pair.first(p)))
  use b <- result.try(int.parse(pair.second(p)))

  Ok(#(a, b))
}
