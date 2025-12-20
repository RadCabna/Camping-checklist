import SwiftUI

struct Onboarding: View {
    @State private var currentPage: Int = 0
    @ObservedObject private var nav: NavGuard = NavGuard.shared
    
    private let titles = [
        "",
        "Works Completely Offline",
        "Reusable Inventory"
    ]
    
    private let descriptions = [
        "Generate ready-to-use packing checklists based on your trip type and destination. No more forgetting essentials.",
        "All your data is stored locally on your device. No internet connection needed, no accounts required.",
        "Build your personal gear inventory once, then reuse items across trips. Track what you use most and plan better."
    ]
    
    var body: some View {
        ZStack {
            Image("onboardBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        nav.currentScreen = .MAIN
                    }) {
                        Image("skipButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.018)
                    }
                }
                .padding(.top, screenHeight * 0.09)
                .padding(.trailing, screenWidth * 0.05)
                
                Spacer()
                
                Image("onboardingImage_\(currentPage + 1)")
                    .resizable()
                    .scaledToFit()
                    .frame(height: currentPage == 0 ? screenHeight * 0.35 : screenHeight * 0.14)
                    .padding(.bottom, currentPage == 0 ? 0 : screenHeight * 0.12)
                
                Spacer().frame(height: screenHeight * 0.03)
                
                if currentPage > 0 {
                    Text(titles[currentPage])
                        .font(.custom("Inter-Medium", size: screenHeight * 0.028))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, screenWidth * 0.1)
                    
                    Spacer().frame(height: screenHeight * 0.015)
                }
                
                Text(descriptions[currentPage])
                    .font(.custom("Inter-Regular", size: screenHeight * 0.018))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, screenWidth * 0.1)
                
                Spacer().frame(height: screenHeight * 0.04)
                
                HStack(spacing: screenWidth * 0.02) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(currentPage == index ? "onboardingOn" : "onboardingOff")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.01)
                    }
                }
                
                Spacer().frame(height: screenHeight * 0.04)
                
                if currentPage == 0 {
                    Button(action: {
                        withAnimation {
                            currentPage = 1
                        }
                    }) {
                        Image("longNext")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.9)
                    }
                } else if currentPage == 1 {
                    HStack(spacing: screenWidth * 0.03) {
                        Button(action: {
                            withAnimation {
                                currentPage = 0
                            }
                        }) {
                            Image("shortBack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.43)
                        }
                        
                        Button(action: {
                            withAnimation {
                                currentPage = 2
                            }
                        }) {
                            Image("shortNext")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.43)
                        }
                    }
                } else {
                    HStack(spacing: screenWidth * 0.03) {
                        Button(action: {
                            withAnimation {
                                currentPage = 1
                            }
                        }) {
                            Image("shortBack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.43)
                        }
                        
                        Button(action: {
                            nav.currentScreen = .MAIN
                        }) {
                            Image("shortGetStarted")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.43)
                        }
                    }
                }
                
                Spacer().frame(height: screenHeight * 0.06)
            }
        }
    }
}

#Preview {
    Onboarding()
}
