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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.black)
        
    }
    
    var menuButton: some View {
        Menu {
            NavigationLink(destination: ProfileView()) {
                Label("Profile", systemImage: "person.crop.circle")
            }
            
            Button(action: {
                viewModel.logout()
            }) {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
        }
    }
}
