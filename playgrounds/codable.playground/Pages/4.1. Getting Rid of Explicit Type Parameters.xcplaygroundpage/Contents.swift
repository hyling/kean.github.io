//: [Previous](@previous)

import Foundation


final class Post: Decodable {
    let id: Id<Post>
    let title: String
    let webURL: URL?

    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try map.decode(.id)
        self.title = try map.decode(.title)
        self.webURL = try? map.decode(.webURL)
    }

    private enum CodingKeys: CodingKey {
        case id
        case title
        case webURL
    }
}


let json = """
{
    "id": "pos_1",
    "title": "Codable: Tips and Tricks",
    "webURL": "http://apple.com/🤬"
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

