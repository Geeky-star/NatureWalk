import Foundation
import FirebaseFirestoreSwift


struct AppUser: Identifiable, Codable {
    var id = UUID()
    var email: String
    var password: String
    var name: String?
    var contactDetails: String?
    var paymentInfo: String?
}


struct Session: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var price: Double
    var images: [String]
    var description: String
    var starRating: Int
    var guideName: String
    var guidePhoneNumber: String
    var imageName: String
    var address: String
}
   



