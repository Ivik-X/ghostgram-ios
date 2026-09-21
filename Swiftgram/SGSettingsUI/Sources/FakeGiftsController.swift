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

private enum FakeGiftsSection: Int32 {
    case enable
    case items
    case actions
}

private enum FakeGiftsEntry: ItemListNodeEntry {
    case enableHeader(PresentationTheme, String)
    case enableToggle(PresentationTheme, String, Bool)
    case enableNotice(PresentationTheme, String)
    case itemsHeader(PresentationTheme, String)
    case itemEntry(PresentationTheme, String, String, Int32)
    case actionsHeader(PresentationTheme, String)
    case clearAll(PresentationTheme, String)

    var section: ItemListSectionId {
        switch self {
        case .enableHeader, .enableToggle, .enableNotice:
            return FakeGiftsSection.enable.rawValue
        case .itemsHeader, .itemEntry:
            return FakeGiftsSection.items.rawValue
        case .actionsHeader, .clearAll:
            return FakeGiftsSection.actions.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .enableHeader: return 0
        case .enableToggle: return 1
        case .enableNotice: return 2
        case .itemsHeader: return 3
        case let .itemEntry(_, _, _, id): return 4 + id
        case .actionsHeader: return 1000
        case .clearAll: return 1001
        }
    }

    static func ==(lhs: FakeGiftsEntry, rhs: FakeGiftsEntry) -> Bool {
        return lhs.stableId == rhs.stableId
    }

    static func <(lhs: FakeGiftsEntry, rhs: FakeGiftsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let args = arguments as! FakeGiftsControllerArguments
        switch self {
        case let .enableHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .enableToggle(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleEnabled(v)
            })
        case let .enableNotice(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .itemsHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .itemEntry(_, title, subtitle, _):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: subtitle, sectionId: self.section, style: .blocks, action: {})
        case let .actionsHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .clearAll(_, title):
            return ItemListActionItem(presentationData: presentationData, title: title, kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                args.clearAll()
            })
        }
    }
}

private final class FakeGiftsControllerArguments {
    let toggleEnabled: (Bool) -> Void
    let clearAll: () -> Void

    init(toggleEnabled: @escaping (Bool) -> Void, clearAll: @escaping () -> Void) {
        self.toggleEnabled = toggleEnabled
        self.clearAll = clearAll
    }
}

public func fakeGiftsController(context: AccountContext) -> ViewController {
    let arguments = FakeGiftsControllerArguments(
        toggleEnabled: { v in
            GGFakeGiftsManager.shared.isEnabled = v
        },
        clearAll: {
            GGFakeGiftsManager.shared.clearAll()
        }
    )

    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<FakeGiftsEntry>, FakeGiftsEntry.ItemGenerationArguments)) in
            var entries: [FakeGiftsEntry] = []
            let isEnabled = GGFakeGiftsManager.shared.isEnabled

            entries.append(.enableHeader(presentationData.theme, "ФЕЙКОВЫЕ ПОДАРКИ"))
            entries.append(.enableToggle(presentationData.theme, "Включить фейковые подарки", isEnabled))
            entries.append(.enableNotice(presentationData.theme, "Позволяет отображать любые звездные подарки в вашем профиле локально."))

            if isEnabled {
                entries.append(.actionsHeader(presentationData.theme, "УПРАВЛЕНИЕ"))
                entries.append(.clearAll(presentationData.theme, "Очистить все фейковые подарки"))
            }

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Фейковые подарки"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, arguments))
        })

    return controller
}
