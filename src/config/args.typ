/// Parses a type spec string into a structured dictionary.
/// - Plain type: `"str"` -> `(kind: "type", ty: str)`
/// - Literal refinement: `"str:inline"` -> `(kind: "literal", ty: str, value: "inline")`
#let parse-type-spec(spec-str) = {
  if type(spec-str) == str and spec-str.contains(":") {
    let idx = spec-str.position(":")
    let ty-str = spec-str.slice(0, idx)
    let literal = spec-str.slice(idx + 1)
    let ty = eval(ty-str, mode: "code")
    if ty == none { ty = type(none) }
    (kind: "literal", ty: ty, value: literal)
  } else {
    let ty = if type(spec-str) == str {
      eval(spec-str, mode: "code")
    } else {
      spec-str
    }
    if ty == none { ty = type(none) }
    (kind: "type", ty: ty)
  }
}

/// Checks if a value matches any of the parsed type specs.
/// Returns a closure (value, use) => bool.
/// - `specs`: array of parsed type spec dicts
/// - `allow-func`: if true, also accept function values at set time (not use time)
#let check-type(specs, allow-func) = {
  assert(
    type(specs) == array,
    message: "examst (internal): an argument's type specs must be specified as an array",
  )

  (value, use) => {
    for spec in specs {
      if spec.kind == "literal" {
        if type(value) == spec.ty and str(value) == spec.value {
          return true
        }
      } else {
        if type(value) == spec.ty {
          return true
        }
      }
    }
    if allow-func and (not use) and type(value) == function {
      return true
    }
    false
  }
}

/// Generates a human-readable string of allowed types for error messages.
/// Returns a closure (use) => str.
#let get-type-str(specs, allow-func) = {
  assert(
    type(specs) == array,
    message: "examst (internal): an argument's type specs must be specified as an array",
  )

  let parts = specs.map(spec => {
    if spec.kind == "literal" {
      "\"" + spec.value + "\" (" + str(spec.ty) + ")"
    } else {
      str(spec.ty)
    }
  })

  use => {
    if allow-func and (not use) {
      "one of: " + parts.join(", ") + ", or a function that returns one of the previous"
    } else {
      "one of: " + parts.join(", ")
    }
  }
}

/// Creates a typed state for a configuration argument.
/// Returns a dictionary with set-raw, get-raw, update, type-check, reset, and default.
#let typed-state(
  name,
  checker,
  type-str-fn,
  default,
  allow-func,
) = {
  let st = state("examst:" + name, default)

  (
    set-raw: value => {
      st.update(_ => value)
    },
    get-raw: () => {
      st.get()
    },
    update: value => {
      assert(
        checker(value, false),
        message: "examst: `" + name + "` must be " + type-str-fn(false) + ", found: " + repr(value),
      )
      st.update(_ => value)
    },
    type-check: value => {
      if allow-func and type(value) == function {
        value = value()
      }

      assert(
        checker(value, true),
        message: "examst: `" + name + "` must be " + type-str-fn(true) + ", found: " + repr(value),
      )

      value
    },
    reset: () => {
      st.update(_ => default)
    },
    default: default,
  )
}

/// Builds the argument dictionary from args.toml.
/// Each entry maps an argument name to its typed-state dictionary.
#let __examst-args = {
  let out = (:)
  let args = toml("args.toml")
  for (key, arg) in args {
    let specs = arg.types.map(parse-type-spec)

    let has-function-type = specs.any(s => s.kind == "type" and s.ty == function)
    if arg.function and has-function-type {
      panic("examst (internal): `function` is not a valid type for an argument")
    }

    out.insert(
      key,
      typed-state(
        key,
        check-type(specs, arg.function),
        get-type-str(specs, arg.function),
        eval(arg.default, mode: "code"),
        arg.function,
      ),
    )
  }

  out
}

/// Extracts defaults from all args as a flat dictionary.
#let __examst-defaults = {
  __examst-args.pairs().map(((key, value)) => (key, value.default)).to-dict()
}

/// Saves current state of all args. Must be called in a context.
#let __examst-save() = {
  let out = (:)
  for (key, value) in __examst-args {
    out.insert(key, (value.get-raw)())
  }
  return out
}

/// Restores previously saved state.
#let __examst-load(stored) = {
  for (key, value) in __examst-args {
    (value.set-raw)(stored.at(key))
  }
}

/// Opaque sentinel value — used as the default for function parameters so that
/// `none`, `auto`, etc. remain available as real user-facing values.
#let __examst-default = context [examst-default]

/// Returns the local override if provided (after type-checking it against the
/// same specs used by `examst-set`), otherwise the current global default.
#let arg-or-default(arg, key) = {
  if arg == __examst-default {
    (__examst-args.at(key).get-raw)()
  } else {
    (__examst-args.at(key).type-check)(arg)
  }
}
