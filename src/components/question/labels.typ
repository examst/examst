#import "@preview/oxifmt:1.0.0": strfmt
#import "../../state.typ" as state

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
  num: state._question-number.get().map(it => str(it)).join(".")
)

#let _q-start-label() = label(_q-start-label-text())

#let _q-end-label-text() = strfmt(
  "q-end:{num}",
  num: state._question-number
  .get()
  .slice(0, state._question-depth.get())
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
