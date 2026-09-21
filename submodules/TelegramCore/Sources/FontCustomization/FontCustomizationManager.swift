import Foundation
import CoreGraphics

public enum TripleTapDeleteMode: String, CaseIterable, Codable {
    case none
    case local
    case everyone
}

public enum ReadStatusColorMode: String, CaseIterable, Codable {
    case blue
    case gray
    case custom
}

public enum HiddenSettingsItem: String, CaseIterable, Codable {
    case passport
    case watch
    case myProfile
    case support
    case tips
    case wallet
}

public enum GhostgramFont: String, CaseIterable, Codable {
    case system = "System"
    case mononoki = "mononoki-Regular"
    case sourceCodePro = "SourceCodePro-Regular"
    case robotoMono = "RobotoMono-Regular"
    case liberationSerif = "LiberationSerif-Regular"
    case sourceSerifPro = "SourceSerifPro-Regular"
    case merriweather = "Merriweather-Regular"
    case nanumSquareRoundR = "NanumSquareRoundR"
    case nanumSquareRoundB = "NanumSquareRoundB"
    case sourceSansPro = "SourceSansPro-Regular"
    case sourceSansProBold = "SourceSansPro-Bold"
    case workSans = "WorkSans-Regular"
    case metropolis = "Metropolis-Regular"
    case montserrat = "Montserrat-Regular"
    case openSans = "OpenSans-Regular"
}

public extension Notification.Name {
    static let FontCustomizationSettingsChanged = Notification.Name("FontCustomizationSettingsChanged")
}

@objc public final class FontCustomizationManager: NSObject {
    @objc public static let shared = FontCustomizationManager()

    private let defaults = UserDefaults.standard

    private override init() {
        super.init()
    }

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: "FontCustomization.isEnabled") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.isEnabled")
            notifyChanged()
        }
    }

    public var isCustomSelected: Bool {
        get { return defaults.bool(forKey: "FontCustomization.isCustomSelected") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.isCustomSelected")
            notifyChanged()
        }
    }

    public var selectedFont: String {
        get { return defaults.string(forKey: "FontCustomization.selectedFont") ?? GhostgramFont.system.rawValue }
        set {
            defaults.set(newValue, forKey: "FontCustomization.selectedFont")
            notifyChanged()
        }
    }

    public var importedFontPath: String? {
        get { return defaults.string(forKey: "FontCustomization.importedFontPath") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.importedFontPath")
            notifyChanged()
        }
    }

    public var showExactLastSeen: Bool {
        get { return defaults.bool(forKey: "FontCustomization.showExactLastSeen") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.showExactLastSeen")
            notifyChanged()
        }
    }

    public var showConnectionStatusText: Bool {
        get { return defaults.bool(forKey: "FontCustomization.showConnectionStatusText") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.showConnectionStatusText")
            notifyChanged()
        }
    }

    public var useTelegramServerTranscription: Bool {
        get { return defaults.bool(forKey: "FontCustomization.useTelegramServerTranscription") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.useTelegramServerTranscription")
            notifyChanged()
        }
    }

    public var squareAvatarsInChatList: Bool {
        get { return defaults.bool(forKey: "FontCustomization.squareAvatarsInChatList") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.squareAvatarsInChatList")
            notifyChanged()
        }
    }

    public var roundAvatarsInForums: Bool {
        get { return defaults.bool(forKey: "FontCustomization.roundAvatarsInForums") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.roundAvatarsInForums")
            notifyChanged()
        }
    }

    public var tabBarUnifiedSearch: Bool {
        get { return defaults.bool(forKey: "FontCustomization.tabBarUnifiedSearch") }
        set {
            defaults.set(newValue, forKey: "FontCustomization.tabBarUnifiedSearch")
            notifyChanged()
        }
    }

    public var avatarSquarenessLevel: CGFloat {
        get {
            let val = defaults.double(forKey: "FontCustomization.avatarSquarenessLevel")
            return val == 0 ? 0.2 : CGFloat(val)
        }
        set {
            defaults.set(Double(newValue), forKey: "FontCustomization.avatarSquarenessLevel")
            notifyChanged()
        }
    }

    public var folderBarHeightOffset: CGFloat {
        get { return CGFloat(defaults.double(forKey: "FontCustomization.folderBarHeightOffset")) }
        set {
            defaults.set(Double(newValue), forKey: "FontCustomization.folderBarHeightOffset")
            notifyChanged()
        }
    }

    // Amoled & Appearance
    public var amoledTrueBlack: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.amoledTrueBlack") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.amoledTrueBlack")
            notifyChanged()
        }
    }

    public var hideCellSeparators: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideCellSeparators") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideCellSeparators")
            notifyChanged()
        }
    }

    public var amoledKeyboard: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.amoledKeyboard") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.amoledKeyboard")
            notifyChanged()
        }
    }

    public var senderMiniAvatars: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.senderMiniAvatars") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.senderMiniAvatars")
            notifyChanged()
        }
    }

    public var snowflakes: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.snowflakes") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.snowflakes")
            notifyChanged()
        }
    }

    public var inputBarHeightPadding: CGFloat {
        get { return CGFloat(defaults.double(forKey: "GG.fontCustomization.inputBarHeightPadding")) }
        set {
            defaults.set(Double(newValue), forKey: "GG.fontCustomization.inputBarHeightPadding")
            notifyChanged()
        }
    }

    public var tripleTapDeleteMode: TripleTapDeleteMode {
        get {
            guard let raw = defaults.string(forKey: "FontCustomization.tripleTapDeleteMode"),
                  let mode = TripleTapDeleteMode(rawValue: raw) else {
                return .none
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: "FontCustomization.tripleTapDeleteMode")
            notifyChanged()
        }
    }

    public var readStatusColorMode: ReadStatusColorMode {
        get {
            guard let raw = defaults.string(forKey: "FontCustomization.readStatusColorMode"),
                  let mode = ReadStatusColorMode(rawValue: raw) else {
                return .blue
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: "FontCustomization.readStatusColorMode")
            notifyChanged()
        }
    }

    public func isSettingHidden(_ item: HiddenSettingsItem) -> Bool {
        return defaults.bool(forKey: "FontCustomization.hiddenSettings.\(item.rawValue)")
    }

    public func setSettingHidden(_ item: HiddenSettingsItem, hidden: Bool) {
        defaults.set(hidden, forKey: "FontCustomization.hiddenSettings.\(item.rawValue)")
        notifyChanged()
    }

    private func notifyChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .FontCustomizationSettingsChanged, object: self)
        }
    }
}
