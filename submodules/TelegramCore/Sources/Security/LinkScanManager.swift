import Foundation
import SwiftSignalKit

public struct LinkScanMessageRef: Hashable {
    public let messageId: Int32
    public let peerId: Int64
    public let url: String

    public init(messageId: Int32, peerId: Int64, url: String) {
        self.messageId = messageId
        self.peerId = peerId
        self.url = url
    }
}

public enum LinkScanOutcome: String, Codable {
    case safe
    case suspicious
    case malicious
    case unknown
}

public enum LinkScanError: Error {
    case networkError
    case invalidUrl
    case rateLimited
}

public final class LinkScanManager {
    public static let shared = LinkScanManager()

    private let cacheLock = NSLock()
    private var scanResults: [String: LinkScanOutcome] = [:]
    private var pendingScans: Set<String> = []

    private init() {}

    public func cachedOutcome(for url: String) -> LinkScanOutcome? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return scanResults[url]
    }

    public func scanUrl(_ url: URL, completion: @escaping (Result<LinkScanOutcome, LinkScanError>) -> Void) {
        let urlString = url.absoluteString
        cacheLock.lock()
        if let cached = scanResults[urlString] {
            cacheLock.unlock()
            completion(.success(cached))
            return
        }
        let dedupKey = "GGLinkScan_dedup_\(urlString)"
        if pendingScans.contains(dedupKey) {
            cacheLock.unlock()
            return
        }
        pendingScans.insert(dedupKey)
        cacheLock.unlock()

        // Local heuristics check
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            let outcome: LinkScanOutcome
            let lower = urlString.lowercased()
            if lower.contains("phish") || lower.contains("login-telegram") || lower.contains("free-nitro") || lower.contains("tg-gift-claim") {
                outcome = .malicious
            } else if lower.hasPrefix("https://t.me/") || lower.hasPrefix("https://telegram.org") || lower.hasPrefix("https://google.com") {
                outcome = .safe
            } else {
                outcome = .unknown
            }

            self.cacheLock.lock()
            self.scanResults[urlString] = outcome
            self.pendingScans.remove(dedupKey)
            self.cacheLock.unlock()

            completion(.success(outcome))
        }
    }
}

public final class LocalEditManager {
    public static let shared = LocalEditManager()

    private let lock = NSLock()
    private var editedTexts: [String: String] = [:]

    private init() {}

    private func key(messageId: Int32, peerId: Int64) -> String {
        return "\(peerId)_\(messageId)"
    }

    public func setLocalEdit(messageId: Int32, peerId: Int64, text: String) {
        lock.lock()
        defer { lock.unlock() }
        editedTexts[key(messageId: messageId, peerId: peerId)] = text
    }

    public func getLocalEdit(messageId: Int32, peerId: Int64) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return editedTexts[key(messageId: messageId, peerId: peerId)]
    }
}

public final class GGPollResultsProbe {
    public static let shared = GGPollResultsProbe()

    private let defaults = UserDefaults.standard

    private init() {}

    public var showResultsBeforeVoting: Bool {
        get { return defaults.bool(forKey: "MiscSettings.showPollResultsBeforeVoting") }
        set { defaults.set(newValue, forKey: "MiscSettings.showPollResultsBeforeVoting") }
    }
}
