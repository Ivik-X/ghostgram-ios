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

private enum MessageBookmarksSection: Int32 {
    case info
    case list
}

private enum MessageBookmarksEntry: ItemListNodeEntry {
    case infoHeader(PresentationTheme, String)
    case infoNotice(PresentationTheme, String)
    case listHeader(PresentationTheme, String)
    case bookmarkItem(PresentationTheme, String, String, Int32, Int64, Int32)

    var section: ItemListSectionId {
        switch self {
        case .infoHeader, .infoNotice:
            return MessageBookmarksSection.info.rawValue
        case .listHeader, .bookmarkItem:
            return MessageBookmarksSection.list.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .infoHeader: return 0
        case .infoNotice: return 1
        case .listHeader: return 2
        case let .bookmarkItem(_, _, _, _, _, idx): return 3 + idx
        }
    }

    static func ==(lhs: MessageBookmarksEntry, rhs: MessageBookmarksEntry) -> Bool {
        return lhs.stableId == rhs.stableId
    }

    static func <(lhs: MessageBookmarksEntry, rhs: MessageBookmarksEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let args = arguments as! MessageBookmarksControllerArguments
        switch self {
        case let .infoHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .infoNotice(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .listHeader(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .bookmarkItem(_, title, subtitle, msgId, peerId, _):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: subtitle, sectionId: self.section, style: .blocks, action: {
                args.openMessage(msgId, peerId)
            })
        }
    }
}

private final class MessageBookmarksControllerArguments {
    let openMessage: (Int32, Int64) -> Void

    init(openMessage: @escaping (Int32, Int64) -> Void) {
        self.openMessage = openMessage
    }
}

public func messageBookmarksController(context: AccountContext) -> ViewController {
    let arguments = MessageBookmarksControllerArguments(
        openMessage: { msgId, peerId in
            // Navigate to message
        }
    )

    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<MessageBookmarksEntry>, MessageBookmarksEntry.ItemGenerationArguments)) in
            var entries: [MessageBookmarksEntry] = []
            let bookmarks = MessageBookmarkManager.shared.allBookmarks()

            entries.append(.infoHeader(presentationData.theme, "ЗАКЛАДКИ СООБЩЕНИЙ"))
            entries.append(.infoNotice(presentationData.theme, "Сохранённые сообщения хранятся локально на вашем устройстве даже в случае их удаления в чатах."))

            entries.append(.listHeader(presentationData.theme, "СОХРАНЁННЫЕ СООБЩЕНИЯ (\(bookmarks.count))"))
            for (idx, b) in bookmarks.enumerated() {
                let author = b.authorName ?? "Сообщение"
                let preview = b.text ?? "Медиа"
                entries.append(.bookmarkItem(presentationData.theme, author, preview, b.messageId, b.peerId, Int32(idx)))
            }

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Закладки"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, arguments))
        })

    return controller
}
