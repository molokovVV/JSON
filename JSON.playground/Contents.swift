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

func getData(names: [String], completion: @escaping (Result<[Card], Error>) -> Void) {
    for name in names {
        let urlString = "https://api.magicthegathering.io/v1/cards?name=\(name)"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode URL query"])))
            return
        }
        guard let url = URL(string: encodedUrlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200:
                guard let data = data else { return }
                print("Код ответа с сервера:", statusCode)
                do {
                    let response = try JSONDecoder().decode(CardsResponse.self, from: data)
                    completion(.success(response.cards))
                } catch {
                    completion(.failure(error))
                }
            case 400:
                print("Bad request, we could not process that action:", statusCode)
            case 403:
                print("Forbidden, you exceeded the rate limit:", statusCode)
            case 404:
                print("Not Found, the requested resource could not be found:", statusCode)
            case 500:
                print("Internal Server Error, we had a problem with our server. Please try again later:", statusCode)
            case 503:
                print("Service Unavailable, we are temporarily offline for maintenance. Please try again later:", statusCode)
            default:
                print("Неизвестная ошибка, код ответа:", statusCode)
            }  
        }.resume()
    }
}

getData(names: ["Opt", "Black Lotus"]) { result in
    
    switch result {
    case .success(let cards):
        let filteredCards = cards.filter { $0.name == "Opt" || $0.name == "Black Lotus" }
        for card in filteredCards {
            print("Имя карты: \(card.name)")
            print("Тип: \(card.type)")
            print("Мановая стоимость: \(card.manaCost ?? "Не указано")")
            print("Название сета: \(card.setName)")
            print("Редкость: \(card.rarity)")
            print("--------")
        }
    case .failure(let error):
        print("Ошибка: \(error.localizedDescription)")
    }
}
