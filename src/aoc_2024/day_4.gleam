import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/string

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
  let indexed_rows =
    list.map(input, string.to_graphemes)
    |> list.map(index_dict)

  let right_shifted =
    list.index_fold(indexed_rows, dict.new(), fn(diags, indexed_row, row_idx) {
      shift_keys(indexed_row, row_idx)
      |> dict.combine(diags, string.append)
    })

  let left_shifted =
    list.index_fold(indexed_rows, dict.new(), fn(diags, indexed_row, row_idx) {
      shift_keys(indexed_row, -row_idx)
      |> dict.combine(diags, string.append)
    })

  list.append(dict.values(right_shifted), dict.values(left_shifted))
}

fn shift_keys(row: Dict(Int, elems), by: Int) -> Dict(Int, elems) {
  dict.to_list(row)
  |> list.map(pair.map_first(_, int.add(_, by)))
  |> dict.from_list()
}

fn count_xmas(input: String) -> Int {
  count_xmas_loop(input, 0, 0)
}

fn count_xmas_loop(input: String, idx: Int, count: Int) -> Int {
  case string.slice(input, idx, 4) {
    "" -> count
    "XMAS" | "SAMX" -> count_xmas_loop(input, idx + 1, count + 1)
    _ -> count_xmas_loop(input, idx + 1, count)
  }
}
