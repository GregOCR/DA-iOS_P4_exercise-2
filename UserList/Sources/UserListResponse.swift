import Foundation

// MARK: - UserListResponse

struct UserListResponse: Codable {
    
    let results: [User]

    struct User: Codable {
        let name: Name
        let dob: Dob
        let picture: Picture
    }
}
