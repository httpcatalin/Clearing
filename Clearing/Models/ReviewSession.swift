import Foundation

enum ReviewMode: String {
    case detailed
    case compact
}

struct ReviewSession {
    let photos: [Photo]
    let startIndex: Int
    let mode: ReviewMode
}
