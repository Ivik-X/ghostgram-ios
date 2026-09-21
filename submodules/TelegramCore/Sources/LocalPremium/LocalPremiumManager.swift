import Foundation
import Postbox
import TelegramApi
import SwiftSignalKit

public struct LocalPremiumAppearanceOverride: Codable, Equatable {
    public var nameColor: Int32?
    public var backgroundEmojiId: Int64?
    public var profileBackgroundEmojiId: Int64?
    public var collectible: Bool
    
    public init(nameColor: Int32? = nil, backgroundEmojiId: Int64? = nil, profileBackgroundEmojiId: Int64? = nil, collectible: Bool = false) {
        self.nameColor = nameColor
        self.backgroundEmojiId = backgroundEmojiId
        self.profileBackgroundEmojiId = profileBackgroundEmojiId
        self.collectible = collectible
    }
}

public final class LocalPremiumManager {
    public static let shared = LocalPremiumManager()
    
    private let lock = NSRecursiveLock()
    private let defaults: UserDefaults
    
    public var isEnabled: Bool {
        get { return self.defaults.object(forKey: "ghostgram.localPremiumEnabled") == nil ? true : self.defaults.bool(forKey: "ghostgram.localPremiumEnabled") }
        set { self.defaults.set(newValue, forKey: "ghostgram.localPremiumEnabled") }
    }
    
    public var activePeerId: Int64? {
        get {
            let val = self.defaults.integer(forKey: "ghostgram.localPremiumActivePeerId")
            return val != 0 ? Int64(val) : nil
        }
        set {
            if let newValue = newValue {
                self.defaults.set(Int(newValue), forKey: "ghostgram.localPremiumActivePeerId")
            } else {
                self.defaults.removeObject(forKey: "ghostgram.localPremiumActivePeerId")
            }
        }
    }
    
    public var appearanceOverride: LocalPremiumAppearanceOverride {
        get {
            if let data = self.defaults.data(forKey: "ghostgram.localPremiumAppearance.override"),
               let decoded = try? JSONDecoder().decode(LocalPremiumAppearanceOverride.self, from: data) {
                return decoded
            }
            return LocalPremiumAppearanceOverride()
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                self.defaults.set(encoded, forKey: "ghostgram.localPremiumAppearance.override")
            }
        }
    }
    
    private init() {
        self.defaults = UserDefaults.standard
        if self.defaults.object(forKey: "ghostgram.localPremiumEnabled") == nil {
            self.defaults.set(true, forKey: "ghostgram.localPremiumEnabled")
        }
    }
    
    public func isUserPremium(user: TelegramUser) -> Bool {
        guard self.isEnabled else { return false }
        if let activePeerId = self.activePeerId {
            return user.id.toInt64() == activePeerId
        }
        return true
    }
}
