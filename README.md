# examst

A [Typst](https://typst.app) package for writing exams. Provides hierarchical questions with automatic numbering and point tracking, multiple-choice inputs, fill-in-the-blank fields, solution/answer spaces, and points summary tables — all with a single `#import`.

> **Status:** v0.0.1 — API is still evolving.

## Quick start

```typst
#import "@local/examst:0.0.1": *

#set page(paper: "us-letter")

#question(points: 10)[
  Why is there air?
]

#question(aggregate: false)[
  What if there were no air?
  #question(points: 5)[
    Describe the effect on the balloon industry.
  ]
  #question(points: 5)[
    Describe the effect on the aircraft industry.
  ]
]
```

## Features

### Questions

Nest `#question()` calls to create hierarchical question structures. Points can be integers or multi-category dictionaries (e.g., `(points: 10, bonus: 5)`). Use `aggregate: true` to roll child points into the parent.

```typst
#question(points: 20, aggregate: true)[
  #question(inline: true)[
    Define the universe. Give three examples.
  ]
  #question()[
    If the universe were to end, how would you know?
  ]
]
```

### Points positioning

Control where point values appear relative to the question text:

```typst
#examst-set(points-position: "right-margin")
#examst-set(points-position: "left-margin")
#examst-set(points-position: "before-counter")
#examst-set(points-position: "after-body")
#examst-set(points-position: "two-sided") // alternates margins for duplex printing
```

### Points rendering

Choose how point values are formatted:

```typst
#examst-set(render-points: "parenthesized") // (10 points)
#examst-set(render-points: "bracketed")     // [10 points]
#examst-set(render-points: "boxed")         // boxed variant
```

### Multiple choice

```typst
#question(points: 5)[
  What is the capital of France?
  #multi-choice(
    [London],
    [Berlin],
    correct[Paris],
    [Madrid],
  )
]
```

Marker presets: `"bubble"`, `"bubble-letter"`, `"checkbox"`, `"checkbox-letter"`, `"none"`.

Layout options: single column (default), multi-column grid, or inline flow via `columns`.

Convenience aliases: `#select-one()` (bubble markers) and `#select-many()` (checkbox markers).

### Fill-in-the-blank

```typst
The answer is #fill-in("42").
```

### Solutions and answer spaces

```typst
// Only visible when show-answers is true
#solution[
  Rayleigh scattering of sunlight by atmospheric molecules.
]

// Fixed-height answer region — shows fill pattern when hidden, solution when shown
#answer[
  Evaporation, condensation, precipitation, collection.
]

// Standalone answer space (always visible, not tied to show/hide)
#answer-space()
#answer-space(fill: fill-grid.with(spacing: 0.4in), height: 3in)
```

Fill presets: `"lines"`, `"grid"`, `"none"`. Frame presets: `"boxed"`, `"shaded"`, `"none"`.

### Points table

Generate a summary table of all questions and their point values:

```typst
#points-table()                                     // vertical, auto-detected columns
#points-table(orientation: "horizontal")             // horizontal layout
#points-table(depth: 2, group-by-parent: true)       // show subparts grouped under parents
#points-table(score: true)                           // add blank score column for grading
#points-table(max-per-group: 5)                      // auto-split into sub-tables on overflow
```

## Configuration

Use `#examst-set()` to configure behavior globally and `#examst-reset()` to restore defaults:

```typst
#examst-set(
  render-question-counter: counter => numbering("1.", counter.get().last()),
  render-points: "bracketed",
  points-position: "right-margin",
  show-answers: true,
)

// ... questions ...

#examst-reset()
```

## Project structure

```
src/
├── lib.typ              # Package entrypoint
├── state.typ            # Global state (counters, depth)
├── config/
│   ├── exam.typ         # Public API: examst-set(), examst-reset()
│   └── args.typ         # Type-safe configuration system
└── components/
    ├── question.typ     # Hierarchical questions
    ├── multi-choice.typ # Multiple-choice inputs
    ├── fill-in.typ      # Fill-in-the-blank fields
    ├── solution.typ     # Solutions and answer spaces
    └── points-table.typ # Points summary tables
example/                 # Usage examples
docs/                    # Documentation
```

## Development

### Prerequisites

The dev shell is provided via Nix:

```sh
nix develop
```

This gives you `typst`, `typstyle` (formatter), and `tinymist` (LSP).

### Building the example

```sh
typst compile example/main.typ
```

## License

MIT
