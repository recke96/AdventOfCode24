pub fn shortcircuit(result: Result(a, b), short: c, circuit: fn(a) -> c) -> c {
  case result {
    Ok(a) -> circuit(a)
    Error(_) -> short
  }
}
