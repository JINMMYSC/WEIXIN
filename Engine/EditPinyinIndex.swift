import Foundation

/// Bounds-checked reader for the recovered editpinyin record envelope.
/// Payload semantics remain intentionally opaque until runtime evidence confirms them.
struct EditPinyinRecord {
    let keys: [UInt32]
    let endOffsets: [UInt16]
    let payload: Data

    func payload(for index: Int) -> Data? {
        guard index >= 0, index < endOffsets.count else { return nil }
        let start = index == 0 ? 0 : Int(endOffsets[index - 1])
        let end = Int(endOffsets[index])
        guard start <= end, end <= payload.count else { return nil }
        return payload.subdata(in: start..<end)
    }
}

struct EditPinyinIndex {
    enum ParseError: Error, Equatable {
        case truncatedHeader(offset: Int)
        case invalidEntryCount(offset: Int)
        case nonMonotonicOffsets(offset: Int)
        case payloadOutOfBounds(offset: Int)
        case invalidRecordLength
    }

    let records: [EditPinyinRecord]
    let trailingData: Data

    init(data: Data) throws {
        let container = try IndexedResource(data: data)
        var decodedRecords: [EditPinyinRecord] = []
        var fileTrailer = Data()
        for (index, block) in container.records.enumerated() {
            let decoded = try Self.decodeRecord(block)
            if index + 1 < container.records.count && !decoded.trailing.isEmpty {
                throw ParseError.invalidRecordLength
            }
            decodedRecords.append(decoded.record)
            if index + 1 == container.records.count { fileTrailer = decoded.trailing }
        }
        records = decodedRecords
        trailingData = fileTrailer
    }

    /// Decodes an isolated record block, not a complete dictionary file.
    init(recordData: Data) throws {
        let decoded = try Self.decodeRecord(recordData)
        guard decoded.trailing.isEmpty else { throw ParseError.invalidRecordLength }
        records = [decoded.record]
        trailingData = Data()
    }

    private static func decodeRecord(_ data: Data) throws -> (record: EditPinyinRecord, trailing: Data) {
        var cursor = 0
        guard let count = data.readUInt32LE(at: cursor) else {
            throw ParseError.truncatedHeader(offset: 0)
        }
        cursor += 4
        let entryCount = Int(count)
        guard entryCount <= (data.count - cursor) / 6 else {
            throw ParseError.invalidEntryCount(offset: 0)
        }
        let keyBytes = entryCount * 4
        let endBytes = entryCount * 2
        guard cursor + keyBytes + endBytes <= data.count else {
            throw ParseError.truncatedHeader(offset: 0)
        }
        var keys: [UInt32] = []
        keys.reserveCapacity(entryCount)
        for _ in 0..<entryCount {
            guard let key = data.readUInt32LE(at: cursor) else {
                throw ParseError.truncatedHeader(offset: 0)
            }
            keys.append(key)
            cursor += 4
        }
        var ends: [UInt16] = []
        ends.reserveCapacity(entryCount)
        var previous: UInt16 = 0
        for index in 0..<entryCount {
            guard let end = data.readUInt16LE(at: cursor) else {
                throw ParseError.truncatedHeader(offset: 0)
            }
            if index > 0 && end < previous {
                throw ParseError.nonMonotonicOffsets(offset: 0)
            }
            ends.append(end)
            previous = end
            cursor += 2
        }
        let payloadLength = Int(ends.last ?? 0)
        guard cursor + payloadLength <= data.count else {
            throw ParseError.payloadOutOfBounds(offset: 0)
        }
        let payloadEnd = cursor + payloadLength
        let record = EditPinyinRecord(
            keys: keys,
            endOffsets: ends,
            payload: data.subdata(in: cursor..<payloadEnd)
        )
        return (record, data.subdata(in: payloadEnd..<data.count))
    }
}

private extension Data {
    func readUInt16LE(at offset: Int) -> UInt16? {
        guard offset >= 0, offset + 2 <= count else { return nil }
        return UInt16(self[offset]) | (UInt16(self[offset + 1]) << 8)
    }

    func readUInt32LE(at offset: Int) -> UInt32? {
        guard offset >= 0, offset + 4 <= count else { return nil }
        return UInt32(self[offset]) |
            (UInt32(self[offset + 1]) << 8) |
            (UInt32(self[offset + 2]) << 16) |
            (UInt32(self[offset + 3]) << 24)
    }
}
