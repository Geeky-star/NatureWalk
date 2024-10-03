

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var name: String = ""
    @State private var contactDetails: String = ""
    @State private var paymentInfo: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    TextField("Name", text: $name)
                }
                
                HStack {
                    Image(systemName: "phone.circle.fill")
                        .foregroundColor(.green)
                    TextField("Contact Details", text: $contactDetails)
                }
            }
            
            Section(header: Text("Payment Information")) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.orange)
                    TextField("Payment Information", text: $paymentInfo)
                }
            }
            
            Section {
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .onAppear {
            loadProfile()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func loadProfile() {
        if let currentUser = viewModel.currentUser {
            name = currentUser.name ?? ""
            contactDetails = currentUser.contactDetails ?? ""
            paymentInfo = currentUser.paymentInfo ?? ""
        }
    }
    
    private func saveProfile() {
        guard var currentUser = viewModel.currentUser else { return }
        currentUser.name = name
        currentUser.contactDetails = contactDetails
        currentUser.paymentInfo = paymentInfo
        
        viewModel.saveUserProfile(user: currentUser) { success in
            if success {
                alertMessage = "Profile updated successfully"
            } else {
                alertMessage = "Failed to update profile"
            }
            showAlert = true
        }
    }
}
