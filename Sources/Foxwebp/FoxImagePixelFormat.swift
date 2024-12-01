import UIKit

struct FoxImagePixelFormat: Equatable {
    let bitmapInfo: CGBitmapInfo
    let alignment: Int
    
    static func preffered(_ hasAlpha: Bool) -> FoxImagePixelFormat {
        let image = hasAlpha ? UIImage.alphaDummy : UIImage.nonAlphaDummy
        let bitmapInfo = image.cgImage!.bitmapInfo
        
        let bitsPerComponent = ((
            bitmapInfo.rawValue & CGBitmapInfo.floatComponents.rawValue
        ) == CGBitmapInfo.floatComponents.rawValue) ? 16 : 8
        
        let components = 4
        let alignment = (bitsPerComponent / 8) * components * 8
        
        return FoxImagePixelFormat(
            bitmapInfo: bitmapInfo,
            alignment: alignment
        )
    }
}
