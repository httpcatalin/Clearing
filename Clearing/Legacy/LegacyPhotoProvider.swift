import Foundation

final class LegacyPhotoProvider {
    private let archivedPhotos: [LegacyPhoto] = [
        LegacyPhoto(fileName: "sample-09.jpg", kilobytes: 6_100),
        LegacyPhoto(fileName: "sample-02.jpg", kilobytes: 2_800),
        LegacyPhoto(fileName: "sample-11.jpg", kilobytes: 3_200),
        LegacyPhoto(fileName: "sample-05.jpg", kilobytes: 5_600),
        LegacyPhoto(fileName: "sample-07.jpg", kilobytes: 4_700),
        LegacyPhoto(fileName: "sample-04.jpg", kilobytes: 3_400),
        LegacyPhoto(fileName: "sample-12.jpg", kilobytes: 3_600),
        LegacyPhoto(fileName: "sample-06.jpg", kilobytes: 2_300)
    ]

    func fetchArchivedPhotos() -> [LegacyPhoto] {
        archivedPhotos
    }
}
