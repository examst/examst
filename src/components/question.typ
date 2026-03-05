#import "@preview/oxifmt:1.0.0": strfmt
#import "../state.typ" as state

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
  num: state.question-number.get().map(it => str(it)).join(".")
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

#let question(
  // TODO: consider if this is good semantics
  render-question-counter: none,
  points: (:), 
  aggregate: false, 
  inline: false, 
  body
) = context {
  let wrapper = if inline { 
    it => { h(1em); box(it) } 
  } else { 
    block.with(inset: (left: 1em)) 
  }
  
  let _render-counter =  if render-question-counter == none {
    state.render.get().render-question-counter
  } else {
    render-question-counter
  }
  
  wrapper({
    state.question-depth.update(it => it + 1)

    context [
      #state.question-number.step(level: state.question-depth.get())
    ]

    _q-start(points)

    [
      #context[
        #let _points-end-label = if aggregate {
          _q-end-label()
        } else {
          if next-q-start-label() != none { next-q-start-label() } else { _q-end-label() }
        }
        #_render-counter(state.question-number)
        #let point-texts = points-between(
          _q-start-label(),
          _points-end-label,
        ).pairs().map(((k, v)) => [#v #k])
        #if point-texts.len() > 0 [
          (#point-texts.join(", "))
        ]
      ] 
      #body
    ]

    _q-end()

    context[
      #state.question-depth.update(it => it - 1)
    ]
  })
}
