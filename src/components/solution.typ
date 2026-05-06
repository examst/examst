/// Solution component — merged answer-space + solution environment.
///
/// Maps to exam.cls's solution/solutionorbox/solutionorlines/etc.
/// When show-answers is true, renders the solution body.
/// When false, renders the answer space (if provided).

#import "../config/args.typ": __examst-args, __examst-default, arg-or-default, if-print-answers
#import "solution/spaces.typ": fill-lines, fill-grid
#import "solution/frame.typ": frame-solution

// ── Primary API ──────────────────────────────────────────────────
// 

#let _solution-base(
  title,
  emphasis,
  frame,
  fill,
  body
) = context {
  let _show = (__examst-args.at("show-answers").get-raw)()
  let _cancel = (__examst-args.at("cancel-space").get-raw)()
  let _title = arg-or-default(title, "solution-title")
  let _emphasis = arg-or-default(emphasis, "solution-emphasis")
  let _frame = arg-or-default(frame, "solution-frame")
}

/// Renders nothing when answers are hidden and a solution box when answers are
/// shown.
#let solution(
  title: __examst-default,
  emphasis: __examst-default,
  // content -> content | dict (block keys)
  frame: __examst-default,
  fill: __examst-default,
  body
) = if-print-answers({
  let _frame = if type(frame) == function {
    frame
  } else if type(frame) == dict {
    block.with(..frame)
  } else {
    panic("bad type")
  }
})

/// Renders the desired fill when answers are hidden and a solution box when 
/// answers are shown.
#let answer(
  title: __examst-default,
  emphasis: __examst-default,
  frame: __examst-default,
  fill: __examst-default,
  body
) = {}

/// Renders a solution environment.
///
/// When `show-answers` is true, renders `body` with the configured
/// title, emphasis, and frame style.
/// When `show-answers` is false, renders the answer space described
/// by `space` (if provided and `cancel-space` is not active).
///
/// - `space` (none | dict): Answer space descriptor from `lines()`,
///   `dotted-lines()`, `grid-space()`, `box-space()`, or `blank()`.
///   `none` means no space when answers are hidden.
/// - `title`: Content prepended to the solution (e.g. `[*Solution:*]`).
/// - `emphasis`: Function applied to the solution body text.
/// - `frame`: Visual framing style: `"boxed"`, `"shaded"`, or `"none"`.
/// - `body`: The solution content.
#let answer(
  fill: none,
  title: __examst-default,
  emphasis: __examst-default,
  frame: __examst-default,
  body,
) = context {
  let _show = (__examst-args.at("show-answers").get-raw)()
  let _cancel = (__examst-args.at("cancel-space").get-raw)()
  let _title = arg-or-default(title, "solution-title")
  let _emphasis = arg-or-default(emphasis, "solution-emphasis")
  let _frame = arg-or-default(frame, "solution-frame")
  let _shade-color = (__examst-args.at("solution-shade-color").get-raw)()
  let _box-color = (__examst-args.at("solution-box-color").get-raw)()

  if _show {
    frame-solution(body, _frame, _title, _emphasis, _shade-color, _box-color)
  } else if fill != none and not _cancel {
    resolve-space(fill)
  }
}

/// Always-visible answer box (maps to exam.cls `solutionbox`).
///
/// Always draws a bordered box of the given height.
/// When `show-answers` is true, the solution content fills the box.
/// When false, the box is empty.
///
/// - `height` (length): Height of the box.
/// - `title`: Content prepended to the solution inside the box.
/// - `emphasis`: Function applied to the solution body text.
/// - `body`: The solution content.
#let solution-box(
  height,
  title: __examst-default,
  emphasis: __examst-default,
  box-color: __examst-default,
  body,
) = context {
  let _show = (__examst-args.at("show-answers").get-raw)()
  let _title = arg-or-default(title, "solution-title")
  let _emphasis = arg-or-default(emphasis, "solution-emphasis")
  let _box-color = arg-or-default(box-color, "solution-box-color")

  block(width: 100%, height: height, stroke: _box-color, inset: 8pt, {
    if _show {
      let styled = _emphasis(body)
      if _title != none [
        #_title #styled
      ] else {
        styled
      }
    }
  })
}