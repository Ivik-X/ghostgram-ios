import Foundation
import SwiftSignalKit
import Postbox

public struct VideoFeedItem: Codable, Equatable {
    public let id: String
    public let messageId: Int32
    public let peerId: Int64
    public let caption: String?
    public let duration: Double
    public let viewsCount: Int32

    public init(
        id: String,
        messageId: Int32,
        peerId: Int64,
        caption: String?,
        duration: Double,
        viewsCount: Int32
    ) {
        self.id = id
        self.messageId = messageId
        self.peerId = peerId
        self.caption = caption
        self.duration = duration
        self.viewsCount = viewsCount
    }
}

public struct VideoFeedCatalog: Codable {
    public var items: [VideoFeedItem]
    public init(items: [VideoFeedItem] = []) {
        self.items = items
    }
}

public extension Notification.Name {
    static let GGVideoFeedCatalogUpdated = Notification.Name("GGVideoFeedCatalogUpdated")
    static let GGVideoFeedSettingsChanged = Notification.Name("GGVideoFeedSettingsChanged")
}

public final class VideoFeedAPIClient {
    public static let shared = VideoFeedAPIClient()

    private init() {}

    public func fetchFeedItems(limit: Int = 20, completion: @escaping ([VideoFeedItem]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion([])
        }
    }
}

public final class VideoFeedManager {
    public static let shared = VideoFeedManager()

    private let defaults = UserDefaults.standard
    private let enabledKey = "VideoFeed.isEnabled"
    private var items: [VideoFeedItem] = []

    private init() {}

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: enabledKey) }
        set {
            defaults.set(newValue, forKey: enabledKey)
            NotificationCenter.default.post(name: .GGVideoFeedSettingsChanged, object: nil)
        }
    }

    public func getCachedItems() -> [VideoFeedItem] {
        return items
    }

    public func updateItems(_ newItems: [VideoFeedItem]) {
        self.items = newItems
        NotificationCenter.default.post(name: .GGVideoFeedCatalogUpdated, object: nil)
    }
}
