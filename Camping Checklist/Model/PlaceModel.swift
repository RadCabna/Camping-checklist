import Foundation
import UIKit

struct Place: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var date: Date
    var weatherType: Int
    var temperature: String
    var notes: String
    var photoData: Data?
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

class PlaceManager: ObservableObject {
    static let shared = PlaceManager()
    
    @Published var places: [Place] = []
    
    private let key = "savedPlaces"
    
    init() {
        loadPlaces()
    }
    
    func savePlace(_ place: Place) {
        places.append(place)
        savePlaces()
    }
    
    func savePlaces() {
        if let encoded = try? JSONEncoder().encode(places) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadPlaces() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Place].self, from: data) {
            places = decoded
        }
    }
    
    func deletePlace(_ place: Place) {
        places.removeAll { $0.id == place.id }
        savePlaces()
    }
    
    func updatePlace(_ oldPlace: Place, with newPlace: Place) {
        if let index = places.firstIndex(where: { $0.id == oldPlace.id }) {
            var updatedPlace = newPlace
            updatedPlace.id = oldPlace.id
            places[index] = updatedPlace
            savePlaces()
        }
    }
}

