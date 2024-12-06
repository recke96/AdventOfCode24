import gleam/dict.{type Dict}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleam/yielder

pub fn parse(input: String) -> WordSearch {
  parse_loop(input, Position(0, 0), dict.new())
}

fn parse_loop(
  input: String,
  position: Position,
  search: WordSearch,
) -> WordSearch {
  let Position(x, y) = position
  use #(grapheme, rest) <- shortcircuit(string.pop_grapheme(input), search)

  case grapheme {
    "\n" -> parse_loop(rest, Position(0, y + 1), search)
    grapheme ->
      parse_loop(
        rest,
        Position(x + 1, y),
        search |> dict.insert(position, grapheme),
      )
  }
}

pub fn pt_1(input: WordSearch) -> Int {
  dict.keys(input)
  |> yielder.from_list()
  |> yielder.filter(fn(position) {
    case input |> dict.get(position) {
      Ok("X") | Ok("M") | Ok("A") | Ok("S") -> True
      _ -> False
    }
  })
  |> yielder.flat_map(fn(position) {
    use <- yielder.yield(match_xmas_at_dir(input, position, Up))
    use <- yielder.yield(match_xmas_at_dir(input, position, UpRight))
    use <- yielder.yield(match_xmas_at_dir(input, position, Right))
    use <- yielder.yield(match_xmas_at_dir(input, position, DownRight))
    use <- yielder.yield(match_xmas_at_dir(input, position, Down))
    use <- yielder.yield(match_xmas_at_dir(input, position, DownLeft))
    use <- yielder.yield(match_xmas_at_dir(input, position, Left))
    use <- yielder.yield(match_xmas_at_dir(input, position, UpLeft))
    yielder.empty()
  })
  |> yielder.fold(set.new(), set.union)
  |> set.size()
}

pub fn pt_2(input: WordSearch) {
  dict.keys(input)
  |> yielder.from_list()
  |> yielder.filter(is_x_mas_at(input, _))
  |> yielder.length()
}

pub type Position {
  Position(x: Int, y: Int)
}

pub type WordSearch =
  Dict(Position, String)

fn shortcircuit(result: Result(a, b), short: c, circuit: fn(a) -> c) -> c {
  case result {
    Ok(a) -> circuit(a)
    Error(_) -> short
  }
}

type Direction {
  Up
  UpRight
  Right
  DownRight
  Down
  DownLeft
  Left
  UpLeft
}

fn next_pos(current: Position, direction: Direction) -> Position {
  let Position(x, y) = current
  case direction {
    Up -> Position(x, y - 1)
    UpRight -> Position(x + 1, y - 1)
    Right -> Position(x + 1, y)
    DownRight -> Position(x + 1, y + 1)
    Down -> Position(x, y + 1)
    DownLeft -> Position(x - 1, y + 1)
    Left -> Position(x - 1, y)
    UpLeft -> Position(x - 1, y - 1)
  }
}

type Match {
  Match(at: Position, direction: Direction)
}

fn string_at(
  search: WordSearch,
  position: Position,
  count: Int,
  direction: Direction,
) -> Result(String, Nil) {
  yielder.unfold(#(0, position), fn(state) {
    let #(step, current_pos) = state
    case step < count {
      True ->
        yielder.Next(current_pos, #(step + 1, next_pos(current_pos, direction)))
      False -> yielder.Done
    }
  })
  |> yielder.try_fold("", fn(str, pos) {
    use grapheme <- result.try(search |> dict.get(pos))
    Ok(str <> grapheme)
  })
}

fn match_xmas_at_dir(
  search: WordSearch,
  at: Position,
  direction: Direction,
) -> Set(Match) {
  let empty = set.new()
  use str <- shortcircuit(string_at(search, at, 4, direction), empty)
  case str {
    "XMAS" -> empty |> set.insert(Match(at, direction))
    _ -> empty
  }
}

fn is_x_mas_at(search: WordSearch, at: Position) -> Bool {
  use str_1 <- shortcircuit(string_at(search, at, 3, DownRight), False)

  let other_start = Position(at.x, at.y + 2)
  use str_2 <- shortcircuit(string_at(search, other_start, 3, UpRight), False)

  case str_1, str_2 {
    "MAS", "MAS" | "SAM", "MAS" | "SAM", "SAM" | "MAS", "SAM" -> True
    _, _ -> False
  }
}
