#import "../config/args.typ": (
  __examst-args, __examst-default, arg-or-default, if-print-answers,
)
#import "multi-choice/markers.typ": bad-overlay, marker-configs

#let fill-in(answer, width: __examst-default, stroke: 0.5pt) = context {
  let _width = arg-or-default(width, "fill-in-width")

  if _width == auto {
    _width = measure(answer).width + 3em
  }

  box(stroke: (bottom: stroke), outset: (bottom: 2pt), width: _width, align(
    center,
    if-print-answers(answer, []),
  ))
}
