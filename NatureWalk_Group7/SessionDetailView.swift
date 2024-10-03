import SwiftUI
import MapKit

struct SessionDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var currentIndex = 0
    @State private var showingAlert = false
    @State private var region = MKCoordinateRegion()
    @State private var showMap = false
    let session: Session
    
    let carouselImages: [String]
    
    init(session: Session) {
        self.session = session
        if session.name == "Evening Stroll" {
            carouselImages = ["evenning-stroll", "evening_stroll2"]
        } else if session.name == "Night Hike" {
            carouselImages = ["nightt_hike1", "night_hike2"]
        } else {
            carouselImages = session.images
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Carousel
                TabView(selection: $currentIndex) {
                    ForEach(0..<carouselImages.count, id: \.self) { index in
                        Image(carouselImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
                
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
                    
                    Text(getWhatToExpectText(for: session.name))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    
                    HStack(spacing: 16) {
                        favoriteButton
                        callGuideButton
                    }
                    
                    shareButton
                    purchaseButton
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationBarTitle(session.name, displayMode: .inline)
       // .alert(isPresented: $showingAlert) {
          //  Alert(title: Text("Added to Favorites"), message: Text("This session has been added to your favorites list."), dismissButton: .default(Text("OK")))
         //  print("added")
       // }
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
    
    private var purchaseButton: some View {
        Button(action: purchaseSession) {
            Label("Purchase", systemImage: "cart.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
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
    
    func purchaseSession() {
        guard let user = viewModel.currentUser else {
            // Handle case where currentUser is nil
            return
        }
        let purchase = Purchase(sessionId: session.id.uuidString, userId: user.id.uuidString, sessionName: session.name, date: Date())
        viewModel.addPurchase(purchase: purchase)
    }

    func getWhatToExpectText(for sessionName: String) -> String {
        switch sessionName {
        case "Morning Walk":
            return "Start your day with a refreshing walk in the morning dew. Enjoy the sights and sounds of nature waking up, with a gentle pace suitable for all ages."
        case "Evening Stroll":
            return "Unwind with a peaceful evening stroll. The cool breeze and setting sun provide a perfect backdrop for relaxation and reflection."
        case "Night Hike":
            return "Experience the thrill of a night hike under the stars. With lanterns to light your path, explore the nocturnal wonders of the wilderness."
        default:
            return "Join us for a delightful nature walk. Our guide will lead you through scenic trails, where you can appreciate the beauty of the natural world."
        }
    }
}
