import Foundation

struct Photo: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let sizeInBytes: Int64
}
