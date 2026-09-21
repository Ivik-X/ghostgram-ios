import Foundation
import Postbox
import TelegramApi
import SwiftSignalKit

public enum GhostModeActivityKind: Int32, Codable {
    case typing = 0
    case voiceRecord = 1
    case videoRecord = 2
    case upload = 3
    case choosingSticker = 4
}

public struct GhostModePeerExceptionSettings: Codable, Equatable {
    public var hideReadReceipts: Bool?
    public var hideTyping: Bool?
    public var hideOnline: Bool?
    public var hideStories: Bool?
    
    public init(hideReadReceipts: Bool? = nil, hideTyping: Bool? = nil, hideOnline: Bool? = nil, hideStories: Bool? = nil) {
        self.hideReadReceipts = hideReadReceipts
        self.hideTyping = hideTyping
        self.hideOnline = hideOnline
        self.hideStories = hideStories
    }
}

public final class GhostModeManager {
    public static let shared = GhostModeManager()
    
    private let lock = NSRecursiveLock()
    private let defaults: UserDefaults
    
    // Ghost Mode Keys
    public var isEnabled: Bool {
        get { return self.defaults.bool(forKey: "ghostMode.isEnabled") }
        set { self.defaults.set(newValue, forKey: "ghostMode.isEnabled") }
    }
    
    public var hideOnlineStatus: Bool {
        get { return self.isEnabled && (self.defaults.object(forKey: "ghostMode.hideOnlineStatus") == nil ? true : self.defaults.bool(forKey: "ghostMode.hideOnlineStatus")) }
        set { self.defaults.set(newValue, forKey: "ghostMode.hideOnlineStatus") }
    }
    
    public var forceOffline: Bool {
        get { return self.isEnabled && self.defaults.bool(forKey: "ghostMode.forceOffline") }
        set { self.defaults.set(newValue, forKey: "ghostMode.forceOffline") }
    }
    
    public var hideReadReceipts: Bool {
        get { return self.isEnabled && (self.defaults.object(forKey: "ghostMode.hideReadReceipts") == nil ? true : self.defaults.bool(forKey: "ghostMode.hideReadReceipts")) }
        set { self.defaults.set(newValue, forKey: "ghostMode.hideReadReceipts") }
    }
    
    public var hideTypingIndicator: Bool {
        get { return self.isEnabled && (self.defaults.object(forKey: "ghostMode.hideTypingIndicator") == nil ? true : self.defaults.bool(forKey: "ghostMode.hideTypingIndicator")) }
        set { self.defaults.set(newValue, forKey: "ghostMode.hideTypingIndicator") }
    }
    
    public var hideStoryViews: Bool {
        get { return self.isEnabled && (self.defaults.object(forKey: "ghostMode.hideStoryViews") == nil ? true : self.defaults.bool(forKey: "ghostMode.hideStoryViews")) }
        set { self.defaults.set(newValue, forKey: "ghostMode.hideStoryViews") }
    }
    
    public var readOnAction: Bool {
        get { return self.defaults.bool(forKey: "ghostMode.readOnAction") }
        set { self.defaults.set(newValue, forKey: "ghostMode.readOnAction") }
    }
    
    public var stealthReadSessionDurationMinutes: Int32 {
        get { return Int32(self.defaults.integer(forKey: "ghostMode.stealthReadSessionDurationMinutes")) }
        set { self.defaults.set(Int(newValue), forKey: "ghostMode.stealthReadSessionDurationMinutes") }
    }
    
    public var excludedPeerIds: Set<Int64> = []
    public var excludedFolderIds: Set<Int32> = []
    public var excludeAllGroups: Bool = false
    public var excludeAllChannels: Bool = false
    
    private init() {
        self.defaults = UserDefaults.standard
        if self.defaults.object(forKey: "ghostMode.initialized") == nil {
            self.defaults.set(true, forKey: "ghostMode.initialized")
            self.defaults.set(true, forKey: "ghostMode.isEnabled")
            self.defaults.set(true, forKey: "ghostMode.hideOnlineStatus")
            self.defaults.set(true, forKey: "ghostMode.hideReadReceipts")
            self.defaults.set(true, forKey: "ghostMode.hideTypingIndicator")
            self.defaults.set(true, forKey: "ghostMode.hideStoryViews")
        }
    }
    
    public func isPeerExcluded(peerId: PeerId) -> Bool {
        if self.excludedPeerIds.contains(peerId.toInt64()) {
            return true
        }
        if self.excludeAllGroups && peerId.namespace == Namespaces.Peer.CloudGroup {
            return true
        }
        if self.excludeAllChannels && peerId.namespace == Namespaces.Peer.CloudChannel {
            return true
        }
        return false
    }
    
    public func shouldSuppressReadReceipt(for peerId: PeerId) -> Bool {
        guard self.hideReadReceipts else { return false }
        return !self.isPeerExcluded(peerId: peerId)
    }
    
    public func shouldSuppressTyping(for peerId: PeerId) -> Bool {
        guard self.hideTypingIndicator else { return false }
        return !self.isPeerExcluded(peerId: peerId)
    }
    
    public func shouldSuppressOnline() -> Bool {
        return self.hideOnlineStatus || self.forceOffline
    }
    
    public func shouldSuppressStoryView() -> Bool {
        return self.hideStoryViews
    }
}
