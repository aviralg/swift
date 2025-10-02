// RUN: %empty-directory(%t)

// Ensure ignored by-default
// RUN: %target-swift-frontend -typecheck %s -diagnostic-style llvm -verify

// Ensure enabled with '-Wwarning'
// RUN: %target-swift-frontend -typecheck %s -diagnostic-style llvm -Wwarning PerformanceHints &> %t/output_warn.txt
// RUN: cat %t/output_warn.txt | %FileCheck %s -check-prefix CHECK-WARN
// RUN: %target-swift-frontend -typecheck %s -diagnostic-style llvm -Wwarning ExistentialAnyType &> %t/output_warn.txt
// RUN: cat %t/output_warn.txt | %FileCheck %s -check-prefix CHECK-WARN

// Ensure enabled with '-Werror' for the broad category and downgraded to warning for the subgroup with '-Wwarning'
// RUN: %target-swift-frontend -typecheck %s -diagnostic-style llvm -Werror PerformanceHints -Wwarning ExistentialAnyType &> %t/output_warn.txt
// RUN: cat %t/output_warn.txt | %FileCheck %s -check-prefix CHECK-WARN

// Ensure enabled with '-Wwarning' for the broad category and downgraded to warning for the subgroup with '-Werror'
// RUN: not %target-swift-frontend -typecheck %s -diagnostic-style llvm -Wwarning PerformanceHints -Werror ExistentialAnyType &> %t/output_err.txt
// RUN: cat %t/output_err.txt | %FileCheck %s -check-prefix CHECK-ERR

// Ensure escalated with '-Werror'
// RUN: not %target-swift-frontend -typecheck %s -diagnostic-style llvm -Werror ExistentialAnyType &> %t/output_err.txt
// RUN: cat %t/output_err.txt | %FileCheck %s -check-prefix CHECK-ERR

// CHECK-ERR: error: Performance: 'AnyAnimal' aliases existential any type, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'AnimalContainer' aliases existential any type, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'AnimalHandler' aliases existential any type, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'returnAnimal1()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'returnAnimal2()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'returnAnimal3()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'returnAnimal4()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'other' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: getter for 'animal' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'releaseAnimal()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: getter for 'subscript(_:)' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals1' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals2' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals3' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals4' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals5' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals6' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animals7' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'container' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animalsA' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animalsB' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animalsC' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'tuple' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'handler' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'factory' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: closure returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'transformer' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: closure returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'handlers' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'handler' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'animalThunk' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'value' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'a1' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'a2' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'pet' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: 'owner' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: parameter uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-ERR: error: Performance: parameter uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]

// CHECK-WARN: warning: Performance: 'AnyAnimal' aliases existential any type, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'AnimalContainer' aliases existential any type, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'AnimalHandler' aliases existential any type, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'returnAnimal1()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'returnAnimal2()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'returnAnimal3()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'returnAnimal4()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'other' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: getter for 'animal' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'releaseAnimal()' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: getter for 'subscript(_:)' returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals1' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals2' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals3' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals4' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals5' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals6' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animals7' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'container' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animalsA' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animalsB' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animalsC' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: Ignored value uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'tuple' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'handler' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animal' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'factory' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: closure returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'transformer' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: closure returns existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'handlers' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'handler' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'animalThunk' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'value' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'a1' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'a2' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'pet' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: 'owner' uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: parameter uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]
// CHECK-WARN: warning: Performance: parameter uses existential any, leading to heap allocation, reference counting, and dynamic dispatch. Consider using generic constraints or concrete types instead. [#ExistentialAnyType]

protocol Animal {
  var Name: String { get }
}

struct Tiger: Animal {
  let Name: String = "Tiger"
}

struct Panda: Animal {
  let Name: String = "Panda"
}

struct AnimalError: Error {
  let reason: String

  init(reason: String) {
    self.reason = reason
  }
}

struct Container<T> {
  let value: T
}

protocol Person {
}

////////////////////////////////////////////////////////////////////////////////
// Typealias
///////////////////////////////////////////////////////////////////////////////

typealias AnyAnimal = any Animal
typealias AnimalContainer<T> = Container<any Animal>
typealias AnimalHandler = (any Animal) -> (any Animal)?

////////////////////////////////////////////////////////////////////////////////
// Function Return Type
///////////////////////////////////////////////////////////////////////////////

// Regular
func returnAnimal1() -> any Animal { return Tiger() }

// Optional
func returnAnimal2() -> (any Animal)? {
  let n = Int.random(in: 1...100)
  return (n <= 50) ? nil : Tiger()
}

// Throwing
func returnAnimal3() throws -> any Animal {
  let n = Int.random(in: 1...100)
  if n <= 50 {
    throw AnimalError(reason: "All animals are extinct.")
  } else {
    return Tiger()
  }
}

// Async
func returnAnimal4() async -> any Animal {}

////////////////////////////////////////////////////////////////////////////////
// Function Parameter Type
///////////////////////////////////////////////////////////////////////////////

// Regular parameters
func animalParam1(_ animal: any Animal) {}

// Multiple parameters
func animalParam2(_ animal: any Animal, to other: any Animal) {}

// Variadic parameters
func animalParam3(_ animals: any Animal...) {}

// In-out parameters
func animalParam4(_ animal: inout any Animal) {}

////////////////////////////////////////////////////////////////////////////////
// Protocol
////////////////////////////////////////////////////////////////////////////////
protocol AnimalShelter {
  var animal: (any Animal)? { get }
  func admit(_ animal: any Animal)
  func releaseAnimal() -> (any Animal)?
  subscript(id: String) -> (any Animal)? { get }
}

////////////////////////////////////////////////////////////////////////////////
// Constructor
////////////////////////////////////////////////////////////////////////////////
class Zoo {
  var animals: [any Animal]

  init(with animal: any Animal) {
    self.animals = [animal]
  }

  init(animals: [any Animal]) {
    self.animals = animals
  }
}

////////////////////////////////////////////////////////////////////////////////
// Compound Types
////////////////////////////////////////////////////////////////////////////////
func testCompoundTypes() {
  let animals1: [any Animal] = []
  print(type(of: animals1))

  let animals2: [any Animal] = []
  print(type(of: animals2))

  let animals3: [String: any Animal] = [:]
  print(type(of: animals3))

  let animals4: [String: any Animal] = [:]
  print(type(of: animals4))

  let animals5: (any Animal)? = nil
  print(type(of: animals5))

  let animals6: (any Animal)? = nil
  print(type(of: animals6))

  let animals7: Result<any Animal, Error> = .success(Tiger())
  print(type(of: animals7))

  let container = Container<any Animal>(value: Tiger())
  print(type(of: container))
}

////////////////////////////////////////////////////////////////////////////////
// Tuple
////////////////////////////////////////////////////////////////////////////////
func tupleTest() {
  let _ = ([Tiger() as any Animal], [Panda() as any Animal])

  let (animalsA, animalsB) = ([Tiger() as any Animal], [Panda() as any Animal])
  print(type(of: animalsA))
  print(type(of: animalsB))

  let (_, animalsC) = ([Tiger() as any Animal], [Panda() as any Animal])
  print(type(of: animalsC))

  let (_, _) = ([Tiger() as any Animal], [Panda() as any Animal])

  let tuple: (animal1: any Animal, animal2: any Animal) = (Tiger(), Panda())
  print(type(of: tuple))
}

////////////////////////////////////////////////////////////////////////////////
// Closure
////////////////////////////////////////////////////////////////////////////////
func closureTest() {
  // Closure parameter type
  let handler: (any Animal) -> Void = { animal in print(type(of: animal)) }
  handler(Tiger())

  // Closure return type
  let factory: () -> any Animal = { Tiger() }
  print(type(of: factory()))

  // Both parameter and return types
  let transformer: (any Animal) -> any Animal = { $0 }
  print(type(of: transformer(Tiger())))

  // Escaping closures
  var handlers: [(any Animal) -> Void] = []
  func registerHandler(with handler: @escaping (any Animal) -> Void) {
    handlers.append(handler)
  }

  // Autoclosure
  func registerHandler2(animalThunk: @autoclosure () -> any Animal) {
    handlers[0](animalThunk())
  }
}

////////////////////////////////////////////////////////////////////////////////
// Type casting
///////////////////////////////////////////////////////////////////////////////
protocol A {
}

protocol A1: A {
}

protocol A2: A {
}

struct S1: A1 {
}

struct S2: A2 {
}

func testTypeCasting() {
  let randomNumber = Int.random(in: 1...100)

  let value: any A = randomNumber <= 50 ? S1() : S2()

  let a1 = value as? any A1
  print(type(of: a1))

  let a2 = value as! any A2
  print(type(of: a2))
}

////////////////////////////////////////////////////////////////////////////////
// Enum
///////////////////////////////////////////////////////////////////////////////
enum PetOwnership {
  case owned(pet: any Animal, owner: any Person)
  case stray(any Animal)
  case multiple([any Animal])
}
