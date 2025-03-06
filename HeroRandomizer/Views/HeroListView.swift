import SwiftUI
import Combine

class HeroViewModel: ObservableObject {
    @Published var heroes: [Superhero] = []
    @Published var currentHero: Superhero?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var filteredHeroes: [Superhero] = []
    @Published var isSearchActive: Bool = false
    
    private var allHeroes: [Superhero] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAllHeroes()
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.filterHeroes(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadAllHeroes() {
        isLoading = true
        errorMessage = nil
        
        NetworkManager.shared.fetchAllHeroes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.description
                }
            }, receiveValue: { [weak self] heroes in
                self?.allHeroes = heroes
                self?.getRandomHero()
                self?.filterHeroes(searchText: self?.searchText ?? "")
            })
            .store(in: &cancellables)
    }
    
    func getRandomHero() {
        guard !allHeroes.isEmpty else { return }
        currentHero = allHeroes.randomElement()
    }
    
    func filterHeroes(searchText: String) {
        if searchText.isEmpty {
            filteredHeroes = allHeroes
            isSearchActive = false
        } else {
            filteredHeroes = allHeroes.filter { hero in
                hero.name.lowercased().contains(searchText.lowercased()) ||
                hero.biography.fullName.lowercased().contains(searchText.lowercased())
            }
            isSearchActive = true
        }
    }
}

struct HeroListView: View {
    @StateObject private var viewModel = HeroViewModel()
    @State private var showingDetailView = false
    @State private var showingFavorites = false
    @State private var isSearchBarFocused = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(error: errorMessage) {
                        viewModel.loadAllHeroes()
                    }
                } else {
                    VStack(spacing: 0) {
                        searchBar
                        
                        if viewModel.isSearchActive {
                            searchResultsList
                        } else {
                            randomHeroView
                        }
                    }
                    .navigationBarTitle("Hero Randomizer", displayMode: .large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingFavorites.toggle()
                            }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .sheet(isPresented: $showingFavorites) {
                        FavoritesView()
                    }
                }
            }
        }
    }
    
    // MARK: - UI Components
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search heroes...", text: $viewModel.searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                ForEach(viewModel.filteredHeroes) { hero in
                    HeroCard(hero: hero) {
                        viewModel.currentHero = hero
                        showingDetailView = true
                    }
                    .frame(height: 240)
                }
            }
            .padding()
        }
        .overlay(
            Group {
                if viewModel.filteredHeroes.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No heroes found")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                }
            }
        )
        .background(
            NavigationLink(
                destination: Group {
                    if let hero = viewModel.currentHero {
                        HeroDetailView(hero: hero)
                    }
                },
                isActive: $showingDetailView
            ) {
                EmptyView()
            }
        )
    }
    
    private var randomHeroView: some View {
        VStack {
            Spacer()
            
            if let hero = viewModel.currentHero {
                VStack(spacing: 20) {
                    ZStack {
                        AsyncImage(url: URL(string: hero.images.lg)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 400)
                                    .clipped()
                                    .cornerRadius(20)
                            } else if phase.error != nil {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 400)
                                    .cornerRadius(20)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 70))
                                            .foregroundColor(.gray)
                                    )
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 400)
                                    .cornerRadius(20)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .scaleEffect(1.5)
                                    )
                            }
                        }
                        
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(width: UIScreen.main.bounds.width - 40, height: 400)
                        .cornerRadius(20)
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(hero.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                if !hero.biography.fullName.isEmpty {
                                    Text(hero.biography.fullName)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Text(hero.biography.publisher ?? "Unknown Publisher")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(width: UIScreen.main.bounds.width - 40, height: 400, alignment: .leading)
                    }
                    .shadow(radius: 10)
                    
                    HStack(spacing: 15) {
                        statBox(value: hero.powerstats.intelligence, label: "INT", color: .blue)
                        statBox(value: hero.powerstats.strength, label: "STR", color: .red)
                        statBox(value: hero.powerstats.speed, label: "SPD", color: .green)
                        statBox(value: hero.powerstats.durability, label: "DUR", color: .orange)
                        statBox(value: hero.powerstats.power, label: "POW", color: .purple)
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            showingDetailView = true
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("View Details")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.getRandomHero()
                            }
                        }) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Random")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.purple)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .background(
                    NavigationLink(
                        destination: HeroDetailView(hero: hero),
                        isActive: $showingDetailView
                    ) {
                        EmptyView()
                    }
                )
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Views
    private func statBox(value: Int, label: String, color: Color) -> some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(value)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
    }
}

#Preview {
    HeroListView()
}
