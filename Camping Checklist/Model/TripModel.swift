import Foundation

struct ChecklistItem: Codable, Identifiable {
    var id: UUID = UUID()
    var itemId: UUID
    var name: String
    var isChecked: Bool = false
}

struct Trip: Codable, Identifiable {
    var id: UUID = UUID()
    var tripTypeId: Int
    var tripTypeName: String
    var places: [Place]
    var checklistItems: [ChecklistItem]
    var isCompleted: Bool = false
}

class TripManager: ObservableObject {
    static let shared = TripManager()
    
    @Published var currentTrip: Trip? = nil
    @Published var trips: [Trip] = []
    
    private let currentTripKey = "currentTrip"
    private let tripsKey = "savedTrips"
    
    init() {
        loadCurrentTrip()
        loadTrips()
    }
    
    func createTrip(tripTypeId: Int, tripTypeName: String, places: [Place], items: [InventoryItem]) {
        let checklistItems = items.map { item in
            ChecklistItem(itemId: item.id, name: item.name, isChecked: false)
        }
        
        let trip = Trip(
            tripTypeId: tripTypeId,
            tripTypeName: tripTypeName,
            places: places,
            checklistItems: checklistItems
        )
        
        currentTrip = trip
        saveCurrentTrip()
    }
    
    func toggleItem(_ itemId: UUID) {
        if let index = currentTrip?.checklistItems.firstIndex(where: { $0.id == itemId }) {
            currentTrip?.checklistItems[index].isChecked.toggle()
            saveCurrentTrip()
        }
    }
    
    func addItemToChecklist(_ item: InventoryItem) {
        let checklistItem = ChecklistItem(itemId: item.id, name: item.name, isChecked: false)
        currentTrip?.checklistItems.append(checklistItem)
        saveCurrentTrip()
    }
    
    func saveCurrentTrip() {
        if let encoded = try? JSONEncoder().encode(currentTrip) {
            UserDefaults.standard.set(encoded, forKey: currentTripKey)
        }
    }
    
    func loadCurrentTrip() {
        if let data = UserDefaults.standard.data(forKey: currentTripKey),
           let decoded = try? JSONDecoder().decode(Trip?.self, from: data) {
            currentTrip = decoded
        }
    }
    
    func finishTrip() {
        if var trip = currentTrip {
            trip.isCompleted = true
            trips.append(trip)
            saveTrips()
            currentTrip = nil
            saveCurrentTrip()
        }
    }
    
    func saveTrips() {
        if let encoded = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(encoded, forKey: tripsKey)
        }
    }
    
    func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: tripsKey),
           let decoded = try? JSONDecoder().decode([Trip].self, from: data) {
            trips = decoded
        }
    }
}

