// RUN: %empty-directory(%t)

// Ensure diagnosed as error by-default
// RUN: not %target-swift-frontend -typecheck %s -diagnostic-style llvm -enable-experimental-feature SwiftPerformanceAssistance &> %t/output_err.txt
// RUN: cat %t/output_err.txt | %FileCheck %s

// Ensure downgraded to a warning with '-Wwarning'
// RUN: %target-swift-frontend -typecheck %s -diagnostic-style llvm -enable-experimental-feature SwiftPerformanceAssistance -Wwarning SPAFunctionReturnType &> %t/output_warn.txt
// RUN: cat %t/output_warn.txt | %FileCheck %s -check-prefix CHECK-WARN

// Ensure fully suppressed with '-Wsuppress'
// RUN: %target-swift-frontend -typecheck %s -diagnostic-style llvm -enable-experimental-feature SwiftPerformanceAssistance -Wsuppress SPAFunctionReturnType -verify

// CHECK: error: Performance Assistant Issue: 'foo()' returns an array, leading to implicit copies. Consider using an 'inout' parameter instead. [#SPAFunctionReturnType]
// CHECK-WARN: warning: Performance Assistant Issue: 'foo()' returns an array, leading to implicit copies. Consider using an 'inout' parameter instead. [#SPAFunctionReturnType]

class foo {
}
