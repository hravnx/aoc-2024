import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import helpers.{ignore}
import simplifile

// --------------------------------------------------------------------------

fn get_numbers_from_match(m: regexp.Match) -> #(Int, Int) {
  case m.submatches {
    [Some(a), Some(b)] -> {
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)

      #(a, b)
    }
    _ -> #(0, 0)
  }
}

fn parse_mul_instructions(line: String) -> List(#(Int, Int)) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(re, line)
  |> list.map(get_numbers_from_match)
}

type Instruction {
  Mul(Int, Int)
  Do
  Dont
}

fn get_instruction_from_match(m: regexp.Match) -> Instruction {
  case m.submatches {
    [Some("mul"), Some(a), Some(b)] -> {
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)
      //io.debug(#(a, b))
      Mul(a, b)
    }
    [_, _, _, Some("do()")] -> Do
    [_, _, _, _, Some("don't()")] -> Dont
    _ -> {
      io.debug(m) |> ignore
      panic as "Invalid instruction"
    }
  }
}

fn parse_instructions_cond(line: String) -> List(Instruction) {
  let assert Ok(re) =
    regexp.from_string("(mul)\\((\\d+),(\\d+)\\)|(do\\(\\))|(don't\\(\\))")
  regexp.scan(re, line)
  |> list.map(get_instruction_from_match)
}

type EvalState {
  State(total: Int, enabled: Bool)
}

fn evaluate(instructions: List(Instruction)) -> Int {
  let final_state =
    list.fold(
      instructions,
      State(0, True),
      fn(state: EvalState, instruction: Instruction) -> EvalState {
        case instruction {
          Mul(a, b) -> {
            case state {
              State(total, True) -> State(a * b + total, True)
              State(total, False) -> State(total, False)
            }
          }
          Do -> State(state.total, True)
          Dont -> State(state.total, False)
        }
      },
    )
  final_state.total
}

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------

fn day_03_part1(text: String) -> Nil {
  parse_mul_instructions(text)
  |> list.map(fn(pair) {
    let #(a, b) = pair
    a * b
  })
  |> list.fold(0, fn(a, b) { a + b })
  |> fn(sum) { io.println("Part 1: " <> sum |> int.to_string) }
}

fn day_03_part2(text: String) -> Nil {
  parse_instructions_cond(text)
  |> evaluate
  |> fn(sum) { io.println("Part 2: " <> sum |> int.to_string) }
}

pub fn main() {
  let _test_text_part1 =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

  let _test_text_part2 =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  case simplifile.read("../input/day-03.txt") {
    Ok(text) -> {
      text |> day_03_part1
      text |> day_03_part2
    }
    Error(e) -> io.debug(e) |> ignore
  }
}
