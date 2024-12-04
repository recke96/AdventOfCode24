import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder

pub fn pt_1(input: String) -> Int {
  let rows = rows(input)
  let cols = cols(rows)
  let diags = diags(rows)

  list.flatten([rows, cols, diags])
  |> list.fold(0, fn(xmas, row) { xmas + count_xmas(row) })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

fn index_dict(input: List(elem)) -> Dict(Int, elem) {
  list.index_map(input, pair.new)
  |> list.map(pair.swap)
  |> dict.from_list()
}

fn rows(input: String) -> List(String) {
  string.split(input, on: "\n")
}

fn cols(input: List(String)) -> List(String) {
  list.map(input, string.to_graphemes)
  |> list.map(index_dict)
  |> list.fold(dict.new(), fn(cols, row) {
    dict.combine(cols, row, string.append)
  })
  |> dict.values()
}

fn diags(input: List(String)) -> List(String) {
  list.map(input, string.to_graphemes)
  |> list.index_fold(dict.new(), fn(diags, graphemes, row_idx) {
    list.index_map(graphemes, fn(grapheme, col_idx) {
      case col_idx == 0 {
        True -> [#(row_idx, grapheme)]
        False -> [
          #(row_idx + col_idx, grapheme),
          #(row_idx - col_idx, grapheme),
        ]
      }
    })
    |> list.flatten()
    |> dict.from_list()
    |> dict.combine(diags, string.append)
  })
  |> dict.values()
}

fn shift_row(row: Dict(Int, String), by: Int) -> Dict(Int, String) {
  dict.to_list(row)
  |> list.map(pair.map_first(_, int.add(_, by)))
  |> dict.from_list()
}

fn count_xmas(input: String) -> Int {
  let count = count_xmas_loop(input, 0, 0)
  io.debug("found " <> string.inspect(count) <> " in " <> input)
  count
}

fn count_xmas_loop(input: String, idx: Int, count: Int) -> Int {
  case string.slice(input, idx, 4) {
    "" -> count
    "XMAS" | "SAMX" -> count_xmas_loop(input, idx + 1, count + 1)
    _ -> count_xmas_loop(input, idx + 1, count)
  }
}
