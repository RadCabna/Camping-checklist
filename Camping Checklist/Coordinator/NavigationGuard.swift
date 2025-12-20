import Foundation


enum AvailableScreens {
    case LOADING
    case ONBOARDING
    case MAIN
}

class NavGuard: ObservableObject {
    @Published var currentScreen: AvailableScreens = .LOADING
    static var shared: NavGuard = .init()
}
