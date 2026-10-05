import Foundation

// DIP: the review logic depends on this abstraction.
// Today it is implemented by LocalPhotoRepository,
// later it can be implemented by a PhotoKit repository.
protocol PhotoRepository {
    func getPhotos() -> [Photo]
}
