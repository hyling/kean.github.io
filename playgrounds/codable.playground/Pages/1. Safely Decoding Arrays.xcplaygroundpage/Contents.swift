import Foundation


final class Post: Decodable {
    let id: Id<Post>
    let title: String
    let subtitle: String?
}

let json = """
[
    {
        "id": "pos_1",
        "title": "Codable: Tips and Tricks"
    },
    {
        "id": "pos_2"
    }
]
"""

do {
    let posts = try JSONDecoder().decode([Post].self, from: json.data(using: .utf8)!)
} catch {
    print(error)
}

do {
    let posts = try JSONDecoder().decode([Safe<Post>].self, from: json.data(using: .utf8)!)
    print(posts[0].value!.title)
    print(posts[1].value)
} catch {
    print(error)
}

//: [Next](@next)
