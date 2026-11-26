import Foundation

final class LoggingPhotoActionDecorator: PhotoActionDecorator {
    private let name: String
    private let log: (String) -> Void

    init(wrapping action: PhotoAction, name: String, log: @escaping (String) -> Void) {
        self.name = name
        self.log = log
        super.init(wrapping: action)
    }

    override func execute(on photo: Photo) {
        super.execute(on: photo)
        log("\(name) \(photo.imageName)")
    }

    override func undo(on photo: Photo) {
        super.undo(on: photo)
        log("Undo \(name) \(photo.imageName)")
    }
}
