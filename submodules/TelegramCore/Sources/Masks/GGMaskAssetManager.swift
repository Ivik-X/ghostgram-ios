import Foundation

public enum GGMaskEffectType: String, Codable {
    case filter
    case distort
    case face3D
    case particle
}

public enum GGMaskAnchor: String, Codable {
    case face
    case eyes
    case mouth
    case forehead
    case background
}

public enum GGMaskDistortKind: String, Codable {
    case bulge
    case pinch
    case twirl
}

public enum GGMaskBlendMode: String, Codable {
    case normal
    case multiply
    case screen
    case overlay
}

public struct GGMaskManifest: Codable {
    public let id: String
    public let name: String
    public let version: Int
    public let effectType: GGMaskEffectType
    public let blendMode: GGMaskBlendMode?

    public init(id: String, name: String, version: Int = 1, effectType: GGMaskEffectType, blendMode: GGMaskBlendMode? = nil) {
        self.id = id
        self.name = name
        self.version = version
        self.effectType = effectType
        self.blendMode = blendMode
    }
}

public struct GGMaskPackage: Codable {
    public let manifest: GGMaskManifest
    public let assetPath: String?

    public init(manifest: GGMaskManifest, assetPath: String? = nil) {
        self.manifest = manifest
        self.assetPath = assetPath
    }
}

public struct GGMaskCatalogEntry: Codable, Equatable {
    public let id: String
    public let title: String
    public let iconUrl: String?
    public let downloadUrl: String?

    public init(id: String, title: String, iconUrl: String? = nil, downloadUrl: String? = nil) {
        self.id = id
        self.title = title
        self.iconUrl = iconUrl
        self.downloadUrl = downloadUrl
    }
}

public struct GGMaskCatalog: Codable {
    public var entries: [GGMaskCatalogEntry]
    public init(entries: [GGMaskCatalogEntry] = []) {
        self.entries = entries
    }
}

public enum GGMaskStoreError: Error {
    case notFound
    case writeFailed
    case corruptedData
}

public enum GGMaskPrepareError: Error {
    case invalidManifest
    case assetMissing
}

public final class GGMaskLocalStore {
    public static let shared = GGMaskLocalStore()

    private let storeLock = NSLock()
    private var installedPackages: [String: GGMaskPackage] = [:]

    private init() {}

    public func getPackage(id: String) -> GGMaskPackage? {
        storeLock.lock()
        defer { storeLock.unlock() }
        return installedPackages[id]
    }

    public func savePackage(_ package: GGMaskPackage) {
        storeLock.lock()
        defer { storeLock.unlock() }
        installedPackages[package.manifest.id] = package
    }
}

public final class GGMaskCatalogService {
    public static let shared = GGMaskCatalogService()

    private init() {}

    public func fetchCatalog(completion: @escaping (GGMaskCatalog) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            completion(GGMaskCatalog(entries: []))
        }
    }
}

public final class GGMaskAssetManager {
    public static let shared = GGMaskAssetManager()

    private init() {}

    public func loadMask(id: String) -> GGMaskPackage? {
        return GGMaskLocalStore.shared.getPackage(id: id)
    }
}
