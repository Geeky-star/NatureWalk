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
    var id: String
    var name: String
    var price: Double
    var images: [String]
    var description: String
    var starRating: String
    var guideName: String
    var guidePhoneNumber: String
    var imageName: String
    var address: String
}

struct Purchase: Identifiable, Codable {
    var id: String // Assuming this is your id property
    
    // Other properties
    var sessionId: String
    var userId: String
    var sessionName: String
    var date: Date

    // Initialize id explicitly in initializer
    init(id: String = UUID().uuidString, sessionId: String, userId: String, sessionName: String, date: Date) {
        self.id = id
        self.sessionId = sessionId
        self.userId = userId
        self.sessionName = sessionName
        self.date = date
    }
}




