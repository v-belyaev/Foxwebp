import UIKit
import Foxwebp
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers

public final class AnimationImageDecoder {
    private let decodingQueue: DispatchQueue
    
    public init(
        _ decodingQueue: DispatchQueue = .init(
            label: "AnimationImageDecoder.serial_queue",
            qos: .userInitiated
        )
    ) {
        self.decodingQueue = decodingQueue
    }
    
    public func decode(from data: Data) async -> UIImage? {
        await withUnsafeContinuation { (continuation: UnsafeContinuation<UIImage?, Never>) in
            decodingQueue.async {
                guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                      let imageType = CGImageSourceGetType(imageSource),
                      let uttype = UTType(imageType as String)
                else {
                    continuation.resume(returning: nil)
                    return
                }
                
                if uttype.conforms(to: .webP) {
                    let image = UIImage.from(webpData: data)
                    continuation.resume(returning: image)
                    return
                }
                
                let count = CGImageSourceGetCount(imageSource)
                var decodedImages: [UIImage] = []
                
                for i in (0 ..< count) {
                    guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let image = UIImage(cgImage: cgImage)
                    decodedImages.append(image)
                }
                
                let animatedImage = UIImage.animatedImage(with: decodedImages, duration: 0)
                continuation.resume(returning: animatedImage)
            }
        }
    }
}
