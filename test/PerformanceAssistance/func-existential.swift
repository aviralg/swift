


protocol Vehicle {
    func travel(to destination: String)
}

struct Car: Vehicle {
    func travel(to destination: String) {
        print("I'm driving to \(destination)")
    }
}


func travel2(to destinations: [String], using vehicle: any Vehicle) {
    for destination in destinations {
        vehicle.travel(to: destination)
    }
}

func asVehicle(using car: Car) -> any Vehicle {
  return car
}

func asVehicle2(using car: Car) -> (Bool, any Vehicle) {
  return (true, car)
}

func asVehicle3(using vehicles: [any Vehicle]) -> Int {
  return vehicles.count
}

typealias AnyVehicle = any Vehicle

func asVehicle5(using vehicles: [AnyVehicle]) -> Int {
  return vehicles.count
}

func testMe() {
  let inner = { (_ vehicles: [AnyVehicle]) -> Int in
    return vehicles.count
  }

  let inner2 = { (_ vehicles: [AnyVehicle]) -> AnyVehicle in
    return vehicles[0]
  }
}

struct Hello {
  var field: any Vehicle
}

func asVehicle4(hellos: [Hello]) -> Int {
  return hellos.count
}

class MoreInteresting {
  var field2: (any Vehicle) -> Int

  init() {
  }
}

protocol Animal {
  var name: String { get set }
}

protocol Person {
  var name: String { get set }
}

enum PetOwnership {
    case owned(pet: any Animal, owner: any Person)
    case stray(any Animal)
    case multiple([any Animal])
}

// Regular return type
func createAnimal() -> any Animal { }

// Optional return type
func findAnimal() -> (any Animal)? { }

// Throwing functions
func loadAnimal() throws -> any Animal { }

// Async functions
func fetchAnimal() async -> any Animal { }

struct Test100 {
  var f : () -> any Vehicle = { () -> any Vehicle in return Car() }
}

func serve(customer personProvider: @autoclosure () -> AnyVehicle) {
    print("Now serving \(personProvider())!")
}

enum Barcode {
    case upc(Int, any Vehicle, Int, Int)
    case qrCode(String)
}

enum Barcode2 {
    case upc(a: Int, b: Int, c: any Vehicle, d: Int)
    case qrCode(e: String)
}

struct Point {
    var x = 0.0, y = 0.0
}
struct Size {
    var width = 0.0, height = 0.0
}

/*
struct Hello {
  
func multipleVehicles(vehicles: Vehicle...) -> Int {
  return vehicles.count
}*/

//}
