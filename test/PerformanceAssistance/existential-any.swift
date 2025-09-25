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

protocol Person {
  var name: String { get set }
}

struct Scientist : Person {
  var name: String
  
  init() {
    self.name = "Dr. FNU LNU"
  }
}

struct Director : Person {
  var name: String
  
  init() {
    self.name = "Mr. Movie Maker"
  }
}

protocol Animal {
  var species: String { get set }
}

struct Tiger: Animal {
  var species: String

  init() {
    self.species = "Tiger"
  }
}

struct Panda: Animal {
  var species: String

  init() {
    self.species = "Panda"
  }
}

// Local variables
func testVariableDeclarations() {
  let person: any Person = Scientist()
  var animal: any Animal = Tiger()
}

// Property declarations
class Zoo {
  var animals: [any Animal] = [Tiger(), Panda()]
  let director: any Person = Director()
}

// Static/class properties
struct Home {
  static let owner: any Person = Scientist()
}
