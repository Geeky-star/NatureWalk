import SwiftUI

struct FavoritesListView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack{
            Text("Favorites")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            List {
                if viewModel.favoriteSessions.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(viewModel.favoriteSessions) { session in
                        NavigationLink(destination: SessionDetailView(session: session)) {
                            SessionRowView(session: session)
                                .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        viewModel.favoriteSessions.remove(atOffsets: indexSet)
                    })
                }
            }
        }
       
        
    }
}
