import SwiftUI

struct PurchasedTicketsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var purchasedTickets: [Purchase] = []
    
    var body: some View {
        VStack {
            Text("Purchased Tickets")
                .font(.title)
                .padding(.top, 20)
            
            List(purchasedTickets) { purchase in
                VStack(alignment: .leading) {
                    Text("\(purchase.sessionName)")
                        .font(.headline)
                    Text("Date: \(formattedDate(from: purchase.date))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .onAppear {
                viewModel.fetchPurchasedTickets { tickets in
                    self.purchasedTickets = tickets
                }
            }
        }
        .padding()
    }
    
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
