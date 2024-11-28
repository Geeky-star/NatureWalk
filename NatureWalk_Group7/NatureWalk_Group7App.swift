
import SwiftUI
import FirebaseCore
import Stripe

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = "pk_test_51QMgZ8RtyUObPMT9VsAfAUM9IQdLyalOHlArHwXjOsDctp0y7CoGU4ByRsdjySeSj4HBKvqBDY3bdMWfhoqkSrzV000viRsMVN"
        return true
    }
}

@main
struct NatureWalksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = AppViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .accentColor(.black)
        }
    }
}
