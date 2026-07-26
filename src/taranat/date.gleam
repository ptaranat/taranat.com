import gleam/int
import gleam/string

pub type Date {
  Date(year: Int, month: Int, day: Int)
}

pub fn parse(iso: String) -> Result(Date, Nil) {
  case string.split(iso, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(year), Ok(month), Ok(day) if month >= 1 && month <= 12 ->
          case day >= 1 && day <= days_in_month(year, month) {
            True -> Ok(Date(year, month, day))
            False -> Error(Nil)
          }
        _, _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn days_in_month(year: Int, month: Int) -> Int {
  case month {
    2 ->
      case is_leap_year(year) {
        True -> 29
        False -> 28
      }
    4 | 6 | 9 | 11 -> 30
    _ -> 31
  }
}

fn is_leap_year(year: Int) -> Bool {
  year % 4 == 0 && { year % 100 != 0 || year % 400 == 0 }
}

/// `May 2, 2026`, for the top of a post.
pub fn long(iso: String) -> String {
  case parse(iso) {
    Ok(date) ->
      month_name(date.month)
      <> " "
      <> int.to_string(date.day)
      <> ", "
      <> int.to_string(date.year)
    Error(_) -> iso
  }
}

/// `MAY 02, 2026`, zero-padded so the dates line up as a column in the post
/// index.
pub fn index(iso: String) -> String {
  case parse(iso) {
    Ok(date) ->
      string.uppercase(month_abbrev(date.month))
      <> " "
      <> pad2(date.day)
      <> ", "
      <> int.to_string(date.year)
    Error(_) -> iso
  }
}

/// `Sat, 02 May 2026 00:00:00 GMT`, as RSS wants it. Posts carry a date but no
/// time, so midnight UTC stands in.
pub fn rfc822(iso: String) -> String {
  case parse(iso) {
    Ok(date) ->
      day_of_week(date)
      <> ", "
      <> pad2(date.day)
      <> " "
      <> month_abbrev(date.month)
      <> " "
      <> int.to_string(date.year)
      <> " 00:00:00 GMT"
    Error(_) -> iso
  }
}

/// Zeller's congruence.
fn day_of_week(date: Date) -> String {
  let #(m, y) = case date.month < 3 {
    True -> #(date.month + 12, date.year - 1)
    False -> #(date.month, date.year)
  }
  let k = y % 100
  let j = y / 100
  let h = { date.day + { 13 * { m + 1 } } / 5 + k + k / 4 + j / 4 + 5 * j } % 7

  case h {
    0 -> "Sat"
    1 -> "Sun"
    2 -> "Mon"
    3 -> "Tue"
    4 -> "Wed"
    5 -> "Thu"
    _ -> "Fri"
  }
}

fn pad2(value: Int) -> String {
  case value < 10 {
    True -> "0" <> int.to_string(value)
    False -> int.to_string(value)
  }
}

fn month_abbrev(month: Int) -> String {
  string.slice(month_name(month), 0, 3)
}

fn month_name(month: Int) -> String {
  case month {
    1 -> "January"
    2 -> "February"
    3 -> "March"
    4 -> "April"
    5 -> "May"
    6 -> "June"
    7 -> "July"
    8 -> "August"
    9 -> "September"
    10 -> "October"
    11 -> "November"
    _ -> "December"
  }
}
