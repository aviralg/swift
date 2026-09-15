// A diagnostic with no source location becomes a result with no locations.

// RUN: %empty-directory(%t)
// RUN: not %target-swift-frontend -typecheck -serialize-diagnostics=sarif -serialize-diagnostics-path %t/diags.sarif %t/nonexistent.swift
// RUN: %FileCheck --input-file=%t/diags.sarif %s

// Nothing was opened, so there are no artifacts.
// CHECK: "runs" : [
// CHECK-NOT: "artifacts"

// CHECK: "results" : [
// CHECK: "level" : "error"
// CHECK-NOT: "locations"
// CHECK: "message" : {
// CHECK-NEXT: "text" : "error opening input file
// CHECK: "ruleId" : "error_open_input_file"

// REQUIRES: swift_sarif
