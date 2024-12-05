import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder

pub fn parse(input: String) -> Result(#(List(Rule), List(Update)), Nil) {
  let rows = string.split(input, on: "\n")
  let #(rule_strs, update_strs) =
    list.split_while(rows, fn(r) { !string.is_empty(r) })

  use rules <- result.try(parse_rules(rule_strs))
  use updates <- result.try(parse_updates(update_strs))

  Ok(#(rules, updates))
}

pub fn pt_1(input: Result(#(List(Rule), List(Update)), Nil)) -> Int {
  let assert Ok(#(rules, updates)) = input

  let assert Ok(middle_sum) =
    list.filter(updates, is_update_correct(_, rules))
    |> list.try_map(middle_page)
    |> result.map(list.fold(_, 0, int.add))

  middle_sum
}

pub fn pt_2(input: Result(#(List(Rule), List(Update)), Nil)) -> Int {
  let assert Ok(#(rules, updates)) = input

  let assert Ok(middle_sum) =
    list.filter(updates, fn(update) { !is_update_correct(update, rules) })
    |> list.map(fix_update(_, rules))
    |> list.try_map(middle_page)
    |> result.map(list.fold(_, 0, int.add))

  middle_sum
}

pub type Rule {
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

pub type Update =
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

type PageAfter {
  PageAfter(page: Int, after_count: Int)
}

fn fix_update(update: Update, rules: List(Rule)) -> Update {
  let relevant_rules =
    list.filter(rules, fn(r) {
      list.contains(update, r.before) && list.contains(update, r.after)
    })
  let inital_pages_dict =
    list.map(update, fn(page) { #(page, 0) })
    |> dict.from_list()

  let pages_after =
    list.fold(relevant_rules, inital_pages_dict, fn(pa, page) {
      dict.upsert(pa, page.after, dict_add(_, 1, 1))
    })
    |> dict.to_list()
    |> list.map(fn(kvp) { PageAfter(kvp.0, kvp.1) })

  yielder.unfold(pages_after, fn(pages_after) {
    let next_page =
      list.pop(pages_after, fn(page_after) { page_after.after_count <= 0 })

    case next_page {
      Ok(#(PageAfter(page, 0), others)) ->
        yielder.Next(page, update_pages_after(others, page, relevant_rules))
      _ -> yielder.Done
    }
  })
  |> yielder.to_list()
}

fn update_pages_after(
  pages_after: List(PageAfter),
  page: Int,
  rules: List(Rule),
) -> List(PageAfter) {
  list.map(pages_after, fn(page_after) {
    case list.contains(rules, Rule(page, page_after.page)) {
      True -> PageAfter(page_after.page, page_after.after_count - 1)
      False -> page_after
    }
  })
}

fn dict_add(
  current_value: option.Option(Int),
  increment: Int,
  starting_value: Int,
) -> Int {
  option.map(current_value, int.add(_, increment))
  |> option.unwrap(starting_value)
}

fn middle_page(update: Update) -> Result(Int, Nil) {
  let len = list.length(update)
  let middle_idx = len / 2

  yielder.from_list(update)
  |> yielder.at(middle_idx)
}
