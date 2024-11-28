import SwiftUI
import Stripe

struct PaymentFormView: View {
    var onPaymentSuccess: () -> Void
    var session:Session
    @EnvironmentObject var viewModel: AppViewModel
    @State private var cardNumber = ""
    @State private var expirationDate = ""
    @State private var cvv =  ""
    @State private var isPaymentSuccessful = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pay with Debit/Credit Card")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            TextField("Card Number", text: $cardNumber)
                .keyboardType(.numberPad)
                .textContentType(.creditCardNumber)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)
            
            HStack(spacing: 10) {
                TextField("MM/YY", text: $expirationDate)
                    .keyboardType(.numbersAndPunctuation)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                
                TextField("CVV", text: $cvv)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            }
            .padding(.horizontal)
            
            Button(action: createPaymentIntent) {
                Text("Pay")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            if isPaymentSuccessful {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Payment Successful!")
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                .transition(.scale)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray5)) // Light gray background for the form
        .cornerRadius(15)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Payment Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func createPaymentIntent() {
        guard let url = URL(string: "http://localhost:3000/create-checkout-session") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "amount": 1000 // Amount in cents, adjust as needed
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error.localizedDescription)")
                alertMessage = "Failed to create payment intent."
                showAlert = true
                return
            }

            guard let data = data else {
                print("No data returned in response.")
                alertMessage = "No response from server."
                showAlert = true
                return
            }

            do {
                let response = try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
                let clientSecret = response.id
                print("Payment Intent created successfully. Client Secret: \(clientSecret)")
                
                DispatchQueue.main.async {
                    isPaymentSuccessful = true
                    alertMessage = "Purchase successful!"
                    showAlert = true
                    clearFields()
                    checkPaymentSuccess()
                }
                
                onPaymentSuccess()
                
                print("executed payment success ")
                        
                
                
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                alertMessage = "Failed to decode payment response."
                showAlert = true
            }
        }.resume()
    }
    
    func checkPaymentSuccess(){
        print("added purchase to backend")
        let purchase = Purchase(id: UUID().uuidString,
                                sessionId: session.id,
                                userId: "",
                                sessionName:session.name,
                                date: Date(), amount: session.price)
        self.viewModel.addPurchase(purchase: purchase)

    }
    
    func clearFields() {
        cardNumber = ""
        expirationDate = ""
        cvv = ""
    }

    struct PaymentIntentResponse: Codable {
        let id: String
    }
}
