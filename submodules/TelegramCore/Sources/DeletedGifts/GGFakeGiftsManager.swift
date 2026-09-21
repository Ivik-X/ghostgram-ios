import Foundation
import Postbox
import SwiftSignalKit

public struct FakeGift: Equatable {
    public let reference: StarGiftReference
    public let gift: StarGift
    public var fromPeerId: PeerId?
    public var date: Int32
    public var text: String?
    public var pinnedToTop: Bool
    public var savedToProfile: Bool

    public init(
        reference: StarGiftReference,
        gift: StarGift,
        fromPeerId: PeerId?,
        date: Int32,
        text: String?,
        pinnedToTop: Bool = false,
        savedToProfile: Bool = true
    ) {
        self.reference = reference
        self.gift = gift
        self.fromPeerId = fromPeerId
        self.date = date
        self.text = text
        self.pinnedToTop = pinnedToTop
        self.savedToProfile = savedToProfile
    }
}

public struct PersistedFakeGift: Codable, Equatable {
    public let id: Int64
    public let peerId: Int64
    public var fromPeerId: Int64?
    public var date: Int32
    public var text: String?
    public var pinnedToTop: Bool
    public var savedToProfile: Bool
    public var giftTitle: String
    public var giftStars: Int64

    public init(
        id: Int64,
        peerId: Int64,
        fromPeerId: Int64?,
        date: Int32,
        text: String?,
        pinnedToTop: Bool,
        savedToProfile: Bool,
        giftTitle: String,
        giftStars: Int64
    ) {
        self.id = id
        self.peerId = peerId
        self.fromPeerId = fromPeerId
        self.date = date
        self.text = text
        self.pinnedToTop = pinnedToTop
        self.savedToProfile = savedToProfile
        self.giftTitle = giftTitle
        self.giftStars = giftStars
    }
}

public extension Notification.Name {
    static let GGFakeGiftsChanged = Notification.Name("GGFakeGiftsChanged")
}

@objc public final class GGFakeGiftsManager: NSObject {
    @objc public static let shared = GGFakeGiftsManager()

    public static let changedNotification = Notification.Name.GGFakeGiftsChanged

    private let defaults = UserDefaults.standard
    private let lock = NSLock()
    private var itemsByPeer: [Int64: [PersistedFakeGift]] = [:]

    private override init() {
        super.init()
        loadAll()
    }

    public var isEnabled: Bool {
        get {
            return defaults.bool(forKey: "GG.fakeGifts.enabled")
        }
        set {
            defaults.set(newValue, forKey: "GG.fakeGifts.enabled")
            notifyChanged()
        }
    }

    private func itemsKey(for peerId: Int64) -> String {
        return "GG.fakeGifts.items.\(peerId)"
    }

    private func loadAll() {
        lock.lock()
        defer { lock.unlock() }
        // Items loaded lazily per peer or on demand
    }

    private func loadGifts(for peerId: Int64) -> [PersistedFakeGift] {
        if let items = itemsByPeer[peerId] {
            return items
        }
        if let data = defaults.data(forKey: itemsKey(for: peerId)),
           let decoded = try? JSONDecoder().decode([PersistedFakeGift].self, data: data) {
            itemsByPeer[peerId] = decoded
            return decoded
        }
        return []
    }

    private func saveGifts(for peerId: Int64, gifts: [PersistedFakeGift]) {
        itemsByPeer[peerId] = gifts
        if let data = try? JSONEncoder().encode(gifts) {
            defaults.set(data, forKey: itemsKey(for: peerId))
        }
        notifyChanged()
    }

    public func hasGifts(for peerId: PeerId) -> Bool {
        guard isEnabled else { return false }
        lock.lock()
        defer { lock.unlock() }
        return !loadGifts(for: peerId.toInt64()).isEmpty
    }

    public func count(for peerId: PeerId) -> Int {
        guard isEnabled else { return 0 }
        lock.lock()
        defer { lock.unlock() }
        return loadGifts(for: peerId.toInt64()).count
    }

    public func isFakeReference(_ reference: StarGiftReference, for peerId: PeerId) -> Bool {
        guard isEnabled else { return false }
        lock.lock()
        defer { lock.unlock() }
        let rawPeerId = peerId.toInt64()
        let list = loadGifts(for: rawPeerId)
        switch reference {
        case let .generic(id):
            return list.contains(where: { $0.id == id })
        case let .unique(slug):
            return list.contains(where: { String($0.id) == slug })
        }
    }

    public func updateGift(
        reference: StarGiftReference,
        for peerId: PeerId,
        fromPeerId: PeerId?,
        date: Int32,
        text: String?
    ) {
        lock.lock()
        defer { lock.unlock() }
        let rawPeerId = peerId.toInt64()
        var list = loadGifts(for: rawPeerId)
        let targetId: Int64
        switch reference {
        case let .generic(id):
            targetId = id
        case let .unique(slug):
            targetId = Int64(slug) ?? 0
        }

        if let index = list.firstIndex(where: { $0.id == targetId }) {
            list[index].fromPeerId = fromPeerId?.toInt64()
            list[index].date = date
            list[index].text = text
            saveGifts(for: rawPeerId, gifts: list)
        }
    }

    public func setPinnedToTop(reference: StarGiftReference, for peerId: PeerId, pinned: Bool) {
        lock.lock()
        defer { lock.unlock() }
        let rawPeerId = peerId.toInt64()
        var list = loadGifts(for: rawPeerId)
        let targetId: Int64
        switch reference {
        case let .generic(id): targetId = id
        case let .unique(slug): targetId = Int64(slug) ?? 0
        }
        if let index = list.firstIndex(where: { $0.id == targetId }) {
            list[index].pinnedToTop = pinned
            saveGifts(for: rawPeerId, gifts: list)
        }
    }

    public func setSavedToProfile(reference: StarGiftReference, for peerId: PeerId, added: Bool) {
        lock.lock()
        defer { lock.unlock() }
        let rawPeerId = peerId.toInt64()
        var list = loadGifts(for: rawPeerId)
        let targetId: Int64
        switch reference {
        case let .generic(id): targetId = id
        case let .unique(slug): targetId = Int64(slug) ?? 0
        }
        if let index = list.firstIndex(where: { $0.id == targetId }) {
            list[index].savedToProfile = added
            saveGifts(for: rawPeerId, gifts: list)
        }
    }

    public func addFakeGift(
        peerId: PeerId,
        gift: StarGift,
        fromPeerId: PeerId?,
        date: Int32,
        text: String?
    ) {
        lock.lock()
        defer { lock.unlock() }
        let nextId = defaults.integer(forKey: "GG.fakeGifts.nextLocalId") + 1
        defaults.set(nextId, forKey: "GG.fakeGifts.nextLocalId")

        let rawPeerId = peerId.toInt64()
        var list = loadGifts(for: rawPeerId)
        let persisted = PersistedFakeGift(
            id: Int64(nextId),
            peerId: rawPeerId,
            fromPeerId: fromPeerId?.toInt64(),
            date: date,
            text: text,
            pinnedToTop: false,
            savedToProfile: true,
            giftTitle: "Star Gift",
            giftStars: 100
        )
        list.append(persisted)
        saveGifts(for: rawPeerId, gifts: list)
    }

    public func clear(for peerId: PeerId) {
        lock.lock()
        defer { lock.unlock() }
        let rawPeerId = peerId.toInt64()
        saveGifts(for: rawPeerId, gifts: [])
    }

    public func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        itemsByPeer.removeAll()
        notifyChanged()
    }

    private func notifyChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .GGFakeGiftsChanged, object: self)
        }
    }
}
