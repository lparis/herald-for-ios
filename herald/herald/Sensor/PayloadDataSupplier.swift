//
//  PayloadDataSupplier.swift
//
//  Copyright 2020 VMware, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Payload data supplier for generating payload data that is shared with other devices to provide device identity information while maintaining privacy and security.
/// Implement this to integration your solution with this transport.
public protocol PayloadDataSupplier {
    /// Legacy payload supplier callback - for those transitioning their apps to Herald. Note: Device may be null if Payload in use is same for all receivers
    func legacyPayload(_ timestamp: PayloadTimestamp, device: Device?) -> PayloadData?
    
    /// Get payload for given timestamp. Use this for integration with any payload generator. Note: Device may be null if Payload in use is same for all receivers
    func payload(_ timestamp: PayloadTimestamp, device: Device?) -> PayloadData?
    
    /// Parse raw data into payloads. This is used to split concatenated payloads that are transmitted via share payload. The default implementation assumes payload data is fixed length.
    func payload(_ data: Data) -> [PayloadData]
}

/// Implements payload splitting function, assuming fixed length payloads.
public extension PayloadDataSupplier {
    /// Default implementation assumes fixed length payload data.
    func payload(_ data: Data) -> [PayloadData] {
        // Get example payload to determine length
        let fixedLengthPayload = payload(PayloadTimestamp(), device: nil)
        // Split data into payloads based on fixed length
        var payloads: [PayloadData] = []
        if let fixedLengthPayload = fixedLengthPayload {
            let payloadLength = fixedLengthPayload.count
            var indexStart = 0, indexEnd = payloadLength
            while indexEnd <= data.count {
                let payload = PayloadData(data.subdata(in: indexStart..<indexEnd))
                payloads.append(payload)
                indexStart += payloadLength
                indexEnd += payloadLength
            }
        }
        return payloads
    }
}

/// Payload timestamp, should normally be Date, but it may change to UInt64 in the future to use server synchronised relative timestamp.
public typealias PayloadTimestamp = Date

/// Encrypted payload data received from target. This is likely to be an encrypted datagram of the target's actual permanent identifier.
public class PayloadData : Hashable, Equatable {
    public var data: Data
    public var shortName: String {
        guard data.count > 0 else {
            return ""
        }
        guard data.count > 3 else {
            return data.base64EncodedString()
        }
        return String(data.subdata(in: 3..<data.count).base64EncodedString().prefix(6))
    }

    init(_ data: Data) {
        self.data = data
    }

    init?(base64Encoded: String) {
        guard let data = Data(base64Encoded: base64Encoded) else {
            return nil
        }
        self.data = data
    }

    init(repeating: UInt8, count: Int) {
        self.data = Data(repeating: repeating, count: count)
    }

    init() {
        self.data = Data()
    }
    
    // MARK:- Data
    
    public var count: Int { get { data.count }}

    public var hexEncodedString: String { get { data.hexEncodedString }}
    
    public func base64EncodedString() -> String {
        return data.base64EncodedString()
    }
    
    public func subdata(in range: Range<Data.Index>) -> Data {
        return data.subdata(in: range)
    }
    
    // MARK:- Hashable
    
    public var hashValue: Int { get { data.hashValue } }

    public func hash(into hasher: inout Hasher) {
        data.hash(into: &hasher)
    }
    
    // MARK:- Equatable
    
    public static func ==(lhs: PayloadData, rhs: PayloadData) -> Bool {
        return lhs.data == rhs.data
    }

    // MARK:- Append

    func append(_ other: PayloadData) {
        data.append(other.data)
    }
    
    func append(_ other: Data) {
        data.append(other)
    }

    func append(_ other: Int8) {
        data.append(other)
    }

    func append(_ other: Int16) {
        data.append(other)
    }
    
    func append(_ other: Int32) {
        data.append(other)
    }
    
    func append(_ other: Int64) {
        data.append(other)
    }

    func append(_ other: UInt8) {
        data.append(other)
    }

    func append(_ other: UInt16) {
        data.append(other)
    }
    
    func append(_ other: UInt32) {
        data.append(other)
    }
    
    func append(_ other: UInt64) {
        data.append(other)
    }

    @available(iOS 14.0, *)
    func append(_ other: Float16) {
        data.append(other)
    }
    
    func append(_ other: Float32) {
        data.append(other)
    }
}

/// Payload data associated with legacy service
public class LegacyPayloadData : PayloadData {
    public let service: String
    
    init(service: String, data: Data) {
        self.service = service
        super.init(data)
    }

    public override var shortName: String { get { super.shortName + ":L" }}
}
