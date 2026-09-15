// A diagnostic raised without a source location, such as a failure to open an
// input file, is recorded as a result with no locations. The binary format
// records these, and dropping them would let a failed compilation produce a log
// that looks clean.

// RUN: %empty-directory(%t)
// RUN: not %target-swift-frontend -typecheck -serialize-diagnostics=sarif -serialize-diagnostics-path %t/diags.sarif %t/nonexistent.swift
// RUN: %FileCheck --input-file=%t/diags.sarif %s

// Nothing was opened, so the run has no artifacts.
// CHECK: "runs" : [
// CHECK-NOT: "artifacts"

// CHECK: "results" : [
// CHECK: "level" : "error"
// The result carries the message but no locations.
// CHECK-NOT: "locations"
// CHECK: "message" : {
// CHECK-NEXT: "text" : "error opening input file
// CHECK: "ruleId" : "error_open_input_file"

// REQUIRES: swift_sarif
