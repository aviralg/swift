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

/* Variable Declarations */


// MARK: - Base Protocols for Testing Existential Any

protocol TestProtocol {
  func testMethod()
}

protocol AnotherProtocol {
  var value: Int { get }
}

struct ConcreteStruct: TestProtocol {
  func testMethod() {}
}

class ConcreteClass: TestProtocol, AnotherProtocol {
  let value = 42
  func testMethod() {}
}

enum ConcreteEnum: TestProtocol {
case test
  func testMethod() {}
}

func functionTestCases() {
  // 1. var + function + concrete + explicit + direct existential
  var funcVarExplicit: any TestProtocol = ConcreteStruct()

  // 2. let + function + concrete + explicit + direct existential
  let funcLetExplicit: any TestProtocol = ConcreteClass()
}

class classTestCases {
  // 1. var + function + concrete + explicit + direct existential
  var classVar: any TestProtocol = ConcreteStruct()

  // 2. let + function + concrete + explicit + direct existential
  let classLet: any TestProtocol = ConcreteClass()
}

struct structTestCases {
  // 1. var + function + concrete + explicit + direct existential
  var structVar: any TestProtocol = ConcreteStruct()

  // 2. let + function + concrete + explicit + direct existential
  let structLet: any TestProtocol = ConcreteClass()
}

