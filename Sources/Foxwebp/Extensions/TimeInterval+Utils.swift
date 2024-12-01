import Foundation
import FoxwebpBridge

extension TimeInterval {
    static func from(iterator: WebPIterator) -> TimeInterval {
        let duration = iterator.duration <= 10 ? 100 : iterator.duration
        return TimeInterval(duration / 1000)
    }
}
