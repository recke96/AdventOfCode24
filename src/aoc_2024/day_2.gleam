import gleam/int
import gleam/list
import gleam/string
import gleam/yielder

pub type Report {
  Report(levels: List(Int))
}

pub fn parse(input: String) -> List(Report) {
  string.split(input, on: "\n")
  |> yielder.from_list()
  |> yielder.map(string.split(_, on: " "))
  |> yielder.map(list.filter_map(_, int.parse))
  |> yielder.map(Report)
  |> yielder.to_list()
}

pub fn pt_1(input: List(Report)) {
  yielder.from_list(input)
  |> yielder.filter(is_safe_strict)
  |> yielder.length()
}

pub fn pt_2(input: List(Report)) {
  yielder.from_list(input)
  |> yielder.filter(is_safe_damped)
  |> yielder.length()
}

type Status {
  Starting
  Started(previous: Int)
  Increasing(previous: Int)
  Decreasing(previous: Int)
  Unsafe
}

fn is_safe_strict(report: Report) -> Bool {
  let assessment =
    list.fold_until(report.levels, Starting, fn(assessment, current) {
      case assessment {
        Starting -> list.Continue(Started(current))
        Started(prev) if current > prev && current - prev <= 3 ->
          list.Continue(Increasing(current))
        Started(prev) if current < prev && prev - current <= 3 ->
          list.Continue(Decreasing(current))
        Increasing(prev) if current > prev && current - prev <= 3 ->
          list.Continue(Increasing(current))
        Decreasing(prev) if current < prev && prev - current <= 3 ->
          list.Continue(Decreasing(current))
        _ -> list.Stop(Unsafe)
      }
    })

  assessment != Unsafe
}

fn is_safe_damped(report: Report) -> Bool {
  yield_with_one_dropped(report.levels)
  |> yielder.map(Report)
  |> yielder.prepend(report)
  |> yielder.any(is_safe_strict)
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

fn remove_idx(from list: List(elem), index to_remove: Int) -> List(elem) {
  let list_without =
    list.index_fold(list, list.new(), fn(acc, e, idx) {
      case idx == to_remove {
        False -> [e, ..acc]
        True -> acc
      }
    })

  list.reverse(list_without)
}
