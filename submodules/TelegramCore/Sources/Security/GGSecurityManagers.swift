import Foundation
import Postbox
import SwiftSignalKit

public final class GhostBlockedPeersCache {
    public static let shared = GhostBlockedPeersCache()

    private let lock = NSLock()
    private var blockedPeerIds: Set<PeerId> = []

    private init() {}

    public func setBlockedPeers(_ peers: [PeerId]) {
        lock.lock()
        defer { lock.unlock() }
        blockedPeerIds = Set(peers)
    }

    public func isBlocked(peerId: PeerId) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return blockedPeerIds.contains(peerId)
    }

    public func addBlocked(peerId: PeerId) {
        lock.lock()
        defer { lock.unlock() }
        blockedPeerIds.insert(peerId)
    }

    public func removeBlocked(peerId: PeerId) {
        lock.lock()
        defer { lock.unlock() }
        blockedPeerIds.remove(peerId)
    }
}

public final class GGNetworkSecurity {
    public static let shared = GGNetworkSecurity()

    private let defaults = UserDefaults.standard

    private init() {}

    public var disableProxyWhenVPNActive: Bool {
        get { return defaults.bool(forKey: "MiscSettings.disableProxyWhenVPNActive") }
        set { defaults.set(newValue, forKey: "MiscSettings.disableProxyWhenVPNActive") }
    }
}

public final class GGAccountSwitchGuard {
    public static let shared = GGAccountSwitchGuard()

    private let defaults = UserDefaults.standard

    private init() {}

    public var requirePasscodeToSwitchAccount: Bool {
        get { return defaults.bool(forKey: "GG.accountSwitchGuard.enabled") }
        set { defaults.set(newValue, forKey: "GG.accountSwitchGuard.enabled") }
    }
}

public final class GGAnonymousModeManager {
    public static let shared = GGAnonymousModeManager()

    private let defaults = UserDefaults.standard

    private init() {}

    public var isAnonymousModeEnabled: Bool {
        get { return defaults.bool(forKey: "GG.anonymous.enabled") }
        set { defaults.set(newValue, forKey: "GG.anonymous.enabled") }
    }

    public var hideSendAsChannelNotice: Bool {
        get { return defaults.bool(forKey: "GG.anonymous.hideNotice") }
        set { defaults.set(newValue, forKey: "GG.anonymous.hideNotice") }
    }
}
