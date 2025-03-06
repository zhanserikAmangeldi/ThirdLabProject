import SwiftUI

struct HeroCard: View {
    let hero: Superhero
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    var onTap: () -> Void
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: hero.images.md)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.3))
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            )
                    }
                }
                .frame(height: 200)
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(hero.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        if !hero.biography.fullName.isEmpty {
                            Text(hero.biography.fullName)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            favoritesManager.toggleFavorite(hero)
                        }
                    }) {
                        Image(systemName: favoritesManager.isFavorite(hero) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(hero) ? .red : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                    }
                    .onChange(of: favoritesManager.isFavorite(hero)) { _ in
                        withAnimation(.spring()) {
                            isAnimating = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring()) {
                                isAnimating = false
                            }
                        }
                    }
                }
                .padding(10)
            }
            
            HStack(spacing: 0) {
                ForEach([
                    (label: "INT", value: hero.powerstats.intelligence),
                    (label: "STR", value: hero.powerstats.strength),
                    (label: "SPD", value: hero.powerstats.speed)
                ], id: \.label) { stat in
                    statView(label: stat.label, value: stat.value)
                }
            }
            .frame(height: 40)
        }
        .cornerRadius(12)
        .shadow(radius: 5)
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - UI Components
    private func statView(label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

#Preview {
    let sampleHero = Superhero(
        id: 1,
        name: "Batman",
        slug: "batman",
        powerstats: PowerStats(intelligence: 90, strength: 60, speed: 45, durability: 55, power: 60, combat: 95),
        appearance: Appearance(gender: "Male", race: "Human", height: ["6'2", "188 cm"], weight: ["210 lb", "95 kg"], eyeColor: "Blue", hairColor: "Black"),
        biography: Biography(fullName: "Bruce Wayne", alterEgos: "No alter egos found.", aliases: ["Dark Knight", "Caped Crusader", "Matches Malone"], placeOfBirth: "Gotham City", firstAppearance: "Detective Comics #27", publisher: "DC Comics", alignment: "good"),
        work: Work(occupation: "Businessman", base: "Batcave, Stately Wayne Manor, Gotham City"),
        connections: Connections(groupAffiliation: "Batman Family, Justice League", relatives: "Alfred Pennyworth (butler), Dick Grayson (ward), Jason Todd (ward), Tim Drake (ward), Damian Wayne (son)"),
        images: Images(xs: "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/xs/70-batman.jpg", sm: "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/70-batman.jpg", md: "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/70-batman.jpg", lg: "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/70-batman.jpg")
    )

    return HeroCard(hero: sampleHero, onTap: {})
        .frame(width: 300)
        .padding()
}
