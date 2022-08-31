import UIKit
import Foundation
import Darwin


// criando protocolo de parkable

protocol Parkable {
    //precisa ser var por causa do get
    var plate: String { get }
    var type: VehicleType { get }
    var parkedTime: Int { get }
    var discountCard: String? { get }
    var checkInTime: Date { get }
}

// criando a estrutura de veiculo

struct Vehicle: Parkable, Hashable {
    var plate: String
    var type: VehicleType
    var checkInTime: Date
    var discountCard: String?
    var parkedTime: Int {
        return Calendar.current.dateComponents([.minute], from: checkInTime).minute ?? 0
    }
    
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.plate == rhs.plate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
    
    
}

//MARK: - estacionamento

struct AlkeParking {
    var maxCapacity = 20
    var vehicles = Set<Vehicle>()
    var totalCarsAndEarnings = (totalCars: 0, totalEarnings: 0)
    
    // criar um meteodo para acrescentar um veiculo no estacionamento, onde placa e tipo não iguais
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish: (Bool, String) -> Void) {
        
        guard vehicles.count < maxCapacity else {
            return onFinish(false, "Sorry the checkin failed")
        }
        
        guard vehicles.insert(vehicle).inserted else {
            return onFinish(false, "Sorry the checkin failed")
        }
        
        onFinish(true, "Welcome to AlkeParking")
        
    }
    
    mutating func checkoutVehicle(_ plate: String, onSucess: (Int, String) -> (), onError: (String) -> ()) {
        let existsVehicle = vehicles.first { vehicle in
            vehicle.plate == plate
        }
        
        if let vehicle = existsVehicle {
            // retira e calcula o pagamento
            vehicles.remove(vehicle)
            let valueToPay = calculateFee(vehicle: vehicle) { hasDiscount in
                print("The user has discount \(hasDiscount)")
            }
            totalCarsAndEarnings.totalEarnings = totalCarsAndEarnings.totalEarnings + valueToPay
            totalCarsAndEarnings.totalCars = totalCarsAndEarnings.totalCars + 1
            onSucess(valueToPay, "Your fee is \(valueToPay). Come back soon")
        } else {
            onError("Sorry, the check-out failed")
        }
    }
    private func calculateMinutes(_ vehicle: Vehicle) -> Int {
        let mins = Calendar.current.dateComponents([.minute], from: vehicle.checkInTime, to: Date()).minute ?? 0
        return mins
    }
    
    private func calculatePayments(vehicle: Vehicle) -> Int {
        let firstHour = 120
        let time = calculateMinutes(vehicle)
        let fixedFee = vehicle.type.value()
        var totalValue = fixedFee
        if time <= firstHour {
            return totalValue
        } else {
            if (time - firstHour) % 15 != 0 {
                totalValue += 5
                totalValue += (time - firstHour) / 15 * 5
                return totalValue
            } else {
                totalValue += (time - firstHour) / 15 * 5
                return totalValue
            }
        }
    }
    
    private func calculateFee(vehicle: Vehicle, hasDiscountCard: (Bool) -> ()) -> Int {
        let totalValue = calculatePayments(vehicle: vehicle)
        guard (vehicle.discountCard != nil) else {
            hasDiscountCard(false)
            
            return totalValue
        }
        hasDiscountCard(true)
        return totalValue - ((15 * totalValue) / 100)
    }
    
    func totalEarnings () -> String {
        return "\(totalCarsAndEarnings.totalCars) vehicles have checked out and have earnings of $\(totalCarsAndEarnings.totalEarnings)"
    }
    
    func listVehicles() {
        print(vehicles.map { vehicle in
            vehicle.plate
        })
    }
    
}

//MARK: - exercicio 1
// criando tipos de veiculos

enum VehicleType {
    case car
    case moto
    case miniBus
    case bus
    
    func value() -> Int{
        switch self {
        case .car:
            return 20
        case .moto:
            return 15
        case .miniBus:
            return 25
        case .bus:
            return 30
        }
    }
}


var alkeParking = AlkeParking()
let threeHoursBefore = Date.now.addingTimeInterval(-10800)

let vehicle1 = Vehicle(plate: "AA111AA", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_001")

let vehicle2 = Vehicle(plate: "B222BBB", type: VehicleType.moto, checkInTime: Date(), discountCard: nil)

let vehicle3 = Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

let vehicle4 = Vehicle(plate: "DD444DD", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_002")

let vehicle5 = Vehicle(plate: "AA111BB", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_003")

let vehicle6 = Vehicle(plate: "B222CCC", type: VehicleType.moto, checkInTime: Date(), discountCard: "DISCOUNT_CARD_004")

let vehicle7 = Vehicle(plate: "CC333CC", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

let vehicle8 = Vehicle(plate: "DD444EE", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_005")

let vehicle9 = Vehicle(plate: "AA111CC", type: VehicleType.car, checkInTime: threeHoursBefore, discountCard: nil)

let vehicle10 = Vehicle(plate: "B222DDD", type: VehicleType.moto, checkInTime: Date(), discountCard: nil)

let vehicle11 = Vehicle(plate: "CC333EE", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

let vehicle12 = Vehicle(plate: "DD444GG", type: VehicleType.bus, checkInTime: Date(), discountCard: "DISCOUNT_CARD_006")

let vehicle13 = Vehicle(plate: "AA111DD", type: VehicleType.car, checkInTime: Date(), discountCard: "DISCOUNT_CARD_007")

let vehicle14 = Vehicle(plate: "B222EEE", type: VehicleType.moto, checkInTime: Date(), discountCard: nil)

let vehicle15 = Vehicle(plate: "CC333FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

let vehicle16 = Vehicle(plate: "CC333FF", type: VehicleType.miniBus, checkInTime: Date(), discountCard: nil)

// exercicio 6, 2
let arrayVehicle = [vehicle1, vehicle2, vehicle3, vehicle4, vehicle5, vehicle6, vehicle7, vehicle8, vehicle9, vehicle10, vehicle11, vehicle12, vehicle13, vehicle14, vehicle15, vehicle16]

// exercicio 6, 3
for vehicle in arrayVehicle {
    alkeParking.checkInVehicle(vehicle) { park, message in
        print(message, park)
    }
}

alkeParking.checkoutVehicle(vehicle9.plate) { value, mesage  in
    print(mesage)
} onError: { error in
    print(error)
}

alkeParking.checkoutVehicle(vehicle12.plate) { value, mesage  in
    print(mesage)
} onError: { error in
    print(error)
}

alkeParking.totalEarnings()

alkeParking.listVehicles()

