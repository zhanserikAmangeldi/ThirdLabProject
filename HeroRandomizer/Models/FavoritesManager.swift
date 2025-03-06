import Foundation
import Combine

class FavoritesManager: ObservableObject {
    @Published private(set) var favorites: [Superhero] = []
    private let favoritesKey = "FavoriteHeroes"
    private var cancellables = Set<AnyCancellable>()
    static let shared = FavoritesManager()
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    func addToFavorites(_ hero: Superhero) {
        if !isFavorite(hero) {
            favorites.append(hero)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(_ hero: Superhero) {
        favorites.removeAll { $0.id == hero.id }
        saveFavorites()
    }
    
    func isFavorite(_ hero: Superhero) -> Bool {
        return favorites.contains { $0.id == hero.id }
    }
    
    func toggleFavorite(_ hero: Superhero) {
        if isFavorite(hero) {
            removeFromFavorites(hero)
        } else {
            addToFavorites(hero)
        }
    }
    
    // MARK: - Private Methods
    private func saveFavorites() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favorites)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("Error saving favorites: \(error.localizedDescription)")
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            favorites = try decoder.decode([Superhero].self, from: data)
        } catch {
            print("Error loading favorites: \(error.localizedDescription)")
        }
    }
}
