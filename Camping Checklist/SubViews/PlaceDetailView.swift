import SwiftUI

struct PlaceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var placeManager = PlaceManager.shared
    let placeId: UUID
    @State private var showEditPlace = false
    
    private var place: Place? {
        placeManager.places.first { $0.id == placeId }
    }
    
    private var dateFormatted: String {
        guard let place = place else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: place.date)
    }
    
    var body: some View {
        ZStack {
            Image("menuBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            if let place = place {
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        Image("checkPlaceFrame")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth)
                            .ignoresSafeArea()
                        
                        VStack(spacing: screenHeight * 0.01) {
                            HStack {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image("arrowBack")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight * 0.025)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showEditPlace = true
                                }) {
                                    Image("editPlace")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight * 0.025)
                                }
                                
                                Button(action: {
                                    placeManager.deletePlace(place)
                                    dismiss()
                                }) {
                                    Image("deletePlace")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight * 0.025)
                                }
                            }
                            .padding(.top, screenHeight * 0.045)
                            
                            HStack {
                                Text(place.name)
                                    .font(.custom("Inter-Medium", size: screenHeight * 0.024))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image("weatherImage_\(place.weatherType)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenHeight * 0.05, height: screenHeight * 0.05)
                                    .clipped()
                            }
                            
                            HStack {
                                Text(dateFormatted)
                                    .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            HStack {
                                Text("Temperature: \(place.temperature)°C")
                                    .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, screenWidth * 0.05)
                    }
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                            if let photoData = place.photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.2)
                                    .clipped()
                                    .cornerRadius(screenHeight * 0.015)
                            }
                            
                            if !place.notes.isEmpty {
                                Text("Notes")
                                    .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                                    .foregroundColor(.white)
                                
                                ZStack(alignment: .topLeading) {
                                    Image("notesInfoFrame")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth * 0.9)
                                    
                                    Text(place.notes)
                                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, screenWidth * 0.04)
                                        .padding(.vertical, screenHeight * 0.015)
                                        .frame(width: screenWidth * 0.9, alignment: .topLeading)
                                }
                            }
                        }
                        .padding(.horizontal, screenWidth * 0.05)
                        .padding(.top, screenHeight * 0.02)
                    }
                    
                    Spacer()
                }
                .fullScreenCover(isPresented: $showEditPlace) {
                    AddPlaceView(editingPlace: place)
                }
            }
        }
    }
}

#Preview {
    PlaceDetailView(placeId: UUID())
}
