import Foundation
import Observation

@Observable
final class ClearingSettings {
    static let shared = ClearingSettings()

    var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: Keys.hapticsEnabled)
        }
    }

    var reviewMode: ReviewMode {
        didSet {
            UserDefaults.standard.set(reviewMode.rawValue, forKey: Keys.reviewMode)
        }
    }

    var photoSource: PhotoSource {
        didSet {
            UserDefaults.standard.set(photoSource.rawValue, forKey: Keys.photoSource)
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        reviewMode = ReviewMode(rawValue: defaults.string(forKey: Keys.reviewMode) ?? "") ?? .detailed
        photoSource = PhotoSource(rawValue: defaults.string(forKey: Keys.photoSource) ?? "") ?? .library
    }

    private enum Keys {
        static let hapticsEnabled = "settings.hapticsEnabled"
        static let reviewMode = "settings.reviewMode"
        static let photoSource = "settings.photoSource"
    }
}
