import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn pt_1(input: String) {
  let #(map, heads) =
    parse_loop(input |> string.to_graphemes(), Position(0, 0), dict.new(), [])

  list.map(heads, trail_score(_, map))
  |> list.fold(0, int.add)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
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
  trail_score_dfs(head, 0, set.new(), map) |> set.size()
}

fn trail_score_dfs(
  current: Position,
  height: Int,
  tops: Set(Position),
  map: TopoMap,
) -> Set(Position) {
  case height {
    9 -> set.insert(tops, current)
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
      |> list.map(fn(next) { trail_score_dfs(next.0, next.1, tops, map) })
      |> list.fold(tops, set.union)
    }
  }
}
