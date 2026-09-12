import Foundation

struct IndexedResource {
    enum ParseError: Error, Equatable {
        case tooSmall
        case invalidMagic
        case invalidCount
        case invalidOffset
    }

    let magic: UInt32
    let records: [Data]

    init(data: Data) throws {
        guard data.count >= 8 else { throw ParseError.tooSmall }
        let magic = data.readUInt32LE(at: 0)
        guard magic == 0x80000001 else { throw ParseError.invalidMagic }
        let count = Int(data.readUInt32LE(at: 4))
        guard count > 0, count <= (data.count - 8) / 4 else { throw ParseError.invalidCount }

        var offsets = [Int]()
        offsets.reserveCapacity(count)
        for index in 0..<count {
            let offset = Int(data.readUInt32LE(at: 8 + index * 4))
            guard offset >= 8 + count * 4, offset <= data.count else { throw ParseError.invalidOffset }
            if let previous = offsets.last, offset < previous { throw ParseError.invalidOffset }
            offsets.append(offset)
        }

        var records = [Data]()
        records.reserveCapacity(count)
        for index in 0..<count {
            let start = offsets[index]
            let end = index + 1 < count ? offsets[index + 1] : data.count
            guard end >= start else { throw ParseError.invalidOffset }
            records.append(data.subdata(in: start..<end))
        }
        self.magic = magic
        self.records = records
    }
}

private extension Data {
    func readUInt32LE(at offset: Int) -> UInt32 {
        UInt32(self[offset])
            | UInt32(self[offset + 1]) << 8
            | UInt32(self[offset + 2]) << 16
            | UInt32(self[offset + 3]) << 24
    }
}
