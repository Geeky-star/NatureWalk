func savePaymentSuccessToFirestore(userId: String, sessionId: String) {
    let db = Firestore.firestore()
    db.collection("users").document(userId).updateData([
        "purchasedSessions": FieldValue.arrayUnion([sessionId])
    ]) { error in
        if let error = error {
            print("Error updating document: \(error)")
        } else {
            print("Document successfully updated with session purchase!")
        }
    }
}
