import gleam/int
import gleam/list
import gleam/string
import gleam/yielder

pub fn pt_1(input: String) {
  string.split(input, on: "\n")
  |> yielder.from_list()
  |> yielder.map(string.split(_, on: " "))
  |> yielder.map(list.filter_map(_, int.parse))
  |> yielder.map(is_save)
  |> yielder.filter(fn(r) {
    case r {
      Safe(_, _) -> True
      _ -> False
    }
  })
  |> yielder.length()
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

type LevelChange {
  Undetermined
  Increasing
  Decreasing
}

type Safety {
  Unknown
  Safe(LevelChange, Int)
  Unsafe
}

fn is_save(report: List(Int)) -> Safety {
  list.fold_until(report, Unknown, fn(safety, level) {
    case safety {
      Unknown -> list.Continue(Safe(Undetermined, level))
      Unsafe -> list.Stop(Unsafe)
      Safe(change, previous) ->
        case change, { previous - level } {
          Undetermined, -1 | Undetermined, -2 | Undetermined, -3 ->
            list.Continue(Safe(Decreasing, level))
          Undetermined, 1 | Undetermined, 2 | Undetermined, 3 ->
            list.Continue(Safe(Increasing, level))
          Increasing, 1 | Increasing, 2 | Increasing, 3 ->
            list.Continue(Safe(Increasing, level))
          Decreasing, -1 | Decreasing, -2 | Decreasing, -3 ->
            list.Continue(Safe(Decreasing, level))
          _, _ -> list.Stop(Unsafe)
        }
    }
  })
}
