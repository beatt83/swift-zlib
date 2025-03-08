import XCTest
@testable import ZlibSwift


final class ZlibTests: XCTestCase {

    func testZLib() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Zlib API
        guard let zCompressed = randomData.zCompressed else {
            XCTAssert(false)
            return
        }
    
        // decompress using zLib
        guard let decompressed = zCompressed.zDecompressed else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(randomData==decompressed,true)
    }

    
#if canImport(Darwin)
    func testDarwinDecompressed() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Darwin API
        let darwinCompressed = try (randomData as NSData).compressed(using: .zlib) as Data
                      
        // decompress using zLib
        guard let decompressed = darwinCompressed.zDecompressed else {
            XCTAssert(false)
            return
        }
        
        
        XCTAssertEqual(randomData==decompressed,true)
    }
    
    func testDarwinCompressed() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Zlib API
        guard let zCompressed = randomData.zCompressed else {
            XCTAssert(false,"Compression error")
            return
        }
        
        // decompress using Darwin
        guard let decompressed = try (zCompressed as NSData).decompressed(using: .zlib) as Data? else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(randomData==decompressed,true)
    }
     
#endif // canImport(Darwin)
}
