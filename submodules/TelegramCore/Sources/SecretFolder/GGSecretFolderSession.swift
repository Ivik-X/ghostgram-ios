import Foundation
import UIKit
import Postbox

public extension Notification.Name {
    static let GGSecretFolderStateChanged = Notification.Name("GGSecretFolderStateChanged")
}

@objc public final class GGSecretFolderSession: NSObject {
    @objc public static let shared = GGSecretFolderSession()

    private let defaults = UserDefaults.standard
    private let passcodeKey = "GG.secretFolder.passcode"
    private let hiddenChatsKey = "GG.secretFolder.hiddenChatIds"
    private let enabledKey = "GG.secretFolder.enabled"

    private var _isUnlocked: Bool = false
    private var _hiddenPeerIds: Set<Int64> = []

    public override init() {
        super.init()
        loadHiddenChats()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: enabledKey) }
        set {
            defaults.set(newValue, forKey: enabledKey)
            if !newValue {
                _isUnlocked = false
            }
            notifyChanged()
        }
    }

    public var hasPasscode: Bool {
        return (defaults.string(forKey: passcodeKey)?.count ?? 0) > 0
    }

    public var isUnlocked: Bool {
        if !isEnabled { return true }
        return _isUnlocked
    }

    public func setPasscode(_ passcode: String?) {
        defaults.set(passcode, forKey: passcodeKey)
        notifyChanged()
    }

    public func unlock(passcode: String) -> Bool {
        guard let savedPasscode = defaults.string(forKey: passcodeKey) else {
            _isUnlocked = true
            notifyChanged()
            return true
        }
        if savedPasscode == passcode {
            _isUnlocked = true
            notifyChanged()
            return true
        }
        return false
    }

    public func lock() {
        _isUnlocked = false
        notifyChanged()
    }

    public func isPeerHidden(_ peerId: PeerId) -> Bool {
        guard isEnabled && !_isUnlocked else { return false }
        return _hiddenPeerIds.contains(peerId.toInt64())
    }

    public func hidePeer(_ peerId: PeerId) {
        _hiddenPeerIds.insert(peerId.toInt64())
        saveHiddenChats()
    }

    public func unhidePeer(_ peerId: PeerId) {
        _hiddenPeerIds.remove(peerId.toInt64())
        saveHiddenChats()
    }

    public func allHiddenPeerIds() -> Set<Int64> {
        return _hiddenPeerIds
    }

    private func loadHiddenChats() {
        if let array = defaults.array(forKey: hiddenChatsKey) as? [Int64] {
            _hiddenPeerIds = Set(array)
        }
    }

    private func saveHiddenChats() {
        defaults.set(Array(_hiddenPeerIds), forKey: hiddenChatsKey)
        notifyChanged()
    }

    @objc private func applicationDidEnterBackground() {
        if isEnabled {
            lock()
        }
    }

    private func notifyChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .GGSecretFolderStateChanged, object: self)
        }
    }
}
