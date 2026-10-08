import SwiftUI

struct LibrarySlab: View {
    let photos: [Photo]
    var opening: CGFloat
    var clearedPhotoIDs: Set<Photo.ID> = []
    var showsCleared = false
    var breathes = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let columns = 4

    var body: some View {
        SplitView(opening: opening, cornerRadius: Radius.slab, glow: Palette.glow) {
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                ForEach(rowStarts, id: \.self) { start in
                    GridRow {
                        ForEach(start..<min(start + columns, photos.count), id: \.self) { index in
                            tile(at: index)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    private var spacing: CGFloat {
        breathes ? 8 : 3
    }

    private var rowStarts: [Int] {
        Array(stride(from: 0, to: photos.count, by: columns))
    }

    private func tile(at index: Int) -> some View {
        let isCleared = showsCleared && clearedPhotoIDs.contains(photos[index].id)

        return Color.clear
            .overlay {
                Image(photos[index].imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .scaleEffect(isCleared && !reduceMotion ? 0.6 : 1)
            .opacity(isCleared ? 0 : 1)
            .animation(reduceMotion ? nil : Motion.reveal.delay(Double(index) * 0.05), value: isCleared)
    }
}

#Preview {
    LibrarySlab(photos: LocalPhotoRepository().getPhotos(), opening: 0.3)
        .frame(width: 320)
        .padding()
}
