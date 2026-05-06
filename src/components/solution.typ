/// Solution component — answer-space + solution environment.
///
/// Two public APIs:
/// - `solution`: renders nothing when hidden, framed solution when shown.
/// - `answer`: renders fill inside frame when hidden, solution inside frame when shown.
///   (Replaces the old solution-box — use `answer(fill: v)` for an empty box.)

#import "../config/args.typ": (
  __examst-args, __examst-default, arg-or-default, is-show-answers,
)
#import "solution/spaces.typ": fill-grid, fill-lines, resolve-fill
#import "solution/frame.typ": resolve-frame

// ── Primary API ──────────────────────────────────────────────────

/// Always-visible answer space. Not tied to show/hide — renders unconditionally.
///
/// - `height`: Height of the space. Defaults to global `solution-height`.
/// - `fill`: Fill pattern — preset string or `(height) -> content` function.
/// - `frame`: Framing style — preset string, dict of block() keys, or function.
///   Defaults to `"none"` (no border).
#let answer-space(
  height: __examst-default,
  fill: __examst-default,
  frame: "none",
) = context {
  let _height = arg-or-default(height, "solution-height")
  let _raw-fill = arg-or-default(fill, "solution-fill")
  let _fill = resolve-fill(_raw-fill)
  let _frame = if _raw-fill == "grid" or _raw-fill == fill-grid {
    resolve-frame(frame, inset: 0pt)
  } else {
    resolve-frame(frame)
  }
  _frame(_fill(_height))
}


/// Renders nothing when answers are hidden and a framed solution when shown.
///
/// - `title`: Content prepended to the solution (e.g. `[*Solution:*]`).
/// - `emphasis`: Function applied to the solution body text.
/// - `frame`: Framing style — preset string, dict of block() keys, or function.
/// - `body`: The solution content.
#let solution(
  title: __examst-default,
  emphasis: __examst-default,
  frame: __examst-default,
  body,
) = context {
  let _show = is-show-answers()
  if not _show { return }

  let _title = arg-or-default(title, "solution-title")
  let _emphasis = arg-or-default(emphasis, "solution-emphasis")
  let _frame = resolve-frame(arg-or-default(frame, "solution-frame"))

  let styled = _emphasis(body)
  let titled = if _title != none {
    [#_title #styled]
  } else {
    styled
  }

  _frame(titled)
}

/// Renders a fixed-height framed region. Layout is stable between show/hide modes.
///
/// When `show-answers` is false: renders `fill(height)` inside the frame.
/// When `show-answers` is true: renders the solution body inside the frame.
///
/// - `height`: Height of the answer region. Defaults to global `solution-height`.
/// - `fill`: Fill pattern — preset string (`"lines"`, `"grid"`, `"none"`) or
///   a `(height) -> content` function (e.g. `v`, `fill-lines.with(spacing: 0.5in)`).
/// - `frame`: Framing style — preset string, dict of block() keys, or function.
/// - `title`: Content prepended to the solution.
/// - `emphasis`: Function applied to the solution body text.
/// - `sol-height`: Height of the solution frame when shown.
///   Default (`none`) matches `height`. `auto` auto-sizes to content. A length forces that height.
/// - `body`: The solution content.
#let answer(
  height: __examst-default,
  fill: __examst-default,
  frame: __examst-default,
  title: __examst-default,
  emphasis: __examst-default,
  sol-height: none,
  body,
) = context {
  let _show = is-show-answers()
  let _height = arg-or-default(height, "solution-height")
  let _raw-fill = arg-or-default(fill, "solution-fill")
  let _fill = resolve-fill(_raw-fill)
  let _raw-frame = arg-or-default(frame, "solution-frame")
  let _frame = resolve-frame(_raw-frame)
  let _title = arg-or-default(title, "solution-title")
  let _emphasis = arg-or-default(emphasis, "solution-emphasis")

  if _show {
    let effective-height = if sol-height == none {
      _height
    } else if sol-height == auto {
      auto
    } else {
      sol-height
    }

    let styled = _emphasis(body)
    let titled = if _title != none {
      [#_title #styled]
    } else {
      styled
    }

    _frame(block(
      width: 100%,
      height: effective-height,
      breakable: false,
      titled,
    ))
  } else {
    let hidden-frame = if _raw-fill == "grid" or _raw-fill == fill-grid {
      resolve-frame(_raw-frame, inset: 0pt)
    } else {
      _frame
    }
    hidden-frame(_fill(_height))
  }
}
