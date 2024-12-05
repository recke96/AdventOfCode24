import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder

pub fn pt_1(input: String) -> Result(Int, Nil) {
  let rows = string.split(input, on: "\n")
  let #(rule_strs, update_strs) =
    list.split_while(rows, fn(r) { !string.is_empty(r) })

  use rules <- result.try(parse_rules(rule_strs))
  use updates <- result.try(parse_updates(update_strs))

  list.filter(updates, is_update_correct(_, rules))
  |> list.try_map(middle_page)
  |> result.map(list.fold(_, 0, int.add))
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}

type Rule {
  Rule(before: Int, after: Int)
}

fn parse_rule(input: String) -> Result(Rule, Nil) {
  use #(a, b) <- result.try(string.split_once(input, on: "|"))
  use x <- result.try(int.parse(a))
  use y <- result.try(int.parse(b))

  Ok(Rule(x, y))
}

fn parse_rules(input: List(String)) -> Result(List(Rule), Nil) {
  list.filter(input, fn(r) { !string.is_empty(r) })
  |> list.try_map(parse_rule)
}

type Update =
  List(Int)

fn parse_update(input: String) -> Result(Update, Nil) {
  string.split(input, on: ",")
  |> list.try_map(int.parse)
}

fn parse_updates(input: List(String)) -> Result(List(Update), Nil) {
  list.filter(input, fn(r) { !string.is_empty(r) })
  |> list.try_map(parse_update)
}

fn is_update_correct(update: Update, rules: List(Rule)) -> Bool {
  let update_state = fn(s: #(Bool, List(Rule)), page: Int) -> #(
    Bool,
    List(Rule),
  ) {
    let is_violation = list.any(s.1, fn(r) { r.before == page })

    #(
      !is_violation,
      list.unique(list.append(
        s.1,
        list.filter(rules, fn(r) { r.before == page || r.after == page }),
      )),
    )
  }

  let applied_rules =
    list.fold_until(update, #(True, []), fn(state, page) {
      case state {
        #(False, _) -> list.Stop(state)
        _ -> list.Continue(update_state(state, page))
      }
    })

  applied_rules.0
}

fn middle_page(update: Update) -> Result(Int, Nil) {
  let len = list.length(update)
  let middle_idx = len / 2

  yielder.from_list(update)
  |> yielder.at(middle_idx)
}
