
import Foundation
import Zlib

public extension Data {
    var zlibDecompressed: Data? {
        
          let data = self.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in
            let src = ptr.baseAddress!.bindMemory(to: UInt8.self, capacity: self.count)
            
            var outSize : UInt32
            let uintPointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            guard let buffer = zUncompress(src, UInt32(self.count),uintPointer) else {
                return nil as Data?
            }
            outSize=uintPointer.pointee
            let result = Data(bytes: buffer, count:Int(outSize))
            zFree(buffer)
            return result
        })
        return data
    }
    

    var zlibCompressed: Data? {
        let data = self.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in
            let src = ptr.baseAddress!.bindMemory(to: UInt8.self, capacity: self.count)
            
            var outSize : UInt32
            let uintPointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            guard let buffer = zCompress(src, UInt32(self.count),uintPointer) else {
                return nil as Data?
            }
            outSize=uintPointer.pointee
            let result = Data(bytes: buffer, count:Int(outSize));
            zFree(buffer)
            return result;
         })
        return data
    }
}
