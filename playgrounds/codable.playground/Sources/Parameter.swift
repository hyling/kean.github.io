import Foundation


public enum Parameter<Base: Swift.Codable>: Swift.Encodable {
    case null // parameter set to `null`
    case value(Base)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case let .value(value): try container.encode(value)
        }
    }
}
