import Foundation

class PhotoActionDecorator: PhotoAction {
    private let wrappedAction: PhotoAction

    init(wrapping action: PhotoAction) {
        wrappedAction = action
    }

    var handledPhotos: [Photo] {
        wrappedAction.handledPhotos
    }

    func execute(on photo: Photo) {
        wrappedAction.execute(on: photo)
    }

    func undo(on photo: Photo) {
        wrappedAction.undo(on: photo)
    }
}
