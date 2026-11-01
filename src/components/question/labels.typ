#import "@preview/oxifmt:1.0.0": strfmt
#import "../../state.typ" as state
#import "meta.typ": _ilabel, _set-points-meta, _get-points-value, _set-question-label-meta
// Label Utilities

/* Join text for label names */
#let _join-text(left-str, right-str) = strfmt(
  "{left}:{right}",
  left: left-str,
  right: right-str
)

/* Emits a label attached to metadata.*/
#let _emit-label(label-arg, meta: none) = {
  let label-str = ""
  let label-ref = none

  if type(label-arg) == label {
    label-str = str(label-arg)
    label-ref = label-arg
  } else if type(label-arg) == str {
    label-str = label-arg
    label-ref = label(label-arg)
  } else {
    panic("examst-internal: tried to emit an object of type " + str(type(label-arg)) +": " + str(label-arg))
  }

  [
    #if meta != none {metadata(meta)} else {metadata(label-str)}
    #label-ref
  ]
}

// Points labels

#let _points-label = label(_ilabel("points"))

#let points-between(start-label, end-label) = (
  query(
    selector(_points-label).after(start-label).before(end-label),
  )
    .map(it => _get-points-value(it.value))
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


// Question Number Labels

#let _q-num-text() = {
  let numbers = state._question-number.get();
  let end-depth = state._question-depth.get()

  numbers.slice(0, end-depth).map(it => str(it)).join(".")
}

#let _q-start-label() = label(
  _ilabel(_join-text("q-start", _q-num-text()))
)

#let _q-end-label() = label(
  _ilabel(_join-text("q-end", _q-num-text()))
)

#let next-q-start-label() = {
  let labels = query(selector(metadata).after(here()))
    .filter(it => {
      (type(it.value) == str) and (it.value.starts-with(_ilabel("q-start")))
    })
  if labels.len() > 0 {
    return labels.first().label
  } else {
    return none
  }
}

#let _q-start(points, label-str, render-ctr) = {
  context [
    #_emit-label(_q-start-label())
    #if label-str != none {
      _emit-label(label-str, meta: _set-question-label-meta([#render-ctr(state._question-number)]))
      _emit-label(_join-text(label-str, "start"))
    }

    #_emit-label(_points-label, meta: _set-points-meta(points))
  ]
}

#let _q-end(label-str) = {
  context [
    #_emit-label(_q-end-label())
    #if label-str != none {
      _emit-label(_join-text(label-str, "end"))
    }
  ]
}
