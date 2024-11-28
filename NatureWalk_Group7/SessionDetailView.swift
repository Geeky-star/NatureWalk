import SwiftUI
import MapKit

struct SessionDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var currentIndex = 0
    @State private var showingAlert = false
    @State private var region = MKCoordinateRegion()
    @State private var showMap = false
    @State private var showPurchaseModal = false // State variable for showing the modal
    @State private var isPurchaseCompleted = false
    let session: Session

    init(session: Session) {
        self.session = session
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<session.images.count, id: \.self) { index in
                            AsyncImage(url: URL(string: session.images[index])) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 250)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .shadow(radius: 5)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 250)
                                @unknown default:
                                    Image(systemName: "exclamationmark.triangle")
                                        .frame(height: 250)
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 250)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(session.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("$\(String(format: "%.2f", session.price)) / person")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.7))
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Guide: \(session.guideName)", systemImage: "person.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("Address")
                            .font(.headline)
                        
                        Text(session.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        Button(action: {
                            showMap = true
                        }) {
                            Label("Show on Map", systemImage: "map.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showMap) {
                            MapView(address: session.address)
                        }
                        
                        Text("What to Expect")
                            .font(.headline)
                        
                        Text(session.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                        HStack(spacing: 16) {
                            favoriteButton
                            callGuideButton
                        }
                        
                        shareButton
                        
                        // Purchase button to open the modal
                        Button(action: {
                            showPurchaseModal = true
                        }) {
                            Label("Purchase", systemImage: "cart.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showPurchaseModal) {
                            OrderSummaryView(session: session, onPaymentSuccess: {
                                isPurchaseCompleted = true
                                showPurchaseModal = false
                                
                                    })
                            
                            
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Added to Favorites"),
                    message: Text("\(session.name) has been added to your favorites list."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    

    private var favoriteButton: some View {
        Button(action: {
            viewModel.addToFavorites(session: session)
            showingAlert = true
        }) {
            Label("Favorite", systemImage: "heart.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private var callGuideButton: some View {
        Button(action: {
            callGuide(phoneNumber: session.guidePhoneNumber)
        }) {
            Label("Call Guide", systemImage: "phone.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private var shareButton: some View {
        Button(action: shareSession) {
            Label("Share", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    func callGuide(phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
   

    func shareSession() {
        let activityVC = UIActivityViewController(activityItems: ["Join me on this amazing nature walk: \(session.name)! It's only $\(String(format: "%.2f", session.price)) per person. Can't wait to explore nature together!"], applicationActivities: nil)
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
}



struct OrderSummaryView: View {
    let session: Session
    let onPaymentSuccess: () -> Void
    let taxRate = 0.13
    
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Order Summary")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Session: \(session.name)")
                .font(.headline)
            
            Text("Price: $\(String(format: "%.2f", session.price))")
            
            let tax = session.price * taxRate
            Text("Tax: $\(String(format: "%.2f", tax))")
            
            Text("Total: $\(String(format: "%.2f", session.price + tax))")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            
            Divider()
            
          
            PaymentFormView(onPaymentSuccess: onPaymentSuccess,session:session)
            
            
        }
        .padding()
    }
}
