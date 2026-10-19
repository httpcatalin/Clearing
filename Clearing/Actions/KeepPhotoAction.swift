import Foundation

final class KeepPhotoAction: PhotoAction {
    private(set) var keptPhotos: [Photo] = []

    var handledPhotos: [Photo] {
        keptPhotos
    }

    func execute(on photo: Photo) {
        keptPhotos.append(photo)
    }
}
