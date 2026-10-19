import Foundation

final class DeletePhotoActionFactory: PhotoActionFactory {
    func makeAction() -> PhotoAction {
        DeletePhotoAction()
    }
}
