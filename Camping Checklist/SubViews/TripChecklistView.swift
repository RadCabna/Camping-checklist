import SwiftUI

struct TripChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var tripManager = TripManager.shared
    @ObservedObject private var itemManager = ItemManager.shared
    @State private var showAddItem = false
    
    private var checkedCount: Int {
        tripManager.currentTrip?.checklistItems.filter { $0.isChecked }.count ?? 0
    }
    
    private var totalCount: Int {
        tripManager.currentTrip?.checklistItems.count ?? 0
    }
    
    private var progress: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(checkedCount) / CGFloat(totalCount)
    }
    
    private var allItemsChecked: Bool {
        totalCount > 0 && checkedCount == totalCount
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Image("bigTopFrame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth)
                    
                    VStack(alignment: .leading, spacing: screenHeight * 0.015) {
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
                        }
                        .padding(.top, screenHeight * 0.06)
                        
                        Text(tripManager.currentTrip?.tripTypeName ?? "My Trip")
                            .font(.custom("Inter-Medium", size: screenHeight * 0.026))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Progress")
                                .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(checkedCount)/\(totalCount)")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.016))
                                .foregroundColor(.progressYellow)
                        }
                        
                        ZStack(alignment: .leading) {
                            Image("progressBar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth * 0.9)
                            
                            RoundedRectangle(cornerRadius: screenHeight * 0.005)
                                .fill(Color("progressYellow"))
                                .frame(width: screenWidth * 0.9 * progress, height: screenHeight * 0.012)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                }
                
                if tripManager.currentTrip?.checklistItems.isEmpty ?? true {
                    Spacer()
                    
                    VStack(spacing: screenHeight * 0.015) {
                        Image("itemIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.08)
                        
                        Text("No items in checklist")
                            .font(.custom("Inter-Medium", size: screenHeight * 0.02))
                            .foregroundColor(.gray)
                        
                        Text("Add items to your checklist")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showAddItem = true
                    }) {
                        Image("addItemToList")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.9)
                    }
                    .padding(.bottom, screenHeight * 0.04)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: screenHeight * 0.01) {
                            ForEach(tripManager.currentTrip?.checklistItems ?? []) { item in
                                ChecklistItemCard(item: item)
                            }
                            
                            Button(action: {
                                showAddItem = true
                            }) {
                                Image("addItemToList")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.9)
                            }
                            .padding(.top, screenHeight * 0.01)
                        }
                        .padding(.horizontal, screenWidth * 0.05)
                        .padding(.vertical, screenHeight * 0.02)
                    }
                    
                    Button(action: {
                        tripManager.finishTrip()
                        dismiss()
                    }) {
                        Image("finishTripButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.9)
                    }
                    .opacity(allItemsChecked ? 1.0 : 0.5)
                    .disabled(!allItemsChecked)
                    .padding(.bottom, screenHeight * 0.04)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddItem, onDismiss: {
            if let lastItem = itemManager.items.last {
                if !(tripManager.currentTrip?.checklistItems.contains(where: { $0.itemId == lastItem.id }) ?? false) {
                    tripManager.addItemToChecklist(lastItem)
                }
            }
        }) {
            AddItemView()
        }
    }
}

struct ChecklistItemCard: View {
    let item: ChecklistItem
    @ObservedObject private var tripManager = TripManager.shared
    
    var body: some View {
        Button(action: {
            tripManager.toggleItem(item.id)
        }) {
            ZStack {
                Image("itemListPlate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth * 0.9)
                
                HStack {
                    Image(item.isChecked ? "markOn" : "markOff")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.025)
                    
                    Text(item.name)
                        .font(.custom("Inter-Regular", size: screenHeight * 0.018))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, screenWidth * 0.04)
            }
        }
    }
}

#Preview {
    TripChecklistView()
}

