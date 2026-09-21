import Foundation

public struct GGVoiceCloneEntry: Codable, Equatable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
    public let sampleAudioUrl: String?
    public let isDownloaded: Bool

    public init(id: String, name: String, avatarUrl: String? = nil, sampleAudioUrl: String? = nil, isDownloaded: Bool = false) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.sampleAudioUrl = sampleAudioUrl
        self.isDownloaded = isDownloaded
    }
}

public struct GGVoiceCloneCatalog: Codable {
    public var entries: [GGVoiceCloneEntry]
    public init(entries: [GGVoiceCloneEntry] = []) {
        self.entries = entries
    }
}

public extension Notification.Name {
    static let GGVoiceCloneCatalogDidUpdate = Notification.Name("GGVoiceCloneCatalogDidUpdate")
    static let GGVoiceCloneDownloadCompleted = Notification.Name("GGVoiceCloneDownloadCompleted")
    static let GGVoiceCloneDownloadStateDidChange = Notification.Name("GGVoiceCloneDownloadStateDidChange")
}

public final class GGVoiceCloneManager {
    public static let shared = GGVoiceCloneManager()

    private let lock = NSLock()
    private var catalog: GGVoiceCloneCatalog = GGVoiceCloneCatalog()

    private init() {}

    public func getCatalog() -> GGVoiceCloneCatalog {
        lock.lock()
        defer { lock.unlock() }
        return catalog
    }

    public func updateCatalog(_ newCatalog: GGVoiceCloneCatalog) {
        lock.lock()
        self.catalog = newCatalog
        lock.unlock()
        NotificationCenter.default.post(name: .GGVoiceCloneCatalogDidUpdate, object: nil)
    }
}

public final class VoiceMorpherManager {
    public static let shared = VoiceMorpherManager()

    private let defaults = UserDefaults.standard

    private init() {}

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: "VoiceMorpher.isEnabled") }
        set { defaults.set(newValue, forKey: "VoiceMorpher.isEnabled") }
    }

    public var pitchShift: Float {
        get { return defaults.float(forKey: "VoiceMorpher.pitchShift") }
        set { defaults.set(newValue, forKey: "VoiceMorpher.pitchShift") }
    }
}

public final class SpotifyNowPlayingClient {
    public static let shared = SpotifyNowPlayingClient()

    private init() {}

    public func getCurrentTrack(completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}

public final class NowPlayingManager {
    public static let shared = NowPlayingManager()

    private let defaults = UserDefaults.standard

    private init() {}

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: "GG.nowPlaying.enabled") }
        set { defaults.set(newValue, forKey: "GG.nowPlaying.enabled") }
    }
}

public final class NowPlayingUploader {
    public static let shared = NowPlayingUploader()

    private init() {}

    public func uploadStatus(track: String) {
    }
}
