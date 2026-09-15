// A file with no diagnostics still produces a log, as for serialized
// diagnostics, so that clients can tell a clean compile from one that never
// ran. The run has neither results nor artifacts.

// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -typecheck -serialize-diagnostics=sarif -serialize-diagnostics-path %t/diags.sarif %s
// RUN: %normalize_sarif %t/diags.sarif | %diff -U1 -b %S/Inputs/expected-sarif/sarif-diagnostics-empty.sarif -

// REQUIRES: swift_sarif

let x = 1
