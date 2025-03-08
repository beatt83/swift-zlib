import XCTest
@testable import Zlib


final class ZlibTests: XCTestCase {

    func testZLib() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Zlib API
        let zCompressed = try randomData.zlibCompressed
    
        // decompress using zLib
        let decompressed = try zCompressed.zlibDecompressed
        XCTAssertEqual(randomData==decompressed,true)
    }

    
#if canImport(Darwin)
    func testDarwinDecompressed() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Darwin API
        let darwinCompressed = try (randomData as NSData).compressed(using: .zlib) as Data
                      
        // decompress using zLib
        let decompressed = try darwinCompressed.deflateDecompressed
        
        
        XCTAssertEqual(randomData==decompressed,true)
    }
    
    func testDarwinCompressed() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Zlib API
        let zCompressed = try randomData.deflateCompressed
        
        // decompress using Darwin
        guard let decompressed = try (zCompressed as NSData).decompressed(using: .zlib) as Data? else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(randomData==decompressed,true)
    }
     
#endif // canImport(Darwin)
}
