
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSignUp = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.currentUser != nil {
                    MainTabView()
                } else {
                    loginView
                }
            }
        }
    }

    var loginView: some View {
        VStack {
            Text("Welcome to Nature Walk Adventures")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            Image("Login")
                .resizable()
                .scaledToFit()
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Toggle("Remember Me", isOn: $rememberMe)
                .padding()

            Button(action: {
                if isSignUp {
                    viewModel.signUp(email: email, password: password) { success, error in
                        if success {
                            isSignUp = false
                        } else {
                            alertMessage = error ?? "Sign up failed"
                            showAlert = true
                        }
                    }
                } else {
                    viewModel.login(email: email, password: password, rememberMe: rememberMe) { success, error in
                        if !success {
                            alertMessage = error ?? "Login failed"
                            showAlert = true
                        }
                    }
                }
            }) {
                Text(isSignUp ? "Sign Up" : "Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Button(action: {
                isSignUp.toggle()
            }) {
                Text(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .padding(.top)
            }
        }
        .padding()
        .onAppear {
            viewModel.autoLogin()
        }
    }
}
