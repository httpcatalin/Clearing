import Foundation

protocol PhotoAction {
    var handledPhotos: [Photo] { get }
    func execute(on photo: Photo)
}
