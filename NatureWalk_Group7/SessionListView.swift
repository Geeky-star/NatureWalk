import SwiftUI

struct SessionListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var currentIndex = 0
    @State private var searchQuery: String = ""
    @State private var sortOption: SortOption = .none
    
    let featuredImages = ["morning_walk1", "evening_stroll1", "night_hike"]

    enum SortOption {
        case none
        case price
        case rating
    }
    
    var filteredSessions: [Session] {
        let filtered = viewModel.sessions.filter { session in
            searchQuery.isEmpty || session.name.lowercased().contains(searchQuery.lowercased())
        }
        
        switch sortOption {
        case .price:
            return filtered.sorted { $0.price < $1.price }
        case .rating:
            return filtered.sorted { $0.starRating > $1.starRating }
        case .none:
            return filtered
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Text("All Sessions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search sessions...", text: $searchQuery)
                            .padding(5)
                         
                        Menu {
                            Button(action: { sortOption = .price }) {
                                Label("Sort by Price", systemImage: "dollarsign.circle")
                            }
                            Button(action: { sortOption = .rating }) {
                                Label("Sort by Rating", systemImage: "star.fill")
                            }
                            Button(action: { sortOption = .none }) {
                                Label("Clear Filters", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 6)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Featured images
                TabView(selection: $currentIndex) {
                    ForEach(0..<featuredImages.count, id: \.self) { index in
                        Image(featuredImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 200)
                .cornerRadius(15)
                .padding(.horizontal)
                .shadow(radius: 5)
          
                // List of sessions
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(filteredSessions) { session in
                        NavigationLink(destination: SessionDetailView(session: session)) {
                            SessionRowView(session: session)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.vertical)
        }
    }
}


struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageUrl = URL(string: session.images[0]) {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(session.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("$\(String(format: "%.2f", session.price)) / person")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
