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

    public var localStarsBalance: Int64? {
        get {
            let val = defaults.object(forKey: "GG.fontCustomization.localStarsBalance")
            if let num = val as? NSNumber {
                return num.int64Value
            } else if let str = val as? String, let num = Int64(str) {
                return num
            }
            return nil
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "GG.fontCustomization.localStarsBalance")
            } else {
                defaults.removeObject(forKey: "GG.fontCustomization.localStarsBalance")
            }
            notifyChanged()
        }
    }

    public var hideStarRatingBadge: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideStarRatingBadge") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideStarRatingBadge")
            notifyChanged()
        }
    }

    public var showPeerInfoShareButton: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.showPeerInfoShareButton") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.showPeerInfoShareButton")
            notifyChanged()
        }
    }

    public var autoMuteNewChannels: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.autoMuteNewChannels") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.autoMuteNewChannels")
            notifyChanged()
        }
    }

    public var readStatusColorEnabled: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.readStatusColorEnabled") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.readStatusColorEnabled")
            notifyChanged()
        }
    }

    public var readStatusCustomColor: Int32 {
        get { return Int32(defaults.integer(forKey: "GG.fontCustomization.readStatusCustomColor")) }
        set {
            defaults.set(Int(newValue), forKey: "GG.fontCustomization.readStatusCustomColor")
            notifyChanged()
        }
    }

    public var showChatListAccountSwitcher: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.showChatListAccountSwitcher") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.showChatListAccountSwitcher")
            notifyChanged()
        }
    }

    public var hideEditEmojiStatusAction: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideEditEmojiStatusAction") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideEditEmojiStatusAction")
            notifyChanged()
        }
    }

    public var settingsAccountsCollapsed: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.settingsAccountsCollapsed") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.settingsAccountsCollapsed")
            notifyChanged()
        }
    }

    public var hideEditProfileColorAction: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideEditProfileColorAction") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideEditProfileColorAction")
            notifyChanged()
        }
    }

    public var hideEditProfilePhotoAction: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideEditProfilePhotoAction") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideEditProfilePhotoAction")
            notifyChanged()
        }
    }

    public var hideChatListSearchBar: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideChatListSearchBar") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideChatListSearchBar")
            notifyChanged()
        }
    }

    public var hideProfileDescription: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideProfileDescription") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideProfileDescription")
            notifyChanged()
        }
    }

    public var androidChatList: Bool {
        get { return defaults.bool(forKey: "GG.ggdroid.androidChatList") }
        set {
            defaults.set(newValue, forKey: "GG.ggdroid.androidChatList")
            notifyChanged()
        }
    }

    public var contextShowLocalEdit: Bool {
        get { return defaults.bool(forKey: "GG.contextShowLocalEdit") }
        set {
            defaults.set(newValue, forKey: "GG.contextShowLocalEdit")
            notifyChanged()
        }
    }

    public var doubleTapToCopyIncoming: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.doubleTapToCopyIncoming") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.doubleTapToCopyIncoming")
            notifyChanged()
        }
    }

    public var snowflakesInChat: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.snowflakesInChat") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.snowflakesInChat")
            notifyChanged()
        }
    }

    public var snowflakesIntensity: Double {
        get {
            let val = defaults.double(forKey: "GG.fontCustomization.snowflakesIntensity")
            return val == 0.0 ? 1.0 : val
        }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.snowflakesIntensity")
            notifyChanged()
        }
    }

    public var chatListItemScale: Int32 {
        get { return Int32(defaults.integer(forKey: "GG.fontCustomization.chatListItemScale")) }
        set {
            defaults.set(Int(newValue), forKey: "GG.fontCustomization.chatListItemScale")
            notifyChanged()
        }
    }

    public var hideStoryCirclesInChatList: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.hideStoryCirclesInChatList") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.hideStoryCirclesInChatList")
            notifyChanged()
        }
    }

    public var storyCircleColor: Int32 {
        get { return Int32(defaults.integer(forKey: "GG.fontCustomization.storyCircleColor")) }
        set {
            defaults.set(Int(newValue), forKey: "GG.fontCustomization.storyCircleColor")
            notifyChanged()
        }
    }

    public var searchBarColorEnabled: Bool {
        get { return defaults.bool(forKey: "GG.fontCustomization.searchBarColorEnabled") }
        set {
            defaults.set(newValue, forKey: "GG.fontCustomization.searchBarColorEnabled")
            notifyChanged()
        }
    }

    public var searchBarColor: Int32 {
        get { return Int32(defaults.integer(forKey: "GG.fontCustomization.searchBarColor")) }
        set {
            defaults.set(Int(newValue), forKey: "GG.fontCustomization.searchBarColor")
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
