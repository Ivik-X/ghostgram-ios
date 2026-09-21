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

public func antiDeleteFolderExclusionsController(context: AccountContext) -> ViewController {
    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<VideoFeedEntry>, VideoFeedEntry.ItemGenerationArguments)) in
            var entries: [VideoFeedEntry] = []
            entries.append(.header(presentationData.theme, "ИСКЛЮЧЕНИЯ АНТИ-УДАЛЕНИЯ"))
            entries.append(.notice(presentationData.theme, "Выберите папки или чаты, в которых удаленные сообщения не должны сохраняться."))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Исключения"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, ()))
        })

    return controller
}

public func ghostModeFolderExclusionsController(context: AccountContext) -> ViewController {
    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<VideoFeedEntry>, VideoFeedEntry.ItemGenerationArguments)) in
            var entries: [VideoFeedEntry] = []
            entries.append(.header(presentationData.theme, "ИСКЛЮЧЕНИЯ ПРИЗРАКА"))
            entries.append(.notice(presentationData.theme, "Выберите папки или чаты, в которых скрытный режим будет автоматически отключаться."))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Исключения"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, ()))
        })

    return controller
}
