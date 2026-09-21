import Foundation
import Postbox
import SwiftSignalKit

public struct GGDeletedGift: Codable, Equatable {
    public let id: Int64
    public let slug: String
    public let title: String
    public let num: Int32
    public let availabilityIssued: Int32
    public let availabilityTotal: Int32
    public let price: Int64
    public let date: Int32
    public let fromPeerId: Int64?
    public let toPeerId: Int64
    public let text: String?

    public init(
        id: Int64,
        slug: String,
        title: String,
        num: Int32,
        availabilityIssued: Int32,
        availabilityTotal: Int32,
        price: Int64,
        date: Int32,
        fromPeerId: Int64?,
        toPeerId: Int64,
        text: String?
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.num = num
        self.availabilityIssued = availabilityIssued
        self.availabilityTotal = availabilityTotal
        self.price = price
        self.date = date
        self.fromPeerId = fromPeerId
        self.toPeerId = toPeerId
        self.text = text
    }
}

public struct GGDeletedGiftsCatalog: Codable {
    public var gifts: [GGDeletedGift]
    public init(gifts: [GGDeletedGift] = []) {
        self.gifts = gifts
    }
}

public extension Notification.Name {
    static let GGDeletedGiftsChanged = Notification.Name("GGDeletedGiftsChanged")
}

@objc public final class GGDeletedGiftsManager: NSObject {
    @objc public static let shared = GGDeletedGiftsManager()

    private let queue = DispatchQueue(label: "org.ghostgram.deletedGifts")
    private let storageKey = "GG.deletedGifts.catalog"
    private var cachedGifts: [GGDeletedGift] = []

    private override init() {
        super.init()
        load()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let catalog = try JSONDecoder().decode(GGDeletedGiftsCatalog.self, data: data)
                self.cachedGifts = catalog.gifts
            } catch {
                self.cachedGifts = []
            }
        }
    }

    private func save() {
        let catalog = GGDeletedGiftsCatalog(gifts: cachedGifts)
        if let data = try? JSONEncoder().encode(catalog) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .GGDeletedGiftsChanged, object: nil)
        }
    }

    public func allDeletedGifts() -> [GGDeletedGift] {
        return queue.sync {
            return self.cachedGifts
        }
    }

    public func gifts(for peerId: PeerId) -> [GGDeletedGift] {
        let rawId = peerId.toInt64()
        return queue.sync {
            return self.cachedGifts.filter { $0.toPeerId == rawId }
        }
    }

    public func recordDeletedGift(_ gift: GGDeletedGift) {
        queue.async {
            if !self.cachedGifts.contains(where: { $0.id == gift.id }) {
                self.cachedGifts.append(gift)
                self.save()
            }
        }
    }

    public func removeGift(id: Int64) {
        queue.async {
            self.cachedGifts.removeAll(where: { $0.id == id })
            self.save()
        }
    }

    public func clearAll() {
        queue.async {
            self.cachedGifts.removeAll()
            self.save()
        }
    }
}
