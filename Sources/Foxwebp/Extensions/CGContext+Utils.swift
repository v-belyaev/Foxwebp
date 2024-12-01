import Foundation
import CoreGraphics

extension CGContext {
    static func createForWebpCanvas(
        hasAlpha: Bool,
        canvasSize: CGSize,
        preserveAspectRatio: Bool
    ) -> CGContext? {
        let bitmapInfo = FoxImagePixelFormat.preffered(hasAlpha).bitmapInfo
        let colorSpace = CGColorSpace.deviceSRGB
        let canvas = CGContext(
            data: nil,
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )
        return canvas
    }
}
