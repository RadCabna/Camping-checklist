import Foundation


enum AvailableScreens {
    case LOADING
    case ONBOARDING
    case MAIN
}

class NavGuard: ObservableObject {
    @Published var currentScreen: AvailableScreens = .LOADING
    static var shared: NavGuard = .init()
    
    private let onboardingCompletedKey = "onboardingCompleted"
    
    var isOnboardingCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingCompletedKey) }
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
        currentScreen = .MAIN
    }
}
