import SwiftUI

enum LoaderStatus {
    case LOADING
    case DONE
    case ERROR
}



enum Screen {
    case LOADING
    case ONBOARDING
    case MAIN
}

class OrientationManager: ObservableObject  {
    @Published var isHorizontalLock = true
    
    static var shared: OrientationManager = .init()
    
    func unlockAllOrientations() {
        isHorizontalLock = false
        updateOrientation()
    }
    
    func lockToPortrait() {
        isHorizontalLock = true
        updateOrientation()
    }
    
    private func updateOrientation() {
        if #available(iOS 16.0, *) {
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let orientations: UIInterfaceOrientationMask = self.isHorizontalLock ? .portrait : .allButUpsideDown
                    let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientations)
                    windowScene.requestGeometryUpdate(geometryPreferences) { _ in }
                    
                    for window in windowScene.windows {
                        window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}

struct RootView: View {
    @State private var status: LoaderStatus = .LOADING
    @ObservedObject private var nav: NavGuard = NavGuard.shared
    let url: URL = URL(string: "https://campchecklist.pro/load")!
    
    @ObservedObject private var orientationManager: OrientationManager = OrientationManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch status {
                case .LOADING, .ERROR:
                    switch nav.currentScreen {
                    case .LOADING:
                        Loading()
                            .edgesIgnoringSafeArea(.all)
                    case .ONBOARDING:
                        Onboarding()
                    case .MAIN:
                        MainMenu()
                    }
                case .DONE:
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                        
                        GameLoader_1E6704B4Overlay(data: .init(url: url))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }

        .onAppear {
            Task {
                let result = await GameLoader_1E6704B4StatusChecker().checkStatus(url: url)
                if result {
                    orientationManager.unlockAllOrientations()
                    self.status = .DONE
                } else {
                    orientationManager.lockToPortrait()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        if nav.isOnboardingCompleted {
                            nav.currentScreen = .MAIN
                        } else {
                            nav.currentScreen = .ONBOARDING
                        }
                    }
                    self.status = .ERROR
                }
                print(result)
            }
        }
    }
}



#Preview {
    RootView()
}
