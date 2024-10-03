
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        TabView {
            SessionListView()
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet")
                }
            
            FavoritesListView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            PurchasedTicketsView()
                .tabItem {
                    Label("Purchases", systemImage: "ticket.fill")
                }
        }
        .navigationBarItems(leading: profileButton, trailing: logoutButton)
        .navigationBarTitle("Nature Walks", displayMode: .inline)
    }
    
    var profileButton: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.crop.circle")
        }
    }
    
    var logoutButton: some View {
        Button(action: {
            viewModel.logout()
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
        }
    }
}
