import Foundation
import CNIOExtrasZlib

/// An error type for compression and decompression failures.
public enum CompressionError: Error {
    /// Indicates that compression failed with the provided zlib error code.
    case compressionFailed(Int32)
    /// Indicates that decompression failed with the provided zlib error code.
    case decompressionFailed(Int32)
}

public extension Data {
    
    // MARK: - RFC1950 (zlib) Functions
    
    /**
     Compresses the receiver using the zlib format (RFC 1950), which includes a header and trailer.
     
     - Returns: A `Data` object containing the zlib-compressed stream.
     - Throws: `CompressionError.compressionFailed` if compression fails.
     
     This variable initializes the zlib stream with a positive windowBits (15) so that the
     resulting stream includes the standard zlib header (typically starting with 0x78 0x9C) and trailer.
     */
    var zlibCompressed: Data {
        get throws {
            var stream = z_stream()
            stream.zalloc = nil
            stream.zfree = nil
            stream.opaque = nil
            
            // Initialize the compression stream using our inline wrapper.
            let initResult = CNIOExtrasZlib_deflateInit2(&stream,
                                                         Z_DEFAULT_COMPRESSION,
                                                         Z_DEFLATED,
                                                         15, // windowBits: 15 for zlib format
                                                         8,  // memLevel: default is usually 8
                                                         Z_DEFAULT_STRATEGY)
            guard initResult == Z_OK else {
                throw CompressionError.compressionFailed(initResult)
            }
            defer { deflateEnd(&stream) }
            
            return try self.withUnsafeBytes { srcBuffer -> Data in
                guard let srcPointer = srcBuffer.bindMemory(to: Bytef.self).baseAddress else { return Data() }
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: srcPointer)
                stream.avail_in = uInt(self.count)
                
                var output = Data()
                let chunkSize = 16384
                var buffer = [UInt8](repeating: 0, count: chunkSize)
                
                while true {
                    let deflateResult: Int32 = buffer.withUnsafeMutableBufferPointer { outBuffer in
                        stream.next_out = outBuffer.baseAddress
                        stream.avail_out = uInt(chunkSize)
                        return deflate(&stream, Z_FINISH)
                    }
                    let bytesCompressed = chunkSize - Int(stream.avail_out)
                    output.append(contentsOf: buffer.prefix(bytesCompressed))
                    
                    if deflateResult == Z_STREAM_END {
                        break
                    } else if deflateResult != Z_OK {
                        throw CompressionError.compressionFailed(deflateResult)
                    }
                }
                return output
            }
        }
    }
    
    /**
     Decompresses data that was compressed using the zlib format (RFC 1950), which includes a header and trailer.
     
     - Returns: A `Data` object containing the decompressed data.
     - Throws: `CompressionError.decompressionFailed` if decompression fails.
     
     This variable initializes the zlib stream with a positive windowBits (15) so that it expects the
     standard zlib header and trailer in the compressed data.
     */
    var zlibDecompressed: Data {
        get throws {
            var stream = z_stream()
            stream.zalloc = nil
            stream.zfree = nil
            stream.opaque = nil
            
            // windowBits = 15 tells zlib to expect a zlib header/trailer.
            let initResult = CNIOExtrasZlib_inflateInit2(&stream, 15)
            guard initResult == Z_OK else {
                throw CompressionError.decompressionFailed(initResult)
            }
            defer { inflateEnd(&stream) }
            
            return try self.withUnsafeBytes { srcBuffer -> Data in
                guard let srcPointer = srcBuffer.bindMemory(to: Bytef.self).baseAddress else { return Data() }
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: srcPointer)
                stream.avail_in = uInt(self.count)
                
                var output = Data()
                let chunkSize = 16384
                var buffer = [UInt8](repeating: 0, count: chunkSize)
                
                while true {
                    let inflateResult = buffer.withUnsafeMutableBufferPointer { outBuffer -> Int32 in
                        stream.next_out = outBuffer.baseAddress
                        stream.avail_out = uInt(chunkSize)
                        return inflate(&stream, Z_NO_FLUSH)
                    }
                    let bytesDecompressed = chunkSize - Int(stream.avail_out)
                    output.append(contentsOf: buffer.prefix(bytesDecompressed))
                    
                    if inflateResult == Z_STREAM_END {
                        break
                    } else if inflateResult != Z_OK {
                        throw CompressionError.decompressionFailed(inflateResult)
                    }
                }
                return output
            }
        }
    }
    
    // MARK: - RFC1951 (Raw DEFLATE) Functions
        
    /**
     Compresses the receiver using a raw DEFLATE stream (RFC 1951) without any zlib header or trailer.
     
     - Returns: A `Data` object containing the raw deflate-compressed stream.
     - Throws: `CompressionError.compressionFailed` if compression fails.
     
     By using a negative windowBits value (-15), this function produces a stream that does not include
     the zlib header and trailer, resulting in a pure DEFLATE (RFC 1951) output.
     */
    var deflateCompressed: Data {
        get throws {
            var stream = z_stream()
            stream.zalloc = nil
            stream.zfree = nil
            stream.opaque = nil

            // windowBits = -15 produces a raw DEFLATE stream (RFC1951), no header/trailer.
            let initResult = CNIOExtrasZlib_deflateInit2(&stream,
                                                         Z_DEFAULT_COMPRESSION,
                                                         Z_DEFLATED,
                                                         -15,
                                                         8,
                                                         Z_DEFAULT_STRATEGY)
            guard initResult == Z_OK else {
                throw CompressionError.compressionFailed(initResult)
            }
            defer { deflateEnd(&stream) }
            
            return try self.withUnsafeBytes { srcBuffer -> Data in
                guard let srcPointer = srcBuffer.bindMemory(to: Bytef.self).baseAddress else { return Data() }
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: srcPointer)
                stream.avail_in = uInt(self.count)
                
                var output = Data()
                let chunkSize = 16384
                var buffer = [UInt8](repeating: 0, count: chunkSize)
                
                while true {
                    let deflateResult = buffer.withUnsafeMutableBufferPointer { outBuffer -> Int32 in
                        stream.next_out = outBuffer.baseAddress
                        stream.avail_out = uInt(chunkSize)
                        return deflate(&stream, Z_FINISH)
                    }
                    let bytesCompressed = chunkSize - Int(stream.avail_out)
                    output.append(contentsOf: buffer.prefix(bytesCompressed))
                    
                    if deflateResult == Z_STREAM_END {
                        break
                    } else if deflateResult != Z_OK {
                        throw CompressionError.compressionFailed(deflateResult)
                    }
                }
                return output
            }
        }
    }
    
    /**
     Decompresses data that was compressed using a raw DEFLATE stream (RFC 1951) without any zlib header or trailer.
     
     - Returns: A `Data` object containing the decompressed data.
     - Throws: `CompressionError.decompressionFailed` if decompression fails.
     
     This variable initializes the zlib stream with a negative windowBits value (-15) so that it expects a raw
     DEFLATE stream without any header or trailer.
     */
    var deflateDecompressed: Data {
        get throws {
            var stream = z_stream()
            stream.zalloc = nil
            stream.zfree = nil
            stream.opaque = nil
            
            // windowBits = -15 tells zlib to expect a raw DEFLATE stream.
            let initResult = CNIOExtrasZlib_inflateInit2(&stream, -15)
            guard initResult == Z_OK else {
                throw CompressionError.decompressionFailed(initResult)
            }
            defer { inflateEnd(&stream) }
            
            return try self.withUnsafeBytes { srcBuffer -> Data in
                guard let srcPointer = srcBuffer.bindMemory(to: Bytef.self).baseAddress else { return Data() }
                stream.next_in = UnsafeMutablePointer<Bytef>(mutating: srcPointer)
                stream.avail_in = uInt(self.count)
                
                var output = Data()
                let chunkSize = 16384
                var buffer = [UInt8](repeating: 0, count: chunkSize)
                
                while true {
                    let inflateResult = buffer.withUnsafeMutableBufferPointer { outBuffer -> Int32 in
                        stream.next_out = outBuffer.baseAddress
                        stream.avail_out = uInt(chunkSize)
                        return inflate(&stream, Z_NO_FLUSH)
                    }
                    let bytesDecompressed = chunkSize - Int(stream.avail_out)
                    output.append(contentsOf: buffer.prefix(bytesDecompressed))
                    
                    if inflateResult == Z_STREAM_END {
                        break
                    } else if inflateResult != Z_OK {
                        throw CompressionError.decompressionFailed(inflateResult)
                    }
                }
                return output
            }
        }
    }
}
