import gleam/deque.{type Deque}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}
import utils.{shortcircuit}

pub fn pt_1(input: String) {
  parse_disk_map(input)
  |> yielder.fold(deque.new(), deque.push_back)
  |> compact()
  |> yielder.index()
  |> yielder.fold(0, fn(checksum, indexed_block) {
    case indexed_block.0 {
      Data(id) -> checksum + { indexed_block.1 * id }
      Free -> checksum
    }
  })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

pub type Block {
  Data(id: Int)
  Free
}

fn parse_disk_map(disk_map: String) -> Yielder(Block) {
  yielder.unfold(#(True, 0, disk_map), fn(state) {
    let #(is_data, id, current) = state
    use #(count_str, rest) <- shortcircuit(
      string.pop_grapheme(current),
      yielder.Done,
    )
    let assert Ok(count) = int.parse(count_str)

    case is_data {
      True ->
        yielder.Next(yielder.repeat(Data(id)) |> yielder.take(count), #(
          False,
          id + 1,
          rest,
        ))
      False ->
        yielder.Next(yielder.repeat(Free) |> yielder.take(count), #(
          True,
          id,
          rest,
        ))
    }
  })
  |> yielder.flatten()
}

fn compact(file: Deque(Block)) -> Yielder(Block) {
  yielder.unfold(file, fn(f) {
    use #(front, rest) <- shortcircuit(deque.pop_front(f), yielder.Done)

    case front {
      Data(_) -> yielder.Next(front, rest)
      Free -> {
        use #(data, rest_2) <- shortcircuit(
          pop_back_to_data(rest),
          yielder.Done,
        )
        yielder.Next(data, rest_2)
      }
    }
  })
}

fn pop_back_to_data(file: Deque(Block)) -> Result(#(Block, Deque(Block)), Nil) {
  use #(back, rest) <- result.try(deque.pop_back(file))

  case back {
    Data(_) -> Ok(#(back, rest))
    Free -> pop_back_to_data(rest)
  }
}
