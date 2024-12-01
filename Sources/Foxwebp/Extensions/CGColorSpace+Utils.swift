import Foundation
import FoxwebpBridge
import CoreGraphics

extension CGColorSpace {
    static let deviceSRGB = CGColorSpace(name: CGColorSpace.sRGB)!
    
    static func from(_ demux: OpaquePointer) -> CGColorSpace {
        let flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS)
        var chunkIterator = WebPChunkIterator()
        
        guard (flags * ICCP_FLAG.rawValue) != 0,
              WebPDemuxGetChunk(demux, "ICCP", 1, &chunkIterator) != 0
        else { return Self.deviceSRGB }
        
        let data = Data(
            bytes: chunkIterator.chunk.bytes,
            count: chunkIterator.chunk.size
        ) as CFData
        
        guard let colorSpace = CGColorSpace(iccData: data),
              colorSpace.model == CGColorSpaceModel.rgb
        else { return Self.deviceSRGB }
        
        return colorSpace
    }
}