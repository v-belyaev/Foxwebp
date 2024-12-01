import SwiftUI

struct AnimationImageDelayBetweenEnvironmentKey: EnvironmentKey {
    static var defaultValue: TimeInterval = 0.0
}

extension EnvironmentValues {
    var animationImageDelayBetween: TimeInterval {
        get { self[AnimationImageDelayBetweenEnvironmentKey.self] }
        set { self[AnimationImageDelayBetweenEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Specifies the number of seconds to delay between animation cycles.
    ///
    /// The default value is `0.0`
    func animationImageDelayBetween(_ delayBetween: TimeInterval) -> some View {
        environment(\.animationImageDelayBetween, delayBetween)
    }
}
