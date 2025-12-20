import SwiftUI
import PhotosUI
import AVFoundation

struct AddPlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var placeManager = PlaceManager.shared
    
    var editingPlace: Place? = nil
    
    @State private var placeName: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedWeather: Int? = nil
    @State private var temperature: Int = 20
    @State private var notes: String = ""
    @State private var selectedImage: UIImage? = nil
    
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showDatePicker = false
    @State private var showTemperaturePicker = false
    @State private var showCameraPermissionAlert = false
    @State private var showPhotoLibraryPermissionAlert = false
    
    private let maxNotesLength = 200
    
    private let weatherTypes = [
        (1, "Sunny"),
        (2, "Partly Cloudy"),
        (3, "Cloudy"),
        (4, "Rainy"),
        (5, "Snowy"),
        (6, "Windy")
    ]
    
    private var isEditing: Bool {
        editingPlace != nil
    }
    
    private var isFormValid: Bool {
        !placeName.isEmpty && selectedWeather != nil
    }
    
    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Text(isEditing ? "Edit Place" : "Add Place")
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
                        Text("Place Name")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                        
                        TextFieldWithFrame(text: $placeName, placeholder: "")
                        
                        Text("Date")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        Button(action: {
                            showDatePicker = true
                        }) {
                            ZStack {
                                Image("textFrame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.9)
                                
                                HStack {
                                    Text(dateFormatted)
                                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, screenWidth * 0.04)
                            }
                        }
                        
                        Text("Weather")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: screenHeight * 0.01) {
                            ForEach(weatherTypes, id: \.0) { weather in
                                Button(action: {
                                    selectedWeather = weather.0
                                }) {
                                    ZStack {
                                        Image(selectedWeather == weather.0 ? "weatherFrameOn" : "weatherFrameOff")
                                            .resizable()
                                            .scaledToFit()
                                        
                                        VStack(spacing: screenHeight * 0.005) {
                                            Image("weatherImage_\(weather.0)")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: screenHeight * 0.03)
                                            
                                            Text(weather.1)
                                                .font(.custom("Inter-Regular", size: screenHeight * 0.012))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Text("Temperature (°C)")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        Button(action: {
                            showTemperaturePicker = true
                        }) {
                            ZStack {
                                Image("textFrame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenWidth * 0.9)
                                
                                HStack {
                                    Text("\(temperature)°C")
                                        .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, screenWidth * 0.04)
                            }
                        }
                        
                        Text("Photos")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth * 0.9, height: screenHeight * 0.15)
                                .clipped()
                                .cornerRadius(screenHeight * 0.015)
                        } else {
                            Button(action: {
                                showActionSheet = true
                            }) {
                                Image("addPhoto")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight * 0.1)
                            }
                        }
                        
                        Text("Notes (\(notes.count)/\(maxNotesLength))")
                            .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.gray)
                            .padding(.top, screenHeight * 0.01)
                        
                        TextFieldWithFrame(text: $notes, placeholder: "Add notes about your experience...")
                            .onChange(of: notes) { newValue in
                                if newValue.count > maxNotesLength {
                                    notes = String(newValue.prefix(maxNotesLength))
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
                    savePlace()
                }) {
                    Image("savePlace")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.9)
                        .opacity(isFormValid ? 1.0 : 0.5)
                }
                .disabled(!isFormValid)
                .padding(.vertical, screenHeight * 0.02)
            }
            
            if showDatePicker {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showDatePicker = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showDatePicker = false
                        }) {
                            Text("Done")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.018))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.015)
                    .background(Color("bgColor"))
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.dark)
                        .background(Color("bgColor"))
                }
                .background(Color("bgColor"))
                .cornerRadius(screenHeight * 0.02)
                .padding(.horizontal, screenWidth * 0.05)
            }
            
            if showTemperaturePicker {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showTemperaturePicker = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showTemperaturePicker = false
                        }) {
                            Text("Done")
                                .font(.custom("Inter-Medium", size: screenHeight * 0.018))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.015)
                    .background(Color("bgColor"))
                    
                    Picker("", selection: $temperature) {
                        ForEach(-40...50, id: \.self) { temp in
                            Text("\(temp)°C")
                                .foregroundColor(.white)
                                .tag(temp)
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
        .confirmationDialog("Select Photo", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                checkCameraPermission()
            }
            Button("Photo Library") {
                checkPhotoLibraryPermission()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to take photos.")
        }
        .alert("Photo Library Access Required", isPresented: $showPhotoLibraryPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow photo library access in Settings to select photos.")
        }
        .onAppear {
            if let place = editingPlace {
                placeName = place.name
                selectedDate = place.date
                selectedWeather = place.weatherType
                temperature = Int(place.temperature) ?? 20
                notes = place.notes
                if let photoData = place.photoData {
                    selectedImage = UIImage(data: photoData)
                }
            }
        }
    }
    
    private func savePlace() {
        var photoData: Data? = nil
        if let image = selectedImage {
            photoData = image.jpegData(compressionQuality: 0.8)
        }
        
        let newPlace = Place(
            name: placeName,
            date: selectedDate,
            weatherType: selectedWeather ?? 1,
            temperature: "\(temperature)",
            notes: notes,
            photoData: photoData
        )
        
        if let existingPlace = editingPlace {
            placeManager.updatePlace(existingPlace, with: newPlace)
        } else {
            placeManager.savePlace(newPlace)
        }
        dismiss()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sourceType = .camera
            showImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        sourceType = .camera
                        showImagePicker = true
                    } else {
                        showCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
        @unknown default:
            showCameraPermissionAlert = true
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            sourceType = .photoLibrary
            showImagePicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    } else {
                        showPhotoLibraryPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPhotoLibraryPermissionAlert = true
        @unknown default:
            showPhotoLibraryPermissionAlert = true
        }
    }
}

struct TextFieldWithFrame: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack {
            Image("textFrame")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth * 0.9)
            
            TextField(placeholder, text: $text)
                .font(.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(.white)
                .padding(.horizontal, screenWidth * 0.04)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddPlaceView()
}
