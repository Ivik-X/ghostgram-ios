import Foundation
import Postbox

public struct MessageBookmark: Codable, Equatable {
    public let id: String
    public let messageId: Int32
    public let peerId: Int64
    public let text: String?
    public let date: Int32
    public let authorName: String?

    public init(
        id: String = UUID().uuidString,
        messageId: Int32,
        peerId: Int64,
        text: String?,
        date: Int32,
        authorName: String?
    ) {
        self.id = id
        self.messageId = messageId
        self.peerId = peerId
        self.text = text
        self.date = date
        self.authorName = authorName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case messageId
        case peerId
        case text
        case date
        case authorName
    }
}

public extension Notification.Name {
    static let MessageBookmarkManagerBookmarksChanged = Notification.Name("MessageBookmarkManagerBookmarksChanged")
}

@objc public final class MessageBookmarkManager: NSObject {
    @objc public static let shared = MessageBookmarkManager()

    private let queue = DispatchQueue(label: "org.ghostgram.MessageBookmarkManager.persist")
    private let fileName = "ghostgram_message_bookmarks.json"
    private var bookmarks: [MessageBookmark] = []

    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }

    private override init() {
        super.init()
        load()
    }

    private func load() {
        queue.sync {
            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let data = try Data(contentsOf: fileURL)
                    self.bookmarks = try JSONDecoder().decode([MessageBookmark].self, data: data)
                }
            } catch {
                print("[MessageBookmarkManager] Failed to load: \(error)")
            }
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(bookmarks)
            try data.write(to: fileURL, options: .atomic)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .MessageBookmarkManagerBookmarksChanged, object: nil)
            }
        } catch {
            print("[MessageBookmarkManager] Failed to save: \(error)")
        }
    }

    public func allBookmarks() -> [MessageBookmark] {
        return queue.sync {
            return self.bookmarks
        }
    }

    public func isBookmarked(messageId: Int32, peerId: Int64) -> Bool {
        return queue.sync {
            return self.bookmarks.contains(where: { $0.messageId == messageId && $0.peerId == peerId })
        }
    }

    public func addBookmark(messageId: Int32, peerId: Int64, text: String?, date: Int32, authorName: String?) {
        queue.async {
            if !self.bookmarks.contains(where: { $0.messageId == messageId && $0.peerId == peerId }) {
                let bookmark = MessageBookmark(
                    messageId: messageId,
                    peerId: peerId,
                    text: text,
                    date: date,
                    authorName: authorName
                )
                self.bookmarks.append(bookmark)
                self.save()
            }
        }
    }

    public func removeBookmark(messageId: Int32, peerId: Int64) {
        queue.async {
            self.bookmarks.removeAll(where: { $0.messageId == messageId && $0.peerId == peerId })
            self.save()
        }
    }

    public func toggleBookmark(messageId: Int32, peerId: Int64, text: String?, date: Int32, authorName: String?) {
        if isBookmarked(messageId: messageId, peerId: peerId) {
            removeBookmark(messageId: messageId, peerId: peerId)
        } else {
            addBookmark(messageId: messageId, peerId: peerId, text: text, date: date, authorName: authorName)
        }
    }
}
