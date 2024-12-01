import SwiftUI

public struct AnimationImage: View {
    private let animationImageDark: UIImage?
    private let animationImageLight: UIImage?
    
    @Environment(\.animationImageIsAnimating)
    private var animationImageIsAnimating: Bool
    
    @Environment(\.animationImageRepeatCount)
    private var repeatCount: Int
    
    @Environment(\.animationImageContentMode)
    private var contentMode: ContentMode
    
    @Environment(\.animationImageDelayBetween)
    private var delayBetween: TimeInterval
    
    @Environment(\.scenePhase)
    private var scenePhase: ScenePhase
    
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    
    public init(_ animationImage: UIImage?) {
        self.animationImageDark = animationImage
        self.animationImageLight = animationImage
    }
    
    public init(dark: UIImage?, light: UIImage?) {
        self.animationImageDark = dark
        self.animationImageLight = light
    }
    
    public var body: some View {
        AnimationUIImageView(
            animationImage: animationImage,
            contentMode: contentMode,
            repeatCount: repeatCount,
            delayBetween: delayBetween,
            isAnimating: isAnimating
        )
    }
    
    private var animationImage: UIImage? {
        switch colorScheme {
        case .light:
            return animationImageLight
        case .dark:
            return animationImageDark
        @unknown default:
            fatalError()
        }
    }
    
    private var isAnimating: Bool {
        switch scenePhase {
        case .background, .inactive:
            return false
        case .active:
            return animationImageIsAnimating
        @unknown default:
            fatalError()
        }
    }
}
