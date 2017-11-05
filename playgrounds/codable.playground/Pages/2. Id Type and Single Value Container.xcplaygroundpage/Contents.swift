//: [Previous](@previous)

import Foundation

final class Post: Decodable {
    let id: Id<Post>
    let title: String
    let subtitle: String?
}

//: ### Happy scenario in which Id is present.

let json = """
{
    "id": "pos_1",
    "title": "Codable: Tips and Tricks"
}
"""

do {
    let post = try JSONDecoder().decode(Post.self, from: json.data(using: .utf8)!)
    print(post.id)
} catch {
    print(error)
}


//: ### Id is empty which isn't allowed.

let jsonEmptyId = """
{
    "id": "",
    "title": "Smart Retry"
}
"""

do {
    let post = try JSONDecoder().decode(Post.self, from: jsonEmptyId.data(using: .utf8)!)
    print(post.id)
} catch {
    print(error)
}

//: [Next](@next)
