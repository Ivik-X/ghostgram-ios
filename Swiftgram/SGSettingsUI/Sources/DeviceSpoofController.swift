import Foundation
import UIKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext

private enum DeviceSpoofSection: Int32 {
    case enable
    case profiles
    case custom
}

private enum DeviceSpoofEntry: ItemListNodeEntry {
    case enableHeader(PresentationTheme, String)
    case enableToggle(PresentationTheme, String, Bool)
    case enableNotice(PresentationTheme, String)
    case profilesHeader(PresentationTheme, String)
    case profileItem(PresentationTheme, String, String, Bool, Int)
    case customHeader(PresentationTheme, String)
    case customDeviceModel(PresentationTheme, String, String)
    case customSystemVersion(PresentationTheme, String, String)

    var section: ItemListSectionId {
        switch self {
        case .enableHeader, .enableToggle, .enableNotice:
            return DeviceSpoofSection.enable.rawValue
        case .profilesHeader, .profileItem:
            return DeviceSpoofSection.profiles.rawValue
        case .customHeader, .customDeviceModel, .customSystemVersion:
            return DeviceSpoofSection.custom.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .enableHeader: return 0
        case .enableToggle: return 1
        case .enableNotice: return 2
        case .profilesHeader: return 3
        case let .profileItem(_, _, _, _, index): return 4 + Int32(index)
        case .customHeader: return 20
        case .customDeviceModel: return 21
        case .customSystemVersion: return 22
        }
    }

    static func ==(lhs: DeviceSpoofEntry, rhs: DeviceSpoofEntry) -> Bool {
        switch (lhs, rhs) {
        case let (.enableHeader(lTheme, lText), .enableHeader(rTheme, rText)):
            return lTheme === rTheme && lText == rText
        case let (.enableToggle(lTheme, lText, lVal), .enableToggle(rTheme, rText, rVal)):
            return lTheme === rTheme && lText == rText && lVal == rVal
        case let (.enableNotice(lTheme, lText), .enableNotice(rTheme, rText)):
            return lTheme === rTheme && lText == rText
        case let (.profilesHeader(lTheme, lText), .profilesHeader(rTheme, rText)):
            return lTheme === rTheme && lText == rText
        case let (.profileItem(lTheme, lTitle, lSub, lSel, lIdx), .profileItem(rTheme, rTitle, rSub, rSel, rIdx)):
            return lTheme === rTheme && lTitle == rTitle && lSub == rSub && lSel == rSel && lIdx == rIdx
        case let (.customHeader(lTheme, lText), .customHeader(rTheme, rText)):
            return lTheme === rTheme && lText == rText
        case let (.customDeviceModel(lTheme, lTitle, lVal), .customDeviceModel(rTheme, rTitle, rVal)):
            return lTheme === rTheme && lTitle == rTitle && lVal == rVal
        case let (.customSystemVersion(lTheme, lTitle, lVal), .customSystemVersion(rTheme, rTitle, rVal)):
            return lTheme === rTheme && lTitle == rTitle && lVal == rVal
        default:
            return false
        }
    }

    static func <(lhs: DeviceSpoofEntry, rhs: DeviceSpoofEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let args = arguments as! DeviceSpoofControllerArguments
        switch self {
        case let .enableHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .enableToggle(_, title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { val in
                args.toggleEnabled(val)
            })
        case let .enableNotice(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .profilesHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .profileItem(_, title, subtitle, selected, _):
            return ItemListCheckboxItem(presentationData: presentationData, title: title, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                args.selectProfile(title)
            })
        case let .customHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .customDeviceModel(_, title, value):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: value.isEmpty ? "Не задано" : value, sectionId: self.section, style: .blocks, action: {
                args.editCustomModel()
            })
        case let .customSystemVersion(_, title, value):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: value.isEmpty ? "Не задано" : value, sectionId: self.section, style: .blocks, action: {
                args.editCustomVersion()
            })
        }
    }
}

private final class DeviceSpoofControllerArguments {
    let toggleEnabled: (Bool) -> Void
    let selectProfile: (String) -> Void
    let editCustomModel: () -> Void
    let editCustomVersion: () -> Void

    init(toggleEnabled: @escaping (Bool) -> Void, selectProfile: @escaping (String) -> Void, editCustomModel: @escaping () -> Void, editCustomVersion: @escaping () -> Void) {
        self.toggleEnabled = toggleEnabled
        self.selectProfile = selectProfile
        self.editCustomModel = editCustomModel
        self.editCustomVersion = editCustomVersion
    }
}

public func deviceSpoofController(context: AccountContext) -> ViewController {
    let arguments = DeviceSpoofControllerArguments(
        toggleEnabled: { enabled in
            DeviceSpoofManager.shared.isEnabled = enabled
        },
        selectProfile: { title in
            if let profile = DeviceSpoofManager.defaultProfiles.first(where: { $0.name == title }) {
                DeviceSpoofManager.shared.selectedProfileId = profile.id
            } else {
                DeviceSpoofManager.shared.selectedProfileId = "custom"
            }
        },
        editCustomModel: {},
        editCustomVersion: {}
    )

    let signal = NotificationCenter.default.makeSignal(for: .DeviceSpoofSettingsChanged)
        |> map { _ in () }
        |> take(1)

    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<DeviceSpoofEntry>, DeviceSpoofEntry.ItemGenerationArguments)) in
            var entries: [DeviceSpoofEntry] = []
            let isEnabled = DeviceSpoofManager.shared.isEnabled
            let selectedProfileId = DeviceSpoofManager.shared.selectedProfileId

            entries.append(.enableHeader(presentationData.theme, "ПОДМЕНА УСТРОЙСТВА"))
            entries.append(.enableToggle(presentationData.theme, "Включить спуфинг", isEnabled))
            entries.append(.enableNotice(presentationData.theme, "Telegram и собеседники в звонках будут видеть выбранное устройство вместо вашего настоящего."))

            if isEnabled {
                entries.append(.profilesHeader(presentationData.theme, "ГОТОВЫЕ ПРОФИЛИ"))
                for (idx, profile) in DeviceSpoofManager.defaultProfiles.enumerated() {
                    entries.append(.profileItem(presentationData.theme, profile.name, "\(profile.deviceModel) • \(profile.systemVersion)", profile.id == selectedProfileId, idx))
                }
                entries.append(.profileItem(presentationData.theme, "Своё устройство", "Пользовательские параметры", selectedProfileId == "custom", DeviceSpoofManager.defaultProfiles.count))

                if selectedProfileId == "custom" {
                    entries.append(.customHeader(presentationData.theme, "ПАРАМЕТРЫ СВОЕГО УСТРОЙСТВА"))
                    entries.append(.customDeviceModel(presentationData.theme, "Модель устройства", DeviceSpoofManager.shared.customDeviceModel))
                    entries.append(.customSystemVersion(presentationData.theme, "Версия ОС", DeviceSpoofManager.shared.customSystemVersion))
                }
            }

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Подмена устройства"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, arguments))
        })

    return controller
}

private extension NotificationCenter {
    func makeSignal(for name: Notification.Name) -> Signal<Void, NoError> {
        return Signal { subscriber in
            let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
                subscriber.putNext(())
            }
            return ActionDisposable {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
