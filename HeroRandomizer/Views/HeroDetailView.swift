import SwiftUI

struct HeroDetailView: View {
    let hero: Superhero
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    private let gradientColors = [Color(#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroHeader
                
                Group {
                    powerStatsSection
                    biographySection
                    appearanceSection
                    workSection
                    connectionsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationBarTitle(hero.name, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    favoritesManager.toggleFavorite(hero)
                }) {
                    Image(systemName: favoritesManager.isFavorite(hero) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesManager.isFavorite(hero) ? .red : .gray)
                }
            }
        }
    }
    
    // MARK: - UI Components
    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: hero.images.lg)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Color.gray
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(height: 300)
            .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Text(hero.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
        }
    }
    
    private var powerStatsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Power Stats")
            
            VStack(spacing: 8) {
                statBar(title: "Intelligence", value: hero.powerstats.intelligence)
                statBar(title: "Strength", value: hero.powerstats.strength)
                statBar(title: "Speed", value: hero.powerstats.speed)
                statBar(title: "Durability", value: hero.powerstats.durability)
                statBar(title: "Power", value: hero.powerstats.power)
                statBar(title: "Combat", value: hero.powerstats.combat)
            }
        }
    }
    
    private var biographySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Biography")
            
            infoRow(title: "Full Name", value: hero.biography.fullName)
            infoRow(title: "Alter Egos", value: hero.biography.alterEgos)
            infoRow(title: "Aliases", value: hero.biography.aliases.joined(separator: ", "))
            infoRow(title: "Place of Birth", value: hero.biography.placeOfBirth)
            infoRow(title: "First Appearance", value: hero.biography.firstAppearance)
            infoRow(title: "Publisher", value: hero.biography.publisher ?? "Unknown")
            infoRow(title: "Alignment", value: hero.biography.alignment)
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Appearance")
            
            infoRow(title: "Gender", value: hero.appearance.gender)
            infoRow(title: "Race", value: hero.appearance.race ?? "Unknown")
            infoRow(title: "Height", value: hero.appearance.height.joined(separator: ", "))
            infoRow(title: "Weight", value: hero.appearance.weight.joined(separator: ", "))
            infoRow(title: "Eye Color", value: hero.appearance.eyeColor)
            infoRow(title: "Hair Color", value: hero.appearance.hairColor)
        }
    }
    
    private var workSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Work")
            
            infoRow(title: "Occupation", value: hero.work.occupation)
            infoRow(title: "Base", value: hero.work.base)
        }
    }
    
    private var connectionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Connections")
            
            infoRow(title: "Group Affiliation", value: hero.connections.groupAffiliation)
            infoRow(title: "Relatives", value: hero.connections.relatives)
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.vertical, 5)
    }
    
    private func statBar(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Text("\(value)")
                    .fontWeight(.bold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.2)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(value) / 100.0 * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(statColor(value: value))
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value.isEmpty ? "Unknown" : value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
    
    private func statColor(value: Int) -> Color {
        switch value {
        case 0..<30: return .red
        case 30..<60: return .orange
        case 60..<80: return .yellow
        default: return .green
        }
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

    return NavigationView {
        HeroDetailView(hero: sampleHero)
    }
}
