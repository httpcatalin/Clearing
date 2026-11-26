import Foundation

final class LegacyPhotoRepositoryAdapter: PhotoRepository {
    private let provider: LegacyPhotoProvider

    init(provider: LegacyPhotoProvider) {
        self.provider = provider
    }

    func getPhotos() -> [Photo] {
        provider.fetchArchivedPhotos().map { legacyPhoto in
            convert(legacyPhoto)
        }
    }

    private func convert(_ legacyPhoto: LegacyPhoto) -> Photo {
        Photo(
            imageName: URL(filePath: legacyPhoto.fileName).deletingPathExtension().lastPathComponent,
            sizeInBytes: Int64(legacyPhoto.kilobytes) * 1_000
        )
    }
}
