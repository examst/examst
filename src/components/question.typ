#import "../state.typ" as state
#import "../config/args.typ": __examst-args, __examst-default, arg-or-default
#import "question/labels.typ": *
#import "question/render-points.typ": *
#import "question/render-name.typ": *
#import "question/points-position.typ": *

#let qref(label) = context {
  state._question-number.at(label)
}


#let question(
  question-numbering: __examst-default,
  render-question-counter: __examst-default,
  render-name: __examst-default,
  render-points: __examst-default,
  points-position: __examst-default,
  points: (:),
  name: none,
  label: none,
  aggregate: false,
  inline: false,
  body,
) = context {
  // TODO: allow for customizing wrapper
  let _wrapper = if inline {
    box.with(width: 1fr)
  } else {
    block.with(inset: (left: 1em), width: 100%)
  }

  let _render-counter = arg-or-default(
    render-question-counter,
    "render-question-counter",
  )


  let _render-name = arg-or-default(
    render-name,
    "render-name",
  )

  let _render-name = if type(_render-name) == str {
    render-name-configs.at(_render-name)
  } else {
    _render-name
  }

  let _question-numbering = arg-or-default(
    question-numbering,
    "question-numbering",
  )

  let _render-pts = arg-or-default(
    render-points,
    "render-points",
  )
  // Resolve preset name to function
  let _render-pts = if type(_render-pts) == str {
    render-points-configs.at(_render-pts)
  } else {
    _render-pts
  }

  let _pts-position = arg-or-default(
    points-position,
    "points-position",
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
    state._question-depth.update(it => it + 1)

    context [
      #let depth = state._question-depth.get()
      #state._question-number.step(level: depth)
    ]

    _q-start(_points, label, _question-numbering)

    // Compute the rendered points content
    let _pts-content = context {
      let _points-end-label = if aggregate {
        _q-end-label()
      } else {
        if next-q-start-label() != none { next-q-start-label() } else {
          _q-end-label()
        }
      }
      let _pts = points-between(
        _q-start-label(),
        _points-end-label,
      )
      _render-pts(_pts)
    }

    let _counter-content = context [#_render-counter(state._question-number, _question-numbering)]
    let _depth = state._question-depth.get()

    let _name-content = context [#_render-name(name)]

    _pts-position(_pts-content, _counter-content, _name-content, body, _depth)

    _q-end(label)
    
    state._question-depth.update(it => it - 1)
  })
}
