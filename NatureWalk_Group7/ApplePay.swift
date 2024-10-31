import UIKit
import PassKit

class PaymentViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paymentButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        paymentButton.addTarget(self, action: #selector(startApplePayPayment), for: .touchUpInside)
        paymentButton.frame = CGRect(x: 50, y: 100, width: 200, height: 50) // Adjust as needed
        self.view.addSubview(paymentButton)
    }

    @objc func startApplePayPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "your.merchant.id" // Replace with your Merchant ID
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "US" // Your country code
        request.currencyCode = "USD" // Your currency
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Nature Walk Session", amount: NSDecimalNumber(string: "10.00"))
        ]

        if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
            paymentVC.delegate = self
            present(paymentVC, animated: true, completion: nil)
        }
    }

    // Handle the result of the Apple Pay authorization
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Handle payment success here
        // Send payment.token to your server for processing

        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
