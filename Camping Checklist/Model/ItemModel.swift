import Foundation

struct InventoryItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var quantity: Int
    var isAvailable: Bool
    var tripTypes: [Int]
}

class ItemManager: ObservableObject {
    static let shared = ItemManager()
    
    @Published var items: [InventoryItem] = []
    
    private let key = "savedItems"
    
    init() {
        loadItems()
    }
    
    func saveItem(_ item: InventoryItem) {
        items.append(item)
        saveItems()
    }
    
    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            items = decoded
        }
    }
    
    func deleteItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func updateItem(_ oldItem: InventoryItem, with newItem: InventoryItem) {
        if let index = items.firstIndex(where: { $0.id == oldItem.id }) {
            var updatedItem = newItem
            updatedItem.id = oldItem.id
            items[index] = updatedItem
            saveItems()
        }
    }
}

