import SwiftUI

struct AnimationImageIsAnimatingEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var animationImageIsAnimating: Bool {
        get { self[AnimationImageIsAnimatingEnvironmentKey.self] }
        set { self[AnimationImageIsAnimatingEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Boolean value indicating whether the animation is running
    ///
    /// The default value is `false`
    func animationImageIsAnimating(_ isAnimating: Bool) -> some View {
        environment(\.animationImageIsAnimating, isAnimating)
    }
}
