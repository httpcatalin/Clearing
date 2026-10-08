import Foundation

final class DeletePhotoAction: PhotoAction {
    private(set) var photosToDelete: [Photo] = []

    var spaceToFree: Int64 {
        photosToDelete.reduce(0) { total, photo in total + photo.sizeInBytes }
    }

    func execute(on photo: Photo) {
        photosToDelete.append(photo)
    }
}
