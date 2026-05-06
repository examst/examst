/// Points table component — summary tables of exam points.
///
/// Public API:
/// - `points-table`: renders a summary table showing points per question.

#import "../state.typ" as state
#import "../config/args.typ": __examst-args
#import "question/labels.typ": points-between

// ── Query infrastructure ───────────────────────────────────────────

/// Collect all questions whose number string has exactly `target-depth`
/// components (e.g. depth 1 → "1", "2"; depth 2 → "1.1", "2.3").
/// Returns array of (number: str, points: dict, depth: int).
#let _collect-at-depth(target-depth) = {
  let all-starts = query(selector(metadata))
    .filter(it => type(it.value) == str and it.value.starts-with("q-start:"))

  all-starts
    .filter(it => {
      let num = it.value.slice("q-start:".len())
      num.split(".").len() == target-depth
    })
    .map(it => {
      let num = it.value.slice("q-start:".len())
      let pts = points-between(label("q-start:" + num), label("q-end:" + num))
      (number: num, points: pts, depth: target-depth)
    })
}

/// Detect all unique point-category keys across a set of questions.
#let _detect-categories(questions) = {
  let cats = ()
  for q in questions {
    for key in q.points.keys() {
      if key not in cats { cats.push(key) }
    }
  }
  cats
}

// ── Column resolution ──────────────────────────────────────────────

/// Resolve the `columns` parameter into a concrete array of column ids.
#let _resolve-columns(columns, categories, score) = {
  if columns == auto {
    let cols = ("question",) + categories
    if score { cols.push("score") }
    cols
  } else {
    columns
  }
}

// ── Label helpers ──────────────────────────────────────────────────

#let _default-labels = (
  question: "Question",
  score: "Score",
  total: "Total",
)

/// Resolve the display label for a column.
#let _resolve-label(col, user-labels) = {
  if col in user-labels { user-labels.at(col) }
  else if col in _default-labels { _default-labels.at(col) }
  else { upper(col.first()) + col.slice(1) } // capitalize
}

// ── Total computation ──────────────────────────────────────────────

/// Compute per-category totals, then apply any user overrides.
#let _compute-totals(questions, categories, total-override) = {
  let computed = (:)
  for cat in categories {
    computed.insert(
      cat,
      questions.map(q => q.points.at(cat, default: 0)).sum(default: 0),
    )
  }

  if total-override != auto {
    if type(total-override) == int or type(total-override) == float {
      // Single number → override the first (or only) category
      if categories.len() > 0 {
        computed.insert(categories.first(), total-override)
      }
    } else if type(total-override) == dictionary {
      for (k, v) in total-override {
        if v != auto { computed.insert(k, v) }
      }
    }
  }

  computed
}

// ── Row descriptors ────────────────────────────────────────────────
// A uniform representation so renderers don't need to care about
// grouping logic.  Each row is a dict:
//   (number: str, points: dict, kind: "regular"|"parent"|"child")

/// Build a flat list of row descriptors for the table body.
/// `depth` is the maximum depth to expand to — questions without children
/// at that level still appear as leaves.
#let _build-rows(depth, group-by-parent, questions-filter) = {
  if depth <= 1 {
    // Simple case: just top-level questions
    let qs = _collect-at-depth(1)
    if questions-filter != auto {
      let filters = questions-filter.map(q => str(q))
      qs = qs.filter(q => {
        filters.any(f => q.number == f or q.number.starts-with(f + "."))
      })
    }
    return qs.map(q => (..q, kind: "regular"))
  }

  // depth > 1: collect top-level questions, then expand those with children
  let top = _collect-at-depth(1)
  let children-at-depth = _collect-at-depth(depth)

  if questions-filter != auto {
    let filters = questions-filter.map(q => str(q))
    top = top.filter(q => {
      filters.any(f => q.number == f or q.number.starts-with(f + "."))
    })
    children-at-depth = children-at-depth.filter(q => {
      filters.any(f => q.number == f or q.number.starts-with(f + "."))
    })
  }

  let rows = ()
  for parent in top {
    let prefix = parent.number + "."
    let children = children-at-depth.filter(q => q.number.starts-with(prefix))

    // Don't expand if children have no points of their own (aggregate parent)
    let children-have-points = children.any(q => q.points.values().sum(default: 0) > 0)

    if children.len() == 0 or not children-have-points {
      // Leaf question — no expandable subparts
      rows.push((..parent, kind: "regular"))
    } else if group-by-parent {
      // Show parent as a header row, then children
      rows.push((..parent, kind: "parent"))
      for child in children {
        rows.push((..child, kind: "child"))
      }
    } else {
      // Flat: just show the children (expanded)
      for child in children {
        rows.push((..child, kind: "regular"))
      }
    }
  }
  rows
}

// TODO: future — add config option for parent row display in group-by-parent
// (e.g. show aggregated points, em-dash, or blank)

// ── Vertical renderer ──────────────────────────────────────────────

#let _render-vertical(rows, columns, categories, labels, totals, fill-scores, show-answers) = {
  let n-cols = columns.len()

  // Header cells
  let header-cells = columns.map(col =>
    table.cell(/*fill: luma(230)*/)[*#_resolve-label(col, labels)*]
  )

  // Data cells
  let data-cells = ()
  for row in rows {
    for col in columns {
      if col == "question" {
        let display = row.number
        let cell = if row.kind == "child" {
          // Indent children
          table.cell(align: left)[#h(1em)#display]
        } else if row.kind == "parent" {
          table.cell(align: left)[*#display*]
        } else {
          table.cell(align: left)[#display]
        }
        data-cells.push(cell)
      } else if col == "score" {
        let content = if row.kind == "parent" {
          [\u{2014}]
        } else if fill-scores and show-answers {
          let total = row.points.values().sum(default: 0)
          [#total]
        }
        data-cells.push(table.cell(content))
      } else {
        // Point category column
        if row.kind == "parent" {
          data-cells.push(table.cell[\u{2014}])
        } else {
          let val = row.points.at(col, default: 0)
          data-cells.push(table.cell[#val])
        }
      }
    }
  }

  // Total row (omitted when totals is none)
  let total-cells = if totals != none {
    columns.map(col => {
      if col == "question" {
        table.cell(align: left)[*#_resolve-label("total", labels)*]
      } else if col == "score" {
        table.cell[]
      } else {
        let val = totals.at(col, default: 0)
        table.cell[*#val*]
      }
    })
  }

  if totals != none {
    table(
      columns: n-cols,
      align: center + horizon,
      stroke: 0.5pt,
      ..header-cells,
      ..data-cells,
      table.hline(stroke: 1pt),
      ..total-cells,
    )
  } else {
    table(
      columns: n-cols,
      align: center + horizon,
      stroke: 0.5pt,
      ..header-cells,
      ..data-cells,
    )
  }
}

// ── Horizontal renderer ────────────────────────────────────────────

#let _render-horizontal(rows, columns, categories, labels, totals, fill-scores, show-answers) = {
  // Each config "column" becomes a table row; each question becomes a table column.
  let has-total = totals != none
  let n-table-cols = rows.len() + 1 + if has-total { 1 } else { 0 }

  let all-cells = ()
  for col in columns {
    // Row header
    all-cells.push(table.cell(/*fill: luma(230)*/)[*#_resolve-label(col, labels)*])

    // Per-question cells
    for row in rows {
      if col == "question" {
        all-cells.push(table.cell[#row.number])
      } else if col == "score" {
        let content = if row.kind == "parent" {
          [\u{2014}]
        } else if fill-scores and show-answers {
          let total = row.points.values().sum(default: 0)
          [#total]
        }
        all-cells.push(table.cell(content))
      } else {
        if row.kind == "parent" {
          all-cells.push(table.cell[\u{2014}])
        } else {
          let val = row.points.at(col, default: 0)
          all-cells.push(table.cell[#val])
        }
      }
    }

    // Total cell (only if totals provided)
    if has-total {
      if col == "question" {
        all-cells.push(table.cell(/*fill: luma(230)*/)[*#_resolve-label("total", labels)*])
      } else if col == "score" {
        all-cells.push(table.cell[])
      } else {
        let val = totals.at(col, default: 0)
        all-cells.push(table.cell[*#val*])
      }
    }
  }

  table(
    columns: n-table-cols,
    align: center + horizon,
    stroke: 0.5pt,
    ..all-cells,
  )
}

// ── Overflow splitting ─────────────────────────────────────────────

/// Split rows into groups of at most `n` items.
#let _split-rows(rows, max-per-group) = {
  if max-per-group == none { return (rows,) }
  let groups = ()
  let i = 0
  while i < rows.len() {
    let end = calc.min(i + max-per-group, rows.len())
    groups.push(rows.slice(i, end))
    i = end
  }
  groups
}

// ── Public API ─────────────────────────────────────────────────────

/// Renders a summary table showing points per question.
///
/// ```example
/// #points-table()
/// #points-table(orientation: "horizontal", score: true)
/// ```
///
/// - `orientation` ("vertical" | "horizontal"): Table layout direction.
/// - `columns` (auto | array): Column specifiers. `auto` detects point categories.
///   Built-in ids: `"question"`, `"score"`, and any point-category key
///   (e.g. `"points"`, `"bonus"`).
/// - `score` (bool): Append a blank "Score" column for hand-grading.
/// - `fill-scores` (bool): When `true` and `show-answers` is on, fill score cells
///   with max points instead of leaving them blank.
/// - `total` (auto | number | dictionary): Override the total row values.
///   `auto` = computed sum. A single number overrides the primary category.
///   A dictionary overrides per-category: `(points: 60, bonus: 20)`.
/// - `depth` (int): How many levels of question hierarchy to show.
///   `1` = top-level only (subparts aggregated). `2` = include subparts. Etc.
/// - `questions` (auto | array): Filter to specific question numbers.
///   Integers or strings; prefix-matched (e.g. `(1,)` includes `"1.1"`, `"1.2"` at deeper depths).
/// - `group-by-parent` (bool): When `depth > 1`, show parent questions as
///   header rows with children indented beneath.
/// - `max-per-group` (none | int): Auto-split into sub-tables when exceeding
///   this many items. Vertical splits side-by-side; horizontal stacks vertically.
/// - `labels` (dictionary): Override display labels.
///   Keys: `"question"`, `"score"`, `"total"`, or any category name.
/// - `render` (auto | function): Custom renderer. Receives a dictionary with
///   keys `rows`, `columns`, `categories`, `totals`. Returns content.
#let points-table(
  orientation: "vertical",
  columns: auto,
  score: false,
  fill-scores: false,
  total: auto,
  depth: 1,
  questions: auto,
  range: none,
  group-by-parent: false,
  max-per-group: none,
  labels: (:),
  render: auto,
) = context {
  // 1. Build row descriptors (handles depth, grouping, filtering)
  let rows = _build-rows(depth, group-by-parent, questions)

  // 2. Detect point categories and resolve columns
  let categories = _detect-categories(rows)
  let cols = _resolve-columns(columns, categories, score)

  // 3. Compute totals
  // For grouped tables, only count leaf (non-parent) rows to avoid double-counting
  let leaf-rows = rows.filter(r => r.kind != "parent")
  let totals = _compute-totals(leaf-rows, categories, total)

  // 4. Get show-answers state
  let show-ans = (__examst-args.at("show-answers").get-raw)()

  // 5. Custom renderer escape hatch
  if render != auto {
    return render((
      rows: rows,
      columns: cols,
      categories: categories,
      totals: totals,
    ))
  }

  // 6. Choose built-in renderer
  let renderer = if orientation == "vertical" {
    _render-vertical
  } else {
    _render-horizontal
  }

  // 7. Handle overflow splitting
  let groups = _split-rows(rows, max-per-group)

  let tables = groups.enumerate().map(((i, group)) => {
    // Only the last group shows the overall total; intermediate groups have no total row
    let group-totals = if groups.len() > 1 and i < groups.len() - 1 {
      none
    } else {
      totals
    }
    renderer(group, cols, categories, labels, group-totals, fill-scores, show-ans)
  })

  if tables.len() == 1 {
    tables.first()
  } else if orientation == "vertical" {
    // Side-by-side sub-tables
    grid(columns: tables.len(), column-gutter: 1em, ..tables)
  } else {
    // Stacked sub-tables
    stack(dir: ttb, spacing: 1em, ..tables)
  }
}
