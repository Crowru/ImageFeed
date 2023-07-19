import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}
