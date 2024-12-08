import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/yielder.{type Yielder}

pub type Position {
  Position(x: Int, y: Int)
}

pub type Antenna {
  Antenna(pos: Position, freq: String)
}

pub fn parse(input: String) -> #(Int, Int, List(Antenna)) {
  parse_loop(input |> string.to_graphemes(), Position(0, 0), [], 0, 0)
}

fn parse_loop(
  graphemes: List(String),
  current: Position,
  antennas: List(Antenna),
  width: Int,
  height: Int,
) -> #(Int, Int, List(Antenna)) {
  let Position(x, y) = current
  case graphemes {
    [] -> #(width + 1, height + 1, antennas)
    ["\n", ..rest] ->
      parse_loop(
        rest,
        Position(0, y + 1),
        antennas,
        width,
        int.max(height, y + 1),
      )
    [".", ..rest] ->
      parse_loop(
        rest,
        Position(x + 1, y),
        antennas,
        int.max(width, x + 1),
        height,
      )
    [freq, ..rest] ->
      parse_loop(
        rest,
        Position(x + 1, y),
        [Antenna(current, freq), ..antennas],
        int.max(width, x + 1),
        height,
      )
  }
}

pub fn pt_1(input: #(Int, Int, List(Antenna))) {
  let #(width, height, antennas) = input

  list.group(antennas, fn(a) { a.freq })
  |> dict.values()
  |> list.flat_map(anti_nodes)
  |> list.filter(is_on_map(_, width, height))
  |> list.fold(set.new(), set.insert)
  |> set.size()
}

fn is_on_map(pos: Position, width: Int, height: Int) -> Bool {
  let Position(x, y) = pos
  x >= 0 && x < width && y >= 0 && y < height
}

pub fn pt_2(input: #(Int, Int, List(Antenna))) {
  todo as "part 2 not implemented"
}

fn anti_nodes(antennas: List(Antenna)) -> List(Position) {
  list.map(antennas, fn(a) { a.pos })
  |> list.combination_pairs()
  |> yielder.from_list()
  |> yielder.flat_map(fn(positions) {
    let #(a, b) = positions
    let diff = diff(positions)

    use <- yielder.yield(Position(a.x + diff.x, a.y + diff.y))
    use <- yielder.yield(Position(b.x - diff.x, b.y - diff.y))
    yielder.empty()
  })
  |> yielder.to_list()
}

fn diff(posisitons: #(Position, Position)) -> Position {
  let #(Position(ax, ay), Position(bx, by)) = posisitons
  Position(ax - bx, ay - by)
}
