import gleam/dict.{type Dict}
import gleam/io
import gleam/set.{type Set}

pub fn pt_1(input: String) {
  let assert #(map, Ok(start)) = map_and_start(input)

  let visited = set.new() |> set.insert(start.at)
  walk(start, visited, map) |> set.size()
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

pub type Position {
  Position(x: Int, y: Int)
}

pub type Direction {
  Up
  Right
  Left
  Down
}

fn turn_clockwise(current: Direction) {
  case current {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn next_pos(current: Position, direction: Direction) -> Position {
  let Position(x, y) = current
  case direction {
    Up -> Position(x, y - 1)
    Right -> Position(x + 1, y)
    Down -> Position(x, y + 1)
    Left -> Position(x - 1, y)
  }
}

pub type Guard {
  Guard(at: Position, facing: Direction)
}

pub type MapSymbol {
  Free
  Obstacle
}

pub type Map =
  Dict(Position, MapSymbol)

fn walk(current: Guard, visited: Set(Position), map: Map) -> Set(Position) {
  let next_pos = next_pos(current.at, current.facing)
  case dict.get(map, next_pos) {
    Ok(Free) ->
      walk(Guard(..current, at: next_pos), set.insert(visited, next_pos), map)
    Ok(Obstacle) ->
      walk(
        Guard(..current, facing: turn_clockwise(current.facing)),
        visited,
        map,
      )
    Error(Nil) -> visited
  }
}

fn map_and_start(input: String) -> #(Map, Result(Guard, Nil)) {
  map_and_start_loop(input, dict.new(), Position(0, 0), Error(Nil))
}

fn map_and_start_loop(
  input: String,
  map: Map,
  current_position: Position,
  start_position: Result(Guard, Nil),
) -> #(Map, Result(Guard, Nil)) {
  case input {
    "." <> rest ->
      map_and_start_loop(
        rest,
        dict.insert(map, current_position, Free),
        Position(current_position.x + 1, current_position.y),
        start_position,
      )
    "#" <> rest ->
      map_and_start_loop(
        rest,
        dict.insert(map, current_position, Obstacle),
        Position(current_position.x + 1, current_position.y),
        start_position,
      )
    "^" <> rest ->
      map_and_start_loop(
        rest,
        dict.insert(map, current_position, Free),
        Position(current_position.x + 1, current_position.y),
        Ok(Guard(at: current_position, facing: Up)),
      )
    ">" <> rest ->
      map_and_start_loop(
        rest,
        dict.insert(map, current_position, Free),
        Position(current_position.x + 1, current_position.y),
        Ok(Guard(at: current_position, facing: Right)),
      )
    "v" <> rest ->
      map_and_start_loop(
        rest,
        dict.insert(map, current_position, Free),
        Position(current_position.x + 1, current_position.y),
        Ok(Guard(at: current_position, facing: Down)),
      )
    "<" <> rest ->
      map_and_start_loop(
        rest,
        dict.insert(map, current_position, Free),
        Position(current_position.x + 1, current_position.y),
        Ok(Guard(at: current_position, facing: Left)),
      )
    "\n" <> rest ->
      map_and_start_loop(
        rest,
        map,
        Position(0, current_position.y + 1),
        start_position,
      )
    _ -> #(map, start_position)
  }
}
