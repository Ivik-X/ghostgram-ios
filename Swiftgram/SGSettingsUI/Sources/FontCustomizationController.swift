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

private enum FontCustomizationSection: Int32 {
    case fonts
    case appearance
    case chatList
    case behavior
}

private enum FontCustomizationEntry: ItemListNodeEntry {
    case fontsHeader(PresentationTheme, String)
    case fontsToggle(PresentationTheme, String, Bool)
    case fontOption(PresentationTheme, String, String, Bool, Int)
    case appearanceHeader(PresentationTheme, String)
    case amoledTrueBlack(PresentationTheme, String, Bool)
    case amoledKeyboard(PresentationTheme, String, Bool)
    case hideCellSeparators(PresentationTheme, String, Bool)
    case snowflakes(PresentationTheme, String, Bool)
    case chatListHeader(PresentationTheme, String)
    case squareAvatars(PresentationTheme, String, Bool)
    case roundAvatarsInForums(PresentationTheme, String, Bool)
    case senderMiniAvatars(PresentationTheme, String, Bool)
    case showExactLastSeen(PresentationTheme, String, Bool)
    case showConnectionStatus(PresentationTheme, String, Bool)
    case unifiedSearch(PresentationTheme, String, Bool)
    case behaviorHeader(PresentationTheme, String)
    case tripleTapDelete(PresentationTheme, String, String)
    case readStatusColor(PresentationTheme, String, String)

    var section: ItemListSectionId {
        switch self {
        case .fontsHeader, .fontsToggle, .fontOption:
            return FontCustomizationSection.fonts.rawValue
        case .appearanceHeader, .amoledTrueBlack, .amoledKeyboard, .hideCellSeparators, .snowflakes:
            return FontCustomizationSection.appearance.rawValue
        case .chatListHeader, .squareAvatars, .roundAvatarsInForums, .senderMiniAvatars, .showExactLastSeen, .showConnectionStatus, .unifiedSearch:
            return FontCustomizationSection.chatList.rawValue
        case .behaviorHeader, .tripleTapDelete, .readStatusColor:
            return FontCustomizationSection.behavior.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .fontsHeader: return 0
        case .fontsToggle: return 1
        case let .fontOption(_, _, _, _, idx): return 2 + Int32(idx)
        case .appearanceHeader: return 50
        case .amoledTrueBlack: return 51
        case .amoledKeyboard: return 52
        case .hideCellSeparators: return 53
        case .snowflakes: return 54
        case .chatListHeader: return 100
        case .squareAvatars: return 101
        case .roundAvatarsInForums: return 102
        case .senderMiniAvatars: return 103
        case .showExactLastSeen: return 104
        case .showConnectionStatus: return 105
        case .unifiedSearch: return 106
        case .behaviorHeader: return 200
        case .tripleTapDelete: return 201
        case .readStatusColor: return 202
        }
    }

    static func ==(lhs: FontCustomizationEntry, rhs: FontCustomizationEntry) -> Bool {
        return lhs.stableId == rhs.stableId
    }

    static func <(lhs: FontCustomizationEntry, rhs: FontCustomizationEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let args = arguments as! FontCustomizationControllerArguments
        switch self {
        case let .fontsHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .fontsToggle(_, title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { val in
                args.toggleCustomFont(val)
            })
        case let .fontOption(_, title, fontName, selected, _):
            return ItemListCheckboxItem(presentationData: presentationData, title: title, style: .left, checked: selected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                args.selectFont(fontName)
            })
        case let .appearanceHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .amoledTrueBlack(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleAmoled(v)
            })
        case let .amoledKeyboard(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleAmoledKeyboard(v)
            })
        case let .hideCellSeparators(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleSeparators(v)
            })
        case let .snowflakes(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleSnowflakes(v)
            })
        case let .chatListHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .squareAvatars(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleSquareAvatars(v)
            })
        case let .roundAvatarsInForums(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleRoundForumAvatars(v)
            })
        case let .senderMiniAvatars(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleSenderMiniAvatars(v)
            })
        case let .showExactLastSeen(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleExactLastSeen(v)
            })
        case let .showConnectionStatus(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleConnectionStatus(v)
            })
        case let .unifiedSearch(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggleUnifiedSearch(v)
            })
        case let .behaviorHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .tripleTapDelete(_, title, label):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: label, sectionId: self.section, style: .blocks, action: {
                args.cycleTripleTapDelete()
            })
        case let .readStatusColor(_, title, label):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: label, sectionId: self.section, style: .blocks, action: {
                args.cycleReadStatusColor()
            })
        }
    }
}

private final class FontCustomizationControllerArguments {
    let toggleCustomFont: (Bool) -> Void
    let selectFont: (String) -> Void
    let toggleAmoled: (Bool) -> Void
    let toggleAmoledKeyboard: (Bool) -> Void
    let toggleSeparators: (Bool) -> Void
    let toggleSnowflakes: (Bool) -> Void
    let toggleSquareAvatars: (Bool) -> Void
    let toggleRoundForumAvatars: (Bool) -> Void
    let toggleSenderMiniAvatars: (Bool) -> Void
    let toggleExactLastSeen: (Bool) -> Void
    let toggleConnectionStatus: (Bool) -> Void
    let toggleUnifiedSearch: (Bool) -> Void
    let cycleTripleTapDelete: () -> Void
    let cycleReadStatusColor: () -> Void

    init(
        toggleCustomFont: @escaping (Bool) -> Void,
        selectFont: @escaping (String) -> Void,
        toggleAmoled: @escaping (Bool) -> Void,
        toggleAmoledKeyboard: @escaping (Bool) -> Void,
        toggleSeparators: @escaping (Bool) -> Void,
        toggleSnowflakes: @escaping (Bool) -> Void,
        toggleSquareAvatars: @escaping (Bool) -> Void,
        toggleRoundForumAvatars: @escaping (Bool) -> Void,
        toggleSenderMiniAvatars: @escaping (Bool) -> Void,
        toggleExactLastSeen: @escaping (Bool) -> Void,
        toggleConnectionStatus: @escaping (Bool) -> Void,
        toggleUnifiedSearch: @escaping (Bool) -> Void,
        cycleTripleTapDelete: @escaping () -> Void,
        cycleReadStatusColor: @escaping () -> Void
    ) {
        self.toggleCustomFont = toggleCustomFont
        self.selectFont = selectFont
        self.toggleAmoled = toggleAmoled
        self.toggleAmoledKeyboard = toggleAmoledKeyboard
        self.toggleSeparators = toggleSeparators
        self.toggleSnowflakes = toggleSnowflakes
        self.toggleSquareAvatars = toggleSquareAvatars
        self.toggleRoundForumAvatars = toggleRoundForumAvatars
        self.toggleSenderMiniAvatars = toggleSenderMiniAvatars
        self.toggleExactLastSeen = toggleExactLastSeen
        self.toggleConnectionStatus = toggleConnectionStatus
        self.toggleUnifiedSearch = toggleUnifiedSearch
        self.cycleTripleTapDelete = cycleTripleTapDelete
        self.cycleReadStatusColor = cycleReadStatusColor
    }
}

public func fontCustomizationController(context: AccountContext) -> ViewController {
    let arguments = FontCustomizationControllerArguments(
        toggleCustomFont: { v in FontCustomizationManager.shared.isEnabled = v },
        selectFont: { f in FontCustomizationManager.shared.selectedFont = f },
        toggleAmoled: { v in FontCustomizationManager.shared.amoledTrueBlack = v },
        toggleAmoledKeyboard: { v in FontCustomizationManager.shared.amoledKeyboard = v },
        toggleSeparators: { v in FontCustomizationManager.shared.hideCellSeparators = v },
        toggleSnowflakes: { v in FontCustomizationManager.shared.snowflakes = v },
        toggleSquareAvatars: { v in FontCustomizationManager.shared.squareAvatarsInChatList = v },
        toggleRoundForumAvatars: { v in FontCustomizationManager.shared.roundAvatarsInForums = v },
        toggleSenderMiniAvatars: { v in FontCustomizationManager.shared.senderMiniAvatars = v },
        toggleExactLastSeen: { v in FontCustomizationManager.shared.showExactLastSeen = v },
        toggleConnectionStatus: { v in FontCustomizationManager.shared.showConnectionStatusText = v },
        toggleUnifiedSearch: { v in FontCustomizationManager.shared.tabBarUnifiedSearch = v },
        cycleTripleTapDelete: {
            let current = FontCustomizationManager.shared.tripleTapDeleteMode
            switch current {
            case .none: FontCustomizationManager.shared.tripleTapDeleteMode = .local
            case .local: FontCustomizationManager.shared.tripleTapDeleteMode = .everyone
            case .everyone: FontCustomizationManager.shared.tripleTapDeleteMode = .none
            }
        },
        cycleReadStatusColor: {
            let current = FontCustomizationManager.shared.readStatusColorMode
            switch current {
            case .blue: FontCustomizationManager.shared.readStatusColorMode = .gray
            case .gray: FontCustomizationManager.shared.readStatusColorMode = .custom
            case .custom: FontCustomizationManager.shared.readStatusColorMode = .blue
            }
        }
    )

    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<FontCustomizationEntry>, FontCustomizationEntry.ItemGenerationArguments)) in
            var entries: [FontCustomizationEntry] = []
            let mgr = FontCustomizationManager.shared

            entries.append(.fontsHeader(presentationData.theme, "ШРИФТЫ"))
            entries.append(.fontsToggle(presentationData.theme, "Кастомный шрифт", mgr.isEnabled))
            if mgr.isEnabled {
                for (idx, font) in GhostgramFont.allCases.enumerated() {
                    entries.append(.fontOption(presentationData.theme, font.rawValue, font.rawValue, mgr.selectedFont == font.rawValue, idx))
                }
            }

            entries.append(.appearanceHeader(presentationData.theme, "ОФОРМЛЕНИЕ И ЦВЕТА"))
            entries.append(.amoledTrueBlack(presentationData.theme, "AMOLED True Black", mgr.amoledTrueBlack))
            entries.append(.amoledKeyboard(presentationData.theme, "AMOLED Клавиатура", mgr.amoledKeyboard))
            entries.append(.hideCellSeparators(presentationData.theme, "Скрыть разделители ячеек", mgr.hideCellSeparators))
            entries.append(.snowflakes(presentationData.theme, "Снежинки в чатах", mgr.snowflakes))

            entries.append(.chatListHeader(presentationData.theme, "СПИСОК ЧАТОВ И АВАТАРЫ"))
            entries.append(.squareAvatars(presentationData.theme, "Квадратные аватары в чатах", mgr.squareAvatarsInChatList))
            entries.append(.roundAvatarsInForums(presentationData.theme, "Круглые аватары в форумах", mgr.roundAvatarsInForums))
            entries.append(.senderMiniAvatars(presentationData.theme, "Мини-аватарки отправителя", mgr.senderMiniAvatars))
            entries.append(.showExactLastSeen(presentationData.theme, "Точное время «Был(а) в сети»", mgr.showExactLastSeen))
            entries.append(.showConnectionStatus(presentationData.theme, "Текст статуса подключения", mgr.showConnectionStatusText))
            entries.append(.unifiedSearch(presentationData.theme, "Универсальный поиск во вкладках", mgr.tabBarUnifiedSearch))

            entries.append(.behaviorHeader(presentationData.theme, "ДЕЙСТВИЯ И СТАТУСЫ"))
            let deleteLabel: String
            switch mgr.tripleTapDeleteMode {
            case .none: deleteLabel = "Выключено"
            case .local: deleteLabel = "Удалить у себя"
            case .everyone: deleteLabel = "Удалить у всех"
            }
            entries.append(.tripleTapDelete(presentationData.theme, "Удаление тройным тапом", deleteLabel))

            let statusLabel: String
            switch mgr.readStatusColorMode {
            case .blue: statusLabel = "Синий"
            case .gray: statusLabel = "Серый"
            case .custom: statusLabel = "Кастомный"
            }
            entries.append(.readStatusColor(presentationData.theme, "Цвет галочек прочтения", statusLabel))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Кастомизация UI"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, arguments))
        })

    return controller
}
