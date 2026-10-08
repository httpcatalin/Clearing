import Foundation

final class LocalPhotoRepository: PhotoRepository {
    private let samplePhotos: [Photo] = [
        Photo(imageName: "sample-01", sizeInBytes: 4_200_000),
        Photo(imageName: "sample-02", sizeInBytes: 2_800_000),
        Photo(imageName: "sample-03", sizeInBytes: 1_900_000),
        Photo(imageName: "sample-04", sizeInBytes: 3_400_000),
        Photo(imageName: "sample-05", sizeInBytes: 5_600_000),
        Photo(imageName: "sample-06", sizeInBytes: 2_300_000),
        Photo(imageName: "sample-07", sizeInBytes: 4_700_000),
        Photo(imageName: "sample-08", sizeInBytes: 3_900_000),
        Photo(imageName: "sample-09", sizeInBytes: 6_100_000),
        Photo(imageName: "sample-10", sizeInBytes: 2_100_000),
        Photo(imageName: "sample-11", sizeInBytes: 3_200_000),
        Photo(imageName: "sample-12", sizeInBytes: 3_600_000)
    ]

    func getPhotos() -> [Photo] {
        samplePhotos
    }
}
