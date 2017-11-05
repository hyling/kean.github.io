//: [Previous](@previous)

import Foundation


struct PatchParameters: Swift.Encodable {
    let name: Parameter<String>?
}

func encoded(_ params: PatchParameters) -> String {
    // WARNING! Avoid using force unwraps in production!
    let data = try! JSONEncoder().encode(params)
    return String(data: data, encoding: .utf8)!
}

encoded(PatchParameters(name: nil))
// prints "{}"

encoded(PatchParameters(name: .null))
//print "{"name":null}"

encoded(PatchParameters(name: .value("Alex")))
//print "{"name":"Alex"}"
