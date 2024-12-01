import UIKit
import FoxwebpBridge

struct FoxWebpDecoder {
    static func decode(from data: Data) -> UIImage? {
        var webpData = WebPData()
        WebPDataInit(&webpData)
        
        webpData.size = data.count
        webpData.bytes = data.withUnsafeBytes {
            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }
        
        guard let demuxer = WebPDemux(&webpData)
        else { return nil }
        
        let flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS)
        let hasAlpha = (flags & ALPHA_FLAG.rawValue) != 0
        let hasAnimation = (flags & ANIMATION_FLAG.rawValue) != 0
        
        let scale: CGFloat = 1.0
        let preserveAspectRatio: Bool = true
        
        var iterator = WebPIterator()
        
        guard WebPDemuxGetFrame(demuxer, 1, &iterator) != 0 else {
            WebPDemuxReleaseIterator(&iterator)
            WebPDemuxDelete(demuxer)
            return nil
        }
        
        let colorSpace = CGColorSpace.from(demuxer)
        
        let canvasWidth = CGFloat(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH))
        let canvasHeight = CGFloat(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT))
        
        let scaledSize = CGSize(width: canvasWidth, height: canvasHeight)
        
        if !hasAnimation {
            let image = CGImage.createFrom(
                webpImageData: iterator.fragment,
                colorSpace: colorSpace,
                size: scaledSize
            )
            
            let uiImage = image.map {
                UIImage(cgImage: $0, scale: scale, orientation: .up)
            }
            
            WebPDemuxReleaseIterator(&iterator)
            WebPDemuxDelete(demuxer)
            
            return uiImage
        }
        
        guard let canvas = CGContext.createForWebpCanvas(
            hasAlpha: hasAlpha,
            canvasSize: scaledSize,
            preserveAspectRatio: preserveAspectRatio
        ) else {
            WebPDemuxReleaseIterator(&iterator)
            WebPDemuxDelete(demuxer)
            
            return nil
        }
        
        var frames: [FoxImageFrame] = []
        
        repeat {
            autoreleasepool {
                let image = CGImage.create(
                    with: canvas,
                    demuxer: demuxer,
                    iterator: iterator,
                    colorSpace: colorSpace
                )
                
                guard let image
                else { return }
                
                let uiImage = UIImage(cgImage: image, scale: scale, orientation: .up)
                let duration = TimeInterval.from(iterator: iterator)
                
                let frame = FoxImageFrame(image: uiImage, duration: duration)
                
                frames.append(frame)
            }
        } while (WebPDemuxNextFrame(&iterator) != 0)
        
        WebPDemuxReleaseIterator(&iterator)
        WebPDemuxDelete(demuxer)
        
        let animatedImage = UIImage.animatedImage(with: frames)
        return animatedImage
    }
}
