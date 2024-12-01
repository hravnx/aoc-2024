import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

fn split_and_parse(line: String) -> Result(#(Int, Int), String) {
  case string.split(line, "   ") {
    [x_str, y_str] ->
      case int.base_parse(x_str, 10), int.base_parse(y_str, 10) {
        Ok(x), Ok(y) -> Ok(#(x, y))
        _, _ -> Error("Bad values in " <> line)
      }
    _ -> Error("Bad list entry " <> line)
  }
}

fn day_01_part1(left: List(Int), right: List(Int)) -> Int {
  let left_s = left |> list.sort(by: int.compare)
  let right_s = right |> list.sort(by: int.compare)
  list.zip(left_s, right_s)
  |> list.map(fn(pair) {
    let #(a, b) = pair
    int.absolute_value(a - b)
  })
  |> list.fold(from: 0, with: int.add)
}

fn day_01_part2(left: List(Int), right: List(Int)) -> Int {
  let right_count =
    right
    |> list.fold(from: dict.new(), with: fn(acc, x) {
      dict.upsert(acc, x, fn(prev_count) {
        case prev_count {
          Some(count) -> count + 1
          None -> 1
        }
      })
    })
  left
  |> list.fold(from: 0, with: fn(acc, x) {
    case dict.get(right_count, x) {
      Ok(count) -> acc + x * count
      Error(_) -> acc
    }
  })
}

fn is_not_empty(line: String) -> Bool {
  line |> string.trim != ""
}

pub fn main() -> Int {
  let values_maybe =
    simplifile.read("../input/day-01.txt")
    |> result.unwrap(or: "")
    |> string.split(on: "\n")
    |> list.filter(keeping: is_not_empty)
    |> list.map(with: split_and_parse)
    |> result.all

  case values_maybe {
    Ok(values) -> {
      let #(left, right) =
        list.fold(over: values, from: #([], []), with: fn(acc, value) {
          let #(a, b) = value
          let #(left, right) = acc
          #([a, ..left], [b, ..right])
        })
      [#("Part 1: ", day_01_part1), #("Part 2: ", day_01_part2)]
      |> list.each(fn(pair) {
        let #(label, compute_answer) = pair
        io.println(label <> compute_answer(left, right) |> int.to_string)
      })
      0
    }
    Error(e) -> {
      io.debug(e)
      1
    }
  }
}
