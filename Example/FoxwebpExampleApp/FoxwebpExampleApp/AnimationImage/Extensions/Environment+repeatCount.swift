import SwiftUI

struct AnimationImageRepeatCountEnvironmentKey: EnvironmentKey {
    static var defaultValue: Int = 0
}

extension EnvironmentValues {
    var animationImageRepeatCount: Int {
        get { self[AnimationImageRepeatCountEnvironmentKey.self] }
        set { self[AnimationImageRepeatCountEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Specifies the number of times to repeat the animation.
    ///
    /// The default value is`0`, which specifies to repeat the animation indefinitely.
    func animationImageRepeatCount(_ repeatCount: Int) -> some View {
        environment(\.animationImageRepeatCount, repeatCount)
    }
}
