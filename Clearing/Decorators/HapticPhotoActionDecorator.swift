import Foundation

final class HapticPhotoActionDecorator: PhotoActionDecorator {
    private let playFeedback: () -> Void

    init(wrapping action: PhotoAction, playFeedback: @escaping () -> Void) {
        self.playFeedback = playFeedback
        super.init(wrapping: action)
    }

    override func execute(on photo: Photo) {
        super.execute(on: photo)
        if ClearingSettings.shared.hapticsEnabled {
            playFeedback()
        }
    }
}
