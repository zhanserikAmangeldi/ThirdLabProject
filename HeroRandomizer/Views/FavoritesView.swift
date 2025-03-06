import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var selectedHero: Superhero?
    @State private var showingDetail = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                if favoritesManager.favorites.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(favoritesManager.favorites) { hero in
                                HeroCard(hero: hero) {
                                    selectedHero = hero
                                    showingDetail = true
                                }
                                .frame(height: 240)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Favorites", displayMode: .large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(
                NavigationLink(
                    destination: Group {
                        if let hero = selectedHero {
                            HeroDetailView(hero: hero)
                        }
                    },
                    isActive: $showingDetail
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    // MARK: - UI Components
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the heart icon on any hero to add them to your favorites.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Discover Heroes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
    }
}

#Preview {
    FavoritesView()
}
