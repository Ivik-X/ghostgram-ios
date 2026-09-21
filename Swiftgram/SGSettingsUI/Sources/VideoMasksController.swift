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

public func videoMasksController(context: AccountContext) -> ViewController {
    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<VideoFeedEntry>, VideoFeedEntry.ItemGenerationArguments)) in
            var entries: [VideoFeedEntry] = []
            entries.append(.header(presentationData.theme, "ВИДЕОМАСКИ ДЛЯ КРУЖОЧКОВ"))
            entries.append(.toggle(presentationData.theme, "Маски и фильтры в камере", true))
            entries.append(.notice(presentationData.theme, "AR-маски, 3D элементы и фильтры лица при записи видеосообщений и историй."))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Видеомаски"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, ()))
        })

    return controller
}

public func ggMaskLibraryController(context: AccountContext) -> ViewController {
    return videoMasksController(context: context)
}

public func voiceCloneLibraryController(context: AccountContext) -> ViewController {
    let controller = ItemListController(context: context, state: context.sharedContext.presentationData
        |> map { presentationData -> (ItemListControllerState, (ItemListNodeState<VideoFeedEntry>, VideoFeedEntry.ItemGenerationArguments)) in
            var entries: [VideoFeedEntry] = []
            entries.append(.header(presentationData.theme, "КЛОНИРОВАНИЕ ГОЛОСА"))
            entries.append(.toggle(presentationData.theme, "Включить генерацию голоса", VoiceMorpherManager.shared.isEnabled))
            entries.append(.notice(presentationData.theme, "Преобразование текста и голосовых сообщений в голос знаменитостей и персонажей."))

            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Клонирование голоса"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(entries: entries, style: .blocks)
            return (controllerState, (listState, ()))
        })

    return controller
}
