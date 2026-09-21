import Foundation

public struct DeviceProfile: Equatable, Codable {
    public let id: String
    public let name: String
    public let deviceModel: String
    public let systemVersion: String

    public init(id: String, name: String, deviceModel: String, systemVersion: String) {
        self.id = id
        self.name = name
        self.deviceModel = deviceModel
        self.systemVersion = systemVersion
    }
}

public extension Notification.Name {
    static let DeviceSpoofSettingsChanged = Notification.Name("DeviceSpoofSettingsChanged")
}

@objc public final class DeviceSpoofManager: NSObject {
    @objc public static let shared = DeviceSpoofManager()

    private let defaults = UserDefaults.standard

    public static let defaultProfiles: [DeviceProfile] = [
        DeviceProfile(id: "iphone15promax", name: "iPhone 15 Pro Max", deviceModel: "iPhone 15 Pro Max", systemVersion: "iOS 17.5.1"),
        DeviceProfile(id: "s23", name: "Samsung Galaxy S23", deviceModel: "Samsung Galaxy S23", systemVersion: "Android 14"),
        DeviceProfile(id: "sms918b", name: "Samsung SM-S918B", deviceModel: "Samsung SM-S918B", systemVersion: "Android 14"),
        DeviceProfile(id: "pixel8pro", name: "Google Pixel 8 Pro", deviceModel: "Google Pixel 8 Pro", systemVersion: "Android 14"),
        DeviceProfile(id: "xiaomi2311", name: "Xiaomi 2311DRK48G", deviceModel: "Xiaomi 2311DRK48G", systemVersion: "Android 14")
    ]

    private override init() {
        super.init()
        if !defaults.bool(forKey: "DeviceSpoof.didCompleteFirstRun_v1") {
            defaults.set(true, forKey: "DeviceSpoof.didCompleteFirstRun_v1")
            if defaults.object(forKey: "DeviceSpoof.selectedProfileId") == nil {
                defaults.set("iphone15promax", forKey: "DeviceSpoof.selectedProfileId")
            }
        }
    }

    @objc public var isEnabled: Bool {
        get {
            return defaults.bool(forKey: "DeviceSpoof.isEnabled")
        }
        set {
            defaults.set(newValue, forKey: "DeviceSpoof.isEnabled")
            defaults.set(true, forKey: "DeviceSpoof.hasExplicitConfiguration")
            notifyChanged()
        }
    }

    public var selectedProfileId: String {
        get {
            return defaults.string(forKey: "DeviceSpoof.selectedProfileId") ?? "iphone15promax"
        }
        set {
            defaults.set(newValue, forKey: "DeviceSpoof.selectedProfileId")
            notifyChanged()
        }
    }

    public var customDeviceModel: String {
        get {
            return defaults.string(forKey: "DeviceSpoof.customDeviceModel") ?? ""
        }
        set {
            defaults.set(newValue, forKey: "DeviceSpoof.customDeviceModel")
            notifyChanged()
        }
    }

    public var customSystemVersion: String {
        get {
            return defaults.string(forKey: "DeviceSpoof.customSystemVersion") ?? ""
        }
        set {
            defaults.set(newValue, forKey: "DeviceSpoof.customSystemVersion")
            notifyChanged()
        }
    }

    @objc public var currentDeviceModel: String? {
        guard isEnabled else { return nil }
        if selectedProfileId == "custom" {
            let trimmed = customDeviceModel.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "iPhone 15 Pro Max" : trimmed
        }
        if let profile = Self.defaultProfiles.first(where: { $0.id == selectedProfileId }) {
            return profile.deviceModel
        }
        return "iPhone 15 Pro Max"
    }

    @objc public var currentSystemVersion: String? {
        guard isEnabled else { return nil }
        if selectedProfileId == "custom" {
            let trimmed = customSystemVersion.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "iOS 17.5.1" : trimmed
        }
        if let profile = Self.defaultProfiles.first(where: { $0.id == selectedProfileId }) {
            return profile.systemVersion
        }
        return "iOS 17.5.1"
    }

    private func notifyChanged() {
        NotificationCenter.default.post(name: .DeviceSpoofSettingsChanged, object: self)
    }
}
