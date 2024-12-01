import SwiftUI

struct AnimationImageContentModeEnvironmentKey: EnvironmentKey {
    static var defaultValue: ContentMode = .fill
}

extension EnvironmentValues {
    var animationImageContentMode: ContentMode {
        get { self[AnimationImageContentModeEnvironmentKey.self] }
        set { self[AnimationImageContentModeEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Constants that define how a view’s content fills the available space
    ///
    /// The default value is `fill`
    func animationImageContentMode(_ contentMode: ContentMode) -> some View {
        environment(\.animationImageContentMode, contentMode)
    }
}
