import Foundation
import Postbox
import TelegramApi

public final class MiscSettingsManager {
    public static let shared = MiscSettingsManager()
    
    private let defaults: UserDefaults
    
    public var bypassCopyProtection: Bool {
        get { return self.defaults.object(forKey: "miscBypassCopyProtection") == nil ? true : self.defaults.bool(forKey: "miscBypassCopyProtection") }
        set { self.defaults.set(newValue, forKey: "miscBypassCopyProtection") }
    }
    
    public var disableViewOnceAutoDelete: Bool {
        get { return self.defaults.object(forKey: "miscDisableViewOnceAutoDelete") == nil ? true : self.defaults.bool(forKey: "miscDisableViewOnceAutoDelete") }
        set { self.defaults.set(newValue, forKey: "miscDisableViewOnceAutoDelete") }
    }
    
    public var bypassScreenshotProtection: Bool {
        get { return self.defaults.object(forKey: "miscBypassScreenshotProtection") == nil ? true : self.defaults.bool(forKey: "miscBypassScreenshotProtection") }
        set { self.defaults.set(newValue, forKey: "miscBypassScreenshotProtection") }
    }
    
    public var blockAds: Bool {
        get { return self.defaults.object(forKey: "miscBlockAds") == nil ? true : self.defaults.bool(forKey: "miscBlockAds") }
        set { self.defaults.set(newValue, forKey: "miscBlockAds") }
    }
    
    public var alwaysOnline: Bool {
        get { return self.defaults.bool(forKey: "miscAlwaysOnline") }
        set { self.defaults.set(newValue, forKey: "miscAlwaysOnline") }
    }
    
    public var autoSendVideosAsRoundVideo: Bool {
        get { return self.defaults.bool(forKey: "miscAutoSendVideosAsRoundVideo") }
        set { self.defaults.set(newValue, forKey: "miscAutoSendVideosAsRoundVideo") }
    }
    
    public var antiSpoiler: Bool {
        get { return self.defaults.bool(forKey: "miscAntiSpoiler") }
        set { self.defaults.set(newValue, forKey: "miscAntiSpoiler") }
    }
    
    public var showPollResultsBeforeVoting: Bool {
        get { return self.defaults.object(forKey: "miscShowPollResultsBeforeVoting") == nil ? true : self.defaults.bool(forKey: "miscShowPollResultsBeforeVoting") }
        set { self.defaults.set(newValue, forKey: "miscShowPollResultsBeforeVoting") }
    }
    
    private init() {
        self.defaults = UserDefaults.standard
    }
}
