import Foundation

struct Superhero: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let powerstats: PowerStats
    let appearance: Appearance
    let biography: Biography
    let work: Work
    let connections: Connections
    let images: Images
    
    // Equatable
    static func == (lhs: Superhero, rhs: Superhero) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PowerStats: Codable {
    let intelligence: Int
    let strength: Int
    let speed: Int
    let durability: Int
    let power: Int
    let combat: Int
}

struct Appearance: Codable {
    let gender: String
    let race: String?
    let height: [String]
    let weight: [String]
    let eyeColor: String
    let hairColor: String
}

struct Biography: Codable {
    let fullName: String
    let alterEgos: String
    let aliases: [String]
    let placeOfBirth: String
    let firstAppearance: String
    let publisher: String?
    let alignment: String
}

struct Work: Codable {
    let occupation: String
    let base: String
}

struct Connections: Codable {
    let groupAffiliation: String
    let relatives: String
}

struct Images: Codable {
    let xs: String
    let sm: String
    let md: String
    let lg: String
}
