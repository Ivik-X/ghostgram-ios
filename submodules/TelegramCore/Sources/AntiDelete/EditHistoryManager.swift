import Foundation
import Postbox
import TelegramApi
import SwiftSignalKit

public struct EditRecord: Codable, Equatable {
    public let originalText: String
    public let originalAuthor: Int64?
    public let originalAuthorName: String?
    public let originalOutgoing: Bool
    public let orignalDate: Int32
    
    public init(
        originalText: String,
        originalAuthor: Int64? = nil,
        originalAuthorName: String? = nil,
        originalOutgoing: Bool = false,
        orignalDate: Int32 = 0
    ) {
        self.originalText = originalText
        self.originalAuthor = originalAuthor
        self.originalAuthorName = originalAuthorName
        self.originalOutgoing = originalOutgoing
        self.orignalDate = orignalDate
    }
}

public struct EditedMessageHistory: Codable, Equatable {
    public let peerId: Int64
    public let messageId: Int32
    public var records: [EditRecord]
    
    public init(peerId: Int64, messageId: Int32, records: [EditRecord] = []) {
        self.peerId = peerId
        self.messageId = messageId
        self.records = records
    }
}

public final class EditHistoryManager {
    public static let shared = EditHistoryManager()
    
    private let lock = NSRecursiveLock()
    private let storageUrl: URL
    private var historyByPeer: [Int64: [Int32: EditedMessageHistory]] = [:]
    
    private init() {
        let fileManager = FileManager.default
        let docUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.storageUrl = docUrl.appendingPathComponent("ghostgram_edit_history.json")
        self.loadHistory()
    }
    
    private func loadHistory() {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        if let data = try? Data(contentsOf: self.storageUrl),
           let list = try? JSONDecoder().decode([EditedMessageHistory].self, from: data) {
            for item in list {
                if self.historyByPeer[item.peerId] == nil {
                    self.historyByPeer[item.peerId] = [:]
                }
                self.historyByPeer[item.peerId]?[item.messageId] = item
            }
        }
    }
    
    private func saveHistory() {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        var allHistories: [EditedMessageHistory] = []
        for (_, peerHistories) in self.historyByPeer {
            allHistories.append(contentsOf: peerHistories.values)
        }
        
        if let data = try? JSONEncoder().encode(allHistories) {
            try? data.write(to: self.storageUrl, options: .atomic)
        }
    }
    
    public func recordEdit(peerId: Int64, messageId: Int32, originalText: String, authorId: Int64?, authorName: String?, outgoing: Bool, date: Int32) {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        if self.historyByPeer[peerId] == nil {
            self.historyByPeer[peerId] = [:]
        }
        
        var history = self.historyByPeer[peerId]?[messageId] ?? EditedMessageHistory(peerId: peerId, messageId: messageId)
        let record = EditRecord(
            originalText: originalText,
            originalAuthor: authorId,
            originalAuthorName: authorName,
            originalOutgoing: outgoing,
            orignalDate: date
        )
        history.records.append(record)
        self.historyByPeer[peerId]?[messageId] = history
        self.saveHistory()
    }
    
    public func getHistory(peerId: Int64, messageId: Int32) -> EditedMessageHistory? {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.historyByPeer[peerId]?[messageId]
    }
}
