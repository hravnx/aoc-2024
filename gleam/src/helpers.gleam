import gleam/list
import gleam/string

pub fn is_not_empty(line: String) -> Bool {
  line |> string.trim != ""
}

pub fn to_lines(input: String) -> List(String) {
  input |> string.split(on: "\n") |> list.filter(keeping: is_not_empty)
}

pub fn is_negative(value: Int) -> Bool {
  value < 0
}

pub fn is_positive(value: Int) -> Bool {
  value > 0
}

pub fn ignore(_value: a) -> Nil {
  Nil
}

/// Return a list that is equal to the `values` list, with the element at
/// position `index` removed.
pub fn remove_index(values: List(a), index: Int) -> List(a) {
  case list.split(values, index) {
    #(h, [_, ..rest]) -> list.append(h, rest)
    _ -> values
  }
}
