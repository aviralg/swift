// Check the shape of a SARIF log: the tool description, one artifact per source
// file, a rule per distinct diagnostic, and a result per diagnostic.

// RUN: %empty-directory(%t)
// RUN: not %target-swift-frontend -typecheck -serialize-diagnostics=sarif -serialize-diagnostics-path %t/diags.sarif %s
// RUN: %normalize_sarif %t/diags.sarif | %diff -U1 -b %S/Inputs/expected-sarif/sarif-diagnostics.sarif -

// REQUIRES: swift_sarif

// An error, the note attached to it, and an unrelated warning. The note is a
// result of its own for now, rather than a related location of the error.
struct Point { var x: Int; var y: Int }
let p = Point()
func f() { let unused = 1 }
