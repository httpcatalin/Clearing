import Foundation

final class DeletePhotoAction: PhotoAction {
    private(set) var photosToDelete: [Photo] = []

    var handledPhotos: [Photo] {
        photosToDelete
    }

    func execute(on photo: Photo) {
        photosToDelete.append(photo)
    }
}
