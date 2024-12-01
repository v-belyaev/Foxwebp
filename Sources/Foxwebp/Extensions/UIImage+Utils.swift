import UIKit

extension UIImage {
    static let alphaDummy: UIImage = {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1
        format.opaque = false
        
        let size = CGSize(width: 1, height: 1)
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fill([CGRect(origin: .zero, size: size)])
        }
        return image
    }()
    
    static let nonAlphaDummy: UIImage = {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1
        format.opaque = true
        
        let size = CGSize(width: 1, height: 1)
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.fill([CGRect(origin: .zero, size: size)])
        }
        return image
    }()
    
    static func animatedImage(with frames: [FoxImageFrame]) -> UIImage? {
        guard !frames.isEmpty
        else { return nil }
        
        let durations: [UInt] = frames.map {
            UInt($0.duration * 1000)
        }
        
        let gcd = gcdArray(durations)
        
        var animatedImages: [UIImage] = []
        var totalDuration: TimeInterval = 0
        
        frames.forEach {
            let image = $0.image
            let duration = $0.duration * 1000
            
            totalDuration += duration
            
            let repeatCount = gcd != 0 ? (UInt(duration) / gcd) : 1
            
            for _ in 0..<repeatCount {
                animatedImages.append(image)
            }
        }
        
        let animatedImage = UIImage.animatedImage(
            with: animatedImages,
            duration: totalDuration
        )
        
        return animatedImage
    }
}

private func gcd(_ a: UInt, _ b: UInt) -> UInt {
    var a = a
    var b = b
    
    while a != 0 {
        let c = a
        a = b % a
        b = c
    }
    
    return b
}

private func gcdArray(_ values: [UInt]) -> UInt {
    guard !values.isEmpty else {
        return 0
    }
    
    var result = values[0]
    
    for value in values.dropFirst() {
        result = gcd(value, result)
    }
    return result
}
