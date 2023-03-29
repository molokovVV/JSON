import Foundation

struct Card: Codable {
    let name: String
    let type: String
    let manaCost: String?
    let setName: String
    let rarity: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case manaCost = "manaCost"
        case setName = "set"
        case rarity
    }
}

struct CardsResponse: Codable {
    let cards: [Card]
}
