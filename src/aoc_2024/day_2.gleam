import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
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

type Assessment {
  Assessment(previous: Option(Int), increased: Int, decreased: Int, safe: Bool)
}

fn is_safe_strict(report: Report) -> Bool {
  let assessment =
    list.fold_until(
      report.levels,
      Assessment(None, 0, 0, True),
      fn(assessment, lvl) {
        case { option.map(assessment.previous, int.subtract(lvl, _)) } {
          None -> list.Continue(Assessment(..assessment, previous: Some(lvl)))
          Some(1) | Some(2) | Some(3) if assessment.decreased <= 0 ->
            list.Continue(
              Assessment(
                ..assessment,
                previous: Some(lvl),
                increased: assessment.increased + 1,
              ),
            )
          Some(-1) | Some(-2) | Some(-3) if assessment.increased <= 0 ->
            list.Continue(
              Assessment(
                ..assessment,
                previous: Some(lvl),
                decreased: assessment.decreased + 1,
              ),
            )
          _ ->
            list.Stop(
              Assessment(..assessment, previous: Some(lvl), safe: False),
            )
        }
      },
    )
  assessment.safe
}

fn is_safe_damped(report: Report) -> Bool {
  yield_with_one_dropped(report.levels)
  |> yielder.map(Report)
  |> yielder.prepend(report)
  |> yielder.any(is_safe_strict)
}

fn yield_with_one_dropped(over l: List(elem)) -> yielder.Yielder(List(elem)) {
  let len = list.length(l)
  yielder.unfold(1, fn(idx) {
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
