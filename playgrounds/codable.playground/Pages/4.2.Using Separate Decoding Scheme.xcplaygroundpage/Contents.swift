//: [Previous](@previous)

import Foundation


final class Post: Decodable {
    let id: Id<Post>
    let title: String
    let webURL: URL?

    init(from decoder: Decoder) throws {
        let map = try PostScheme(from: decoder)
        self.id = map.id
        self.title = map.title
        self.webURL = map.webURL?.value
    }

    final class PostScheme: Decodable {
        let id: Id<Post>
        let title: String
        let webURL: Safe<URL>?
    }
}

let json = """
{
    "id": "pos_1",
    "title": "Codable: Tips and Tricks",
    "webURL": "http://google.com/🤬"
}
"""

do {
    let post = try JSONDecoder().decode(Post.self, from: json.data(using: .utf8)!)
    print(post.id)
    print(post.title)
} catch {
    print(error)
}

//: [Next](@next)
