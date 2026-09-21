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

private enum VideoFeedSection: Int32 {
    case general
}

private enum VideoFeedEntry: ItemListNodeEntry {
    case header(PresentationTheme, String)
    case toggle(PresentationTheme, String, Bool)
    case notice(PresentationTheme, String)

    var section: ItemListSectionId {
        return VideoFeedSection.general.rawValue
    }

    var stableId: Int32 {
        switch self {
        case .header: return 0
        case .toggle: return 1
        case .notice: return 2
        }
    }

    static func ==(lhs: VideoFeedEntry, rhs: VideoFeedEntry) -> Bool {
        return lhs.stableId == rhs.stableId
    }

    static func <(lhs: VideoFeedEntry, rhs: VideoFeedEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let args = arguments as! VideoFeedControllerArguments
        switch self {
        case let .header(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, multiline: false, sectionId: self.section)
        case let .toggle(_, title, val):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: val, sectionId: self.section, style: .blocks, updated: { v in
                args.toggle(v)
            })
        case let .notice(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private final class VideoFeedControllerArguments {
    let toggle: (Bool) -> Void
    init(toggle: @escaping (Bool) -> Void) {
        self.toggle = toggle
    }
}

public func videoFeedScreenController(context: AccountContext) -> ViewController {
    let arguments = VideoFeedControllerArguments(
        toggle: { v in
            VideoFeedManager.shared.isEnabled = v
        }
    )

    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<VideoFeedEntry>, VideoFeedEntry.ItemGenerationArguments)) in
            var entries: [VideoFeedEntry] = []
            entries.append(.header(presentationData.theme, "ЛЕНТА ВИДЕО"))
            entries.append(.toggle(presentationData.theme, "Включить видеоленту", VideoFeedManager.shared.isEnabled))
            entries.append(.notice(presentationData.theme, "Бесконечная лента коротких видео и кружочков из ваших каналов в стиле TikTok/Reels."))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Видеолента"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, arguments))
        })

    return controller
}
