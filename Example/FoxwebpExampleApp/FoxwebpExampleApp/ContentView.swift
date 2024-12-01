import SwiftUI
import Foxwebp

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            switch self.viewState {
            case .idle, .loading:
                ProgressView()
            case let .loaded(image):
                AnimationImage(image)
            }
        }
        .padding(.all, 16)
        .animationImageIsAnimating(true)
        .animationImageContentMode(.fit)
        .animationImageRepeatCount(0)
        .animationImageDelayBetween(1.5)
        .task {
            await self.load()
        }
    }
    
    @State
    private var decoder = AnimationImageDecoder()
    
    @State
    private var viewState = ViewState.idle
    
    nonisolated private func load() async {
        await MainActor.run {
            self.viewState = .loading
        }

        guard let animationURL = Bundle.main.url(
            forResource: "image",
            withExtension: "webp"
        ) else { return }

        guard let animationData = try? Data(contentsOf: animationURL)
        else { return }

        guard let image = await self.decoder.decode(from: animationData)
        else { return }

        await MainActor.run {
            self.viewState = .loaded(image)
        }
    }
}

private enum ViewState {
    case idle
    case loading
    case loaded(UIImage)
}
