/// Operator to manipulate a `MediaTree`.
///
/// A `Pass` takes a `MediaTree` as input and outputs a new one. It represents
/// a single step of a tree transformation. Passes are combined into larger
/// operations recursively:
/// * A pass can invoke itself on sub-trees.
/// * A pass can invoke a chain of sub-passes on the tree.
public protocol Pass {
}


/// A special pass that receives no input.
public protocol ImportPass: Pass {}

/// A special pass that generates no output other than side effects.
public protocol ExportPass: Pass {}
