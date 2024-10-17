import SwiftUI

struct FavoritesListView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        List {
            ForEach(viewModel.favoriteSessions) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    SessionRowView(session: session)
                }
            }
            .onDelete(perform: { indexSet in
                print(indexSet)
            })
        }
        .navigationBarItems(trailing: Button("Clear Favorites") {
           
        })
        .onAppear {
          
        }
    }
}

