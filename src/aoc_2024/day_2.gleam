import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> yielder.from_list()
  |> yielder.map(string.split(_, on: " "))
  |> yielder.map(list.filter_map(_, int.parse))
  |> yielder.to_list()
}

pub fn pt_1(input: List(List(Int))) {
  yielder.from_list(input)
  |> yielder.map(report_safety)
  |> yielder.filter(is_safe)
  |> yielder.length()
}

pub fn pt_2(input: List(List(Int))) {
  yielder.from_list(input)
  |> yielder.map(report_safety_damped)
  |> yielder.filter(is_safe)
  |> yielder.length()
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

fn is_safe(report: Safety) -> Bool {
  case report {
    Safe(_, _) -> True
    _ -> False
  }
}

fn report_safety(report: List(Int)) -> Safety {
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

fn report_safety_damped(report: List(Int)) -> Safety {
  yield_with_one_dropped(report)
  |> yielder.prepend(report)
  |> yielder.map(report_safety)
  |> yielder.find(is_safe)
  |> result.unwrap(Unsafe)
}

fn yield_with_one_dropped(over l: List(elem)) -> yielder.Yielder(List(elem)) {
  let len = list.length(l)
  yielder.unfold(0, fn(idx) {
    case idx < len {
      True -> yielder.Next(remove_idx(l, idx), idx + 1)
      False -> yielder.Done
    }
  })
}

fn remove_idx(from l: List(elem), index i: Int) -> List(elem) {
  let before = list.split(l, i).0
  let after = list.split(l, i + 1).1

  list.append(before, after)
}
