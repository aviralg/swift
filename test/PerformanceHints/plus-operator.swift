// RUN: %target-typecheck-verify-swift -enable-upcoming-feature PerformanceHints
// Test cases for performance hints on + operator for arrays and strings
// MARK: - Array concatenation tests

func arrayPlusBasic() {
  let a = [1, 2, 3]
  let b = [4, 5, 6]
  let c = a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(c)
}

func arrayPlusInExpression() {
  let result = [1, 2] + [3, 4] + [5, 6] // expected-warning 2 {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(result)
}

func arrayPlusInReturn() -> [Int] {
  let a = [1, 2]
  let b = [3, 4]
  return a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
}

func arrayPlusStringElements() {
  let words1 = ["Hello", "World"]
  let words2 = ["Swift", "Compiler"]
  let combined = words1 + words2 // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(combined)
}

func arrayPlusOptionalElements() {
  let a = [1, nil, 3]
  let b = [4, nil, 6]
  let c = a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(c)
}

struct Point {
  let x: Int
  let y: Int
}

func arrayPlusCustomType() {
  let points1 = [Point(x: 0, y: 0), Point(x: 1, y: 1)]
  let points2 = [Point(x: 2, y: 2), Point(x: 3, y: 3)]
  let allPoints = points1 + points2 // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(allPoints)
}

func nestedArrayPlus() {
  let matrix1 = [[1, 2], [3, 4]]
  let matrix2 = [[5, 6], [7, 8]]
  let combined = matrix1 + matrix2 // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(combined)
}

func arrayPlusInClosure() {
  let transform: ([Int], [Int]) -> [Int] = { a, b in
    return a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  }

  let result = transform([1, 2], [3, 4])
  print(result)
}

func arrayPlusInReduce() {
  let arrays = [[1, 2], [3, 4], [5, 6]]
  let combined = arrays.reduce([]) { accumulator, array in
    accumulator + array // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  }
  print(combined)
}

func arrayPlusGeneric<T>(a: [T], b: [T]) -> [T] {
  return a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
}

func emptyArrayPlus() {
  let empty: [Int] = []
  let values = [1, 2, 3]
  let result1 = empty + values // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  let result2 = values + empty // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(result1, result2)
}

func arrayPlusParenthesized() {
  let a = [1, 2]
  let b = [3, 4]
  let c = [5, 6]
  let result = a + (b + c) // expected-warning 2 {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(result)
}

// MARK: - String concatenation tests

func stringPlusBasic() {
  let str1 = "Hello"
  let str2 = "World"
  let combined = str1 + str2 // expected-warning {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
  print(combined)
}

func stringPlusInExpression() {
  let result = "Hello" + " " + "World" // expected-warning 2 {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
  print(result)
}

func stringPlusInReturn() -> String {
  let greeting = "Hello"
  let name = "Swift"
  return greeting + name // expected-warning {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
}

func stringPlusInClosure() {
  let combiner: (String, String) -> String = { a, b in
    return a + b // expected-warning {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
  }

  let result = combiner("Hello", "World")
  print(result)
}

func stringPlusInReduce() {
  let words = ["Swift", "is", "awesome"]
  let sentence = words.reduce("") { accumulator, word in
    accumulator + word // expected-warning {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
  }
  print(sentence)
}

func stringPlusParenthesized() {
  let a = "Hello"
  let b = " "
  let c = "World"
  let result = a + (b + c) // expected-warning 2 {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
  print(result)
}

func stringPlusInInterpolation() {
  let greeting = "Hello"
  let name = "Swift"
  let message = "Message: \(greeting + name)" // expected-warning {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}
  print(message)
}

// MARK: - Negative tests (should NOT trigger warnings)

func integerPlus() {
  let x = 1
  let y = 2
  let sum = x + y // No warning - not arrays or strings
  print(sum)
}

func doublePlus() {
  let x = 1.5
  let y = 2.5
  let sum = x + y // No warning - not arrays or strings
  print(sum)
}

func arrayPlusEquals() {
  var a = [1, 2]
  let b = [3, 4]
  a += b // No warning - this is +=, not +
  print(a)
}

func stringPlusEquals() {
  var str = "Hello"
  str += " World" // No warning - this is +=, not +
  print(str)
}

func arrayAppend() {
  var a = [1, 2]
  let b = [3, 4]
  a.append(contentsOf: b) // No warning - using recommended approach
  print(a)
}

func stringAppend() {
  var str = "Hello"
  str.append(" World") // No warning - using recommended approach
  print(str)
}

// MARK: - Mixed contexts

func mixedOperations() {
  let arr1 = [1, 2]
  let arr2 = [3, 4]
  let str1 = "Hello"
  let str2 = "World"

  let combinedArray = arr1 + arr2 // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  let combinedString = str1 + str2 // expected-warning {{Performance: using + to concatenate strings creates a copy. Consider using append(_:) or += to mutate in place.}}

  print(combinedArray, combinedString)
}

func complexExpression() {
  let arrays = [[1], [2], [3]]
  let result = arrays[0] + arrays[1] + arrays[2] // expected-warning 2 {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  print(result)
}

struct Container {
  let data: [Int]

  init(a: [Int], b: [Int]) {
    self.data = a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  }
}

class DataHolder {
  lazy var combined: [Int] = {
    let a = [1, 2, 3]
    let b = [4, 5, 6]
    return a + b // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  }()
}

extension Array where Element == Int {
  func addArray(_ other: [Int]) -> [Int] {
    return self + other // expected-warning {{Performance: using + to concatenate arrays creates a copy. Consider using append(contentsOf:) or += to mutate in place.}}
  }
}
