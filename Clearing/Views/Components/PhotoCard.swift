import SwiftUI

struct PhotoCard: View {
    let photo: Photo
    var opening: CGFloat = 0
    var lidOpacity: Double = 1

    var body: some View {
        Color.clear
            .aspectRatio(3 / 4, contentMode: .fit)
            .overlay {
                SplitView(opening: opening, cornerRadius: Radius.card, lidOpacity: lidOpacity, glow: Palette.glow) {
                    Image(photo.imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
    }
}
