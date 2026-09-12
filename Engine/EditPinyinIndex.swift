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
    }

    let records: [EditPinyinRecord]

    init(data: Data) throws {
        var cursor = 0
        var parsed: [EditPinyinRecord] = []
        while cursor < data.count {
            let recordOffset = cursor
            guard let count = data.readUInt32LE(at: cursor) else {
                throw ParseError.truncatedHeader(offset: recordOffset)
            }
            cursor += 4
            guard count > 0, count <= 64 else {
                throw ParseError.invalidEntryCount(offset: recordOffset)
            }
            let keyBytes = Int(count) * 4
            let endBytes = Int(count) * 2
            guard cursor + keyBytes + endBytes <= data.count else {
                throw ParseError.truncatedHeader(offset: recordOffset)
            }
            var keys: [UInt32] = []
            keys.reserveCapacity(Int(count))
            for _ in 0..<count {
                guard let key = data.readUInt32LE(at: cursor) else {
                    throw ParseError.truncatedHeader(offset: recordOffset)
                }
                keys.append(key)
                cursor += 4
            }
            var ends: [UInt16] = []
            ends.reserveCapacity(Int(count))
            var previous: UInt16 = 0
            for index in 0..<count {
                guard let end = data.readUInt16LE(at: cursor) else {
                    throw ParseError.truncatedHeader(offset: recordOffset)
                }
                if index > 0 && end < previous {
                    throw ParseError.nonMonotonicOffsets(offset: recordOffset)
                }
                ends.append(end)
                previous = end
                cursor += 2
            }
            let payloadLength = Int(ends.last ?? 0)
            guard cursor + payloadLength <= data.count else {
                throw ParseError.payloadOutOfBounds(offset: recordOffset)
            }
            parsed.append(EditPinyinRecord(
                keys: keys,
                endOffsets: ends,
                payload: data.subdata(in: cursor..<(cursor + payloadLength))
            ))
            cursor += payloadLength
        }
        records = parsed
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
