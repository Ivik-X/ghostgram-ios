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

public func pluginListController(context: AccountContext) -> ViewController {
    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<VideoFeedEntry>, VideoFeedEntry.ItemGenerationArguments)) in
            var entries: [VideoFeedEntry] = []
            entries.append(.header(presentationData.theme, "ПЛАГИНЫ И СКРИПТЫ"))
            entries.append(.toggle(presentationData.theme, "Движок плагинов", GGPluginManager.shared.isEnabled))
            entries.append(.notice(presentationData.theme, "Поддержка пользовательских плагинов на JavaScript, расширяющих интерфейс и функции Telegram."))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Плагины"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, ()))
        })

    return controller
}

public func ggPluginAPIDocsController(context: AccountContext) -> ViewController {
    return pluginListController(context: context)
}

public func ggPluginEditorController(context: AccountContext) -> ViewController {
    return pluginListController(context: context)
}
