#import "@preview/oxifmt:1.0.0": strfmt
#import "../state.typ" as state
#import "../config/args.typ": __examst-args

#let next-q-start-label() = {
  let labels = query(selector(metadata)
    .after(here()))
    .filter(it => {
      (type(it.value) == str) and (it.value.starts-with("q-start"))
    })
 if labels.len() > 0 {
   return labels.first().label
 } else {
   return none
 }
}

#let _q-start-label-text() = strfmt(
  "q-start:{num}",
  num: state.question-number.get().map(it => str(it)).join(".")
)

#let _q-start-label() = label(_q-start-label-text())

#let _q-end-label-text() = strfmt(
  "q-end:{num}",
  num: state.question-number
  .get()
  .slice(0, state.question-depth.get())
  .map(it => str(it))
  .join(".")
)

#let _q-end-label() = label(_q-end-label-text())

#let _q-start(points) = {
  context [
    #metadata(_q-start-label-text())
    #_q-start-label()

    #metadata(points)
    #label("points")
  ]
}

#let _q-end() = {
  context [
    #metadata(_q-end-label-text())
    #_q-end-label()
  ]
}

#let points-between(start-label, end-label) = query(
  selector(<points>)
  .after(start-label)
  .before(end-label)
).map(it => it.value).fold(
  (:),
  (acc, curr) => {
    for (k, v) in curr {
      acc.insert(
        k, acc.at(k, default: 0) + v
      )
    }
    return acc
  }
)

// TODO: design consideration, should we do it like this or should it be like a grid where
// ------------------------------------------
// | Qnumber | content                      |
// ------------------------------------------
//           ^ align this to margin
#let question(
  // TODO: consider if this is good semantics
  render-question-counter: none,
  render-points: none,
  points-position: none,
  points: (:),
  aggregate: false,
  inline: false,
  body
) = context {
  // TODO: allow for customizing wrapper
  let _wrapper = if inline {
    box.with(width: 1fr)
  } else {
    block.with(inset: (left: 1em), width: 100%)
  }

  let _render-counter = if render-question-counter == none {
    (__examst-args.at("render-question-counter").get-raw)()
  } else {
    render-question-counter
  }

  let _render-pts = if render-points == none {
    (__examst-args.at("render-points").get-raw)()
  } else {
    render-points
  }

  let _pts-position = if points-position == none {
    (__examst-args.at("points-position").get-raw)()
  } else {
    points-position
  }

  let _points = if type(points) == int or type(points) == float {
    (points: points)
  } else {
    points
  }

  _wrapper({
    state.question-depth.update(it => it + 1)

    context [
      #state.question-number.step(level: state.question-depth.get())
    ]

    _q-start(_points)

    // Compute the rendered points content
    let _pts-content = context {
      let _points-end-label = if aggregate {
        _q-end-label()
      } else {
        if next-q-start-label() != none { next-q-start-label() } else { _q-end-label() }
      }
      let _pts = points-between(
        _q-start-label(),
        _points-end-label,
      )
      _render-pts(_pts)
    }

    // Arrange counter, points, and body based on points-position
    if _pts-position == "before-counter" [
      #context[#_pts-content]
      #context[#_render-counter(state.question-number)]
      #body
    ] else if _pts-position == "after-body" [
      #context[#_render-counter(state.question-number)]
      #body
      #context[#_pts-content]
    ] else if _pts-position == "left-margin" [
      #context { place(left, dx: -6em - 1em * state.question-depth.get(), box(width: 4.5em, align(right, _pts-content))) }
      #context[#_render-counter(state.question-number)]
      #body
    ] else if _pts-position == "right-margin" [
      #context { place(right, dx: 5em, box(width: 4.5em, align(left, _pts-content))) }
      #context[#_render-counter(state.question-number)]
      #body
    ] else if _pts-position == "inline" [
      #context[#_render-counter(state.question-number)]
      #context[#_pts-content]
      #body
    ] else if type(_pts-position) == function [
      #context[#_pts-position(pts-content)]
      #context[#_render-counter(state.question-number)]
    ]

    _q-end()

    context[
      #state.question-depth.update(it => it - 1)
    ]
  })
}
