// All examst-associated metadata takes the form:
// meta: (type: literal<T>, value: T)
//
// This file defines helpers for setting and reading examst metadata.
#import "@preview/oxifmt:1.0.0": strfmt

/* Internal label prefix */
#let _ilabel(label-str) = strfmt(
  "examst-internal:{label}",
  label: label-str,
)

// A map of internal types to validators for the value of those types
#let _validators = (
  "points": (value) => {
    type(value) == dictionary and value.values().fold(true, (acc, x) => {acc and (type(x) == int or type(x) == float)})
  },
  "question-label": (value) => {
    type(value) == content
  }
)
#let _get_validator(typ) = _validators.at(typ, default: (_) => panic("examst-internal: tried to validate invalid metadata type: " + str(typ)))

// calls `.at` on a dictionary with default: none
#let _at(dict, prop) = {dict.at(prop, default: none)}

// Validates the shape of a provided metadata.
// Optionally accepts a `typ` property. If set, also checks that the value matches that specific shape.
#let _validate-meta-shape(meta, typ: none) = {
  if typ == none {
    type(meta) == dictionary and meta.keys().len() == 2 and _get_validator(_at(meta, "type"))(_at(meta, "value"))
  } else {
    type(meta) == dictionary and meta.keys().len() == 2 and _at(meta, "type") == _ilabel(typ) and _get_validator(typ)(_at(meta, "value"))
  }
}

#let _set-meta(value, typ) = {
  if not _get_validator(typ)(value) {
    panic("examst-internal: attempted to set " + str(typ) + " meta with invalid value: " + str(value))
  }

  ( type: _ilabel(typ), value: value )
}

#let _get-value(meta, typ) = {
  if not _validate-meta-shape(meta, typ: typ) {
    panic("examst-internal: attmepted to read malformed " + str(typ) + " metadata", meta)
  }

  meta.value
}

#let _validate-points-meta(meta) = { _validate-meta-shape(meta, typ: "points")}
#let _set-points-meta(value) = { _set-meta(value, "points") }
#let _get-points-value(meta) = { _get-value(meta, "points")}

#let _validate-question-label-meta(meta) = { _validate-meta-shape(meta, typ: "question-label")}
#let _set-question-label-meta(value) = { _set-meta(value, "question-label") }
#let _get-question-label-value(meta) = { _get-value(meta, "question-label") }
