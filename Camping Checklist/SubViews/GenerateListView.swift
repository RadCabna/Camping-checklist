import SwiftUI

struct SelectedTripType: Identifiable {
    let id = UUID()
    let tripTypeId: Int
    let tripTypeName: String
}

struct GenerateListView: View {
    @Binding var isPresented: Bool
    @State private var selectedTrip: SelectedTripType? = nil
    
    private let tripTypes = [
        (1, "Mountain Hiking (3 days)"),
        (2, "Lake Camping"),
        (3, "Winter Bivouac"),
        (4, "Forest Trek (1-2 days)"),
        (5, "Desert Trip"),
        (6, "Kayaking Trip"),
        (7, "Climbing + Overnight"),
        (8, "Urban Backpacking"),
        (9, "Technical Mountaineering"),
        (10, "Family Picnic with Overnight")
    ]
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: screenWidth * 0.03),
            GridItem(.flexible(), spacing: screenWidth * 0.03)
        ]
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Generate Checklist")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.024))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image("crossButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.025)
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.07)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.top, screenHeight * 0.02)
                
                HStack(spacing: screenHeight*0.01) {
                    Image("longLineOn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.45)
                    
                    Image("longLineOff")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.45)
                }
                .padding(.top, screenHeight * 0.02)
                
                HStack {
                    Text("Select Trip Type")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.025)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.015) {
                        LazyVGrid(columns: columns, spacing: screenHeight * 0.015) {
                            ForEach(tripTypes, id: \.0) { tripType in
                                Button(action: {
                                    selectedTrip = SelectedTripType(tripTypeId: tripType.0, tripTypeName: tripType.1)
                                }) {
                                    TripTypeCard(index: tripType.0, title: tripType.1)
                                }
                            }
                        }
                        
                        HStack {
                            Button(action: {
                                selectedTrip = SelectedTripType(tripTypeId: 0, tripTypeName: "Custom Trip")
                            }) {
                                Image("customeTrip")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.4)
                            }
                            Spacer()
                        }
                        .padding(.bottom, screenHeight * 0.02)
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                }
                .padding(.top, screenHeight * 0.02)
            }
        }
        .fullScreenCover(item: $selectedTrip) { trip in
            SelectPlaceView(isPresented: $isPresented, tripTypeId: trip.tripTypeId, tripTypeName: trip.tripTypeName)
        }
    }
}

struct TripTypeCard: View {
    let index: Int
    let title: String
    
    var body: some View {
        ZStack {
            Image("generateFrame")
                .resizable()
                .scaledToFit()
            
            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                Image("tripType_\(index)")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.04)
                
                Text(title)
                    .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, screenWidth * 0.03)
        }
    }
}

#Preview {
    GenerateListView(isPresented: .constant(true))
}
