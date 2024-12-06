import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import utils.{shortcircuit}

pub fn parse(input: String) -> #(Map, Result(Guard, Nil)) {
  map_and_start_loop(input, dict.new(), Position(0, 0), Error(Nil))
}

pub fn pt_1(input: #(Map, Result(Guard, Nil))) -> Int {
  let assert #(map, Ok(guard)) = input

  walk(guard, set.new(), map) |> set.size()
}

pub fn pt_2(input: #(Map, Result(Guard, Nil))) -> Int {
  let assert #(map, Ok(guard)) = input

  let obstacles =
    map
    |> dict.filter(fn(_, sym) { sym == Obstacle })
    |> dict.keys()
  walk(guard, set.new(), map)
  |> set.delete(guard.at)
  |> set.filter(fn(new_obstacle) {
    is_in_loop(guard, set.new(), [new_obstacle, ..obstacles])
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

fn is_in_loop(
  current: Guard,
  visited: Set(Guard),
  obstacles: List(Position),
) -> Bool {
  case visited |> set.contains(current) {
    // Already visited position with same facing -> loops
    True -> True
    False -> {
      let new_visited = visited |> set.insert(current)
      use next_guard <- shortcircuit(
        to_next_obstacle(current, obstacles),
        False,
      )

      is_in_loop(next_guard, new_visited, obstacles)
    }
  }
}

fn to_next_obstacle(
  current: Guard,
  obstacles: List(Position),
) -> Result(Guard, Nil) {
  let next_facing = turn_clockwise(current.facing)
  case current.facing {
    Up -> {
      use Position(obs_x, obs_y) <- result.try(
        obstacles
        |> list.filter(fn(obs) { obs.x == current.at.x && obs.y < current.at.y })
        |> list.sort(fn(a, b) { int.compare(b.y, a.y) })
        |> list.first(),
      )

      Ok(Guard(Position(obs_x, obs_y + 1), next_facing))
    }
    Right -> {
      use Position(obs_x, obs_y) <- result.try(
        obstacles
        |> list.filter(fn(obs) { obs.y == current.at.y && obs.x > current.at.x })
        |> list.sort(fn(a, b) { int.compare(a.x, b.x) })
        |> list.first(),
      )

      Ok(Guard(Position(obs_x - 1, obs_y), next_facing))
    }
    Down -> {
      use Position(obs_x, obs_y) <- result.try(
        obstacles
        |> list.filter(fn(obs) { obs.x == current.at.x && obs.y > current.at.y })
        |> list.sort(fn(a, b) { int.compare(a.y, b.y) })
        |> list.first(),
      )

      Ok(Guard(Position(obs_x, obs_y - 1), next_facing))
    }
    Left -> {
      use Position(obs_x, obs_y) <- result.try(
        obstacles
        |> list.filter(fn(obs) { obs.y == current.at.y && obs.x < current.at.x })
        |> list.sort(fn(a, b) { int.compare(b.x, a.x) })
        |> list.first(),
      )

      Ok(Guard(Position(obs_x + 1, obs_y), next_facing))
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
