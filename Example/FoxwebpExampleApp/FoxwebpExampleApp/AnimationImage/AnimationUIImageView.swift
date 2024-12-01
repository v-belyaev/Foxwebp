import SwiftUI

struct AnimationUIImageView: UIViewRepresentable {
    private let animationImage: UIImage?
    private let delayBetween: TimeInterval
    private let contentMode: ContentMode
    private let repeatCount: Int
    private let isAnimating: Bool
    
    init(
        animationImage: UIImage?,
        contentMode: ContentMode,
        repeatCount: Int,
        delayBetween: TimeInterval,
        isAnimating: Bool
    ) {
        self.animationImage = animationImage
        self.contentMode = contentMode
        self.repeatCount = repeatCount
        self.delayBetween = delayBetween
        self.isAnimating = isAnimating
    }
    
    private var image: UIImage? {
        animationImage?.images?.first
    }
    
    private var animationImages: [UIImage]? {
        animationImage?.images
    }
    
    private var animationDuration: TimeInterval {
        guard let animationImages
        else { return 0 }
        
        let duration = Double(animationImages.count / 30)
        return duration
    }
    
    func makeUIView(
        context: Context
    ) -> UIAnimationImageView {
        let view = UIAnimationImageView(frame: .zero)
        view.image = image
        view.contentMode = contentMode.uiViewContentMode
        view.animationImages = animationImages
        view.animationDuration = animationDuration
        view.animationRepeatCount = repeatCount
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }
    
    func updateUIView(
        _ uiView: UIAnimationImageView,
        context: Context
    ) {
        uiView.image = image
        uiView.contentMode = contentMode.uiViewContentMode
        uiView.animationImages = animationImages
        uiView.animationDuration = animationDuration
        uiView.animationRepeatCount = repeatCount
        
        if isAnimating {
            uiView.startAnimating(with: delayBetween)
        } else {
            uiView.stopAllAnimating()
        }
    }
}

// MARK: - ContentMode+uiViewContentMode

private extension ContentMode {
    var uiViewContentMode: UIView.ContentMode {
        switch self {
        case .fit:
            return .scaleAspectFit
        case .fill:
            return .scaleAspectFill
        }
    }
}
