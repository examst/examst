/// Checks if a value's type is in the allowed types list.
/// Returns a closure (value-type, use) => bool.
#let check-type(tys, allow-func) = {
  assert(
    type(tys) == array,
    message: "examst (internal): an argument's type must be specified as an array",
  )

  (value-ty, use) => {
    value-ty in tys or (allow-func and (not use) and value-ty == function)
  }
}

/// Generates a human-readable string of allowed types for error messages.
/// Returns a closure (use) => str.
#let get-type-str(tys, allow-func) = {
  assert(
    type(tys) == array,
    message: "examst (internal): an argument's type must be specified as an array",
  )

  (use) => {
    if allow-func and (not use) {
      "either a " + tys.map(str).join(", a ") + ", or a function that returns one of the previous types"
    } else {
      "either a " + tys.map(str).join(", a ", last: ", or a ")
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
    set-raw: (value) => {
      st.update((_) => value)
    },
    get-raw: () => {
      st.get()
    },
    update: (value) => {
      assert(
        checker(type(value), false),
        message: "examst: `" + name + "` must be " + type-str-fn(false) + ", found: " + str(type(value)),
      )
      st.update((_) => value)
    },
    type-check: (value) => {
      if allow-func and type(value) == function {
        value = value()
      }

      assert(
        checker(type(value), true),
        message: "examst: `" + name + "` must be " + type-str-fn(true) + ", found: " + str(type(value)),
      )

      value
    },
    reset: () => {
      st.update((_) => default)
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
    let tys = arg.types.map(t => {
      let t = eval(t, mode: "code")
      if t == none {
        type(none)
      } else {
        t
      }
    })

    if arg.function and function in tys {
      panic("examst (internal): `function` is not a valid type for an argument")
    }

    out.insert(
      key,
      typed-state(
        key,
        check-type(tys, arg.function),
        get-type-str(tys, arg.function),
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
