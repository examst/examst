/// Configures behavior of examst. Should be used for overriding defaults if desired
/// ```example
/// examst-set(
///   show-answers: true,
/// )
/// ```
#let examst-set(
  /// Whether or not to print answers 
  /// -> bool
  show-answers: false,
) = {
  if args.pos().len() > 0 {
    panic("positional arguments are not allowed in examst configuration")
  }
  
  let pos = args.named()
}