import Foundation

final class KeepPhotoActionFactory: PhotoActionFactory {
    func makeAction() -> PhotoAction {
        KeepPhotoAction()
    }
}
