import SwiftUI

struct Loading: View {
    var body: some View {
        ZStack {
            Image("onboardBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Loading...")
                    .font(.custom("Inter-Medium", size: screenHeight * 0.022))
                    .foregroundColor(.white)
                    .padding(.bottom, screenHeight * 0.08)
            }
        }
    }
}

#Preview {
    Loading()
}
