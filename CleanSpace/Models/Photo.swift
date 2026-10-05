import Foundation

// SRP: Photo only describes a photo.
// It has no review logic and no UI code.
struct Photo: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let sizeInBytes: Int64
}
