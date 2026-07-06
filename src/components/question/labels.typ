#import "@preview/oxifmt:1.0.0": strfmt
#import "../../state.typ" as state

#let next-q-start-label() = {
  let labels = query(selector(metadata).after(here()))
    .filter(it => {
      (type(it.value) == str) and (it.value.starts-with("q-start"))
    })
  if labels.len() > 0 {
    return labels.first().label
  } else {
    return none
  }
}

#let _q-num-text() = {
  let numbers = state._question-number.get();
  let end-depth = state._question-depth.get()

  numbers.slice(0, end-depth).map(it => str(it)).join(".")
}

#let _label-text(left-str, right-str) = strfmt(
  "{left}:{right}",
  left: left-str,
  right: right-str
)

#let _q-start-label() = label(_label-text("q-start", _q-num-text()))
#let _q-end-label() = label(_label-text("q-end", _q-num-text()))

#let _emit-label(label-str, meta: none) = [
  #if meta != none {metadata(meta)} else {metadata(label-str)}
  #label(label-str)
]

#let _q-start(points, label-str, render-ctr) = {
  context [
    #_emit-label(_label-text("q-start", _q-num-text()))
    #if label-str != none {
      _emit-label(label-str, meta: render-ctr(state._question-number))
      _emit-label(_label-text(label-str, "start"))
    }

    #_emit-label("points", meta: points)
  ]
}

#let _q-end(label-str) = {
  context [
    #_emit-label(_label-text("q-end", _q-num-text()))
    #if label-str != none {
      _emit-label(_label-text(label-str, "end"))
    }
  ]
}


#let points-between(start-label, end-label) = (
  query(
    selector(<points>).after(start-label).before(end-label),
  )
    .map(it => it.value)
    .fold(
      (:),
      (acc, curr) => {
        for (k, v) in curr {
          acc.insert(
            k,
            acc.at(k, default: 0) + v,
          )
        }
        return acc
      },
    )
)
