import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://akabab.github.io/superhero-api/api"
    private var cancellables = Set<AnyCancellable>()
    private init() {}
    
    // MARK: - API Methods
    func fetchAllHeroes() -> AnyPublisher<[Superhero], APIError> {
        guard let url = URL(string: "\(baseURL)/all.json") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: [Superhero].self, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else if error is DecodingError {
                    return APIError.decodingError(error)
                } else {
                    return APIError.unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Helper method to get a random hero
    func fetchRandomHero() -> AnyPublisher<Superhero?, APIError> {
        return fetchAllHeroes()
            .map { heroes in
                guard !heroes.isEmpty else { return nil }
                return heroes.randomElement()
            }
            .eraseToAnyPublisher()
    }
    
    // Helper method to search for heroes by name
    func searchHeroes(query: String) -> AnyPublisher<[Superhero], APIError> {
        return fetchAllHeroes()
            .map { heroes in
                guard !query.isEmpty else { return heroes }
                return heroes.filter { hero in
                    hero.name.lowercased().contains(query.lowercased()) ||
                    hero.biography.fullName.lowercased().contains(query.lowercased())
                }
            }
            .eraseToAnyPublisher()
    }
}
