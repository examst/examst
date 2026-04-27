#import "../state.typ" as state
#import "../config/args.typ": __examst-args, arg-or-default
#import "question/labels.typ": *
#import "question/render-points.typ": *
#import "question/points-position.typ": *

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
  
  let _render-counter = arg-or-default(
    render-question-counter, 
    "render-question-counter"
  )
  
  let _render-pts = arg-or-default(
    render-points,
    "render-points"
  )
  // Resolve preset name to function
  let _render-pts = if type(_render-pts) == str {
    render-points-configs.at(_render-pts)
  } else {
    _render-pts
  }
  
  let _pts-position = arg-or-default(
    points-position,
    "points-position"
  )
  // Resolve preset name to function
  let _pts-position = if type(_pts-position) == str {
    points-position-configs.at(_pts-position)
  } else {
    _pts-position
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

    let _counter-content = context[#_render-counter(state.question-number)]
    let _depth = state.question-depth.get()

    _pts-position(_pts-content, _counter-content, body, _depth)

    _q-end()

    context[
      #state.question-depth.update(it => it - 1)
    ]
  })
}
