import SwiftUI

struct ReviewView: View {
    let viewModel: PhotoReviewViewModel
    let onClose: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var hasInteracted = false
    @State private var departingCards: [DepartingCard] = []
    @State private var keepArrivals = 0
    @State private var isRoomOpen = false
    @State private var showsSummary = false
    @State private var stackFrame: CGRect = .zero
    @State private var keepButtonFrame: CGRect = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let decisionThreshold: CGFloat = 110
    private let coordinateSpace = "review"

    var body: some View {
        ZStack {
            SpaceLight(openness: isRoomOpen ? 1 : 0.04 + 0.32 * viewModel.progress)
                .animation(Motion.promote, value: viewModel.progress)

            if showsSummary {
                FinishedView(viewModel: viewModel, onDone: onClose)
                    .transition(.opacity)
            } else {
                reviewLayout
                    .opacity(isRoomOpen ? 0 : 1)
                    .scaleEffect(isRoomOpen && !reduceMotion ? 0.97 : 1)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.canvas.ignoresSafeArea())
        .coordinateSpace(name: coordinateSpace)
        .sensoryFeedback(Haptics.touch, trigger: isDragging) { _, isNowDragging in
            isNowDragging
        }
        .sensoryFeedback(Haptics.threshold, trigger: isPastThreshold) { _, isPast in
            isPast
        }
        .sensoryFeedback(Haptics.keep, trigger: viewModel.keptCount) { old, new in
            new > old
        }
        .sensoryFeedback(Haptics.clear, trigger: viewModel.deletedCount) { old, new in
            new > old
        }
        .task {
            await playSwipeHint()
        }
    }

    private var reviewLayout: some View {
        VStack(spacing: 0) {
            header

            photoStack
                .readFrame(in: coordinateSpace, into: $stackFrame)
                .padding(.horizontal, 28)
                .padding(.top, 18)
                .padding(.bottom, 34)

            photoDetails

            decisionButtons
                .padding(.horizontal, 20)
                .padding(.top, 18)
        }
        .padding(.bottom, 12)
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Palette.surface, in: Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close")

            Spacer()

            ReviewProgress(
                text: viewModel.positionText,
                accessibilityText: viewModel.positionAccessibilityText,
                value: viewModel.progress
            )

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    private var photoStack: some View {
        ZStack {
            ForEach(Array(viewModel.upcomingPhotos.enumerated()).reversed(), id: \.element.id) { depth, photo in
                stackedCard(photo, depth: depth)
            }

            ForEach(departingCards) { card in
                DepartingPhotoCard(card: card, reduceMotion: reduceMotion) { finished in
                    departingCards.removeAll { $0.id == finished.id }
                    if finished.choice == .keep {
                        keepArrivals += 1
                    }
                }
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stackedCard(_ photo: Photo, depth: Int) -> some View {
        let isTop = depth == 0
        let spin: Double = isTop ? cardRotation(for: dragOffset, reduceMotion: reduceMotion) : 0
        let tilt: Double = isTop ? cardTilt(for: dragOffset, reduceMotion: reduceMotion) : 0

        return cardAppearance(photo, isTop: isTop, layer: layer(for: depth))
            .rotation3DEffect(.degrees(tilt), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .offset(isTop ? dragOffset : .zero)
            .rotationEffect(.degrees(spin), anchor: .bottom)
            .modifier(RiseInOnAppear(reduceMotion: reduceMotion))
            .zIndex(Double(-depth))
            .allowsHitTesting(isTop)
            .gesture(dragGesture)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(viewModel.positionAccessibilityText), \(viewModel.currentSizeText)")
            .accessibilityHint("Swipe right to keep, swipe left to clear")
            .accessibilityAction(named: "Keep") { commit(.keep) }
            .accessibilityAction(named: "Clear") { commit(.clear) }
            .accessibilityHidden(!isTop)
    }

    private func cardAppearance(_ photo: Photo, isTop: Bool, layer: CGFloat) -> some View {
        let lift: CGFloat = isTop ? cardLift(for: dragOffset) : 0
        let opening: CGFloat = isTop ? clearOpening : 0

        return PhotoCard(photo: photo, opening: opening)
            .animation(Motion.micro, value: isTop && isPastThreshold)
            .overlay(alignment: .top) {
                DecisionBadge(choice: activeChoice, progress: swipeProgress, isCommitted: isPastThreshold)
                    .padding(.top, 18)
                    .opacity(isTop ? 1 : 0)
            }
            .scaleEffect(1 + 0.025 * lift)
            .animation(Motion.promote) { content in
                content
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                            .fill(Palette.canvas)
                            .opacity(0.32 * layer)
                    }
                    .scaleEffect(1 - 0.05 * layer, anchor: .bottom)
                    .offset(y: 12 * layer)
            }
            .shadow(color: .black.opacity(0.16 * lift), radius: 22 * lift, y: 12 * lift)
    }

    private var photoDetails: some View {
        VStack(spacing: 6) {
            Text(viewModel.currentSizeText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text("Swipe right to keep, left to clear")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .opacity(viewModel.reviewedCount == 0 ? 1 : 0)
        }
        .opacity(viewModel.isFinished ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: viewModel.reviewedCount)
        .accessibilityHidden(true)
    }

    private var decisionButtons: some View {
        HStack(spacing: 12) {
            DecisionButton(choice: .clear, emphasis: emphasis(for: .clear)) {
                commit(.clear)
            }

            DecisionButton(choice: .keep, emphasis: emphasis(for: .keep), arrivals: keepArrivals) {
                commit(.keep)
            }
            .readFrame(in: coordinateSpace, into: $keepButtonFrame)
        }
        .disabled(viewModel.isFinished)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                hasInteracted = true
                if !isDragging {
                    isDragging = true
                }
                dragOffset = CGSize(width: value.translation.width, height: value.translation.height * 0.35)
            }
            .onEnded { value in
                isDragging = false
                let projectedWidth = value.predictedEndTranslation.width

                if abs(projectedWidth) >= decisionThreshold, let choice = ReviewChoice(dragWidth: projectedWidth) {
                    commit(choice)
                } else {
                    withAnimation(Motion.gesture) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private var swipeProgress: CGFloat {
        min(abs(dragOffset.width) / decisionThreshold, 1)
    }

    private var activeChoice: ReviewChoice? {
        ReviewChoice(dragWidth: dragOffset.width)
    }

    private var isPastThreshold: Bool {
        abs(dragOffset.width) >= decisionThreshold
    }

    private var clearOpening: CGFloat {
        guard activeChoice == .clear else { return 0 }
        return isPastThreshold ? 0.34 : 0.16 * swipeProgress
    }

    private var keepTarget: CGSize {
        CGSize(width: keepButtonFrame.midX - stackFrame.midX, height: keepButtonFrame.midY - stackFrame.midY)
    }

    private func layer(for depth: Int) -> CGFloat {
        depth == 0 ? 0 : max(CGFloat(depth) - swipeProgress, 0)
    }

    private func emphasis(for choice: ReviewChoice) -> CGFloat {
        activeChoice == choice ? swipeProgress : 0
    }

    private func commit(_ choice: ReviewChoice) {
        guard let photo = viewModel.currentPhoto else { return }
        hasInteracted = true

        departingCards.append(
            DepartingCard(photo: photo, choice: choice, startOffset: dragOffset, startOpening: clearOpening, keepTarget: keepTarget)
        )
        dragOffset = .zero

        switch choice {
        case .keep:
            viewModel.keepCurrentPhoto()
        case .clear:
            viewModel.deleteCurrentPhoto()
        }

        if viewModel.isFinished {
            finish()
        }
    }

    private func finish() {
        Task {
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 0 : 380))
            withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : Motion.completion) {
                isRoomOpen = true
            }
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 150 : 650))
            withAnimation(Motion.navigation) {
                showsSummary = true
            }
        }
    }

    private func playSwipeHint() async {
        guard viewModel.reviewedCount == 0, !reduceMotion else { return }
        try? await Task.sleep(for: .milliseconds(900))

        for width: CGFloat in [46, 0, -46, 0] {
            guard !hasInteracted else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                dragOffset = CGSize(width: width, height: 0)
            }
            try? await Task.sleep(for: .milliseconds(420))
        }
    }
}

private func cardRotation(for offset: CGSize, reduceMotion: Bool) -> Double {
    reduceMotion ? 0 : Double(offset.width / 24)
}

private func cardTilt(for offset: CGSize, reduceMotion: Bool) -> Double {
    reduceMotion ? 0 : Double(offset.width / 16)
}

private func cardLift(for offset: CGSize) -> CGFloat {
    min(abs(offset.width) / 60, 1)
}

private struct SpaceLight: View {
    let openness: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            let diagonal = hypot(proxy.size.width, proxy.size.height)

            Rectangle()
                .fill(Palette.accent)
                .frame(width: diagonal * 1.5, height: 24 + openness * diagonal * 1.3)
                .rotationEffect(-Split.angle)
                .position(x: proxy.size.width / 2, y: proxy.size.height * 0.4)
                .blur(radius: 60)
                .opacity(colorScheme == .dark ? 0.18 : 0.12)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct DecisionBadge: View {
    let choice: ReviewChoice?
    let progress: CGFloat
    let isCommitted: Bool

    var body: some View {
        if let choice {
            HStack(spacing: 6) {
                ChoiceGlyph(choice: choice, color: choice.onColor)
                    .frame(width: 16, height: 16)

                Text(choice.title.uppercased())
                    .font(Typography.badge)
                    .tracking(1.2)
            }
            .foregroundStyle(choice.onColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(choice.color, in: Capsule())
            .scaleEffect(isCommitted ? 1.06 : 0.9 + 0.1 * progress)
            .opacity(Double(progress))
            .animation(Motion.micro, value: isCommitted)
        }
    }
}

private struct DepartingCard: Identifiable {
    let id = UUID()
    let photo: Photo
    let choice: ReviewChoice
    let startOffset: CGSize
    let startOpening: CGFloat
    let keepTarget: CGSize
}

private struct DepartingPhotoCard: View {
    let card: DepartingCard
    let reduceMotion: Bool
    let onFinished: (DepartingCard) -> Void

    @State private var isGone = false

    var body: some View {
        PhotoCard(photo: card.photo, opening: opening, lidOpacity: isGone && isClear ? 0 : 1)
            .scaleEffect(scale)
            .blur(radius: isGone && isClear && !reduceMotion ? 8 : 0)
            .rotation3DEffect(.degrees(isGone ? 0 : cardTilt(for: card.startOffset, reduceMotion: reduceMotion)), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .offset(offset)
            .rotationEffect(.degrees(rotation), anchor: .bottom)
            .opacity(opacity)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onAppear {
                withAnimation(animation) {
                    isGone = true
                } completion: {
                    onFinished(card)
                }
            }
    }

    private var isClear: Bool {
        card.choice == .clear
    }

    private var opening: CGFloat {
        guard isClear, !reduceMotion else { return card.startOpening }
        return isGone ? 1.5 : card.startOpening
    }

    private var scale: CGFloat {
        let start = 1 + 0.025 * cardLift(for: card.startOffset)
        guard isGone, !reduceMotion else { return start }
        return isClear ? 1.04 : 0.12
    }

    private var offset: CGSize {
        guard isGone, !reduceMotion else { return card.startOffset }
        return isClear ? CGSize(width: card.startOffset.width - 40, height: card.startOffset.height) : card.keepTarget
    }

    private var rotation: Double {
        let start = cardRotation(for: card.startOffset, reduceMotion: reduceMotion)
        return isGone ? start * 0.3 : start
    }

    private var opacity: Double {
        guard isGone else { return 1 }
        return isClear || reduceMotion ? 0 : 0.25
    }

    private var animation: Animation {
        if reduceMotion {
            return .easeOut(duration: 0.25)
        }
        return isClear ? Motion.clear : Motion.keep
    }
}

private struct RiseInOnAppear: ViewModifier {
    let reduceMotion: Bool

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : 24)
            .onAppear {
                withAnimation(Motion.reveal) {
                    isVisible = true
                }
            }
    }
}

private extension View {
    func readFrame(in space: String, into frame: Binding<CGRect>) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        frame.wrappedValue = proxy.frame(in: .named(space))
                    }
                    .onChange(of: proxy.frame(in: .named(space))) { _, newFrame in
                        frame.wrappedValue = newFrame
                    }
            }
        }
    }
}

#Preview {
    ReviewView(
        viewModel: PhotoReviewViewModel(
            reviewService: PhotoReviewService(repository: LocalPhotoRepository())
        ),
        onClose: {}
    )
}
