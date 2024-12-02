import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import helpers.{ignore, remove_index, to_lines}
import simplifile

// --------------------------------------------------------------------------
// Utils
// --------------------------------------------------------------------------

fn parse_list_of_numbers(line: String) -> Result(List(Int), Nil) {
  line
  |> string.split(on: " ")
  |> list.map(fn(x) { int.base_parse(x, 10) })
  |> result.all
}

fn is_safe(values: List(Int)) -> Bool {
  let diffs =
    values
    |> list.window_by_2
    |> list.map(fn(pair) {
      let #(a, b) = pair
      a - b
    })
  list.all(diffs, fn(v) { v < 0 && v > -4 })
  || list.all(diffs, fn(v) { v > 0 && v < 4 })
}

fn is_safe_dampened(values: List(Int)) -> Bool {
  case is_safe(values) {
    True -> True
    False -> {
      let l = list.length(values) - 1
      list.any(list.range(0, l), fn(i) { is_safe(remove_index(values, i)) })
    }
  }
}

fn day_02_part1(reports: Result(List(List(Int)), a)) {
  case reports {
    Ok(values) -> {
      let count = list.count(values, is_safe)
      io.println("Part 1: " <> count |> int.to_string)
    }
    Error(e) -> io.debug(e) |> ignore
  }
}

fn day_02_part2(reports: Result(List(List(Int)), a)) {
  case reports {
    Ok(values) -> {
      let count = list.count(values, is_safe_dampened)
      io.println("Part 2: " <> count |> int.to_string)
    }
    Error(e) -> io.debug(e) |> ignore
  }
}

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------

pub fn main() {
  case simplifile.read("../input/day-02.txt") {
    Ok(text) -> {
      let values_maybe =
        to_lines(text)
        |> list.map(parse_list_of_numbers)
        |> result.all

      values_maybe |> day_02_part1
      values_maybe |> day_02_part2
    }
    Error(e) -> io.debug(e) |> ignore
  }
}
