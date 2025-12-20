import SwiftUI

struct SelectPlaceView: View {
    @Binding var isPresented: Bool
    let tripTypeId: Int
    let tripTypeName: String
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var placeManager = PlaceManager.shared
    @ObservedObject private var itemManager = ItemManager.shared
    @ObservedObject private var tripManager = TripManager.shared
    @State private var showAddPlace = false
    @State private var showChoosePlace = false
    @State private var selectedPlaces: [Place] = []
    @State private var openPlaceId: UUID? = nil
    
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
                
                HStack(spacing: screenHeight * 0.01) {
                    Image("longLineOn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.45)
                    
                    Image("longLineOn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.45)
                }
                .padding(.top, screenHeight * 0.02)
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("backToTrip")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.35)
                    }
                    Spacer()
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.02)
                
                HStack {
                    Text("Select Place")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.025)
                
                if selectedPlaces.isEmpty {
                    VStack(spacing: screenHeight * 0.015) {
                        Button(action: {
                            showChoosePlace = true
                        }) {
                            Image("chosePlaceButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.9)
                        }
                        .opacity(placeManager.places.isEmpty ? 0.5 : 1)
                        .disabled(placeManager.places.isEmpty)
                        
                        Button(action: {
                            showAddPlace = true
                        }) {
                            Image("addNewPlace")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.9)
                        }
                        
                        Spacer()
                        
                        Text("No places yet")
                            .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                            .foregroundColor(.gray)
                        
                        Text("Add your first place to continue")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenHeight * 0.02)
                } else {
                    VStack(spacing: screenHeight * 0.015) {
                        Button(action: {
                            showChoosePlace = true
                        }) {
                            Image("chosePlaceButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.9)
                        }
                        
                        Button(action: {
                            showAddPlace = true
                        }) {
                            Image("addNewPlace")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.9)
                        }
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: screenHeight * 0.01) {
                                ForEach(selectedPlaces) { place in
                                    PlaceCard(place: place, selectedPlaces: $selectedPlaces, openPlaceId: $openPlaceId)
                                }
                            }
                        }
                        
                        Button(action: {
                            createTrip()
                        }) {
                            Image("createCheckList")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.9)
                        }
                        .padding(.bottom, screenHeight * 0.04)
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenHeight * 0.02)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddPlace, onDismiss: {
            if let lastPlace = placeManager.places.last {
                if !selectedPlaces.contains(where: { $0.id == lastPlace.id }) {
                    selectedPlaces.append(lastPlace)
                }
            }
        }) {
            AddPlaceView()
        }
        .fullScreenCover(isPresented: $showChoosePlace) {
            ChoosePlaceView(selectedPlaces: $selectedPlaces)
        }
    }
    
    private func createTrip() {
        let filteredItems: [InventoryItem]
        if tripTypeId == 0 {
            filteredItems = []
        } else {
            filteredItems = itemManager.items.filter { $0.tripTypes.contains(tripTypeId) }
        }
        
        tripManager.createTrip(
            tripTypeId: tripTypeId,
            tripTypeName: tripTypeName,
            places: selectedPlaces,
            items: filteredItems
        )
        
        isPresented = false
    }
}

struct PlaceCard: View {
    let place: Place
    @Binding var selectedPlaces: [Place]
    @Binding var openPlaceId: UUID?
    
    @State private var offset: CGFloat = 0
    @State private var isDeleting = false
    
    private var showDeleteButton: Bool {
        openPlaceId == place.id
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: {
                deletePlace()
            }) {
                Image("deleteItemButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.08)
            }
            .opacity(showDeleteButton ? 1 : 0)
            
            ZStack {
                Image("myPlaceFrame")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.9)
                
                HStack {
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        Text(place.name)
                            .font(.custom("Inter-Medium", size: screenHeight * 0.018))
                            .foregroundColor(.white)
                        
                        Text(place.dateFormatted)
                            .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image("weatherImage_\(place.weatherType)")
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenHeight * 0.05, height: screenHeight * 0.05)
                        .clipped()
                }
                .padding(.horizontal, screenWidth * 0.04)
            }
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        if abs(value.translation.width) > abs(value.translation.height) && value.translation.width < 0 {
                            if openPlaceId != place.id {
                                openPlaceId = nil
                            }
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -screenWidth * 0.15 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = -screenWidth * 0.25
                                openPlaceId = place.id
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = 0
                                openPlaceId = nil
                            }
                        }
                    }
            )
            .onTapGesture {
                if showDeleteButton {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                        openPlaceId = nil
                    }
                }
            }
            .onChange(of: openPlaceId) { newValue in
                if newValue != place.id && offset != 0 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                    }
                }
            }
        }
        .opacity(isDeleting ? 0 : 1)
    }
    
    private func deletePlace() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = -screenWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isDeleting = true
            }
            selectedPlaces.removeAll { $0.id == place.id }
        }
    }
}

struct ChoosePlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var placeManager = PlaceManager.shared
    @Binding var selectedPlaces: [Place]
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Choose Place")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.024))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.01) {
                        ForEach(placeManager.places) { place in
                            Button(action: {
                                if !selectedPlaces.contains(where: { $0.id == place.id }) {
                                    selectedPlaces.append(place)
                                }
                                dismiss()
                            }) {
                                ChoosePlaceCard(place: place, isSelected: selectedPlaces.contains(where: { $0.id == place.id }))
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenHeight * 0.02)
                }
            }
        }
    }
}

struct ChoosePlaceCard: View {
    let place: Place
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Image("myPlaceFrame")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth * 0.9)
                .opacity(isSelected ? 0.5 : 1)
            
            HStack {
                VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                    Text(place.name)
                        .font(.custom("Inter-Medium", size: screenHeight * 0.018))
                        .foregroundColor(.white)
                    
                    Text(place.dateFormatted)
                        .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image("weatherImage_\(place.weatherType)")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenHeight * 0.05, height: screenHeight * 0.05)
                    .clipped()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: screenHeight * 0.025))
                }
            }
            .padding(.horizontal, screenWidth * 0.04)
        }
    }
}

#Preview {
    SelectPlaceView(isPresented: .constant(true), tripTypeId: 1, tripTypeName: "Mountain Hiking")
}
