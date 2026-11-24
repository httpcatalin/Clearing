import Foundation

final class DeletePhotoAction: PhotoAction {
    private(set) var photosToDelete: [Photo] = []

    var handledPhotos: [Photo] {
        photosToDelete
    }

    func execute(on photo: Photo) {
        photosToDelete.append(photo)
    }

    func undo(on photo: Photo) {
        photosToDelete.removeAll { $0.id == photo.id }
    }
}
