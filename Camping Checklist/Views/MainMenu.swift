import SwiftUI

struct MainMenu: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            Image("menuBG")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                switch selectedTab {
                case 0:
                    Spacer()
                    Menu1View()
                    Spacer()
                case 1:
                    Menu2View()
                case 2:
                    Menu3View()
                default:
                    Spacer()
                    Menu4View()
                    Spacer()
                }
                
                BottomBar(selectedTab: $selectedTab)
            }
        }
    }
}

struct BottomBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            Image("barFrame")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth)
            
            HStack(spacing: screenWidth * 0.08) {
                ForEach(0..<4, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Image(selectedTab == index ? "menu_\(index + 1)On" : "menu_\(index + 1)Off")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.045)
                            .padding(.bottom, screenHeight*0.01)
                    }
                }
            }
        }
    }
}

struct Menu1View: View {
    @State private var showGenerateList = false
    @State private var showMyList = false
    @ObservedObject private var tripManager = TripManager.shared
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            Image("onboardingImage_1")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.3)
            
            Button(action: {
                showGenerateList = true
            }) {
                Image("generateListButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.85)
            }
            
            Button(action: {
                showMyList = true
            }) {
                Image("myListButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.85)
            }
            .opacity(tripManager.currentTrip != nil ? 1 : 0.5)
            .disabled(tripManager.currentTrip == nil)
        }
        .fullScreenCover(isPresented: $showGenerateList) {
            GenerateListView(isPresented: $showGenerateList)
        }
        .fullScreenCover(isPresented: $showMyList) {
            TripChecklistView()
        }
    }
}

struct Menu2View: View {
    @ObservedObject private var placeManager = PlaceManager.shared
    @State private var showAddPlace = false
    @State private var selectedPlace: Place? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image("topFrame")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight * 0.16)
                    .clipped()
                    .ignoresSafeArea()
                HStack {
                    Text("Places")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.026))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddPlace = true
                    }) {
                        Image("plusButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.04)
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.bottom, screenHeight * 0.04)
            }
            .frame(height: screenHeight * 0.16)
            
            if placeManager.places.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.015) {
                    Image("geoMark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("No places yet")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                        .foregroundColor(.gray)
                    
                    Text("Add your first camping location")
                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.015) {
                        ForEach(placeManager.places) { place in
                            Button(action: {
                                selectedPlace = place
                            }) {
                                Menu2PlaceCard(place: place)
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.02)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddPlace) {
            AddPlaceView()
        }
        .fullScreenCover(item: $selectedPlace) { place in
            PlaceDetailView(placeId: place.id)
        }
    }
}

struct Menu2PlaceCard: View {
    let place: Place
    
    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: place.date)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("placeFrame")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth * 0.9)
            
            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                HStack(alignment: .top, spacing: screenWidth * 0.03) {
                    if let photoData = place.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenHeight * 0.1, height: screenHeight * 0.1)
                            .clipped()
                            .cornerRadius(screenHeight * 0.015)
                    }
                    
                    VStack(alignment: .leading, spacing: screenHeight * 0.008) {
                        Text(place.name)
                            .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                            .foregroundColor(.white)
                        
                        Text(dateFormatted)
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                        
                        Text("Temperature: \(place.temperature)°C")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                if !place.notes.isEmpty {
                    Text(place.notes)
                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, screenWidth * 0.04)
            .padding(.vertical, screenHeight * 0.015)
            
            Image("weatherImage_\(place.weatherType)")
                .resizable()
                .scaledToFill()
                .frame(width: screenHeight * 0.045, height: screenHeight * 0.045)
                .clipped()
                .padding(.top, screenHeight * 0.015)
                .padding(.trailing, screenWidth * 0.04)
        }
    }
}

struct Menu3View: View {
    @ObservedObject private var itemManager = ItemManager.shared
    @State private var showAddItem = false
    @State private var openItemId: UUID? = nil
    @State private var selectedItemForEdit: InventoryItem? = nil
    
    private let tripTypeNames: [Int: String] = [
        1: "Mountain Hiking",
        2: "Lake Camping",
        3: "Winter Bivouac",
        4: "Forest Trek",
        5: "Desert Trip",
        6: "Kayaking Trip",
        7: "Climbing",
        8: "Urban Backpacking",
        9: "Mountaineering",
        10: "Family Picnic"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image("topFrame")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight * 0.16)
                    .clipped()
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                    HStack {
                        Text("Inventory")
                            .font(.custom("Inter-Medium", size: screenHeight * 0.026))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddItem = true
                        }) {
                            Image("plusButton")
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight * 0.04)
                        }
                    }
                    
                    Text("\(itemManager.items.count) items")
                        .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.bottom, screenHeight * 0.02)
            }
            .frame(height: screenHeight * 0.16)
            
            if itemManager.items.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.015) {
                    Image("itemIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("No items in inventory")
                        .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                        .foregroundColor(.gray)
                    
                    Text("Add your first camping gear")
                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.015) {
                        ForEach(itemManager.items) { item in
                            InventoryItemCard(item: item, tripTypeNames: tripTypeNames, openItemId: $openItemId, onEdit: {
                                selectedItemForEdit = item
                            })
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.02)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddItem) {
            AddItemView()
        }
        .fullScreenCover(item: $selectedItemForEdit) { item in
            AddItemView(editingItem: item)
        }
    }
}

struct InventoryItemCard: View {
    let item: InventoryItem
    let tripTypeNames: [Int: String]
    @Binding var openItemId: UUID?
    var onEdit: () -> Void
    @ObservedObject private var itemManager = ItemManager.shared
    
    @State private var offset: CGFloat = 0
    @State private var isDeleting = false
    
    private var showDeleteButton: Bool {
        openItemId == item.id
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: {
                deleteItem()
            }) {
                Image("deleteItemButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.14)
            }
            .opacity(showDeleteButton ? 1 : 0)
            
            ZStack(alignment: .topLeading) {
                Image("inventoryItemCard")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.14)
                
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    Text(item.name)
                        .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                        .foregroundColor(.white)
                    
                    HStack(spacing: screenWidth * 0.02) {
                        Text("Qty: \(item.quantity)")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                            .foregroundColor(.gray)
                        
                        Image(item.isAvailable ? "greenDot" : "redDot")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.01)
                        
                        Text(item.isAvailable ? "Available" : "In Repair")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: screenWidth * 0.015) {
                        let visibleTypes = Array(item.tripTypes.prefix(3))
                        let hiddenCount = item.tripTypes.count - 3
                        
                        ForEach(visibleTypes, id: \.self) { typeId in
                            Text(tripTypeNames[typeId] ?? "")
                                .font(.custom("Inter-Regular", size: screenHeight * 0.011))
                                .foregroundColor(.gray)
                                .padding(.horizontal, screenWidth * 0.02)
                                .padding(.vertical, screenHeight * 0.005)
                                .background(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.005)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        if hiddenCount > 0 {
                            Text("+\(hiddenCount)")
                                .font(.custom("Inter-Regular", size: screenHeight * 0.011))
                                .foregroundColor(.gray)
                                .padding(.horizontal, screenWidth * 0.02)
                                .padding(.vertical, screenHeight * 0.005)
                                .background(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.005)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, screenWidth * 0.04)
                .padding(.vertical, screenHeight * 0.015)
            }
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        if abs(value.translation.width) > abs(value.translation.height) && value.translation.width < 0 {
                            if openItemId != item.id {
                                openItemId = nil
                            }
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -screenWidth * 0.15 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = -screenWidth * 0.3
                                openItemId = item.id
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = 0
                                openItemId = nil
                            }
                        }
                    }
            )
            .onTapGesture {
                if showDeleteButton {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                        openItemId = nil
                    }
                } else {
                    onEdit()
                }
            }
            .onChange(of: openItemId) { newValue in
                if newValue != item.id && offset != 0 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                    }
                }
            }
        }
        .opacity(isDeleting ? 0 : 1)
    }
    
    private func deleteItem() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = -screenWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isDeleting = true
            }
            itemManager.deleteItem(item)
        }
    }
}

struct Menu4View: View {
    @ObservedObject private var tripManager = TripManager.shared
    @ObservedObject private var placeManager = PlaceManager.shared
    @ObservedObject private var itemManager = ItemManager.shared
    
    @State private var isMonthSelected = true
    
    private let tripTypeNames: [Int: String] = [
        0: "Custom Trip",
        1: "Mountain Hiking",
        2: "Lake Camping",
        3: "Winter Bivouac",
        4: "Forest Trek",
        5: "Desert Trip",
        6: "Kayaking Trip",
        7: "Climbing",
        8: "Urban Backpacking",
        9: "Mountaineering",
        10: "Family Picnic"
    ]
    
    private var totalTrips: Int {
        tripManager.trips.count
    }
    
    private var totalPlaces: Int {
        placeManager.places.count
    }
    
    private var totalItems: Int {
        itemManager.items.count
    }
    
    private var hasStats: Bool {
        totalTrips > 0
    }
    
    private var tripTypeCounts: [Int: Int] {
        var counts: [Int: Int] = [:]
        for trip in tripManager.trips {
            counts[trip.tripTypeId, default: 0] += 1
        }
        return counts
    }
    
    private var maxTripCount: Int {
        max(tripTypeCounts.values.max() ?? 0, 2)
    }
    
    private var sortedTripTypes: [(Int, Int)] {
        tripTypeCounts.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image("topFrame")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight * 0.16)
                    .clipped()
                    .ignoresSafeArea()
                
                Text("Statistics")
                    .font(.custom("Inter-Medium", size: screenHeight * 0.026))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.bottom, screenHeight * 0.05)
            }
            .frame(height: screenHeight * 0.14)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: screenHeight * 0.02) {
                    HStack(spacing: screenWidth * 0.03) {
                        Button(action: {
                            isMonthSelected = true
                        }) {
                            ZStack {
                                Image(isMonthSelected ? "dateFrameOn" : "dateFrameOff")
                                    .resizable()
                                    .scaledToFit()
                                
                                Text("Month")
                                    .font(.custom("Inter-Medium", size: screenHeight * 0.016))
                                    .foregroundColor(isMonthSelected ? Color("bgColor") : .gray)
                            }
                        }
                        
                        Button(action: {
                            isMonthSelected = false
                        }) {
                            ZStack {
                                Image(!isMonthSelected ? "dateFrameOn" : "dateFrameOff")
                                    .resizable()
                                    .scaledToFit()
                                
                                Text("Year")
                                    .font(.custom("Inter-Medium", size: screenHeight * 0.016))
                                    .foregroundColor(!isMonthSelected ? Color("bgColor") : .gray)
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    
                    HStack(spacing: screenWidth * 0.03) {
                        StatisticCard(value: totalTrips, title: "Total Trips")
                        StatisticCard(value: totalPlaces, title: "Places")
                        StatisticCard(value: totalItems, title: "Items")
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    
                    if !hasStats {
                        VStack(spacing: screenHeight * 0.01) {
                            Text("No trips recorded yet")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                                .foregroundColor(.gray)
                            
                            Text("Create your first checklist to see stats")
                                .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, screenHeight * 0.1)
                    } else {
                        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                            Text("Trip Types")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                                .foregroundColor(.white)
                            
                            HStack(alignment: .bottom, spacing: screenWidth * 0.02) {
                                VStack(alignment: .trailing, spacing: 0) {
                                    ForEach((1...maxTripCount).reversed(), id: \.self) { num in
                                        Text("\(num)")
                                            .font(.custom("Inter-Regular", size: screenHeight * 0.012))
                                            .foregroundColor(.gray)
                                            .frame(height: screenHeight * 0.15 / CGFloat(maxTripCount))
                                    }
                                }
                                .frame(width: screenWidth * 0.06)
                                
                                HStack(alignment: .bottom, spacing: max(screenWidth * 0.01, screenWidth * 0.02 / CGFloat(max(sortedTripTypes.count, 1)))) {
                                    ForEach(sortedTripTypes, id: \.0) { typeId, count in
                                        VStack {
                                            RoundedRectangle(cornerRadius: screenHeight * 0.005)
                                                .fill(Color("progressYellow"))
                                                .frame(
                                                    width: max(screenWidth * 0.04, screenWidth * 0.6 / CGFloat(max(sortedTripTypes.count, 1))),
                                                    height: CGFloat(count) / CGFloat(maxTripCount) * screenHeight * 0.15
                                                )
                                        }
                                    }
                                }
                            }
                            .frame(height: screenHeight * 0.18)
                            
                            ForEach(sortedTripTypes, id: \.0) { typeId, count in
                                HStack {
                                    Image("tripType_\(typeId == 0 ? 1 : typeId)Item")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                                        .clipped()
                                        .cornerRadius(screenHeight * 0.005)
                                    
                                    Text(tripTypeNames[typeId] ?? "Unknown")
                                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(count) trips")
                                        .font(.custom("Inter-Medium", size: screenHeight * 0.016))
                                        .foregroundColor(Color("progressYellow"))
                                }
                            }
                        }
                        .padding(screenWidth * 0.04)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color("bgColor").opacity(0.5))
                        )
                        .padding(.horizontal, screenWidth * 0.05)
                        
                        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                            Text("Top Places")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                                .foregroundColor(.white)
                            
                            ForEach(Array(sortedTripTypes.prefix(5).enumerated()), id: \.element.0) { index, item in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.custom("Inter-Medium", size: screenHeight * 0.014))
                                        .foregroundColor(.white)
                                        .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                                        .background(
                                            RoundedRectangle(cornerRadius: screenHeight * 0.005)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                    
                                    Image("tripType_\(item.0 == 0 ? 1 : item.0)Item")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                                        .clipped()
                                        .cornerRadius(screenHeight * 0.005)
                                    
                                    Text(tripTypeNames[item.0] ?? "Unknown")
                                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(item.1)×")
                                        .font(.custom("Inter-Medium", size: screenHeight * 0.016))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(screenWidth * 0.04)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color("bgColor").opacity(0.5))
                        )
                        .padding(.horizontal, screenWidth * 0.05)
                    }
                }
                .padding(.top, screenHeight * 0.02)
                .padding(.bottom, screenHeight * 0.02)
            }
        }
    }
}

struct StatisticCard: View {
    let value: Int
    let title: String
    
    var body: some View {
        ZStack {
            Image("statisticFrame")
                .resizable()
                .scaledToFit()
            
            VStack(spacing: screenHeight * 0.005) {
                Text("\(value)")
                    .font(.custom("Inter-Bold", size: screenHeight * 0.03))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.custom("Inter-Regular", size: screenHeight * 0.012))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    MainMenu()
}
