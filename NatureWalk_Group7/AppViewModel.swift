

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class AppViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var sessions: [Session]
    @Published var favoriteSessions: [Session] = []
    private var db = Firestore.firestore()
    
    init() {
        self.currentUser = nil
        self.sessions = []
        
        loadUser()
        loadSessions()
        fetchFavoritesFromFirestore()
        
        self.sessions = [
            Session(name: "Morning Walk", price: 10.00, images: ["morning_walkk", "morning_walk2"], description: "Enjoy a refreshing morning walk", starRating: 4, guideName: "Franck Venance", guidePhoneNumber: "1234567890", imageName: "morninng-walk",address: "123 Morning Walk St, Ottawa, Canada"),
            Session(name: "Evening Stroll", price: 15.00, images: ["evening_stroll1", "evening_stroll2"], description: "Relax with an evening stroll", starRating: 5, guideName: "Kris Paul", guidePhoneNumber: "0987654321", imageName: "eveninng-stroll",address: "456 Evening Stroll Blvd, Ottawa, Canada"),
            Session(name: "Night Hike", price: 20.00, images: ["night_hike1", "night_hike2"], description: "Experience the thrill of a night hike", starRating: 3, guideName: "Lionnel Messi", guidePhoneNumber: "1122334455", imageName: "night_hike",address: "789 Night Hike Ave, Ottawa, Canada")
        ]
        
        autoLogin()
    }
    
    func loadUser() {
        if let savedUser = UserDefaults.standard.data(forKey: "savedUser") {
            do {
                let decodedUser = try JSONDecoder().decode(AppUser.self, from: savedUser)
                currentUser = decodedUser
                fetchUserProfile()
                fetchFavoritesFromFirestore()
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
            }
        }
    }
    
    func saveUser(user: AppUser?) {
        if let user = user {
            do {
                let encodedUser = try JSONEncoder().encode(user)
                UserDefaults.standard.set(encodedUser, forKey: "savedUser")
                saveUserProfile(user: user)
            } catch {
                print("Error encoding user: \(error.localizedDescription)")
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "savedUser")
        }
        currentUser = user
    }
    
    func saveUserProfile(user: AppUser, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let userRef = db.collection("users").document(userId)
        do {
            try userRef.setData(from: user) { error in
                if let error = error {
                    print("Error saving user profile: \(error)")
                    completion(false)
                } else {
                    self.currentUser = user
                    completion(true)
                }
            }
        } catch {
            print("Error encoding user profile: \(error)")
            completion(false)
        }
    }
    
    func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user profile: \(error)")
                return
            }
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: AppUser.self)
                    self.currentUser = user
                } catch {
                    print("Error decoding user profile: \(error)")
                }
            }
        }
    }
    
    func addToFavorites(session: Session) {
        guard let currentUser = currentUser else { return }
        if !favoriteSessions.contains(where: { $0.id == session.id }) {
            favoriteSessions.append(session)
            saveFavoritesToFirestore()
        }
    }
    
    func removeFavorite(at offsets: IndexSet) {
        favoriteSessions.remove(atOffsets: offsets)
        saveFavoritesToFirestore()
    }
    
    func clearFavorites() {
        favoriteSessions.removeAll()
        saveFavoritesToFirestore()
    }
    
    private func saveFavoritesToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userFavoritesRef = db.collection("users").document(userId).collection("favorites")
        
        // Remove all existing favorites
        userFavoritesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            for document in snapshot?.documents ?? [] {
                document.reference.delete()
            }
            
            // Add new favorites
            for session in self.favoriteSessions {
                do {
                    try userFavoritesRef.document(session.id.uuidString).setData(from: session)
                } catch {
                    print("Error saving favorite: \(error)")
                }
            }
        }
    }
    
    func fetchFavoritesFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userFavoritesRef = db.collection("users").document(userId).collection("favorites")
        
        userFavoritesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.favoriteSessions = snapshot?.documents.compactMap { document in
                try? document.data(as: Session.self)
            } ?? []
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                if rememberMe {
                    let user = AppUser(email: email, password: password, name: nil, contactDetails: nil, paymentInfo: nil)
                    self.saveUser(user: user)
                }
                self.fetchUserProfile()
                self.fetchFavoritesFromFirestore()
                completion(true, nil)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                let user = AppUser(email: email, password: password, name: nil, contactDetails: nil, paymentInfo: nil)
                self.saveUser(user: user)
                self.fetchUserProfile()
                self.fetchFavoritesFromFirestore()
                completion(true, nil)
            }
        }
    }
    
    func autoLogin() {
        if let savedUser = currentUser {
            login(email: savedUser.email, password: savedUser.password, rememberMe: true) { success, error in
                if !success {
                    self.currentUser = nil
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            saveUser(user: nil)
            currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func loadSessions() {
        // Load sessions from Firestore or hardcoded for now
    }
    
    func addPurchase(purchase: Purchase) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userPurchasesRef = db.collection("users").document(userId).collection("purchases")
        
        do {
            try userPurchasesRef.document(purchase.id).setData(from: purchase)
        } catch {
            print("Error adding purchase: \(error)")
        }
    }
    
    func fetchPurchasedTickets(completion: @escaping ([Purchase]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        let userPurchasesRef = db.collection("users").document(userId).collection("purchases")
        userPurchasesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting purchased tickets: \(error)")
                completion([])
                return
            }
            let purchases = querySnapshot?.documents.compactMap {
                try? $0.data(as: Purchase.self)
            } ?? []
            completion(purchases)
        }
    }
}
