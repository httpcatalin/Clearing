import Foundation

enum ReviewSessionEvent {
    case started(totalPhotos: Int)
    case photoKept(Photo)
    case photoDeleted(Photo)
    case keepUndone(Photo)
    case deleteUndone(Photo)
    case finished
}

protocol ReviewSessionObserver: AnyObject {
    func update(with event: ReviewSessionEvent)
}
