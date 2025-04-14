extension Substring {
  var firstCapitalized: String {
    if let first {
      first.uppercased() + dropFirst()
    } else {
      ""
    }
  }
}
