import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var itemManager = ItemManager.shared
    
    var editingItem: InventoryItem? = nil
    
    @State private var itemName: String = ""
    @State private var quantity: Int = 1
    @State private var isAvailable: Bool = true
    @State private var selectedTripTypes: Set<Int> = []
    @State private var showQuantityPicker = false
    
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
    
    private var isEditing: Bool {
        editingItem != nil
    }
    
    private var isFormValid: Bool {
        !itemName.isEmpty && quantity > 0 && !selectedTripTypes.isEmpty
    }
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: screenWidth * 0.02),
            GridItem(.flexible(), spacing: screenWidth * 0.02)
        ]
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Text(isEditing ? "Edit Item" : "Add Item")
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
                    VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                        Text("Item Name")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                        
                        TextFieldWithFrame(text: $itemName, placeholder: "e.g., Tent, Sleeping Bag")
                        
                        Text("Quantity")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        Button(action: {
                            showQuantityPicker = true
                        }) {
                            ZStack {
                                Image("textFrame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.9)
                                
                                HStack {
                                    Text("\(quantity)")
                                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, screenWidth * 0.04)
                            }
                        }
                        
                        Text("Status")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        HStack(spacing: screenWidth * 0.03) {
                            Button(action: {
                                isAvailable = true
                            }) {
                                ZStack {
                                    Image(isAvailable ? "statusOnFrame" : "statusOffFrame")
                                        .resizable()
                                        .scaledToFit()
                                    
                                    HStack(spacing: screenWidth * 0.02) {
                                        Image("greenDot")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: screenHeight * 0.012)
                                        
                                        Text("Available")
                                            .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            Button(action: {
                                isAvailable = false
                            }) {
                                ZStack {
                                    Image(!isAvailable ? "statusOnFrame" : "statusOffFrame")
                                        .resizable()
                                        .scaledToFit()
                                    
                                    HStack(spacing: screenWidth * 0.02) {
                                        Image("redDot")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: screenHeight * 0.012)
                                        
                                        Text("In Repair")
                                            .font(.custom("Inter-Regular", size: screenHeight * 0.014))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        
                        Text("Trip Types")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        LazyVGrid(columns: columns, spacing: screenHeight * 0.01) {
                            ForEach(tripTypes, id: \.0) { tripType in
                                Button(action: {
                                    if selectedTripTypes.contains(tripType.0) {
                                        selectedTripTypes.remove(tripType.0)
                                    } else {
                                        selectedTripTypes.insert(tripType.0)
                                    }
                                }) {
                                    ZStack {
                                        Image(selectedTripTypes.contains(tripType.0) ? "inventoryTripFrameOn" : "inventoryTripFrame")
                                            .resizable()
                                            .scaledToFit()
                                        
                                        HStack(spacing: screenWidth * 0.02) {
                                            Image("tripType_\(tripType.0)Item")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: screenHeight * 0.04, height: screenHeight * 0.04)
                                            
                                            Text(tripType.1)
                                                .font(.custom("Inter-Regular", size: screenHeight * 0.013))
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, screenWidth * 0.025)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenHeight * 0.02)
                    .padding(.bottom, screenHeight * 0.02)
                }
                .frame(maxHeight: .infinity)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Button(action: {
                    saveItem()
                }) {
                    Image("saveItemButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.9)
                        .opacity(isFormValid ? 1.0 : 0.5)
                }
                .disabled(!isFormValid)
                .padding(.vertical, screenHeight * 0.02)
            }
            
            if showQuantityPicker {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showQuantityPicker = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showQuantityPicker = false
                        }) {
                            Text("Done")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.018))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.015)
                    .background(Color("bgColor"))
                    
                    Picker("", selection: $quantity) {
                        ForEach(1...99, id: \.self) { num in
                            Text("\(num)")
                                .foregroundColor(.white)
                                .tag(num)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .colorScheme(.dark)
                    .background(Color("bgColor"))
                }
                .background(Color("bgColor"))
                .cornerRadius(screenHeight * 0.02)
                .padding(.horizontal, screenWidth * 0.05)
            }
        }
        .onAppear {
            if let item = editingItem {
                itemName = item.name
                quantity = item.quantity
                isAvailable = item.isAvailable
                selectedTripTypes = Set(item.tripTypes)
            }
        }
    }
    
    private func saveItem() {
        let newItem = InventoryItem(
            name: itemName,
            quantity: quantity,
            isAvailable: isAvailable,
            tripTypes: Array(selectedTripTypes).sorted()
        )
        
        if let existingItem = editingItem {
            itemManager.updateItem(existingItem, with: newItem)
        } else {
            itemManager.saveItem(newItem)
        }
        dismiss()
    }
}

#Preview {
    AddItemView()
}

