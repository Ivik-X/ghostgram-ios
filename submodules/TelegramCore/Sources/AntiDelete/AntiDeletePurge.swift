import Foundation
import Postbox
import TelegramApi
import SwiftSignalKit

public final class AntiDeleteManager {
    public static let shared = AntiDeleteManager()
    
    public struct ArchivedMessage: Codable, Equatable {
        public let globalId: Int32
        public let peerId: Int64
        public let messageId: Int32
        public let timestamp: Int32
        public let deletedAt: Int32
        public let authorId: Int64?
        public let authorName: String?
        public let authorUsername: String?
        public let text: String?
        public let forwardAuthorId: Int64?
        public let mediaDescription: String?
        public let threadId: Int64?
        
        public init(
            globalId: Int32,
            peerId: Int64,
            messageId: Int32,
            timestamp: Int32,
            deletedAt: Int32,
            authorId: Int64? = nil,
            authorName: String? = nil,
            authorUsername: String? = nil,
            text: String? = nil,
            forwardAuthorId: Int64? = nil,
            mediaDescription: String? = nil,
            threadId: Int64? = nil
        ) {
            self.globalId = globalId
            self.peerId = peerId
            self.messageId = messageId
            self.timestamp = timestamp
            self.deletedAt = deletedAt
            self.authorId = authorId
            self.authorName = authorName
            self.authorUsername = authorUsername
            self.text = text
            self.forwardAuthorId = forwardAuthorId
            self.mediaDescription = mediaDescription
            self.threadId = threadId
        }
    }
    
    public struct ArchivedDeletedReaction: Codable, Equatable {
        public let peerId: Int64
        public let messageId: Int32
        public let messageTimestamp: Int32
        public let deletedAt: Int32
        public let authorId: Int64?
        public let reaction: String
        
        public init(
            peerId: Int64,
            messageId: Int32,
            messageTimestamp: Int32,
            deletedAt: Int32,
            authorId: Int64?,
            reaction: String
        ) {
            self.peerId = peerId
            self.messageId = messageId
            self.messageTimestamp = messageTimestamp
            self.deletedAt = deletedAt
            self.authorId = authorId
            self.reaction = reaction
        }
    }
    
    public struct ArchivedEditedReaction: Codable, Equatable {
        public let peerId: Int64
        public let messageId: Int32
        public let messageTimestamp: Int32
        public let editedAt: Int32
        public let authorId: Int64?
        public let previousReaction: String?
        public let updatedReaction: String
        
        public init(
            peerId: Int64,
            messageId: Int32,
            messageTimestamp: Int32,
            editedAt: Int32,
            authorId: Int64?,
            previousReaction: String?,
            updatedReaction: String
        ) {
            self.peerId = peerId
            self.messageId = messageId
            self.messageTimestamp = messageTimestamp
            self.editedAt = editedAt
            self.authorId = authorId
            self.previousReaction = previousReaction
            self.updatedReaction = updatedReaction
        }
    }
    
    private let lock = NSRecursiveLock()
    private let storageUrl: URL
    private let backupUrl: URL
    
    public var enabled: Bool = true
    public var archiveMedia: Bool = true
    public var keepLocallyWhenDeletingForEveryone: Bool = true
    public var displayEditedMessages: Bool = true
    public var classicEditedStyle: Bool = false
    public var shouldPreserveTTL: Bool = false
    public var showDeletedInBots: Bool = true
    public var showDeletedInChannels: Bool = true
    public var showEditedInBots: Bool = true
    public var showEditedInChannels: Bool = true
    public var deletedMessageTransparency: Double = 0.65
    public var localEditedMessageTransparency: Double = 0.65
    public var antiDeleteTTL: Int32 = 0
    public var autoClearInterval: Int32 = 0
    
    public var excludedPeerIds: Set<Int64> = []
    public var excludedFolderIds: Set<Int32> = []
    public var excludeAllGroups: Bool = false
    
    public private(set) var archivedMessages: [ArchivedMessage] = []
    private var archivedIndexByPeer: [Int64: [Int32: ArchivedMessage]] = [:]
    
    private init() {
        let fileManager = FileManager.default
        let docUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.storageUrl = docUrl.appendingPathComponent("ghostgram_deleted_archive.json")
        self.backupUrl = docUrl.appendingPathComponent("ghostgram_deleted_archive.backup.json")
        
        self.loadArchive()
    }
    
    private func loadArchive() {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        if let data = try? Data(contentsOf: self.storageUrl),
           let messages = try? JSONDecoder().decode([ArchivedMessage].self, from: data) {
            self.archivedMessages = messages
            self.rebuildIndex()
            print("[AntiDelete] Loaded \(messages.count) archived messages from file")
            return
        }
        
        if let data = try? Data(contentsOf: self.backupUrl),
           let messages = try? JSONDecoder().decode([ArchivedMessage].self, from: data) {
            self.archivedMessages = messages
            self.rebuildIndex()
            print("[AntiDelete] Restored \(messages.count) archived messages from backup")
            return
        }
    }
    
    private func rebuildIndex() {
        var index: [Int64: [Int32: ArchivedMessage]] = [:]
        for msg in self.archivedMessages {
            if index[msg.peerId] == nil {
                index[msg.peerId] = [:]
            }
            index[msg.peerId]?[msg.messageId] = msg
        }
        self.archivedIndexByPeer = index
    }
    
    public func saveArchive() {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        do {
            let data = try JSONEncoder().encode(self.archivedMessages)
            try data.write(to: self.storageUrl, options: .atomic)
            try? data.write(to: self.backupUrl, options: .atomic)
        } catch {
            print("[AntiDelete] Failed to save archive: \(error)")
        }
    }
    
    public func isExcluded(peerId: PeerId) -> Bool {
        if self.excludedPeerIds.contains(peerId.toInt64()) {
            return true
        }
        if self.excludeAllGroups && (peerId.namespace == Namespaces.Peer.CloudGroup || peerId.namespace == Namespaces.Peer.CloudChannel) {
            return true
        }
        return false
    }
    
    public func recordDeletedMessage(_ message: Message) {
        guard self.enabled, !self.isExcluded(peerId: message.id.peerId) else {
            return
        }
        
        self.lock.lock()
        defer { self.lock.unlock() }
        
        let now = Int32(Date().timeIntervalSince1970)
        let authorPeer = message.author
        let authorName = authorPeer?.debugDisplayTitle
        let authorUsername = authorPeer?.addressName
        
        let mediaDesc: String? = message.media.first.map { String(describing: type(of: $0)) }
        let threadId: Int64? = message.threadId
        
        let archived = ArchivedMessage(
            globalId: message.id.id,
            peerId: message.id.peerId.toInt64(),
            messageId: message.id.id,
            timestamp: message.timestamp,
            deletedAt: now,
            authorId: message.author?.id.toInt64(),
            authorName: authorName,
            authorUsername: authorUsername,
            text: message.text,
            forwardAuthorId: nil,
            mediaDescription: mediaDesc,
            threadId: threadId
        )
        
        self.archivedMessages.append(archived)
        if self.archivedIndexByPeer[archived.peerId] == nil {
            self.archivedIndexByPeer[archived.peerId] = [:]
        }
        self.archivedIndexByPeer[archived.peerId]?[archived.messageId] = archived
        self.saveArchive()
    }
    
    public func isMessageDeleted(peerId: Int64, messageId: Int32) -> Bool {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.archivedIndexByPeer[peerId]?[messageId] != nil
    }
    
    public func getArchivedMessage(peerId: Int64, messageId: Int32) -> ArchivedMessage? {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.archivedIndexByPeer[peerId]?[messageId]
    }
    
    public func getArchivedMessages(forPeerId peerId: Int64) -> [ArchivedMessage] {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.archivedMessages.filter { $0.peerId == peerId }
    }
    
    public func allArchivedMessages() -> [ArchivedMessage] {
        self.lock.lock()
        defer { self.lock.unlock() }
        return self.archivedMessages
    }
    
    public func unmarkAsDeleted(peerId: Int64, messageId: Int32) {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.archivedMessages.removeAll { $0.peerId == peerId && $0.messageId == messageId }
        self.archivedIndexByPeer[peerId]?.removeValue(forKey: messageId)
        self.saveArchive()
    }
    
    public func exportArchiveData() -> Data? {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        guard let jsonData = try? JSONEncoder().encode(self.archivedMessages),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        var rows = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for m in self.archivedMessages {
            let d = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(m.deletedAt)))
            let txt = (m.text ?? m.mediaDescription ?? "").replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;")
            let auth = m.authorName ?? (m.authorId.map { "\($0)" } ?? "")
            rows += "<tr><td>\(d)</td><td>\(m.peerId)</td><td>\(m.messageId)</td><td>\(auth)</td><td>\(txt)</td></tr>\n"
        }
        
        let html = """
        <!doctype html>
        <html lang="ru"><head><meta charset="utf-8">
        <title>Ghostgram — архив удалённых сообщений</title>
        <style>
        body{font:14px/1.4 -apple-system,BlinkMacSystemFont,Helvetica,Arial,sans-serif;padding:20px;background:#fafafa;color:#222}
        h1{font-size:18px;margin-bottom:4px}
        .meta{color:#666;margin-bottom:16px}
        table{border-collapse:collapse;width:100%;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.06)}
        th,td{padding:8px 10px;border-bottom:1px solid #eee;text-align:left;vertical-align:top}
        th{background:#f3f3f3;font-weight:600;font-size:12px;text-transform:uppercase;letter-spacing:.04em}
        td{font-size:13px}
        tr:hover td{background:#fafbfc}
        </style></head><body>
        <h1>Архив удалённых сообщений</h1>
        <div class="meta">Экспортировано Ghostgram. Файл также является источником для повторного импорта — не удаляйте блок <code>&lt;script id="ghostgram-archive"&gt;</code>.</div>
        <table><thead><tr><th>Удалено</th><th>Peer</th><th>Msg ID</th><th>Автор</th><th>Текст</th></tr></thead>
        <tbody>
        \(rows)
        </tbody></table>
        <script id="ghostgram-archive" type="application/json">\(jsonString)</script>
        </body></html>
        """
        return html.data(using: .utf8)
    }
    
    public func importArchiveData(_ data: Data, merge: Bool) -> (added: Int, total: Int) {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        var jsonPayload = data
        if let htmlStr = String(data: data, encoding: .utf8),
           let startRange = htmlStr.range(of: "<script id=\"ghostgram-archive\" type=\"application/json\">"),
           let endRange = htmlStr.range(of: "</script>", range: startRange.upperBound..<htmlStr.endIndex) {
            let jsonSub = htmlStr[startRange.upperBound..<endRange.lowerBound]
            if let extracted = jsonSub.data(using: .utf8) {
                jsonPayload = extracted
            }
        }
        
        guard let imported = try? JSONDecoder().decode([ArchivedMessage].self, from: jsonPayload) else {
            return (0, self.archivedMessages.count)
        }
        
        if !merge {
            self.archivedMessages = imported
            self.rebuildIndex()
            self.saveArchive()
            return (imported.count, imported.count)
        }
        
        var added = 0
        for m in imported {
            if self.archivedIndexByPeer[m.peerId]?[m.messageId] == nil {
                self.archivedMessages.append(m)
                added += 1
            }
        }
        self.rebuildIndex()
        self.saveArchive()
        return (added, self.archivedMessages.count)
    }
}

public func setAntiDeleteCaptureActiveSharedFlag(_ active: Bool) {
    AntiDeleteManager.shared.enabled = active
}

public func ghostgramPurgeAntiDeleteMessages(postbox: Postbox, keys: [(peerId: Int64, messageId: Int32)]) -> Signal<Int, NoError> {
    return Signal { subscriber in
        var purgedCount = 0
        for (peerId, messageId) in keys {
            AntiDeleteManager.shared.unmarkAsDeleted(peerId: peerId, messageId: messageId)
            purgedCount += 1
        }
        subscriber.putNext(purgedCount)
        subscriber.putCompletion()
        return EmptyDisposable
    }
}
