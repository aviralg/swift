// Each input gets its own SARIF log, and the format travels with the path.

// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics=sarif -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s

// Without a format, diagnostics stay in the binary format and no format flag is
// passed to any job.
// RUN: %swiftc_driver -driver-print-jobs -typecheck -serialize-diagnostics -disallow-use-new-driver %s %S/Inputs/main.swift 2>&1 | %FileCheck %s -check-prefix=BITCODE

// Legacy C++ driver only; the same behavior is tested for swift-driver in
// Tests/SwiftDriverTests.
// REQUIRES: cplusplus_driver

// CHECK: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics.sarif
// CHECK-SAME: -serialize-diagnostics=sarif
// CHECK: -serialize-diagnostics-path {{[^ ]*}}main.sarif
// CHECK-SAME: -serialize-diagnostics=sarif

// BITCODE-NOT: -serialize-diagnostics=
// BITCODE: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics.dia
// BITCODE: -serialize-diagnostics-path {{[^ ]*}}main.dia
