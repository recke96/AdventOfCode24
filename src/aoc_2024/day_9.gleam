import gleam/bool
import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/string

pub fn pt_1(input: String) {
  parse(input)
  |> compact_1()
  |> checksum()
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

pub type Block {
  Free(size: Int)
  Data(size: Int, id: Int)
}

fn split_block(block: Block, at: Int) -> Result(List(Block), Nil) {
  use <- bool.guard(at < 0, Error(Nil))

  case int.compare(block.size, at), block {
    order.Eq, Free(size) | order.Lt, Free(size) -> Ok([Free(size)])
    order.Eq, Data(size, id) | order.Lt, Data(size, id) -> Ok([Data(size, id)])
    order.Gt, Free(size) -> Ok([Free(at), Free(size - at)])
    order.Gt, Data(size, id) -> Ok([Data(at, id), Data(size - at, id)])
  }
}

fn parse(graphemes: String) -> Deque(Block) {
  graphemes |> string.to_graphemes() |> parse_loop(True, 0, deque.new())
}

fn parse_loop(
  graphemes: List(String),
  is_data: Bool,
  id: Int,
  blocks: Deque(Block),
) -> Deque(Block) {
  case graphemes {
    [] -> blocks
    [g, ..rest] -> {
      let assert Ok(count) = int.parse(g)
      let #(block, next_id) = case is_data {
        True -> #(Data(count, id), id + 1)
        False -> #(Free(count), id)
      }
      parse_loop(
        rest,
        bool.negate(is_data),
        next_id,
        blocks |> deque.push_back(block),
      )
    }
  }
}

fn compact_1(disk: Deque(Block)) -> Deque(Block) {
  case deque.pop_front(disk) {
    Error(Nil) -> disk
    Ok(#(front, rest)) -> compact_1_loop(deque.new(), front, rest)
  }
}

fn compact_1_loop(
  front: Deque(Block),
  current: Block,
  back: Deque(Block),
) -> Deque(Block) {
  case current {
    Data(_, _) ->
      case deque.pop_front(back) {
        Error(Nil) -> deque.push_back(front, current)
        Ok(#(next, rest)) ->
          compact_1_loop(deque.push_back(front, current), next, rest)
      }
    Free(space) -> {
      let #(new_front, new_back) = fill_free_space(front, space, back)
      case deque.pop_front(new_back) {
        Error(Nil) -> new_front
        Ok(#(next, rest)) -> compact_1_loop(new_front, next, rest)
      }
    }
  }
}

fn fill_free_space(
  front: Deque(Block),
  free_space: Int,
  back: Deque(Block),
) -> #(Deque(Block), Deque(Block)) {
  use <- bool.guard(free_space <= 0, #(front, back))

  case deque.pop_back(back) {
    Error(Nil) -> #(front, back)
    Ok(#(moving, rest)) ->
      case moving {
        Data(size, _) if size <= free_space ->
          fill_free_space(
            deque.push_back(front, moving),
            free_space - size,
            rest,
          )
        Data(_, _) ->
          case split_block(moving, free_space) {
            Error(Nil) -> #(front, back)
            Ok([fitting, splitted]) -> #(
              deque.push_back(front, fitting),
              deque.push_back(rest, splitted),
            )
            Ok(_) -> panic as "Should not happen because guards"
          }
        Free(_) -> fill_free_space(front, free_space, rest)
      }
  }
}

fn checksum(disk: Deque(Block)) -> Int {
  case deque.pop_front(disk) {
    Error(Nil) -> 0
    Ok(#(first, rest)) -> checksum_loop(first, rest, 0, 0)
  }
}

fn checksum_loop(block: Block, disk: Deque(Block), sum: Int, offset: Int) -> Int {
  let #(partial_sum, next_offset) = checksum_block(offset, block)
  case deque.pop_front(disk) {
    Error(Nil) -> sum + partial_sum
    Ok(#(next, rest)) ->
      checksum_loop(next, rest, sum + partial_sum, next_offset)
  }
}

fn checksum_block(offset: Int, block: Block) -> #(Int, Int) {
  case block {
    Free(_) -> #(0, offset)
    Data(size, id) ->
      list.repeat(id, size)
      |> list.index_fold(0, fn(sum, id, idx) { sum + { id * { offset + idx } } })
      |> pair.new(offset + size)
  }
}
