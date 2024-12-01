import UIKit

public extension UIImage {
    static func from(webpData: Data) -> UIImage? {
        let image = FoxWebpDecoder.decode(from: webpData)
        return image
    }
}
