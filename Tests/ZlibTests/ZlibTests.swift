import XCTest
@testable import ZlibSwift


final class ZlibTests: XCTestCase {

    func testZLib() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Zlib API
        guard let zCompressed = randomData.zlibCompressed else {
            XCTAssert(false)
            return
        }
    
        // decompress using zLib
        guard let decompressed = zCompressed.zlibDecompressed else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(randomData==decompressed,true)
    }

#if canImport(Darwin)
    func testDarwinCompressed() throws {
        let randomData=Data((0 ..< 64).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
        
        // generate compressed data using Zlib API
        guard let zCompressed = randomData.zlibCompressed else {
            XCTAssert(false,"Compression error")
            return
        }
        
        let darwinCompressed = try (randomData as NSData).compressed(using: .zlib) as Data

        let subData = zCompressed.subdata(in: 2..<zCompressed.count-4)

        XCTAssertEqual(subData==darwinCompressed,true)

        // decompress using Darwin
        guard let decompressed = try (subData as NSData).decompressed(using: .zlib) as Data? else {
            XCTAssert(false)
            return
        }
        XCTAssertEqual(randomData==decompressed,true)
    }
     
#endif // canImport(Darwin)
}
