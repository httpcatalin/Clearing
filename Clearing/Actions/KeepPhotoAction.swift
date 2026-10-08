import Foundation

final class KeepPhotoAction: PhotoAction {
    private(set) var keptPhotos: [Photo] = []

    func execute(on photo: Photo) {
        keptPhotos.append(photo)
    }
}
