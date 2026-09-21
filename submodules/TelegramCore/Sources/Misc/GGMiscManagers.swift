import Foundation

public final class GGCallSettingsManager {
    public static let shared = GGCallSettingsManager()
    private let defaults = UserDefaults.standard
    private init() {}

    public var showCallStatsOverlay: Bool {
        get { return defaults.bool(forKey: "GG.callSettings.showStatsOverlay") }
        set { defaults.set(newValue, forKey: "GG.callSettings.showStatsOverlay") }
    }
}

public final class RoleManager {
    public static let shared = RoleManager()
    private let defaults = UserDefaults.standard
    private init() {}

    public var customRoleTitle: String? {
        get { return defaults.string(forKey: "org.ghostgram.RoleManager.title") }
        set { defaults.set(newValue, forKey: "org.ghostgram.RoleManager.title") }
    }
}

public final class RoundVideoSettingsManager {
    public static let shared = RoundVideoSettingsManager()
    private let defaults = UserDefaults.standard
    private init() {}

    public var roundVideoFlipAnimation: Bool {
        get { return defaults.bool(forKey: "MiscSettings.roundVideoFlipAnimation") }
        set { defaults.set(newValue, forKey: "MiscSettings.roundVideoFlipAnimation") }
    }
}

public final class SendDelayManager {
    public static let shared = SendDelayManager()
    private let defaults = UserDefaults.standard
    private init() {}

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: "SendDelay.enabled") }
        set { defaults.set(newValue, forKey: "SendDelay.enabled") }
    }

    public var delaySeconds: Int {
        get { return defaults.integer(forKey: "SendDelay.seconds") }
        set { defaults.set(newValue, forKey: "SendDelay.seconds") }
    }
}

public struct WordReplacementRule: Codable, Equatable {
    public let id: String
    public var pattern: String
    public var replacement: String
    public var isEnabled: Bool
    public var isRegex: Bool

    public init(id: String = UUID().uuidString, pattern: String, replacement: String, isEnabled: Bool = true, isRegex: Bool = false) {
        self.id = id
        self.pattern = pattern
        self.replacement = replacement
        self.isEnabled = isEnabled
        self.isRegex = isRegex
    }
}

public final class GGTextReplacementManager {
    public static let shared = GGTextReplacementManager()
    private let defaults = UserDefaults.standard
    private var rules: [WordReplacementRule] = []

    private init() {}

    public func applyReplacements(to text: String) -> String {
        var result = text
        for rule in rules where rule.isEnabled {
            if rule.isRegex {
                if let regex = try? NSRegularExpression(pattern: rule.pattern, options: []) {
                    result = regex.stringByReplacingMatches(in: result, options: [], range: NSRange(location: 0, length: result.utf16.count), withTemplate: rule.replacement)
                }
            } else {
                result = result.replacingOccurrences(of: rule.pattern, with: rule.replacement)
            }
        }
        return result
    }
}

public final class GGIconPackManager {
    public static let shared = GGIconPackManager()
    private init() {}
}

public final class GGLocalizationManager {
    public static let shared = GGLocalizationManager()
    private init() {}
}

public final class GGAboutManager {
    public static let shared = GGAboutManager()
    private init() {}
}

public final class GGAccountConfigManager {
    public static let shared = GGAccountConfigManager()
    private init() {}
}

public final class GGDeviceKeyManager {
    public static let shared = GGDeviceKeyManager()
    private init() {}
}

public final class GGDroidManager {
    public static let shared = GGDroidManager()
    private init() {}
}

public final class GGBurmaldaManager {
    public static let shared = GGBurmaldaManager()
    private init() {}
}

public final class GGRemotePublicKeyStore {
    public static let shared = GGRemotePublicKeyStore()
    private init() {}
}
