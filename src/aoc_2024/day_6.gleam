import gleam/dict.{type Dict}
import gleam/set.{type Set}

pub fn parse(input: String) -> #(Map, Result(Guard, Nil)) {
  map_and_start_loop(input, dict.new(), Position(0, 0), Error(Nil))
}

pub fn pt_1(input: #(Map, Result(Guard, Nil))) -> Int {
  let assert #(map, Ok(guard)) = input

  walk(guard, set.new(), map) |> set.size()
}

pub fn pt_2(input: #(Map, Result(Guard, Nil))) -> Int {
  let assert #(map, Ok(guard)) = input

  walk(guard, set.new(), map)
  |> set.delete(guard.at)
  |> set.filter(fn(new_obstacle) {
    is_in_loop(guard, set.new(), map |> dict.insert(new_obstacle, Obstacle))
  })
  |> set.size()
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
  let new_visited = visited |> set.insert(current.at)
  case dict.get(map, next_pos) {
    Ok(Free) -> walk(Guard(..current, at: next_pos), new_visited, map)
    Ok(Obstacle) ->
      walk(
        Guard(..current, facing: turn_clockwise(current.facing)),
        new_visited,
        map,
      )
    Error(Nil) -> new_visited
  }
}

fn is_in_loop(current: Guard, visited: Set(Guard), map: Map) -> Bool {
  case visited |> set.contains(current) {
    // Already visited position with same facing -> loops
    True -> True
    False -> {
      let new_visited = visited |> set.insert(current)
      let next_pos = next_pos(current.at, current.facing)
      case map |> dict.get(next_pos) {
        Ok(Free) ->
          is_in_loop(
            // move to next free space
            Guard(..current, at: next_pos),
            new_visited,
            map,
          )
        Ok(Obstacle) ->
          is_in_loop(
            // turn
            Guard(..current, facing: turn_clockwise(current.facing)),
            new_visited,
            map,
          )
        // Out of map, no loop
        Error(Nil) -> False
      }
    }
  }
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
