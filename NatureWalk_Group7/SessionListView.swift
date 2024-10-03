
import SwiftUI

struct SessionListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var currentIndex = 0
    
    let featuredImages = ["morning_walk1", "evening_stroll1", "night_hike"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Featured Sessions Carousel
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
                
                // Session List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Available Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.sessions) { session in
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

// SessionRowView

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 15) {
            Image(session.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 3)
            
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
