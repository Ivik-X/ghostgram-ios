import Foundation
import Postbox

public class DeletedMessageAttribute: MessageAttribute {
    public let deletedAt: Int32
    public let timestamp: Int32
    public let originalAuthor: PeerId?
    
    public init(deletedAt: Int32, timestamp: Int32, originalAuthor: PeerId? = nil) {
        self.deletedAt = deletedAt
        self.timestamp = timestamp
        self.originalAuthor = originalAuthor
    }
    
    required public init(decoder: PostboxDecoder) {
        self.deletedAt = decoder.decodeInt32ForKey("d", orElse: 0)
        self.timestamp = decoder.decodeInt32ForKey("t", orElse: 0)
        if let authorId = decoder.decodeOptionalInt64ForKey("a") {
            self.originalAuthor = PeerId(authorId)
        } else {
            self.originalAuthor = nil
        }
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.deletedAt, forKey: "d")
        encoder.encodeInt32(self.timestamp, forKey: "t")
        if let originalAuthor = self.originalAuthor {
            encoder.encodeInt64(originalAuthor.toInt64(), forKey: "a")
        } else {
            encoder.encodeNil(forKey: "a")
        }
    }
}

public extension Message {
    var isGhostgramDeleted: Bool {
        for attribute in self.attributes {
            if attribute is DeletedMessageAttribute {
                return true
            }
        }
        return false
    }
    
    var ghostgramDeletedAt: Int32? {
        for attribute in self.attributes {
            if let attribute = attribute as? DeletedMessageAttribute {
                return attribute.deletedAt
            }
        }
        return nil
    }
}
