import Foundation


public struct Id<Entity>: Hashable {
    public let raw: String
    public init(_ raw: String) {
        self.raw = raw
    }

    // MARK: Equatable+Hashable
    
    public var hashValue: Int {
        return raw.hashValue
    }
    
    public static func ==(lhs: Id, rhs: Id) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Id: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        if raw.isEmpty {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Id cannot be empty string")
        }
        self.init(raw)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(raw)
    }
}
