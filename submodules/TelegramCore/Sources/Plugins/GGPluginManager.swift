import Foundation

public struct GGPluginManifest: Codable {
    public let id: String
    public let name: String
    public let version: String
    public let author: String?
    public let description: String?
    public let script: String?

    public init(id: String, name: String, version: String, author: String? = nil, description: String? = nil, script: String? = nil) {
        self.id = id
        self.name = name
        self.version = version
        self.author = author
        self.description = description
        self.script = script
    }
}

public struct GGPluginRegisteredAction {
    public let id: String
    public let title: String
    public let handler: () -> Void

    public init(id: String, title: String, handler: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.handler = handler
    }
}

public final class GGPluginActionRegistryBuiltins {
    public static let shared = GGPluginActionRegistryBuiltins()
    private var actions: [String: GGPluginRegisteredAction] = [:]

    private init() {}

    public func register(action: GGPluginRegisteredAction) {
        actions[action.id] = action
    }

    public func execute(actionId: String) {
        actions[actionId]?.handler()
    }
}

public final class GGPluginStore {
    public static let shared = GGPluginStore()
    private var plugins: [String: GGPluginManifest] = [:]

    private init() {}

    public func allPlugins() -> [GGPluginManifest] {
        return Array(plugins.values)
    }

    public func addPlugin(_ plugin: GGPluginManifest) {
        plugins[plugin.id] = plugin
    }

    public func removePlugin(id: String) {
        plugins.removeValue(forKey: id)
    }
}

public final class GGPluginConsole {
    public static let shared = GGPluginConsole()
    private var logs: [String] = []

    private init() {}

    public func log(_ message: String) {
        logs.append(message)
    }

    public func getLogs() -> [String] {
        return logs
    }

    public func clear() {
        logs.removeAll()
    }
}

public final class GGPluginDevBridgeClient {
    public static let shared = GGPluginDevBridgeClient()
    private init() {}
    public func connect(to host: String, port: Int) {}
}

public final class GGPluginMarketplaceManager {
    public static let shared = GGPluginMarketplaceManager()
    private init() {}
}

public final class GGPluginMarketplaceImageStore {
    public static let shared = GGPluginMarketplaceImageStore()
    private init() {}
}

public final class GGPluginObjCReflection {
    public static let shared = GGPluginObjCReflection()
    private init() {}
}

public final class GGPluginUITreeWalker {
    public static let shared = GGPluginUITreeWalker()
    private init() {}
}

public final class GGPluginChatListBridgeStub {
    public static let shared = GGPluginChatListBridgeStub()
    private init() {}
}

public final class GGPluginFileBridgeStub {
    public static let shared = GGPluginFileBridgeStub()
    private init() {}
}

public final class GGPluginProfileBridgeStub {
    public static let shared = GGPluginProfileBridgeStub()
    private init() {}
}

public final class GGPluginSettingsBridgeStub {
    public static let shared = GGPluginSettingsBridgeStub()
    private init() {}
}

public final class GGPluginRuntime {
    public static let shared = GGPluginRuntime()
    private init() {}

    public func execute(script: String) {
        GGPluginConsole.shared.log("Executing script: \(script.prefix(50))...")
    }
}

public final class GGPluginManager {
    public static let shared = GGPluginManager()

    private let defaults = UserDefaults.standard

    private init() {}

    public var isEnabled: Bool {
        get { return defaults.bool(forKey: "GG.plugins.enabled") }
        set { defaults.set(newValue, forKey: "GG.plugins.enabled") }
    }
}
