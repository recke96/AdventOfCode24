import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder

pub fn pt_1(input: String) {
  string.split(input, on: "\n")
  |> yielder.from_list()
  |> all_dirs()
  |> yielder.flatten()
  |> yielder.fold(0, fn(count, str) { count + count_xmas(str) })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

fn all_dirs(
  input: yielder.Yielder(String),
) -> yielder.Yielder(yielder.Yielder(String)) {
  use <- yielder.yield(input)
  use <- yielder.yield(input)
  let cols =
    yielder.fold(input, dict.new(), fn(cols, row) {
      dict.combine(cols, index_chars(row), string.append)
    })

  use <- yielder.yield(dict.values(cols) |> yielder.from_list())
  yielder.empty()
}

fn index_chars(input: String) -> dict.Dict(Int, String) {
  string.to_graphemes(input)
  |> list.index_map(fn(c, i) { #(i, c) })
  |> dict.from_list()
}

fn count_xmas(input: String) -> Int {
  string.to_graphemes(input)
  |> list.window(by: 4)
  |> list.count(fn(window) {
    case string.concat(window) {
      "XMAS" | "SAMX" -> True
      _ -> False
    }
  })
}
