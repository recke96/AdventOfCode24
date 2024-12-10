import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub fn parse(input: String) -> #(TopoMap, List(Position)) {
  parse_loop(input |> string.to_graphemes(), Position(0, 0), dict.new(), [])
}

pub fn pt_1(input: #(TopoMap, List(Position))) {
  let #(map, heads) = input

  list.map(heads, trail_score(_, map))
  |> list.fold(0, int.add)
}

pub fn pt_2(input: #(TopoMap, List(Position))) {
  let #(map, heads) = input

  list.map(heads, trail_rating(_, map))
  |> list.fold(0, int.add)
}

pub type Position {
  Position(x: Int, y: Int)
}

pub type TopoMap =
  Dict(Position, Int)

fn parse_loop(
  graphemes: List(String),
  current: Position,
  map: TopoMap,
  trail_heads: List(Position),
) -> #(TopoMap, List(Position)) {
  let Position(x, y) = current
  case graphemes {
    [] -> #(map, trail_heads)
    ["\n", ..rest] -> parse_loop(rest, Position(0, y + 1), map, trail_heads)
    [height_str, ..rest] -> {
      let assert Ok(height) = int.parse(height_str)
      let new_trail_heads = case height {
        0 -> [current, ..trail_heads]
        _ -> trail_heads
      }

      parse_loop(
        rest,
        Position(x + 1, y),
        dict.insert(map, current, height),
        new_trail_heads,
      )
    }
  }
}

fn trail_score(head: Position, map: TopoMap) -> Int {
  trail_dfs(head, 0, fn(top) { set.new() |> set.insert(top) }, set.union, map)
  |> result.map(set.size)
  |> result.unwrap(-1)
}

fn trail_rating(head: Position, map: TopoMap) -> Int {
  trail_dfs(head, 0, fn(_) { 1 }, int.add, map) |> result.unwrap(-1)
}

fn trail_dfs(
  current: Position,
  height: Int,
  on_top: fn(Position) -> a,
  combinator: fn(a, a) -> a,
  map: TopoMap,
) -> Result(a, Nil) {
  case height {
    9 -> Ok(on_top(current))
    _ -> {
      let Position(x, y) = current
      let nexts = [
        Position(x, y - 1),
        Position(x + 1, y),
        Position(x, y + 1),
        Position(x - 1, y),
      ]

      list.filter_map(nexts, fn(next) {
        dict.get(map, next)
        |> result.map(fn(height) { #(next, height) })
      })
      |> list.filter(fn(next) { next.1 == height + 1 })
      |> list.filter_map(fn(next) {
        trail_dfs(next.0, next.1, on_top, combinator, map)
      })
      |> list.reduce(combinator)
    }
  }
}
