// A PCH's diagnostics file is read by clients that expect the binary format, so
// it stays binary while the rest of the compilation serializes to SARIF.

// RUN: %empty-directory(%t)
// RUN: %swiftc_driver -typecheck -driver-print-jobs -disallow-use-new-driver -serialize-diagnostics=sarif -emit-module-path %t/main.swiftmodule -pch-output-dir %t/pch -import-objc-header %S/Inputs/bridging-header.h %s 2>&1 | %FileCheck %s

// The PCH job gets a '.dia' path and no format flag, so it keeps writing
// bitcode.
// CHECK: -serialize-diagnostics-path {{[^ ]*}}bridging-header-{{[^ ]*}}.dia
// CHECK-SAME: -emit-pch

// The compile job serializes to SARIF.
// CHECK: -primary-file {{[^ ]*}}sarif-diagnostics-pch.swift
// CHECK-SAME: -serialize-diagnostics-path {{[^ ]*}}sarif-diagnostics-pch.sarif
// CHECK-SAME: -serialize-diagnostics=sarif

// No later job serializes diagnostics: the format is never forwarded wholesale,
// so the emit-module job neither gets a path nor needs putting back to 'dia'.
// CHECK-NOT: -serialize-diagnostics

// REQUIRES: cplusplus_driver

let y = x
