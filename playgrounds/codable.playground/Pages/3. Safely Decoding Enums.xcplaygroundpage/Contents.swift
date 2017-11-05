//: [Previous](@previous)

import Foundation
import CoreLocation


enum System: String, Decodable {
    case ios, macos, tvos, watchos
}

struct Location: Decodable {
    let latitude: Double
    let longitude: Double
}

final class Device: Decodable {
    let location: Location
    let system: System?

    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.location = try map.decode(Location.self, forKey: .location)
        //self.system = try? map.decode(System.self, forKey: .system)
        self.system = System(rawValue: try map.decode(String.self, forKey: .system))
    }

    private enum CodingKeys: CodingKey {
        case location
        case system
    }
}


let json = """
{
    "location": {
        "latitude": 37.3317,
        "longitude": 122.0302
    },
    "system": "caros"
}
"""

do {
    let device = try JSONDecoder().decode(Device.self, from: json.data(using: .utf8)!)
    print(device.location)
} catch {
    print(error)
}

//: [Next](@next)
