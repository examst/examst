/// Displays the number attached to a question
/// e.g. Q1.2.3.4
#let question-number = counter("question-depth")

/// Tracks the depth of nested questions (subparts)
#let question-depth = state("question-depth", 0)

/// Tracks the structure of an exam, structured as a list of dictionaries that follow the below schema:
/// (
///   points:   int | float
///   children: array (of dictionaries)
/// )
#let questions = state("questions", ())

/// Tracks rendering functions for displaying certain components of the exam
#let render = state("render", (:))
