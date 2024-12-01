import Foundation
import CoreGraphics
import FoxwebpBridge

extension CGImage {
    static func createFrom(
        webpImageData data: WebPData,
        colorSpace: CGColorSpace,
        size: CGSize
    ) -> CGImage? {
        var config = WebPDecoderConfig()
        
        guard WebPInitDecoderConfig(&config) != 0,
              WebPGetFeatures(data.bytes, data.size, &config.input) == VP8_STATUS_OK
        else { return nil }
        
        let hasAlpha = config.input.has_alpha != 0
        let pixelFormat = FoxImagePixelFormat.preffered(hasAlpha)
        
        var bitmapInfo = pixelFormat.bitmapInfo
        var mode = convertCSPMode(from: pixelFormat.bitmapInfo)
        
        if mode == MODE_LAST {
            mode = MODE_rgbA
            bitmapInfo = .byteOrderDefault
            bitmapInfo.formUnion(CGBitmapInfo(
                rawValue: hasAlpha
                ? CGImageAlphaInfo.premultipliedLast.rawValue
                : CGImageAlphaInfo.noneSkipLast.rawValue
            ))
        }
        
        config.output.colorspace = mode
        config.options.use_threads = 1
        
        var width = config.input.width
        var height = config.input.height
        
        if (size.width != 0 && size.height != 0) {
            config.options.use_scaling = 1
            config.options.scaled_width = Int32(size.width)
            config.options.scaled_height = Int32(size.height)
            width = Int32(size.width)
            height = Int32(size.height)
        }
        
        let bitsPerComponent = 8
        let components = (mode == MODE_RGB || mode == MODE_BGR) ? 3 : 4
        let bitsPerPixel = bitsPerComponent * components
        
        let alignment = pixelFormat.alignment
        let bytesPerRow = byteAlign(size: Int(width) * (bitsPerPixel / 8), alignment: alignment)
        
        let rgba = WebPMalloc(bytesPerRow * Int(height));
        config.output.is_external_memory = 1
        config.output.u.RGBA.rgba = rgba?.assumingMemoryBound(to: UInt8.self)
        config.output.u.RGBA.stride = Int32(bytesPerRow)
        config.output.u.RGBA.size = Int(height) * bytesPerRow
        
        guard WebPDecode(data.bytes, data.size, &config) == VP8_STATUS_OK
        else { return nil }
        
        guard let provider = CGDataProvider(
            dataInfo: nil,
            data: config.output.u.RGBA.rgba,
            size: config.output.u.RGBA.size,
            releaseData: freeImageData(_:_:_:)
        ) else { return nil }
        
        let shouldInterpolate = true
        let renderingIntent = CGColorRenderingIntent.defaultIntent
        
        let image = CGImage(
            width: Int(width),
            height: Int(height),
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: shouldInterpolate,
            intent: renderingIntent
        )
        
        return image
    }
    
    static func create(
        with canvas: CGContext,
        demuxer: OpaquePointer,
        iterator: WebPIterator,
        colorSpace: CGColorSpace
    ) -> CGImage? {
        guard let image = Self.createFrom(
            webpImageData: iterator.fragment,
            colorSpace: colorSpace,
            size: .zero
        ) else { return nil }
        
        let canvasHeight = Int32(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT))
        
        let tempX = CGFloat(iterator.x_offset)
        let tempY = CGFloat(canvasHeight - iterator.height - iterator.y_offset)
        
        let imageRect = CGRect(
            x: tempX,
            y: tempY,
            width: CGFloat(iterator.width),
            height: CGFloat(iterator.height)
        )
        
        let shouldBlend = iterator.blend_method == WEBP_MUX_BLEND
        
        if !shouldBlend {
            canvas.clear(imageRect)
        }
        
        canvas.draw(image, in: imageRect)
        let newImage = canvas.makeImage()
        
        if iterator.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND {
            canvas.clear(imageRect)
        }
        
        return newImage
    }
}

// MARK: - Private

private func convertCSPMode(from bitmapInfo: CGBitmapInfo) -> WEBP_CSP_MODE {
    let alphaInfo = CGImageAlphaInfo(
        rawValue: bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
    )
    let byteOrderInfo = CGImageByteOrderInfo(
        rawValue: bitmapInfo.rawValue & CGBitmapInfo.byteOrderMask.rawValue
    )
    
    var byteOrderNormal = false
    
    switch byteOrderInfo {
    case .orderDefault:
        byteOrderNormal = true
    case .order32Little, .order16Little:
        break
    case .order32Big, .order16Big:
        byteOrderNormal = true
    default:
        break
    }
    
    switch alphaInfo {
    case .premultipliedFirst:
        return byteOrderNormal ? MODE_Argb : MODE_bgrA
    case .premultipliedLast:
        return byteOrderNormal ? MODE_rgbA : MODE_LAST
    case .none?:
        return byteOrderNormal ? MODE_RGB : MODE_BGR
    case .last, .noneSkipLast:
        return byteOrderNormal ? MODE_RGBA : MODE_LAST
    case .first, .noneSkipFirst:
        return byteOrderNormal ? MODE_ARGB : MODE_BGRA
    case .alphaOnly:
        return MODE_LAST
    default:
        return MODE_LAST
    }
}

private func byteAlign(size: Int, alignment: Int) -> Int {
    return ((size + (alignment - 1)) / alignment) * alignment
}

private func freeImageData(
    _ info: UnsafeMutableRawPointer?,
    _ data: UnsafeRawPointer,
    _ size: Int
) {
    WebPFree(UnsafeMutableRawPointer(mutating: data))
}
