#import "@preview/mantys:1.0.2": *

#import "../src/lib.typ" as examst

#show: mantys(
  ..toml("../typst.toml"),
  title: [examst],
  subtitle: [Utilities for exam-writing in Typst],
  date: datetime.today().display(),
  abstract: [
    *examst* is a Typst package for creating professional exam documents. It
    provides numbered questions with automatic point tracking, multiple-choice
    answers, fill-in-the-blank lines, solution environments with configurable
    visibility, and summary points tables --- all with a flexible, data-driven
    configuration system.
  ],

  examples-scope: (
    scope: (examst: examst),
    imports: (examst: "*"),
  ),
)

// ══════════════════════════════════════════════════════════════════════
= Introduction

*examst* helps you write exams, quizzes, and homework assignments in Typst with
minimal boilerplate. Its main features include:

- *Numbered questions* with automatic counters and nestable sub-parts.
- *Point tracking* --- assign points per-question or per-category, aggregate
  across sub-parts, and render a summary table.
- *Multiple-choice* answers with several marker styles (bubbles, checkboxes,
  letters) and flexible layouts (vertical, grid, inline).
- *Fill-in-the-blank* lines with configurable width.
- *Solution environments* that can be shown or hidden globally --- including
  framed solutions, ruled answer spaces, and grid paper.
- *Global configuration* via `examst-set()` --- change rendering, positioning,
  marker styles, and more in one place.

// ══════════════════════════════════════════════════════════════════════
= Quick Start

Import the package and start writing questions:

#example[```
#examst-set(
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 { numbering("1.", last) }
    #if depth == 2 { numbering("(a)", last) }
  ],
)

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
```]

// ══════════════════════════════════════════════════════════════════════
= Configuration <config>

All global options are controlled through two functions: `examst-set` to update
options and `examst-reset` to restore defaults.

#command("examst-set", sarg[options])[
  Updates one or more global configuration options. Only the specified options
  are changed; all others retain their current values.

  Accepts the following named arguments:

  #argument("show-answers", types: (bool,), default: false)[
    Whether to display correct answers, solutions, and filled score cells.
  ]
  #argument("render-question-counter", types: (function,))[
    A function `(counter) => content` that formats the question number.
    Receives the `question-number` counter.
  ]
  #argument("render-points", types: (str, function), default: "parenthesized")[
    How points are formatted next to questions. Preset strings:
    `"parenthesized"`, `"bracketed"`, `"boxed"`. Or provide a custom
    `(points-dict) => content` function.
  ]
  #argument("points-position", types: (str, function), default: "inline")[
    Where points appear relative to the question. Presets:
    - `"inline"` --- after the counter, before the body
    - `"before-counter"` --- before the counter
    - `"after-body"` --- at the end of the question
    - `"left-margin"` / `"right-margin"` --- placed in the page margin
    - `"two-sided"` / `"two-sided-reversed"` --- alternates margins on odd/even pages

    Or a custom `(pts-content, counter-content, body, depth) => content` function.
  ]
  #argument("multi-choice-columns", types: (int, "none"), default: 1)[
    Default column count for multi-choice layouts.
    `1` = vertical list, `none` = inline/wrapping, `> 1` = grid.
  ]
  #argument("multi-choice-marker", types: (str, function), default: "bubble")[
    Default marker style. Presets: `"bubble"`, `"bubble-letter"`, `"checkbox"`,
    `"checkbox-letter"`, `"none"`. Or a custom function.
  ]
  #argument("multi-choice-label", types: (str,), default: "A")[
    Numbering pattern for choice labels (passed to `numbering()`).
  ]
  #argument("multi-choice-correct-emphasis", types: (function,))[
    Function applied to correct-answer text when `show-answers` is `true`.
  ]
  #argument("multi-choice-marker-font", types: (str, array, "none"), default: none)[
    Font for marker letters. `none` inherits the document font.
  ]
  #argument("solution-title", types: (content, "none"), default: [*Solution:* ])[
    Content prepended to printed solutions. Set to `none` to disable.
  ]
  #argument("solution-emphasis", types: (function,))[
    Function applied to solution body text when printed.
  ]
  #argument("solution-frame", types: (str, dictionary, function), default: "boxed")[
    How solutions are framed. Presets: `"boxed"`, `"shaded"`, `"none"`.
    Also accepts a dictionary of `block()` keys or a `(content) => content` function.
  ]
  #argument("solution-fill", types: (str, function), default: "lines")[
    Fill pattern for answer spaces. Presets: `"lines"`, `"grid"`, `"none"`.
    Or a `(height) => content` function.
  ]
  #argument("solution-height", types: (length,), default: 2in)[
    Default height for answer spaces.
  ]
  #argument("fill-in-width", types: ("auto", length, function), default: auto)[
    Width of fill-in-the-blank lines. `auto` measures the answer content.
  ]

  #example[```
  #examst-set(
    show-answers: true,
    render-points: "boxed",
    points-position: "left-margin",
  )
  ```]
]

#command("examst-reset")[
  Resets all configuration options to their defaults.

  #example[```
  #examst-reset()
  ```]
]

// ══════════════════════════════════════════════════════════════════════
= Questions <questions>

The `question` function is the core building block for exam content. Questions
are automatically numbered, track points, and support arbitrary nesting for
sub-parts.

#command("question", arg(points: (:)), arg(aggregate: false), arg(inline: false), arg(render-question-counter: none), arg(render-points: none), arg(points-position: none), barg[body])[
  Renders a numbered question with optional point assignment.

  #argument("points", types: (int, float, dictionary), default: (:))[
    Points for this question. A number is shorthand for `(points: n)`.
    A dictionary maps category names to values, e.g. `(points: 10, bonus: 3)`.
  ]
  #argument("aggregate", types: (bool,), default: false)[
    When `true`, points shown for this question are the *sum* of all nested
    sub-questions. When `false`, each sub-question displays its own points.
  ]
  #argument("inline", types: (bool,), default: false)[
    When `true`, renders the question inline (as a `box` with `width: 1fr`)
    instead of as a block-level element.
  ]
  #argument("render-question-counter", types: (function, "none"))[
    Local override for how this question's counter is displayed. Takes the
    counter and returns content.
  ]
  #argument("render-points", types: (str, function, "none"))[
    Local override for point formatting. Same options as the global setting.
  ]
  #argument("points-position", types: (str, function, "none"))[
    Local override for point positioning. Same options as the global setting.
  ]
  #argument("body", types: (content,))[
    The question text. May contain nested `#question()` calls for sub-parts,
    as well as any other examst components.
  ]
]

== Nested Questions (Sub-parts)

Questions can be nested to create lettered sub-parts:

#example[```
#examst-set(
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 { numbering("1.", last) }
    #if depth == 2 { numbering("(a)", last) }
  ],
)

#question(aggregate: false)[
  Thermodynamics
  #question(points: 6)[State the first law.]
  #question(points: 4)[State the second law.]
  #question(points: 5)[State the third law.]
]
```]

== Aggregated Points

Use `aggregate: true` on a parent question to display the *sum* of its
children's points at the parent level:

#example[```
#examst-set(
  render-question-counter: it => [
    #let depth = it.get().len()
    #let last = it.get().last()
    #if depth == 1 { numbering("1.", last) }
    #if depth == 2 { numbering("(a)", last) }
  ],
)

#question(points: 20, aggregate: true)[
  #question(inline: true)[Define the universe.]
  #question()[Give three examples.]
]
```]

== Points Positioning

Control where points appear relative to the question text:

#example[```
#examst-set(
  render-question-counter: it => numbering("1.", it.get().last()),
  points-position: "right-margin",
  render-points: "boxed",
)

#question(points: 10)[
  Explain why the sky is blue.
]
```]

// ══════════════════════════════════════════════════════════════════════
= Multiple Choice <multi-choice>

The `multi-choice` function renders answer options with configurable markers
and layouts.

#command("multi-choice", arg(columns: 1), arg(marker: "bubble"), arg(label: "A"), arg(marker-font: none), arg(correct-emphasis: none), arg(none-above: none), arg(choice-align: top), sarg[choices])[
  Renders a multiple-choice answer group.

  #argument("columns", types: (int, "none"), default: 1)[
    Column layout. `1` = vertical list, `none` = inline/wrapping, `> 1` = grid.
  ]
  #argument("marker", types: (str, function), default: "bubble")[
    Marker style preset or custom function. Presets: `"bubble"`,
    `"bubble-letter"`, `"checkbox"`, `"checkbox-letter"`, `"none"`.
  ]
  #argument("label", types: (str,), default: "A")[
    Numbering pattern for choice labels (e.g. `"A"`, `"a"`, `"1"`).
  ]
  #argument("marker-font", types: (str, array, "none"), default: none)[
    Font for marker letter content. `none` = inherit document font.
  ]
  #argument("correct-emphasis", types: (function, "none"))[
    Function applied to correct choice text when answers are shown.
  ]
  #argument("none-above", types: ("none", bool, "auto"), default: none)[
    Append a "None of the above" option. `auto` = if no other choice is marked
    correct, "None of the above" becomes the correct answer.
  ]
  #argument("choice-align", types: (alignment,), default: top)[
    Vertical alignment within each choice cell.
  ]
  #argument("choices", is-sink: true, types: (content, dictionary))[
    Positional arguments --- plain content, `#correct[...]`, or `#bad[...]`.
  ]
]

#command("select-one", sarg[args])[
  Alias for `multi-choice(marker: "bubble", ..)`. Use for single-select
  (radio-style) questions.
]

#command("select-many", sarg[args])[
  Alias for `multi-choice(marker: "checkbox", ..)`. Use for multi-select
  (checkbox-style) questions.
]

#command("correct", barg[body])[
  Marks a choice as the correct answer. When `show-answers` is `true`, the
  marker is filled and the text is emphasized.
]

#command("bad", barg[body])[
  Marks a choice as a "bad fill" example (e.g. "don't bubble like this").
  Overlays scribble marks on the marker.
]

== Basic Vertical Layout

#example[```
#question(points: 5)[
  What is the capital of France?
  #multi-choice(
    marker: "bubble-letter",
    [London],
    [Berlin],
    correct[Paris],
    [Madrid],
  )
]
```]

== Grid Layout

#example[```
#question(points: 5)[
  Which of these are prime numbers?
  #select-many(
    columns: 2,
    marker: "checkbox-letter",
    correct[7],
    [8],
    correct[11],
    [12],
  )
]
```]

== Inline Layout

#example[```
#question(points: 3)[
  Is the earth flat?
  #select-one(
    marker: "checkbox-letter",
    columns: none,
    [Yes],
    correct[No],
  )
]
```]

== None of the Above

#example[```
#question(points: 5)[
  Which of these animals can fly?
  #multi-choice(
    marker: "bubble-letter",
    none-above: auto,
    [Dog],
    [Cat],
    [Fish],
  )
]
```]

== Showing Answers

#example[```
#examst-set(show-answers: true)

#question(points: 5)[
  What is 2 + 2?
  #multi-choice(
    marker: "bubble-letter",
    [3],
    correct[4],
    [5],
    [6],
  )
]

#examst-reset()
```]

// ══════════════════════════════════════════════════════════════════════
= Fill-in-the-Blank <fill-in>

For short-answer questions where students write on a line.

#command("fill-in", arg[answer], arg(width: auto), arg(stroke: 0.5pt))[
  Renders an underlined blank. When `show-answers` is `true`, the answer text
  appears on the line; otherwise the line is empty.

  #argument("answer", types: (content,))[
    The correct answer (shown when answers are visible).
  ]
  #argument("width", types: ("auto", length), default: auto)[
    Width of the blank line. `auto` measures the answer content plus padding.
  ]
  #argument("stroke", types: (stroke,), default: 0.5pt)[
    The stroke style for the underline.
  ]
]

#example[```
The capital of France is #fill-in[Paris].
```]

#example[```
#examst-set(show-answers: true)
The capital of France is #fill-in[Paris].
#examst-reset()
```]

// ══════════════════════════════════════════════════════════════════════
= Solutions & Answer Spaces <solutions>

examst provides three levels of solution/answer-space functionality:

/ `solution`: Invisible when hidden, shows framed solution when visible.
/ `answer`: Fixed-height region --- fill pattern when hidden, solution when visible.
/ `answer-space`: Always-visible blank space (not tied to show/hide).

#command("solution", arg(title: none), arg(emphasis: none), arg(frame: none), barg[body])[
  Renders nothing when `show-answers` is `false`. When `true`, renders the
  solution inside a styled frame.

  #argument("title", types: (content, "none"))[
    Content prepended to the solution (e.g. `[*Solution:*]`).
    Defaults to the global `solution-title` setting.
  ]
  #argument("emphasis", types: (function, "none"))[
    Function applied to the solution body text.
  ]
  #argument("frame", types: (str, dictionary, function, "none"))[
    Framing style. Presets: `"boxed"`, `"shaded"`, `"none"`.
  ]
  #argument("body", types: (content,))[
    The solution content.
  ]
]

#example[```
#examst-set(show-answers: true)

#question(points: 5)[
  Why is the sky blue?
  #solution[
    Rayleigh scattering of sunlight by atmospheric molecules.
  ]
]

#examst-reset()
```]

#command("answer", arg(height: none), arg(fill: none), arg(frame: none), arg(title: none), arg(emphasis: none), arg(sol-height: none), barg[body])[
  Renders a fixed-height answer region. When `show-answers` is `false`, displays
  the fill pattern inside a frame. When `true`, displays the solution content.

  Layout is stable between modes --- the space on the page is consistent whether
  or not answers are shown.

  #argument("height", types: (length,))[
    Height of the answer region. Defaults to global `solution-height`.
  ]
  #argument("fill", types: (str, function))[
    Fill pattern. Presets: `"lines"`, `"grid"`, `"none"`.
    Or a `(height) => content` function like `fill-lines.with(spacing: 0.5in)`.
  ]
  #argument("frame", types: (str, dictionary, function))[
    Framing style for the region.
  ]
  #argument("title", types: (content, "none"))[
    Content prepended to the solution when shown.
  ]
  #argument("emphasis", types: (function, "none"))[
    Function applied to the solution body.
  ]
  #argument("sol-height", types: ("none", "auto", length), default: none)[
    Height of the solution frame when shown. `none` matches the fill height.
    `auto` sizes to content.
  ]
  #argument("body", types: (content,))[
    The solution/answer content.
  ]
]

== Answer with Default Lines

#example[```
#question(points: 10)[
  Explain the water cycle.
  #answer[
    Evaporation, condensation, precipitation, collection.
  ]
]
```]

== Answer with Grid Fill

#example[```
#question(points: 10)[
  Draw a diagram of a cell.
  #answer(
    fill: fill-grid.with(spacing: 0.4in),
    frame: (stroke: 0.5pt),
    height: 2in,
  )[
    A labeled diagram of an animal cell.
  ]
]
```]

== Answer with Blank Box (No Fill)

#example[```
#question(points: 5)[
  Write your name.
  #answer(
    fill: v,
    frame: (stroke: 0.5pt, width: 100%, inset: 8pt),
    height: 1in,
  )[
    Andrew
  ]
]
```]

#command("answer-space", arg(height: none), arg(fill: none), arg(frame: "none"))[
  Renders an always-visible answer space. Not tied to the `show-answers` toggle
  --- renders unconditionally. Useful for scratch work areas.

  #argument("height", types: (length,))[
    Height of the space. Defaults to global `solution-height`.
  ]
  #argument("fill", types: (str, function))[
    Fill pattern. Same options as `answer`.
  ]
  #argument("frame", types: (str, dictionary, function), default: "none")[
    Framing style. Defaults to no border.
  ]
]

#example[```
#answer-space()
```]

#example[```
#answer-space(fill: fill-grid.with(spacing: 0.45in), height: 1in)
```]

#example[```
#answer-space(fill: "none", frame: "boxed")
```]

== Fill Pattern Helpers

These functions can be used directly or passed as the `fill` argument:

#command("fill-lines", arg[height], arg(spacing: 0.33in), arg(stroke: 0.5pt))[
  Fills vertical space with ruled horizontal lines.

  #argument("height", types: (length,))[Height of the space to fill.]
  #argument("spacing", types: (length,), default: 0.33in)[Distance between lines.]
  #argument("stroke", types: (stroke,), default: 0.5pt)[Line stroke style.]
]

#command("fill-grid", arg[height], arg(spacing: 5mm), arg(stroke: 0.5pt))[
  Fills vertical space with a grid of squares. Cell size is adjusted so columns
  divide the available width evenly.

  #argument("height", types: (length,))[Height of the space to fill.]
  #argument("spacing", types: (length,), default: 5mm)[Approximate cell size.]
  #argument("stroke", types: (stroke,), default: 0.5pt)[Grid line stroke style.]
]

// ══════════════════════════════════════════════════════════════════════
= Points Table <points-table>

The `points-table` function generates a summary table of all (or selected)
questions and their point values. It supports vertical and horizontal
orientations, multi-category points, sub-question expansion, and overflow
splitting.

#command("points-table", arg(orientation: "vertical"), arg(columns: auto), arg(score: false), arg(fill-scores: false), arg(total: auto), arg(depth: 1), arg(questions: auto), arg(group-by-parent: false), arg(max-per-group: none), arg(labels: (:)), arg(render: auto))[
  Renders a summary table of exam points.

  #argument("orientation", types: (str,), default: "vertical")[
    `"vertical"` = questions as rows; `"horizontal"` = questions as columns.
  ]
  #argument("columns", types: ("auto", array), default: auto)[
    Which columns to show. `auto` detects point categories and includes
    `"question"` + all detected categories. Built-in ids: `"question"`,
    `"score"`, and any point-category key.
  ]
  #argument("score", types: (bool,), default: false)[
    Append a blank "Score" column for hand-grading.
  ]
  #argument("fill-scores", types: (bool,), default: false)[
    When `true` and `show-answers` is on, fill score cells with max points.
  ]
  #argument("total", types: ("auto", int, float, dictionary), default: auto)[
    Override the total row. `auto` = computed sum. A number overrides the
    primary category. A dictionary overrides per-category.
  ]
  #argument("depth", types: (int,), default: 1)[
    How many levels of hierarchy to show. `1` = top-level only.
    `2` = expand sub-parts.
  ]
  #argument("questions", types: ("auto", array), default: auto)[
    Filter to specific question numbers. Integers or strings;
    prefix-matched (e.g. `(1,)` includes `"1.1"`, `"1.2"` at deeper depths).
  ]
  #argument("group-by-parent", types: (bool,), default: false)[
    When `depth > 1`, show parent questions as header rows with children
    indented beneath.
  ]
  #argument("max-per-group", types: ("none", int), default: none)[
    Auto-split into sub-tables when exceeding this many questions.
    Vertical splits side-by-side; horizontal stacks vertically.
  ]
  #argument("labels", types: (dictionary,), default: (:))[
    Override display labels. Keys: `"question"`, `"score"`, `"total"`, or
    any category name.
  ]
  #argument("render", types: ("auto", function), default: auto)[
    Custom renderer. Receives a dictionary with keys `rows`, `columns`,
    `categories`, `totals`. Returns content.
  ]
]

== Basic Usage

The simplest usage --- just call `points-table()` after defining your questions:

```typ
#align(center, points-table())
```

== Horizontal Layout

```typ
#align(center, points-table(orientation: "horizontal"))
```

== With Score Column

```typ
#align(center, points-table(score: true))
```

== Expanding Sub-parts

```typ
// Show sub-questions at depth 2, grouped under their parent
#align(center, points-table(depth: 2, group-by-parent: true))
```

== Custom Labels (Localization)

```typ
#align(center, points-table(
  score: true,
  labels: (
    question: "Aufgabe",
    points: "Punkte",
    score: "Note",
    total: "Summe",
  ),
))
```

== Overflow Splitting

For exams with many questions, split the table into manageable groups:

```typ
// Vertical: splits side-by-side
#align(center, points-table(max-per-group: 5))

// Horizontal: stacks vertically
#align(center, points-table(
  orientation: "horizontal",
  max-per-group: 5,
))
```

== Multi-category Points

When questions use dictionary points (e.g. `(points: 10, bonus: 3)`), the
table automatically detects all categories and adds a column for each:

```typ
#question(points: (points: 10, bonus: 3))[
  Extra credit question.
]

#align(center, points-table())
```
